//
//  FirebaseConfig.swift
//  StringerCLI
//
//  Created by Igor Leonovich on 16/11/22.
//  Copyright © 2022. All rights reserved.
//

import Foundation

struct FirebaseConfig: Codable {
    
    let remoteConfig: FirebaseConfig.RemoteConfig
    
    struct RemoteConfig: Codable {
        let template: String
    }
    
    enum CodingKeys: String, CodingKey {
        case remoteConfig = "remoteconfig"
    }
}
