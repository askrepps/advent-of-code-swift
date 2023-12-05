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

import Collections
import Foundation

private struct Card {
    let id: Int
    let winningNumbers: Set<Int>
    let scratchedNumbers: Set<Int>
    
    let numWinningNumbers: Int
    
    init(id: Int, winningNumbers: Set<Int>, scratchedNumbers: Set<Int>) {
        self.id = id
        self.winningNumbers = winningNumbers
        self.scratchedNumbers = scratchedNumbers
        self.numWinningNumbers = winningNumbers.intersection(scratchedNumbers).count
    }
}

private func parseCard(from line: String) throws -> Card {
    let mainComponents = line.components(separatedBy: ": ")
    let idComponent = mainComponents[0]
    guard let idStart = idComponent.firstIndex(where: { $0.isNumber }) else {
        throw AdventError.invalidData("No card ID found")
    }
    let id = Int(idComponent[idStart...]) ?? -1
    let numberComponents = mainComponents[1].components(separatedBy: " | ")
    let winningNumbers = Set(numberComponents[0].components(separatedBy: " ").compactMap { Int($0) })
    let scratchedNumbers = Set(numberComponents[1].components(separatedBy: " ").compactMap { Int($0) })
    return Card(id: id, winningNumbers: winningNumbers, scratchedNumbers: scratchedNumbers)
}

private func playScratchCardGame(with cardsById: [Int: Card]) -> UInt64 {
    var idQueue = Deque<Int>(cardsById.keys)
    var count = UInt64(cardsById.count)
    while let nextId = idQueue.popFirst() {
        if let card = cardsById[nextId] {
            if card.numWinningNumbers > 0 {
                for offset in 1...card.numWinningNumbers {
                    idQueue.append(card.id + offset)
                    count += 1
                }
            }
        }
    }
    return count
}

private func getPart1Answer(_ lines: [String]) throws -> UInt64 {
    return try lines.map { line in
        let card = try parseCard(from: line)
        return switch card.numWinningNumbers {
        case 0:
            UInt64(0)
        default:
            UInt64(1) << (card.numWinningNumbers - 1)
        }
    }.reduce(UInt64(0), +)
}

private func getPart2Answer(_ lines: [String]) throws -> UInt64 {
    let cards = try lines.map { try parseCard(from: $0) }
    let cardsById = cards.reduce(into: [Int: Card]()) { (dict, card) in dict[card.id] = card }
    return playScratchCardGame(with: cardsById)
}

class Advent2023Day04Runner: AdventRunner {
    let year = "2023"
    let day = "04"
    
    func run(withInputDirectoryURL inputURL: URL) throws {
        let lines = try getInputLines(fromFileNamed: inputFilename, inDirectoryURL: inputURL)
        print("The answer to part 1 is \(try getPart1Answer(lines))")
        print("The answer to part 2 is \(try getPart2Answer(lines))")
    }
}
