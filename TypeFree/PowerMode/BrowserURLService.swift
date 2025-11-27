import AppKit
import Foundation
import os

enum BrowserType {
    case safari
    case arc
    case chrome
    case edge
    case firefox
    case brave
    case opera
    case vivaldi
    case orion
    case zen
    case yandex

    var scriptName: String {
        switch self {
        case .safari: "safariURL"
        case .arc: "arcURL"
        case .chrome: "chromeURL"
        case .edge: "edgeURL"
        case .firefox: "firefoxURL"
        case .brave: "braveURL"
        case .opera: "operaURL"
        case .vivaldi: "vivaldiURL"
        case .orion: "orionURL"
        case .zen: "zenURL"
        case .yandex: "yandexURL"
        }
    }

    var bundleIdentifier: String {
        switch self {
        case .safari: "com.apple.Safari"
        case .arc: "company.thebrowser.Browser"
        case .chrome: "com.google.Chrome"
        case .edge: "com.microsoft.edgemac"
        case .firefox: "org.mozilla.firefox"
        case .brave: "com.brave.Browser"
        case .opera: "com.operasoftware.Opera"
        case .vivaldi: "com.vivaldi.Vivaldi"
        case .orion: "com.kagi.kagimacOS"
        case .zen: "app.zen-browser.zen"
        case .yandex: "ru.yandex.desktop.yandex-browser"
        }
    }

    var displayName: String {
        switch self {
        case .safari: "Safari"
        case .arc: "Arc"
        case .chrome: "Google Chrome"
        case .edge: "Microsoft Edge"
        case .firefox: "Firefox"
        case .brave: "Brave"
        case .opera: "Opera"
        case .vivaldi: "Vivaldi"
        case .orion: "Orion"
        case .zen: "Zen Browser"
        case .yandex: "Yandex Browser"
        }
    }

    static var allCases: [BrowserType] {
        [.safari, .arc, .chrome, .edge, .brave, .opera, .vivaldi, .orion, .yandex]
    }

    static var installedBrowsers: [BrowserType] {
        allCases.filter { browser in
            let workspace = NSWorkspace.shared
            return workspace.urlForApplication(withBundleIdentifier: browser.bundleIdentifier) != nil
        }
    }
}

enum BrowserURLError: Error {
    case scriptNotFound
    case executionFailed
    case browserNotRunning
    case noActiveWindow
    case noActiveTab
}

class BrowserURLService {
    static let shared = BrowserURLService()

    private let logger = Logger(
        subsystem: "dev.zhangyu.typefree",
        category: "browser.applescript"
    )

    private init() {}

    func getCurrentURL(from browser: BrowserType) async throws -> String {
        guard let scriptURL = Bundle.main.url(forResource: browser.scriptName, withExtension: "scpt") else {
            logger.error("❌ AppleScript file not found: \(browser.scriptName).scpt")
            throw BrowserURLError.scriptNotFound
        }

        logger.debug("🔍 Attempting to execute AppleScript for \(browser.displayName)")

        // Check if browser is running
        if !isRunning(browser) {
            logger.error("❌ Browser not running: \(browser.displayName)")
            throw BrowserURLError.browserNotRunning
        }

        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = [scriptURL.path]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        do {
            logger.debug("▶️ Executing AppleScript for \(browser.displayName)")
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                if output.isEmpty {
                    logger.error("❌ Empty output from AppleScript for \(browser.displayName)")
                    throw BrowserURLError.noActiveTab
                }

                // Check if output contains error messages
                if output.lowercased().contains("error") {
                    logger.error("❌ AppleScript error for \(browser.displayName): \(output)")
                    throw BrowserURLError.executionFailed
                }

                logger.debug("✅ Successfully retrieved URL from \(browser.displayName): \(output)")
                return output
            } else {
                logger.error("❌ Failed to decode output from AppleScript for \(browser.displayName)")
                throw BrowserURLError.executionFailed
            }
        } catch {
            logger.error("❌ AppleScript execution failed for \(browser.displayName): \(error.localizedDescription)")
            throw BrowserURLError.executionFailed
        }
    }

    func isRunning(_ browser: BrowserType) -> Bool {
        let workspace = NSWorkspace.shared
        let runningApps = workspace.runningApplications
        let isRunning = runningApps.contains { $0.bundleIdentifier == browser.bundleIdentifier }
        logger.debug("\(browser.displayName) running status: \(isRunning)")
        return isRunning
    }
}
