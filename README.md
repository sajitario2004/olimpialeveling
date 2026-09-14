# Olimpia Leveling

> **"De skinny bitch a dios del olimpo (despanchizado)"**

Aplicación de gamificación del entrenamiento en gimnasio inspirada en la interfaz holográfica del "Sistema" de **Solo Leveling** y la mitología del Olimpo.

---

## ⚡ Características Principales

1. **Nivel por Músculo & Nivel Total**:
   - Cada uno de los **14 músculos** tiene su propia barra de experiencia y nivel individual:
     - *Pecho, Tríceps, Bíceps, Antebrazo, Dorsales, Trapecio, Lumbar, Deltoides, Cuádriceps, Isquiotibiales, Glúteos, Gemelos, Abdominales y Oblicuos*.
   - La suma de todos los niveles musculares determina el **Nivel Total** del Cazador.

2. **Mapa Anatómico Interactivo (Frontal y Dorsal)**:
   - Pantalla principal con siluetas corporales lado a lado (Frente a la izquierda, Espalda a la derecha).
   - **Mapa de calor dinámico por nivel**:
     - Nivel 1-4: Gris / Skinny (`#64748B`)
     - Nivel 5-14: Azul Neón del Sistema (`#00F0FF`)
     - Nivel 15-29: Verde Cazador (`#10B981`)
     - Nivel 30-49: Oro Espartano (`#F59E0B`)
     - Nivel 50-79: Rojo Hércules (`#EF4444`)
     - Nivel 80+: Púrpura Divino del Olimpo (`#A855F7`)
   - Al tocar cualquier músculo, se abre la ventana holográfica con registro de series y cálculo de XP en tiempo real.

3. **Jerarquía del Olimpo (8 Rangos)**:
   - `SKINNYBITCH` ➔ `HUMAN` ➔ `NORMAL GYM BUDDY` ➔ `GYMBRO` ➔ `SOLDIER` ➔ `SPARTAN` ➔ `HERCULES` ➔ `GOD OF OLIMPUS`.

4. **Curva de Experiencia Recursiva (+15%)**:
   - Niveles 1-4: 100, 200, 300, 400 XP. Nivel 5: 1,000 XP.
   - A partir del Nivel 6: Cada nivel requiere un **15% más de XP compuesta** sobre el anterior ($1000 \times 1.15^{(L - 5)}$).

5. **Las 4 Pruebas Legendarias del Olimpo**:
   - Selección diaria entre: 100 Flexiones, 100 Sentadillas, 100 Abdominales o Carrera de 10 km.
   - Temporizador en cuenta regresiva hasta las 23:59:59.
   - **Penalización**: Si no se completa la misión antes de medianoche, el Sistema aplica **-1 Nivel Total**.
   - **Racha de Días**: 7+ días = +5% XP; 30+ días = +10% XP adicional.
   - **Tokens de Descanso**: 1 token cada 6 días de racha para descansar sin romper la racha.

6. **Mazmorras Semanales de Ascenso & Regla de Balance Muscular**:
   - Selección de sendero físico: Pecho, Espalda o Pierna.
   - **Regla inquebrantable**: Ningún músculo puede estar a más de 2 rangos por debajo del rango objetivo ($T - 2$). Si hay músculos rezagados, el acceso queda bloqueado indicando qué músculos entrenar primero.

7. **Calculadora Visual de Discos en Barra Olímpica**:
   - Barra olímpica de 20 kg con representación visual de manga y discos por colores reglamentarios.
   - Integrada en el modal de series para transferir el peso calculado directamente.

8. **Poder de Combate (Combat Power - CP)**:
   - Medidor de fuerza general calculado mediante: `(Nivel Total * 100) + (STR * 15) + (AGI * 10) + (END * 12) + (DIS * 8)`.

9. **Efectos Audiovisuales, Temporizador de Descanso & Anti-Cheat**:
   - Sonido "Ding!" del Sistema al subir de nivel y alarma de penalización.
   - Temporizador de descanso post-serie (60s, 90s, 120s, 180s) con alerta háptica y sonora.
   - Protección anti-cheat (<5s spam detection, máx 200 reps/set).

10. **Dashboard Web en Python (FastAPI)**:
    - Panel interactivo en `http://localhost:8000` con visualización de curva de XP, balanceo de ejercicios y simulador.

---

## 🚀 Puesta en Marcha

### 1. Iniciar el Servidor Python (Dashboard de Control)
```bash
cd server
pip install -r requirements.txt
python3 main.py
```
Abre en tu navegador: **http://localhost:8000**

### 2. Iniciar la App en Flutter
```bash
cd app
flutter pub get
# Ejecutar en macOS (escritorio):
flutter run -d macos

# O en tu dispositivo móvil / simulador:
flutter run
```

---

## 🧪 Pruebas Automatizadas

### Servidor Python
```bash
cd server
python3 -m pytest test_server.py -v
```

### App Flutter
```bash
cd app
flutter test
```
