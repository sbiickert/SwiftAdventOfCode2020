import Foundation

public class Day18 {
	
	private static let parenRedef = "(\\([0-9+* ]+\\))"
	private static var parenRegex: NSRegularExpression?
	private static let addRedef = "(\\d+)\\+(\\d+)"
	private static var addRegex: NSRegularExpression?
	private static let multRedef = "(\\d+)\\*(\\d+)"
	private static var multRegex: NSRegularExpression?

	public static func solve(testing: Bool) {
		if createRegularExpressions() == false {
			return
		}
		
		//let input = ["1 + (2 * 3) + (4 * (5 + 6))"]
		let allInput = readGroupedInputFile(named: "Day18_Input")
		var input = allInput[0]
		if !testing {
			input = allInput[1]
		}
		
		var answers = [Int]()
		for line in input {
			let answer = solveEquation(line)
			answers.append(answer)
			print("\(line) = \(answer)")
		}
		print("All Answers: \(answers)")
		print("Sum: \(answers.reduce(0, +))")
	}
	
	static func solveEquation(_ input:String) -> Int {
		// Use recursion to solve parenthetical expressions
		var mutableInput = input.replacingOccurrences(of: " ", with: "")
		//print("solveEquation \(mutableInput)")
		
		var range = NSRange(location: 0, length: mutableInput.utf16.count)
		while let match = parenRegex?.firstMatch(in: mutableInput, options: [], range: range) {
			if let rParens = Range(match.range(at: 1), in: mutableInput) {
				// rParens includes the parens
				// need to shrink by 1
				let idxS = mutableInput.index(rParens.lowerBound, offsetBy: 1)
				let idxE = mutableInput.index(rParens.upperBound, offsetBy: -1)

				let parenExpression = String(mutableInput[idxS..<idxE])
				let expressionSolution = solveEquation(parenExpression)
				// use rParens to replace with the result, stripping parens with it
				mutableInput.replaceSubrange(rParens, with: String(expressionSolution))
			}
			//print("solveEquation \(mutableInput)")
			range = NSRange(location: 0, length: mutableInput.utf16.count)
		}
		
		// At this point, there are no more parentheses.
		// Adds have precedence, do them
		for (op, regex) in [("+", addRegex), ("*", multRegex)] {
			range = NSRange(location: 0, length: mutableInput.utf16.count)
			while let match = regex?.firstMatch(in: mutableInput, options: [], range: range) {
				if let rExpr = Range(match.range(at: 0), in: mutableInput),
				   let rOperand1 = Range(match.range(at: 1), in: mutableInput),
				   let rOperand2 = Range(match.range(at: 2), in: mutableInput) {
					if let operand1 = Int(mutableInput[rOperand1]),
					   let operand2 = Int(mutableInput[rOperand2]) {
						var result = ""
						if op == "+" {
							result = String(operand1 + operand2)
						}
						else {
							result = String(operand1 * operand2)
						}
						mutableInput.replaceSubrange(rExpr, with: result)
					}
				}
				range = NSRange(location: 0, length: mutableInput.utf16.count)
			}
		}
		
		// Should only be string of digits left
		//print("Answer: \(mutableInput)")
		return Int(mutableInput)!
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
	
	static func createRegularExpressions() -> Bool {
		do {
			parenRegex = try NSRegularExpression(pattern: parenRedef, options: [])
			addRegex = try NSRegularExpression(pattern: addRedef, options: [])
			multRegex = try NSRegularExpression(pattern: multRedef, options: [])
		} catch {
			print("Error creating regular expression.")
			return false
		}
		return true
	}
}
