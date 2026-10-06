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
		
		var seatingArea = AoCArrayGrid(defaultValue: ".", rule: .queen)
		seatingArea.load(data: input.textLines)
		let p1 = solvePart(seatingArea, part: 1)
		
		seatingArea = AoCArrayGrid(defaultValue: ".", rule: .queen)
		seatingArea.load(data: input.textLines)
		let p2 = solvePart(seatingArea, part: 2)

		return AoCResult(part1: "There are \(p1) occupied seats",
						 part2: "There are \(p2) occupied seats")
	}
	
	func solvePart(_ seatingArea: AoCArrayGrid, part: Int) -> Int {
		var adds = Set<AoCCoord2D>()
		var deletes = Set<AoCCoord2D>()
		let tolerance = part == 1 ? 4 : 5
		
		while true {
			for xy in seatingArea.allXY {
				let value = seatingArea.stringValue(x: xy.0, y: xy.1)
				
				let occupiedNeighborCount =
					(part == 1) ?
						countNeighborsP1(x: xy.0, y: xy.1, in: seatingArea) :
						countNeighborsP2(x: xy.0, y: xy.1, in: seatingArea)
				
				if value == "L" {
					if occupiedNeighborCount == 0 {
						adds.insert(AoCCoord2D(x: xy.0, y: xy.1))
					}
				}
				else if value == "#" {
					if occupiedNeighborCount >= tolerance {
						deletes.insert(AoCCoord2D(x: xy.0, y: xy.1))
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
	
	func countNeighborsP1(x: Int, y: Int, in seatingArea: AoCArrayGrid) -> Int {
		return seatingArea.neighbourXY(x: x, y: y, withValue: "#").count
	}
	
	func countNeighborsP2(x: Int, y: Int, in seatingArea: AoCArrayGrid) -> Int {
		var count = 0
		for offset in seatingArea.neighbourOffsets {
			var xy = (x + offset.x, y + offset.y)
			while seatingArea.isInBounds(x: xy.0, y: xy.1) {
				let value = seatingArea.stringValue(x: xy.0, y: xy.1)
				if value == "#" {
					count += 1
					break
				}
				else if value == "L" {
					break
				}
				xy = (xy.0 + offset.x, xy.1 + offset.y)
			}
		}
		return count
	}
}

