import Cocoa

//Day1.solveForTwo()
//Day1.solveForThree()
//Day2.solve()
//Day3.solve()
// Have refactored Days 1-3 to use the AOCUtil function to read lines
//Day4.solve()
//Day5.solve()
//Day6.solve()
// Using AOCUtil functions
//Day7.solve()
//Day8.solve()
//Day9.solve()
//Day10.solve()
//Day11.solve()
//Day12.solve()
//Day13.solve(inputSched: nil)
//Day14.solve()
//Day15.solve()
//Day16.solve()
//Day17.solve()
//Day18.solve(testing: false)

//Day19.solve(testing: true)

//Day20.solve()
//Day21.solve(testing: false)
//Day22.solve(testing: false)
//Day23.solve()
//Day24.solve(testing: false)

//Day25.solve()

let line = "0: 4 1 5"
let cs = CharacterSet(charactersIn: "ab")
let value = "\"b\""
let filtered = String(value.unicodeScalars.filter({cs.contains($0)}))
filtered
