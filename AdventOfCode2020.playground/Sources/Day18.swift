import Foundation

public class Day18 {
	
	private static let parenRedef = "(\\([0-9+* ]+\\))"
	private static var parenRegex: NSRegularExpression?
	
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
		
		// At this point, there are no more parentheses
		// Just digit(s), operator,  digit(s), operator...  digit(s)
		let chars = Array(mutableInput)
		
		// Consolidate multiple digits into single strings
		var eqComponents = [String]()
		var component = ""
		for char in chars {
			if "+*".contains(char) {
				// Push the number
				eqComponents.append(component)
				// Push the operator
				eqComponents.append("\(char)")
				// Get ready for next number
				component = ""
			}
			else {
				component.append(char)
			}
		}
		eqComponents.append(component)

		var value = Int(String(eqComponents.remove(at: 0)))!
		
		// Now it's operator, number, operator, number
		for i in stride(from: 0, to: eqComponents.count-1, by: 2) {
			let op = eqComponents[i]
			let operand = Int(eqComponents[i+1])!
			if op == "+" {
				value += operand
			}
			else if op == "*" {
				value *= operand
			}
			else {
				print("Unexpected operator: \(op)")
			}
		}
		//print("Answer: \(value)")
		return value
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
		} catch {
			print("Error creating regular expression.")
			return false
		}
		return true
	}
}
