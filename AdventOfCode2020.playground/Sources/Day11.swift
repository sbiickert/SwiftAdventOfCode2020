import Foundation

public class Day11 {
	public static func solve() {
		let input = readInputFile(named: "Day11_Input", removingEmptyLines: true)
		let waitingArea = WaitingArea(text: input)
		//print("\(waitingArea)\nempty seats: \(waitingArea.occupiedSeatCount)")
		var seatHistory = [waitingArea.occupiedSeatCount]
		var iterCount = 1
		while true {
			print("Iteration \(iterCount)")
			iterate(waitingArea, maxTolerableNeighbours: 5)
			seatHistory.insert(waitingArea.occupiedSeatCount, at: 0)
			if seatHistory.count >= 3 && seatHistory[0] == seatHistory[1] && seatHistory[1] == seatHistory[2] {
				break
			}
			iterCount += 1
			//print("\(waitingArea)\noccupied seats: \(waitingArea.occupiedSeatCount)")
		}
		print(seatHistory)
		print("\(waitingArea)\noccupied seats: \(waitingArea.occupiedSeatCount)")
	}
	
	static func iterate(_ waitingArea: WaitingArea, maxTolerableNeighbours: Int) {
		var newMap = waitingArea.locations
		for x in stride(from: 0, to: waitingArea.width, by: 1) {
			for y in stride(from: 0, to: waitingArea.length, by: 1) {
				let l = waitingArea.location(x: x, y: y)
				if l.isSeat {
					let occupiedNeighbours = waitingArea.countOccupiedAdjacentSeats(x: x, y: y, usingLineOfSight: true)
					if l.desc == .emptySeat && occupiedNeighbours == 0 {
						newMap[y][x] = Location(desc: .occupiedSeat)
					}
					else if l.desc == .occupiedSeat && occupiedNeighbours >= maxTolerableNeighbours {
						newMap[y][x] = Location(desc: .emptySeat)
					}
				}
			}
		}
		waitingArea.locations = newMap
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
}

class WaitingArea: CustomStringConvertible {
	var description: String {
		var strings = [String]()
		for row in _locations {
			let rowDescs = row.map({$0.desc.rawValue})
			let rowString = rowDescs.joined(separator: "")
			strings.append(rowString)
		}
		return strings.joined(separator: "\n")
	}
	
	init(text: [String]) {
		_locations = [[Location]]()
		for line in text {
			var row = [Location]()
			for col in line {
				row.append(Location(desc: Location.Desc.from(char: String(col))))
			}
			_locations.append(row)
		}
	}
	
	private var _locations: [[Location]]
	
	var locations: [[Location]] {
		get {
			return _locations
		}
		set {
			_locations = newValue
		}
	}
	
	var width: Int {
		return _locations[0].count
	}
	var length: Int {
		return _locations.count
	}
	
	func location(x: Int, y: Int) -> Location {
		guard x >= 0 && x < width && y >= 0 && y < length else {
			//print("Asked for location at invalid coord set \(x), \(y)")
			return Location.wall
		}
		return _locations[y][x]
	}
	
	func getAdjacentLocations(x: Int, y: Int, usingLineOfSight: Bool) -> [Location] {
		guard location(x: x, y: y).desc != Location.Desc.inaccessible else {
			return [Location.wall]
		}
		if usingLineOfSight {
			let vectors: [(Int, Int)] = [(-1, -1), (0, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (0, 1), (1, 1)]
			var adjacentLocations = [Location]()
			for v in vectors {
				var coords: (x:Int, y:Int) = (x, y)
				var neighbour = Location(desc: .floor)
				while neighbour.desc == .floor {
					coords.x += v.0
					coords.y += v.1
					neighbour = location(x: coords.x, y: coords.y)
				}
				adjacentLocations.append(neighbour)
			}
			return adjacentLocations
		}
		else {
			return [
				location(x: x-1, y: y-1), location(x: x+0, y: y-1), location(x: x+1, y: y-1),
				location(x: x-1, y: y+0), 							location(x: x+1, y: y+0),
				location(x: x-1, y: y+1), location(x: x+0, y: y+1), location(x: x+1, y: y+1)
			]
		}
	}
	
	func countOccupiedAdjacentSeats(x: Int, y: Int, usingLineOfSight los: Bool) -> Int {
		let neighbours = getAdjacentLocations(x: x, y: y, usingLineOfSight: los)
		var count = 0
		assert(neighbours.count == 8)
		for loc in neighbours {
			if loc.desc == .occupiedSeat {
				//print("Found occupied seat at \(x), \(y)")
				count += 1
			}
		}
		return count
	}
	
	var occupiedSeatCount: Int {
		var count = 0
		for row in _locations {
			for col in row {
				if col.desc == .occupiedSeat {
					count += 1
				}
			}
		}
		return count
	}
}

struct Location {
	static let wall = Location(desc: Location.Desc.inaccessible)
	
	enum Desc: String {
		case emptySeat = "L"
		case occupiedSeat = "#"
		case floor = "."
		case inaccessible = "X"
		
		static func from(char: String) -> Location.Desc {
			switch char {
			case "L":
				return Desc.emptySeat
			case "#":
				return Desc.occupiedSeat
			case ".":
				return Desc.floor
			default:
				return Desc.inaccessible
			}
		}
		var isSeat: Bool {
			return self == Desc.occupiedSeat || self == Desc.emptySeat
		}
	}
	
	let desc: Desc
	var isSeat: Bool {
		return self.desc.isSeat
	}
}
