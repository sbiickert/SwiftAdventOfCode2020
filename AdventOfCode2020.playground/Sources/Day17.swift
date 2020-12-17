import Foundation

public class Day17 {
	
	static let MAX_ITER = 6
	
	public static func solve() {
		//let input = [[".#.", "..#", "###"], []] // Example
		let input = readGroupedInputFile(named: "Day17_Input") // [0] is the example, [1] is the real input
		let dimension = PocketDimension(inputState: input[1], numberOfDimensions: 4)
		print(dimension)
		print("Start active cube count: \(dimension.activeCount)")
		for i in 0..<MAX_ITER {
			dimension.iterate()
			//print(dimension)
			print("(\(i+1)) active cubes: \(dimension.activeCount)")
		}
	}
	
	static func readInputFile(named name:String, removingEmptyLines removeEmpty:Bool) -> [String] {
		var results = [String]()
		if let inputPath = Bundle.main.path(forResource: name, ofType: "txt") {
			do {
				let input = try String(contentsOfFile: inputPath)
				results = input.components(separatedBy: "\n")
			} catch {
				print("Could not read file \(name)")
			}
		}
		if removeEmpty {
			results = results.filter { $0.count > 0 }
		}
		return results
	}

	static func readGroupedInputFile(named name: String) -> [[String]] {
		var results = [[String]]()
		let lines = readInputFile(named: name, removingEmptyLines: false)
		
		var group = [String]()
		for line in lines {
			if line.count > 0 {
				group.append(line)
			}
			else {
				results.append(group)
				group = [String]()
			}
		}
		if group.count > 0 {
			results.append(group)
		}
		
		return results
	}
}

private class PocketDimension: CustomStringConvertible {
	enum State: Character {
		case active = "#"
		case inactive = "."
	}
	
	var description: String {
		var desc = ""
		let size = bounds
		
		for w in size.wmin...size.wmax {
			for z in size.zmin...size.zmax {
				desc += "Z: \(z), W: \(w)\n"
				for y in size.ymin...size.ymax {
					for x in size.xmin...size.xmax {
						let c = PocketCoord4(x: x, y: y, z: z, w: w)
						let s = getState(at: c)
						desc += String(s.rawValue)
					}
					desc += "\n"
				}
			}
		}
		return desc
	}
	
	private(set) var dimensionCount = 3
	private var _grid = Dictionary<PocketCoord4, State>()
	
	init(inputState: [String], numberOfDimensions nDim: Int) {
		for (j, line) in inputState.enumerated() {
			for (i, state) in Array(line).enumerated() {
				let pc = PocketCoord4(x: i, y: j, z: 0, w: 0)
				_grid[pc] = State(rawValue: state)
			}
		}
		dimensionCount = nDim
	}
	
	func getState(at coord: PocketCoord4) -> State {
		if let state = _grid[coord] {
			return state
		}
		return .inactive
	}
	
	var bounds: (xmin: Int, xmax: Int, ymin: Int, ymax: Int, zmin: Int, zmax: Int, wmin: Int, wmax: Int) {
		// Figure out the min, max X, Y, Z dimensions
		let xKeys = _grid.keys.sorted(by: {$0.x < $1.x})
		let yKeys = _grid.keys.sorted(by: {$0.y < $1.y})
		let zKeys = _grid.keys.sorted(by: {$0.z < $1.z})
		let wKeys = _grid.keys.sorted(by: {$0.w < $1.w})

		return (xKeys.first!.x, xKeys.last!.x,
				yKeys.first!.y, yKeys.last!.y,
				zKeys.first!.z, zKeys.last!.z,
				wKeys.first!.w, wKeys.last!.w)
	}
	
	var activeCount: Int {
		var count = 0
		for coord in _grid.keys {
			count += _grid[coord] == .active ? 1 : 0
		}
		return count
	}
	
	func iterate() {
		var gridcopy = _grid
		
		// Every iteration will grow the pocket dimension impacted area by 1
		let dw = dimensionCount == 4 ? 1 : 0 //only grow w dimension if 4 dimensional
		var size = bounds
		size = (size.xmin-1, size.xmax+1,
				size.ymin-1, size.ymax+1,
				size.zmin-1, size.zmax+1,
				size.wmin-dw, size.wmax+dw)
		var allCoords = [PocketCoord4]()
		for x in size.xmin...size.xmax {
			for y in size.ymin...size.ymax {
				for z in size.zmin...size.zmax {
					for w in size.wmin...size.wmax { // 3D will be min, max = 0
						allCoords.append(PocketCoord4(x: x, y: y, z: z, w: w))
					}
				}
			}
		}
		
		for coord in allCoords {
			var countActive = 0
			let neighborCoords = coord.neighboringCoords
			for nc in neighborCoords {
				if getState(at: nc) == .active {
					//print("Found active neighbour at \(nc)")
					countActive += 1
				}
			}
			//print("Active neighbors for \(coord) is \(countActive) of \(neighborCoords.count)")
			let cubeState = getState(at: coord)
			if cubeState == .active {
				if countActive < 2 || countActive > 3 {
					gridcopy[coord] = .inactive
				}
			}
			else {
				if countActive == 3 {
					gridcopy[coord] = .active
				}
				else {
					gridcopy[coord] = .inactive
				}
			}
		}
		_grid = gridcopy
	}
}

private struct PocketCoord4: Hashable {
	let x: Int
	let y: Int
	let z: Int
	let w: Int
	
	var neighboringCoords: [PocketCoord4] {
		var nc = [PocketCoord4]()
		for i in -1...1 {
			for j in -1...1 {
				for k in -1...1 {
					for l in -1...1 {
						if i != 0 || j != 0 || k != 0 || l != 0 {
							nc.append(PocketCoord4(x: x+i, y: y+j, z: z+k, w: w+l))
						}
					}
				}
			}
		}
		return nc
	}
}
