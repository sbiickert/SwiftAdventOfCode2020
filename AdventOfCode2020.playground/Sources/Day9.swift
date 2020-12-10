import Foundation

public class Day9 {
	static let WSIZE = 25

	public static func solve() {
		let input = InputUtil.readInputFile(named: "Day9_Input", removingEmptyLines: true)
		let numbers = input.compactMap { Int($0) }
		let (_, invalidNumber) = findInvalidNumber(in: numbers)
		if let weakness = findWeakness(in: numbers, addingTo: invalidNumber)?.sorted() {
			let sum = weakness.first! + weakness.last!
			
			print("First: \(weakness.first!), Last: \(weakness.last!) add to \(sum)")
		}
	}
	
	static func findWeakness(in numbers: [Int], addingTo invalidNumber:Int) -> [Int]? {
		for ptr in stride(from: 0, to: numbers.count-1, by: 1) {
			var sum = numbers[ptr]
			for upperPtr in stride(from: ptr+1, to: numbers.count, by: 1) {
				sum += numbers[upperPtr]
				if sum == invalidNumber {
					// We have found the weakness
					print("Found the weakness. Numbers between \(numbers[ptr]) and \(numbers[upperPtr]) add to \(invalidNumber)")
					return [Int](numbers[ptr...upperPtr])
				}
				if sum > invalidNumber {
					// Numbers have added to more than the invalid number
					break
				}
			}
		}
		
		return nil
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
