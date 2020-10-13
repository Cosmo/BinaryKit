import XCTest

public func allTests() -> [Linux.TestCase] {
    return [
        Linux.makeTestCase(using: BinaryKitTests.allTests),
    ]
}

#if canImport(ObjectiveC)
internal final class LinuxVerificationTests: XCTestCase {
    func testAllTestsRunOnLinux() {
        Linux.testAllTestsRunOnLinux(allTests: allTests())
    }
}
#endif

public enum Linux {}

public extension Linux {
    typealias TestCase = (testCaseClass: XCTestCase.Type, allTests: TestManifest)
    typealias TestManifest = [(String, TestRunner)]
    typealias TestRunner = (XCTestCase) throws -> Void
    typealias TestList<T: XCTestCase> = [(String, Test<T>)]
    typealias Test<T: XCTestCase> = (T) -> () throws -> Void
}

extension Linux {
    static func makeTestCase<T: XCTestCase>(using list: TestList<T>) -> TestCase {
        let manifest: TestManifest = list.map { name, function in
            (name, { type in
                try function(type as! T)()
            })
        }
        
        return (T.self, manifest)
    }
    
    #if canImport(ObjectiveC)
    static func testAllTestsRunOnLinux(allTests: [Linux.TestCase]) {
        for testCase in allTests {
            let type = testCase.testCaseClass
            
            let testNames: [String] = type.defaultTestSuite.tests.map { test in
                let components = test.name.components(separatedBy: .whitespaces)
                return components[1].replacingOccurrences(of: "]", with: "")
            }
            
            let linuxTestNames = Set(testCase.allTests.map { $0.0 })
            
            for name in testNames {
                if !linuxTestNames.contains(name) {
                    XCTFail("""
                        \(type).\(name) does not run on Linux.
                        Please add it to \(type).allTests.
                        """)
                }
            }
        }
    }
    #endif
}
