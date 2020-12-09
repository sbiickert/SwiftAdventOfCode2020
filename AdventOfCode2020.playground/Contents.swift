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

Day9.solve()

public class Day9 {
	static let WSIZE = 25

	public static func solve() {
		let input = InputUtil.readInputFile(named: "Day9_Input", removingEmptyLines: true)
		let numbers = input.compactMap { Int($0) }
		let (_, invalidNumber) = findInvalidNumber(in: numbers)
		let weakness = findWeakness(in: numbers, addingTo: invalidNumber)
	}
	
	static func findWeakness(in numbers: [Int], addingTo invalidNumber:Int) -> [Int] {
		var weakness = [Int]()
		
		// TODO
		
		return weakness
	}
	
	static func findInvalidNumber(in numbers: [Int]) -> (index:Int, value:Int) {
		var ptrEval:Int = WSIZE
		var wBounds: (Int,Int) {
			return (ptrEval - WSIZE, ptrEval)
		}

		var invalidNumber:Int = 0
		
		while ptrEval < numbers.count {
			let window = Set<Int>(numbers[wBounds.0..<wBounds.1])
			let numberToEval = numbers[ptrEval]
			var isSumOfTwo = false
			
			for number in window {
				let diff = numberToEval - number
				if diff != number && window.contains(diff) {
					// The number to evaluate is the sum of two numbers in the window
					isSumOfTwo = true
					//print("\(numberToEval) = \(number) + \(diff)")
					break
				}
			}
			
			if isSumOfTwo == false {
				// Did not find two numbers in window that add to numberToEval
				print("Could not find two numbers in \(window) that add to \(numberToEval)")
				invalidNumber = numberToEval
				break
			}
			ptrEval += 1
		}
		
		return (ptrEval, invalidNumber)
	}
}

public class InputUtil {
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
	
	public static func readGroupedInputFile(named name: String) -> [[String]] {
		var results = [[String]]()
		let lines = readInputFile(named: name, removingEmptyLines: false)
		
		var group = [String]()
		for line in lines {
			if line.count > 0 {
				group.append(line)
			}
			else {
				results.append(group)
				group = [String]()
			}
		}
		if group.count > 0 {
			results.append(group)
		}
		
		return results
	}
}
