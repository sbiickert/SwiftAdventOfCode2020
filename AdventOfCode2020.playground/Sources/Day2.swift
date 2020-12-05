import Foundation

public class Day2 {
	public static func solve() {
		let expenseAmounts = Day1.readExpenseAmounts()
		let expenseLookup = Set<Int>(expenseAmounts)
		for eAmount in expenseAmounts {
			let diff = 2020 - eAmount
			if expenseLookup.contains(diff) {
				print("The expenses that add to $2020 are \(eAmount) and \(diff)")
				print("The product is \(eAmount * diff)")
				break
			}
		}
	}
}
