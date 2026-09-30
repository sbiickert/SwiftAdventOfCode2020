//
//  Day03.swift
//  AoC2020
//

import Foundation

class Day03: AoCSolution {
	override init() {
		super.init()
		day = 03
		self.name = "Toboggan Trajectory"
		self.emptyLinesIndicateMultipleInputs = true
	}
	
	override func solve(_ input: AoCInput) -> AoCResult {
		super.solve(input)
		
		let map = AoCGrid2D()
		map.load(data: input.textLines)
		
		let p1Runs = [(3,1)]
		let p1 = solvePart(map: map, runs: p1Runs)
		
		let p2Runs = [(1,1),(3,1),(5,1),(7,1),(1,2)]
		let p2 = solvePart(map: map, runs: p2Runs)
		
		return AoCResult(part1: "The number of impacted trees is \(p1)", part2: "Product of impacts on trajectories: \(p2)")
	}
	
	func solvePart(map: AoCGrid2D, runs:[(Int,Int)]) -> Int {
		let impacts = runs.map { slide(map: map, right: $0.0, down: $0.1) }
		return impacts.reduce(1, *)
	}

	func slide(map: AoCGrid2D, right: Int, down: Int) -> Int {
		let offset = AoCCoord2D(x: right, y: down)
		let xMax = map.extent!.max.x
		let yMax = map.extent!.max.y

		var location = AoCCoord2D.origin
		var impacts = 0
		while location.y < yMax {
			location = location + offset
			if (location.x > xMax) { // Wrap horizontally
				location = AoCCoord2D(x: location.x - (xMax+1), y: location.y)
			}
			if map.stringValue(at: location) == "#" {
				impacts += 1
			}
		}
		return impacts
	}
}

