.PHONY: build test format lint clean all help deps

# Default target
all: build test format lint

# Build the project
build:
	@./build.sh build

# Run tests
test:
	@./build.sh test

# Format code
format:
	@./build.sh format

# Lint code
lint:
	@./build.sh lint

# Clean build artifacts
clean:
	@./build.sh clean

# Install dependencies
deps:
	@echo "📦 Installing dependencies..."
	@cd src/native/tiny_keccak_ffi && cargo fetch
	@gleam deps download
	@echo "✅ Dependencies installed"

# Development setup
dev-setup: deps
	@echo "🛠️ Setting up development environment..."
	@echo "Installing pre-commit hooks..."
	@echo "#!/bin/bash" > .git/hooks/pre-commit
	@echo "make format lint test" >> .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "✅ Development environment ready"

# Release build
release:
	@echo "🚀 Building release..."
	@cd src/native/tiny_keccak_ffi && cargo build --release
	@gleam build
	@echo "✅ Release build completed"

# Help
help:
	@echo "Keccaky Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  build      - Build Rust NIF and Gleam project"
	@echo "  test       - Run all tests"
	@echo "  format     - Format all code"
	@echo "  lint       - Lint all code"
	@echo "  clean      - Clean build artifacts"
	@echo "  deps       - Install dependencies"
	@echo "  dev-setup  - Setup development environment"
	@echo "  release    - Build release version"
	@echo "  all        - Build, test, format, and lint"
	@echo "  help       - Show this help"