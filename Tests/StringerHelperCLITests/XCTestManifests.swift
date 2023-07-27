//
//  XCTestManifests.swift
//  StringerHelperCLI
//
//  Created by Igor Leonovich on 7/10/20.
//  Copyright © 2020 Cr. All rights reserved.
//

import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(StringerHelperCLITests.allTests),
    ]
}
#endif
