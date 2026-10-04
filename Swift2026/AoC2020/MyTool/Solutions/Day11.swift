//
//  Day11.swift
//  AoC2020
//

import Foundation

class Day11: AoCSolution {
	override init() {
		super.init()
		day = 11
		self.name = "Seating System"
		self.emptyLinesIndicateMultipleInputs = true
	}
	
	override func solve(_ input: AoCInput) -> AoCResult {
		super.solve(input)
		
		let seatingArea = AoCGrid2D(defaultValue: ".", rule: .queen)
		seatingArea.load(data: input.textLines)
		
		let p1 = solvePartOne(seatingArea)
		
		return AoCResult(part1: "There are \(p1) occupied seats", part2: "sync")
	}
	
	func solvePartOne(_ seatingArea: AoCGrid2D) -> Int {
		var adds = Set<AoCCoord2D>()
		var deletes = Set<AoCCoord2D>()
		
		while true {
			for coord in seatingArea.coords {
				let value = seatingArea.stringValue(at: coord)
				let occupiedNeighborCount = seatingArea.neighbourCoords(at: coord, withValue: "#").count
				if value == "L" {
					if occupiedNeighborCount == 0 {
						adds.insert(coord)
					}
				}
				else { // value == "#"
					if occupiedNeighborCount >= 4 {
						deletes.insert(coord)
					}
				}
			}
			
			// Steady state
			if adds.isEmpty && deletes.isEmpty {break}
			
			for coord in adds {
				seatingArea.setValue("#", at: coord)
			}
			for coord in deletes {
				seatingArea.setValue("L", at: coord)
			}
			adds.removeAll()
			deletes.removeAll()
		}
		
		let passengerCount = seatingArea.getCoords(withValue: "#").count
		return passengerCount
	}
}

