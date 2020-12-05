import Foundation

public class Day1 {
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
