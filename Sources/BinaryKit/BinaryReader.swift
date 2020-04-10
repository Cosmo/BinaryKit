import Foundation

public struct BinaryReader<BytesStore: DataProtocol> where BytesStore.Index == Int {
    /// Returns the bit position of the reading cursor.
    /// All methods starting with `read` will increment this value.
    public private(set) var readBitCursor: Int
    
    /// Returns the stored bytes.
    public let bytesStore: BytesStore
    
    /// Constant with number of bits in a byte
    private let byteSize = UInt8.bitWidth
    
    /// Returns the stored number of bytes.
    public var count: Int {
        return bytesStore.count
    }
    
    public var isEmpty: Bool { nextFullByteIndex >= count }
    
    private var nextFullByteIndex: Int {
        return readBitCursor / byteSize
    }
    
    /// Creates a new `BinaryReader`.
    public init(bytes: BytesStore) {
        self.readBitCursor = 0
        self.bytesStore = bytes
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
    public func getBits<Integer>(range: Range<Int>, type: Integer.Type = Integer.self) throws -> Integer where Integer: FixedWidthInteger {
        assert(
            (MemoryLayout<Integer>.size * 8) >= range.count,
            "requested range count (\(range.count)) is larger than size of \(Integer.self) (\(MemoryLayout<Integer>.size * 8)bit)."
        )
        // Check if the request is within bounds
        let storeRange = 0...(bytesStore.count * byteSize)
        guard storeRange.contains(range.endIndex) else {
            throw BinaryError.outOfBounds
        }
        
        // Get bits
        return try range.reversed().enumerated().reduce(0) {
            let bit = try getBit(index: $1.element)
            return $0 &+ Integer(bit) << $1.offset
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
    public func getBytes(range: Range<Int>) throws -> BytesStore.SubSequence {
        // Check if the request is within bounds
        let storeRange = 0...bytesStore.count
        guard storeRange.contains(range.endIndex) else {
            throw BinaryError.outOfBounds
        }
        
        // Get bytes
        return bytesStore[range]
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
    
    /// Returns the `Int`-value of the next n-bits (`quantitiy`)
    /// and increments the reading cursor by n-bits.
    public mutating func readBits<Integer>(_ quantitiy: Int, type: Integer.Type = Integer.self) throws -> Integer where Integer: FixedWidthInteger {
        let range = (readBitCursor..<(readBitCursor + quantitiy))
        let result: Integer = try getBits(range: range)
        incrementReadCursorBy(bits: quantitiy)
        return result
    }
    
    /// Returns the `UInt8`-value of the next byte and
    /// increments the reading cursor by 1 byte.
    public mutating func readByte() throws -> UInt8 {
        let result = try getByte(index: nextFullByteIndex)
        incrementReadCursorBy(bytes: 1)
        return result
    }
    
    /// Returns a `[UInt8]` of the next n-bytes (`quantitiy`) and
    /// increments the reading cursor by n-bytes.
    public mutating func readBytes(_ quantitiy: Int) throws -> BytesStore.SubSequence {
        let readByteCursor = readBitCursor / byteSize
        incrementReadCursorBy(bytes: quantitiy)
        return try getBytes(range: readByteCursor..<(readByteCursor + quantitiy))
    }
    
    public mutating func readBytes(_ quantitiy: UInt8) throws -> BytesStore.SubSequence {
        return try readBytes(Int(quantitiy))
    }
    
    /// Returns a `String` of the next n-bytes (`quantitiy`) and
    /// increments the reading cursor by n-bytes.
    public mutating func readString(quantitiyOfBytes quantitiy: Int, encoding: String.Encoding = .ascii) throws -> String {
        guard let result = String(bytes: try self.readBytes(quantitiy), encoding: encoding) else {
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
        return try readBits(NibbleBitWidth)
    }
    
    // MARK: Read — Fixed Width Integer

    // Returns an `FixedWidthInteger` (UInt8, Int8, UInt16, ...) and increments the reading cursor by `MemoryLayout<Integer>.size` bytes.
    public mutating func readInteger<Integer>(type: Integer.Type = Integer.self) throws -> Integer where Integer: FixedWidthInteger {
        Integer(networkByteOrder: Integer(bytes: try readBytes(MemoryLayout<Integer>.size)))
    }
    
    // MARK: Read - Unsigned Integer
    
    /// Returns an `UInt8` and increments the reading cursor by 1 byte.
    public mutating func readUInt8() throws -> UInt8 {
        return try readByte()
    }
    
    /// Returns an `Int8` and increments the reading cursor by 1 byte.
    public mutating func readInt8() throws -> Int8 {
        return Int8(bitPattern: try readByte())
    }
    
    public mutating func readRemainingBytes() throws -> BytesStore.SubSequence {
        try readBytes(count - nextFullByteIndex)
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
}

extension BinaryReader where BytesStore == [UInt8] {
    /// Creates an empty `BinaryReader`.
    public init() {
        self.init(bytes: [])
    }
    
    /// Creates a new `BinaryReader` with a string of hexadecimal values converted to bytes.
    public init?(hexString: String) {
        let charsPerByte = 2
        let hexBase = 16
        let bytes = hexString.chunked(by: charsPerByte).compactMap{ UInt8($0, radix: hexBase) }
        guard hexString.count / charsPerByte == bytes.count else {
            return nil
        }
        self.init(bytes: bytes)
    }
}
