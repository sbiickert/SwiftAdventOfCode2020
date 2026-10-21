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
			.compactMap({Int($0)})
			.sorted()
		
		let p1 = solvePartOne(timestamp, busIDs)
		
		return AoCResult(part1: "The earliest bus ID * wait is \(p1)", part2: "sync")
	}
	
	func solvePartOne(_ timestamp: Int, _ busIDs: [Int]) -> Int {
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
}

