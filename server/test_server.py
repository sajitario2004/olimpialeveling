import pytest
from fastapi.testclient import TestClient
from main import app, load_config

client = TestClient(app)

def test_health_check():
    response = client.get("/api/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok", "app": "Olimpia Leveling Server"}

def test_get_config():
    response = client.get("/api/config")
    assert response.status_code == 200
    data = response.json()
    assert "muscles" in data
    assert "ranks" in data
    assert "level_intervals" in data
    assert len(data["muscles"]) == 14

def test_14_muscles_present():
    response = client.get("/api/muscles")
    assert response.status_code == 200
    muscles = response.json()
    muscle_ids = [m["id"] for m in muscles]
    expected_muscles = [
        "pecho", "triceps", "biceps", "antebrazo", "dorsales", "trapecio",
        "lumbar", "deltoides", "cuadriceps", "isquiotibiales", "gluteos",
        "gemelos", "abdominales", "oblicuos"
    ]
    for expected in expected_muscles:
        assert expected in muscle_ids, f"Falta el músculo {expected}"

def test_ranks_order():
    response = client.get("/api/ranks")
    assert response.status_code == 200
    ranks = response.json()
    rank_ids = [r["id"] for r in ranks]
    assert rank_ids[0] == "skinnybitch"
    assert rank_ids[-1] == "god_of_olimpus"

def test_calculate_xp():
    # Press inclinado: deltoides 5 XP/kg, pecho 2 XP/kg, base_xp: 20
    # 60kg, 10 reps
    # Primary: (60 * 5 * 10) / 10 + 20 = 300 + 20 = 320
    # Secondary: (60 * 2 * 10) / 10 + 10 = 120 + 10 = 130
    payload = {
        "exercise_id": "press_inclinado",
        "weight": 60.0,
        "reps": 10
    }
    response = client.post("/api/calculate_xp", json=payload)
    assert response.status_code == 200
    res = response.json()
    assert res["primary"]["muscle"] == "deltoides"
    assert res["primary"]["xp"] == 320.0
    assert res["secondary"]["muscle"] == "pecho"
    assert res["secondary"]["xp"] == 130.0
    assert res["total_xp"] == 450.0

def test_level_intervals_crud():
    new_interval = {
        "id": "test_interval_5_20",
        "min_level": 5,
        "max_level": 20,
        "title": "Prueba diaria 5-20",
        "quests": [
            {"name": "Flexiones", "target": 20.0, "unit": "reps"},
            {"name": "Kilómetros", "target": 5.0, "unit": "km"}
        ],
        "penalty_level": 1,
        "penalty_message": "Penalización aplicada: -1 nivel"
    }
    post_res = client.post("/api/intervals", json=new_interval)
    assert post_res.status_code == 200
    
    get_res = client.get("/api/intervals")
    assert get_res.status_code == 200
    matching = [i for i in get_res.json() if i["id"] == "test_interval_5_20"]
    assert len(matching) == 1
    assert matching[0]["quests"][0]["target"] == 20.0
    assert matching[0]["quests"][1]["target"] == 5.0

def test_recursive_xp_curve():
    response = client.get("/api/xp_curve?max_level=8")
    assert response.status_code == 200
    curve = response.json()
    assert curve[0]["level"] == 1
    assert curve[0]["xp_required"] == 100.0
    assert curve[1]["level"] == 2
    assert curve[1]["xp_required"] == 200.0
    assert curve[2]["level"] == 3
    assert curve[2]["xp_required"] == 300.0
    assert curve[3]["level"] == 4
    assert curve[3]["xp_required"] == 400.0
    assert curve[4]["level"] == 5
    assert curve[4]["xp_required"] == 1000.0
    assert curve[5]["level"] == 6
    assert curve[5]["xp_required"] == 1150.0
    assert curve[6]["level"] == 7
    assert curve[6]["xp_required"] == 1322.5

def test_settings_endpoint():
    get_res = client.get("/api/settings")
    assert get_res.status_code == 200
    settings = get_res.json()
    assert "default_rest_time_seconds" in settings
    assert settings["default_rest_time_seconds"] == 90

    # Update settings
    new_settings = {
        "default_rest_time_seconds": 120,
        "xp_curve_base": 1000.0,
        "xp_curve_multiplier": 1.15,
        "xp_base_per_level": 100,
        "stat_points_per_level": 3,
        "penalty_enabled": True,
        "penalty_level_drop": 1
    }
    post_res = client.post("/api/settings", json=new_settings)
    assert post_res.status_code == 200
    assert post_res.json()["settings"]["default_rest_time_seconds"] == 120

    # Revert back to 90
    new_settings["default_rest_time_seconds"] = 90
    client.post("/api/settings", json=new_settings)

def test_export_to_apk():
    res = client.post("/api/export_to_apk")
    assert res.status_code == 200
    data = res.json()
    assert data["status"] == "success"
    assert "exported_path" in data

def test_create_exercise_with_4_muscles_and_media():
    payload = {
        "id": "press_banca_test_4m",
        "name": "Press de Banca Dioses",
        "description": "Fuerza máxima de empuje",
        "tips": "Retracción escapular firme y pies clavados al suelo",
        "base_xp": 25.0,
        "image_url": "https://example.com/bench.jpg",
        "gif_url": "https://example.com/bench.gif",
        "youtube_url": "https://www.youtube.com/watch?v=rT7DgCr-3pg",
        "muscles_xp": [
            {"muscle": "pecho", "xp": 5.0},
            {"muscle": "triceps", "xp": 3.0},
            {"muscle": "deltoides", "xp": 2.0},
            {"muscle": "antebrazo", "xp": 1.0}
        ]
    }
    res = client.post("/api/exercises", json=payload)
    assert res.status_code == 200
    ex = res.json()["exercise"]
    assert ex["primary_muscle"] == "pecho"
    assert ex["secondary_muscle"] == "triceps"
    assert len(ex["muscles_xp"]) == 4
    assert ex["tips"] == "Retracción escapular firme y pies clavados al suelo"
    assert ex["youtube_url"] == "https://www.youtube.com/watch?v=rT7DgCr-3pg"

    # Test calculate_xp with 4 muscles
    calc_res = client.post("/api/calculate_xp", json={"exercise_id": "press_banca_test_4m", "weight": 100.0, "reps": 10})
    assert calc_res.status_code == 200
    calc_data = calc_res.json()
    assert "all_muscles" in calc_data
    assert len(calc_data["all_muscles"]) == 4

    # Clean up
    del_res = client.delete("/api/exercises/press_banca_test_4m")
    assert del_res.status_code == 200


