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
		
		let sacks = input.textLines.map { Haversack(defn: $0) }
		
		let p1 = solvePartOne(sacks)
		
		return AoCResult(part1: "The number of colors that can contain shiny gold is \(p1)",
						 part2: "sync")
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
