import Foundation

precedencegroup ExponentiationPrecedence {
    associativity: right
    higherThan: MultiplicationPrecedence
}

prefix operator √
infix operator ** : ExponentiationPrecedence
infix operator %%: MultiplicationPrecedence

extension SignedInteger {
    static func %% (_ lhs: Self, _ rhs: Self) -> Self {
        let r = lhs % rhs
        return r >= 0 ? r : r + abs(rhs)
    }
}

extension Float: Exponentiable {
    static let e: Float = exp(1)
    static func ** (_ lhs: Self, _ rhs: Self) -> Self { powf(lhs, rhs) }
    static prefix func √ (_ radicand: Self) -> Self { sqrtf(radicand) }
}

extension Double: Exponentiable {
    static let e: Double = exp(1)
    static func ** (_ lhs: Self, _ rhs: Self) -> Self { pow(lhs, rhs) }
    static prefix func √ (_ radicand: Self) -> Self { sqrt(radicand) }
}

extension Exponentiable {
    static func Ν(x: Self, μ: Self, σ: Self) -> Self {
        let exponent = (-1 * (((x - μ)/σ) ** 2)/2)
        return Self.e ** exponent / (σ * √(2*Self.pi))
    }
}
