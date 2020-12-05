import Cocoa

//Day1.solveForTwo()
//Day1.solveForThree()
//Day2.solve()
Day3.solve()

public class Day3 {
	public static func solve() {
		let theHill = Hill()
		
		var treeCount = 0
		var index = 0
		
		for row in 0..<theHill.rows.count {
			if theHill.isTree(at: row, index: index) {
				treeCount += 1
				//print("\(row+1), \((index % theHill.rows[row].pattern.count)+1): THUMP!")
			}
			index += 3
		}
		
		print("The total number of trees hit: \(treeCount)")
	}
}


public struct Hill {
	let rows: [HillRow]
	
	init() {
		var theRows = [HillRow]()
		if let inputPath = Bundle.main.path(forResource: "Day3_Input", ofType: "txt") {
			do {
				let input = try String(contentsOfFile: inputPath)
				let strRows = input.components(separatedBy: "\n")
				theRows = strRows.compactMap {
					let hr = HillRow(pattern: $0)
					return hr.pattern.count > 0 ? hr : nil
				}
			} catch {
			 
			}
		}
		self.rows = theRows
	}
	
	func isTree(at row: Int, index: Int) -> Bool {
		return rows[row].isTree(at: index)
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
