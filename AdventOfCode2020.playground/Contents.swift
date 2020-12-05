import Cocoa

//Day1.solveForTwo()
//Day1.solveForThree()
//Day2.solve()
//Day3.solve()
Day4.solve()

public class Day4 {
	public static func solve() {
		let passports = readPassports()
		var validCount = 0
		for passport in passports {
			if passport.isValid {
				validCount += 1
			}
		}
		print("The number of valid passports is \(validCount)")
	}
	
	static func readPassports() -> [Passport] {
		var passports = [Passport]()
		if let inputPath = Bundle.main.path(forResource: "Day4_Input", ofType: "txt") {
			do {
				let input = try String(contentsOfFile: inputPath)
				let lines = input.components(separatedBy: "\n")
				// Join passport info onto single lines
				var adjustedLines = [String]()
				var builder = ""
				for idx in stride(from: 0, to: lines.count, by: 1) {
					let thisLine = lines[idx]
					if thisLine.count == 0 && builder.count > 0 {
						adjustedLines.append(builder)
						builder = ""
					}
					else {
						builder += " \(thisLine)"
					}
				}
				adjustedLines.append(builder)

				for line in adjustedLines {
					//print(line)
					passports.append(Passport(info: line))
				}
			} catch {
				
			}
		}
		return passports
	}

}

struct Passport {
	let fields: Dictionary<String,String>
	
	enum Field: String, CaseIterable {
		case birthYear = "byr"
		case issueYear = "iyr"
		case expireYear = "eyr"
		case height = "hgt"
		case hairColor = "hcl"
		case eyeColor = "ecl"
		case passportID = "pid"
		case countryID = "cid"
	}
	
	init(info: String) {
		// string is key:value key:value...
		// byr:1994 hgt:152cm pid:198152466 eyr:2022 ecl:hzl hcl:#4df239 iyr:2020
		var theFields = Dictionary<String, String>()
		for field in Field.allCases {
			do {
				let regex = try NSRegularExpression(pattern: "\(field.rawValue):([^ ]+)", options: [])
				let range = NSRange(location: 0, length: info.utf16.count)
				if let match = regex.firstMatch(in: info, options:[], range: range) {
					if let rValue = Range(match.range(at: 1), in: info) {
						let value = String(info[rValue])
						theFields[field.rawValue] = value
					}
				}
			} catch {
				
			}
		}
		fields = theFields
	}
	
	var isValid: Bool {
		let keys = fields.keys
		// Must contain these keys
		return keys.contains(Field.birthYear.rawValue) &&
			keys.contains(Field.issueYear.rawValue) &&
			keys.contains(Field.expireYear.rawValue) &&
			keys.contains(Field.height.rawValue) &&
			keys.contains(Field.hairColor.rawValue) &&
			keys.contains(Field.eyeColor.rawValue) &&
			keys.contains(Field.passportID.rawValue)
	}
}
