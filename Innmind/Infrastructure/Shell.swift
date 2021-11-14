//
//  Process.swift
//  Innmind
//
//  Created by Baptouuuu on 12/11/2021.
//

import Foundation


final class Shell {
    static func run(_ command: String, callback: @escaping (String, Data) -> Void) {
        let process = Process()
        let output = Pipe()
        let tmpDirectory = NSTemporaryDirectory()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", command]
        process.currentDirectoryURL = URL(fileURLWithPath: tmpDirectory)
        process.standardOutput = output
        process.terminationHandler = { [callback, output, tmpDirectory] process in
            let data = output.fileHandleForReading.readDataToEndOfFile()

            callback(tmpDirectory, data)
        }

        do {
            try process.run()
        } catch {
            return
        }
    }
}
