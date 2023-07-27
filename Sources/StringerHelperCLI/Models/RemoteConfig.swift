//
//  RemoteConfig.swift
//  StringerCLI
//
//  Created by Igor Leonovich on 11/11/22.
//  Copyright © 2022. All rights reserved.
//

import Foundation

struct RemoteConfig: Codable {
    
    let conditions: [Condition]?
    var parameterGroups: [String: ParameterGroup]?
    let parameters: [String: Parameter]?
    
    var allParameters: [String: Parameter] {
        // TODO: Add parameters
        var result = [String: Parameter]()
        parameterGroups?.values.forEach { parameterGroup in
            parameterGroup.parameters.forEach { (key: String, value: Parameter) in
                result[key] = value
            }
        }
        if let parameters = parameters {
            result.merge(parameters) { (current,_) in current }
            // TODO: Sorting: Alphabetically
        }
        return result
    }
    
    var parametersToTranslate: [String: Parameter] {
        return allParameters.filter { parameter in
            return RemoteConfig.keysToTranslate.contains(parameter.key)
        }
    }
    
    static var languages: [String: String] {
        return ["ar" : "ar", "ch-si": "zh-Hans", "ch-tr": "zh-Hant", "fr": "fr", "de": "de", "hi": "hi", "id": "id", "it": "it", "ja": "ja", "ko": "ko", "no": "nb", "pl": "pl", "pt": "pt-PT", "ro": "ro", "ru": "ru", "es": "es", "sw": "sv", "th": "th", "tr": "tr", "uk": "uk", "vi": "vi"]
    }

    static var keysToTranslate: [String] {
        return ["priceDescriptionLabelText",
                "startButtonText",
                "subtitleLabelText",
                "titleLabelText",
                "paywallTitleText"
        ]
    }
}

struct Condition: Codable {
    let name: String
    let expression: String
    let tagColor: String
}

struct ParameterGroup: Codable {
    var parameters: [String: Parameter]
}

struct Parameter: Codable {
    let defaultValue: DefaultValue
    var conditionalValues: [String: ConditionalValue]?
    let description: String?
    let valueType: String?
}

struct DefaultValue: Codable {
    let value: String
}

struct ConditionalValue: Codable {
    let value: String
}
