import Foundation

public class Day6 {
	
	public static func solve() {
		let groups = readDeclarations()
		
		var yesCount = 0
		for group in groups {
			yesCount += group.yesAnswers.count
		}
		print("The total number of yes answers for all groups is \(yesCount)")
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
	
	var yesAnswers: Set<Character> {
		var answers = Set<Character>()
		for declaration in declarations {
			for character in declaration.code {
				answers.insert(character)
			}
		}
		return answers
	}
}

struct Declaration {
	let code: String
}
