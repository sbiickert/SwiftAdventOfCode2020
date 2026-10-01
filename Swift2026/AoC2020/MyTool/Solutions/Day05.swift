//
//  Day05.swift
//  AoC2020
//

import Foundation

class Day05: AoCSolution {
	override init() {
		super.init()
		day = 05
		self.name = "Binary Boarding"
		self.emptyLinesIndicateMultipleInputs = true
	}
	
	override func solve(_ input: AoCInput) -> AoCResult {
		super.solve(input)
		
		let passes = input.textLines.map { BoardingPass(defn: $0) }
		
		let p1 = passes.max(by: { $0.seatID < $1.seatID })?.seatID ?? -1
//		let p1 = passes.sorted(by: { $0.seatID < $1.seatID }).last?.seatID ?? -1

		return AoCResult(part1: "The highest seat ID is \(p1)", part2: "sync")
	}
}

struct BoardingPass {
	let defn: String
	let row: Int
	let seat: Int
	
	init(defn str: String) {
		defn = str
		
		let m = defn.firstMatch(of: /([FB]+)([RL]+)/)!
		let rowBinary = m.1.replacingOccurrences(of: "B", with: "1")
			.replacingOccurrences(of: "F", with: "0")
		let seatBinary = m.2.replacingOccurrences(of: "R", with: "1")
			.replacingOccurrences(of: "L", with: "0")
		row = Int(rowBinary, radix: 2)!
		seat = Int(seatBinary, radix: 2)!
	}
	
	var seatID: Int {
		return row * 8 + seat
	}
}
