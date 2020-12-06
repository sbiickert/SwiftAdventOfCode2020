import Foundation

public class Day6 {
	
	public static func solve() {
		let groups = readDeclarations()
		
		var yesAnyCount = 0
		for group in groups {
			yesAnyCount += group.yesAnswersAny.count
		}
		print("The total number of yes answers for all groups is \(yesAnyCount)")
		
		var yesAllCount = 0
		for group in groups {
			yesAllCount += group.yesAnswersAll.count
		}
		print("The total number of questions with all members answering yes for all groups is \(yesAllCount)")
	}
	
	static func readDeclarations() -> [Group] {
		var groups = [Group]()
		if let inputPath = Bundle.main.path(forResource: "Day6_Input", ofType: "txt") {
			do {
				let input = try String(contentsOfFile: inputPath)
				let lines = input.components(separatedBy: "\n")
				// Start reading declarations. When empty line is hit, wrap into a Group
				var builder = [Declaration]()
				for line in lines {
					if line.count > 0 {
						builder.append(Declaration(code: line))
					}
					else {
						groups.append(Group(declarations: builder))
						builder = [Declaration]()
					}
				}
			} catch {
				
			}
		}
		return groups
	}
}

struct Group {
	let declarations: [Declaration]
	
	var yesAnswersAny: Set<Character> {
		var answers = Set<Character>()
		for declaration in declarations {
			for character in declaration.code {
				answers.insert(character)
			}
		}
		return answers
	}
	
	var yesAnswersAll: Set<Character> {
		var allAnswers = Set<Character>()
		for (index, declaration) in declarations.enumerated() {
			if index == 0 {
				allAnswers = declaration.codeSet
			}
			else {
				let answers = declaration.codeSet
				allAnswers.formIntersection(answers)
			}
		}
		return allAnswers
	}
}

struct Declaration {
	let code: String
	
	var codeSet: Set<Character> {
		var chars = Set<Character>()
		for char in code {
			chars.insert(char)
		}
		return chars
	}
}
