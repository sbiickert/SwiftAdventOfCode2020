//
//  Day14.swift
//  AoC2020
//

import Foundation

class Day14: AoCSolution {
	override init() {
		super.init()
		day = 14
		self.name = "Docking Data"
		self.emptyLinesIndicateMultipleInputs = true
	}
	
	override func solve(_ input: AoCInput) -> AoCResult {
		super.solve(input)
		
		let instructions = parseInput(lines: input.textLines)
		
		let p1 = solvePartOne(instructions: instructions)
		
		return AoCResult(part1: "The total memory values is \(p1)", part2: "sync")
	}
	
	func solvePartOne(instructions: [Instruction]) -> Int {
		var mInstructions = instructions
		var currentMask = mInstructions.removeFirst() as! MaskInstruction
		var memory = Dictionary<Int, Int>()
		
		while !mInstructions.isEmpty {
			let nextInstruction = mInstructions.removeFirst()
			if let mask = nextInstruction as? MaskInstruction {
				currentMask = mask
			}
			else if let mem = nextInstruction as? MemInstruction {
				let value = mem.value.mask(with: currentMask)
				memory[mem.address] = value.integerValue
			}
		}
		
		let total = memory.values.reduce(0, +)
		return total
	}
	
//	func solvePartTwo
	
	func parseInput(lines: [String]) -> [Instruction] {
		var result = [Instruction]()
		for line in lines {
			if let m = line.firstMatch(of: /mask = ([X01]+)/) {
				result.append(MaskInstruction(data: String(m.1).map(String.init).reversed()))
			}
			else if let m = line.firstMatch(of: /mem\[(\d+)\] = (\d+)/) {
				let i64 = Int(String(m.2))!
				result.append(MemInstruction(address: Int(String(m.1))!, value: Int36(intval: i64)))
			}
		}
		return result
	}
}

protocol Instruction {}

struct MaskInstruction: Instruction {
	let data: [String]
}

struct MemInstruction: Instruction {
	let address: Int
	let value: Int36
}

struct Int36 {
	let data: [Bool]
	
	init(intval i: Int) {
		var d = [Bool]()
		for exp in 0..<36 {
			d.append(AoCUtil.powerOf(base: 2, toExponent: exp) & i != 0)
		}
		data = d
	}
	
	init(data d: [Bool]) {
		assert(d.count == 36)
		data = d
	}
	
	var integerValue: Int {
		var i = 0
		for exp in 0..<36 {
			if data[exp] {
				i += AoCUtil.powerOf(base: 2, toExponent: exp)
			}
		}
		return i
	}
	
	func mask(with m:MaskInstruction) -> Int36 {
		var newData = [Bool]()
		for exp in 0..<36 {
			switch m.data[exp] {
			case "1":
				newData.append(true)
			case "0":
				newData.append(false)
			default:
				newData.append(data[exp])
			}
		}
		return Int36(data: newData)
	}
	
	func decode(with m:MaskInstruction) -> [Int36] {
		return [Int36(intval: 0)]
	}
}
