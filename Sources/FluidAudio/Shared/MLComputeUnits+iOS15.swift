import CoreML

extension MLComputeUnits {
    /// `.cpuAndNeuralEngine` is iOS 16+ / macOS 13+. The Aidoku fork lowers the
    /// package floor to iOS 15 so the iOS-15 app target can link it. Callers
    /// that previously used `.cpuAndNeuralEngine` directly use this instead.
    /// The TTS backend that actually runs this code is gated `@available(iOS
    /// 16, *)` downstream, so the iOS-15 branch below is dead code that only
    /// needs to compile.
    public static var aneOrAll: MLComputeUnits {
        if #available(iOS 16, macOS 13, *) { return .cpuAndNeuralEngine }
        return .all
    }
}
