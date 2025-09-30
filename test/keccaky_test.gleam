import gleeunit
import gleeunit/should
import keccaky
import gleam/bit_array
import gleam/string

pub fn main() {
  gleeunit.main()
}

// === Basic Hash Tests ===

pub fn empty_string_test() {
  let result = keccaky.hash_keccak_256("")
  case result {
    Ok(hash) -> {
      let hex = keccaky.to_hex_string(hash)
      hex
      |> should.equal("c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470")
    }
    Error(_) -> should.fail()
  }
}

pub fn hello_world_test() {
  let result = keccaky.hash_keccak_256("hello world")
  case result {
    Ok(hash) -> {
      let hex = keccaky.to_hex_string(hash)
      hex
      |> should.equal("47173285a8d7341e5e972fc677286384f802f8ef42a5ec5f03bbfa254cb01fad")
    }
    Error(_) -> should.fail()
  }
}

pub fn abc_test() {
  let result = keccaky.hash_keccak_256("abc")
  case result {
    Ok(hash) -> {
      let hex = keccaky.to_hex_string(hash)
      hex
      |> should.equal("4e03657aea45a94fc7d47ba826c8d667c0d1e6e33a64a036ec44f58fa12d6c45")
    }
    Error(_) -> should.fail()
  }
}

pub fn test_256_a_test() {
  let input = bit_array.from_string("a")
  let result = keccaky.hash_keccak_256_bytes(input)
  case result {
    Ok(hash) -> {
      let hex = keccaky.to_hex_string(hash)
      hex
      |> should.equal("3ac225168df54212a25c1c01fd35bebfea408fdac2e31ddd6f80a4bbf9a5f1cb")
    }
    Error(_) -> should.fail()
  }
}

pub fn long_string_test() {
  let input = "The quick brown fox jumps over the lazy dog"
  let result = keccaky.hash_keccak_256(input)
  case result {
    Ok(hash) -> {
      let hex = keccaky.to_hex_string(hash)
      hex
      |> should.equal("4d741b6f1eb29cb2a9b9911c82f56fa8d73b04959d3d9d222895df6c0b28aa15")
    }
    Error(_) -> should.fail()
  }
}

pub fn bytes_input_test() {
  let input = <<0x42, 0xff, 0x00, 0xaa>>
  let result = keccaky.hash_keccak_256_bytes(input)
  case result {
    Ok(_hash) -> {
      // This test just ensures the function works with raw bytes
      should.be_true(True)
    }
    Error(_) -> should.fail()
  }
}

// === Error Handling Tests ===

pub fn large_input_error_test() {
  // Create a very large string (over 100MB limit)
  let large_input = string.repeat("x", 100_000_001)
  let result = keccaky.hash_keccak_256(large_input)
  case result {
    Error(keccaky.InvalidInput) -> should.be_true(True)
    _ -> should.fail()
  }
}

pub fn large_bytes_error_test() {
  // Create a large byte array
  let large_bytes = bit_array.from_string(string.repeat("y", 100_000_001))
  let result = keccaky.hash_keccak_256_bytes(large_bytes)
  case result {
    Error(keccaky.InvalidInput) -> should.be_true(True)
    _ -> should.fail()
  }
}

// === Hex Encoding/Decoding Tests ===

pub fn hex_encoding_test() {
  let result = keccaky.hash_keccak_256("test")
  case result {
    Ok(hash) -> {
      let hex = keccaky.to_hex_string(hash)
      // Should be lowercase
      hex
      |> should.equal(string.lowercase(hex))
      // Should be 64 characters (32 bytes * 2)
      string.length(hex)
      |> should.equal(64)
    }
    Error(_) -> should.fail()
  }
}

pub fn hex_decoding_valid_test() {
  let hex = "c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470"
  let result = keccaky.from_hex_string(hex)
  case result {
    Ok(hash) -> {
      let decoded_hex = keccaky.to_hex_string(hash)
      decoded_hex
      |> should.equal(hex)
    }
    Error(_) -> should.fail()
  }
}

pub fn hex_decoding_with_0x_prefix_test() {
  let hex = "0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470"
  let expected = "c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470"
  let result = keccaky.from_hex_string(hex)
  case result {
    Ok(hash) -> {
      let decoded_hex = keccaky.to_hex_string(hash)
      decoded_hex
      |> should.equal(expected)
    }
    Error(_) -> should.fail()
  }
}

pub fn hex_decoding_uppercase_test() {
  let hex = "C5D2460186F7233C927E7DB2DCC703C0E500B653CA82273B7BFAD8045D85A470"
  let expected = "c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470"
  let result = keccaky.from_hex_string(hex)
  case result {
    Ok(hash) -> {
      let decoded_hex = keccaky.to_hex_string(hash)
      decoded_hex
      |> should.equal(expected)
    }
    Error(_) -> should.fail()
  }
}

pub fn hex_decoding_invalid_length_test() {
  let hex = "c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a47"  // 63 chars
  let result = keccaky.from_hex_string(hex)
  case result {
    Error(keccaky.InvalidHexString) -> should.be_true(True)
    _ -> should.fail()
  }
}

pub fn hex_decoding_invalid_chars_test() {
  let hex = "g5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470"  // 'g' is invalid
  let result = keccaky.from_hex_string(hex)
  case result {
    Error(keccaky.InvalidHexString) -> should.be_true(True)
    _ -> should.fail()
  }
}

// === Utility Function Tests ===

pub fn to_bytes_test() {
  let result = keccaky.hash_keccak_256("test")
  case result {
    Ok(hash) -> {
      let bytes = keccaky.to_bytes(hash)
      bit_array.byte_size(bytes)
      |> should.equal(32)
    }
    Error(_) -> should.fail()
  }
}

pub fn compare_same_test() {
  let result1 = keccaky.hash_keccak_256("test")
  let result2 = keccaky.hash_keccak_256("test")
  case result1, result2 {
    Ok(hash1), Ok(hash2) -> {
      keccaky.compare(hash1, hash2)
      |> should.be_true()
    }
    _, _ -> should.fail()
  }
}

pub fn compare_different_test() {
  let result1 = keccaky.hash_keccak_256("test1")
  let result2 = keccaky.hash_keccak_256("test2")
  case result1, result2 {
    Ok(hash1), Ok(hash2) -> {
      keccaky.compare(hash1, hash2)
      |> should.be_false()
    }
    _, _ -> should.fail()
  }
}

// === Round-trip Tests ===

pub fn hex_round_trip_test() {
  let original = "hello world"
  let result = keccaky.hash_keccak_256(original)
  case result {
    Ok(hash) -> {
      let hex = keccaky.to_hex_string(hash)
      let decoded_result = keccaky.from_hex_string(hex)
      case decoded_result {
        Ok(decoded_hash) -> {
          keccaky.compare(hash, decoded_hash)
          |> should.be_true()
        }
        Error(_) -> should.fail()
      }
    }
    Error(_) -> should.fail()
  }
}
