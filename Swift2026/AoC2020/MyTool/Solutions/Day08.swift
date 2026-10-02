//
//  Day08.swift
//  AoC2020
//

import Foundation

class Day08: AoCSolution {
	override init() {
		super.init()
		day = 08
		self.name = "Handheld Halting"
		self.emptyLinesIndicateMultipleInputs = true
	}
	
	override func solve(_ input: AoCInput) -> AoCResult {
		super.solve(input)
		
		let console = GameConsole(program: input.textLines)
		
		let p1 = solvePartOne(console)
		let p2 = solvePartTwo(console)
		
		return AoCResult(part1: "The accumulator at the loop was \(p1)", part2: "The final accumulator was \(p2)")
	}
	
	func solvePartOne(_ console: GameConsole) -> Int {
		if let _ = console.run() {  } // Will return nil
		return console.accumulator
	}
	
	func solvePartTwo(_ console: GameConsole) -> Int {
		for i in 0..<console.programLength {
			console.reset()
			if console.swapJmpNop(at: i) {
				// Was a change, test
				if let acc = console.run() {
					return acc
				}
			}
		}
		return -1
	}
}

class GameConsole {
	private var program: [GameInstruction]
	private let originalProgram: [GameInstruction]
	private var ptr: Int = 0
	private(set) var accumulator = 0
	private var history = Set<Int>()
	
	init(program defn: [String]) {
		program = defn.map{ GameInstruction(defn: $0) }
		originalProgram = program
	}
	
	var programLength: Int { return program.count }
	
	func reset() {
		ptr = 0
		accumulator = 0
		history.removeAll()
		program = originalProgram
	}
	
	func run() -> Int? {
		while ptr < program.count {
			if history.contains(ptr) { return nil } // Infinite loop found
			executeInstruction()
		}
		return accumulator
	}
	
	func executeInstruction() {
		let instruction = program[ptr]
		history.insert(ptr)
		
		switch instruction.type {
		case .acc:
			accumulator += instruction.value
			ptr += 1
		case .jmp:
			ptr += instruction.value
		case .nop:
			ptr += 1
		}
	}
	
	func swapJmpNop(at index:Int) -> Bool {
		switch (program[index].type, program[index].value) {
		case (.jmp, let v):
			program[index] = GameInstruction(type: .nop, value: v)
		case (.nop, let v):
			program[index] = GameInstruction(type: .jmp, value: v)
		case (.acc, _):
			return false
		}
		return true
	}
}

struct GameInstruction {
	let type: GameInstructionType
	let value: Int
	
	init(defn: String) {
		let m = defn.firstMatch(of: /([a-z]+) (.+)/)!
		type = GameInstructionType(rawValue: String(m.1))!
		value = Int(String(m.2))!
	}
	
	init(type: GameInstructionType, value: Int) {
		self.type = type
		self.value = value
	}
}

enum GameInstructionType: String {
	case acc = "acc"
	case jmp = "jmp"
	case nop = "nop"
}
