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
		
		var seatingArea = AoCDictionaryGrid(defaultValue: ".", rule: .queen)
		seatingArea.load(data: input.textLines)
		let p1 = solvePart(seatingArea, part: 1)
		
		seatingArea = AoCDictionaryGrid(defaultValue: ".", rule: .queen)
		seatingArea.load(data: input.textLines)
		let p2 = solvePart(seatingArea, part: 2)

		return AoCResult(part1: "There are \(p1) occupied seats",
						 part2: "There are \(p2) occupied seats")
	}
	
	func solvePart(_ seatingArea: AoCGrid2D, part: Int) -> Int {
		var adds = Set<AoCCoord2D>()
		var deletes = Set<AoCCoord2D>()
		let tolerance = part == 1 ? 4 : 5
		
		while true {
			for coord in seatingArea.coords {
				let value = seatingArea.stringValue(at: coord)
				
				let occupiedNeighborCount =
					(part == 1) ?
						countNeighborsP1(coord, in: seatingArea) :
						countNeighborsP2(coord, in: seatingArea)
				
				if value == "L" {
					if occupiedNeighborCount == 0 {
						adds.insert(coord)
					}
				}
				else { // value == "#"
					if occupiedNeighborCount >= tolerance {
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
	
	func countNeighborsP1(_ coord: AoCCoord2D, in seatingArea: AoCGrid2D) -> Int {
		return seatingArea.neighbourCoords(at: coord, withValue: "#").count
	}
	
	func countNeighborsP2(_ coord: AoCCoord2D, in seatingArea: AoCGrid2D) -> Int {
		let ext = seatingArea.extent!
		var count = 0
		for offset in seatingArea.neighbourOffsets {
			var n = coord + offset
			while ext.contains(n) {
				let value = seatingArea.stringValue(at: n)
				if value == "#" {
					count += 1
					break
				}
				else if value == "L" {
					break
				}
				n = n + offset
			}
		}
		return count
	}
}

