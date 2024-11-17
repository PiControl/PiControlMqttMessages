//
//  protoc.swift
//  pi_control_coordinator
//
//  Created by Thomas Bonk on 05.11.24.
//  Copyright 2024 Thomas Bonk
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import PackagePlugin

@main
struct protoc: BuildToolPlugin {
    
    // MARK: - BuildToolPlugin
    func createBuildCommands(context: PackagePlugin.PluginContext, target: any PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
        let protoPath = target.directory.appending("protobuf")
        let outputDirectory = context.pluginWorkDirectoryURL
        
        return [
            .prebuildCommand(
                displayName: "protobuf-compiler",
                executable: compilerPath(from: context),
                arguments: merge(
                    [
                        "--proto_path=\(protoPath.string)",
                        "--swift_opt=Visibility=Public",
                        "--swift_out=\(outputDirectory.path)",
                    ],
                    protobufFiles(target.directory.appending("protobuf"))
                ),
                environment: [:],
                outputFilesDirectory: outputDirectory
            )
        ]
    }
    

    // MARK: - Private Methods
    
    private func compilerPath(from context: PackagePlugin.PluginContext) -> URL {
        let scriptPath = context.package.directoryURL
            .appending(component: "Plugins")
            .appending(component: "protoc")
            .appending(component: "Resources")
            .appending(component: "protobuf-compiler.sh")
        
        return scriptPath
    }
    
    private func merge(_ arrays: [String]...) -> [String] {
        return arrays.flatMap { $0 }
    }
    
    private func protobufFiles(_ path: Path) -> [String] {
        guard
            let protobufFiles = try? FileManager.default.contentsOfDirectory(atPath: path.string)
        else {
            return []
        }
        
        return protobufFiles
            .filter { $0.hasSuffix(".proto") }
            .map { path.appending(subpath: $0) }
            .map { $0.string }
    }
    
}
