import Foundation

public class Day8 {
	static let redef = "([a-z]{3}) ([+-])([0-9]{1,})"
	static var regex: NSRegularExpression?

	public static func solve() {
		let input = readInputFile(named: "Day8_Input", removingEmptyLines: true)
		if createRegularExpressions() == false {
			return
		}
		let instructions = parseInstructions(from: input)
		
		// Work backwards through the executed instructions until one change results in success
		// This is the set of instructions leading to the infinite loop
		let codePath = run(instructions)
		var results = codePath

		for index in stride(from: codePath.count-2, to: 0, by: -1)
		{
			if results.last! >= instructions.count {
				print("Winner! Modified instruction at \(index+1)")
				break
			}
			else {
				var modifiedInstructions = instructions // Copy the original
				let instruction = instructions[codePath[index]]

				switch instruction {
				case .jmp(let value):
					let modified = Instruction.nop(value)
					modifiedInstructions[codePath[index]] = modified
					results = run(modifiedInstructions)
				case .nop(let value):
					let modified = Instruction.jmp(value)
					modifiedInstructions[codePath[index]] = modified
					results = run(modifiedInstructions)
				default:
					let _ = 1 // This was an acc. Do nothing.
				}
				
			}
		}
	}
	
	static func run(_ instructions: [Instruction]) -> [Int] {
		var ptr = 0
		var history = [Int]()
		var accumulated = 0
		
		while true {
			history.append(ptr)
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
			if history.contains(ptr) {
				print("Infinite loop at \(ptr). Exiting.")
//				for step in history {
//					print("\(step)")
//				}
				break
			}
			if ptr < 0 {
				print("ptr less than zero. Exiting.")
				break
			}
			if ptr >= instructions.count {
				print("ptr past end of instructions. Exiting.")
				break
			}
		}
		
		history.append(ptr) // Last ptr position
		print("The accumulated value is \(accumulated)")
		return history
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
							instructions.append(Instruction.nop(value))
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

enum Instruction {
	case acc(Int)
	case jmp(Int)
	case nop(Int)
}
