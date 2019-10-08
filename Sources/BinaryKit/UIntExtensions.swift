//
//  UIntExtensions.swift
//  
//
//  Created by Devran on 01.10.19.
//

extension UInt {
    init(bytes: [UInt8]) {
        self = bytes.reduce(UInt(0)) { value, byte in
            return value << UInt8.bitWidth | UInt(byte)
        }
    }
}
