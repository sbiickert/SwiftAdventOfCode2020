import Foundation

public class Day23 {
	
	private static let MAX_ITER = 100 //100 pt1 10000000 pt2
	private static let PICK_UP = 3
	private static var currentCup = 0
	private static var cups = [Int]()
	private static var minCup = 0
	private static var maxCup = 0
	
	private static var currentCupIndex: Int {
		return cups.firstIndex(of: currentCup)!
	}
	
	private static func printCups() {
		var str = ""
		for (i, cup) in cups.enumerated() {
			str += i == currentCupIndex ? "(\(cup)) " : " \(cup)  "
		}
		print(str)
	}
	private static func printFinalStatePart1() {
		// Need to find 1, then print from there
		let idxOf1 = cups.firstIndex(of: 1)!
		let r1 = idxOf1+1..<cups.count
		let r2 = 0..<idxOf1
		let finalState = cups[r1] + cups[r2]
		print("Final state: \(finalState.map({String($0)}).joined())")
	}
	private static func printFinalStatePart2() {
		// Need to find 1, then multiply the next two
		let idxOf1 = cups.firstIndex(of: 1)!
		var nextTwo = [Int]()
		for i in 1...2 {
			var next = idxOf1 + i
			if next >= cups.count {
				next -= cups.count
			}
			nextTwo.append(cups[next])
		}
		print("\(nextTwo) multiplied together is \(nextTwo.reduce(1, *))")
	}
	
	public static func solve() {
		
		let input = "389125467" // Sample
		//let input = "326519478" // Challenge input
		
		let cupLabels = Array(input).map({String($0)})
		cups = cupLabels.compactMap({Int($0)})
		currentCup = cups[0]
		maxCup = cups.max()!
		minCup = cups.min()!
		
		if MAX_ITER > 100 {
			// Append values up to 1,000,000
			cups.append(contentsOf: maxCup+1...1000000)
			maxCup = cups.max()!
		}
		print(cups.count)
		//printCups()
		
		for i in 1...MAX_ITER {
			iterate()
			
			//if i % 100 == 0 {
				print(i)
			//}
			//printCups()
		}
		
		if MAX_ITER == 100 {
			printFinalStatePart1()
		}
		else {
			printFinalStatePart2()
		}
	}
	
	private static func iterate() {
		// Extract next PICK_UP numbers from cups
		let pickedUpCups = pickUpCups()
		//print(pickedUpCups)
		
		// Find destination
		var dest = currentCup - 1
		while cups.firstIndex(of: dest) == nil {
			if dest < minCup {
				dest = maxCup
			}
			if pickedUpCups.contains(dest) {
				dest -= 1
			}
		}
		let destIndex = cups.firstIndex(of: dest)!
		
		// Insert at destination
		cups.insert(contentsOf: pickedUpCups, at: destIndex+1)
		
		// Increment cup index
		currentCup = currentCupIndex == cups.count-1 ? cups[0] : cups[currentCupIndex+1]
	}
	
	private static func pickUpCups() -> [Int] {
		let idx = currentCupIndex + 1
		var cupsCopy = cups // value type, copy on write
		var pickedUp = [Int]()
		while idx < cupsCopy.count && pickedUp.count < PICK_UP {
			pickedUp.append(cupsCopy.remove(at: idx))
		}
		while pickedUp.count < PICK_UP {
			pickedUp.append(cupsCopy.remove(at: 0))
		}
		cups = cupsCopy
		return pickedUp
	}
	
}
