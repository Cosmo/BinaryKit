import Foundation

enum BinError: Error {
    case outOfBounds
    case notString
}

public struct Binary {
    /// Stores a reading cursor in bits.
    /// All methods starting with `read` will increment the value of `bitCursor`.
    private var bitCursor: Int
    
    /// Stores the binary content.
    var bytesStore: [UInt8]
    
    private let byteSize = UInt8.bitWidth
    
    public init(bytes: [UInt8]) {
        self.bitCursor = 0
        self.bytesStore = bytes
    }
    
    /// Initialize with a `String` of hexadecimal values.
    public init?(hexString: String) {
        let bytes = hexString.chunked(by: 2).compactMap{ UInt8($0, radix: 16) }
        guard hexString.count == bytes.count * 2 else {
            return nil
        }
        self.init(bytes: bytes)
    }
    
    // MARK: - Cursor
    
    /// Returns an `Int` with the value of `bitCursor` incremented by `bits`.
    private func incrementedCursorBy(bits: Int) -> Int {
        return bitCursor + bits
    }
    
    /// Returns an `Int` with the value of `bitCursor` incremented by `bytes`.
    private func incrementedCursorBy(bytes: Int) -> Int {
        return bitCursor + (bytes * byteSize)
    }
    
    /// Increments the `bitCursor`-value by the given `bits`.
    private mutating func incrementCursorBy(bits: Int) {
        bitCursor = incrementedCursorBy(bits: bits)
    }
    
    /// Increments the `bitCursor`-value by the given `bytes`.
    private mutating func incrementCursorBy(bytes: Int) {
        bitCursor = incrementedCursorBy(bytes: bytes)
    }

    /// Sets the reading cursor back to its initial value.
    public mutating func resetCursor() {
        self.bitCursor = 0
    }
    
    // MARK: - Bit
    
    /// Returns an `UInt8` with the value of 0 or 1 of the given position.
    public func getBit(index: Int) throws -> UInt8 {
        guard (0..<(bytesStore.count)).contains(index / byteSize) else {
            throw BinError.outOfBounds
        }
        let byteCursor = index / byteSize
        let bitindex = 7 - (index % byteSize)
        return (bytesStore[byteCursor] >> bitindex) & 1
    }
    
    /// Returns the `Int`-value of the given range.
    public mutating func getBits(range: Range<Int>) throws -> Int {
        guard (0...(bytesStore.count * byteSize)).contains(range.endIndex) else {
            throw BinError.outOfBounds
        }
        return try range.reversed().enumerated().reduce(0) {
            $0 + Int(try getBit(index: $1.element) << $1.offset)
        }
    }
    
    /// Returns an `UInt8` with the value of 0 or 1 of the given
    /// position and increments the reading cursor by one bit.
    public mutating func readBit() throws -> UInt8 {
        let result = try getBit(index: bitCursor)
        incrementCursorBy(bits: 1)
        return result
    }
    
    /// Returns the `Int`-value of the next n-bits (`quantitiy`)
    /// and increments the reading cursor by n-bits.
    public mutating func readBits(quantitiy: Int) throws -> Int {
        guard (0...(bytesStore.count * byteSize)).contains(bitCursor + quantitiy) else {
            throw BinError.outOfBounds
        }
        let result = try (bitCursor..<(bitCursor + quantitiy)).reversed().enumerated().reduce(0) {
            $0 + Int(try getBit(index: $1.element) << $1.offset)
        }
        incrementCursorBy(bits: quantitiy)
        return result
    }
    
    // MARK: - Byte
    
    /// Returns the `UInt8`-value of the given `index`.
    public func getByte(index: Int) throws -> UInt8 {
        /// Check if `index` is within bounds of `bytes`
        guard (0..<(bytesStore.count)).contains(index) else {
            throw BinError.outOfBounds
        }
        return bytesStore[index]
    }
    
    /// Returns an `[UInt8]` of the given `range`.
    public func getBytes(range: Range<Int>) throws -> [UInt8] {
        guard (0...(bytesStore.count)).contains(range.endIndex) else {
            throw BinError.outOfBounds
        }
        return Array(bytesStore[range])
    }
    
    /// Returns the `UInt8`-value of the next byte and increments the reading cursor.
    public mutating func readByte() throws -> UInt8 {
        let result = try getByte(index: bitCursor / byteSize)
        incrementCursorBy(bytes: 1)
        return result
    }
    
    /// Returns an `[UInt8]` of the next n-bytes (`quantitiy`) and
    /// increments the reading cursor by n-bytes.
    public mutating func readBytes(quantitiy: Int) throws -> [UInt8] {
        let byteCursor = bitCursor / byteSize
        incrementCursorBy(bytes: quantitiy)
        return try getBytes(range: byteCursor..<(byteCursor + quantitiy))
    }
    
    // MARK: - Read Other
    
    public mutating func readString(quantitiyOfBytes quantitiy: Int, encoding: String.Encoding = .utf8) throws -> String {
        guard let result = String(bytes: try self.readBytes(quantitiy: quantitiy), encoding: encoding) else {
            throw BinError.notString
        }
        return result
    }
    
    public mutating func readCharacter() throws -> Character {
        return Character(UnicodeScalar(try readByte()))
    }
    
    public mutating func readBool() throws -> Bool {
        return try readBit() == 1
    }
    
    public mutating func readNibble() throws -> UInt8 {
        return UInt8(try readBits(quantitiy: 4))
    }
    
    // MARK: - Find
    
    func indices(of sequence: [UInt8]) -> [Int] {
        let size = sequence.count
        return bytesStore.indices.dropLast(size-1).filter {
            bytesStore[$0..<$0+size].elementsEqual(sequence)
        }
    }
    
    func indices(of string: String) -> [Int] {
        let sequence = [UInt8](string.utf8)
        return indices(of: sequence)
    }
}
