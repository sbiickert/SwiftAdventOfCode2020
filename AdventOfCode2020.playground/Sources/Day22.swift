import Foundation

public class Day22 {
	
	public static func solve(testing: Bool) {
		let allInput = readGroupedInputFile(named: "Day22_input")
		let p1Input = allInput[testing ? 0 : 2]
		let p2Input = allInput[testing ? 1 : 3]
		
		print("Parsing hands.")
		let p1Hand = Hand(data: p1Input)
		let p2Hand = Hand(data: p2Input)

		print("Starting play.")
		while p1Hand.cards.count > 0 && p2Hand.cards.count > 0 {
			let p1Card = p1Hand.draw()!
			let p2Card = p2Hand.draw()!
			
			if p1Card > p2Card {
				print("p1 plays \(p1Card), p2 plays \(p2Card). p1 wins.")
				p1Hand.addCard(card: p1Card)
				p1Hand.addCard(card: p2Card)
			}
			else {
				print("p1 plays \(p1Card), p2 plays \(p2Card). p2 wins.")
				p2Hand.addCard(card: p2Card)
				p2Hand.addCard(card: p1Card)
			}
		}
		let winningHand = p1Hand.cards.count > 0 ? p1Hand : p2Hand
		print("The winner is \(winningHand.player). Score: \(winningHand.score)")
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
	
	static func readGroupedInputFile(named name: String) -> [[String]] {
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

private class Hand {
	private(set) var player: String
	private(set) var cards: [Int]

	init(data: [String]) {
		print(data)
		var mData = data
		// Read the player name
		var firstLine = mData.removeFirst()
		firstLine.removeLast()
		player = firstLine
		
		// Read the cards
		cards = mData.compactMap({Int($0)}).reversed()
	}
	
	func draw() -> Int? {
		if cards.count > 0 {
			return cards.removeLast()
		}
		return nil
	}
	
	func addCard(card: Int) {
		cards.insert(card, at: 0)
	}
	
	var score: Int {
		var s = 0
		var multiplier = 1
		for card in cards {
			s += card * multiplier
			multiplier += 1
		}
		return s
	}
}
