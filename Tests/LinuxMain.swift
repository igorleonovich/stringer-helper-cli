//
//  LinuxMain.swift
//  StringerCLI
//
//  Created by Igor Leonovich on 7/10/20.
//  Copyright © 2020 Cr. All rights reserved.
//

import XCTest

import StringerHelperCLITests

var tests = [XCTestCaseEntry]()
tests += StringerHelperCLITests.allTests()
XCTMain(tests)
