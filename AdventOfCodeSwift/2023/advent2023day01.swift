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

// include first and last letter of the word in case there are adjacent overlapping number words
private let wordReplacements = [
    "one": "o1e",
    "two": "t2o",
    "three": "t3e",
    "four": "f4r",
    "five": "f5e",
    "six": "s6x",
    "seven": "s7n",
    "eight": "e8t",
    "nine": "n9e"
]

private func getCalibrationValues(fromLines lines: [String]) throws -> [Int] {
    return try lines.map {
        let digits = $0.compactMap { Int(String($0)) }
        guard !digits.isEmpty else {
            throw AdventError.invalidData("Line contained no digits: \($0)")
        }
        return 10 * digits[0] + digits[digits.count - 1]
    }
}

private func convertDigitWords(inLines lines: [String]) -> [String] {
    return lines.map {
        var line = $0
        for (word, replacement) in wordReplacements {
            line = line.replacingOccurrences(of: word, with: replacement)
        }
        return line
    }
}

private func getPart1Answer(_ lines: [String]) throws -> Int {
    return try getCalibrationValues(fromLines: lines).reduce(0, +)
}

private func getPart2Answer(_ lines: [String]) throws -> Int {
    let convertedLines = convertDigitWords(inLines: lines)
    return try getCalibrationValues(fromLines: convertedLines).reduce(0, +)
}

class Advent2023Day01Runner: AdventRunner {
    var year = "2023"
    var day = "01"
    
    func run(withInputDirectoryURL inputURL: URL) throws {
        let lines = try getInputLines(fromFileNamed: self.inputFilename, inDirectoryURL: inputURL)
        print("The answer to part 1 is \(try getPart1Answer(lines))")
        print("The answer to part 2 is \(try getPart2Answer(lines))")
    }
}
