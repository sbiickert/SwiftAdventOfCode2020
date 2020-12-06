import Foundation

public class Day4 {
	public static func solve() {
		let passports = readPassports()
		//print("The total number of passports is \(passports.count)")
		let validPassports = passports.filter { $0.isValid }
//		for passport in validPassports {
//			print("Valid: \(passport)")
//		}
		print("The number of valid passports is \(validPassports.count)")
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
					passports.append(Passport(info: line, enhanced: true))
				}
			} catch {
				
			}
		}
		return passports
	}

}

struct Passport: CustomStringConvertible {
	var description: String {
		var desc = ""
		for field in Field.allCases {
			desc += "\(field.rawValue):\(fields[field.rawValue] ?? "nil") "
		}
		return desc
	}
	
	let source: String
	let fields: Dictionary<String,String>
	let enhanced: Bool
	
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
	
	static let EYE_COLORS: Set<String> = Set(["amb", "blu", "brn", "gry", "grn", "hzl", "oth"])
	
	init(info: String, enhanced:Bool) {
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
		self.source = info
		self.fields = theFields
		self.enhanced = enhanced
	}
	
	var id: String? {
		return fields[Field.passportID.rawValue]
	}
	
	var isValid: Bool {
		let keys = fields.keys
		// Must contain these keys
		if keys.contains(Field.birthYear.rawValue) &&
			keys.contains(Field.issueYear.rawValue) &&
			keys.contains(Field.expireYear.rawValue) &&
			keys.contains(Field.height.rawValue) &&
			keys.contains(Field.hairColor.rawValue) &&
			keys.contains(Field.eyeColor.rawValue) &&
			keys.contains(Field.passportID.rawValue) {
			if enhanced {
				// Additional value checking
				return isEnhancedValid()
			}
			else {
				return true
			}
		}
		return false
	}
	
	private func isEnhancedValid() -> Bool {
		//pid (Passport ID) - a nine-digit number, including leading zeroes.
		do {
			let pidValue = fields[Field.passportID.rawValue]!
			if pidValue.count != 9 {
				print("Passport \(id!) pid invalid")
				return false
			}
			let pidRegex = try NSRegularExpression(pattern: "\\d{9}", options: [])
			let range = NSRange(location: 0, length: pidValue.utf16.count)
			let match = pidRegex.firstMatch(in: pidValue, options:[], range: range)
			if match == nil {
				print("Passport \(id!) pid invalid")
				return false
			}
		} catch {
			return false
		}

		//byr (Birth Year) - four digits; at least 1920 and at most 2002.
		let byrValue = fields[Field.birthYear.rawValue]!
		if isValidNumber(value: byrValue, between: 1920, and: 2002) == false {
			print("Passport \(id!) byr invalid: \(byrValue)")
			return false
		}

		//iyr (Issue Year) - four digits; at least 2010 and at most 2020.
		let iyrValue = fields[Field.issueYear.rawValue]!
		if isValidNumber(value: iyrValue, between: 2010, and: 2020) == false {
			print("Passport \(id!) iyr invalid: \(iyrValue)")
			return false
		}

		//eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
		let eyrValue = fields[Field.expireYear.rawValue]!
		if isValidNumber(value: eyrValue, between: 2020, and: 2030) == false {
			print("Passport \(id!) eyr invalid: \(eyrValue)")
			return false
		}

		//ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
		let eclValue = fields[Field.eyeColor.rawValue]!
		if Passport.EYE_COLORS.contains(eclValue) == false {
			print("Passport \(id!) ecl invalid: \(eclValue)")
			return false
		}

		//hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
		do {
			let hclValue = fields[Field.hairColor.rawValue]!
			let hclRegex = try NSRegularExpression(pattern: "#[0-9a-f]{6}", options: [])
			let range = NSRange(location: 0, length: hclValue.utf16.count)
			let match = hclRegex.firstMatch(in: hclValue, options:[], range: range)
			if match == nil {
				print("Passport \(id!) hcl invalid: \(hclValue)")
				return false
			}
		} catch {
			return false
		}

		//hgt (Height) - a number followed by either cm or in:
		//	If cm, the number must be at least 150 and at most 193.
		//	If in, the number must be at least 59 and at most 76.
		do {
			let hgtValue = fields[Field.height.rawValue]!
			let hgtRegex = try NSRegularExpression(pattern: "(\\d+)(\\w{2})", options: [])
			let range = NSRange(location: 0, length: hgtValue.utf16.count)
			let match = hgtRegex.firstMatch(in: hgtValue, options:[], range: range)
			if match == nil {
				print("Passport \(id!) hgt did not match pattern: \(hgtValue)")
				return false
			}
			
			if let rValue = Range(match!.range(at: 1), in: hgtValue),
			   let rUnits = Range(match!.range(at: 2), in: hgtValue) {
				if let value = Int(hgtValue[rValue]) {
					let units = String(hgtValue[rUnits])
					switch units {
					case "cm":
						if value < 150 || value > 193 {
							print("Passport \(id!) hgt invalid: \(hgtValue)")
							return false
						}
					case "in":
						if value < 59 || value > 76 {
							print("Passport \(id!) hgt invalid: \(hgtValue)")
							return false
						}
					default:
						print("Passport \(id!) hgt units invalid: \(hgtValue)")
						return false
					}
				}
				else {
					print("Passport \(id!) hgt could not assign values: \(hgtValue)")
					return false
				}
			}
			else {
				print("Passport \(id!) hgt could not get values: \(hgtValue)")
				return false
			}
		} catch {
			return false
		}
		
		//cid (Country ID) - ignored, missing or not.
		return true
	}
	
	private func isValidNumber(value: String, between min:Int, and max:Int) -> Bool {
		if let intValue = Int(value) {
			if intValue < min || intValue > max {
				return false
			}
		}
		else {
			return false
		}
		return true
	}
	
	
}
