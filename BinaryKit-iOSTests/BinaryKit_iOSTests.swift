//
//  BinaryKit_iOSTests.swift
//  BinaryKit-iOSTests
//
//  Created by Devran Uenal on 11.9.16.
//
//

import XCTest
import BinaryKit

class BinaryKit_iOSTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testBit0() {
        var binary = Binary(bytes: [0xDE, 0xAD])
        let bit0 = binary.next(bits: 1)
        XCTAssertEqual(bit0, 1)
    }
    
    func testBit1() {
        var binary = Binary(bytes: [0xDE, 0xAD])
        let _ = binary.next(bits: 1)
        let bit1 = binary.next(bits: 1)
        XCTAssertEqual(bit1, 1)
    }
    
    func testBit2() {
        var binary = Binary(bytes: [0xDE, 0xAD])
        let _ = binary.next(bits: 1)
        let _ = binary.next(bits: 1)
        let bit2 = binary.next(bits: 1)
        XCTAssertEqual(bit2, 0)
    }
    
    func testBit3() {
        var binary = Binary(bytes: [0xDE, 0xAD])
        let _ = binary.next(bits: 1)
        let _ = binary.next(bits: 1)
        let _ = binary.next(bits: 1)
        let bit3 = binary.next(bits: 1)
        XCTAssertEqual(bit3, 1)
    }
    
    func testBit4And5() {
        var binary = Binary(bytes: [0xDE, 0xAD])
        let _ = binary.next(bits: 1)
        let _ = binary.next(bits: 1)
        let _ = binary.next(bits: 1)
        let _ = binary.next(bits: 1)
        let bits4And5 = binary.next(bits: 2)
        XCTAssertEqual(bits4And5, 3)
    }
    
    func testBit6And7() {
        var binary = Binary(bytes: [0xDE, 0xAD])
        let _ = binary.next(bits: 1)
        let _ = binary.next(bits: 1)
        let _ = binary.next(bits: 1)
        let _ = binary.next(bits: 1)
        let _ = binary.next(bits: 2)
        let bits6And7 = binary.next(bits: 2)
        XCTAssertEqual(bits6And7, 2)
    }
    
    func testByte1() {
        var binary = Binary(bytes: [0xDE, 0xAD])
        let _ = binary.next(bits: 1)
        binary.readingOffset = 0
        let bytes0and1 = binary.next(bytes: 2)
        XCTAssertEqual(bytes0and1, [222, 173])
    }
    
    func testBitByPosition() {
        var binary = Binary(bytes: [0xDE, 0xAD])
        let _ = binary.next(bits: 1)
        binary.readingOffset = 0
        let bit5 = binary.bit(5)
        XCTAssertEqual(bit5, 1)
    }
    
    func testByteByPosition() {
        var binary = Binary(bytes: [0xDE, 0xAD])
        let _ = binary.next(bits: 1)
        binary.readingOffset = 0
        let _ = binary.bit(5)
        let byte1 = binary.byte(1)
        XCTAssertEqual(byte1, 173)
    }
    
    func testFirst16Bits() {
        var binary = Binary(bytes: [0xDE, 0xAD])
        let _ = binary.next(bits: 1)
        binary.readingOffset = 0
        let _ = binary.bit(5)
        let _ = binary.byte(1)
        let first16Bits = binary.bits(0, 16)
        XCTAssertEqual(first16Bits, 57005)
    }
    
    func testFirstTwoBytes() {
        var binary = Binary(bytes: [0xDE, 0xAD])
        let _ = binary.next(bits: 1)
        binary.readingOffset = 0
        let _ = binary.bit(5)
        let _ = binary.byte(1)
        let _ = binary.bits(0, 16)
        let firstTwoBytes = binary.bytes(0, 2) as Int
        XCTAssertEqual(firstTwoBytes, 57005)
    }
}
