import Foundation

public struct BinaryWriter<BytesStore: MutableDataProtocol> where BytesStore.Index == Int {
    /// Returns the bit position of the writing cursor.
    /// All methods starting with `write` will increment this value.
    @usableFromInline
    internal var writeBitCursor: Int
    
    /// Returns the byte position of the writing cursor.
    @usableFromInline
    internal var writeByteCursor: Int {
        return byteCursorFromBitCursor(writeBitCursor)
    }
    
    @usableFromInline
    internal var _bytes: BytesStore
    /// Returns the stored bytes.
    @inlinable
    public var bytes: BytesStore { _bytes }
    
    /// Returns the stored number of bytes.
    @inlinable
    public var count: Int {
        return bytes.count
    }
    
    /// Creates a new `BinaryWriter`.
    @inlinable
    public init(bytes: BytesStore) {
        self.writeBitCursor = 0
        self._bytes = bytes
    }
    
    // MARK: - Write
    
    /// Writes a byte (`UInt8`) to `self`.
    @inlinable
    public mutating func writeByte(_ byte: UInt8) {
        _bytes.append(byte)
        writeBitCursor += UInt8.bitWidth
    }
    
    /// Writes bytes (`DataProtocol`) to `self`.
    @inlinable
    public mutating func writeBytes<D>(_ bytes: D) where D: DataProtocol {
        self._bytes.append(contentsOf: bytes)
        writeBitCursor += bitCountFromByteCount(bytes.count)
    }
    
    /// Writes a bit (`UInt8`) to `self`.
    @inlinable
    public mutating func writeBit(bit: UInt8) {
        let byte: UInt8 = (bit & 0b1) << Int(7 - (writeBitCursor % UInt8.bitWidth))
        let writeByteCursor = self.writeByteCursor
        
        if bytes.count == writeByteCursor {
            _bytes.append(byte)
        } else {
            let oldByte = bytes[writeByteCursor]
            let newByte = oldByte ^ byte
            _bytes[writeByteCursor] = newByte
        }
        
        writeBitCursor = writeBitCursor + 1
    }
    
    @inlinable
    public mutating func writeBits<Integer>(from value: Integer, count: Int) where Integer: FixedWidthInteger {
        for index in (0..<count).reversed() {
            writeBit(bit: (value >> index).data[0])
        }
    }
    
    /// Writes a `Bool` as a bit to `self`.
    @inlinable
    public mutating func writeBool(_ bool: Bool) {
        writeBit(bit: bool ? 1 : 0)
    }
    
    /// Writes a `String` to `self`.
    @inlinable
    public mutating func writeString(_ string: String) {
        let bytes = [UInt8](string.utf8)
        writeBytes(bytes)
    }
    
    /// Writes an `FixedWidthInteger` (`Int`, `UInt8`, `Int8`, `UInt16`, `Int16`, …) to `self`.
    @inlinable
    public mutating func writeInt<T: FixedWidthInteger>(_ int: T) {
        writeBytes(int.toNetworkByteOrder.data)
    }
}

extension BinaryWriter where BytesStore == [UInt8] {
    /// Creates an empty `BinaryWriter`.
    @inlinable
    public init() {
        self.init(bytes: [])
    }
    
    /// Creates a new `BinaryWriter` with a string of hexadecimal values converted to bytes.
    @inlinable
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

extension BinaryWriter {
    @inlinable
    public init(capacity: Int) {
        var bytes = BytesStore()
        bytes.reserveCapacity(capacity)
        self.init(bytes: bytes)
    }
}
