# BinaryKit

BinaryKit helps you to break down binary data into bits and bytes, easily access specific parts and write data to binary.
This is a fork of [Cosmo/BinaryKit](https://github.com/Cosmo/BinaryKit) and still in active development.

## Access Bytes

By using any `read*` method (`readByte()`, `readBytes(quantitiy:)`, `readBit()`, …) of `BinaryReader`, BinaryKit will increment an internal cursor (or reading offset) to the end of the requested bit or byte, so the next `read*` method can continue from there.

Any `get*` method (`getByte(index:)`, `getBytes(range:)`, `getBit(index:)`, …) will give access to binary data at any given location — without incrementing the internal cursor.

Here are the methods you can call:

```swift
var binary = BinaryReader(bytes: [0xDE, 0xAD, 0xBE, 0xEF, …])

// Reads exactly 1 byte and
// increments the cursor by 1 byte 
try binary.readByte()

// Reads the next 4 bytes and
// increments the cursor by 4 bytes
try binary.readBytes(4)

// Reads the next 1 bit and
// increments the cursor by 1 bit
try binary.readBit()

// Reads the next 4 bits and
// increments the cursor by 4 bits
try binary.readBits(4)
```

### Example

```swift
var binary = BinaryReader(bytes: [0b1_1_0_1_1_1_0_0])
//                                  | | | | | | | | 
//                                  | | | | | | | try binary.readBit()  // 0
//                                  | | | | | | try binary.readBit()    // 0
//                                  | | | | | try binary.readBit()      // 1
//                                  | | | | try binary.readBit()        // 1
//                                  | | | try binary.readBit()          // 1
//                                  | | try binary.readBit()            // 0
//                                  | try binary.readBit()              // 1
//                                  try binary.readBit()                // 1
```

This shows how easy it is, to break down an [IPv4 header](https://en.wikipedia.org/wiki/IPv4#Header).

```swift
var binary = BinaryReader(bytes: [0x1B, 0x44, …])
let version                         = try binary.readBits(4)
let internetHeaderLength            = try binary.readBits(4)
let differentiatedServicesCodePoint = try binary.readBits(6)
let explicitCongestionNotification  = try binary.readBits(2)
let totalLength                     = try binary.readBytes(2)
let identification                  = try binary.readBytes(2)
let flags                           = try binary.readBits(4)
let fragmentOffset                  = try binary.readBits(12)
let timeToLive                      = try binary.readByte()
let protocolNumber                  = try binary.readByte()
let headerChecksum                  = try binary.readBytes(2)
let sourceIpAddress                 = try binary.readBytes(4)
let destinationIpAddress            = try binary.readBytes(4)
...
```

## Store Bytes

Use the `write*` methods of `BinaryWriter` to store different types to binary. 

```swift
var binary = BinaryWriter<[UInt8]>()
binary.writeInt32(1_350_849_546)
binary.writeString("Hello World!")
binary.writeBytes([0xFF, 0xCC, 0x00, 0x01])
binary.writeBool(true)
```

## License

BinaryKit is released under the [MIT License](http://www.opensource.org/licenses/MIT).
