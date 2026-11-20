//
//  Day15.swift
//  AoC2020
//

import Foundation

class Day15: AoCSolution {
	override init() {
		super.init()
		day = 15
		self.name = "Rambunctious Recitation"
		self.emptyLinesIndicateMultipleInputs = true
	}
	
	override func solve(_ input: AoCInput) -> AoCResult {
		super.solve(input)
		
		let nums = input.textLines.first!.split(separator: ",").compactMap {Int($0)}
		
		let p1 = solve(startNumbers: nums, rounds: 2020)
		
		return AoCResult(part1: "The last number after 2020 rounds is \(p1)", part2: "sync")
	}
	
	func solve(startNumbers: [Int], rounds: Int) -> Int {
		let nums = startNumbers[0..<startNumbers.count-1]
		var data = Dictionary(uniqueKeysWithValues: nums.enumerated().map { ($1, $0) } )
//		print(nums.compactMap({String($0)}).joined(separator: ","))
		
		var lastNumber = startNumbers.last!
		
		for index in nums.count ..< rounds-1 {
//			print("\(index): \(lastNumber)")
			var nextNumber = 0
			
			if let previousIndex = data[lastNumber] {
				nextNumber = index - previousIndex
			}
			
			data[lastNumber] = index
			lastNumber = nextNumber
		}
		return lastNumber
	}
	
}

