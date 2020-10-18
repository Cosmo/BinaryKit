import XCTest
@testable import BinaryKit

final class BinaryKitTests: XCTestCase {
    // MARK: - Bit
    
    func testBit() {
        let bytes: [UInt8] = [0b1010_1101, 0b1010_1111]
        var bin = Binary(bytes: bytes)
        
        XCTAssertEqual(try bin.readBit(), 1)
        XCTAssertEqual(try bin.readBit(), 0)
        XCTAssertEqual(try bin.readBit(), 1)
        XCTAssertEqual(try bin.readBit(), 0)
        XCTAssertEqual(try bin.readBit(), 1)
        XCTAssertEqual(try bin.readBit(), 1)
        XCTAssertEqual(try bin.readBit(), 0)
        XCTAssertEqual(try bin.readBit(), 1)
        
        XCTAssertEqual(try bin.readBit(), 1)
        XCTAssertEqual(try bin.readBit(), 0)
        XCTAssertEqual(try bin.readBit(), 1)
        XCTAssertEqual(try bin.readBit(), 0)
        XCTAssertEqual(try bin.readBit(), 1)
        XCTAssertEqual(try bin.readBit(), 1)
        XCTAssertEqual(try bin.readBit(), 1)
        XCTAssertEqual(try bin.readBit(), 1)
        
        XCTAssertThrowsError(try bin.readBit())
        
        bin.resetReadCursor()
        
        XCTAssertEqual(try bin.readBit(), 1)
        XCTAssertEqual(try bin.readBit(), 0)
    }
    
    func testBitIndex() {
        let bytes: [UInt8] = [0b1010_1101, 0b1010_1111]
        let bin = Binary(bytes: bytes)
        
        XCTAssertEqual(try bin.getBit(index: 0), 1)
        XCTAssertEqual(try bin.getBit(index: 1), 0)
        XCTAssertEqual(try bin.getBit(index: 2), 1)
        XCTAssertEqual(try bin.getBit(index: 3), 0)
    }
    
    func testBits() {
        let bytes: [UInt8] = [0b1010_1101, 0b1010_1111]
        var bin = Binary(bytes: bytes)
        
        XCTAssertEqual(try bin.readBits(4), 10)
        XCTAssertEqual(try bin.readBits(4), 13)
        XCTAssertEqual(try bin.readBits(8), 175)
        XCTAssertThrowsError(try bin.readBits(1))
        bin.resetReadCursor()
        XCTAssertEqual(try bin.readBits(8), 173)
    }
    
    func testBitsRange() {
        let bytes: [UInt8] = [0b1010_1101, 0b1010_1111]
        let bin = Binary(bytes: bytes)
        
        XCTAssertEqual(try bin.getBits(range: 0..<4), 10)
        XCTAssertEqual(try bin.getBits(range: 4..<8), 13)
        XCTAssertEqual(try bin.getBits(range: 8..<16), 175)
        XCTAssertThrowsError(try bin.getBits(range: 16..<17))
    }
    
    // MARK: - Byte
    
    func testByte() {
        let bytes: [UInt8] = [0b1010_1101, 0b1010_1111]
        var bin = Binary(bytes: bytes)
        
        XCTAssertEqual(try bin.readByte(), 173)
        XCTAssertEqual(try bin.readByte(), 175)
        XCTAssertThrowsError(try bin.readByte())
        bin.resetReadCursor()
        XCTAssertEqual(try bin.readByte(), 173)
        XCTAssertEqual(try bin.readByte(), 175)
    }

    func testByteIndex() {
        let bytes: [UInt8] = [0b1010_1101, 0b1010_1111]
        let bin = Binary(bytes: bytes)
        
        XCTAssertThrowsError(try bin.getByte(index: -1))
        XCTAssertEqual(try bin.getByte(index: 0), 173)
        XCTAssertEqual(try bin.getByte(index: 1), 175)
        XCTAssertThrowsError(try bin.getByte(index: 2))
    }
    
    func testBytes() {
        let bytes: [UInt8] = [0b1010_1101, 0b1010_1111, 0b1000_1101]
        var bin = Binary(bytes: bytes)
        
        XCTAssertEqual(try bin.readBytes(1), [173])
        XCTAssertEqual(try bin.readBytes(2), [175, 141])
        XCTAssertThrowsError(try bin.readBytes(3))
        bin.resetReadCursor()
        XCTAssertEqual(try bin.readBytes(1), [173])
    }
    
    func testBytesRange() {
        let bytes: [UInt8] = [0b1010_1101, 0b1010_1111]
        let bin = Binary(bytes: bytes)
        
        XCTAssertEqual(try bin.getBytes(range: 0..<2), [173, 175])
        XCTAssertThrowsError(try bin.getBytes(range: 2..<3))
    }

    // MARK: - Mixed Reading

    func testMixedReadByte() {
        let bytes: [UInt8] = [0b1010_1101, 0b1010_1111]
        var bin = Binary(bytes: bytes)

        XCTAssertEqual(try bin.readBit(), 1)
        XCTAssertEqual(try bin.readByte(), 91)
        XCTAssertEqual(bin.readBitCursor, 9)
    }

    func testMixedReadBytes() {
        let bytes: [UInt8] = [0b1010_1101, 0b1010_1111, 0b1000_1101]
        var bin = Binary(bytes: bytes)

        XCTAssertEqual(try bin.readBit(), 1)
        XCTAssertEqual(try bin.readBytes(2), [UInt8(91),UInt8(95)])
        XCTAssertEqual(bin.readBitCursor, 17)
    }

    func testReadBytesThrowsBeforeReading() {
        let bytes: [UInt8] = [0b1010_1101, 0b1010_1111, 0b1000_1101]
        var bin = Binary(bytes: bytes)

        XCTAssertEqual(try bin.readBit(), 1)
        XCTAssertEqual(bin.readBitCursor, 1)
        XCTAssertThrowsError(try bin.readBytes(3))
        XCTAssertEqual(bin.readBitCursor, 1)
    }

    func testReadBitsThrowsBeforeReading() {
        let bytes: [UInt8] = [0b1010_1101, 0b1010_1111, 0b1000_1101]
        var bin = Binary(bytes: bytes)

        XCTAssertEqual(bin.readBitCursor, 0)
        XCTAssertThrowsError(try bin.readBits(100))
        XCTAssertEqual(bin.readBitCursor, 0)
    }

    // MARK: - Init
    
    func testHexInit() {
        let brokenBinary = Binary(hexString: "xFF00F1")
        XCTAssertNil(brokenBinary)
        
        let binary = Binary(hexString: "FF00F1")
        XCTAssertNotNil(binary)
        guard var bin = binary else { return }
        
        XCTAssertEqual(try bin.readByte(), 255)
        XCTAssertEqual(try bin.readByte(), 0)
        XCTAssertEqual(try bin.readByte(), 241)
        XCTAssertThrowsError(try bin.readByte())
    }
    
    // MARK: - Nibble
    
    func testNibble() {
        let bytes: [UInt8] = [0b1010_1101, 0b1010_1111]
        var bin = Binary(bytes: bytes)
        
        XCTAssertEqual(try bin.readNibble(), 10)
        XCTAssertEqual(try bin.readNibble(), 13)
    }
    
    // MARK: - String and Character
    
    func testStringAndCharacter() {
        let bytes: [UInt8] = [104, 101, 108, 108, 111, 44, 32, 119, 111, 114, 108, 100, 33, 0, 255, 0, 100, 0, 9]
        var bin = Binary(bytes: bytes)
        XCTAssertEqual(try bin.readString(quantityOfBytes: 12), "hello, world")
        XCTAssertEqual(try bin.readCharacter(), "!")
        XCTAssertThrowsError(try bin.readString(quantityOfBytes: 6, encoding: .nonLossyASCII))
    }
    
    // MARK: - Bool
    
    func testBool() {
        let bytes: [UInt8] = [0b1101_0101]
        var bin = Binary(bytes: bytes)
        XCTAssertEqual(try bin.readBool(), true)
        XCTAssertEqual(try bin.readBool(), true)
        XCTAssertEqual(try bin.readBool(), false)
        XCTAssertEqual(try bin.readBool(), true)
        XCTAssertEqual(try bin.readBool(), false)
    }
    
    // MARK: - Finders
    
    func testFinders() {
        let bytes: [UInt8] = [104, 101, 108, 108, 111, 44, 32, 119, 111, 114, 108, 100, 33]
        let bin = Binary(bytes: bytes)
        XCTAssertEqual(bin.indices(of: [111, 44]), [4])
        XCTAssertEqual(bin.indices(of: "l"), [2, 3, 10])
        XCTAssertEqual(bin.indices(of: "wo"), [7])
    }
    
    // MARK: - Write
    
    func testWrite() {
        var bin = Binary(bytes: [])
        bin.writeBit(bit: 1)
        XCTAssertEqual(bin.bytesStore, [128])
        bin.writeBit(bit: 1)
        XCTAssertEqual(bin.bytesStore, [192])
        bin.writeBit(bit: 1)
        XCTAssertEqual(bin.bytesStore, [224])
        bin.writeBit(bit: 1)
        XCTAssertEqual(bin.bytesStore, [240])
        bin.writeBit(bit: 1)
        XCTAssertEqual(bin.bytesStore, [248])
        bin.writeBit(bit: 1)
        XCTAssertEqual(bin.bytesStore, [252])
        bin.writeBit(bit: 1)
        XCTAssertEqual(bin.bytesStore, [254])
        bin.writeBit(bit: 1)
        XCTAssertEqual(bin.bytesStore, [255])
        bin.writeBit(bit: 1)
        XCTAssertEqual(bin.bytesStore, [255, 128])
        bin.writeByte(7)
        XCTAssertEqual(bin.bytesStore, [255, 128, 7])
        bin.writeByte(128)
        XCTAssertEqual(bin.bytesStore, [255, 128, 7, 128])
        bin.writeString("hello world!")
        XCTAssertEqual(bin.bytesStore, [255, 128, 7, 128] + [UInt8]("hello world!".utf8))
        bin.writeInt(UInt8(2))
        bin.writeInt(UInt32(UInt32.max))


        
        XCTAssertEqual(try bin.readBit(), 1)
        XCTAssertEqual(try bin.readBit(), 1)
        XCTAssertEqual(try bin.readBit(), 1)
        XCTAssertEqual(try bin.readBit(), 1)

        XCTAssertEqual(try bin.readBit(), 1)
        XCTAssertEqual(try bin.readBit(), 1)
        XCTAssertEqual(try bin.readBit(), 1)
        XCTAssertEqual(try bin.readBit(), 1)

        XCTAssertEqual(try bin.readByte(), 128)

        XCTAssertEqual(try bin.readByte(), 7)
        XCTAssertEqual(try bin.readByte(), 128)
        XCTAssertEqual(try bin.readString(quantityOfBytes: 12), "hello world!")
        XCTAssertEqual(try bin.readByte(), 2)
        
        XCTAssertEqual(try bin.readByte(), 255)
        XCTAssertEqual(try bin.readByte(), 255)
        XCTAssertEqual(try bin.readByte(), 255)
        XCTAssertEqual(try bin.readByte(), 255)
    }
    
    func testWriteInt() {
        var bin = Binary(bytes: [])
        bin.writeInt(UInt32(2_370_718_244))
        bin.writeInt(UInt64(0x4112444912881220))
        bin.writeInt(Int8(Int8.max))
        bin.writeInt(Int8(Int8.min))
        bin.writeInt(Int16(Int16.max))
        bin.writeInt(Int16(Int16.min))
        bin.writeInt(Int32(Int32.max))
        bin.writeInt(Int32(Int32.min))
        bin.writeInt(Int64(Int64.max))
        bin.writeInt(Int64(Int64.min))
        
        bin.writeInt(UInt8(UInt8.max))
        bin.writeInt(UInt8(UInt8.min))
        bin.writeInt(UInt16(UInt16.max))
        bin.writeInt(UInt16(UInt16.min))
        bin.writeInt(UInt32(UInt32.max))
        bin.writeInt(UInt32(UInt32.min))
        bin.writeInt(UInt64(UInt64.max))
        bin.writeInt(UInt64(UInt64.min))
        
        
        XCTAssertEqual(try bin.readUInt32(), 2_370_718_244)
        XCTAssertEqual(try bin.readUInt64(), 0x4112444912881220)
        
        XCTAssertEqual(try bin.readInt8(), Int8.max)
        XCTAssertEqual(try bin.readInt8(), Int8.min)
        XCTAssertEqual(try bin.readInt16(), Int16.max)
        XCTAssertEqual(try bin.readInt16(), Int16.min)
        XCTAssertEqual(try bin.readInt32(), Int32.max)
        XCTAssertEqual(try bin.readInt32(), Int32.min)
        XCTAssertEqual(try bin.readInt64(), Int64.max)
        XCTAssertEqual(try bin.readInt64(), Int64.min)
        
        XCTAssertEqual(try bin.readUInt8(), UInt8.max)
        XCTAssertEqual(try bin.readUInt8(), UInt8.min)
        XCTAssertEqual(try bin.readUInt16(), UInt16.max)
        XCTAssertEqual(try bin.readUInt16(), UInt16.min)
        XCTAssertEqual(try bin.readUInt32(), UInt32.max)
        XCTAssertEqual(try bin.readUInt32(), UInt32.min)
        XCTAssertEqual(try bin.readUInt64(), UInt64.max)
        XCTAssertEqual(try bin.readUInt64(), UInt64.min)
    }
    
    func testLongBits() {
        var bin = Binary(bytes: [0x47, 0x11, 0xff, 0x1c])
        XCTAssertEqual(try bin.readBits(8), 0x47)
        XCTAssertEqual(try bin.readBits(3), 0)
        XCTAssertEqual(try bin.readBits(13), 0x11ff)
    }
    
    func testSignedBits() {
        var binary = Binary(bytes: [0xFF, 0x7F, 0x00, 0xFF, 0x77, 0xFF, 0xFF])
        XCTAssertEqual(try binary.readSignedBits(8), -127)
        XCTAssertEqual(try binary.readSignedBits(8), 127)
        XCTAssertEqual(try binary.readSignedBits(8), 0)
        XCTAssertEqual(try binary.readSignedBits(4), -7)
        XCTAssertEqual(try binary.readSignedBits(4), -7)
        XCTAssertEqual(try binary.readSignedBits(4), 7)
        XCTAssertEqual(try binary.readSignedBits(4), 7)
        XCTAssertEqual(try binary.readSignedBits(16), -32767)
    }
    
    // MARK: -

    static var allTests = [
        ("testBitIndex", testBitIndex),
        ("testBit", testBit),
        ("testBits", testBits),
        ("testBitsRange", testBitsRange),
        ("testByte", testByte),
        ("testByteIndex", testByteIndex),
        ("testBytes", testBytes),
        ("testBytesRange", testBytesRange),
        ("testHexInit", testHexInit),
        ("testNibble", testNibble),
        ("testStringAndCharacter", testStringAndCharacter),
        ("testFinders", testFinders),
        ("testWrite", testWrite),
        ("testWriteInt", testWriteInt),
        ("testLongBits", testLongBits),
    ]
}
