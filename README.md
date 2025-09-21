# Keccaky

Keccaky is a high-performance Keccak (SHA-3) implementation with a Gleam interface, providing easy access to Keccak-256 hashing through a Rust backend. The project leverages Rust's efficient hashing algorithms and integrates them with Gleam for high-level usage.

## Features

- **Keccak-256 Hashing**: Provides Keccak-256 hash functionality using the `tiny-keccak` Rust library.
- **Gleam Integration**: Exposes the hashing functionality to Gleam via an FFI layer.
- **Cross-Language Compatibility**: Utilizes Rust for performance and Gleam for ease of use and safety.

## Installation

### Rust Setup

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/vidalpaul/keccaky.git
   cd keccaky
   ```

2. **Build the Rust Library**:
   Ensure you have Rust installed. Build the Rust shared library:
   ```bash
   cargo build --release
   ```

   The shared library will be available in the `target/release` directory.

### Gleam Setup

1. **Install Gleam**:
   Follow the [Gleam installation instructions](https://gleam.run/getting-started) if you haven't already.

2. **Build the Gleam Project**:
   Ensure the shared library is placed in the correct directory (`src/native` or specified path). Then build the Gleam project:
   ```bash
   gleam build
   ```

## Usage

### Rust FFI

The Rust function `keccak_256` is exposed to Gleam. The function signature is:
```rust
extern "C" fn keccak_256(input_ptr: *const u8, input_len: usize, output_ptr: *mut u8);
```

### Gleam Integration

In Gleam, you can call the Keccak-256 hash function using:

```gleam
import gleam/erlang
import gleam/ffi

// External function declaration for FFI
@external(erlang, "keccak_ffi", "keccak_256")
fn keccak_256(input: ffi.Buffer, input_len: Int, output: ffi.Buffer) -> Nil

// Function to hash a string using Keccak-256
pub fn hash_keccak_256(input: String) -> Result(String, Nil) {
  let input_bytes = erlang.binary_to_list(erlang.bitstring_to_binary(input))
  let output_size = 32
  let output_bytes = ffi.Buffer.from_binary(erlang.binary_init(output_size, 0))

  keccak_256(input_bytes, List.length(input_bytes), output_bytes)

  let output_binary = ffi.Buffer.to_binary(output_bytes)
  Ok(erlang.binary_to_string(output_binary))
}
```

### Testing

To ensure everything is working correctly, run tests in Rust and Gleam:

- **Rust Tests**:
  ```bash
  cargo test
  ```

- **Gleam Tests**:
  ```bash
  gleam test
  ```

## Contributing

Feel free to contribute by submitting issues or pull requests. Ensure all contributions adhere to the project's coding standards and pass existing tests.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
