//
//  Day12.swift
//  AoC2020
//

import Foundation

class Day12: AoCSolution {
	override init() {
		super.init()
		day = 12
		self.name = "Rain Risk"
		self.emptyLinesIndicateMultipleInputs = true
	}
	
	override func solve(_ input: AoCInput) -> AoCResult {
		super.solve(input)
		
		let instructions = input.textLines.map { NavInstruction(defn: $0) }
		
		let p1 = solvePartOne(instructions)
		
		return AoCResult(part1: "The ferry is \(p1) units from the start", part2: "sync")
	}
	
	func solvePartOne(_ instructions: [NavInstruction]) -> Int {
		let ferry = Ferry()
		for i in instructions {
			ferry.move(instruction: i)
		}
		return ferry.position.location.manhattanDistance(to: AoCCoord2D.origin)
	}
}

class Ferry {
	var position = AoCPos2D(location: AoCCoord2D.origin,
							direction: .east)
	var waypoint = AoCCoord2D(x: 10, y: -1)
	
	func move(instruction: NavInstruction) {
		if let dir = instruction.iType.direction {
			var loc = position.location
			for _ in 1...instruction.value { loc = loc.offset(direction: dir) }
			position = AoCPos2D(location: loc, direction: position.direction)
		}
		else if let turnDir = instruction.iType.turnDirection {
			let turnCount = instruction.turnCount
			var p = position
			for _ in 1...turnCount { p = p.turned(turnDir) }
			position = p
		}
		else {
			position = position.movedForward(distance: instruction.value)
		}
	}
}

enum NavInstructionType: String {
	case N = "N"
	case S = "S"
	case E = "E"
	case W = "W"
	case L = "L"
	case R = "R"
	case F = "F"
	
	var direction: AoCDir? {
		if self == .N 		{ return .north}
		else if self == .S	{ return .south }
		else if self == .W	{ return .west }
		else if self == .E	{ return .east }
		return nil
	}
	
	var turnDirection: AoCTurn? {
		if self == .L		{ return .left }
		else if self == .R	{ return .right }
		return nil
	}
}

struct NavInstruction {
	let iType: NavInstructionType
	let value: Int
	
	init(defn: String) {
		let m = defn.firstMatch(of: /([A-Z])(\d+)/)!
		iType = NavInstructionType(rawValue: String(m.1))!
		value = Int(String(m.2))!
	}
	
	var turnCount: Int {
		guard iType.turnDirection != nil else { return 0 }
		return value / 90
	}
}
