import Foundation

let s = Day05()
let i = AoCInput.inputsFor(solution: s)
var r = s.solve(i[0]) // 0 is challenge, 1 is first test group, etc.
print("\(r.description)")

// Year End
//let solutions = [Day01(), Day02(), Day03(), Day04(),
//				 Day05(), Day06(), Day07(), Day08(),
//				 Day09(), Day10(), Day11(), Day12(),
//				 Day13(), Day14(), Day15(), Day16(),
//				 Day17(), Day18(), Day19(), Day20(),
//				 Day21(), Day22(), Day23(), Day24(), Day25()]
//for s in solutions {
//	let i = AoCInput.inputsFor(solution: s)
//	let r = s.solve(i[0])
//	print("\(r.description)")
//}

