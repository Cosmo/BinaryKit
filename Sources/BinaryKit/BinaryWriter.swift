import Foundation

public struct BinaryWriter<BytesStore: MutableDataProtocol> where BytesStore.Index == Int {
    /// Returns the bit position of the writing cursor.
    /// All methods starting with `write` will increment this value.
    public private(set) var writeBitCursor: Int
    
    /// Returns the byte position of the writing cursor.
    @usableFromInline
    internal var writeByteCursor: Int {
        return byteCursorFromBitCursor(writeBitCursor)
    }
    
    /// Returns the stored bytes.
    public private(set) var bytesStore: BytesStore
    
    /// Returns the stored number of bytes.
    public var count: Int {
        return bytesStore.count
    }
    
    /// Creates a new `BinaryWriter`.
    public init(bytes: BytesStore) {
        self.writeBitCursor = 0
        self.bytesStore = bytes
    }
    
    // MARK: - Write
    
    /// Writes a byte (`UInt8`) to `self`.
    public mutating func writeByte(_ byte: UInt8) {
        bytesStore.append(byte)
        writeBitCursor += UInt8.bitWidth
    }
    
    /// Writes bytes (`DataProtocol`) to `self`.
    public mutating func writeBytes<D>(_ bytes: D) where D: DataProtocol {
        bytesStore.append(contentsOf: bytes)
        writeBitCursor += bitCountFromByteCount(bytes.count)
    }
    
    /// Writes a bit (`UInt8`) to `self`.
    public mutating func writeBit(bit: UInt8) {
        let byte: UInt8 = (bit & 0b1) << Int(7 - (writeBitCursor % UInt8.bitWidth))
        let writeByteCursor = self.writeByteCursor
        
        if bytesStore.count == writeByteCursor {
            bytesStore.append(byte)
        } else {
            let oldByte = bytesStore[writeByteCursor]
            let newByte = oldByte ^ byte
            bytesStore[writeByteCursor] = newByte
        }
        
        writeBitCursor = writeBitCursor + 1
    }
    
    public mutating func writeBits<Integer>(from value: Integer, count: Int) where Integer: FixedWidthInteger {
        for index in (0..<count).reversed() {
            writeBit(bit: (value >> index).data[0])
        }
    }
    
    /// Writes a `Bool` as a bit to `self`.
    public mutating func writeBool(_ bool: Bool) {
        writeBit(bit: bool ? 1 : 0)
    }
    
    /// Writes a `String` to `self`.
    public mutating func writeString(_ string: String) {
        let bytes = [UInt8](string.utf8)
        writeBytes(bytes)
    }
    
    /// Writes an `FixedWidthInteger` (`Int`, `UInt8`, `Int8`, `UInt16`, `Int16`, …) to `self`.
    public mutating func writeInt<T: FixedWidthInteger>(_ int: T) {
        writeBytes(int.toNetworkByteOrder.data)
    }
}

extension BinaryWriter where BytesStore == [UInt8] {
    /// Creates an empty `BinaryWriter`.
    public init() {
        self.init(bytes: [])
    }
    
    /// Creates a new `BinaryWriter` with a string of hexadecimal values converted to bytes.
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
    public init(capacity: Int) {
        var bytes = BytesStore()
        bytes.reserveCapacity(capacity)
        self.init(bytes: bytes)
    }
}
