//
//  Day16.swift
//  AoC2020
//

import Foundation

class Day16: AoCSolution {
	override init() {
		super.init()
		day = 16
		self.name = "Ticket Translation"
		self.emptyLinesIndicateMultipleInputs = true
	}
	
	override func solve(_ input: AoCInput) -> AoCResult {
		super.solve(input)
		
		let (rules, myTicket, otherTickets) = parseInput(lines: input.textLines)
		
		let p1 = solvePartOne(tickets: otherTickets, rules: rules)
		
		let validTickets = otherTickets.filter { $0.isValid(given: rules) }
		
		let p2 = solvePartTwo(myTicket, others: validTickets, given: rules)
		
		return AoCResult(part1: "The ticket scanning error rate is \(p1)",
						 part2: "Product of departure values is \(p2)")
	}
	
	func solvePartOne(tickets: [Ticket], rules: [TicketRule]) -> Int {
		var allInvalidValues = [Int]()
		for ticket in tickets {
			allInvalidValues.append(contentsOf: ticket.invalidValues(given: rules))
		}
		let ticketScanningErrorRate = allInvalidValues.reduce(0, +)
		return ticketScanningErrorRate
	}
	
	func solvePartTwo(_ myTicket: Ticket, others otherTickets: [Ticket], given rules:[TicketRule]) -> Int {
		var possible = [Set<String>]()
		let fieldCount = myTicket.values.count
		
		// Start with all fields being possible
		for _ in 0..<fieldCount {
			possible.append(Set(rules.map({$0.name})))
		}
		
		// Process of elimination
		// Find rules that don't allow a ticket value at position i
		while possible.contains(where: {$0.count > 1}) {
			for i in 0..<fieldCount {
				for ticket in otherTickets {
					for rule in rules {
						if !rule.allows(ticket.values[i]) {
							possible[i].remove(rule.name)
						}
					}
				}
				// If this field has been determined, all others can't be it
				if possible[i].count == 1 {
					let fieldName = possible[i].first!
					for j in 0..<fieldCount {
						if i != j { possible[j].remove(fieldName)}
					}
				}
			}
		}
		
		var departureValues = [Int]()
		for (i, fieldName) in possible.compactMap( {$0.first} ).enumerated() {
			if fieldName.starts(with: "departure") {
				departureValues.append(myTicket.values[i])
			}
		}
		let product = departureValues.reduce(1, *)
		return product
	}
	
	func parseInput(lines: [String]) -> ([TicketRule], Ticket, [Ticket]) {
		// I modified the inputs to remove the empty lines between sections
		var rules = [TicketRule]()
		var myTicket: Ticket?
		var otherTickets = [Ticket]()
		for line in lines {
			if let m = line.firstMatch(of: /([\w\s]+): (\d+)-(\d+) or (\d+)-(\d+)/) {
				let name = String(m.1)
				let r0 = Int(String(m.2))!...Int(String(m.3))!
				let r1 = Int(String(m.4))!...Int(String(m.5))!
				let rule = TicketRule(name: name, ranges: (r0,r1))
				rules.append(rule)
			}
			else if let _ = line.firstMatch(of: /^[\d,]+$/) {
				let v = line.split(separator: ",").compactMap { Int($0) }
				let ticket = Ticket(values: v)
				if myTicket == nil {
					myTicket = ticket
				}
				else {
					otherTickets.append(ticket)
				}
			}
		}
		return (rules, myTicket!, otherTickets)
	}
}

struct TicketRule {
	let name: String
	let ranges: (ClosedRange<Int>, ClosedRange<Int>)
	
	func allows(_ value: Int) -> Bool {
		return ranges.0.contains(value) || ranges.1.contains(value)
	}
}

struct Ticket {
	let values: [Int]
	
	func invalidValues(given rules: [TicketRule]) -> [Int] {
		return values.filter { value in
			let valueCoveredByRules = rules.map { $0.allows(value) }
			return valueCoveredByRules.allSatisfy {$0 == false}
		}
	}
	
	func isValid(given rules: [TicketRule]) -> Bool {
		return self.invalidValues(given: rules).isEmpty
	}
}
