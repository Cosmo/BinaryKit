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
// Read first 4 bits, bit by bit
var binary = Binary(bytes: [0xDE, 0xAD])
print(binary)

let bit0 = binary.next(bits: 1)
print(bit0) // 1

let bit1 = binary.next(bits: 1)
print(bit1) // 1

let bit2 = binary.next(bits: 1)
print(bit2) // 0

let bit3 = binary.next(bits: 1)
print(bit3) // 1
```

```swift
// Read next 4 bits, 2 x 2 bits
let bits4And5 = binary.next(bits: 2)
print(bits4And5) // 3

let bits6And7 = binary.next(bits: 2)
print(bits6And7) // 2
```

```swift
// Set reading offset (cursor) back to starting position
binary.readingOffset = 0
```

```swift
// Read first two bytes
let nextTwoBytes = binary.next(bytes: 2)
print(nextTwoBytes) // [222, 173]
```

```swift
// Read bit by position
let bit5 = binary.bit(5)
print(bit5) // 1
```

```swift
// Read byte by position
let byte1 = binary.byte(1)
print(byte1) // 173
```

```swift
// Read first 16 bits as Integer
let first16Bits = binary.bits(0, 16)
print(first16Bits) // 57005
```

```swift
// Read first two bytes as Integer
let firstTwoBytes = binary.bytes(0, 2) as Int
print(firstTwoBytes) // 57005
```

## License

BinaryKit is released under the [MIT License](http://www.opensource.org/licenses/MIT).
