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
		
		//let validTickets = otherTickets.filter { $0.isValid(given: rules) }
		
		return AoCResult(part1: "The ticket scanning error rate is \(p1)", part2: "sync")
	}
	
	func solvePartOne(tickets: [Ticket], rules: [TicketRule]) -> Int {
		var allInvalidValues = [Int]()
		for ticket in tickets {
			let invalidValues = ticket.invalidValues(given: rules)
			allInvalidValues.append(contentsOf: invalidValues)
		}
		let ticketScanningErrorRate = allInvalidValues.reduce(0, +)
		return ticketScanningErrorRate
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
}

struct Ticket {
	let values: [Int]
	
	func invalidValues(given rules: [TicketRule]) -> [Int] {
		return values.filter { value in
			let valueCoveredByRules = rules.map {
				$0.ranges.0.contains(value) || $0.ranges.1.contains(value)
			}
			return valueCoveredByRules.allSatisfy {$0 == false}
		}
	}
	
	func isValid(given rules: [TicketRule]) -> Bool {
		let valuesCovered = values.map { value in
			let valueCoveredByRules = rules.map {
				$0.ranges.0.contains(value) || $0.ranges.1.contains(value)
			}
			return valueCoveredByRules.contains(where: {$0}) // value was covered by a rule
		}
		return !valuesCovered.contains(where: {$0 == false})
	}
}
