//
//  StringerHelper.swift
//  StringerHelperCLI
//
//  Created by Igor Leonovich on 11/11/22.
//  Copyright © 2022. All rights reserved.
//

import ArgumentParser
import Foundation

struct StringerHelper: ParsableCommand {

    static var configuration = CommandConfiguration(abstract: "A Stringer Helper utility.",
                                                    version: "0.1.0",
                                                    subcommands: [Translate.self, Publish.self, GenerateSwift.self, Cleanup.self])
}

extension StringerHelper {

    struct Translate: ParsableCommand {
        
        static var configuration = CommandConfiguration(abstract: "Translate strings")
        static var remoteConfig: RemoteConfig!
        static let firebaseConfigJsonFileName = "firebase.json"
        static let firebaseConfigJsonUrlString = Constants.stringerProjectURLString + firebaseConfigJsonFileName
        static let stringsToTranslateFileName = "stringsToTranslate.json"
        static let remoteConfigJsonFileName = "remoteconfig.last.json"
        static let remoteConfigJsonURLString = Constants.stringerProjectURLString + remoteConfigJsonFileName
        static let remoteConfigToPublishJsonFileName = "remoteconfig.topublish.json"
        static let remoteConfigToPublishJsonURLString = Constants.stringerProjectURLString + remoteConfigToPublishJsonFileName
        static let stringsToTranslateJsonUrlString = Constants.stringerProjectURLString + stringsToTranslateFileName
        
        func run() throws {
            cli.print("Translating strings...", to: .highlightedPurple)
            
            let firebaseConfig = FirebaseConfig(remoteConfig: FirebaseConfig.RemoteConfig(template: Translate.remoteConfigJsonFileName))
            if let data = try? JSONEncoder().encode(firebaseConfig) {
                FileManager.default.createFile(atPath: Translate.firebaseConfigJsonUrlString, contents: data, attributes: nil)
            }
            
            Translate.getRemoteConfig()
            let allParameters = Translate.remoteConfig.allParameters
            let parametersToTranslate = allParameters.filter { fullParameter in
                return RemoteConfig.keysToTranslate.contains(fullParameter.key)
            }.map({ [$0.key: $0.value.defaultValue.value] })
            print("[PARAMETERS TO TRANSLATE]\n\(parametersToTranslate)")
            let jsonData = try JSONEncoder().encode(parametersToTranslate)
            FileManager.default.createFile(atPath: Translate.stringsToTranslateJsonUrlString, contents: jsonData, attributes: nil)
        }
        
        static func getRemoteConfig() {
            if Translate.remoteConfig == nil {
                if let data = try? Data(contentsOf: URL(fileURLWithPath: Translate.remoteConfigJsonURLString)) {
                    Translate.remoteConfig = try? JSONDecoder().decode(RemoteConfig.self, from: data)
                }
            }
        }
    }
    
    struct Publish: ParsableCommand {
        
        static var configuration = CommandConfiguration(abstract: "Publish remote config")
        
        func run() throws {
            cli.print("Applying translated strings to remote config json file...", to: .highlightedPurple)
            Translate.getRemoteConfig()
            var outputRemoteConfig = Translate.remoteConfig!
            Translate.remoteConfig.parameterGroups?.forEach { parameterGroup in
                parameterGroup.value.parameters.enumerated().forEach { index, fullParameter in
                    if RemoteConfig.keysToTranslate.contains(fullParameter.key) {
                        var conditionalValues = [String: ConditionalValue]()
                        RemoteConfig.languages.forEach({ language in
                            let dirPath = Constants.stringerProjectURLString + language.key
                            let filePath = dirPath + "/" + Translate.stringsToTranslateFileName
                            if let data = FileManager.default.contents(atPath: filePath) {
                                if let objects = try? JSONDecoder().decode([[String: String]].self, from: data) {
                                    if let object = objects.first(where: {$0.first!.key == fullParameter.key }) {
                                        let conditionalValue = ConditionalValue(value: object.values.first!)
                                        conditionalValues[language.key] = conditionalValue
                                    }
                                }
                            }
                        })
                        outputRemoteConfig.parameterGroups?[parameterGroup.key]?.parameters[fullParameter.key]?.conditionalValues = conditionalValues
                    }
                }
            }
            let jsonData = try JSONEncoder().encode(outputRemoteConfig)
            let url = Translate.remoteConfigToPublishJsonURLString
            FileManager.default.createFile(atPath: url, contents: jsonData, attributes: nil)
            
            let firebaseConfig = FirebaseConfig(remoteConfig: FirebaseConfig.RemoteConfig(template: Translate.remoteConfigToPublishJsonFileName))
            if let data = try? JSONEncoder().encode(firebaseConfig) {
                FileManager.default.createFile(atPath: Translate.firebaseConfigJsonUrlString, contents: data, attributes: nil)
            }
        }
    }
    
    struct GenerateSwift: ParsableCommand {
        
        static var configuration = CommandConfiguration(abstract: "Generate swift file")
        
        func run() throws {
            cli.print("Generating swift file...")
            var file = ""
            file += """
            import FirebaseRemoteConfig
            
            struct RemoteSettings: Decodable {
                
                private enum Keys: String {
            
            """
            Translate.getRemoteConfig()
            Translate.remoteConfig.allParameters.forEach { (key: String, value: Parameter) in
                file += "\t\tcase \(key)\n"
            }
            file += "\t}\n"
            Translate.remoteConfig.allParameters.forEach { (key: String, value: Parameter) in
                var valueType = ""
                var defaultValue = "\"\""
                switch value.valueType {
                case "STRING":
                    valueType = "String"
                    defaultValue = "\"\""
                case "NUMBER":
                    if value.defaultValue.value.contains(".") {
                        valueType = "Float"
                    } else {
                        valueType = "Int"
                    }
                    defaultValue = "0"
                case "BOOLEAN":
                    valueType = "Bool"
                    defaultValue = "false"
                default: break
                }
                file += "\n\tvar \(key): \(valueType) = \(defaultValue)"
            }
            file += "\n\n\tinit(with config: RemoteConfig) {\n"
            Translate.remoteConfig.allParameters.forEach { (key: String, value: Parameter) in
                file += "\n\n"
                switch value.valueType {
                case "STRING":
                    file += "\t\tif let \(key) = config.configValue(forKey: Keys.\(key).rawValue).stringValue {\n"
                    file += "\t\t\tself.\(key) = \(key)"
                    file += "\n\t\t}"
                case "NUMBER":
                    if value.defaultValue.value.contains(".") {
                        file += "\t\t\(key) = config.configValue(forKey: Keys.\(key).rawValue).numberValue.floatValue"
                    } else {
                        file += "\t\t\(key) = config.configValue(forKey: Keys.\(key).rawValue).numberValue.intValue"
                    }
                case "BOOLEAN":
                    file += "\t\t\(key) = config.configValue(forKey: Keys.\(key).rawValue).boolValue"
                default: break
                }
            }
            file += "\n\t}\n}"
            
            let url = URL(fileURLWithPath: Constants.remoteSettingsSwiftFileURLString)
            try? file.write(to: url, atomically: true, encoding: .utf8)
        }
    }
    
    struct Cleanup: ParsableCommand {
        
        static var configuration = CommandConfiguration(abstract: "Clean up")
        
        func run() throws {
            cli.print("Cleaning up...")
            RemoteConfig.languages.forEach { language in
                try? FileManager.default.removeItem(atPath: Constants.stringerProjectURLString + language.key)
            }
        }
    }
}
