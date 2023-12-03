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

private struct GridCoordinates: Hashable {
    let row: Int
    let column: Int
}

private struct GridNumber {
    let row: Int
    let startColumn: Int
    let endColumn: Int
    let value: UInt64
    
    let surroundingCoordinates: Set<GridCoordinates>
    
    init(row: Int, startColumn: Int, endColumn: Int, value: UInt64) {
        self.row = row
        self.startColumn = startColumn
        self.endColumn = endColumn
        self.value = value
        self.surroundingCoordinates =
            calculateSurroundingCoordinates(row: row, startColumn: startColumn, endColumn: endColumn)
    }
}

private struct GridSymbol {
    let coordinates: GridCoordinates
    let value: Character
}

private func calculateSurroundingCoordinates(row: Int, startColumn: Int, endColumn: Int) -> Set<GridCoordinates> {
    var coordinates = Set<GridCoordinates>()
    for column in (startColumn - 1)...(endColumn + 1) {
        coordinates.insert(GridCoordinates(row: row - 1, column: column))
        coordinates.insert(GridCoordinates(row: row + 1, column: column))
    }
    coordinates.insert(GridCoordinates(row: row, column: startColumn - 1))
    coordinates.insert(GridCoordinates(row: row, column: endColumn + 1))
    return coordinates
}

private func parseGridNumbers(_ lines: [String]) throws -> [GridNumber] {
    var numbers: [GridNumber] = []
    var accumulator: UInt64? = nil
    var startColumn: Int? = nil
    
    func finalizeAccumulatedNumber(row: Int, endColumn: Int) throws {
        guard accumulator != nil else {
            throw AdventError.invalidState("No value accumulated")
        }
        guard startColumn != nil else {
            throw AdventError.invalidState("Accumulated value with missing start column")
        }
        numbers.append(GridNumber(row: row, startColumn: startColumn!, endColumn: endColumn, value: accumulator!))
        accumulator = nil
        startColumn = nil
    }
    
    for (currentRow, line) in lines.enumerated() {
        for (currentColumn, token) in line.enumerated() {
            if token.isNumber {
                startColumn = startColumn ?? currentColumn
                accumulator = 10 * (accumulator ?? 0) + UInt64(token.wholeNumberValue ?? 0)
            } else if accumulator != nil {
                try finalizeAccumulatedNumber(row: currentRow, endColumn: currentColumn - 1)
            }
        }
        if accumulator != nil {
            try finalizeAccumulatedNumber(row: currentRow, endColumn: line.count - 1)
        }
    }
    return numbers
}

private func parseGridSymbols(_ lines: [String]) -> [GridSymbol] {
    return lines.enumerated().flatMap { (row, line) in
        line.enumerated().compactMap { (column, token) in
            if token != "." && !token.isNumber {
                GridSymbol(coordinates: GridCoordinates(row: row, column: column), value: token)
            } else {
                nil
            }
        }
    }
}

private func getPart1Answer(_ numbers: [GridNumber], _ symbols: [GridSymbol]) -> UInt64 {
    let symbolCoordinates = Set(symbols.map { $0.coordinates })
    return numbers.filter {
        !$0.surroundingCoordinates.intersection(symbolCoordinates).isEmpty
    }.reduce(0) { (total, number) in
        total + number.value
    }
}

private func getPart2Answer(_ numbers: [GridNumber], _ symbols: [GridSymbol]) -> UInt64 {
    return symbols.filter { $0.value == "*" }
        .map { gear in numbers.filter { $0.surroundingCoordinates.contains(gear.coordinates) } }
        .filter { $0.count == 2 }
        .reduce(0) { (total, numbers) in
            total + numbers[0].value * numbers[1].value
        }
}

class Advent2023Day03Runner: AdventRunner {
    let year = "2023"
    let day = "03"
    
    func run(withInputDirectoryURL inputURL: URL) throws {
        let lines = try getInputLines(fromFileNamed: self.inputFilename, inDirectoryURL: inputURL)
        let numbers = try parseGridNumbers(lines)
        let symbols = parseGridSymbols(lines)
        print("The answer to part 1 is \(getPart1Answer(numbers, symbols))")
        print("The answer to part 2 is \(getPart2Answer(numbers, symbols))")
    }
}
