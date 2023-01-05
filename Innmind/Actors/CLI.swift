//
//  CLI.swift
//  Innmind
//
//  Created by Baptouuuu on 05/01/2023.
//

import Foundation

final class CLI {
    actor DependencyGraph {

        static let shared = DependencyGraph()

        private let command = "export PATH=\"/Users/$(whoami)/.composer/vendor/bin:/usr/local/sbin:/usr/local/bin:/opt/homebrew/bin:$PATH\" && dependency-graph "

        func vendor(_ organization: String) -> Data? {
            return run(command+" vendor \(organization) --output")
        }

        func of(_ organization: String, _ package: String) -> Data? {
            return run(command+" of \(organization)/\(package) --output")
        }

        func dependsOn(_ organization: String, _ package: String) -> Data? {
            return run(command+" depends-on \(organization)/\(package) --output")
        }

        private func run(_ command: String) -> Data? {
            let process = Process()
            let output = Pipe()
            process.executableURL = URL(fileURLWithPath: "/bin/zsh")
            process.arguments = ["-c", command]
            process.standardOutput = output

            do {
                try process.run()

                return output.fileHandleForReading.readDataToEndOfFile()
            } catch {
                return nil
            }
        }
    }
}
