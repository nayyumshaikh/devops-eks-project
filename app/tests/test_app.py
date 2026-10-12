from app import app


def test_health():
    resp = app.test_client().get("/health")
    assert resp.status_code == 200
    assert resp.get_json()["status"] == "ok"


def test_items():
    resp = app.test_client().get("/items")
    assert resp.status_code == 200
    assert len(resp.get_json()["items"]) == 3
