import Foundation

public struct Binary {
    public let bytes: [UInt8]
    public var readingOffset: Int = 0
    
    public init(bytes: [UInt8]) {
        self.bytes = bytes
    }
    
    public init(data: Data) {
        let bytesLength = data.count
        var bytesArray  = [UInt8](repeating: 0, count: bytesLength)
        (data as NSData).getBytes(&bytesArray, length: bytesLength)
        self.bytes      = bytesArray
    }
    
    public func bit(_ position: Int) -> Int {
        let byteSize        = 8
        let bytePosition    = position / byteSize
        let bitPosition     = 7 - (position % byteSize)
        let byte            = self.byte(bytePosition)
        return (byte >> bitPosition) & 0x01
    }
    
    public func bits(_ range: Range<Int>) -> Int {
        var positions = [Int]()
        
        for position in range.lowerBound..<range.upperBound {
            positions.append(position)
        }
        
        return positions.reversed().enumerated().reduce(0) {
            $0 + (bit($1.element) << $1.offset)
        }
    }
    
    public func bits(_ start: Int, _ length: Int) -> Int {
        return self.bits(start..<(start + length))
    }
    
    public func byte(_ position: Int) -> Int {
        return Int(self.bytes[position])
    }
    
    public func bytes(_ start: Int, _ length: Int) -> [UInt8] {
        return Array(self.bytes[start..<start+length])
    }
    
    public func bytes(_ start: Int, _ length: Int) -> Int {
        return bits(start*8, length*8)
    }
    
    public func bitsWithInternalOffsetAvailable(_ length: Int) -> Bool {
        return (self.bytes.count * 8) >= (self.readingOffset + length)
    }
    
    public mutating func next(bits length: Int) -> Int {
        if self.bitsWithInternalOffsetAvailable(length) {
            let returnValue = self.bits(self.readingOffset, length)
            self.readingOffset = self.readingOffset + length
            return returnValue
        } else {
            fatalError("Couldn't extract Bits.")
        }
    }
    
    public func bytesWithInternalOffsetAvailable(_ length: Int) -> Bool {
        let availableBits = self.bytes.count * 8
        let requestedBits = readingOffset + (length * 8)
        let possible      = availableBits >= requestedBits
        return possible
    }
    
    public mutating func next(bytes length: Int) -> [UInt8] {
        if bytesWithInternalOffsetAvailable(length) {
            let returnValue = self.bytes[(self.readingOffset / 8)..<((self.readingOffset / 8) + length)]
            self.readingOffset = self.readingOffset + (length * 8)
            return Array(returnValue)
        } else {
            fatalError("Couldn't extract Bytes.")
        }
    }
}
