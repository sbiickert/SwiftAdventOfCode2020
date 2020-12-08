import Foundation

public class Day1 {
	public static func solveForTwo() {
		let expenseAmounts = Day1.readExpenseAmounts()
		let expenseLookup = Set<Int>(expenseAmounts)
		for eAmount in expenseAmounts {
			let diff = 2020 - eAmount
			if expenseLookup.contains(diff) {
				print("The expenses that add to $2020 are \(eAmount) and \(diff)")
				print("The product is \(eAmount * diff)")
				return
			}
		}
		print("Did not find two numbers that add to 2020.")
	}
	
	public static func solveForThree() {
		let expenseAmounts = Day1.readExpenseAmounts()
		let expenseLookup = Set<Int>(expenseAmounts)
		for amountOne in expenseAmounts {
			for amountTwo in expenseAmounts {
				let diff = 2020 - (amountOne + amountTwo)
				if expenseLookup.contains(diff) {
					print("The expenses that add to $2020 are \(amountOne), \(amountTwo) and \(diff)")
					print("The product is \(amountOne * amountTwo * diff)")
					return
				}
			}
		}
		print("Did not find three numbers that add to 2020.")
	}

	public static func readExpenseAmounts() -> [Int] {
		let strAmounts = readInputFile(named: "Day1_Input", removingEmptyLines: true)
		return strAmounts.compactMap { Int($0) }
	}
	
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
