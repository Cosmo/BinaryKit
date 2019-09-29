# BinaryKit

BinaryKit helps you to break down binary data into bits and bytes and easily access specific parts.

## Accessing Bytes

By using any `read*` method (`readByte()`, `readBytes(quantitiy:)`, `readBit()`, …), BinaryKit will increment an internal cursor (or reading offset) to the end of the requested bit or byte, so the next `read*` method can continue from there.

Any `get*` method (`getByte(index:)`, `getBytes(range:)`, `getBit(index:)`, …) will give access to binary data at any given location — without incrementing the internal cursor.

Here are the methods you can call:

```swift
let binary = Binary(bytes: [0xDE, 0xAD, 0xBE, 0xEF, …])

// Reads exactly 1 byte and
// increments the cursor by 1 byte 
try binary.readByte()

// Reads the next 4 bytes and
// increments the cursor by 4 bytes
try binary.readBytes(quantitiy: 4)

// Reads the next 1 bit and
// increments the cursor by 1 bit
try binary.readBit()

// Reads the next 4 bits and
// increments the cursor by 4 bits
try binary.readBits(quantitiy: 4)
```

## Example

This shows how easy it is, to break down an [IPv4 header](https://en.wikipedia.org/wiki/IPv4#Header).

```swift
let binary = Binary(bytes: [0b1_1_0_1_1_1_0_0])
                              | | | | | | | | 
                              | | | | | | | try binary.bit()    // 0
                              | | | | | | try binary.bit()      // 0
                              | | | | | try binary.bit()        // 1
                              | | | | try binary.bit()          // 1
                              | | | try binary.bit()            // 1
                              | | try binary.bit()              // 0
                              | try binary.bit()                // 1
                              try binary.bit()                  // 1
```


```swift
let binary = Binary(bytes: [0x1B, 0x44, …])
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

## Contact

* Devran "Cosmo" Uenal
* Twitter: [@maccosmo](http://twitter.com/maccosmo)
* LinkedIn: [devranuenal](https://www.linkedin.com/in/devranuenal)

## Other Projects

* [Clippy](https://github.com/Cosmo/Clippy) — Clippy from Microsoft Office is back and runs on macOS! Written in Swift.
* [GrammaticalNumber](https://github.com/Cosmo/GrammaticalNumber) — Turns singular words to the plural and vice-versa in Swift.
* [HackMan](https://github.com/Cosmo/HackMan) — Stop writing boilerplate code yourself. Let hackman do it for you via the command line.
* [ISO8859](https://github.com/Cosmo/ISO8859) — Convert ISO8859 1-16 Encoded Text to String in Swift. Supports iOS, tvOS, watchOS and macOS.
* [SpriteMap](https://github.com/Cosmo/SpriteMap) — SpriteMap helps you to extract sprites out of a sprite map. Written in Swift.
* [StringCase](https://github.com/Cosmo/StringCase) — Converts String to lowerCamelCase, UpperCamelCase and snake_case. Tested and written in Swift.
* [TinyConsole](https://github.com/Cosmo/TinyConsole) — TinyConsole is a micro-console that can help you log and display information inside an iOS application, where having a connection to a development computer is not possible.

## License

BinaryKit is released under the [MIT License](http://www.opensource.org/licenses/MIT).
