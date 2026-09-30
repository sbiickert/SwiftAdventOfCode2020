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
		
		let p1 = solvePartOne(map: map)
		
		return AoCResult(part1: "The number of impacted trees is \(p1)", part2: "sync")
	}
	
	func solvePartOne(map: AoCGrid2D) -> Int {
		return traverse(map: map, down: 1, right: 3)
	}
	
	func traverse(map: AoCGrid2D, down: Int, right: Int) -> Int {
		let start = AoCCoord2D.origin
		let offset = AoCCoord2D(x: right, y: down)
		let xMax = map.extent!.max.x
		let yMax = map.extent!.max.y

		var location = start
		var impacts = 0
		while location.y <= yMax {
			location = location + offset
			if (location.x > xMax) {
				location = AoCCoord2D(x: location.x - (xMax+1), y: location.y)
			}
			//print(location)
			if map.stringValue(at: location) == "#" {
			//	print("bang")
				impacts += 1
			}
		}
		return impacts
	}
}

