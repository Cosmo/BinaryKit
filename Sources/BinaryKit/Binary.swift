import Foundation

public struct Binary {
    /// Returns the bit position of the reading cursor.
    /// All methods starting with `read` will increment this value.
    public private(set) var readBitCursor: Int
    
    /// Returns the bit position of the writing cursor.
    /// All methods starting with `write` will increment this value.
    public private(set) var writeBitCursor: Int
    
    /// Returns the stored bytes.
    public private(set) var bytesStore: [UInt8]
    
    /// Constant with number of bits in a byte
    private let byteSize = UInt8.bitWidth
    
    /// Returns the stored number of bytes.
    public var count: Int {
        return bytesStore.count
    }
    
    /// Creates a new `Binary`.
    public init(bytes: [UInt8]) {
        self.readBitCursor = 0
        self.writeBitCursor = 0
        self.bytesStore = bytes
    }
    
    /// Creates an empty `Binary`.
    public init() {
        self.init(bytes: [])
    }
    
    /// Creates a new `Binary` with a string of hexadecimal values converted to bytes.
    public init?(hexString: String) {
        let charsPerByte = 2
        let hexBase = 16
        let bytes = hexString.chunked(by: charsPerByte).compactMap{ UInt8($0, radix: hexBase) }
        guard hexString.count / charsPerByte == bytes.count else {
            return nil
        }
        self.init(bytes: bytes)
    }
    
    // MARK: - Cursor
    
    /// Returns an `Int` with the value of `readBitCursor` incremented by `bits`.
    private func incrementedReadCursorBy(bits: Int) -> Int {
        return readBitCursor + bits
    }
    
    /// Returns an `Int` with the value of `readBitCursor` incremented by `bytes`.
    private func incrementedReadCursorBy(bytes: Int) -> Int {
        return readBitCursor + (bytes * byteSize)
    }
    
    /// Increments the `readBitCursor`-value by the given `bits`.
    private mutating func incrementReadCursorBy(bits: Int) {
        readBitCursor = incrementedReadCursorBy(bits: bits)
    }
    
    /// Increments the `readBitCursor`-value by the given `bytes`.
    private mutating func incrementReadCursorBy(bytes: Int) {
        readBitCursor = incrementedReadCursorBy(bytes: bytes)
    }

    /// Sets the reading cursor back to its initial value.
    public mutating func resetReadCursor() {
        self.readBitCursor = 0
    }
    
    // MARK: - Get
    
    /// All `get` methods give access to binary data at any given
    /// location — without incrementing the internal cursor.
    
    /// Returns an `UInt8` with the value of 0 or 1 of the given position.
    public func getBit(index: Int) throws -> UInt8 {
        guard (0..<(bytesStore.count)).contains(index / byteSize) else {
            throw BinaryError.outOfBounds
        }
        let byteCursor = index / byteSize
        let byteLastBitIndex = 7
        let bitindex = byteLastBitIndex - (index % byteSize)
        return (bytesStore[byteCursor] >> bitindex) & 1
    }
    
    /// Returns the `Int`-value of the given range.
    public mutating func getBits(range: Range<Int>) throws -> Int {
        guard (0...(bytesStore.count * byteSize)).contains(range.endIndex) else {
            throw BinaryError.outOfBounds
        }
        return try range.reversed().enumerated().reduce(0) {
            let bit = try getBit(index: $1.element)
            return $0 + Int(bit << $1.offset)
        }
    }
    
    /// Returns the `UInt8`-value of the given `index`.
    public func getByte(index: Int) throws -> UInt8 {
        /// Check if `index` is within bounds of `bytes`
        guard (0..<(bytesStore.count)).contains(index) else {
            throw BinaryError.outOfBounds
        }
        return bytesStore[index]
    }
    
    /// Returns an `[UInt8]` of the given `range`.
    public func getBytes(range: Range<Int>) throws -> [UInt8] {
        guard (0...(bytesStore.count)).contains(range.endIndex) else {
            throw BinaryError.outOfBounds
        }
        return Array(bytesStore[range])
    }
    
    // MARK: - Read
    
    /// All `read*` methods return the next requested binary data
    /// and increment an internal cursor (or reading offset) to
    /// the end of the requested data, so the
    /// next `read*`-method can continue from there.
    
    /// Returns an `UInt8` with the value of 0 or 1 of the given
    /// position and increments the reading cursor by one bit.
    public mutating func readBit(holdCursor: Bool = false) throws -> UInt8 {
        let result = try getBit(index: readBitCursor)
        if !holdCursor {
            incrementReadCursorBy(bits: 1)
        }
        return result
    }
    
    /// Returns the `Int`-value of the next n-bits (`quantitiy`)
    /// and increments the reading cursor by n-bits.
    public mutating func readBits(_ quantitiy: Int, holdCursor: Bool = false) throws -> Int {
        guard (0...(bytesStore.count * byteSize)).contains(readBitCursor + quantitiy) else {
            throw BinaryError.outOfBounds
        }
        
        let range = (readBitCursor..<(readBitCursor + quantitiy))
        let result = try range.reversed().enumerated().reduce(0) {
            let bit = try getBit(index: $1.element)
            let value = Int(bit) << $1.offset
            return $0 + value
        }
        
        if !holdCursor {
            incrementReadCursorBy(bits: quantitiy)
        }
        
        return result
    }
    
    public mutating func readBits(_ quantitiy: UInt8, holdCursor: Bool = false) throws -> Int {
        return try readBits(Int(quantitiy), holdCursor: holdCursor)
    }
    
    /// Returns the `UInt8`-value of the next byte and
    /// increments the reading cursor by 1 byte.
    public mutating func readByte(holdCursor: Bool = false) throws -> UInt8 {
        let result = try getByte(index: readBitCursor / byteSize)
        if !holdCursor {
            incrementReadCursorBy(bytes: 1)
        }
        return result
    }
    
    /// Returns a `[UInt8]` of the next n-bytes (`quantitiy`) and
    /// increments the reading cursor by n-bytes.
    public mutating func readBytes(_ quantitiy: Int, holdCursor: Bool = false) throws -> [UInt8] {
        let byteCursor = readBitCursor / byteSize
        if !holdCursor {
            incrementReadCursorBy(bytes: quantitiy)
        }
        return try getBytes(range: byteCursor..<(byteCursor + quantitiy))
    }
    
    public mutating func readBytes(_ quantitiy: UInt8, holdCursor: Bool = false) throws -> [UInt8] {
        return try readBytes(Int(quantitiy), holdCursor: holdCursor)
    }
    
    /// Returns a `String` of the next n-bytes (`quantitiy`) and
    /// increments the reading cursor by n-bytes.
    public mutating func readString(quantitiyOfBytes quantitiy: Int, encoding: String.Encoding = .utf8, holdCursor: Bool = false) throws -> String {
        guard let result = String(bytes: try self.readBytes(quantitiy, holdCursor: holdCursor), encoding: encoding) else {
            throw BinaryError.notString
        }
        return result
    }
    
    /// Returns the next byte as `Character` and
    /// increments the reading cursor by 1 byte.
    public mutating func readCharacter(holdCursor: Bool = false) throws -> Character {
        return Character(UnicodeScalar(try readByte(holdCursor: holdCursor)))
    }
    
    /// Returns the `Bool`-value of the next bit and
    /// increments the reading cursor by 1 bit.
    public mutating func readBool(holdCursor: Bool = false) throws -> Bool {
        return try readBit(holdCursor: holdCursor) == 1
    }
    
    /// Returns the `UInt8`-value of the next 4 bit and
    /// increments the reading cursor by 4 bits.
    public mutating func readNibble(holdCursor: Bool = false) throws -> UInt8 {
        let bitsPerNibble = 4
        return UInt8(try readBits(bitsPerNibble, holdCursor: holdCursor))
    }
    
    // MARK: Read — Signed Integer
    
    /// Returns an `Int8` and increments the reading cursor by 1 byte.
    public mutating func readInt8(holdCursor: Bool = false) throws -> Int8 {
        return Int8(bitPattern: try readByte(holdCursor: holdCursor))
    }
    
    /// Returns an `Int16` and increments the reading cursor by 2 bytes.
    public mutating func readInt16(holdCursor: Bool = false) throws -> Int16 {
        let bytes = try readBytes(MemoryLayout<Int16>.size, holdCursor: holdCursor)
        return Int16(bitPattern: UInt16(UInt(bytes: bytes)))
    }
    
    /// Returns an `Int32` and increments the reading cursor by 4 bytes.
    public mutating func readInt32(holdCursor: Bool = false) throws -> Int32 {
        let bytes = try readBytes(MemoryLayout<Int32>.size, holdCursor: holdCursor)
        return Int32(bitPattern: UInt32(UInt(bytes: bytes)))
    }
    
    /// Returns an `Int64` and increments the reading cursor by 8 bytes.
    public mutating func readInt64(holdCursor: Bool = false) throws -> Int64 {
        let bytes = try readBytes(MemoryLayout<Int64>.size, holdCursor: holdCursor)
        return Int64(bitPattern: UInt64(UInt(bytes: bytes)))
    }
    
    // MARK: Read - Unsigned Integer
    
    /// Returns an `UInt8` and increments the reading cursor by 1 byte.
    public mutating func readUInt8(holdCursor: Bool = false) throws -> UInt8 {
        return try readByte(holdCursor: holdCursor)
    }
    
    /// Returns an `UInt16` and increments the reading cursor by 2 bytes.
    public mutating func readUInt16(holdCursor: Bool = false) throws -> UInt16 {
        let bytes = try readBytes(MemoryLayout<UInt16>.size, holdCursor: holdCursor)
        return UInt16(UInt(bytes: bytes))
    }
    
    /// Returns an `UInt32` and increments the reading cursor by 4 bytes.
    public mutating func readUInt32(holdCursor: Bool = false) throws -> UInt32 {
        let bytes = try readBytes(MemoryLayout<UInt32>.size, holdCursor: holdCursor)
        return UInt32(UInt(bytes: bytes))
    }
    
    /// Returns an `UInt64` and increments the reading cursor by 8 bytes.
    public mutating func readUInt64(holdCursor: Bool = false) throws -> UInt64 {
        let bytes = try readBytes(MemoryLayout<UInt64>.size, holdCursor: holdCursor)
        return UInt64(UInt(bytes: bytes))
    }
    
    // MARK: - Find
    
    /// Returns indices of given `[UInt8]`.
    public func indices(of sequence: [UInt8]) -> [Int] {
        let size = sequence.count
        return bytesStore.indices.dropLast(size - 1).filter {
            bytesStore[$0..<($0 + size)].elementsEqual(sequence)
        }
    }
    
    /// Returns indices of given `String`.
    public func indices(of string: String) -> [Int] {
        let sequence = [UInt8](string.utf8)
        return indices(of: sequence)
    }

    // MARK: - Write
    
    /// Writes a byte (`UInt8`) to `Binary`.
    public mutating func writeByte(_ byte: UInt8) {
        bytesStore.append(byte)
    }
    
    /// Writes bytes (`[UInt8]`) to `Binary`.
    public mutating func writeBytes(_ bytes: [UInt8]) {
        bytesStore.append(contentsOf: bytes)
    }
    
    /// Writes a bit (`UInt8`) to `Binary`.
    public mutating func writeBit(bit: UInt8) {
        let byte: UInt8 = bit << Int(7 - (writeBitCursor % 8))
        let index = writeBitCursor / 8
        
        if bytesStore.count == index {
            bytesStore.append(byte)
        } else {
            let oldByte = bytesStore[index]
            let newByte = oldByte ^ byte
            bytesStore[index] = newByte
        }
        
        writeBitCursor += 1
    }
    
    /// Writes a `Bool` as a bit to `Binary`.
    public mutating func writeBool(_ bool: Bool) {
        writeBit(bit: bool ? 1 : 0)
    }
    
    /// Writes a `String` to `Binary`.
    public mutating func writeString(_ string: String) {
        let bytes = [UInt8](string.utf8)
        writeBytes(bytes)
    }
    
    /// Writes an `FixedWidthInteger` (`Int`, `UInt8`, `Int8`, `UInt16`, `Int16`, …) to `Binary`.
    public mutating func writeInt<T: FixedWidthInteger>(_ int: T) {
        bytesStore.append(contentsOf: int.bytes)
    }
}
