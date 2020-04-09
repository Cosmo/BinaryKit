import Foundation

public struct BinaryWriter<BytesStore: MutableDataProtocol> where BytesStore.Index == Int {
    /// Returns the bit position of the writing cursor.
    /// All methods starting with `write` will increment this value.
    public private(set) var writeBitCursor: Int
    
    /// Returns the stored bytes.
    public private(set) var bytesStore: BytesStore
    
    /// Constant with number of bits in a byte
    private let byteSize = UInt8.bitWidth
    
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
    }
    
    /// Writes bytes (`[UInt8]`) to `self`.
    public mutating func writeBytes(_ bytes: [UInt8]) {
        bytesStore.append(contentsOf: bytes)
    }
    
    /// Writes a bit (`UInt8`) to `self`.
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
    
    /// Writes a `Bool` as a bit to `self`.
    public mutating func writeBool(_ bool: Bool) {
        writeBit(bit: bool ? 1 : 0)
    }
    
    /// Writes a `String` to `self`.
    public mutating func writeString(_ string: String) {
        let bytes = [UInt8](string.utf8)
        writeBytes(bytes)
    }
    
    /// Writes an `FixedWidthInteger` (`Int`, `UInt8`, `Int8`, `UInt16`, `Int16`, …) to `Binary`.
    public mutating func writeInt<T: FixedWidthInteger>(_ int: T) {
        bytesStore.append(contentsOf: int.bytes)
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
