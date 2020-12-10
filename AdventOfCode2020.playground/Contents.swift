import Cocoa

//Day1.solveForTwo()
//Day1.solveForThree()
//Day2.solve()
//Day3.solve()
// Have refactored Days 1-3 to use the AOCUtil function to read lines
//Day4.solve()
//Day5.solve()
//Day6.solve()
// Using AOCUtil functions
//Day7.solve()
//Day8.solve()

Day10.solve()

public class Day10 {
	public static func solve() {
		// Example 1
		//var joltages = [16,10,15,5,1,11,7,19,6,12,4].sorted()
		// Example 2
		//var joltages = [28,33,18,42,31,14,46,20,48,47,24,23,49,45,19,38,39,11,1,32,25,35,8,17,7,9,4,2,34,10,3].sorted()
		// Real input
		let input = InputUtil.readInputFile(named: "Day10_Input", removingEmptyLines: true)
		var joltages: [Int] = input.compactMap({ Int($0) }).sorted()
		joltages.append(joltages.last! + 3) // The last diff is to the device, defined to be 3
		print(joltages)
		var diffs = [Int]()
		var lastJoltage = 0 // the seat outlet
		for joltage in joltages {
			let diff = joltage - lastJoltage
			if diff >= 1 && diff <= 3 {
				diffs.append(diff)
			}
			else {
				print("diff is \(diff)")
			}
			lastJoltage = joltage
		}
		print(diffs)
		let counts = Dictionary(diffs.map({ ($0, 1) }), uniquingKeysWith: +)
		print("There are \(counts[1]!) diffs of 1 and \(counts[3]!) diffs of 3.")
		print("The product is \(counts[1]! * counts[3]!)")
	}
}


class InputUtil {
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
