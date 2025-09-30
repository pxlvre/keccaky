import gleam/bit_array
import gleam/string

pub type Keccak256Hash {
  Keccak256Hash(BitArray)
}

pub type KeccakError {
  InvalidInput
  HashError
  InvalidHexString
  EncodingError
}

@external(erlang, "keccaky_nif", "keccak_256_nif")
fn keccak_256_nif(input: BitArray) -> Result(BitArray, String)

pub fn hash_keccak_256(input: String) -> Result(Keccak256Hash, KeccakError) {
  case string.byte_size(input) > 100_000_000 {
    True -> Error(InvalidInput)
    False -> {
      let input_binary = bit_array.from_string(input)
      case keccak_256_nif(input_binary) {
        Ok(hash_binary) -> Ok(Keccak256Hash(hash_binary))
        Error(_) -> Error(HashError)
      }
    }
  }
}

pub fn hash_keccak_256_bytes(input: BitArray) -> Result(Keccak256Hash, KeccakError) {
  case bit_array.byte_size(input) > 100_000_000 {
    True -> Error(InvalidInput)
    False -> {
      case keccak_256_nif(input) {
        Ok(hash_binary) -> Ok(Keccak256Hash(hash_binary))
        Error(_) -> Error(HashError)
      }
    }
  }
}

pub fn to_hex_string(hash: Keccak256Hash) -> String {
  let Keccak256Hash(binary) = hash
  bit_array.base16_encode(binary)
  |> string.lowercase
}

pub fn from_hex_string(hex: String) -> Result(Keccak256Hash, KeccakError) {
  let cleaned_hex = case string.starts_with(hex, "0x") {
    True -> string.drop_left(hex, 2)
    False -> hex
  }
  
  case string.length(cleaned_hex) == 64 {
    False -> Error(InvalidHexString)
    True -> {
      case bit_array.base16_decode(string.uppercase(cleaned_hex)) {
        Ok(binary) -> Ok(Keccak256Hash(binary))
        Error(_) -> Error(InvalidHexString)
      }
    }
  }
}

pub fn to_bytes(hash: Keccak256Hash) -> BitArray {
  let Keccak256Hash(binary) = hash
  binary
}

pub fn compare(hash1: Keccak256Hash, hash2: Keccak256Hash) -> Bool {
  let Keccak256Hash(binary1) = hash1
  let Keccak256Hash(binary2) = hash2
  binary1 == binary2
}
