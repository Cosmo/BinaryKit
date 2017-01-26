import XCTest
@testable import BinaryKitTests

XCTMain([
    testCase([
        ("testBit0", BinaryKit_iOSTests.testBit0),
        ("testBit1", BinaryKit_iOSTests.testBit1),
        ("testBit2", BinaryKit_iOSTests.testBit2),
        ("testBit3", BinaryKit_iOSTests.testBit3),
        ("testBit4And5", BinaryKit_iOSTests.testBit4And5),
        ("testBit6And7", BinaryKit_iOSTests.testBit6And7),
        ("testByte1", BinaryKit_iOSTests.testByte1),
        ("testBitByPosition", BinaryKit_iOSTests.testBitByPosition),
        ("testByteByPosition", BinaryKit_iOSTests.testByteByPosition),
        ("testFirst16Bits", BinaryKit_iOSTests.testFirst16Bits),
        ("testFirstTwoBytes", BinaryKit_iOSTests.testFirstTwoBytes),
    ])
])
