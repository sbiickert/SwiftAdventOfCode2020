import Foundation

public class Day25 {
	// Challenge Input
	static let DOOR_PUBLIC_KEY = 10212254
	static let CARD_PUBLIC_KEY = 12577395
	//static let ENCRYPTION_KEY = 290487 // From Part 1
	
	// Test Input
//	static let DOOR_PUBLIC_KEY = 17807724
//	static let CARD_PUBLIC_KEY = 5764801
//	static let ENCRYPTION_KEY = 14897079 // Test answer Part 1

	static let MAGIC_NUMBER = 20201227
	static let HANDSHAKE_SUBJECT_NUMBER = 7
	
	public static func solve() {
		print("Find card loop size.")
		let cardLoopSize = findLoopSize(publicKey: CARD_PUBLIC_KEY)
		print("Find door loop size.")
		let doorLoopSize = findLoopSize(publicKey: DOOR_PUBLIC_KEY)

		// Do it both ways to check
		let encKey1 = transform(subjectNumber: DOOR_PUBLIC_KEY, loopSize: cardLoopSize)
		let encKey2 = transform(subjectNumber: CARD_PUBLIC_KEY, loopSize: doorLoopSize)

		print("Checking that \(encKey1) == \(encKey2)")
	}
	
	static func findLoopSize(publicKey: Int) -> Int {
		var loop = 0
		var value = 1
		while value != publicKey {
			loop += 1
			value *= HANDSHAKE_SUBJECT_NUMBER
			value = value % MAGIC_NUMBER
			if loop % 1000 == 0 {
				print("Loop \(loop): \(value)")
			}
		}
		print("Loop \(loop): \(value)")
		return loop
	}
	
	static func transform(subjectNumber: Int, loopSize: Int) -> Int {
		var value = 1
		for loop in 1...loopSize {
			value *= subjectNumber
			value = value % MAGIC_NUMBER
			if loop % 1000 == 0 {
				print("Loop \(loop): \(value)")
			}
		}
		print("Loop \(loopSize): \(value)")
		return value
	}
}
