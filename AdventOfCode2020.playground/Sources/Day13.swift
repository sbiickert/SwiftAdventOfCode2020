import Foundation

public class Day13 {
	
	// Examples
	//let busSched = ["17", "x", "13", "19"]
	//let answer = 20
	//let busSched = ["7","13","x","x","59","x","31","19"]
	//let answer = 1068781
	//let busSched = ["17","x","13","19"]
	//let answer = 3417
	//let busSched = ["67","7","59","61"]
	//let answer = 754018
	//let busSched = ["67","x","7","59","61"]
	//let answer = 779210
	//let busSched = ["67","7","x","59","61"]
	//let answer = 1261476
	//let busSched = ["1789","37","47","1889"]
	//let answer = 1202161486

	public static func solve(inputSched: [String]?) {
		var busSched = inputSched
		if inputSched == nil {
			// Challenge Input. The answer will be over 100000000000000
			let input = readInputFile(named: "Day13_Input", removingEmptyLines: true)
			busSched = input[1].components(separatedBy: ",")
		}
		//part1(input)
		print(busSched!)
		let result = findTimestamp(busSched!)
		print("Expected \(100), got \(result)")
	}
	
	static func findTimestamp(_ input: [String]) -> Int {
		let busSched: [Int?] = input.map({ Int($0) })
		var busIDs = [Int]()
		var offsets = [Int]()
		var lookingFor = [Int]()
		for offset in stride(from: 0, to: busSched.count, by: 1) {
			if let id = busSched[offset] {
				busIDs.append(id)
				offsets.append(offset)
				var lf = id - offset
				while lf <= 0 {
					lf += id // avoid negative numbers
				}
				lookingFor.append(lf)
			}
		}
		lookingFor[0] = 0
		print("busIDs:      \(busIDs)")
		print("offsets:     \(offsets)")
		print("looking for: \(lookingFor)")
		
		/*
		After bus1 and bus2 sync up, the time to their next sync is (bus1 * bus2). So, we only have to check
		those times. After bus3 syncs up, the time to the sync up is (bus1 * bus2 * bus3), and so.
		*/
		
		var ts = 0
		var timesSinceDepart = busIDs.map { ts % $0 }
		print("\(ts): \(timesSinceDepart)")
		var maxSync = 0
		var jump = busIDs[maxSync] // Start looking for bus0 and bus1 sync
		while true {
			if timesSinceDepart[0...maxSync+1] == lookingFor[0...maxSync+1] {
				// Found sync
				maxSync += 1
				print("Found sync. maxSync now \(maxSync)")
				if maxSync == busIDs.count - 1 {
					print("Found solution: \(ts)")
					return ts
				}
				jump *= busIDs[maxSync]
				print("Found sync. Changed jump to \(jump)")
			}
			ts += jump
			timesSinceDepart = busIDs.map { ts % $0 }
			print("\(ts): \(timesSinceDepart)")
		}
		return ts
	}
		
	static func part1(_ input: [String]) {
		let earliestDepartTime = Int(input[0])!
		let busIDs = input[1].components(separatedBy: ",").compactMap({ Int($0)}).sorted()
		print(busIDs)
		var delay = 0
		var timesSinceDepart = busIDs.map { earliestDepartTime % $0 }
		while timesSinceDepart.contains(0) == false {
			delay += 1
			timesSinceDepart = busIDs.map { (earliestDepartTime + delay) % $0 }
		}
		print(timesSinceDepart)
		let busIndex = timesSinceDepart.firstIndex(of: 0)!
		print("Bus \(busIDs[busIndex]) is the first to depart with a delay of \(delay) minutes.")
		print("Part 1 answer: \(busIDs[busIndex] * delay)")
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
}

