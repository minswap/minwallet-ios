import Foundation
import UIKit

#if canImport(Darwin)
    import MachO  // for _dyld_* APIs
#endif

public struct JBIndicator: Hashable {
    public let name: String
    public let passed: Bool
    public let details: String
}

public struct JBResult {
    public let isSimulator: Bool
    public let suspicionScore: Int  // >= 3: HIGH, 1-2: MEDIUM, 0: LOW
    public let indicators: [JBIndicator]
}

public enum JailbreakDetector {
    // MARK: - Public entry
    public static func scan() -> JBResult {
        var indicators: [JBIndicator] = []
        
        let sim = isRunningOnSimulator()
        indicators.append(
            .init(
                name: "Simulator check",
                passed: !sim,
                details: sim ? "Running on Simulator" : "Real device"))
        
        indicators.append(checkSuspiciousPaths())
        indicators.append(checkWriteOutsideSandbox())
        indicators.append(checkCydiaURLScheme())
        indicators.append(checkForkOrPrivAPIs())
        indicators.append(checkInjectedDylibs())
        
        // Score: count failed (passed == false) except simulator (we won’t score simulator as JB)
        var score = indicators.reduce(0) { sum, ind in
            if ind.name == "Simulator check" { return sum }
            return sum + (ind.passed ? 0 : 1)
        }
        
        // Cap & simple policy: if Simulator -> keep score low
        if sim { score = min(score, 1) }
        
        return JBResult(isSimulator: sim, suspicionScore: score, indicators: indicators)
    }
    
    // MARK: - Indicators
    
    // 1) Well-known JB paths
    private static func checkSuspiciousPaths() -> JBIndicator {
        let suspicious = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/",
            "/Applications/FakeCarrier.app",
            "/Applications/blackra1n.app",
            "/var/lib/cydia",
            "/var/cache/apt",
        ]
        let exists = suspicious.contains { FileManager.default.fileExists(atPath: $0) }
        return JBIndicator(
            name: "Suspicious paths",
            passed: !exists,
            details: exists ? "Found at least one well-known JB path" : "No suspicious paths found"
        )
    }
    
    // 2) Try writing outside app container (should fail on non-JB)
    private static func checkWriteOutsideSandbox() -> JBIndicator {
        let testPath = "/private/\(UUID().uuidString)"
        do {
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            // cleanup if somehow succeeded
            try? FileManager.default.removeItem(atPath: testPath)
            return JBIndicator(name: "Sandbox write /private", passed: false, details: "Write succeeded")
        } catch {
            return JBIndicator(name: "Sandbox write /private", passed: true, details: "Write blocked (\(error.localizedDescription))")
        }
    }
    
    // 3) canOpenURL for cydia:// (needs LSApplicationQueriesSchemes or will just return false)
    private static func checkCydiaURLScheme() -> JBIndicator {
        guard let url = URL(string: "cydia://package/com.example") else {
            return JBIndicator(name: "Cydia URL scheme", passed: true, details: "URL build failed")
        }
        let can = UIApplication.shared.canOpenURL(url)
        return JBIndicator(name: "Cydia URL scheme", passed: !can, details: can ? "cydia:// is openable" : "cannot open cydia://")
    }
    
    // 4) fork / task_for_pid / ptrace – rough heuristic (should be blocked on stock iOS)
    private static func checkForkOrPrivAPIs() -> JBIndicator {
        // Avoid calling unavailable APIs like fork() on iOS. Instead, we can heuristically
        // check for the presence of private symbols or capabilities in a benign way.
        // We'll attempt a very limited posix_spawnattr initialization (which is allowed)
        // without spawning a process, and report as "passed" unless other indicators fire.

        // Note: We intentionally do NOT attempt to spawn or use task_for_pid/ptrace here,
        // because these are restricted and/or require entitlements. Using them would
        // either fail at compile time or produce runtime errors.

        #if os(iOS) || os(tvOS) || os(watchOS)
        // On these platforms, calling fork() is unavailable. Treat this indicator as passed
        // unless we have other concrete evidence elsewhere.
        return JBIndicator(
            name: "Restricted APIs (fork)",
            passed: true,
            details: "fork() unavailable on this platform; check skipped"
        )
        #else
        // On other Darwin platforms (e.g., macOS), we still avoid fork() to keep parity.
        // If needed, advanced checks could be added under specific conditions.
        return JBIndicator(
            name: "Restricted APIs (fork)",
            passed: true,
            details: "Check not performed to avoid using restricted APIs"
        )
        #endif
    }
    
    // 5) Loaded dylibs – look for Frida/Substrate/Cydia hooks
    private static func checkInjectedDylibs() -> JBIndicator {
        #if canImport(Darwin)
            var flagged = [String]()
            let suspectKeywords = ["frida", "substrate", "cydia", "libhooker", "tsprotector", "xcon"]
            let count = _dyld_image_count()
            for i in 0..<count {
                if let cName = _dyld_get_image_name(i), let name = String(validatingUTF8: cName) {
                    let lower = name.lowercased()
                    if suspectKeywords.contains(where: { lower.contains($0) }) {
                        flagged.append(name)
                    }
                }
            }
            let bad = !flagged.isEmpty
            return JBIndicator(name: "Injected dylibs", passed: !bad, details: bad ? "Found: \(flagged.joined(separator: ", "))" : "No suspicious dylibs")
        #else
            return JBIndicator(name: "Injected dylibs", passed: true, details: "Darwin not available")
        #endif
    }
    
    // MARK: - Helpers
    private static func isRunningOnSimulator() -> Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }
}
