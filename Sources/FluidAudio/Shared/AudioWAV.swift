import Foundation

// Extracted verbatim from the upstream `Shared/AudioConverter.swift` (deleted
// in the Aidoku Kokoro-only fork). `KokoroAneManager.synthesize()` depends on
// it; the rest of AudioConverter was ASR audio-input plumbing.
public enum AudioWAV {
    /// Convert float samples to 16-bit PCM mono WAV at the given sample rate.
    public static func data(from samples: [Float], sampleRate: Double) throws -> Data {
        // Normalize to [-1, 1]
        let maxVal = samples.map { abs($0) }.max() ?? 1.0
        let norm = maxVal > 0 ? samples.map { $0 / maxVal } : samples

        // Convert to 16-bit PCM
        var pcm = Data()
        pcm.reserveCapacity(norm.count * MemoryLayout<Int16>.size)
        for s in norm {
            let clipped = max(-1.0, min(1.0, s))
            let v = Int16(clipped * 32767)
            var le = v.littleEndian
            withUnsafeBytes(of: &le) { pcm.append(contentsOf: $0) }
        }

        // Build WAV header
        var wav = Data()
        // RIFF header
        wav.append(contentsOf: "RIFF".data(using: .ascii)!)
        var fileSize = UInt32(36 + pcm.count).littleEndian
        withUnsafeBytes(of: &fileSize) { wav.append(contentsOf: $0) }
        wav.append(contentsOf: "WAVE".data(using: .ascii)!)

        // fmt chunk
        wav.append(contentsOf: "fmt ".data(using: .ascii)!)
        var subchunk1Size = UInt32(16).littleEndian  // PCM
        withUnsafeBytes(of: &subchunk1Size) { wav.append(contentsOf: $0) }
        var audioFormat = UInt16(1).littleEndian  // PCM
        withUnsafeBytes(of: &audioFormat) { wav.append(contentsOf: $0) }
        var numChannels = UInt16(1).littleEndian
        withUnsafeBytes(of: &numChannels) { wav.append(contentsOf: $0) }
        var sr = UInt32(sampleRate).littleEndian
        withUnsafeBytes(of: &sr) { wav.append(contentsOf: $0) }
        var byteRate = UInt32(sampleRate * 2).littleEndian  // 16-bit mono
        withUnsafeBytes(of: &byteRate) { wav.append(contentsOf: $0) }
        var blockAlign = UInt16(2).littleEndian
        withUnsafeBytes(of: &blockAlign) { wav.append(contentsOf: $0) }
        var bitsPerSample = UInt16(16).littleEndian
        withUnsafeBytes(of: &bitsPerSample) { wav.append(contentsOf: $0) }

        // data chunk
        wav.append(contentsOf: "data".data(using: .ascii)!)
        var dataSize = UInt32(pcm.count).littleEndian
        withUnsafeBytes(of: &dataSize) { wav.append(contentsOf: $0) }
        wav.append(pcm)

        return wav
    }
}
