import json
import os
from pathlib import Path
from typing import List, Optional, Dict, Any
from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

BASE_DIR = Path(__file__).resolve().parent
DATA_FILE = BASE_DIR / "config_data.json"
DEFAULT_FILE = BASE_DIR / "default_config.json"

app = FastAPI(
    title="Olimpia Leveling - Sistema de Control y Balanceo",
    description="Panel de administración y API para gestionar misiones diarias, niveles, ejercicios y balance de XP.",
    version="1.0.0"
)

# Enable CORS for Flutter app development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Setup templates & static files
TEMPLATES_DIR = BASE_DIR / "templates"
STATIC_DIR = BASE_DIR / "static"
TEMPLATES_DIR.mkdir(parents=True, exist_ok=True)
STATIC_DIR.mkdir(parents=True, exist_ok=True)

templates = Jinja2Templates(directory=str(TEMPLATES_DIR))
app.mount("/static", StaticFiles(directory=str(STATIC_DIR)), name="static")

def load_config() -> Dict[str, Any]:
    if DATA_FILE.exists():
        with open(DATA_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    if DEFAULT_FILE.exists():
        with open(DEFAULT_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
            save_config(data)
            return data
    raise RuntimeError("No configuration file found.")

def save_config(data: Dict[str, Any]) -> None:
    with open(DATA_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

def get_xp_required_for_level(level: int) -> float:
    """Calcula el XP necesario para subir del nivel actual al siguiente usando settings dinámicos."""
    config = load_config()
    settings = config.get("settings", {})
    base_6 = settings.get("xp_curve_base", 1000.0)
    multiplier = settings.get("xp_curve_multiplier", 1.15)

    if level <= 1: return 100.0
    if level == 2: return 200.0
    if level == 3: return 300.0
    if level == 4: return 400.0
    if level == 5: return float(base_6)
    xp = float(base_6)
    for _ in range(5, level):
        xp *= multiplier
    return round(xp, 1)

# Pydantic models for validation
class GameplaySettings(BaseModel):
    default_rest_time_seconds: int = 90
    xp_curve_base: float = 1000.0
    xp_curve_multiplier: float = 1.15
    xp_base_per_level: int = 100
    stat_points_per_level: int = 3
    penalty_enabled: bool = True
    penalty_level_drop: int = 1

class QuestItem(BaseModel):
    name: str
    target: float
    unit: str

class LevelInterval(BaseModel):
    id: str
    min_level: int
    max_level: int
    title: str
    quests: List[QuestItem]
    penalty_level: int = 1
    penalty_message: str = "¡Misión diaria fallida! Has perdido 1 nivel."

class MuscleXpItem(BaseModel):
    muscle: str
    xp: float

class ExerciseItem(BaseModel):
    id: str
    name: str
    description: str
    primary_muscle: str = "pecho"
    primary_xp_per_kg: float = 5.0
    secondary_muscle: Optional[str] = None
    secondary_xp_per_kg: Optional[float] = 0.0
    base_xp: float = 20.0
    tips: Optional[str] = ""
    image_url: Optional[str] = ""
    gif_url: Optional[str] = ""
    youtube_url: Optional[str] = ""
    muscles_xp: Optional[List[Dict[str, Any]]] = None

class RankItem(BaseModel):
    id: str
    name: str
    min_level: int
    color: str
    quote: str

class XPCalculationRequest(BaseModel):
    exercise_id: str
    weight: float
    reps: int

class PlayerSyncRequest(BaseModel):
    player_id: str = "main_hunter"
    total_level: int
    rank: str
    muscles: Dict[str, Dict[str, Any]]
    completed_daily_date: Optional[str] = None
    last_sync_date: Optional[str] = None

# --- WEB DASHBOARD ROUTES ---

@app.get("/", response_class=HTMLResponse)
async def dashboard(request: Request):
    config = load_config()
    return templates.TemplateResponse(
        "index.html",
        {
            "request": request,
            "intervals": config.get("level_intervals", []),
            "exercises": config.get("exercises", []),
            "muscles": config.get("muscles", []),
            "ranks": config.get("ranks", []),
            "settings": config.get("settings", {}),
        }
    )

# --- API ENDPOINTS ---

@app.get("/api/config")
async def get_all_config():
    """Devuelve la configuración completa del juego para la app Flutter."""
    return load_config()

@app.get("/api/intervals")
async def get_intervals():
    config = load_config()
    return config.get("level_intervals", [])

@app.post("/api/intervals")
async def create_or_update_interval(interval: LevelInterval):
    config = load_config()
    intervals = config.get("level_intervals", [])
    
    # Update existing or add new
    existing_idx = next((i for i, item in enumerate(intervals) if item["id"] == interval.id), None)
    if existing_idx is not None:
        intervals[existing_idx] = interval.model_dump()
    else:
        intervals.append(interval.model_dump())
    
    # Sort intervals by min_level
    intervals.sort(key=lambda x: x["min_level"])
    config["level_intervals"] = intervals
    save_config(config)
    return {"status": "success", "message": f"Intervalo '{interval.title}' guardado correctamente.", "interval": interval}

@app.delete("/api/intervals/{interval_id}")
async def delete_interval(interval_id: str):
    config = load_config()
    intervals = [i for i in config.get("level_intervals", []) if i["id"] != interval_id]
    config["level_intervals"] = intervals
    save_config(config)
    return {"status": "success", "message": f"Intervalo {interval_id} eliminado."}

@app.get("/api/exercises")
async def get_exercises():
    config = load_config()
    return config.get("exercises", [])

@app.post("/api/exercises")
async def create_or_update_exercise(exercise: ExerciseItem):
    config = load_config()
    exercises = config.get("exercises", [])
    data = exercise.model_dump()

    # Synchronize primary/secondary if muscles_xp is passed
    if exercise.muscles_xp and len(exercise.muscles_xp) > 0:
        data["primary_muscle"] = exercise.muscles_xp[0]["muscle"]
        data["primary_xp_per_kg"] = float(exercise.muscles_xp[0].get("xp", 5.0))
        if len(exercise.muscles_xp) > 1:
            data["secondary_muscle"] = exercise.muscles_xp[1]["muscle"]
            data["secondary_xp_per_kg"] = float(exercise.muscles_xp[1].get("xp", 2.0))
        else:
            data["secondary_muscle"] = None
            data["secondary_xp_per_kg"] = 0.0

    existing_idx = next((i for i, item in enumerate(exercises) if item["id"] == exercise.id), None)
    if existing_idx is not None:
        exercises[existing_idx] = data
    else:
        exercises.append(data)
        
    config["exercises"] = exercises
    save_config(config)
    return {"status": "success", "message": f"Ejercicio '{exercise.name}' guardado.", "exercise": data}

@app.delete("/api/exercises/{exercise_id}")
async def delete_exercise(exercise_id: str):
    config = load_config()
    exercises = [e for e in config.get("exercises", []) if e["id"] != exercise_id]
    config["exercises"] = exercises
    save_config(config)
    return {"status": "success", "message": f"Ejercicio {exercise_id} eliminado."}

@app.get("/api/muscles")
async def get_muscles():
    config = load_config()
    return config.get("muscles", [])

@app.get("/api/ranks")
async def get_ranks():
    config = load_config()
    return config.get("ranks", [])

@app.post("/api/ranks")
async def update_ranks(ranks: List[RankItem]):
    config = load_config()
    config["ranks"] = [r.model_dump() for r in ranks]
    config["ranks"].sort(key=lambda x: x["min_level"])
    save_config(config)
    return {"status": "success", "message": "Rangos actualizados correctamente."}

@app.get("/api/settings")
async def get_settings():
    config = load_config()
    return config.get("settings", {})

@app.post("/api/settings")
async def update_settings(settings: GameplaySettings):
    config = load_config()
    config["settings"] = settings.model_dump()
    save_config(config)
    return {"status": "success", "message": "Ajustes del juego guardados correctamente.", "settings": settings}

@app.post("/api/export_to_apk")
async def export_to_apk():
    """Exporta config_data.json a app/assets/config/game_config.json para incluir en el build de APK."""
    config = load_config()
    app_config_dir = BASE_DIR.parent / "app" / "assets" / "config"
    app_config_dir.mkdir(parents=True, exist_ok=True)
    app_config_path = app_config_dir / "game_config.json"
    with open(app_config_path, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2, ensure_ascii=False)
    return {
        "status": "success",
        "message": f"Configuración exportada con éxito a {app_config_path.name}. Listo para compilar con 'flutter build apk'.",
        "exported_path": str(app_config_path)
    }

@app.get("/api/xp_curve")
async def get_xp_curve(max_level: int = 30):
    """Devuelve la tabla de XP requerida por nivel con la fórmula recursiva del 15%."""
    return [{"level": lvl, "xp_required": get_xp_required_for_level(lvl)} for lvl in range(1, max_level + 1)]

@app.post("/api/calculate_xp")
async def calculate_xp(req: XPCalculationRequest):
    """Calcula la experiencia otorgada a cada músculo para un ejercicio dado peso y repeticiones."""
    config = load_config()
    exercise = next((e for e in config.get("exercises", []) if e["id"] == req.exercise_id), None)
    if not exercise:
        raise HTTPException(status_code=404, detail="Ejercicio no encontrado")

    muscles_xp_list = exercise.get("muscles_xp")
    if muscles_xp_list and len(muscles_xp_list) > 0:
        muscles_result = []
        total_xp = 0.0
        for idx, m_item in enumerate(muscles_xp_list):
            m_name = m_item.get("muscle")
            m_rate = float(m_item.get("xp", 5.0))
            base = exercise.get("base_xp", 10.0) if idx == 0 else (exercise.get("base_xp", 10.0) * 0.5)
            xp_val = round((req.weight * m_rate * req.reps) / 10.0 + base, 2)
            muscles_result.append({"muscle": m_name, "xp": xp_val})
            total_xp += xp_val

        primary_info = muscles_result[0]
        secondary_info = muscles_result[1] if len(muscles_result) > 1 else None
        return {
            "exercise_id": req.exercise_id,
            "name": exercise["name"],
            "primary": primary_info,
            "secondary": secondary_info,
            "all_muscles": muscles_result,
            "total_xp": round(total_xp, 2)
        }

    primary_xp = (req.weight * exercise["primary_xp_per_kg"] * req.reps) / 10.0 + exercise.get("base_xp", 10)
    secondary_xp = 0.0
    if exercise.get("secondary_muscle") and exercise.get("secondary_xp_per_kg"):
        secondary_xp = (req.weight * exercise["secondary_xp_per_kg"] * req.reps) / 10.0 + (exercise.get("base_xp", 10) * 0.5)

    return {
        "exercise_id": req.exercise_id,
        "name": exercise["name"],
        "primary": {
            "muscle": exercise["primary_muscle"],
            "xp": round(primary_xp, 2)
        },
        "secondary": {
            "muscle": exercise.get("secondary_muscle"),
            "xp": round(secondary_xp, 2)
        } if exercise.get("secondary_muscle") else None,
        "total_xp": round(primary_xp + secondary_xp, 2)
    }

@app.post("/api/player/sync")
async def sync_player(player_data: PlayerSyncRequest):
    """Sincroniza y valida el estado del cazador desde la app móvil Flutter."""
    config = load_config()
    
    # Check what interval matches the player's level
    current_interval = None
    for interval in config.get("level_intervals", []):
        if interval["min_level"] <= player_data.total_level <= interval["max_level"]:
            current_interval = interval
            break
            
    # Check player rank based on total level
    current_rank = config["ranks"][0]
    for rank in config.get("ranks", []):
        if player_data.total_level >= rank["min_level"]:
            current_rank = rank
            
    return {
        "status": "synced",
        "current_rank": current_rank,
        "current_interval": current_interval,
        "server_time": "active",
        "config_version": "1.0"
    }

@app.get("/api/health")
async def health_check():
    return {"status": "ok", "app": "Olimpia Leveling Server"}

if __name__ == "__main__":
    import uvicorn
    print("Iniciando Olimpia Leveling Server en http://localhost:8000 ...")
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
