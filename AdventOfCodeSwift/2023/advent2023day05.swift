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

private struct Almanac {
    let seeds: [UInt64]
    let mapsBySource: [String: AlmanacMap]
    let mapsByDestination: [String: AlmanacMap]
}

private struct AlmanacMap {
    let sourceType: String
    let destinationType: String
    let entries: [AlmanacMapEntry]
}

private struct AlmanacMapEntry {
    let destinationStartId: UInt64
    let sourceStartId: UInt64
    let rangeLength: UInt64
    
    func sourceRangeOverlapsWith(_ other: AlmanacMapEntry) -> Bool {
        return rangesOverlap(
            start1: sourceStartId,
            length1: rangeLength,
            start2: other.sourceStartId,
            length2: other.rangeLength
        )
    }
    
    func destinationRangeOverlapsWith(_ other: AlmanacMapEntry) -> Bool {
        return rangesOverlap(
            start1: destinationStartId,
            length1: rangeLength,
            start2: other.destinationStartId,
            length2: other.rangeLength
        )
    }
}

private func rangesOverlap(start1: UInt64, length1: UInt64, start2: UInt64, length2: UInt64) -> Bool {
    let end1 = start1 + length1 - 1
    let end2 = start2 + length2 - 1
    return end1 >= start2 && start1 <= end2
}

private func sanityCheckNoOverlappingRanges(_ entries: [AlmanacMapEntry]) -> Bool {
    for (idx, entry) in entries.enumerated() {
        if idx >= entries.count - 1 {
            continue
        }
        for otherEntry in entries[(idx + 1)...] {
            if entry.sourceRangeOverlapsWith(otherEntry) || entry.destinationRangeOverlapsWith(otherEntry) {
                return false
            }
        }
    }
    return true
}

private func parseAlmanacMap(_ mapChunk: String) throws -> AlmanacMap {
    let lines = mapChunk.components(separatedBy: "\n")
    let labelComponents = lines[0].components(separatedBy: " ")[0].components(separatedBy: "-")
    let sourceType = labelComponents[0]
    let destinationType = labelComponents[2]
    let entries = try lines.dropFirst().map {
        let entryComponents = $0.components(separatedBy: " ")
        guard let destinationStartId = UInt64(entryComponents[0]) else {
            throw AdventError.invalidData("Failed to parse destination from \(entryComponents)")
        }
        guard let sourceStartId = UInt64(entryComponents[1]) else {
            throw AdventError.invalidData("Failed to parse source from \(entryComponents)")
        }
        guard let rangeLength = UInt64(entryComponents[2]) else {
            throw AdventError.invalidData("Failed to parse range length from \(entryComponents)")
        }
        return AlmanacMapEntry(
            destinationStartId: destinationStartId,
            sourceStartId: sourceStartId,
            rangeLength: rangeLength
        )
    }
    guard sanityCheckNoOverlappingRanges(entries) else {
        throw AdventError.invalidAssumption(
            "Map from \(sourceType) to \(destinationType) has overlapping ranges, so it is not 1:1"
        )
    }
    return AlmanacMap(sourceType: sourceType, destinationType: destinationType, entries: entries)
}

private func parseAlmanac(_ inputData: String) throws -> Almanac {
    let chunks = inputData.components(separatedBy: "\n\n")
    let seeds = chunks[0].components(separatedBy: ": ")[1]
        .components(separatedBy: " ")
        .compactMap { UInt64($0) }
    let maps = try chunks.dropFirst().map {
        try parseAlmanacMap($0.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    let mapsBySource = maps.reduce(into: [String: AlmanacMap]()) { (data, map) in
        data[map.sourceType] = map
    }
    let mapsByDestination = maps.reduce(into: [String: AlmanacMap]()) { (data, map) in
        data[map.destinationType] = map
    }
    return Almanac(seeds: seeds, mapsBySource: mapsBySource, mapsByDestination: mapsByDestination)
}

private func getLocation(forSeed seed: UInt64, in almanac: Almanac) throws -> UInt64 {
    var currentId = seed
    var currentType = "seed"
    while currentType != "location" {
        guard let map = almanac.mapsBySource[currentType] else {
            throw AdventError.invalidData("No map for source \(currentType)")
        }
        for entry in map.entries {
            if currentId >= entry.sourceStartId && currentId < entry.sourceStartId + entry.rangeLength {
                currentId -= entry.sourceStartId
                currentId += entry.destinationStartId
                break
            }
        }
        currentType = map.destinationType
    }
    return currentId
}

private func getSeed(forLocation location: UInt64, in almanac: Almanac) throws -> UInt64 {
    var currentId = location
    var currentType = "location"
    while currentType != "seed" {
        guard let map = almanac.mapsByDestination[currentType] else {
            throw AdventError.invalidData("No map for destination \(currentType)")
        }
        for entry in map.entries {
            if currentId >= entry.destinationStartId && currentId < entry.destinationStartId + entry.rangeLength {
                currentId -= entry.destinationStartId
                currentId += entry.sourceStartId
                break
            }
        }
        currentType = map.sourceType
    }
    return currentId
}

private func getMinimumLocation(withSeeds seeds: any Sequence<UInt64>, in almanac: Almanac) throws -> UInt64 {
    guard let location = try seeds.map({ try getLocation(forSeed: $0, in: almanac) }).min() else {
        throw AdventError.invalidData("No seeds found")
    }
    return location
}

private func getPart1Answer(_ almanac: Almanac) throws -> UInt64 {
    return try getMinimumLocation(withSeeds: almanac.seeds, in: almanac)
}

private func getPart2Answer(_ almanac: Almanac) throws -> UInt64 {
    let seedRanges = (0..<(almanac.seeds.count / 2)).map {
        let pairOffset = $0 * 2
        let startId = almanac.seeds[pairOffset]
        let rangeLength = almanac.seeds[pairOffset + 1]
        return startId..<(startId + rangeLength)
    }
    for location in UInt64(0)... {
        let seed = try getSeed(forLocation: location, in: almanac)
        for range in seedRanges {
            if range.contains(seed) {
                return location
            }
        }
    }
    throw AdventError.invalidState("No matching location found")
}

class Advent2023Day05Runner: AdventRunner {
    let year = "2023"
    let day = "05"
    
    func run(withInputDirectoryURL inputURL: URL) throws {
        let data = try getInputText(fromFileNamed: inputFilename, inDirectoryURL: inputURL)
        let almanac = try parseAlmanac(data)
        print("The answer to part 1 is \(try getPart1Answer(almanac))")
        print("The answer to part 2 is \(try getPart2Answer(almanac))")
    }
}
