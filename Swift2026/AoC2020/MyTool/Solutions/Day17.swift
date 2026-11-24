//
//  Day17.swift
//  AoC2020
//

import Foundation

class Day17: AoCSolution {
	override init() {
		super.init()
		day = 17
		self.name = "Conway Cubes"
		self.emptyLinesIndicateMultipleInputs = true
	}
	
	override func solve(_ input: AoCInput) -> AoCResult {
		super.solve(input)
		
		let startPocketDimension = setup(lines: input.textLines)
		
		let p1 = solvePart(pocket: startPocketDimension, dimensions: 3, cycles: 6)
		let p2 = solvePart(pocket: startPocketDimension, dimensions: 4, cycles: 6)

		return AoCResult(part1: "Number of active cubes (d=3): \(p1)",
						 part2: "Number of active cubes (d=4): \(p2)")
	}
	
	func setup(lines: [String]) -> Dictionary<ConwayPoint, Bool> {
		var result = Dictionary<ConwayPoint, Bool>()
		for (y, line) in lines.enumerated() {
			for (x, glyph) in line.map({String($0)}).enumerated() {
				result[ConwayPoint(x: x, y: y, z: 0, w: 0)] = glyph == "#"
			}
		}
		return result
	}
	
	func solvePart(pocket startState: Dictionary<ConwayPoint, Bool>, dimensions: Int, cycles: Int) -> Int {
		var pocket = startState
		let offsets = dimensions == 3 ? ConwayPoint.offsets3 : ConwayPoint.offsets4
		var maxLimit = ConwayPoint.origin
		var minLimit = ConwayPoint.origin
		for (cp, _) in startState {
			maxLimit = maxLimit.max(other: cp)
			minLimit = minLimit.min(other: cp)
		}

		for _ in 1...cycles {
			var nextPocket = Dictionary<ConwayPoint, Bool>()
			let searchMin = minLimit + ConwayPoint(x: -1, y: -1, z: -1, w: dimensions == 4 ? -1 : 0)
			let searchMax = maxLimit + ConwayPoint(x:  1, y:  1, z:  1, w: dimensions == 4 ?  1 : 0)

			for cp in ConwayPoint.allPoints(from: searchMin, to: searchMax) {
				let isActive = pocket[cp, default: false]
				let neighbors = offsets.map { $0 + cp }
				let countOn = neighbors.filter({pocket[$0, default: false]}).count
				var newState = isActive
				if isActive && countOn != 2 && countOn != 3 {
					newState = false
				}
				else if !isActive && countOn == 3 {
					newState = true
				}
				if newState {
					maxLimit = maxLimit.max(other: cp)
					minLimit = minLimit.min(other: cp)
					nextPocket[cp] = true
				}
			}
			
			pocket = nextPocket
		}
		
		return pocket.count
	}
}

struct ConwayPoint: Hashable {
	let x: Int
	let y: Int
	let z: Int
	let w: Int
	
	static var origin: ConwayPoint {
		return ConwayPoint(x: 0, y: 0, z: 0, w: 0)
	}
	
	static func + (cp1: ConwayPoint, cp2: ConwayPoint) -> ConwayPoint {
		return ConwayPoint(x: cp1.x + cp2.x, y: cp1.y + cp2.y, z: cp1.z + cp2.z, w: cp1.w + cp2.w)
	}
	
	static func allPoints(from min: ConwayPoint, to max: ConwayPoint) -> [ConwayPoint] {
		var all = [ConwayPoint]()
		for x in min.x ... max.x {
			for y in min.y ... max.y {
				for z in min.z ... max.z {
					for w in min.w ... max.w {
						all.append(ConwayPoint(x: x, y: y, z: z, w: w))
					}
				}
			}
		}
		return all
	}
	
	func min(other: ConwayPoint) -> ConwayPoint {
		return ConwayPoint(x: Swift.min(x, other.x),
						   y: Swift.min(y, other.y),
						   z: Swift.min(z, other.z),
						   w: Swift.min(w, other.w))
	}
	
	func max(other: ConwayPoint) -> ConwayPoint {
		return ConwayPoint(x: Swift.max(x, other.x),
						   y: Swift.max(y, other.y),
						   z: Swift.max(z, other.z),
						   w: Swift.max(w, other.w))
	}

	static var offsets3: [ConwayPoint] {
		var result = [ConwayPoint]()
		for x in -1...1 {
			for y in -1...1 {
				for z in -1...1 {
					if !(x == 0 && y == 0 && z == 0) {
						result.append(ConwayPoint(x: x, y: y, z: z, w: 0))
					}
				}
			}
		}
		return result
	}
	
	static var offsets4: [ConwayPoint] {
		var result = [ConwayPoint]()
		for x in -1...1 {
			for y in -1...1 {
				for z in -1...1 {
					for w in -1...1 {
						if !(x == 0 && y == 0 && z == 0 && w == 0) {
							result.append(ConwayPoint(x: x, y: y, z: z, w: w))
						}
					}
				}
			}
		}
		return result
	}
}
