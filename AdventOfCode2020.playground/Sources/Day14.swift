import Foundation

public class Day14 {
	
	static let reMaskDef = "mask = ([01X]+)"
	static var reMask: NSRegularExpression?
	static let reMemDef = "mem\\[([0-9]+)\\] = ([0-9]+)"
	static var reMem: NSRegularExpression?

	public static func solve() {
		if createRegularExpressions() == false {
			return
		}
		let input = readInputFile(named: "Day14_Input", removingEmptyLines: true)
		let computer = SeaPortComputer()
		
		for line in input {
			let range = NSRange(location: 0, length: line.utf16.count)
			if let match = reMask?.firstMatch(in: line, options: [], range: range) {
				if let rMask = Range(match.range(at: 1), in: line) {
					let mask = String(line[rMask])
					computer.setMask(value: mask)
				}
			}
			if let match = reMem?.firstMatch(in: line, options: [], range: range) {
				if let rAddr = Range(match.range(at: 1), in: line),
				   let rVal = Range(match.range(at: 2), in: line) {
					if let address = Int(line[rAddr]),
					   let value = Int(line[rVal]) {
						computer.applyMemory(value: value, to: address, forPartTwo: false)
					}
				}
			}
		}
		print("The sum of memory values is: \(computer.sum)")
	}
	
	static func readInputFile(named name:String, removingEmptyLines removeEmpty:Bool) -> [String] {
		var results = [String]()
		if let inputPath = Bundle.main.path(forResource: name, ofType: "txt") {
			do {
				let input = try String(contentsOfFile: inputPath)
				results = input.components(separatedBy: "\n")
			} catch {
				print("Could not read file \(name)")
			}
		}
		if removeEmpty {
			results = results.filter { $0.count > 0 }
		}
		return results
	}
	
	static func createRegularExpressions() -> Bool {
		do {
			reMask = try NSRegularExpression(pattern: reMaskDef, options: [])
			reMem = try NSRegularExpression(pattern: reMemDef, options: [])
		} catch {
			print("Error creating regular expression.")
			return false
		}
		return true
	}
	
}

class SeaPortComputer {
	static let MASK_SIZE = 36
	
	var _mask = [String]()
	var _floatMaskLookups = [[String]]()
	var mask: [String] {
		return _mask
	}
	func setMask(value: String) {
		_mask = Array(value).map { String($0) }
		_floatMaskLookups = generateFloatingMaskLookups()
		print(value)
//		for fMask in _floatMaskLookups {
//			print(fMask.joined())
//		}
	}
	func generateFloatingMaskLookups() -> [[String]] {
		var floatingIndexes = [Int]()
		for (idx, val) in _mask.enumerated() {
			if val == "X" {
				floatingIndexes.append(idx)
			}
		}
//		print(floatingIndexes)
		var lookups = [[String]]()
		let nLookups = Int(truncating: pow(2, floatingIndexes.count) as NSDecimalNumber)
		for i in 0..<nLookups {
			let binString = SeaPortComputer.padBinary(decimalValue: i, length: floatingIndexes.count)
			let bitStrings = Array(binString).map { String($0) }
//			print(bitStrings)
			var lookup = _mask
			for (j, bit) in bitStrings.enumerated() {
				//print("setting bit \(floatingIndexes[j]) to \(bit)")
				lookup[floatingIndexes[j]] = bit
			}
			lookups.append(lookup)
		}
		return lookups
	}
	
	var memory = Dictionary<Int, Int>()
	
	func applyMemory(value: Int, to address: Int, forPartTwo: Bool) {
		print("mem[\(address)] -> \(value)")
		

		if forPartTwo {
			let maskedValues = SeaPortComputer.applyPt2(mask: mask, lookups: _floatMaskLookups, to: address)
			for maskedValue in maskedValues {
				memory[maskedValue] = value
				//print("mem[\(maskedValue)] -> \(memory[maskedValue]!) masked")
			}
		}
		else {
			let maskedValue = SeaPortComputer.applyPt1(mask: mask, to: value)
			memory[address] = maskedValue
			print("mem[\(address)] -> \(memory[address]!) masked")
		}
	}
	
	static func padBinary(decimalValue: Int, length: Int) -> String {
		var binString = String(decimalValue, radix: 2)
		var padding = ""
		for _ in 0..<(length - binString.count) {
			padding = "0" + padding
		}
		binString = padding + binString
		return binString
	}
	
	static func applyPt1(mask: [String], to value: Int) -> Int {
		let binString = padBinary(decimalValue: value, length: MASK_SIZE)
		let bitStrings = Array(binString).map { String($0) }
		
		var masked = [String]()
		for i in 0..<MASK_SIZE {
			switch mask[i] {
			case "0":
				masked.append(mask[i])			// Overwrite 0
			case "1":
				masked.append(mask[i])			// Overwrite 1
			default:
				masked.append(bitStrings[i])	// Pass through
			}
		}
		let maskedBinString = masked.joined()
		
		return Int(maskedBinString, radix: 2)!
	}
	
	static func applyPt2(mask: [String], lookups: [[String]], to value: Int) -> [Int] {
		let binString = padBinary(decimalValue: value, length: MASK_SIZE)
		let bitStrings = Array(binString).map { String($0) }
		//print("Pre-mask:  \(bitStrings)")

		var results = [Int]()
		
		for lookup in lookups {
			var masked = [String]()
			for i in 0..<MASK_SIZE {
				switch mask[i] {
				case "0":
					masked.append(bitStrings[i]) // unchanged
				case "1":
					masked.append(mask[i]) 		 // overwrite
				default:
					masked.append(lookup[i]) 	 // floating
				}
			}
			let maskedBinString = masked.joined()
			results.append(Int(maskedBinString, radix: 2)!)
		}
		return results
	}
	
	var sum: Int {
		return memory.values.reduce(0, +)
	}
}
