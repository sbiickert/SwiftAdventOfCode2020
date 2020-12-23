import Foundation

public class Day23 {
	
	private static let input = "326519478" // 389125467 Sample  326519478 Challenge
	private static let MAX_ITER = 10000000 //100 pt1 10000000 pt2
	private static let EXTRA_CUPS = true
	private static let EXTRA_CUPS_MAX = 1000000
	private static let PICK_UP = 3
	
	private static var currentCup = Cup(value: 0) // Placeholder
	private static var cups = Dictionary<Int, Cup>()
	private static var minCup = 0
	private static var maxCup = 0
	
	public static func solve() {
		let cupLabels = Array(input).map({String($0)})
		let cupValues = cupLabels.compactMap({Int($0)})
		
		var firstCup: Cup? // Need this to close the loop
		var prevCup: Cup?  // Need this to connect prev/next
		var thisCup: Cup!
		for value in cupValues {
			thisCup = Cup(value: value)
			if let pc = prevCup {
				pc.next = thisCup
				thisCup.prev = pc
			}
			cups[value] = thisCup
			prevCup = thisCup
			if firstCup == nil {
				firstCup = thisCup
			}
		}
		// Complete the loop
		firstCup!.prev = thisCup
		thisCup.next = firstCup
		
		maxCup = cups.keys.max()!
		minCup = cups.keys.min()!
		currentCup = firstCup!

		if EXTRA_CUPS {
			// Append values up to 1,000,000
			let extraCups = (maxCup+1...EXTRA_CUPS_MAX).map({Cup(value: $0)})
			for (i, cup) in extraCups.enumerated() {
				cups[cup.value] = cup
				if i > 0 {
					cup.prev = extraCups[i-1]
				}
				if i < extraCups.count-1 {
					cup.next = extraCups[i+1]
				}
			}
			insert(cups: extraCups, after: thisCup)
			maxCup = EXTRA_CUPS_MAX
		}
		print(cups.count)
		print("Playing...")
		//printCups()
		
		for i in 1...MAX_ITER {
			iterate()
			
			if i % 1000000 == 0 {
				print(i)
			}
			//printCups()
		}
		
		if EXTRA_CUPS {
			printFinalStatePart2()
		}
		else {
			printFinalStatePart1()
		}
	}
	
	private static func iterate() {
		// Extract next PICK_UP numbers from cups
		let pickedUpCups = pickUpCups()
		//print(pickedUpCups)
		
		// Find destination
		var destValue = currentCup.value - 1
		if destValue < minCup {
			destValue = maxCup
		}
		var dest = cups[destValue]!
		while pickedUpCups.contains(dest) {
			destValue -= 1
			if destValue < minCup {
				destValue = maxCup
			}
			dest = cups[destValue]!
		}
		
		// Insert at destination
		insert(cups: pickedUpCups, after: dest)
		
		// Increment cup index
		currentCup = currentCup.next!
	}
	
	private static func insert(cups addedCups: [Cup], after: Cup) {
		// Assume the addedCups are linked
		let temp = after.next!
		after.next = addedCups.first!
		addedCups.first!.prev = after
		temp.prev = addedCups.last!
		addedCups.last!.next = temp
	}
	
	private static func pickUpCups() -> [Cup] {
		var pickedUp = [Cup]()
		var ptr = currentCup
		for _ in 1...PICK_UP {
			ptr = ptr.next!
			pickedUp.append(ptr)
		}
		// Break and close the ring
		let cupAfterBreak = ptr.next!
		currentCup.next = cupAfterBreak
		cupAfterBreak.prev = currentCup
		
		// Picked up cups are internally linked, but not in the ring any more
		pickedUp.first!.prev = nil
		pickedUp.last!.next = nil
		
		return pickedUp
	}
	
	private static func printCups() {
		var str = ""
		var cup = currentCup
		while true {
			str += cup == currentCup ? "(\(cup)) " : "\(cup) "
			cup = cup.next!
			if cup == currentCup {
				break
			}
		}
		print(str)
	}
	
	private static func printFinalStatePart1() {
		// Need to find 1, then print from there
		let cup1 = cups[1]!
		var ptr = cup1.next!
		var str = ""
		while ptr != cup1 {
			str += String(ptr.value)
			ptr = ptr.next!
		}
		print("Final state: \(str)")
	}
	
	private static func printFinalStatePart2() {
		// Need to find 1, then multiply the next two
		let cup1 = cups[1]!
		let cupNext1 = cup1.next!
		let cupNext2 = cupNext1.next!
		print("\([cupNext1.value, cupNext2.value]) multiplied together is \(cupNext1.value * cupNext2.value)")
	}
}

private class Cup: Equatable, CustomStringConvertible {
	var description: String {
		return "\(prev?.value ?? 0)<-\(value)->\(next?.value ?? 0)"
	}
	
	static func == (lhs: Cup, rhs: Cup) -> Bool {
		return lhs.value == rhs.value
	}
	
	let value: Int
	weak var next: Cup?
	weak var prev: Cup?
	
	init(value v: Int) {
		value = v
	}
}
