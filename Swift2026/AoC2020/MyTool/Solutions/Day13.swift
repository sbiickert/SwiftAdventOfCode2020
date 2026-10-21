//
//  Day13.swift
//  AoC2020
//

import Foundation

class Day13: AoCSolution {
	override init() {
		super.init()
		day = 13
		self.name = "Shuttle Search"
		self.emptyLinesIndicateMultipleInputs = true
	}
	
	override func solve(_ input: AoCInput) -> AoCResult {
		super.solve(input)
		
		let timestamp = Int(input.textLines.first!)!
		let busIDs = input.textLines.last!
			.split(separator: ",")
			.map({Int($0)})
		
		let p1 = solvePartOne(timestamp, busIDs)
		let p2 = solvePartTwo(busIDs)
		
		return AoCResult(part1: "The earliest bus ID * wait is \(p1)",
						 part2: "The earliest time stamp where the buses line up is \(p2)")
	}
	
	func solvePartOne(_ timestamp: Int, _ busIDsWithNils: [Int?]) -> Int {
		let busIDs = busIDsWithNils.compactMap({$0}).sorted()
		var earliestTime = timestamp - 1
		var earliestBus: Int? = nil
		
		while earliestBus == nil {
			earliestTime += 1
			for id in busIDs {
				if earliestTime % id == 0 {
					earliestBus = id
					break
				}
			}
		}
		
		return (earliestTime - timestamp) * earliestBus!
	}
	
	func solvePartTwo(_ busIDs:[Int?]) -> Int {
		// Turn the list of ids (and nils marking no bus) into a list of (id, offset)
		let info = busIDs.enumerated()
			.compactMap({ (index, id) in
				if let id { return (id: id, offset: index) }
				return nil
			})
		
		var t = 0
		var idx = 0
		var jump = 1
		var result: Int? = nil
		
		while result == nil {
			if t == 0 || (t + info[idx].offset) % info[idx].id == 0 {
				if idx == info.count-1 {
					result = t
					break
				}
				jump *= info[idx].id
				idx += 1
			}
			t += jump
		}
		
		return result!
	}
}

