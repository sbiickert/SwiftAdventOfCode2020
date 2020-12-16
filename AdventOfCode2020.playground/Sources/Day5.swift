import Foundation

public class Day5 {
	
	public static func solve() {
		let tickets = readTickets() // ids are sorted ascending
		print("The highest seat id is \(tickets.last?.id ?? -1)")
		var ids = tickets.map {$0.id}
		let idSet = Set(ids)
		// We aren't the first or last seat, according to the challenge
		ids.removeFirst()
		ids.removeLast()
		for id in stride(from: ids.first!, to: ids.last!, by: 1) {
			if idSet.contains(id) == false {
				let row = Int(id / 8)
				let seat = id % 8
				print("My seat is \(id): row \(row) and seat \(seat)")
				break
			}
		}
	}

	private static func readTickets() -> [Ticket] {
		var tickets = [Ticket]()
		if let inputPath = Bundle.main.path(forResource: "Day5_Input", ofType: "txt") {
			do {
				let input = try String(contentsOfFile: inputPath)
				let strTickets = input.components(separatedBy: "\n")
				tickets = strTickets.compactMap {
					let t = Ticket(code: $0)
					return t.isValid ? t : nil
				}
				tickets.sort(by: {$0.id < $1.id})
			} catch {
				
			}
		}
		return tickets
	}
}

private struct Ticket {
	let code: String
	let row: Int
	let seat: Int
	
	init(code value: String) {
		self.code = value
		guard code.count == 10 else {
			row = -1
			seat = -1
			return
		}
		let code = value
		let binary = code.replacingOccurrences(of: "F", with: "0")
			.replacingOccurrences(of: "B", with: "1")
			.replacingOccurrences(of: "L", with: "0")
			.replacingOccurrences(of: "R", with: "1")
		let splitIndex = binary.index(binary.startIndex, offsetBy: 7)
		let rowBinary = binary[binary.startIndex..<splitIndex]
		let seatBinary = binary[splitIndex..<binary.endIndex]
		
		self.row = Int(rowBinary, radix: 2) ?? -1
		self.seat = Int(seatBinary, radix: 2) ?? -1
	}
	
	var isValid: Bool {
		return row >= 0 && seat >= 0
	}
	
	var id: Int {
		return (row * 8) + seat
	}
}
