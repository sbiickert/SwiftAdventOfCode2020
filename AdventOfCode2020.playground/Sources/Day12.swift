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
		for instruction in instructions {
			//print(instruction)
			ship.move(instruction)
			//print(ship)
		}
		print("Ship ended up at x:\(ship.x) y:\(ship.y) and bearing: \(ship.bearing)")
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
		return "Ship x: \(x) y: \(y) b: \(bearing)"
	}
	
	var x: Int
	var y: Int
	// East is zero
	var bearing: Int
	
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
