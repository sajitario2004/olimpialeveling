#!/usr/bin/env python3
"""
Herramienta de Consola para Gestionar y Editar Ejercicios de Olimpia Leveling.

Permite:
  1. Listar todos los ejercicios disponibles con sus fotos, vídeos de YouTube y XP asignada.
  2. Modificar la URL de la foto (image_url o gif_url) de cualquier ejercicio.
  3. Modificar el enlace a YouTube explicativo (youtube_url).
  4. Modificar la XP asignada a cada músculo y la XP base.
  5. Exportar los cambios directamente a 'app/assets/config/game_config.json' para que se incluyan en el próximo APK.

Uso:
  python3 server/edit_exercises.py               (Modo interactivo con menú)
  python3 server/edit_exercises.py --export      (Exporta config_data.json a assets del APK directamente)
  python3 server/edit_exercises.py --list        (Muestra la lista de ejercicios en consola)
"""

import sys
import json
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
DATA_FILE = BASE_DIR / "config_data.json"
DEFAULT_FILE = BASE_DIR / "default_config.json"
APK_CONFIG_FILE = BASE_DIR.parent / "app" / "assets" / "config" / "game_config.json"

def load_data():
    if DATA_FILE.exists():
        with open(DATA_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    elif DEFAULT_FILE.exists():
        with open(DEFAULT_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    else:
        print("❌ Error: No se encontró config_data.json ni default_config.json")
        sys.exit(1)

def save_data(data):
    with open(DATA_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print(f"✅ Guardado con éxito en: {DATA_FILE.name}")

def export_to_apk():
    data = load_data()
    APK_CONFIG_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(APK_CONFIG_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print(f"🚀 ¡EXPORTACIÓN EXITOSA A LA APP!\n   Archivo actualizado: {APK_CONFIG_FILE}")
    print("   Cuando compiles con 'flutter build apk', el APK contendrá estos ejercicios, fotos, vídeos y XP.")

def print_exercise_summary(ex, idx=None):
    idx_str = f"[{idx}] " if idx is not None else ""
    print(f"\n{idx_str}ID: {ex.get('id')} -> {ex.get('name')}")
    print(f"   Músculo principal: {ex.get('primary_muscle', '').upper()} ({ex.get('primary_xp_per_kg', 0)} XP/kg) | Base XP: {ex.get('base_xp', 20)}")
    
    muscles_xp = ex.get('muscles_xp') or []
    if muscles_xp:
        m_str = ", ".join([f"{m['muscle'].upper()}: {m['xp']} XP" for m in muscles_xp])
        print(f"   Reparto de músculos: {m_str}")
    
    img = ex.get('image_url') or ex.get('gif_url') or '(Sin imagen configurada)'
    yt = ex.get('youtube_url') or '(Sin enlace a YouTube)'
    print(f"   📸 Foto: {img}")
    print(f"   ▶️ YouTube: {yt}")

def list_exercises():
    data = load_data()
    exercises = data.get("exercises", [])
    print(f"\n=======================================================")
    print(f"📋 CATÁLOGO DE EJERCICIOS ({len(exercises)} ejercicios)")
    print(f"=======================================================")
    for idx, ex in enumerate(exercises, start=1):
        print_exercise_summary(ex, idx)
    print("=======================================================\n")

def edit_exercise_interactive():
    data = load_data()
    exercises = data.get("exercises", [])
    if not exercises:
        print("No hay ejercicios registrados.")
        return

    print("\nSelecciona el ejercicio que deseas editar:")
    for idx, ex in enumerate(exercises, start=1):
        print(f"  [{idx}] {ex.get('name')} ({ex.get('id')})")

    choice = input("\nIntroduce el número del ejercicio (o 'c' para cancelar): ").strip()
    if choice.lower() == 'c':
        return

    try:
        idx = int(choice) - 1
        if idx < 0 or idx >= len(exercises):
            print("Número no válido.")
            return
    except ValueError:
        print("Entrada no válida.")
        return

    ex = exercises[idx]
    print("\n--- Editando:", ex.get("name"), "---")
    print_exercise_summary(ex)

    print("\n¿Qué parámetro deseas editar?")
    print("  [1] Foto del ejercicio (URL)")
    print("  [2] Enlace a vídeo explicativo de YouTube")
    print("  [3] XP por kg / Reparto muscular de XP")
    print("  [4] XP Base por serie")
    print("  [5] Nombre o Descripción / Consejos")
    print("  [6] Modificar todo en secuencia")
    print("  [0] Volver sin cambios")

    sub_choice = input("\nElige una opción [0-6]: ").strip()

    if sub_choice == "1" or sub_choice == "6":
        current_img = ex.get("image_url", "")
        print(f"\nFoto actual: {current_img}")
        new_img = input("Nueva URL de imagen (deja vacío para mantener): ").strip()
        if new_img:
            ex["image_url"] = new_img

    if sub_choice == "2" or sub_choice == "6":
        current_yt = ex.get("youtube_url", "")
        print(f"\nYouTube actual: {current_yt}")
        new_yt = input("Nuevo enlace de YouTube (deja vacío para mantener): ").strip()
        if new_yt:
            ex["youtube_url"] = new_yt

    if sub_choice == "3" or sub_choice == "6":
        print("\n--- Configuración de XP por Músculo ---")
        muscles_xp = ex.get("muscles_xp") or []
        if not muscles_xp:
            muscles_xp = [{"muscle": ex.get("primary_muscle", "pecho"), "xp": float(ex.get("primary_xp_per_kg", 5.0))}]
            if ex.get("secondary_muscle"):
                muscles_xp.append({"muscle": ex.get("secondary_muscle"), "xp": float(ex.get("secondary_xp_per_kg", 2.0))})

        updated_muscles = []
        for m in muscles_xp:
            m_name = m["muscle"]
            current_rate = m["xp"]
            val_str = input(f"XP para músculo {m_name.upper()} [actual: {current_rate}]: ").strip()
            if val_str:
                try:
                    new_val = float(val_str)
                    updated_muscles.append({"muscle": m_name, "xp": new_val})
                except ValueError:
                    updated_muscles.append(m)
            else:
                updated_muscles.append(m)

        ex["muscles_xp"] = updated_muscles
        if updated_muscles:
            ex["primary_muscle"] = updated_muscles[0]["muscle"]
            ex["primary_xp_per_kg"] = updated_muscles[0]["xp"]
            if len(updated_muscles) > 1:
                ex["secondary_muscle"] = updated_muscles[1]["muscle"]
                ex["secondary_xp_per_kg"] = updated_muscles[1]["xp"]

    if sub_choice == "4" or sub_choice == "6":
        current_base = ex.get("base_xp", 20.0)
        val_str = input(f"\nXP Base por serie [actual: {current_base}]: ").strip()
        if val_str:
            try:
                ex["base_xp"] = float(val_str)
            except ValueError:
                pass

    if sub_choice == "5" or sub_choice == "6":
        current_tips = ex.get("tips", "")
        new_tips = input(f"\nConsejos técnicos de ejecución [actual: {current_tips}]: ").strip()
        if new_tips:
            ex["tips"] = new_tips

    exercises[idx] = ex
    data["exercises"] = exercises
    save_data(data)

    print("\n✅ Ejercicio actualizado exitosamente.")
    print_exercise_summary(ex)

    export_ans = input("\n¿Deseas exportar ahora a la APK (app/assets/config/game_config.json)? [S/n]: ").strip().lower()
    if export_ans != 'n':
        export_to_apk()

def main_menu():
    while True:
        print("\n=======================================================")
        print("🏛️  OLIMPIA LEVELING - EDITOR DE EJERCICIOS (PYTHON)")
        print("=======================================================")
        print("  [1] Listar todos los ejercicios")
        print("  [2] Editar un ejercicio (Foto, Vídeo YouTube, XP)")
        print("  [3] Exportar configuración para el próximo APK")
        print("  [4] Abrir Servidor Web Dashboard (localhost:8000)")
        print("  [0] Salir")
        print("=======================================================")

        opt = input("Elige una opción: ").strip()
        if opt == "1":
            list_exercises()
        elif opt == "2":
            edit_exercise_interactive()
        elif opt == "3":
            export_to_apk()
        elif opt == "4":
            print("\nIniciando servidor web FastAPI en http://localhost:8000 ...")
            print("Presiona Ctrl+C para detener el servidor y volver.\n")
            import uvicorn
            uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)
        elif opt == "0":
            print("Hasta pronto, Cazador.")
            break
        else:
            print("Opción no reconocida.")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        if "--export" in sys.argv:
            export_to_apk()
        elif "--list" in sys.argv:
            list_exercises()
        else:
            print(__doc__)
    else:
        main_menu()
