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
//Day9.solve()
//Day10.solve()
//Day11.solve()
//Day12.solve()

Day13.solve()

public class Day13 {
	public static func solve() {
		let input = readInputFile(named: "Day13_Input", removingEmptyLines: true)
		part1(input)
		let busSched = input[1].components(separatedBy: ",")
		print(busSched)
	}
	
	static func part1(_ input: [String]) {
		let earliestDepartTime = Int(input[0])!
		let busIDs = input[1].components(separatedBy: ",").compactMap({ Int($0)}).sorted()
		print(busIDs)
		var delay = 0
		var timesSinceDepart = busIDs.map { earliestDepartTime % $0 }
		while timesSinceDepart.contains(0) == false {
			delay += 1
			timesSinceDepart = busIDs.map { (earliestDepartTime + delay) % $0 }
		}
		print(timesSinceDepart)
		let busIndex = timesSinceDepart.firstIndex(of: 0)!
		print("Bus \(busIDs[busIndex]) is the first to depart with a delay of \(delay) minutes.")
		print("Part 1 answer: \(busIDs[busIndex] * delay)")
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
}
