import CoreML

extension MLMultiArrayDataType {
    /// `.float16` is iOS 16+ / macOS 13+. The Aidoku fork lowers the package
    /// floor to iOS 15 so the iOS-15 app target can link it. The Kokoro
    /// synthesis path that uses Float16 multi-arrays is gated `@available(iOS
    /// 16, *)` downstream, so the iOS-15 branch below is dead code that only
    /// needs to compile — its `.float32` value is never actually exercised.
    public static var float16OrFloat32: MLMultiArrayDataType {
        if #available(iOS 16, macOS 13, *) { return .float16 }
        return .float32
    }
}
