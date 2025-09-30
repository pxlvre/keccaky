use rustler::{Env, NifResult, Binary, NewBinary, Error as NifError};
use tiny_keccak::{Hasher, Keccak};

rustler::atoms! {
    ok,
    error,
    invalid_input,
    hash_error
}

#[derive(Debug)]
pub enum KeccakError {
    InvalidInput,
    HashError,
}

impl From<KeccakError> for NifError {
    fn from(err: KeccakError) -> Self {
        match err {
            KeccakError::InvalidInput => NifError::BadArg,
            KeccakError::HashError => NifError::BadArg,
        }
    }
}

#[rustler::nif]
fn keccak_256_nif<'a>(env: Env<'a>, input: Binary) -> NifResult<Binary<'a>> {
    // Validate input size (reasonable limit to prevent DoS)
    if input.len() > 100_000_000 {  // 100MB limit
        return Err(KeccakError::InvalidInput.into());
    }
    
    let mut keccak = Keccak::v256();
    keccak.update(input.as_slice());
    
    let mut output = [0u8; 32];
    keccak.finalize(&mut output);
    
    let mut result = NewBinary::new(env, 32);
    result.as_mut_slice().copy_from_slice(&output);
    
    Ok(result.into())
}

rustler::init!("keccaky_nif", [keccak_256_nif]);

#[cfg(test)]
mod tests {
    use super::*;
    use tiny_keccak::{Hasher, Keccak};

    fn keccak_256_pure(input: &[u8]) -> [u8; 32] {
        let mut keccak = Keccak::v256();
        keccak.update(input);
        let mut output = [0u8; 32];
        keccak.finalize(&mut output);
        output
    }

    #[test]
    fn test_empty_string() {
        let result = keccak_256_pure(b"");
        let expected = [
            0xc5, 0xd2, 0x46, 0x01, 0x86, 0xf7, 0x23, 0x3c, 0x92, 0x7e, 0x7d, 0xb2, 0xdc, 0xc7,
            0x03, 0xc0, 0xe5, 0x00, 0xb6, 0x53, 0xca, 0x82, 0x27, 0x3b, 0x7b, 0xfa, 0xd8, 0x04,
            0x5d, 0x85, 0xa4, 0x70,
        ];
        assert_eq!(result, expected);
    }

    #[test]
    fn test_abc() {
        let result = keccak_256_pure(b"abc");
        let expected = [
            0x4e, 0x03, 0x65, 0x7a, 0xea, 0x45, 0xa9, 0x4f, 0xc7, 0xd4, 0x7b, 0xa8, 0x26, 0xc8,
            0xd6, 0x67, 0xc0, 0xd1, 0xe6, 0xe3, 0x3a, 0x64, 0xa0, 0x36, 0xec, 0x44, 0xf5, 0x8f,
            0xa1, 0x2d, 0x6c, 0x45,
        ];
        assert_eq!(result, expected);
    }

    #[test]
    fn test_hello_world() {
        let result = keccak_256_pure(b"hello world");
        let expected = [
            0x47, 0x17, 0x32, 0x85, 0xa8, 0xd7, 0x34, 0x1e, 0x5e, 0x97, 0x2f, 0xc6, 0x77, 0x28,
            0x63, 0x84, 0xf8, 0x02, 0xf8, 0xef, 0x42, 0xa5, 0xec, 0x5f, 0x03, 0xbb, 0xfa, 0x25,
            0x4c, 0xb0, 0x1f, 0xad,
        ];
        assert_eq!(result, expected);
    }

    #[test]
    fn test_large_input() {
        // Test that we can handle reasonably large inputs
        let large_input = vec![0u8; 10_000_000]; // 10MB
        let result = keccak_256_pure(&large_input);
        
        // This should complete without panic
        assert_eq!(result.len(), 32);
    }

    #[test]
    fn test_various_sizes() {
        // Test inputs of various sizes
        for size in [0, 1, 55, 56, 64, 100, 1000, 10000] {
            let input = vec![42u8; size];
            let result = keccak_256_pure(&input);
            assert_eq!(result.len(), 32, "Failed for input size {}", size);
        }
    }

    #[test]
    fn test_deterministic() {
        // Same input should always produce same output
        let input = b"test deterministic";
        let result1 = keccak_256_pure(input);
        let result2 = keccak_256_pure(input);
        assert_eq!(result1, result2);
    }

    #[test]
    fn test_different_inputs_different_outputs() {
        // Different inputs should produce different outputs
        let result1 = keccak_256_pure(b"test1");
        let result2 = keccak_256_pure(b"test2");
        assert_ne!(result1, result2);
    }

    #[test]
    fn test_avalanche_effect() {
        // Small change in input should cause large change in output
        let result1 = keccak_256_pure(b"test");
        let result2 = keccak_256_pure(b"Test"); // Just changed case of first letter
        
        // Count how many bytes are different
        let diff_count = result1.iter()
            .zip(result2.iter())
            .filter(|(a, b)| a != b)
            .count();
        
        // Should have significant differences (avalanche effect)
        assert!(diff_count > 10, "Expected significant differences, got {}", diff_count);
    }
}

