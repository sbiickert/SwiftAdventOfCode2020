//
//  Day04.swift
//  AoC2020
//

import Foundation

class Day04: AoCSolution {
	override init() {
		super.init()
		day = 04
		self.name = "Passport Processing"
		self.emptyLinesIndicateMultipleInputs = false
	}
	
	override func solve(_ input: AoCInput) -> AoCResult {
		super.solve(input)
		
		let passports = input.allInputGroups.map { Passport(defn: $0) }
		
		let p1 = passports.count(where: { $0.isValidPartOne })
		let p2 = passports.count(where: { $0.isValidPartTwo })

		return AoCResult(part1: "There are \(p1) valid passports.", part2: "There are \(p2) valid passports.")
	}
}

struct Passport {
	let fields: Dictionary<PassportField, String>
	
	init(defn: [String]) {
		var f = Dictionary<PassportField, String>()
		let oneLine = defn.joined(separator: " ")
		
		for m in oneLine.matches(of: /([a-z]{3}):([^\s]+)/) {
			let field = PassportField(rawValue: String(m.1))!
			f[field] = String(m.2)
		}
		
		fields = f
	}
	
	var isValidPartOne: Bool {
		if fields.count == 8 { return true }
		if fields.count == 7 && !fields.contains(where: {$0.key == .countryID}) { return true }
		return false
	}
	
	var isValidPartTwo: Bool {
		guard isValidPartOne else { return false }
		
		var isValid = true
		
		for field in fields.keys {
			let fieldValue = fields[field]!
			switch field {
			case .birthYear:
				if let year = stringToYear(fieldValue) {
					if year < 1920 || year > 2002 { isValid = false }
				}
				else { isValid = false }
				
			case .issueYear:
				if let year = stringToYear(fieldValue) {
					if year < 2010 || year > 2020 { isValid = false }
				}
				else { isValid = false }
				
			case .expirationYear:
				if let year = stringToYear(fieldValue) {
					if year < 2020 || year > 2030 { isValid = false }
				}
				else { isValid = false }
				
			case .height:
				if let m = fieldValue.firstMatch(of: /(\d+)(cm|in)/) {
					let value = Int(String(m.1))!
					if m.2 == "cm" {
						if value < 150 || value > 193 { isValid = false }
					}
					else {
						if value < 59 || value > 76 { isValid = false }
					}
				}
				else { isValid = false }
				
			case .hairColor:
				if let _ = fieldValue.firstMatch(of: /^#[0-9a-f]{6}$/) {}
				else { isValid = false }
				
			case .eyeColor:
				let colors = Set(["amb", "blu", "brn", "gry", "grn", "hzl", "oth"])
				if colors.contains(fieldValue) == false { isValid = false }
				
			case .passportID:
				if let _ = fieldValue.firstMatch(of: /^\d{9}$/) {}
				else { isValid = false }

			case .countryID: break
				
			}
			
			if !isValid { break }
		}
		
		return isValid
	}
	
	func stringToYear(_ str:String) -> Int? {
		if let m = str.firstMatch(of: /^\d{4}$/) {
			return Int(String(m.0))
		}
		return nil
	}
}

enum PassportField: String {
	
	case birthYear = "byr"
	case issueYear = "iyr"
	case expirationYear = "eyr"
	case height = "hgt"
	case hairColor = "hcl"
	case eyeColor = "ecl"
	case passportID = "pid"
	case countryID = "cid"
	
}
