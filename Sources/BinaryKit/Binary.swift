import Foundation

public struct Binary {
    /// Stores a reading cursor in bits.
    /// All methods starting with `read` will increment the value of `readBitCursor`.
    private var readBitCursor: Int
    
    /// Stores a writing cursor in bits.
    /// All methods starting with `write` will increment the value of `writeBitCursor`.
    private var writeBitCursor: Int
    
    /// Stores the binary content.
    var bytesStore: [UInt8]
    
    /// Constant with number of bits in a byte (8)
    private let byteSize = UInt8.bitWidth
    
    /// Initialize a new `Binary`.
    public init(bytes: [UInt8]) {
        self.readBitCursor = 0
        self.writeBitCursor = 0
        self.bytesStore = bytes
    }
    
    
    /// Initialize an empty `Binary`.
    public init() {
        self.init(bytes: [])
    }
    
    /// Initialize with a `String` of hexadecimal values.
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
    private func incrementedCursorBy(bits: Int) -> Int {
        return readBitCursor + bits
    }
    
    /// Returns an `Int` with the value of `readBitCursor` incremented by `bytes`.
    private func incrementedCursorBy(bytes: Int) -> Int {
        return readBitCursor + (bytes * byteSize)
    }
    
    /// Increments the `readBitCursor`-value by the given `bits`.
    private mutating func incrementCursorBy(bits: Int) {
        readBitCursor = incrementedCursorBy(bits: bits)
    }
    
    /// Increments the `readBitCursor`-value by the given `bytes`.
    private mutating func incrementCursorBy(bytes: Int) {
        readBitCursor = incrementedCursorBy(bytes: bytes)
    }

    /// Sets the reading cursor back to its initial value.
    public mutating func resetCursor() {
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
            $0 + Int(try getBit(index: $1.element) << $1.offset)
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
    public mutating func readBit() throws -> UInt8 {
        let result = try getBit(index: readBitCursor)
        incrementCursorBy(bits: 1)
        return result
    }
    
    /// Returns the `Int`-value of the next n-bits (`quantitiy`)
    /// and increments the reading cursor by n-bits.
    public mutating func readBits(quantitiy: Int) throws -> Int {
        guard (0...(bytesStore.count * byteSize)).contains(readBitCursor + quantitiy) else {
            throw BinaryError.outOfBounds
        }
        let result = try (readBitCursor..<(readBitCursor + quantitiy)).reversed().enumerated().reduce(0) {
            $0 + Int(try getBit(index: $1.element) << $1.offset)
        }
        incrementCursorBy(bits: quantitiy)
        return result
    }
    
    /// Returns the `UInt8`-value of the next byte and
    /// increments the reading cursor by 1 byte.
    public mutating func readByte() throws -> UInt8 {
        let result = try getByte(index: readBitCursor / byteSize)
        incrementCursorBy(bytes: 1)
        return result
    }
    
    /// Returns a `[UInt8]` of the next n-bytes (`quantitiy`) and
    /// increments the reading cursor by n-bytes.
    public mutating func readBytes(quantitiy: Int) throws -> [UInt8] {
        let byteCursor = readBitCursor / byteSize
        incrementCursorBy(bytes: quantitiy)
        return try getBytes(range: byteCursor..<(byteCursor + quantitiy))
    }
    
    /// Returns a `String` of the next n-bytes (`quantitiy`) and
    /// increments the reading cursor by n-bytes.
    public mutating func readString(quantitiyOfBytes quantitiy: Int, encoding: String.Encoding = .utf8) throws -> String {
        guard let result = String(bytes: try self.readBytes(quantitiy: quantitiy), encoding: encoding) else {
            throw BinaryError.notString
        }
        return result
    }
    
    /// Returns the next byte as `Character` and
    /// increments the reading cursor by 1 byte.
    public mutating func readCharacter() throws -> Character {
        return Character(UnicodeScalar(try readByte()))
    }
    
    /// Returns the `Bool`-value of the next bit and
    /// increments the reading cursor by 1 bit.
    public mutating func readBool() throws -> Bool {
        return try readBit() == 1
    }
    
    /// Returns the `UInt8`-value of the next 4 bit and
    /// increments the reading cursor by 4 bits.
    public mutating func readNibble() throws -> UInt8 {
        let bitsPerNibble = 4
        return UInt8(try readBits(quantitiy: bitsPerNibble))
    }
    
    // MARK: Read — Signed Integer
    
    /// Returns an `Int8` and increments the reading cursor by 1 byte.
    public mutating func readInt8() throws -> Int8 {
        return Int8(bitPattern: try readByte())
    }
    
    /// Returns an `Int16` and increments the reading cursor by 2 bytes.
    public mutating func readInt16() throws -> Int16 {
        let bytes = try readBytes(quantitiy: MemoryLayout<Int16>.size)
        return Int16(bitPattern: UInt16(UInt(bytes: bytes)))
    }
    
    /// Returns an `Int32` and increments the reading cursor by 4 bytes.
    public mutating func readInt32() throws -> Int32 {
        let bytes = try readBytes(quantitiy: MemoryLayout<Int32>.size)
        return Int32(bitPattern: UInt32(UInt(bytes: bytes)))
    }
    
    /// Returns an `Int64` and increments the reading cursor by 8 bytes.
    public mutating func readInt64() throws -> Int64 {
        let bytes = try readBytes(quantitiy: MemoryLayout<Int64>.size)
        return Int64(bitPattern: UInt64(UInt(bytes: bytes)))
    }
    
    // MARK: Read - Unsigned Integer
    
    /// Returns an `UInt8` and increments the reading cursor by 1 byte.
    public mutating func readUInt8() throws -> UInt8 {
        return try readByte()
    }
    
    /// Returns an `UInt16` and increments the reading cursor by 2 bytes.
    public mutating func readUInt16() throws -> UInt16 {
        let bytes = try readBytes(quantitiy: MemoryLayout<UInt16>.size)
        return UInt16(UInt(bytes: bytes))
    }
    
    /// Returns an `UInt32` and increments the reading cursor by 4 bytes.
    public mutating func readUInt32() throws -> UInt32 {
        let bytes = try readBytes(quantitiy: MemoryLayout<UInt32>.size)
        return UInt32(UInt(bytes: bytes))
    }
    
    /// Returns an `UInt64` and increments the reading cursor by 8 bytes.
    public mutating func readUInt64() throws -> UInt64 {
        let bytes = try readBytes(quantitiy: MemoryLayout<UInt64>.size)
        return UInt64(UInt(bytes: bytes))
    }
    
    // MARK: - Find
    
    /// Returns indices of given `[UInt8]`.
    func indices(of sequence: [UInt8]) -> [Int] {
        let size = sequence.count
        return bytesStore.indices.dropLast(size - 1).filter {
            bytesStore[$0..<($0 + size)].elementsEqual(sequence)
        }
    }
    
    /// Returns indices of given `String`.
    func indices(of string: String) -> [Int] {
        let sequence = [UInt8](string.utf8)
        return indices(of: sequence)
    }

    // MARK: - Write
    
    /// Writes a byte (`UInt8`) to `Binary`.
    mutating func writeByte(_ byte: UInt8) {
        bytesStore.append(byte)
    }
    
    /// Writes bytes (`[UInt8]`) to `Binary`.
    mutating func writeBytes(_ bytes: [UInt8]) {
        bytesStore.append(contentsOf: bytes)
    }
    
    /// Writes a bit (`UInt8`) to `Binary`.
    mutating func writeBit(bit: UInt8) {
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
    mutating func writeBool(bool: Bool) {
        writeBit(bit: bool ? 1 : 0)
    }
    
    /// Writes a `String` to `Binary`.
    mutating func writeString(_ string: String) {
        let bytes = [UInt8](string.utf8)
        writeBytes(bytes)
    }
    
    /// Writes an `FixedWidthInteger` (`Int`, `UInt8`, `Int8`, `UInt16`, `Int16`, …) to `Binary`.
    mutating func writeInt<T: FixedWidthInteger>(_ int: T) {
        bytesStore.append(contentsOf: int.bytes)
    }
}
