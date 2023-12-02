// MIT License
//
// Copyright (c) 2023 Andrew Krepps
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

let adventRunners: [String: [String: AdventRunner]] = [
    "2022": [
        "01": Advent2022Day01Runner(),
        "02": Advent2022Day02Runner()
    ],
    "2023": [
        "01": Advent2023Day01Runner(),
        "02": Advent2023Day02Runner()
    ]
]

func getInputDirectoryURL(forYear year: String) throws -> URL {
    guard let inputRootPath = ProcessInfo.processInfo.environment[environmentKeyInputRoot] else {
        throw AdventError.environmentError("Environment variable \(environmentKeyInputRoot) not set")
    }
    return URL(fileURLWithPath: inputRootPath).appending(path: year)
}

func run(forYear year: String, andDay day: String, withInputDirectory inputDirectory: URL) throws {
    guard let runner = adventRunners[year]?[day] else {
        throw AdventError.invalidArguments("Invalid year/day (\(year)/\(day))")
    }
    print("Running advent \(runner.year) day \(runner.day)")
    let elapsedTime = ContinuousClock().measure {
        do {
            try runner.run(withInputDirectoryURL: inputDirectory)
        } catch AdventError.invalidData(let message) {
            print("Invalid input error: \(message)")
        } catch AdventError.invalidState(let message) {
            print("Invalid state error: \(message)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    print("Elapsed time: \(elapsedTime)\n")
}

do {
    guard CommandLine.arguments.count >= 3 else {
        throw AdventError.invalidArguments("Arguments for year and day not provided")
    }
    let year = CommandLine.arguments[1]
    guard let dayNumber = Int(CommandLine.arguments[2]) else {
        throw AdventError.invalidArguments("Day argument must be a valid number")
    }
    let day = String(format: "%02d", dayNumber)
    
    let inputDirectory = try getInputDirectoryURL(forYear: year)
    try run(forYear: year, andDay: day, withInputDirectory: inputDirectory)
} catch AdventError.environmentError(let message) {
    print("Environment error: \(message)")
    exit(1)
} catch AdventError.invalidArguments(let message) {
    print("Usage error: \(message)")
    exit(2)
}
