import Foundation

infix operator %%: MultiplicationPrecedence

extension SignedInteger {
    static func %% (_ lhs: Self, _ rhs: Self) -> Self {
        let r = lhs % rhs
        return r >= 0 ? r : r + abs(rhs)
    }
}

