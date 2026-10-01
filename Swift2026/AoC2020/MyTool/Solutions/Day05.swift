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
		let p2 = findMySeat(passes)

		return AoCResult(part1: "The highest seat ID is \(p1)", part2: "My seat ID is \(p2)")
	}
	
	func findMySeat(_ passes: [BoardingPass]) -> Int {
		let sortedPasses = passes.sorted(by: { $0.seatID < $1.seatID })
		for i in 0..<passes.count-1 {
			if sortedPasses[i+1].seatID - sortedPasses[i].seatID > 1 {
				return sortedPasses[i].seatID + 1
			}
		}
		return -1
	}
}

struct BoardingPass {
	let defn: String
	let row: Int
	let seat: Int
	let seatID: Int
	
	init(defn str: String) {
		defn = str
		
		let m = defn.firstMatch(of: /([FB]+)([RL]+)/)!
		
		let replacements = [("B","1"), ("F","0"),("R","1"), ("L","0")]
		let rowBinary = replacements.reduce(m.1) { $0.replacing($1.0, with: $1.1) }
		let seatBinary = replacements.reduce(m.2) { $0.replacing($1.0, with: $1.1) }

		row = Int(rowBinary, radix: 2)!
		seat = Int(seatBinary, radix: 2)!
		
		seatID = row * 8 + seat
	}
}
