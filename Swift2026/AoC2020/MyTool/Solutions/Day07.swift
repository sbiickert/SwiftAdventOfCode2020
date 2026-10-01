//
//  Day07.swift
//  AoC2020
//

import Foundation

class Day07: AoCSolution {
	override init() {
		super.init()
		day = 07
		self.name = "Handy Haversacks"
		self.emptyLinesIndicateMultipleInputs = true
	}
	
	override func solve(_ input: AoCInput) -> AoCResult {
		super.solve(input)
		
		var sacks = input.allInputGroups[0].map { Haversack(defn: $0) }
		let p1 = solvePartOne(sacks)
		
		if input.fileName.contains(/test/) {
			sacks = input.allInputGroups[1].map { Haversack(defn: $0) }
		}
		
		let sacksLookup = Dictionary(uniqueKeysWithValues: sacks.map { ($0.color, $0) })
		let p2 = countBags(from: "shiny gold", in: sacksLookup) - 1 // Don't count the shiny gold one
		
		return AoCResult(part1: "The number of colors that can contain shiny gold is \(p1)",
						 part2: "The number of bags inside shiny gold is \(p2)")
	}
	
	func solvePartOne(_ sacks: [Haversack]) -> Int {
		let containers = findContainers(sacks)
		
		var colorsThatCanContainShinyGold = Set<String>()
		
		var search = Set(["shiny gold"])
		while !search.isEmpty {
			var newSearch = Set<String>()
			for color in search {
				if let c = containers[color] {
					colorsThatCanContainShinyGold = colorsThatCanContainShinyGold.union(c)
					newSearch = newSearch.union(c)
				}
			}
			search = newSearch
		}

		return colorsThatCanContainShinyGold.count
	}
	
	func countBags(from color: String, in sacks: Dictionary<String, Haversack>) -> Int {
		let sack = sacks[color]!
		var count = 1
		
		for rule in sack.rules {
			count += rule.value * countBags(from: rule.key, in: sacks)
		}
		
		return count
	}
	
	func findContainers(_ sacks: [Haversack]) -> Dictionary<String, [String]> {
		var result = Dictionary<String, [String]>()
		
		for sack in sacks {
			for rule in sack.rules {
				var temp = result[rule.key, default: []]
				temp.append(sack.color)
				result[rule.key] = temp
			}
		}
		
		return result
	}
}

struct Haversack {
	let color: String
	let rules: Dictionary<String, Int>
	
	init(defn: String) {
		let parts = defn.split(separator: " bags contain ")
		color = String(parts.first!)
		let contents = parts.last!.split(separator: ", ")
		if contents.first! == "no other bags." {
			rules = Dictionary()
		}
		else {
			rules = Dictionary(uniqueKeysWithValues: contents.map({ str in
				let m = str.firstMatch(of: /(\d+) ([\s\w]+) bag/)!
				return ( String(m.2), Int(String(m.1))! )
			}))
		}
	}
}
