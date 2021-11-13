//
//  Process.swift
//  Innmind
//
//  Created by Baptouuuu on 12/11/2021.
//

import Foundation


final class Shell {
    static func run(_ command: String, callback: @escaping (Data) -> Void) {
        let process = Process()
        let output = Pipe()
        let tmpDirectory = NSTemporaryDirectory()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", command]
        process.currentDirectoryURL = URL(fileURLWithPath: tmpDirectory)
        process.standardOutput = output
        process.terminationHandler = { [callback, output, tmpDirectory] process in
            let data = output.fileHandleForReading.readDataToEndOfFile()
            let file = String(decoding: data, as: UTF8.self).trimmingCharacters(in: ["\n"])

            do {
                let svg = try Data(contentsOf: URL(fileURLWithPath: tmpDirectory.appending(file)))
                callback(svg)
            } catch {
                return
            }
        }

        do {
            try process.run()
        } catch {
            return
        }
    }
}
