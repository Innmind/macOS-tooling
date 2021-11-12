//
//  Process.swift
//  Innmind
//
//  Created by Baptouuuu on 12/11/2021.
//

import Foundation


final class Shell {
    static func run(_ command: String, callback: @escaping (String) -> Void) {
        let process = Process()
        let output = Pipe()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", command]
        process.currentDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
        process.standardOutput = output
        process.terminationHandler = { [callback, output] process in
            let data = output.fileHandleForReading.readDataToEndOfFile()
            let svg = String(decoding: data, as: UTF8.self)
            callback(svg)
        }

        do {
            try process.run()
        } catch {
            return
        }
    }
}
