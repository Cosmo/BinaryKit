import Foundation

public struct Binary {
    private let bytes: [UInt8]
    
    public init(bytes: [UInt8]) {
        self.bytes = bytes
    }
    
    public init(data: NSData) {
        let bytesLength = data.length
        var bytesArray  = [UInt8](count: bytesLength, repeatedValue: 0)
        data.getBytes(&bytesArray, length: bytesLength)
        self.bytes      = bytesArray
    }
    
    public func bit(position: Int) -> Int {
        let byteSize        = 8
        let bytePosition    = position / byteSize
        let bitPosition     = 7 - (position % byteSize)
        let byte            = self.byte(bytePosition)
        return (byte >> bitPosition) & 0x01
    }
    
    public func bit(position: Int) -> Bit {
        return self.bit(position) == 1 ? Bit.One : Bit.Zero
    }
    
    public func bits(range: Range<Int>) -> Int {
        return range.reverse().enumerate().reduce(0) {
            $0 + (bit($1.element) << $1.index)
        }
    }
    
    public func bits(start: Int, _ length: Int) -> Int {
        return self.bits(start..<(start + length))
    }
    
    public func byte(position: Int) -> Int {
        return Int(self.bytes[position])
    }
    
    public func bytes(start: Int, _ length: Int) -> [UInt8] {
        return Array(self.bytes[start..<start+length])
    }
    
    public func bytes(start: Int, _ length: Int) -> Int {
        return bits(start*8, length*8)
    }
    
}