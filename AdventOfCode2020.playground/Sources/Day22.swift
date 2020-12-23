import Foundation

public class Day22 {
	private static var whoWins = Dictionary<HandState, Hand>()
	private static var _nextGameID = 0
	private static var nextGameID: Int {
		_nextGameID += 1
		return _nextGameID
	}

	public static func solve(testing: Bool) {
		// Reset state
		_nextGameID = 0
		
		let allInput = readGroupedInputFile(named: "Day22_input")
		let p1Input = allInput[testing ? 0 : 2]
		let p2Input = allInput[testing ? 1 : 3]
		
		print("Parsing hands.")
		let p1Hand = Hand(data: p1Input)
		let p2Hand = Hand(data: p2Input)

		print("Starting play.")
		let winningHand = play(p1: p1Hand, p2: p2Hand)
		print("The winner is \(winningHand.player). Score: \(winningHand.score)")
	}
	
	private static func play(p1: Hand, p2: Hand) -> Hand {
		let gameID = nextGameID
		
		// Avoid playing redundant games
		let startState = HandState(h1: p1, h2: p2)
		if let winningHand = whoWins[startState] {
			return winningHand
		}
		
		var memo = Dictionary<HandState, Int>()
		var round = 0
		var p1Hand = p1
		var p2Hand = p2
		
		if (gameID % 1000 == 0) {
			print(gameID)
		}
		
		while p1Hand.cards.count > 0 && p2Hand.cards.count > 0 {
			round += 1
			let roundState = HandState(h1: p1Hand, h2: p2Hand)
			if memo[roundState] != nil {
				//print("Duplicate game state found. \(p1Hand.player) wins.")
				whoWins[startState] = p1Hand
				return(p1Hand)
			}
			memo[roundState] = 1
			
			let p1Card = p1Hand.draw()!
			let p2Card = p2Hand.draw()!
			
			if (p1Hand.cards.count >= p1Card) && (p2Hand.cards.count >= p2Card) {
				//print("[G: \(gameID), R: \(round)] p1 plays \(p1Card), p2 plays \(p2Card). p1 has \(p1Hand.cards.count) cards,  p2 has \(p2Hand.cards.count) cards. Recursing.")
				
				let subGameWinningHand = play(p1: p1Hand.copy(withNumCards: p1Card), p2: p2Hand.copy(withNumCards: p2Card))
				if subGameWinningHand.player == p1Hand.player {
					p1Hand.addCards(cards: [p1Card, p2Card])
				}
				else {
					p2Hand.addCards(cards: [p2Card, p1Card])
				}
			}
			else {
				if p1Card > p2Card {
					//print("[G: \(gameID), R: \(round)] p1 plays \(p1Card), p2 plays \(p2Card). p1 wins.")
					p1Hand.addCards(cards: [p1Card, p2Card])
				}
				else {
					//print("[G: \(gameID), R: \(round)] p1 plays \(p1Card), p2 plays \(p2Card). p2 wins.")
					p2Hand.addCards(cards: [p2Card, p1Card])
				}
			}
		}
		let winningHand = p1Hand.cards.count > 0 ? p1Hand : p2Hand
		whoWins[startState] = winningHand

		//print("G: \(gameID) play() returning. \(winningHand.player) wins.")
		return winningHand
	}
	
	//static var inputBundle: Bundle = Bundle.main
	static var inputBundle: Bundle {
		let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
		let bundleURL = URL(fileURLWithPath: "AoCInput.bundle", relativeTo: currentDirectoryURL)
		return Bundle(url: bundleURL)!
	}
	
	static func readInputFile(named name:String, removingEmptyLines removeEmpty:Bool) -> [String] {
		var results = [String]()
		if let inputPath = inputBundle.path(forResource: name, ofType: "txt") {
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

private struct HandState: Hashable {
	let h1: Hand
	let h2: Hand
}

private struct Hand: Hashable, CustomStringConvertible {
	var description: String {
		return "\(player):\(cards)"
	}
	
	private(set) var player: String
	private(set) var cards: [Int]

	init(data: [String]) {
		//print(data)
		var mData = data
		
		// Read the player name
		var firstLine = mData.removeFirst()
		firstLine.removeLast()
		player = firstLine
		
		// Read the cards
		cards = mData.compactMap({Int($0)}).reversed()
	}
	
	init(player name:String, cards: [Int]) {
		self.player = name
		self.cards = cards
	}
	
	mutating func draw() -> Int? {
		if cards.count > 0 {
			return cards.removeLast()
		}
		return nil
	}
	
	mutating func addCards(cards toAdd: [Int]) {
		cards.insert(contentsOf: toAdd.reversed(), at: 0)
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
	
	func copy(withNumCards count: Int) -> Hand {
		//print("Source: \(self)")
		let copy = Hand(player: player, cards: Array(cards.suffix(count)))
		//print("Copy: \(copy)")
		return copy
	}
}
