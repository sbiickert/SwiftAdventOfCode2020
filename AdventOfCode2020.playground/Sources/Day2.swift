import Foundation

public class Day2 {
	public static func solve() {
		let entries = readPasswordFile()
		var validCount = 0
		for entry in entries {
			if entry.isValid() {
				validCount += 1
			}
		}
		print("There were \(validCount) valid entries.")
	}

	static func readPasswordFile() -> [PasswordEntry] {
		var passwordInfo = [PasswordEntry]()
		if let inputPath = Bundle.main.path(forResource: "Day2_Input", ofType: "txt") {
			do {
				let input = try String(contentsOfFile: inputPath)
				let strEntries = input.components(separatedBy: "\n")
				let regex = try NSRegularExpression(pattern: "(\\d+)-(\\d+) (\\w): (\\w+)", options: [])
				
				passwordInfo = strEntries.compactMap { strEntry in
					// Example strEntry: 2-6 r: frxrrrfjnmr
					// {min}-{max} {char}: {password}
					let range = NSRange(location: 0, length: strEntry.utf16.count)
					if let match = regex.firstMatch(in: strEntry, options:[], range: range) {
						if let rMin = Range(match.range(at: 1), in: strEntry),
						   let rMax = Range(match.range(at: 2), in: strEntry),
						   let rChar = Range(match.range(at: 3), in: strEntry),
						   let rPwd = Range(match.range(at: 4), in: strEntry) {
							if let character = String(strEntry[rChar]).first {
								let pr = PasswordRule(character: character,
													  min: Int(strEntry[rMin]) ?? 0,
													  max: Int(strEntry[rMax]) ?? 0)
								let pe = PasswordEntry(rule: pr, password: String(strEntry[rPwd]))
								if pr.min > pr.max {
									return nil
								}
								return pe
							}
						}
					}
					return nil
				}
				
			} catch {
				
			}
		}
		return passwordInfo
	}
}

struct PasswordRule {
	let character: Character
	let min: Int
	let max: Int
}

struct PasswordEntry {
	let rule: PasswordRule
	let password: String
	
	func isValid() -> Bool {
		let countChar = password.filter { $0 == rule.character }.count
		return countChar >= rule.min && countChar <= rule.max
	}
}
