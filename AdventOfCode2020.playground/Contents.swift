import Cocoa

//Day1.solveForTwo()
//Day1.solveForThree()
//Day2.solve()
//Day3.solve()
// Have refactored Days 1-3 to use the AOCUtil function to read lines
//Day4.solve()
//Day5.solve()
//Day6.solve()
// Using AOCUtil functions
//Day7.solve()

Day8.solve()

public class Day8 {
	static let redef = "([a-z]{3}) ([+-])([0-9]{1,})"
	static var regex: NSRegularExpression?

	public static func solve() {
		let input = AOCUtil.readInputFile(named: "Day8_Input", removingEmptyLines: true)
		if createRegularExpressions() == false {
			return
		}
		let instructions = parseInstructions(from: input)
		
		var ptr = 0
		var history = Set<Int>()
		var accumulated = 0
		
		while history.contains(ptr) == false {
			history.insert(ptr)
			let instruction = instructions[ptr]
			switch instruction {
			case .acc(let value):
				accumulated += value
				ptr += 1
			case .jmp(let value):
				ptr += value
			case .nop:
				ptr += 1
			}
		}
		
		print("The accumulated value is \(accumulated)")
	}
	
	static func parseInstructions(from input: [String]) -> [Instruction] {
		var instructions = [Instruction]()
		
		for line in input {
			let range = NSRange(location: 0, length: line.utf16.count)
			if let match = regex?.firstMatch(in: line, options: [], range: range) {
				if let rInst = Range(match.range(at: 1), in: line),
				   let rSign = Range(match.range(at: 2), in: line),
				   let rVal = Range(match.range(at: 3), in: line) {
					let inst = String(line[rInst])
					let sign = String(line[rSign])
					if var value = Int(line[rVal]) {
						if sign == "-" {
							value = -1 * value
						}
						switch inst {
						case "acc":
							instructions.append(Instruction.acc(value))
						case "jmp":
							instructions.append(Instruction.jmp(value))
						default:
							instructions.append(Instruction.nop)
						}
					}
				}
			}
		}
		return instructions
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

enum Instruction {
	case acc(Int)
	case jmp(Int)
	case nop
}
