//
//  Day01.swift
//  AoC2020
//

import Foundation
import Algorithms

class Day01: AoCSolution {
	override init() {
		super.init()
		day = 1
		self.name = "Report Repair"
		self.emptyLinesIndicateMultipleInputs = true
	}
	
	override func solve(_ input: AoCInput) -> AoCResult {
		super.solve(input)
		
		let numbers = input.textLines.compactMap({Int($0)})
		
		let p1 = find2020(numbers, count: 2)
		let p2 = find2020(numbers, count: 3)
		
		return AoCResult(part1: "Two numbers product is \(p1)", part2: "Three numbers product is \(p2)")
	}

	func find2020(_ numbers: [Int], count:Int) -> Int {
		for combo in numbers.combinations(ofCount: count) {
			if combo.reduce(0, +) == 2020 {
				return combo.reduce(1, *)
			}
		}
		return -1
	}
}


