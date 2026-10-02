//
//  Day09.swift
//  AoC2020
//

import Foundation
import Algorithms

class Day09: AoCSolution {
	override init() {
		super.init()
		day = 09
		self.name = "Encoding Error"
		self.emptyLinesIndicateMultipleInputs = true
	}
	
	override func solve(_ input: AoCInput) -> AoCResult {
		super.solve(input)
		
		let preambleSize = input.fileName.contains(/test/) ? 5 : 25
		let numbers = input.textLines.compactMap({Int($0)})
		
		let p1 = solvePartOne(numbers, size: preambleSize)
		
		return AoCResult(part1: "The first invalid number is \(p1)", part2: "sync")
	}
	
	func solvePartOne(_ roNumbers:[Int], size: Int) -> Int {
		var numbers = roNumbers
		var preamble = buildPreamble(from: &numbers, size: size)
		
		while !numbers.isEmpty {
			let number = numbers.removeFirst()
			if isValid(number: number, preamble: preamble) {
				let _ = preamble.removeFirst()
				preamble.append(number)
			}
			else {
				return number
			}
		}
		return -1
	}
	
	func isValid(number: Int, preamble:[Int]) -> Bool {
		for pair in preamble.combinations(ofCount: 2) {
			if pair.first! + pair.last! == number { return true }
		}
		return false
	}
	
	func buildPreamble(from numbers: inout [Int], size: Int) -> [Int] {
		var preamble = [Int]()
		for _ in 1...size {
			preamble.append(numbers.removeFirst())
		}
		return preamble
	}
}

