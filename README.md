# Olimpia Leveling

> **"De skinny bitch a dios del olimpo (despanchizado)"**

![Version](https://img.shields.io/badge/version-0.1.1-blue.svg)
![Tests](https://img.shields.io/badge/tests-60%2F60%20passing-brightgreen.svg)
![Analysis](https://img.shields.io/badge/analysis-0%20issues-brightgreen.svg)

Aplicación de gamificación del entrenamiento en gimnasio inspirada en la interfaz holográfica del "Sistema" de **Solo Leveling** y la mitología del Olimpo.

---

## ⚡ Características Principales (v0.1.1)

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

11. **Prueba Suprema de Ascensión y Nivel 100**:
    - Al alcanzar el Nivel 100, la interfaz y el número se muestran en **Azul Imperial** (`#0D47A1` / `#64B5F6`) y el rango se mantiene en **HERCULES**.
    - Se desbloquea la **Prueba Suprema del Olimpo** en Mazmorras.
    - Superar la prueba corona al cazador como **GOD OF OLIMPUS** y transforma el perfil al **Dorado Divino** (`#FFD700`).

12. **UID Único Alfanumérico de 15 Caracteres (Multijugador Online)**:
    - Identificador único aleatorio de 15 caracteres para cada jugador, preparado para sincronización de servidores e interacciones con amigos.
    - Insignia táctica con botón de copiado rápido al portapapeles en el perfil.
    - Cuenta administradora `sajiadmin` preconfigurada con el UID maestro `000000000000001`.

13. **Panel y Récords Personales (PR)**:
    - Carrusel horizontal interactivo en el perfil que exhibe los récords personales (PR) en kg de cada ejercicio.

14. **Herramientas de Desarrollador Ampliadas (Terminal del Sistema)**:
    - Selector rápido para forzar el rango del cazador a cualquiera de los 8 rangos existentes con un solo toque.
    - Editor interactivo para modificar y calibrar los récords personales (PR) directamente.

15. **Gestor de Rutinas de Entrenamiento Guiadas & Drop Sets**:
    - Creación de rutinas personalizadas y sesiones guiadas paso a paso con descansos interactivos.
    - Mecánica Drop Set configurable por ejercicio multiplicando la XP ganada ($2\times$, $3\times$, hasta $4\times$).

---

## 🚀 Puesta en Marcha

Para documentación detallada de cada módulo, consulta:
- 📱 [Documentación del Cliente Flutter (app/README.md)](app/README.md)
- 🖥️ [Documentación del Servidor FastAPI (server/README.md)](server/README.md)

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
