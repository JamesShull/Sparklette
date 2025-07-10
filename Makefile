.PHONY: clean install test build deploy

# Variables
IMAGE_NAME = fastapi-vue-app
CONTAINER_NAME = $(IMAGE_NAME)-container

# Default target
all: build

# Clean up build artifacts and Docker resources
clean:
	@echo "Cleaning up..."
	-docker stop $(CONTAINER_NAME)
	-docker rm $(CONTAINER_NAME)
	-docker rmi $(IMAGE_NAME)
	rm -rf frontend/dist
	rm -rf frontend/node_modules
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -type d -delete

# Variables
VENV_DIR = .venv

# Install dependencies
install: venv
	@echo "Installing frontend dependencies..."
	(cd frontend && npm install)
	@echo "Installing backend dependencies into $(VENV_DIR)..."
	@echo "If this is the first time, it might take a while to download packages."
	uv sync --python $(VENV_DIR)/bin/python --no-cache --all-extras

# Create virtual environment
venv:
	@if [ ! -d "$(VENV_DIR)" ]; then \
		echo "Creating virtual environment in $(VENV_DIR)..."; \
		uv venv $(VENV_DIR); \
		echo "Virtual environment created. Activate with: source $(VENV_DIR)/bin/activate"; \
	else \
		echo "Virtual environment $(VENV_DIR) already exists."; \
	fi

# Run tests
test:
	@echo "Running tests..."
	# Add test commands here once test setup is complete
	# For now, just a placeholder
	$(VENV_DIR)/bin/pytest app/tests  # Assuming tests are in app/tests and pytest is installed in venv

# Build the Docker image
build: requirements
	@echo "Building Docker image..."
	docker build -t $(IMAGE_NAME) .

# Deploy (run) the Docker container
deploy: build
	@echo "Deploying Docker container..."
	-docker stop $(CONTAINER_NAME)
	-docker rm $(CONTAINER_NAME)
	docker run -d -p 8000:8000 --name $(CONTAINER_NAME) $(IMAGE_NAME)
	@echo "Application is running on http://localhost:8000"

# Generate requirements.txt for backend (optional, if not using uv sync in Docker)
requirements:
	uv pip freeze > requirements.txt

# Lint the code (optional)
lint:
	@echo "Linting code..."
	# Add linting commands here, e.g., flake8, eslint
	(cd frontend && npm run lint)
	# Add backend linting if desired, e.g., $(VENV_DIR)/bin/flake8 app

# Serve frontend locally for development (optional)
serve-frontend:
	@echo "Serving frontend locally..."
	(cd frontend && npm run serve)

# Serve backend locally for development (optional)
serve-backend: venv
	@echo "Serving backend locally..."
	$(VENV_DIR)/bin/uvicorn app.main:app --reload --port 8001

help:
	@echo "Available targets:"
	@echo "  clean          - Remove build artifacts and Docker resources"
	@echo "  venv           - Create/ensure Python virtual environment using uv"
	@echo "  install        - Install frontend and backend dependencies (creates venv if needed)"
	@echo "  test           - Run tests"
	@echo "  build          - Build the Docker image"
	@echo "  deploy         - Deploy (run) the Docker container"
	@echo "  requirements   - Generate requirements.txt for backend (if needed)"
	@echo "  lint           - Lint the code (frontend and backend)"
	@echo "  serve-frontend - Serve frontend locally for development"
	@echo "  serve-backend  - Serve backend locally for development"
	@echo "  help           - Show this help message"
