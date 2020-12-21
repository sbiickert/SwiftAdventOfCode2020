import Foundation

public class Day20 {
	
	public static func solve() {
		let input = readGroupedInputFile(named: "Day20_Input")
		
		var tiles = [Tile]()
		for group in input {
			let t = Tile(data: group)
			tiles.append(t)
			//print(t)
		}
		
		// The input for the challenge is 144 tiles, 12x12. Making plenty of space.
		let row = [Tile?](repeating: nil, count: 50)
		var board = [[Tile?]](repeating: row, count: 50)
		
		// First move.
		var ptrs = [Coord2D]()
		ptrs.append(Coord2D(x: 25, y: 25))
		var tile = tiles.removeLast()
		var ptr = ptrs.removeLast()
		board[ptr.y][ptr.x] = tile
		
		while tiles.count > 0 {
			print("Finding neighbors of tile \(tile.id)")
			for side in Tile.Side.allCases {
				let sideStr = tile.getSide(side, reversed: false)
				for (otherIndex, otherTile) in tiles.enumerated() {
					if otherTile.allSides.contains(sideStr) {
						//print("Found tile \(otherTile.id) matching side \(side): \(sideStr)")
						var otherSide = otherTile.findSide(matching: sideStr)!
						//print("The \(otherSide) of tile \(otherTile.id) needs be rotated to \(side.opposite), \(otherSide.numberOfRotates(to: side.opposite)) times.")
						otherTile.rotate(times: otherSide.numberOfRotates(to: side.opposite))
						otherSide = otherTile.findSide(matching: sideStr)!
						//print("Checking. otherSide should now be \(side.opposite): \(otherSide)")
						if sideStr != otherTile.getSide(otherSide, reversed: false) {
							if otherSide == .bottom || otherSide == .top {
								otherTile.flipHorizontal()
							}
							else {
								otherTile.flipVertical()
							}
						}
						//print(tile.getSide(side, reversed: false))
						//print(otherTile.getSide(otherSide, reversed: false))
						let delta = side.deltaCoordsInDirection
						let coord = Coord2D(x: ptr.x+delta.x, y: ptr.y+delta.y)
						ptrs.append(coord) // We will start working on this tile next
						board[coord.y][coord.x] = otherTile
						tiles.remove(at: otherIndex)
						break
					}
				}
			}
			ptr = ptrs.removeFirst()
			tile = board[ptr.y][ptr.x]!
		}
		
		let tileGrid = getMosaic(board)
		let singleTile = joinTiles(tileGrid)
		print(singleTile)
		print("Finding monsters...")
		var monsterCount = 0
		for flip in ["", "v", "h"] {
			if flip == "v" {
				print("flip V")
				singleTile.flipVertical()
			}
			else if flip == "h" {
				print("flip H")
				singleTile.flipHorizontal()
			}
			for _ in 0..<4 {
				let foundMonsterCount = singleTile.findSeaMonsters()
				if foundMonsterCount > 0 {
					print("Found \(foundMonsterCount) monsters")
					monsterCount = max(monsterCount, foundMonsterCount)
					print(singleTile.exportData().joined())
					//break
				}
				print("rotating")
				singleTile.rotate(times: 1)
			}
			if monsterCount > 0 {
				//break
			}
			// Revert
			if flip == "v" {
				print("flip V revert")
				singleTile.flipVertical()
			}
			else if flip == "h" {
				print("flip H revert")
				singleTile.flipHorizontal()
			}
		}
		print(singleTile)
		//let nHashesInMonsters = 15 * monsterCount
		let nHashesInTile = singleTile.count(string: "#")
		print("The number of monsters is \(monsterCount)")
		print("The number of # characters is \(nHashesInTile)")
	}
	
	private static func getMosaic(_ board: [[Tile?]], debug: Bool = false) -> [[Tile]] {
		var idGrid = [[Int]]()
		var tileGrid = [[Tile]]()
		var tileRow = [Tile]()
		for (i, row) in board.enumerated() {
			for (j, t) in row.enumerated() {
				if let tile = t {
					tileRow.append(tile)
					if debug {
						print("x: \(j), y: \(i)")
						print(tile)
						print("") // Newline spacer
					}
				}
				else if tileRow.count > 0 {
					idGrid.append(tileRow.map{$0.id})
					tileGrid.append(tileRow)
					tileRow = [Tile]()
				}
			}
		}
		print(idGrid)
		let corners: [Int] = [idGrid[0].first!, idGrid[0].last!, idGrid[idGrid.count-1].first!, idGrid[idGrid.count-1].last!]
		print("Answer: \(corners.reduce(1, *))")
		return(tileGrid)
	}
	
	private static func joinTiles(_ tileGrid: [[Tile]]) -> Tile {
		for row in tileGrid {
			for tile in row {
				tile.inset()
			}
		}
		print(tileGrid[0][0])
		var joined = ["Tile 66:"]
		for row in tileGrid {
			var rowData: [String]?
			for tile in row {
				let data = tile.exportData()
				if rowData == nil {
					rowData = data
				}
				else {
					for (i, tileRow) in data.enumerated() {
						rowData![i] += tileRow
					}
				}
			}
			joined.append(contentsOf: rowData!)
		}
		return Tile(data: joined)
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

private struct Coord2D {
	let x: Int
	let y: Int
}

private class Tile: CustomStringConvertible {
	private static let monsterRedef = "(#).{X}(#).{4}(##).{4}(##).{4}(###).{X}(#).{2}(#).{2}(#).{2}(#).{2}(#).{2}(#)"
	private static let monsterGroupCount = 11 // Number of matching groups () in above
	
	enum Side: Int, CaseIterable {
		case top = 0
		case right = 1
		case bottom = 2
		case left = 3
		
		var opposite: Side {
			var oppVal = self.rawValue - 2
			while oppVal < 0 {
				oppVal += 4
			}
			return Side(rawValue: oppVal)!
		}
		
		func numberOfRotates(to other: Side) -> Int {
			var value = self.rawValue
			var count = 0
			while value != other.rawValue {
				value += 1
				if value > Side.left.rawValue {
					value -= 4
				}
				count += 1
			}
			return count
		}
		
		var deltaCoordsInDirection: (x: Int, y: Int) {
			switch self {
			case .top:
				return (x: 0, y: -1)
			case .bottom:
				return (x: 0, y: 1)
			case .left:
				return (x: -1, y: 0)
			case .right:
				return (x: 1, y: 0)
			}
		}
	}
	var description: String {
		var info = [String]()
		info.append("Tile: \(id)")
		info.append(contentsOf: _matrix.exportData())
		return info.joined(separator: "\n")
	}
	
	var id: Int
	private var _matrix: Matrix
	
	init(data: [String]) {
		var mData = data
		// First line is "Tile NN:"
		let firstLine = mData.removeFirst().components(separatedBy: " ")
		var tileID = firstLine[1]
		tileID.removeLast()
		id = Int(tileID)!

		// Remaining lines are a grid of # and .
		_matrix = Matrix(rows: mData.count, columns: mData[0].count)
		_matrix.importData(mData)
	}
	
	func getSide(_ side:Side, reversed: Bool) -> String {
		// String with the chars for the side of the matrix
		var s = ""
		switch side {
		case .top:
			for col in 0..<_matrix.size.w {
				s += _matrix[0, col]
			}
		case .bottom:
			let row = _matrix.size.h-1
			for col in 0..<_matrix.size.w {
				s += _matrix[row, col]
			}
		case .right:
			let col = _matrix.size.w-1
			for row in 0..<_matrix.size.h {
				s += _matrix[row, col]
			}
		case .left:
			for row in 0..<_matrix.size.h {
				s += _matrix[row, 0]
			}
		}
		return reversed ? String(s.reversed()) : s
	}
	
	var allSides: Set<String> {
		var set = Set<String>()
		for side in Side.allCases {
			set.insert(getSide(side, reversed: false))
			set.insert(getSide(side, reversed: true))
		}
		return set
	}
	
	func findSide(matching input: String) -> Side? {
		for side in Side.allCases {
			if input == getSide(side, reversed: true) || input == getSide(side, reversed: false) {
				return side
			}
		}
		return nil
	}
	
	func rotate(times: Int) {
		for _ in 0..<times {
			_matrix.rotate()
		}
	}
	
	func flipHorizontal() {
		_matrix.flipHorizontal()
	}
	
	func flipVertical() {
		_matrix.flipVertical()
	}
	
	func inset() {
		let oldSize = _matrix.size
		var data = _matrix.exportData()
		data.removeFirst()
		data.removeLast()
		for (i, var row) in data.enumerated() {
			row.removeFirst()
			row.removeLast()
			data[i] = row
		}
		var smallerMatrix = Matrix(rows: oldSize.h-2, columns: oldSize.w-2)
		smallerMatrix.importData(data)
		self._matrix = smallerMatrix
	}
	
	func exportData() -> [String] {
		return _matrix.exportData()
	}
	
	func findSeaMonsters() -> Int {
		let monsterWidth = 20
		let wrapWidth = _matrix.size.w - monsterWidth + 1
		let mRedef = Tile.monsterRedef.replacingOccurrences(of: "X", with: String(wrapWidth))
		//print("Using regular expression \(mRedef)")
		var mRegex: NSRegularExpression?
		do {
			mRegex = try NSRegularExpression(pattern: mRedef, options: [])
		} catch {
			print("Error creating regular expression.")
		}
		guard mRegex != nil else {
			return 0
		}
		var data = exportData().joined()
		var monsterCount = 0
		var additionalMonsterCount = 999
		while additionalMonsterCount > 0 {
			additionalMonsterCount = 0
			let range = NSRange(location: 0, length: data.utf16.count)
			if let matches = mRegex?.matches(in: data, options: [], range: range) {
				additionalMonsterCount = matches.count
				monsterCount += additionalMonsterCount
				
				// Replace monster # with O
				for match in matches {
					for i in 1...Tile.monsterGroupCount {
						if let r = Range(match.range(at: i), in: data) {
							let length = r.upperBound.utf16Offset(in: data) - r.lowerBound.utf16Offset(in: data)
							data.replaceSubrange(r, with: String(repeating: "O", count: length))
						}
					}
				}
			}
		}
		_matrix.grid = Array(data).map({String($0)})

		return monsterCount
	}
	
	func count(string: String) -> Int {
		return _matrix.grid.filter({$0 == string}).count
	}
}

struct Matrix {
	
	public init(rows: Int, columns: Int) {
		self.rows = rows
		self.columns = columns
		grid = Array(repeating: ".", count: rows * columns)
	}
	
	public subscript(row: Int, column: Int) -> String {
		get {
			assert(indexIsValidForRow(row: row, column: column), "Index out of range")
			return grid[(row * columns) + column]
		}
		set {
			assert(indexIsValidForRow(row: row, column: column), "Index out of range")
			grid[(row * columns) + column] = newValue
		}
	}

	// MARK: Private
	
	private let rows: Int, columns: Int
	var grid: [String]
	
	private func indexIsValidForRow(row: Int, column: Int) -> Bool {
		return row >= 0 && row < rows && column >= 0 && column < columns
	}
	
	var size: (w: Int, h: Int) {
		return (columns, rows)
	}
	
	mutating func importData(_ data: [String]) {
		for (i, line) in data.enumerated() {
			for (j, char) in Array(line).enumerated() {
				self[i, j] = String(char)
			}
		}
	}
	
	func exportData() -> [String] {
		var info = [String]()
		for row in 0..<size.h {
			var line = ""
			for col in 0..<size.w {
				line += self[row, col]
			}
			info.append(line)
		}
		return info
	}
}

extension Matrix: Equatable {}
func ==(lhs: Matrix, rhs: Matrix) -> Bool {
	return lhs.grid == rhs.grid
}

extension Matrix {
	mutating func fill() {
		for i in (0..<rows * columns) {
			grid[i] = "."
		}
	}
}

extension Matrix {
	
	mutating func rotate() {
		
		let layers = (rows%2 == 0) ? rows/2 : (rows - 1)/2  // rows/2 also works but I trust it less
		for layer in 0 ..< layers {
			
			let first = layer
			let last  = rows - 1 - layer
			
			for i in first..<last {
				
				//let top      = (first, i)
				//let left     = (last - (i - first), first)
				//let bottom   = (last, last - (i - first))
				//let right    = (i, last)
				
				let temp     = self[first, i]
				
				self[first, i] = self[last - (i - first), first]
				self[last - (i - first), first] = self[last, last - (i - first)]
				self[last, last - (i - first)] = self[i, last]
				self[i, last]  = temp
			}
		}
	}
	
	mutating func flipHorizontal() {
		var data = self.exportData()
		for (i, row) in data.enumerated() {
			data[i] = String(row.reversed())
		}
		self.importData(data)
	}
	
	mutating func flipVertical() {
		var data = self.exportData()
		data = data.reversed()
		self.importData(data)
	}
}
