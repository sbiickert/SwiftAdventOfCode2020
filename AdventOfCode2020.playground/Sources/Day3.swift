import Foundation

public class Day3 {
	public static func solve() {
		let theHill = Hill()
		
		var product = 1
		
		let runs = [(1,1),(3,1),(5,1),(7,1),(1,2)]
		for run in runs {
			product *= slide(down: theHill, run: run.0, drop: run.1)
		}
		
		print("The product of all collisions is \(product)")
	}
	
	static func slide(down hill:Hill, run: Int, drop: Int) -> Int {
		var treeCount = 0
		var index = 0
		
		for row in stride(from: 0, to: hill.rows.count, by: drop) {
			if hill.isTree(at: row, index: index) {
				treeCount += 1
				//print("\(row+1), \((index % theHill.rows[row].pattern.count)+1): THUMP!")
			}
			index += run
		}
		print("The total number of trees hit (run: \(run), drop: \(drop)) is \(treeCount)")
		return treeCount
	}
}


struct Hill {
	let rows: [HillRow]
	
	init() {
		var theRows = [HillRow]()
		let strRows = Hill.readInputFile(named: "Day3_Input", removingEmptyLines: true)
		theRows = strRows.compactMap {
			let hr = HillRow(pattern: $0)
			return hr.pattern.count > 0 ? hr : nil
		}
		self.rows = theRows
	}
	
	func isTree(at row: Int, index: Int) -> Bool {
		return rows[row].isTree(at: index)
	}

	public static func readInputFile(named name:String, removingEmptyLines removeEmpty:Bool) -> [String] {
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

struct HillRow {
	static let TREE:Character = "#"
	static let SNOW:Character = "."
	let pattern: String
	
	func isTree(at index: Int) -> Bool {
		let wrappedIndex = index % pattern.count
		let idxStart = pattern.index(pattern.startIndex, offsetBy: wrappedIndex)
		let idxEnd   = pattern.index(pattern.startIndex, offsetBy: wrappedIndex + 1)
		let char = pattern[idxStart..<idxEnd].first
		return char == HillRow.TREE
	}
}
