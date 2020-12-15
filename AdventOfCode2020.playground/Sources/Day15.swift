import Foundation

public class Day15 {
	
	//static let MAX_TURN = 2020
	static let MAX_TURN = 30000000

	public static func solve() {
		//let input = [0,3,6] // 436, 175594
		//let input = [1,3,2] // 1, 2578
		//let input = [2,1,3] // 10, 3544142
		//let input = [1,2,3] // 27, 261214
		//let input = [2,3,1] // 78, 6895259
		//let input = [3,2,1] // 438, 18
		//let input = [3,1,2] // 1836, 362
		// The real input
		let input = [15,5,1,4,7,0]
		
		var history = Dictionary<Int,NumberHistory>()
		for turn in 1...input.count {
			history[input[turn-1]] = NumberHistory(number: input[turn-1], turn: turn)  // Note the turn that these numbers were said
		}
		//print(history)
		var lastNumberSaid = input.last!
		var thisTurnNumber = 0
		for turn in (input.count+1)...MAX_TURN {
			thisTurnNumber = 0 // default, if not in history
			if let h = history[lastNumberSaid] {
				//print(h)
				thisTurnNumber = h.age // age of the number
			}
			if let h = history[thisTurnNumber] {
				h.mostRecent = turn
			}
			else {
				let h = NumberHistory(number: thisTurnNumber, turn: turn)
				history[thisTurnNumber] = h
			}
			//print("\(turn): \(history[thisTurnNumber]!)")
			lastNumberSaid = thisTurnNumber
			if turn % 1000000 == 0 {
				print(turn)
			}
		}
		let answer = thisTurnNumber
		print("The number said on the last turn is \(answer)")
	}
}

class NumberHistory: CustomStringConvertible {
	var description: String {
		return "\(number) was last said on \(mostRecent), and \(previous ?? -1) before that."
	}
	
	init(number: Int, turn: Int) {
		self.number = number
		self.mostRecent = turn
	}
	
	private(set) var number: Int
	var mostRecent: Int {
		didSet {
			_prev = oldValue
		}
	}
	private var _prev: Int?
	var previous: Int? {
		return _prev
	}
	var age: Int {
		if let p = _prev {
			return mostRecent - p
		}
		return 0
	}
}
