import Foundation

public class Day19 {
	private static let complexRedef = "([0-9]+): ([0-9 \\|]+)"
	private static var complexRegex: NSRegularExpression?
	private static let simpleRedef = "([0-9]+): \"([ab])\""
	private static var simpleRegex: NSRegularExpression?

	private static var rules: Dictionary<Int, MatchRule>!
	private static var patterns = [String]()
	
	public static func solve(testing: Bool) {
		if createRegularExpressions() == false {
			return
		}
		var input: [[String]]
		if testing {
			input = readGroupedInputFile(named: "Day19_Sample")
		}
		else {
			input = readGroupedInputFile(named: "Day19_Input")
		}
		
		input = [["0: 4 1 5","1: 2 3 | 3 2","2: 4 4 | 5 5","3: 4 5 | 5 4","4: \"a\"","5: \"b\""]]
		rules = parseRules(from: input[0])
		for id in rules.keys.sorted() {
			print(rules[id]!)
		}
		
		patterns = buildPatterns(forRuleID: 0)
		printPatterns()
		
//		var matches = [String]()
//		for message in input[1] {
//			if doesMatch(message: message, forRuleID: 0) {
//				matches.append(message)
//				print("✅ \(message)")
//			}
//		}
//		print(matches.count)
	}
	
	private static func buildPatterns(forRuleID ruleID: Int) -> [String] {
		print("buildPatterns forRuleID \(ruleID))")
		guard let rule = rules[ruleID] else {
			print("Could not find rule with id \(ruleID)")
			return []
		}
		var values = [String]()
		if let value = rule.value {
			values.append(value)
		}
		else if let options = rule.subRuleIDs {
			if options.count == 1 {
				for j in 0..<options[0].count {
					values.append(contentsOf: buildPatterns(forRuleID: options[0][j]))
				}
			}
			else {
				var values0 = [String]()
				for j in 0..<options[0].count {
					values0.append(contentsOf: buildPatterns(forRuleID: options[0][j]))
				}
				var values1 = [String]()
				for j in 0..<options[1].count {
					values1.append(contentsOf: buildPatterns(forRuleID: options[1][j]))
				}
				var valueSet = Set<String>()
				for i in values0 {
					for j in values1 {
						valueSet.insert(i+j)
					}
				}
				values = Array(valueSet)
			}
		}
		return values
	}
	
	private static func printPatterns() {
		for (i, pattern) in patterns.enumerated() {
			print("[\(i)] \(pattern)")
		}
	}
	
	private static func parseRules(from input: [String]) -> Dictionary<Int, MatchRule> {
		var rules = Dictionary<Int, MatchRule>()
		for line in input {
			let range = NSRange(location: 0, length: line.utf16.count)
			// Matching for rules with sub rules (e.g. "4 1 5" or "4 5 | 5 4")
			if let match = complexRegex?.firstMatch(in: line, options: [], range: range) {
				if let rID = Range(match.range(at: 1), in: line),
				   let rDef = Range(match.range(at: 2), in: line) {
					if let id = Int(String(line[rID])) {
						let def = String(line[rDef])
						var subRuleIDs = [[Int]]()
						let opts = def.components(separatedBy: "|")
						for opt in opts {
							let subIDs = opt.components(separatedBy: " ").compactMap({Int($0)})
							subRuleIDs.append(subIDs)
						}
						let rule = MatchRule(id: id, value: nil, subRuleIDs: subRuleIDs)
						rules[id] = rule
					}
				}
			}
			// Matching for rules that define a value, like "a"
			else if let match = simpleRegex?.firstMatch(in: line, options: [], range: range) {
				if let rID = Range(match.range(at: 1), in: line),
				   let rVal = Range(match.range(at: 2), in: line) {
					if let id = Int(String(line[rID])) {
						let val = String(line[rVal])
						let rule = MatchRule(id: id, value: val, subRuleIDs: nil)
						rules[id] = rule
					}
				}
			}
		}
		return rules
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
			complexRegex = try NSRegularExpression(pattern: complexRedef, options: [])
			simpleRegex = try NSRegularExpression(pattern: simpleRedef, options: [])
		} catch {
			print("Error creating regular expression.")
			return false
		}
		return true
	}
	
}

private struct MatchRule: CustomStringConvertible {
	var description: String {
		return "Rule \(id), value: \(value ?? ""), subRules: \(subRuleIDs ?? [[]])"
	}
	
	let id: Int
	let value: String?
	
	// First level of array: options
	// Second level of array: list of ids in that option
	// 17 28 | 67 77 -> [[17, 28], [67, 77]]
	// 99 100 -> [[99, 100]]
	let subRuleIDs: [[Int]]?
}
