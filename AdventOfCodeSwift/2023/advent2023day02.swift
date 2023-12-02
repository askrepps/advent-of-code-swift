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

private struct Game {
    let id: Int
    let maxRedCubes: Int
    let maxGreenCubes: Int
    let maxBlueCubes: Int
}

private func parseGame(from line: String) throws -> Game {
    let mainComponents = line.components(separatedBy: ": ")
    let idComponent = mainComponents[0].components(separatedBy: " ")[1]
    guard let id = Int(idComponent) else {
        throw AdventError.invalidData("Invalid game id: \(idComponent)")
    }
    let roundComponents = mainComponents[1].components(separatedBy: "; ")
    
    var maxRed = 0
    var maxGreen = 0
    var maxBlue = 0
    for round in roundComponents {
        let pullComponents = round.components(separatedBy: ", ")
        for pull in pullComponents {
            let valueComponents = pull.components(separatedBy: " ")
            let color = valueComponents[1]
            let value = Int(valueComponents[0]) ?? 0
            switch color {
            case "red":
                maxRed = max(maxRed, value)
            case "green":
                maxGreen = max(maxGreen, value)
            case "blue":
                maxBlue = max(maxBlue, value)
            default:
                throw AdventError.invalidData("Unrecognized color: \(color)")
            }
        }
    }
    return Game(id: id, maxRedCubes: maxRed, maxGreenCubes: maxGreen, maxBlueCubes: maxBlue)
}

private func getPart1Answer(_ games: [Game]) -> Int {
    return games.filter { $0.maxRedCubes <= 12 && $0.maxGreenCubes <= 13 && $0.maxBlueCubes <= 14 }
        .reduce(0) { (total, game) in total + game.id }
}

private func getPart2Answer(_ games: [Game]) -> Int {
    return games.reduce(0) { (total, game) in
        total + game.maxRedCubes * game.maxGreenCubes * game.maxBlueCubes
    }
}

class Advent2023Day02Runner: AdventRunner {
    var year = "2023"
    var day = "02"
    
    func run(withInputDirectoryURL inputURL: URL) throws {
        let games = try getInputLines(fromFileNamed: self.inputFilename, inDirectoryURL: inputURL)
            .map { try parseGame(from: $0) }
        print("The answer to part 1 is \(getPart1Answer(games))")
        print("The answer to part 2 is \(getPart2Answer(games))")
    }
}
