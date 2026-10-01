//
//  Day06.swift
//  AoC2020
//

import Foundation

class Day06: AoCSolution {
	override init() {
		super.init()
		day = 06
		self.name = "Custom Customs"
		self.emptyLinesIndicateMultipleInputs = false
	}
	
	override func solve(_ input: AoCInput) -> AoCResult {
		super.solve(input)
		
		let answers = input.allInputGroups.map { GroupAnswers(defn: $0) }
		
		let p1 = answers.map({$0.questionsSomeoneAnswered.count}).reduce(0, +)
		let p2 = answers.map({$0.questionsEveryoneAnswered.count}).reduce(0, +)
		
		return AoCResult(part1: "The count of questions someone answered is \(p1)",
						 part2: "The count of questions everyone answered is \(p2)")
	}
}

struct GroupAnswers {
	let eachAnswers: [Set<String>]
	
	init(defn: [String]) {
		eachAnswers = defn.map({ line in
			Set(line.map {String($0)})
		})
	}

	var questionsSomeoneAnswered: Set<String> {
		return eachAnswers.reduce(eachAnswers.first!, {$0.union($1)})
	}

	var questionsEveryoneAnswered: Set<String> {
		return eachAnswers.reduce(eachAnswers.first!, {$0.intersection($1)})
	}
}
