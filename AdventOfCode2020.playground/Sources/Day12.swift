import Foundation

public class Day12 {
	static let redef = "([FRLNEWS])([0-9]{1,})"
	static var regex: NSRegularExpression?

	public static func solve() {
		if createRegularExpressions() == false {
			return
		}
		//let input = ["F10", "N3", "F7", "R90", "F11"] // Example
		//let input = ["W5","F63","S1","L90","F89","W4","F45","W4","F71","R90","S4"] //More testing
		let input = readInputFile(named: "Day12_Input", removingEmptyLines: true)
		let instructions = parseInstructions(from: input)
		var ship = Ship(x: 0, y: 0, bearing: 0)
		ship.waypoint = (10, 1)
		print("Ship started at \(ship)")
		for instruction in instructions {
			//print(instruction)
			//ship.move(instruction)
			ship.navigate(instruction)
			//print(ship)
		}
		print("Ship ended at \(ship)")
		print("The Manhattan distance is \(abs(ship.x) + abs(ship.y))")
	}
	
	static func parseInstructions(from input: [String]) -> [PilotingInstruction] {
		var instructions = [PilotingInstruction]()
		
		for line in input {
			let range = NSRange(location: 0, length: line.utf16.count)
			if let match = regex?.firstMatch(in: line, options: [], range: range) {
				if let rCmd = Range(match.range(at: 1), in: line),
				   let rVal = Range(match.range(at: 2), in: line) {
					let cmd = String(line[rCmd])
					if let value = Int(line[rVal]) {
						switch cmd {
						case "F":
							instructions.append(PilotingInstruction.forward(value))
						case "L":
							instructions.append(PilotingInstruction.left(value))
						case "R":
							instructions.append(PilotingInstruction.right(value))
						case "N":
							instructions.append(PilotingInstruction.north(value))
						case "E":
							instructions.append(PilotingInstruction.east(value))
						case "W":
							instructions.append(PilotingInstruction.west(value))
						case "S":
							instructions.append(PilotingInstruction.south(value))
						default:
							print("Could not parse instruction \(line)")
						}
					}
				}
			}
		}
		return instructions
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
	
	static func createRegularExpressions() -> Bool {
		do {
			regex = try NSRegularExpression(pattern: redef, options: [])
		} catch {
			print("Error creating regular expression.")
			return false
		}
		return true
	}
}

struct Ship: CustomStringConvertible {
	var description: String {
		return "Ship x: \(x) y: \(y) b: \(bearing) waypoint: (x: \(waypoint.x), y: \(waypoint.y))"
	}
	
	var x: Int
	var y: Int
	// East is 0, South is 90
	var bearing: Int
	var waypoint: (x:Int, y:Int) = (0,0)
	
	mutating func move(_ instr: PilotingInstruction) {
		switch instr {
		case .forward(let value):
			switch bearing {
			case 0: // east
				x += value
			case 90: // south
				y -= value
			case 180: // west
				x -= value
			default: // north
				y += value
			}
		case .left(let value):
			bearing -= value
		case .right(let value):
			bearing += value
		case .north(let value):
			y += value
		case .south(let value):
			y -= value
		case .east(let value):
			x += value
		case .west(let value):
			x -= value
		}
		// Keep bearings within 0 to 270
		while bearing > 270 {
			bearing -= 360
		}
		while bearing < 0 {
			bearing += 360
		}
	}
	
	mutating func navigate(_ instr: PilotingInstruction) {
		switch instr {
		case .forward(let count):
			// Move to waypoint count times
			x += waypoint.x * count
			y += waypoint.y * count
			
		case .left(let value):
			waypoint = turnWaypointRight(waypoint, by: value * -1)
		case .right(let value):
			waypoint = turnWaypointRight(waypoint, by: value)
			
		case .north(let value):
			waypoint.y += value
		case .south(let value):
			waypoint.y -= value
		case .east(let value):
			waypoint.x += value
		case .west(let value):
			waypoint.x -= value
		}
	}
	
	func turnWaypointRight(_ waypoint: (x:Int, y:Int), by angle:Int) -> (x: Int, y: Int) {
		var turnAngle = angle
		var returnWaypoint = waypoint
		if angle < 0 {
			turnAngle += 360
		}
		
		switch turnAngle {
		case 90:
			returnWaypoint.x = waypoint.y
			returnWaypoint.y = waypoint.x * -1
		case 180:
			returnWaypoint.x = waypoint.x * -1
			returnWaypoint.y = waypoint.y * -1
		case 270:
			returnWaypoint.x = waypoint.y * -1
			returnWaypoint.y = waypoint.x
		default:
			print("turn 0")
		}
		return returnWaypoint
	}
}

enum PilotingInstruction {
	case forward(Int)
	case left(Int)
	case right(Int)
	case north(Int)
	case east(Int)
	case west(Int)
	case south(Int)
}
