//
//  CLIColor.swift
//  StringerHelperCLI
//
//  Created by Igor Leonovich on 11/11/22.
//  Copyright © 2022. All rights reserved.
//

import Foundation

enum CLIColor: String {
    
    case clear = "\u{001B}[;m"
    case red = "\u{001B}[0;31m"
    case green = "\u{001B}[0;42m"
    case purple = "\u{001B}[0;35m"
    case lightBlueBackground = "\u{001B}[0;104m"
}
