#!/usr/bin/env swift
import AppKit
import Foundation

func runCommand(_ command: String, _ args: [String]) -> String? {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: command)
    process.arguments = args
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = FileHandle.nullDevice
    do {
        try process.run()
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    } catch {
        return nil
    }
}

func getTargetPaneId() -> String? {
    if let envPaneId = ProcessInfo.processInfo.environment["HERDR_PANE_ID"], !envPaneId.isEmpty {
        return envPaneId
    }
    guard let output = runCommand("/opt/homebrew/bin/herdr", ["pane", "current"]) else {
        return nil
    }
    if let data = output.data(using: .utf8),
       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
       let result = json["result"] as? [String: Any],
       let pane = result["pane"] as? [String: Any],
       let paneId = pane["pane_id"] as? String {
        return paneId
    }
    return nil
}

func main() {
    let pb = NSPasteboard.general
    let types = pb.types ?? []
    let hasImage = types.contains { $0.rawValue.contains("png") || $0.rawValue.contains("tiff") }
    let hasString = types.contains { $0 == .string || $0.rawValue.contains("utf8-plain-text") }

    let paneId = getTargetPaneId()

    if hasImage, let image = NSImage(pasteboard: pb),
       let tiff = image.tiffRepresentation,
       let rep = NSBitmapImageRep(data: tiff),
       let png = rep.representation(using: .png, properties: [:]) {
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let filePath = "/tmp/agy_clip_\(timestamp).png"
        let url = URL(fileURLWithPath: filePath)
        do {
            try png.write(to: url)
            if let pid = paneId {
                let payload = "\u{001B}[200~@\(filePath) \u{001B}[201~"
                _ = runCommand("/opt/homebrew/bin/herdr", ["pane", "send-text", pid, payload])
            } else {
                print("@\(filePath)")
            }
            exit(0)
        } catch {
            // fall through
        }
    }

    if hasString, let str = pb.string(forType: .string) {
        if let pid = paneId {
            let payload = "\u{001B}[200~" + str + "\u{001B}[201~"
            _ = runCommand("/opt/homebrew/bin/herdr", ["pane", "send-text", pid, payload])
        } else {
            print(str)
        }
        exit(0)
    }
}

main()
