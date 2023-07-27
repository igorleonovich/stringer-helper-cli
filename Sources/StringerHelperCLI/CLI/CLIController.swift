//
//  CLIController.swift
//  StringerHelperCLI
//
//  Created by Igor Leonovich on 11/11/22.
//  Copyright © 2022. All rights reserved.
//

import Foundation

class CLIController {
    
    func print(_ message: String, to: OutputType = .standardPale) {
        switch to {
        case .standardPale:
            fputs("\(message)\n", stdout)
        case .highlightedGreen:
            fputs("\(CLIColor.green.rawValue)\(message)\(CLIColor.clear.rawValue)\n", stdout)
        case .highlightedPurple:
            fputs("\(CLIColor.purple.rawValue)\(message)\(CLIColor.clear.rawValue)\n", stdout)
        case .highlightedLightBlueBG:
            fputs("\(CLIColor.lightBlueBackground.rawValue)\(message)\(CLIColor.clear.rawValue)\n", stdout)
        case .errorRed:
            fputs("\(CLIColor.red.rawValue)\(message)\(CLIColor.clear.rawValue)\n", stderr)
        }
    }
    
//    func getInput() -> String? {
//        let keyboard = FileHandle.standardInput
//        let inputData = keyboard.availableData
//        let stringData = String(data: inputData, encoding: String.Encoding.utf8)?.trimmingCharacters(in: CharacterSet.newlines)
//        return stringData
//    }
}

enum OutputType {
    
    case standardPale
    case highlightedGreen
    case highlightedPurple
    case highlightedLightBlueBG
    case errorRed
}
