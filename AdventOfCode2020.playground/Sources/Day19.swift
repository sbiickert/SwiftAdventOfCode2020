import Foundation

public class Day19 {

	private static var rules: Dictionary<String, [[String]]>!
	private static let charSetAB = CharacterSet(charactersIn: "ab")

	public static func solve(testing: Bool) {
		var input: [[String]]
		if testing {
			input = readGroupedInputFile(named: "Day19_Sample")
		}
		else {
			input = readGroupedInputFile(named: "Day19_Input")
		}
		
		rules = parseRules(from: input[0])
		//for id in rules.keys.sorted() {
		//	print(rules[id]!)
		//}
		
		print("Part 1: \(countMessages(messages: input[1]))")
		rules["8"] = [["42"], ["42", "8"]]
		rules["11"] = [["42", "31"], ["42", "11", "31"]]
		print("Part 2: \(countMessages(messages: input[1]))")
	}
	
	/*
	The following functions countMessages, matchRule and parseRules are a
	Swift translation of the Python solution found here:
	https://dev.to/qviper/advent-of-code-2020-python-solution-day-19-4p9d
	*/
	private static func countMessages(messages: [String]) -> Int {
		var total = 0
		for message in messages {
			let stack: [String] = rules["0"]!.first!.reversed()
			if matchRule(expr: message, stack: stack) {
				total += 1
			}
		}
		return total
	}
	
	private static func matchRule(expr: String, stack:[String]) -> Bool {
		//print("matchRule(expr: \(expr), stack: \(stack)")
		if stack.count > expr.count {
			return false
		}
		else if stack.count == 0 || expr.count == 0 {
			return stack.count == 0 && expr.count == 0
		}
		
		var mStack = stack
		let c = mStack.removeLast()
		if charSetAB.contains(c.unicodeScalars.first!) { // Is it a or b?
			if expr.first! == c.first! {
				var mExpr = expr
				mExpr.remove(at: mExpr.startIndex)
				return matchRule(expr: mExpr, stack: mStack)
			}
		}
		else {
			for rule in rules[c]! {
				var temp: [String] = mStack
				temp.append(contentsOf: rule.reversed())
				if matchRule(expr: expr, stack: temp) {
					return true
				}
			}
		}
		return false
	}
	
	private static func parseRules(from input: [String]) -> Dictionary<String, [[String]]> {

		var rules = Dictionary<String, [[String]]>()
		for line in input {
			let components = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
			let key = String(components[0])
			let value = components[1]
			if value.contains("a") || value.contains("b") {
				rules[key] = [[String(value.unicodeScalars.filter({charSetAB.contains($0)}))]]
			}
			else {
				let values = value.components(separatedBy: " | ")
				var ruleValues = [[String]]()
				for val in values {
					let opts: [String] = val.split(separator: " ", maxSplits: 10, omittingEmptySubsequences: true).map({String($0)})
					ruleValues.append(opts)
				}
				rules[key] = ruleValues
			}
		}
		return rules
	}
	
	static var inputBundle: Bundle {
		let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
		let bundleURL = URL(fileURLWithPath: "AoCInput.bundle", relativeTo: currentDirectoryURL)
		if let b = Bundle(url: bundleURL) {
			return b
		}
		return Bundle.main
	}

	static func readInputFile(named name:String, removingEmptyLines removeEmpty:Bool) -> [String] {
		var results = [String]()
		
		if let inputPath = inputBundle.path(forResource: name, ofType: "txt") {
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
