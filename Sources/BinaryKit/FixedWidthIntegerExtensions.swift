//
//  FixedWidthIntegerExtensions.swift
//  
//
//  Created by Devran on 01.10.19.
//

extension FixedWidthInteger {
    var bytes: [UInt8] {
        return (0..<(bitWidth / UInt8.bitWidth)).map {
            UInt8(truncatingIfNeeded: self >> ($0 * UInt8.bitWidth))
        }.reversed()
    }
}
