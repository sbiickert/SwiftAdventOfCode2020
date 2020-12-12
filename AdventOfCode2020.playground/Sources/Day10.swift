import Foundation

public class Day10 {
	
	static let MIN_𝝙J = 1
	static let MAX_𝝙J = 3
	
	public static func solve() {
		// Example 1
		//var joltages = [16,10,15,5,1,11,7,19,6,12,4].sorted()
		// Example 2
		//var joltages = [28,33,18,42,31,14,46,20,48,47,24,23,49,45,19,38,39,11,1,32,25,35,8,17,7,9,4,2,34,10,3].sorted()
		// Real input
		//var joltages = [151,94,14,118,25,143,33,23,80,95,87,44,150,39,148,51,138,121,70,69,90,155,144,40,77,8,97,45,152,58,65,63,128,101,31,112,140,86,30,55,104,135,115,16,26,60,96,85,84,48,4,131,54,52,139,76,91,46,15,17,37,156,134,98,83,111,72,34,7,108,149,116,32,110,47,157,75,13,10,145,1,127,41,53,2,3,117,71,109,105,64,27,38,59,24,20,124,9,66].sorted()
		let input = Input10Util.readInputFile(named: "Day10_Input", removingEmptyLines: true)
		var joltages: [Int] = input.compactMap({ Int($0) }).sorted()
		//joltages.insert(0, at: 0) // The outlet
		joltages.append(joltages.last! + MAX_𝝙J) // The last diff is to the device, defined to be 3
		print(joltages)
		let product = part1(joltages)
		print("The solution for part 1 is \(product)")
		
		// Too slow
//		var combinationCounts = 1 // 1 branch by default
//		combinationCounts += navigatePathsFast(from: joltages, at: 0)
//		print("Navigating: found \(combinationCounts) possible adapter combinations.")
		
		var sol = [0:1]
		for joltage in joltages {
			sol[joltage] = 0
			if sol.keys.contains(joltage - 1) {
				sol[joltage]! += sol[joltage - 1]!
			}
			if sol.keys.contains(joltage - 2) {
				sol[joltage]! += sol[joltage - 2]!
			}
			if sol.keys.contains(joltage - 3) {
				sol[joltage]! += sol[joltage - 3]!
			}
		}
		
		print("Part 2: found \(sol[joltages.last!]!) possible adapter combinations.")
	}
	
	static func navigatePaths(from joltages: [Int], at index: Int) -> Int {
		// Identify adapters that are less than the maximum change in joltage
		var additionalBranchCount = 0
		var nextBranchCount = 0
		for i in stride(from: MIN_𝝙J, through: MAX_𝝙J, by: 1) {
			if i+index < joltages.count && joltages[i+index] - joltages[index] <= MAX_𝝙J {
				additionalBranchCount += 1 // for each sub
				additionalBranchCount += navigatePaths(from: joltages, at: i+index) // for branches below
				nextBranchCount += 1
			}
		}
		// At this point, additionalBranchCount is 1 too high, because 3 subs would count as 3 more, which is wrong
		if nextBranchCount > 0 {
			additionalBranchCount -= 1
		}
		return additionalBranchCount
	}
	
	static func navigatePathsFast(from joltages: [Int], at index: Int) -> Int {
		// Identify adapters that are less than the maximum change in joltage
		let joltageCount = joltages.count
		let thisJoltage = joltages[index]
		let next1: Int? = index+1 < joltageCount ? joltages[index+1] : nil
		let next2: Int? = index+2 < joltageCount ? joltages[index+2] : nil
		let next3: Int? = index+3 < joltageCount ? joltages[index+3] : nil
		
		if next1 == nil {
			return 0
		}
		var additionalBranchCount = 0
		// next1 is always < MAX_𝝙J, doesn't add towards additionalBranchCount
		additionalBranchCount += navigatePathsFast(from: joltages, at: index+1)
		if next2 != nil && next2! - thisJoltage <= MAX_𝝙J {
			additionalBranchCount += 1
			additionalBranchCount += navigatePathsFast(from: joltages, at: index+2)
		}
		if next3 != nil && next3! - thisJoltage <= MAX_𝝙J {
			additionalBranchCount += 1
			additionalBranchCount += navigatePathsFast(from: joltages, at: index+3)
		}
		return additionalBranchCount
	}

	static func part1(_ joltages: [Int]) -> Int {
		var diffs = [Int]()
		var lastJoltage = 0 // the seat outlet
		for joltage in joltages {
			let diff = joltage - lastJoltage
			if diff >= MIN_𝝙J && diff <= MAX_𝝙J {
				diffs.append(diff)
			}
			else {
				print("diff is \(diff)")
			}
			lastJoltage = joltage
		}
		//print(diffs)
		let counts = Dictionary(diffs.map({ ($0, 1) }), uniquingKeysWith: +)
		//print("There are \(counts[1]!) diffs of 1 and \(counts[3]!) diffs of 3.")
		if let diff1 = counts[MIN_𝝙J],
		   let diff3 = counts[MAX_𝝙J] {
			return diff1 * diff3
		}
		return 0
	}
	

}


private class Input10Util {
	public static func readInputFile(named name:String, removingEmptyLines removeEmpty:Bool) -> [String] {
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
}
