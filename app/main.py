from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
import os

app = FastAPI()

# Serve Vue app
STATIC_DIR = "static" # Directory where Vue build output is located

if not os.path.exists(STATIC_DIR):
    # Create a dummy index.html if it doesn't exist,
    # Docker will populate this with the actual build.
    os.makedirs(STATIC_DIR, exist_ok=True)
    with open(os.path.join(STATIC_DIR, "index.html"), "w") as f:
        f.write("<html><body><h1>Vue app will be here</h1></body></html>")


app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")


@app.get("/api/health")
async def health_check():
    return {"message": "API is healthy and running!"}

@app.get("/{full_path:path}")
async def serve_vue_app(full_path: str):
    index_path = os.path.join(STATIC_DIR, "index.html")
    if not os.path.exists(index_path):
        return {"error": "index.html not found in static directory. Make sure the frontend has been built and copied."}
    return FileResponse(index_path)
