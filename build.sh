#!/bin/bash

# Keccaky Unified Build Script
set -e

echo "🔨 Building Keccaky project..."

# Function to print colored output
print_status() {
    echo -e "\033[1;34m$1\033[0m"
}

print_success() {
    echo -e "\033[1;32m$1\033[0m"
}

print_error() {
    echo -e "\033[1;31m$1\033[0m"
}

# Check dependencies
check_dependencies() {
    print_status "Checking dependencies..."
    
    if ! command -v cargo &> /dev/null; then
        print_error "❌ Rust/Cargo not found. Please install Rust: https://rustup.rs/"
        exit 1
    fi
    
    if ! command -v gleam &> /dev/null; then
        print_error "❌ Gleam not found. Please install Gleam: https://gleam.run/getting-started/"
        exit 1
    fi
    
    print_success "✅ All dependencies found"
}

# Build Rust NIF
build_rust() {
    print_status "Building Rust NIF..."
    cd src/native/tiny_keccak_ffi
    cargo build --release
    cd ../../..
    print_success "✅ Rust NIF built successfully"
}

# Build Gleam project
build_gleam() {
    print_status "Building Gleam project..."
    gleam deps download
    gleam build
    print_success "✅ Gleam project built successfully"
}

# Run tests
run_tests() {
    print_status "Running tests..."
    
    # Rust tests
    print_status "Running Rust tests..."
    cd src/native/tiny_keccak_ffi
    cargo test
    cd ../../..
    
    # Gleam tests
    print_status "Running Gleam tests..."
    gleam test
    
    print_success "✅ All tests passed"
}

# Format code
format_code() {
    print_status "Formatting code..."
    
    # Format Rust code
    cd src/native/tiny_keccak_ffi
    cargo fmt
    cd ../../..
    
    # Format Gleam code
    gleam format src test
    
    print_success "✅ Code formatted"
}

# Lint code
lint_code() {
    print_status "Linting code..."
    
    # Lint Rust code
    cd src/native/tiny_keccak_ffi
    cargo clippy -- -D warnings
    cd ../../..
    
    print_success "✅ Code linted"
}

# Clean build artifacts
clean() {
    print_status "Cleaning build artifacts..."
    rm -rf build/
    rm -rf src/native/tiny_keccak_ffi/target/
    print_success "✅ Build artifacts cleaned"
}

# Main build function
build() {
    check_dependencies
    build_rust
    build_gleam
    print_success "🎉 Build completed successfully!"
}

# Handle command line arguments
case "${1:-build}" in
    "build")
        build
        ;;
    "test")
        check_dependencies
        build_rust
        run_tests
        ;;
    "format")
        format_code
        ;;
    "lint")
        lint_code
        ;;
    "clean")
        clean
        ;;
    "all")
        build
        run_tests
        format_code
        lint_code
        ;;
    *)
        echo "Usage: $0 {build|test|format|lint|clean|all}"
        echo ""
        echo "Commands:"
        echo "  build   - Build Rust NIF and Gleam project (default)"
        echo "  test    - Build and run all tests"
        echo "  format  - Format all code"
        echo "  lint    - Lint all code"
        echo "  clean   - Clean build artifacts"
        echo "  all     - Build, test, format, and lint"
        exit 1
        ;;
esac