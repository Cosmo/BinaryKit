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
        // Check if the request is within bounds
        let storeRange = 0..<bytesStore.count
        let readByteCursor = index / byteSize
        guard storeRange.contains(readByteCursor) else {
            throw BinaryError.outOfBounds
        }
        
        // Get bit
        let byteLastBitIndex = 7
        let bitindex = byteLastBitIndex - (index % byteSize)
        return (bytesStore[readByteCursor] >> bitindex) & 1
    }
    
    /// Returns the `Int`-value of the given range.
    public func getBits(range: Range<Int>) throws -> Int {
        // Check if the request is within bounds
        let storeRange = 0...(bytesStore.count * byteSize)
        guard storeRange.contains(range.endIndex) else {
            throw BinaryError.outOfBounds
        }
        
        // Get bits
        return try range.reversed().enumerated().reduce(0) {
            let bit = try getBit(index: $1.element)
            return $0 + Int(bit) << $1.offset
        }
    }
    
    /// Returns the `UInt8`-value of the given `index`.
    public func getByte(index: Int) throws -> UInt8 {
        // Check if the request is within bounds
        let storeRange = 0..<bytesStore.count
        guard storeRange.contains(index) else {
            throw BinaryError.outOfBounds
        }
        
        // Get byte
        return bytesStore[index]
    }
    
    /// Returns an `[UInt8]` of the given `range`.
    public func getBytes(range: Range<Int>) throws -> [UInt8] {
        // Check if the request is within bounds
        let storeRange = 0...bytesStore.count
        guard storeRange.contains(range.endIndex) else {
            throw BinaryError.outOfBounds
        }
        
        // Get bytes
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
        incrementReadCursorBy(bits: 1)
        return result
    }
    
    /// Returns the `Int`-value of the next n-bits (`quantity`)
    /// and increments the reading cursor by n-bits.
    public mutating func readBits(_ quantity: Int) throws -> Int {
        let range = (readBitCursor..<(readBitCursor + quantity))
        let result = try getBits(range: range)
        incrementReadCursorBy(bits: quantity)
        return result
    }
    
    public mutating func readBits(_ quantity: UInt8) throws -> Int {
        return try readBits(Int(quantity))
    }
    
    /// Returns the `UInt8`-value of the next byte and
    /// increments the reading cursor by 1 byte.
    public mutating func readByte() throws -> UInt8 {
        return UInt8(try readBits(byteSize))
    }
    
    /// Returns a `[UInt8]` of the next n-bytes (`quantity`) and
    /// increments the reading cursor by n-bytes.
    public mutating func readBytes(_ quantity: Int) throws -> [UInt8] {
        // Check if the request is within bounds
        let range = (readBitCursor..<(readBitCursor + quantity * byteSize))
        let storeRange = 0...(bytesStore.count * byteSize)
        guard storeRange.contains(range.endIndex) else {
            throw BinaryError.outOfBounds
        }
        return try (0..<quantity).map{ _ in try readByte() }
    }
    
    public mutating func readBytes(_ quantity: UInt8) throws -> [UInt8] {
        return try readBytes(Int(quantity))
    }
    
    /// Returns a `String` of the next n-bytes (`quantity`) and
    /// increments the reading cursor by n-bytes.
    public mutating func readString(quantityOfBytes quantity: Int, encoding: String.Encoding = .ascii) throws -> String {
        guard let result = String(bytes: try self.readBytes(quantity), encoding: encoding) else {
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
        let NibbleBitWidth = 4
        return UInt8(try readBits(NibbleBitWidth))
    }
    
    // MARK: Read — Signed Integer
    
    /// Returns an `Int8` and increments the reading cursor by 1 byte.
    public mutating func readInt8() throws -> Int8 {
        return Int8(bitPattern: try readByte())
    }
    
    /// Returns an `Int16` and increments the reading cursor by 2 bytes.
    public mutating func readInt16() throws -> Int16 {
        let bytes = try readBytes(MemoryLayout<Int16>.size)
        return Int16(bitPattern: UInt16(UInt(bytes: bytes)))
    }
    
    /// Returns an `Int32` and increments the reading cursor by 4 bytes.
    public mutating func readInt32() throws -> Int32 {
        let bytes = try readBytes(MemoryLayout<Int32>.size)
        return Int32(bitPattern: UInt32(UInt(bytes: bytes)))
    }
    
    /// Returns an `Int64` and increments the reading cursor by 8 bytes.
    public mutating func readInt64() throws -> Int64 {
        let bytes = try readBytes(MemoryLayout<Int64>.size)
        return Int64(bitPattern: UInt64(UInt(bytes: bytes)))
    }
    
    // MARK: Read - Unsigned Integer
    
    /// Returns an `UInt8` and increments the reading cursor by 1 byte.
    public mutating func readUInt8() throws -> UInt8 {
        return try readByte()
    }
    
    /// Returns an `UInt16` and increments the reading cursor by 2 bytes.
    public mutating func readUInt16() throws -> UInt16 {
        let bytes = try readBytes(MemoryLayout<UInt16>.size)
        return UInt16(UInt(bytes: bytes))
    }
    
    /// Returns an `UInt32` and increments the reading cursor by 4 bytes.
    public mutating func readUInt32() throws -> UInt32 {
        let bytes = try readBytes(MemoryLayout<UInt32>.size)
        return UInt32(UInt(bytes: bytes))
    }
    
    /// Returns an `UInt64` and increments the reading cursor by 8 bytes.
    public mutating func readUInt64() throws -> UInt64 {
        let bytes = try readBytes(MemoryLayout<UInt64>.size)
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
        let byte: UInt8 = bit << Int(7 - (writeBitCursor % byteSize))
        let index = writeBitCursor / byteSize
        
        if bytesStore.count == index {
            bytesStore.append(byte)
        } else {
            let oldByte = bytesStore[index]
            let newByte = oldByte ^ byte
            bytesStore[index] = newByte
        }
        
        writeBitCursor = writeBitCursor + 1
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


extension Binary {
    mutating func readSignedBits(_ quantity: UInt8) throws -> Int {
        let multiplicationFactor = (try readBit() == 1) ? -1 : 1
        let value = try readBits(quantity - 1)
        return value * multiplicationFactor
    }
}
