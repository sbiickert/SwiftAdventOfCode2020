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
		
		let (p1,p2) = solveParts(instructions: instructions)

		return AoCResult(part1: "The total memory values is \(p1)",
						 part2: "The total memory values is \(p2)")
	}
	
	func solveParts(instructions: [Instruction]) -> (Int,Int) {
		var mInstructions = instructions
		var currentMask = mInstructions.removeFirst() as! MaskInstruction
		var memory1 = Dictionary<Int, Int>()
		var memory2 = Dictionary<Int, Int>()

		while !mInstructions.isEmpty {
			let nextInstruction = mInstructions.removeFirst()
			if let mask = nextInstruction as? MaskInstruction {
				currentMask = mask
			}
			else if let mem = nextInstruction as? MemInstruction {
				// Part One
				let value = mem.value.mask(with: currentMask)
				memory1[mem.address.integerValue] = value.integerValue
				
				// Part Two
				let addresses = mem.address.decode(with: currentMask)
				for address in addresses {
					memory2[address.integerValue] = mem.value.integerValue
				}
			}
		}
		
		let total1 = memory1.values.reduce(0, +)
		let total2 = memory2.values.reduce(0, +)
		return (total1, total2)
	}
	
	func parseInput(lines: [String]) -> [Instruction] {
		var result = [Instruction]()
		for line in lines {
			if let m = line.firstMatch(of: /mask = ([X01]+)/) {
				result.append(MaskInstruction(data: String(m.1).map(String.init).reversed()))
			}
			else if let m = line.firstMatch(of: /mem\[(\d+)\] = (\d+)/) {
				let address = Int(String(m.1))!
				let value = Int(String(m.2))!
				result.append(MemInstruction(address: Int36(intval: address),
											 value: Int36(intval: value)))
			}
		}
		return result
	}
}

protocol Instruction {}

struct MaskInstruction: Instruction, CustomDebugStringConvertible {
	var debugDescription: String {
		return data.reversed().joined()
	}
	
	let data: [String]
	
	func derive(fromAddress a:Int36) -> MaskInstruction {
		var newData = [String]()
		for bit in 0..<36 {
			switch data[bit] {
			case "0":
				newData.append(a.data[bit] ? "1" : "0")
			default:
				newData.append(data[bit])
			}
		}
		return MaskInstruction(data: newData)
	}
	
	var hasFloat: Bool {
		return data.contains(where: {$0 == "X"})
	}
	
	// My term: anchoring is the opposite of floating
	var anchoredMasks: [MaskInstruction] {
		let masks = MaskInstruction.anchor(mask: self)
		return masks
	}
	
	private static func anchor(mask: MaskInstruction) -> [MaskInstruction] {
		var result = [MaskInstruction]()
		if mask.hasFloat {
			for bit in 0..<36 {
				if mask.data[bit] == "X" {
					var data1 = mask.data
					data1[bit] = "0"
					let mask1 = MaskInstruction(data: data1)
					result.append(contentsOf: anchor(mask: mask1))
					var data2 = mask.data
					data2[bit] = "1"
					let mask2 = MaskInstruction(data: data2)
					result.append(contentsOf: anchor(mask: mask2))
					break
				}
			}
		}
		else {
			result.append(mask)
		}
		return result
	}
}

struct MemInstruction: Instruction {
	let address: Int36
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
		let floating = m.derive(fromAddress: self)
		var result = [Int36]()
		for anchored in floating.anchoredMasks {
			result.append(self.mask(with: anchored))
		}
		return result
	}
}
