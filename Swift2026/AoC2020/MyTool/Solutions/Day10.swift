//
//  Day10.swift
//  AoC2020
//

import Foundation
import Algorithms

class Day10: AoCSolution {
	override init() {
		super.init()
		day = 10
		self.name = "Adapter Array"
		self.emptyLinesIndicateMultipleInputs = true
	}
	
	override func solve(_ input: AoCInput) -> AoCResult {
		super.solve(input)
		
		var joltages = input.textLines.compactMap({Int($0)}).sorted()
		joltages.insert(0, at: 0)
		
		let p1 = solvePartOne(joltages)
		
		return AoCResult(part1: "1-jolt diffs * 3-jolt diffs is \(p1)", part2: "sync")
	}
	
	func solvePartOne(_ joltagesRO: [Int]) -> Int {
		var joltages = joltagesRO
		joltages.append(joltagesRO.max()! + 3)
		let differences = joltages.adjacentPairs().map { $1 - $0 }
		let count1 = differences.count(where: {$0 == 1})
		let count3 = differences.count(where: {$0 == 3})
		return count1 * count3
	}
}

