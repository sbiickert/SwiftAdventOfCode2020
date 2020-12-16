import Foundation

public class Day16 {
	
	static let redef = "([a-z ]+): (\\d+)-(\\d+) or (\\d+)-(\\d+)"
	static var regex: NSRegularExpression?
	
	public static func solve() {
		if createRegularExpressions() == false {
			return
		}
		var input = readGroupedInputFile(named: "Day16_Input")
		let rules = parseRules(input[0])
		let myTicket = parseTicket(input[1][1]) // The first row is "your ticket:" label
		input[2].remove(at: 0) // Removing "nearby tickets:" label
		var otherTickets = [Ticket]()
		for inputLine in input[2] {
			otherTickets.append(parseTicket(inputLine))
		}

		//print(myTicket.values)
		print("My ticket is valid? \(myTicket.isValid(forRules: rules))")
		var errorRate = 0
		for ticket in otherTickets {
			for invalidValue in ticket.invalidValues(rules: rules) {
				errorRate += invalidValue
			}
		}
		print("Error rate: \(errorRate)")
		
		print(otherTickets.count)
		let validTickets = otherTickets.filter { $0.isValid(forRules: rules) }
		print(validTickets.count)

	}
	
	private static func parseRules(_ input: [String]) -> [FieldRule] {
		var rules = [FieldRule]()
		for line in input {
			let range = NSRange(location: 0, length: line.utf16.count)
			if let match = regex?.firstMatch(in: line, options: [], range: range) {
				if let rField = Range(match.range(at: 1), in: line),
				   let r1Low = Range(match.range(at: 2), in: line),
				   let r1High = Range(match.range(at: 3), in: line),
				   let r2Low = Range(match.range(at: 4), in: line),
				   let r2High = Range(match.range(at: 5), in: line)
				   {
					if let firstRangeLow = Int(line[r1Low]),
					   let firstRangeHigh = Int(line[r1High]),
					   let secondRangeLow = Int(line[r2Low]),
					   let secondRangeHigh = Int(line[r2High]) {
						let field = String(line[rField])
						let r1 = firstRangeLow...firstRangeHigh
						let r2 = secondRangeLow...secondRangeHigh
						rules.append(FieldRule(field: field, ranges: (r1, r2)))
					}
				}
			}
		}
		return rules
	}
	
	private static func parseTicket(_ input: String) -> Ticket {
		let inputStrings = input.components(separatedBy: ",")
		let inputValues = inputStrings.compactMap { Int( $0 ) }
		return Ticket(values: inputValues)
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
			regex = try NSRegularExpression(pattern: redef, options: [])
		} catch {
			print("Error creating regular expression.")
			return false
		}
		return true
	}
}

private struct FieldRule {
	let field: String
	let ranges: (ClosedRange<Int>, ClosedRange<Int>)
	
	func isValueInRanges(_ value: Int) -> Bool {
		return ranges.0.contains(value) || ranges.1.contains(value)
	}
}

private struct Ticket {
	let values: [Int]
	
	func isValid(forRules rules: [FieldRule]) -> Bool {
		return invalidValues(rules: rules).count == 0
	}
	
	func invalidValues(rules: [FieldRule]) -> [Int] {
		var invalidValues = [Int]()
		for value in values {
			var isValidForARule = false
			for rule in rules {
				if rule.isValueInRanges(value) {
					isValidForARule = true
					break
				}
			}
			if isValidForARule == false {
				invalidValues.append(value)
			}
		}
		return invalidValues
	}
}
