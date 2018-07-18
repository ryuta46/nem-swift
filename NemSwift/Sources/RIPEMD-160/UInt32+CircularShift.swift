
infix operator  ~<< : AssignmentPrecedence // { precedence 160 associativity none }

public func ~<< (lhs: UInt32, rhs: Int) -> UInt32 {
    return (lhs << UInt32(rhs)) | (lhs >> UInt32(32 - rhs));
}
