<img src="https://raw.githubusercontent.com/Cosmo/BinaryKit/master/BinaryKitLogo.png" alt=" text" width="100" />

# BinaryKit
Access bits and bytes directly in Swift.

## Usage

Initialize from `NSData`
```swift
let data   = NSData(...)
let binary = Binary(data: data)
```

or `[UInt8]` bytes array
```swift
let binary = Binary(bytes: [0xDE, 0xAD]) // 1101 1110 1010 1101
```

```swift
// Bits
binary.bit(0) as Int      // 1
binary.bit(1) as Int      // 1
binary.bit(2) as Bit      // .Zero
binary.bit(3) as Bit      // .One
binary.bits(0, 16)        // 57005 

// Bytes
binary.byte(0) as Int     // 222
binary.byte(0, 2) as Int  // 57005
```

## Todos

- [ ] Endianness flag
- [ ] Tests
- [ ] Documentation

## License

BinaryKit is released under the [MIT License](http://www.opensource.org/licenses/MIT).
