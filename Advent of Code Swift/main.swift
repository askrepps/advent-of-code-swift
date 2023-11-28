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

let year = "2022"
let day = "01"

let adventRunners: [String: [String: AdventRunner]] = [
    "2022": [
        "01": Advent2022Day01Runner()
    ]
]

guard let inputRootPath = ProcessInfo.processInfo.environment[environmentKeyInputRoot] else {
    print("Environment variable \(environmentKeyInputRoot) not set")
    exit(2)
}

let inputDirectory = URL(fileURLWithPath: inputRootPath).appending(path: year)

guard let runner = adventRunners[year]?[day] else {
    print("Invalid year/day (provided \(year)/\(day))")
    exit(1)
}

print("Running advent \(runner.year) day \(runner.day)")
runner.run(withInputDirectoryURL: inputDirectory)
print()
