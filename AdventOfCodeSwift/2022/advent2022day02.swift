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

private let rockScore = 1
private let paperScore = 2
private let scissorsScore = 3

private let winScore = 6
private let drawScore = 3
private let loseScore = 0

private enum Move {
    case rock
    case paper
    case scissors
}

private enum Outcome {
    case win
    case lose
    case draw
}

private func getWinner(against loser: Move) -> Move {
    return switch loser {
    case .rock:
        .paper
    case .paper:
        .scissors
    case .scissors:
        .rock
    }
}

private func getLoser(against winner: Move) -> Move {
    return switch winner {
    case .rock:
        .scissors
    case .paper:
        .rock
    case .scissors:
        .paper
    }
}

private func getOutcome(forMove move: Move, against opponent: Move) throws -> Outcome {
    return switch move {
    case opponent:
        .draw
    case getWinner(against: opponent):
        .win
    case getLoser(against: opponent):
        .lose
    default:
        throw AdventError.invalidState("Could not determine outcome of \(move) vs. \(opponent)")
    }
}

private func getScore(forMove move: Move) -> Int {
    return switch move {
    case .rock:
        rockScore
    case .paper:
        paperScore
    case .scissors:
        scissorsScore
    }
}

private func getScore(forOutcome outcome: Outcome) -> Int {
    return switch outcome {
    case .win:
        winScore
    case .draw:
        drawScore
    case .lose:
        loseScore
    }
}

private func getScore(forMove move: Move, against opponent: Move) throws -> Int {
    let outcome = try getOutcome(forMove: move, against: opponent)
    return getScore(forMove: move) + getScore(forOutcome: outcome)
}

private func getCounterMove(against opponent: Move, forOutcome outcome: Outcome) -> Move {
    return switch outcome {
    case .win:
        getWinner(against: opponent)
    case .lose:
        getLoser(against: opponent)
    case .draw:
        opponent
    }
}

private func parseMove(fromCode code: String) throws -> Move {
    return switch code {
    case "A", "X":
        .rock
    case "B", "Y":
        .paper
    case "C", "Z":
        .scissors
    default:
        throw AdventError.invalidData("Unrecognized move code: \(code)")
    }
}

private func parseOutcome(fromCode code: String) throws -> Outcome {
    return switch code {
    case "X":
        .lose
    case "Y":
        .draw
    case "Z":
        .win
    default:
        throw AdventError.invalidData("Unrecognized outcome code: \(code)")
    }
}

private func playGame(withLines lines: [String], _ myStrategy: (Move, String) throws -> Move) throws -> Int {
    return try lines.reduce(0) { (totalScore, line) in
        let tokens = line.components(separatedBy: " ")
        let opponentMove = try parseMove(fromCode: tokens[0])
        let myMove = try myStrategy(opponentMove, tokens[1])
        let newScore = try getScore(forMove: myMove, against: opponentMove)
        return totalScore + newScore
    }
}

private func getPart1Answer(withLines lines: [String]) throws -> Int {
    return try playGame(withLines: lines) { (_, myCode) in
        return try parseMove(fromCode: myCode)
    }
}

private func getPart2Answer(withLines lines: [String]) throws -> Int {
    return try playGame(withLines: lines) { (opponentMove, myCode) in
        let outcome = try parseOutcome(fromCode: myCode)
        return getCounterMove(against: opponentMove, forOutcome: outcome)
    }
}

class Advent2022Day02Runner: AdventRunner {
    var year = "2022"
    var day = "02"
    
    func run(withInputDirectoryURL inputURL: URL) throws {
        let lines = try getInputLines(fromFileNamed: self.inputFilename, inDirectoryURL: inputURL)
        print("The answer to part 1 is \(try getPart1Answer(withLines: lines))")
        print("The answer to part 2 is \(try getPart2Answer(withLines: lines))")
    }
}
