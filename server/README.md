# Olimpia Leveling - Servidor & Panel Web (FastAPI)

> Servidor backend y panel de control visual en tiempo real para **Olimpia Leveling**, desarrollado en **Python 3 / FastAPI** con plantillas Jinja2 y Tailwind CSS.

![FastAPI](https://img.shields.io/badge/FastAPI-0.115+-009688.svg)
![Python](https://img.shields.io/badge/Python-3.10+-3776AB.svg)
![Tests](https://img.shields.io/badge/pytest-13%2F13_passed-brightgreen.svg)

---

## ⚡ Capacidades del Servidor

1. **Dashboard Visual en `http://localhost:8000`**:
   - Curva de XP interactiva con visualización de progresión geométrica del 15% y salto 20x en Nivel 100.
   - Gestor de ejercicios multimedia: fotos, GIFs demostrativos y enlaces a YouTube con reparto a hasta 4 músculos anatómicos.
   - Configuración de intervalos de los 8 rangos, tiempos de descanso y multiplicadores Drop Set.

2. **Exportación a Assets para APK Offline**:
   - Endpoint `POST /api/export_to_apk`: Vuelca la configuración activa a `app/assets/config/game_config.json` para que la app móvil funcione 100% offline con las configuraciones personalizadas.

3. **Endpoints REST API**:
   - `GET /api/config`: Retorna la configuración completa actual.
   - `POST /api/config`: Actualiza los parámetros de juego.
   - `GET /api/xp_curve`: Simula y calcula la curva de XP por nivel.
   - `POST /api/exercises`: Crea o actualiza ejercicios con validación de hasta 4 músculos.
   - `POST /api/export_to_apk`: Exporta la configuración a la app Flutter.

---

## 🚀 Puesta en Marcha

### 1. Instalar dependencias
```bash
cd server
pip install -r requirements.txt
```

### 2. Iniciar el servidor
```bash
python3 main.py
```
Abre en tu navegador: **http://localhost:8000**

---

## 🧪 Pruebas Automatizadas

```bash
cd server
pytest test_server.py -v
```
