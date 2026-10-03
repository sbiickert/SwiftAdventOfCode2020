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
		joltages.append(joltages.max()! + 3)

		let p1 = solvePartOne(joltages)
		let p2 = solvePartTwo(joltages)
		
		return AoCResult(part1: "1-jolt diffs * 3-jolt diffs is \(p1)",
						 part2: "Number of possible combos is \(p2)")
	}
	
	func solvePartOne(_ joltages: [Int]) -> Int {
		let differences = joltages.adjacentPairs().map { $1 - $0 }
		let count1 = differences.count(where: {$0 == 1})
		let count3 = differences.count(where: {$0 == 3})
		return count1 * count3
	}
	
	func solvePartTwo(_ joltages: [Int]) -> Int {
		Day10._cache.removeAll()
		let combinationCount = countCombinations(index: 0, total: 0, in: joltages)
		return combinationCount
	}
	
	static var _cache = Dictionary<Int, Int>()
	
	func countCombinations(index: Int, total: Int, in joltages:[Int]) -> Int {
		if let cacheValue = Day10._cache[index] { return cacheValue }
		if index == joltages.count-1 { return 1 }
		
		var count = 0
		
		var offset = 1
		while (index + offset < joltages.count) && (joltages[index+offset] - joltages[index] <= 3) {
			count += countCombinations(index: index+offset, total: total, in: joltages)
			offset += 1
		}
		
		Day10._cache[index] = total + count
		return total + count
	}
}

