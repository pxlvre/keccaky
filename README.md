# Keccaky

Keccaky is a high-performance Keccak (SHA-3) implementation with a Gleam interface, providing easy access to Keccak-256 hashing through a Rust backend. The project leverages Rust's efficient hashing algorithms and integrates them with Gleam for high-level usage.

## Features

- **Keccak-256 Hashing**: Provides Keccak-256 hash functionality using the `tiny-keccak` Rust library.
- **Gleam Integration**: Exposes the hashing functionality to Gleam via an FFI layer.
- **Cross-Language Compatibility**: Utilizes Rust for performance and Gleam for ease of use and safety.

## Prerequisites

- [Gleam](https://gleam.run/getting-started/) >= 1.0.0
- [Rust](https://rustup.rs/) >= 1.60.0

## Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/pxlvre/keccaky.git
   cd keccaky
   ```

2. **Build the Rust FFI Library**:
   ```bash
   cd src/native/tiny_keccak_ffi
   cargo build --release
   cd ../../..
   ```

3. **Build the Gleam Project**:
   ```bash
   gleam build
   ```

## Usage

### Basic Example

```gleam
import keccaky
import gleam/io

pub fn main() {
  case keccaky.hash_keccak_256("hello world") {
    Ok(hash) -> {
      let hex = keccaky.to_hex_string(hash)
      io.println("Hash: " <> hex)
      // Outputs: Hash: 47173285a8d7341e5e972fc677286384f802f8ef42a5ec5f03bbfa254cb01fad
    }
    Error(error) -> {
      case error {
        keccaky.InvalidInput -> io.println("Input too large")
        keccaky.HashError -> io.println("Hashing failed")
        _ -> io.println("Unknown error")
      }
    }
  }
}
```

### Advanced Usage

#### Working with Raw Bytes
```gleam
import keccaky
import gleam/bit_array

let data = <<0x48, 0x65, 0x6c, 0x6c, 0x6f>>  // "Hello" in bytes
case keccaky.hash_keccak_256_bytes(data) {
  Ok(hash) -> {
    let hex = keccaky.to_hex_string(hash)
    // Process the hash
  }
  Error(_) -> // Handle error
}
```

#### Hex String Conversion
```gleam
import keccaky

// From hex string (with or without 0x prefix)
case keccaky.from_hex_string("0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470") {
  Ok(hash) -> {
    // Work with the hash
    let bytes = keccaky.to_bytes(hash)
    let hex = keccaky.to_hex_string(hash)
  }
  Error(keccaky.InvalidHexString) -> // Handle invalid hex
}
```

#### Comparing Hashes
```gleam
let hash1 = keccaky.hash_keccak_256("test1")
let hash2 = keccaky.hash_keccak_256("test2")

case hash1, hash2 {
  Ok(h1), Ok(h2) -> {
    case keccaky.compare(h1, h2) {
      True -> io.println("Hashes are equal")
      False -> io.println("Hashes are different")
    }
  }
  _, _ -> // Handle errors
}
```

### API Reference

#### Types
```gleam
pub type Keccak256Hash {
  Keccak256Hash(BitArray)
}

pub type KeccakError {
  InvalidInput      // Input too large (>100MB)
  HashError         // Internal hashing error
  InvalidHexString  // Invalid hex format
  EncodingError     // Encoding/decoding error
}
```

#### Core Functions
```gleam
// Hash a string
pub fn hash_keccak_256(input: String) -> Result(Keccak256Hash, KeccakError)

// Hash raw bytes
pub fn hash_keccak_256_bytes(input: BitArray) -> Result(Keccak256Hash, KeccakError)

// Convert hash to lowercase hex string
pub fn to_hex_string(hash: Keccak256Hash) -> String

// Parse hex string to hash (supports 0x prefix)
pub fn from_hex_string(hex: String) -> Result(Keccak256Hash, KeccakError)

// Get raw bytes from hash
pub fn to_bytes(hash: Keccak256Hash) -> BitArray

// Compare two hashes for equality
pub fn compare(hash1: Keccak256Hash, hash2: Keccak256Hash) -> Bool
```

## Development

### Quick Start
```bash
# Build everything
make build

# Run all tests
make test

# Format and lint code
make format lint

# Full development cycle
make all
```

### Build System

The project includes a unified build system with multiple options:

#### Using Make
```bash
make build      # Build Rust NIF and Gleam project
make test       # Run all tests  
make format     # Format all code
make lint       # Lint all code
make clean      # Clean build artifacts
make deps       # Install dependencies
make dev-setup  # Setup development environment
make release    # Build release version
make all        # Build, test, format, and lint
```

#### Using Build Script
```bash
./build.sh build    # Build project
./build.sh test     # Run tests
./build.sh format   # Format code
./build.sh lint     # Lint code
./build.sh clean    # Clean artifacts
./build.sh all      # Do everything
```

### Testing

The project includes comprehensive tests:

- **Rust Tests**: Hash correctness, edge cases, performance
- **Gleam Tests**: API functionality, error handling, hex encoding/decoding
- **Integration Tests**: End-to-end functionality

#### Manual Testing
```bash
# Rust tests only
cd src/native/tiny_keccak_ffi && cargo test

# Gleam tests only  
gleam test

# All tests via build system
make test
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for your changes
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Roadmap

- [x] Fix FFI integration issues
- [x] Add comprehensive test suite with test vectors  
- [x] Implement proper error handling
- [x] Add hex encoding/decoding utilities
- [x] Set up CI/CD pipeline
- [x] Create unified build system
- [ ] Add benchmarking suite
- [ ] Add more hash variants (Keccak-224, Keccak-384, Keccak-512)
- [ ] Add fuzzing tests for security validation
- [ ] Performance optimizations
- [ ] Documentation improvements
