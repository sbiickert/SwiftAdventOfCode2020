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
		console.reset()
		
		return AoCResult(part1: "The accumulator was \(p1)", part2: "sync")
	}
	
	func solvePartOne(_ console: GameConsole) -> Int {
		if let _ = console.run() {  } // Will return nil
		return console.accumulator
	}
}

class GameConsole {
	var program: [GameInstruction]
	var ptr: Int = 0
	var accumulator = 0
	var history = Set<Int>()
	
	init(program defn: [String]) {
		program = defn.map{ GameInstruction(defn: $0) }
	}
	
	func reset() {
		ptr = 0
		accumulator = 0
		history.removeAll()
	}
	
	func run() -> Int? {
		while ptr < program.count {
			if history.contains(ptr) { return nil }
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
}

struct GameInstruction {
	let type: GameInstructionType
	let value: Int
	
	init(defn: String) {
		let m = defn.firstMatch(of: /([a-z]+) (.+)/)!
		type = GameInstructionType(rawValue: String(m.1))!
		value = Int(String(m.2))!
	}
}

enum GameInstructionType: String {
	case acc = "acc"
	case jmp = "jmp"
	case nop = "nop"
}
