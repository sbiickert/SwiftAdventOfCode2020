//
//  Day02.swift
//  AoC2020
//

import Foundation

class Day02: AoCSolution {
	override init() {
		super.init()
		day = 02
		self.name = "Password Philosophy"
		self.emptyLinesIndicateMultipleInputs = true
	}
	
	override func solve(_ input: AoCInput) -> AoCResult {
		super.solve(input)
		
		let policies = input.textLines.map { Policy(defn: $0) }
		
		let p1 = policies.count(where: {$0.isValidPartOne})
		let p2 = policies.count(where: {$0.isValidPartTwo})

		return AoCResult(part1: "Number of valid passwords: \(p1)", part2: "Number of valid passwords: \(p2)")
	}
}

struct Policy {
	let letter: Character
	let min: Int
	let max: Int
	let password: String
	
	init(defn: String) {
		let re = /(\d+)-(\d+) ([a-z]): ([a-z]+)/
		let m = defn.firstMatch(of: re)!
		
		letter = Character(String(m.3))
		min = Int(m.1)!
		max = Int(m.2)!
		password = String(m.4)
	}
	
	var isValidPartOne: Bool {
		let count = password.filter({ $0 == letter} ).count
		return count >= min && count <= max
	}
	
	var isValidPartTwo: Bool {
		let index1 = min - 1
		let index2 = max - 1
		let index1IsLetter = password[index1] == letter
		let index2IsLetter = password[index2] == letter

		return AoCUtil.xor(index1IsLetter, index2IsLetter)
	}
}
