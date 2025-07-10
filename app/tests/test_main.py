from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_read_main():
    response = client.get("/api/health")
    assert response.status_code == 200
    assert response.json() == {"message": "API is healthy and running!"}

def test_serve_vue_app():
    response = client.get("/")
    assert response.status_code == 200
    assert "text/html" in response.headers["content-type"]

def test_serve_vue_app_static_files():
    # This test assumes there's a file like 'favicon.ico' in your static directory
    # It will be created by the frontend build process later
    # For now, we can check if the route for static files is working
    # by checking if the dummy index.html is served from a static path (e.g., /static/index.html)
    # However, FastAPI's StaticFiles serves index.html at the root of the mount,
    # so a direct /static/index.html might not be the best test if index.html is also the catch-all.
    # Instead, let's ensure the /static mount itself is active by trying to access a known static file
    # that isn't the index.html. We'll create a dummy one for the test.

    # Create a dummy static file for testing
    with open("static/test.txt", "w") as f:
        f.write("test content")

    response_static_file = client.get("/static/test.txt")
    assert response_static_file.status_code == 200
    assert response_static_file.text == "test content"

    # Test non-existent static file
    response_not_found_static = client.get("/static/nonexistent.txt")
    assert response_not_found_static.status_code == 404

    # Test accessing a path that should serve index.html
    response_vue_route = client.get("/some/vue/route")
    assert response_vue_route.status_code == 200
    assert "text/html" in response_vue_route.headers["content-type"]
    # Verify it's serving the dummy index.html content for now
    assert "Vue app will be here" in response_vue_route.text
