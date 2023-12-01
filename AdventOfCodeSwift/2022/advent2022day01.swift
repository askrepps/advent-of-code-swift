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

private func convertToCalorieSums(_ data: String) -> [Int] {
    data.split(separator: "\n\n").map { group in
        group.split(separator: "\n")
            .compactMap { line in Int(line) }
            .reduce(0, +)
    }
}

private func getPart1Answer(_ calorieSums: [Int]) -> Int {
    return calorieSums.max() ?? -1
}

private func getPart2Answer(_ calorieSums: [Int]) -> Int {
    let sortedSumsDescending = calorieSums.sorted { $0 > $1 }
    return sortedSumsDescending[0..<3].reduce(0, +)
}

class Advent2022Day01Runner: AdventRunner {
    var year = "2022"
    var day = "01"
    
    func run(withInputDirectoryURL inputURL: URL) throws {
        let data = try getInputText(fromFileNamed: self.inputFilename, inDirectoryURL: inputURL)
        let calorieSums = convertToCalorieSums(data)
        print("The answer to part 1 is \(getPart1Answer(calorieSums))")
        print("The answer to part 2 is \(getPart2Answer(calorieSums))")
    }
}
