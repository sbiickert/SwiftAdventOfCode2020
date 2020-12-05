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
		var expenseAmounts = [Int]()
		if let inputPath = Bundle.main.path(forResource: "Day1_Input", ofType: "txt") {
			do {
				let input = try String(contentsOfFile: inputPath)
				let strAmounts = input.components(separatedBy: "\n")
				expenseAmounts = strAmounts.compactMap { Int($0) }
			} catch {
				
			}
		}
		return expenseAmounts
	}
}
