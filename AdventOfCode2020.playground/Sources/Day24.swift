import Foundation

public class Day24 {
	private static let MAX_ITER = 100
	private static var tileColorAt = Dictionary<HexCoord, HexTileColor>()
	
	public static func solve(testing: Bool) {
		let allInput = readGroupedInputFile(named: "Day24_Input")
		let input = testing ? allInput[0] : allInput[1]
		
		var paths = [[HexDir]]()
		for line in input {
			let path = parsePath(line)
			//print(path.map({$0.rawValue}))
			paths.append(path)
			//break
		}
		setupTiles(paths: paths)
		print("Start: \(blackCount) black tiles.")

		for i in 1...MAX_ITER {
			iterateGameOfLife()
			print("Day \(i): \(blackCount)")
		}
	}
	
	static func iterateGameOfLife() {
		// Just grabbing black tiles
		var evalMap = tileColorAt.filter({$0.value == .black})
		// Need to eval neighbouring whites, too
		for (coord, _) in tileColorAt.filter({$0.value == .black}) {
			let neighbours = coord.allNeighbours
			for n in neighbours {
				if evalMap[n] == nil {
					evalMap[n] = .white
				}
			}
		}
		// Apply rules
		var resultMap = Dictionary<HexCoord, HexTileColor>()
		for (coord, color) in evalMap {
			let neighbours = coord.allNeighbours
			var countBlackNeighbours = 0
			for n in neighbours {
				if tileColorAt[n] ?? .white == .black {
					countBlackNeighbours += 1
				}
			}
			if color == .black {
				let changeToWhite = countBlackNeighbours == 0 || countBlackNeighbours > 2
				resultMap[coord] = changeToWhite ? .white : .black
			}
			if color == .white {
				let changeToBlack = countBlackNeighbours == 2
				resultMap[coord] = changeToBlack ? .black : .white
			}
		}
		
		tileColorAt = resultMap
	}
	
	static var blackCount: Int {
		// Count the black tiles
		return tileColorAt.values.filter({$0 == .black}).count
	}
	
	static func setupTiles(paths: [[HexDir]]) {
		tileColorAt.removeAll()
		
		for path in paths {
			let coord = walk(path: path, startingAt: HexCoord.CENTER)
			//print("Walked to \(coord)")
			
			if tileColorAt.keys.contains(coord) == false {
				tileColorAt[coord] = .white
			}
			
			if tileColorAt[coord] == .white {
				tileColorAt[coord] = .black
			}
			else {
				tileColorAt[coord] = .white
			}
		}
	}
	
	static func walk(path: [HexDir], startingAt start: HexCoord) -> HexCoord {
		var coord = start
		
		//print("Starting at \(coord)")
		for dir in path {
			let n = coord.neighbor(at: dir)
			//print("Walk \(dir.rawValue) to \(n)")
			coord = n
		}
		
		return coord
	}
	
	static func parsePath(_ input: String) -> [HexDir] {
		let validDirs = Set<String>(HexDir.allCases.map({$0.rawValue}))
		
		var path = [HexDir]()
		var startOffset = 0
		while startOffset < input.count {
			let start = input.index(input.startIndex, offsetBy: startOffset)
			var end = input.index(input.startIndex, offsetBy: startOffset + 1)
			var subStr = String(input[start..<end])
			if validDirs.contains(subStr) {
				path.append(HexDir(rawValue: subStr)!)
				startOffset += 1
			}
			else {
				end = input.index(input.startIndex, offsetBy: startOffset + 2)
				subStr = String(input[start..<end])
				path.append(HexDir(rawValue: subStr)!)
				startOffset += 2
			}
		}
		
		// Rebuild path to check work
		let test = path.map({$0.rawValue}).joined()
		assert(input == test, "\(input) != \(test)")
		
		return path
	}
	
	static func readInputFile(named name:String, removingEmptyLines removeEmpty:Bool) -> [String] {
		var results = [String]()
		let b = Bundle.main
		//let b = inputBundle
		if let inputPath = b.path(forResource: name, ofType: "txt") {
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

enum HexTileColor: CaseIterable {
	case white
	case black
}

enum HexDir: String, CaseIterable {
	case ne = "ne"
	case nw = "nw"
	case se = "se"
	case sw = "sw"
	case e = "e"
	case w = "w"
}

struct HexCoord: Hashable, CustomStringConvertible {
	var description: String {
		return "[x: \(x), y: \(y)]"
	}
	
	static let CENTER = HexCoord(x: 0, y: 0)
	
	let x: Int
	let y: Int
	
	func neighbor(at dir: HexDir) -> HexCoord {
		var nx = x
		var ny = y
		let isEvenRow = y % 2 == 0
		
		switch dir {
		case .nw:
			nx = isEvenRow ? x - 1 : x
			ny = y + 1
		case .ne:
			nx = isEvenRow ? x : x + 1
			ny = y + 1
		case .sw:
			nx = isEvenRow ? x - 1 : x
			ny = y - 1
		case .se:
			nx = isEvenRow ? x : x + 1
			ny = y - 1
		case .w:
			nx = x - 1
		case .e:
			nx = x + 1
		}
		return HexCoord(x: nx, y: ny)
	}
	
	var allNeighbours: [HexCoord] {
		var neighbours = [HexCoord]()
		for dir in HexDir.allCases {
			neighbours.append(neighbor(at: dir))
		}
		return neighbours
	}
	
	var debugDescription: String {
		var dd = [String]()
		dd.append("\(neighbor(at: .nw)) \(neighbor(at: .ne))")
		dd.append("\(neighbor(at: .w)) \(neighbor(at: .e))")
		dd.append("\(neighbor(at: .sw)) \(neighbor(at: .se))")
		return dd.joined(separator: "\n")
	}
}
