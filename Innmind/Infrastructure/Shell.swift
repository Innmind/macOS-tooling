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
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", command]
        process.standardOutput = output
        process.terminationHandler = { [callback, output] process in
            let data = output.fileHandleForReading.readDataToEndOfFile()

            callback(data)
        }

        do {
            try process.run()
        } catch {
            return
        }
    }
}
