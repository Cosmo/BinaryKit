import XCTest
@testable import BinaryKit

final class BinaryKitTests: XCTestCase {
    // MARK: - Byte
    
    func testByte() {
        let bytes: [UInt8] = [0b1010_1101, 0b1010_1111]
        var bin = Binary(bytes: bytes)
        
        XCTAssertEqual(try bin.readByte(), 173)
        XCTAssertEqual(try bin.readByte(), 175)
        XCTAssertThrowsError(try bin.readByte())
        bin.resetCursor()
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
        
        XCTAssertEqual(try bin.readBytes(quantitiy: 1), [173])
        XCTAssertEqual(try bin.readBytes(quantitiy: 2), [175, 141])
        XCTAssertThrowsError(try bin.readBytes(quantitiy: 3))
        bin.resetCursor()
        XCTAssertEqual(try bin.readBytes(quantitiy: 1), [173])
    }
    
    func testBytesRange() {
        let bytes: [UInt8] = [0b1010_1101, 0b1010_1111]
        let bin = Binary(bytes: bytes)
        
        XCTAssertEqual(try bin.getBytes(range: 0..<2), [173, 175])
        XCTAssertThrowsError(try bin.getBytes(range: 2..<3))
    }
    
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
        
        bin.resetCursor()
        
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
        
        XCTAssertEqual(try bin.readBits(quantitiy: 4), 10)
        XCTAssertEqual(try bin.readBits(quantitiy: 4), 13)
        XCTAssertEqual(try bin.readBits(quantitiy: 8), 175)
        XCTAssertThrowsError(try bin.readBits(quantitiy: 1))
        bin.resetCursor()
        XCTAssertEqual(try bin.readBits(quantitiy: 8), 173)
    }
    
    func testBitsRange() {
        let bytes: [UInt8] = [0b1010_1101, 0b1010_1111]
        var bin = Binary(bytes: bytes)
        
        XCTAssertEqual(try bin.getBits(range: 0..<4), 10)
        XCTAssertEqual(try bin.getBits(range: 4..<8), 13)
        XCTAssertEqual(try bin.getBits(range: 8..<16), 175)
        XCTAssertThrowsError(try bin.getBits(range: 16..<17))
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
    
    // MARK: - Other Readers
    
    func testOtherReaders() {
        let bytes: [UInt8] = [104, 101, 108, 108, 111, 44, 32, 119, 111, 114, 108, 100, 33]
        var bin = Binary(bytes: bytes)
        XCTAssertEqual(try bin.readString(quantitiyOfBytes: 12), "hello, world")
    }
    
    // MARK: -

    static var allTests = [
        ("testByte", testByte),
        ("testByteIndex", testByteIndex),
        ("testBytes", testBytes),
        ("testBytesRange", testBytesRange),
        ("testBitIndex", testBitIndex),
        ("testBit", testBit),
        ("testBits", testBits),
        ("testBitsRange", testBitsRange),
        ("testHexInit", testHexInit),
        ("testOtherReaders", testOtherReaders),
    ]
}
