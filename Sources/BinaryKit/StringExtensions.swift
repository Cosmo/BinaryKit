//
//  StringExtensions.swift
//  
//
//  Created by Devran on 19.09.19.
//

extension String {
    internal func chunked(by groupCount: Int) -> [String] {
        let startIndex = self.startIndex
        return (0..<(self.count / groupCount)).map { (index: Int) -> String in
            let offset = index * groupCount
            let subStringStartIndex = self.index(startIndex, offsetBy: offset)
            let subStringEndIndex = self.index(startIndex, offsetBy: offset + groupCount)
            return String(self[subStringStartIndex..<subStringEndIndex])
        }
    }
}
