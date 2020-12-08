import Foundation

public class Day7 {
	static let redefContainsNothing = "^([\\w\\s]+) bags contain no"
	static let redefContainsSomething = "([\\w\\s]+) bags contain ([^n][^\\.]+)\\."
	static let redefNumberAndColor = "(\\d{1,}) ([ \\w]+) bag"
	
	static var reCN: NSRegularExpression?
	static var reCS: NSRegularExpression?
	static var reNC: NSRegularExpression?

	static var rules = [Rule]()
	
	public static func solve() {
		let input = readInputFile(named: "Day7_Input", removingEmptyLines: true)
		if createRegularExpressions() {
			rules = buildRules(from: input)
						
			// Need to recurse here.
			var containingColors = Set<String>()
			containingColors = findColorsContaining(color: "shiny gold", found: containingColors)
			
			print("Total number of colors containing shiny gold is \(containingColors.count)")
			
			let goldRule = rules.filter({$0.color == "shiny gold"}).first!
			var bagCount = countBagsContained(by: goldRule, count: 0)
			
			print("Total number of bags contained by shiny gold is \(bagCount)")
		}
	}
	
	static func countBagsContained(by rule: Rule, count:Int) -> Int {
		var mutableCount = count
		print("> Finding bags contained by \(rule.color)")
		for containedQuantity in rule.contents {
			let containedRule = findRule(for: containedQuantity.color)
			print("\(containedQuantity.number) \(containedQuantity.color) is/are contained in \(rule.color)")
			let foundInContained = countBagsContained(by: containedRule, count: 0)
			mutableCount += containedQuantity.number * (1 + foundInContained)
		}
		print("< \(mutableCount)")
		return mutableCount
	}

	static func findColorsContaining(color: String, found: Set<String>) -> Set<String> {
		var mutableFound = found
		//print("> Finding rules containing \(color)")
		for containingRule in rules.filter({ $0.contains(color: color)}) {
			if mutableFound.contains(containingRule.color) == false {
				//print("\(color) is contained in \(containingRule)")
				mutableFound.insert(containingRule.color)
				mutableFound = findColorsContaining(color:containingRule.color, found: mutableFound)
			}
			//else {
				//print("Already found color \(containingRule.color)")
			//}
		}
		//print("<")
		return mutableFound
	}
	
	static func buildRules(from input:[String]) -> [Rule] {
		var rules = [Rule]()
		
		for line in input {
			var color = ""
			var contents = [Quantity]()
			
			let range = NSRange(location: 0, length: line.utf16.count)
			// Does the line tell us a bag contains no others?
			if let match = reCN?.firstMatch(in: line, options: [], range: range) {
				// Get the color of the bag
				if let rColor = Range(match.range(at: 1), in: line) {
					color = String(line[rColor])
				}
			}
			// Does the line tell us a bag contains others?
			else if let match = reCS?.firstMatch(in: line, options: [], range: range) {
				// Get the color of the bag
				if let rColor = Range(match.range(at: 1), in: line) {
					color = String(line[rColor])
				}

				// Get the contents
				var strContents = ""
				if let rContents = Range(match.range(at: 2), in: line) {
					strContents = String(line[rContents])
					//print(strContents)
				}

				// Parse all contents
				let cRange = NSRange(location: 0, length: strContents.utf16.count)
				if let matches = reNC?.matches(in: strContents, options: [], range: cRange) {
					for match in matches {
						// Number of bags
						if let rNum = Range(match.range(at: 1), in: strContents),
						   let rColor = Range(match.range(at: 2), in: strContents) {
							let color = String(strContents[rColor])
							let number = Int(strContents[rNum])!
							let q = Quantity(color: color, number: number)
							contents.append(q)
						}
					}
				}
			}
			let rule = Rule(color: color, contents: contents)
			rules.append(rule)
		}
		print("There are \(rules.count) rules.")
		return rules
	}
	
	static func findRule(for color:String) -> Rule {
		return rules.filter({$0.color == color}).first!
	}

	static func createRegularExpressions() -> Bool {
		do {
			reCN = try NSRegularExpression(pattern: redefContainsNothing, options: [])
			reCS = try NSRegularExpression(pattern: redefContainsSomething, options: [])
			reNC = try NSRegularExpression(pattern: redefNumberAndColor, options: [])
		} catch {
			print("Error creating regular expressions.")
			return false
		}
		return true
	}
	
	public static func readInputFile(named name:String, removingEmptyLines removeEmpty:Bool) -> [String] {
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

struct Rule: CustomStringConvertible, Hashable {
	static func == (lhs: Rule, rhs: Rule) -> Bool {
		lhs.color == rhs.color
	}
	
	var description: String {
		let strArray = contents.map { $0.description }
		let s = strArray.joined(separator: ", ")
		return "Rule: color \(color) -> \(s)"
	}
	
	let color: String
	let contents: [Quantity]
	
	func contains(color: String) -> Bool {
		return contents.filter({ $0.color == color }).count > 0
	}
	
	var totalBags: Int {
		var total = 0
		for quantity in contents {
			total += quantity.number
		}
		return total
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(color)
	}
}

struct Quantity: CustomStringConvertible {
	var description: String {
		return "[\(number), \(color)]"
	}
	
	let color: String
	let number: Int
}
