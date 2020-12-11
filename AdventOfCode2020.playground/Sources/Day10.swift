import Foundation

public class Day10 {
	
	static let MIN_𝝙J = 1
	static let MAX_𝝙J = 3
	
	static var joltageTree = Node(value: 0)
	
	public static func solve() {
		// Example 1
		//var joltages = [16,10,15,5,1,11,7,19,6,12,4].sorted()
		// Example 2
		//var joltages = [28,33,18,42,31,14,46,20,48,47,24,23,49,45,19,38,39,11,1,32,25,35,8,17,7,9,4,2,34,10,3].sorted()
		// Real input
		let input = Input10Util.readInputFile(named: "Day10_Input", removingEmptyLines: true)
		var joltages: [Int] = input.compactMap({ Int($0) }).sorted()
		joltages.insert(0, at: 0) // The outlet
		joltages.append(joltages.last! + MAX_𝝙J) // The last diff is to the device, defined to be 3
		print(joltages)
		let product = part1(joltages)
		print("The solution for part 1 is \(product)")
		
		print("Building tree...")
		var joltageTree = Node(value: 0)
		createTree(from: joltages, at: 0, in: &joltageTree)
		
		print("Counting paths...")
		let count = traverse(node: joltageTree, count: 0)
		print("Found \(count) possible adapter combinations.")
	}
	
	static func createTree(from joltages: [Int], at index: Int, in parent:inout Node) {
		// Identify adapters that are less than the maximum change in joltage
		var nextAdapters = [Int]()
		for i in stride(from: MIN_𝝙J, through: MAX_𝝙J, by: 1) {
			if i+index < joltages.count && joltages[i+index] - joltages[index] <= MAX_𝝙J {
				nextAdapters.append(joltages[i+index])
			}
		}
		//print("From \(joltages[index]) can attach \(nextAdapters)")
		for (i, nextAdapter) in nextAdapters.enumerated() {
			var n = Node(value: nextAdapter)
			parent.add(child: n)
			createTree(from: joltages, at: index+i+1, in: &n)
		}
	}
	
	static func traverse(node: Node, count:Int) -> Int {
		if node.children.count == 0 {
			let path = [Int](node.path.map({ $0.value }).reversed())
			let updatedCount = count + 1
			//print("\(updatedCount): \(path)")
			return updatedCount
		}
		var updatedCount = count
		for child in node.children {
			updatedCount = traverse(node: child, count: updatedCount)
		}
		return updatedCount
	}
	
	static func part1(_ joltages: [Int]) -> Int {
		var diffs = [Int]()
		var lastJoltage = 0 // the seat outlet
		for joltage in joltages {
			let diff = joltage - lastJoltage
			if diff >= MIN_𝝙J && diff <= MAX_𝝙J {
				diffs.append(diff)
			}
			else {
				print("diff is \(diff)")
			}
			lastJoltage = joltage
		}
		//print(diffs)
		let counts = Dictionary(diffs.map({ ($0, 1) }), uniquingKeysWith: +)
		//print("There are \(counts[1]!) diffs of 1 and \(counts[3]!) diffs of 3.")
		if let diff1 = counts[MIN_𝝙J],
		   let diff3 = counts[MAX_𝝙J] {
			return diff1 * diff3
		}
		return 0
	}
	
	//		let chains = findAdapterChains(in: joltages, startingAt: 0, building: 0, foundSoFar: [[0]])
	//		print("Found \(chains.count) combinations of adapters.")
	//		for chain in chains {
	//			print(chain)
	//		}
//	static func findAdapterChains(in joltages:[Int], startingAt index:Int, building chainIndex: Int, foundSoFar: [[Int]]) -> [[Int]] {
//		var mutableFSF = foundSoFar
//
//		// Identify adapters that are less than the maximum change in joltage
//		var nextAdapters = [Int]()
//		for i in stride(from: MIN_𝝙J, through: MAX_𝝙J, by: 1) {
//			if i+index < joltages.count && joltages[i+index] - joltages[index] <= MAX_𝝙J {
//				nextAdapters.append(joltages[i+index])
//			}
//		}
//		//print("From \(joltages[index]) can attach \(nextAdapters)")
//
//		// If there is more than one option, copy the chain
//		var chainIndexes = [chainIndex]
//		for _ in stride(from: 1, to: nextAdapters.count, by: 1) {
//			mutableFSF.append(mutableFSF[chainIndex])
//			chainIndexes.append(mutableFSF.count-1)
//		}
//
//		for (i, nextAdapter) in nextAdapters.enumerated() {
//			mutableFSF[chainIndexes[i]].append(nextAdapter)
//			mutableFSF = findAdapterChains(in: joltages, startingAt: index+i+1, building: chainIndexes[i], foundSoFar: mutableFSF)
//		}
//
//		return mutableFSF
//	}
	
}

class Node {
	var value: Int
	var children: [Node] = []
	weak var parent: Node?
	
	init(value: Int) {
		self.value = value
	}
	
	func add(child: Node) {
		children.append(child)
		child.parent = self
	}
	
	var path: [Node] {
		var ptr = self
		var value = [ptr]
		while let p = ptr.parent {
			ptr = p
			value.append(ptr)
		}
		return value
	}
}

private class Input10Util {
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
