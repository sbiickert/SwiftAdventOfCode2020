//
//  AoCArrayGridTests.swift
//  AoCLibraryTests
//
//  Most of these tests use non-square grids in which every cell holds a
//  different letter, so that swapping X and Y, or width and height, or being
//  off by one at an edge, produces a visibly wrong answer.
//

import Testing
import Foundation

@Suite("AoCArrayGrid: loading and values")
struct AoCArrayGridValueTests {

    @Test func aNewGridIsEmpty() {
        let grid = AoCArrayGrid(defaultValue: ".", rule: .rook)
        #expect(grid.defaultValue == ".")
        #expect(grid.rule == .rook)
        #expect(grid.extent == nil)
        #expect(grid.isTiledInfinitely == false)
        #expect(grid.coords.isEmpty)
        #expect(grid.histogram.isEmpty)
        #expect(grid.stringValue(at: .origin) == ".")
    }

    @Test func initTakesADefaultValueAndAnAdjacencyRule() {
        let grid = AoCArrayGrid(defaultValue: " ", rule: .queen)
        #expect(grid.defaultValue == " ")
        #expect(grid.rule == .queen)
        #expect(grid.stringValue(at: AoCCoord2D(x: 99, y: 99)) == " ")
    }

    @Test(arguments: [asymmetricRows, tallRows])
    func loadPlacesEveryCell(rows: [String]) {
        let grid = makeArrayGrid(rows)
        for y in 0..<rows.count {
            for x in 0..<rows[0].count {
                let expected = letter(in: rows, x: x, y: y)
                #expect(grid.stringValue(at: AoCCoord2D(x: x, y: y)) == expected, "at (\(x), \(y))")
                #expect(grid.stringValue(x: x, y: y) == expected, "at (\(x), \(y))")
                #expect(grid.value(at: AoCCoord2D(x: x, y: y)) as? String == expected, "at (\(x), \(y))")
                #expect(grid.value(x: x, y: y) as? String == expected, "at (\(x), \(y))")
            }
        }
    }

    @Test func loadUsesColumnForXAndRowForY() {
        let grid = makeArrayGrid(["...",
                                  "..#"])
        #expect(grid.stringValue(at: AoCCoord2D(x: 2, y: 1)) == "#")
        #expect(grid.stringValue(at: AoCCoord2D(x: 1, y: 2)) == ".")
    }

    @Test func loadStoresDefaultValuedCellsToo() {
        let grid = makeArrayGrid(["..#",
                                  ".#.",
                                  "#.."])
        #expect(grid.stringValue(at: AoCCoord2D(x: 0, y: 0)) == ".")
        #expect(grid.stringValue(at: AoCCoord2D(x: 2, y: 0)) == "#")
        #expect(grid.stringValue(at: AoCCoord2D(x: 1, y: 1)) == "#")
        #expect(grid.stringValue(at: AoCCoord2D(x: 0, y: 2)) == "#")
    }

    @Test func extentOfAWideGrid() throws {
        let grid = makeArrayGrid(asymmetricRows)
        let ext = try #require(grid.extent)
        #expect(ext == AoCExtent2D.build(0, 0, 3, 2))
        #expect(ext.width == 4)
        #expect(ext.height == 3)
    }

    @Test func extentOfATallGrid() throws {
        let grid = makeArrayGrid(tallRows)
        let ext = try #require(grid.extent)
        #expect(ext == AoCExtent2D.build(0, 0, 1, 3))
        #expect(ext.width == 2)
        #expect(ext.height == 4)
    }

    @Test func extentOfASingleCellGrid() {
        let grid = makeArrayGrid(["#"])
        #expect(grid.extent == AoCExtent2D.build(0, 0, 0, 0))
        #expect(grid.stringValue(at: .origin) == "#")
    }

    @Test func loadingNoRowsLeavesTheGridEmpty() {
        #expect(makeArrayGrid([]).extent == nil)
        #expect(makeArrayGrid([""]).extent == nil)
    }

    @Test func settingTheExtentSizesAnEmptyGrid() throws {
        let grid = AoCArrayGrid(defaultValue: ".", rule: .rook)
        grid.extent = AoCExtent2D.build(0, 0, 4, 1)
        let ext = try #require(grid.extent)
        #expect(ext.width == 5)
        #expect(ext.height == 2)
        #expect(grid.histogram == [".": 10])
        #expect(grid.coords.count == 10)
    }

    @Test func settingTheExtentToNilEmptiesTheGrid() {
        let grid = makeArrayGrid(asymmetricRows)
        grid.extent = nil
        #expect(grid.extent == nil)
        #expect(grid.coords.isEmpty)
        #expect(grid.stringValue(at: .origin) == ".")
    }

    /// The corners and the last row and column are where off-by-one errors show up.
    @Test(arguments: [asymmetricRows, tallRows])
    func cornersAreReadCorrectly(rows: [String]) {
        let grid = makeArrayGrid(rows)
        let maxX = rows[0].count - 1
        let maxY = rows.count - 1
        #expect(grid.stringValue(x: 0, y: 0) == letter(in: rows, x: 0, y: 0))
        #expect(grid.stringValue(x: maxX, y: 0) == letter(in: rows, x: maxX, y: 0))
        #expect(grid.stringValue(x: 0, y: maxY) == letter(in: rows, x: 0, y: maxY))
        #expect(grid.stringValue(x: maxX, y: maxY) == letter(in: rows, x: maxX, y: maxY))
    }

    /// One step past each edge must be outside the grid.
    @Test(arguments: [asymmetricRows, tallRows])
    func justOutsideEachEdgeIsTheDefaultValue(rows: [String]) {
        let grid = makeArrayGrid(rows)
        let width = rows[0].count
        let height = rows.count
        #expect(grid.stringValue(x: -1, y: 0) == ".")
        #expect(grid.stringValue(x: 0, y: -1) == ".")
        #expect(grid.stringValue(x: width, y: 0) == ".")
        #expect(grid.stringValue(x: 0, y: height) == ".")
        #expect(grid.stringValue(x: width, y: height) == ".")
        #expect(grid.value(x: width, y: 0) as? String == ".")
        #expect(grid.value(x: 0, y: height) as? String == ".")
    }

    /// Reading far past the bottom of a tall grid must not crash. This runs in a
    /// child process so that a crash fails this test instead of the whole run.
    @Test func readingFarOutsideATallGridDoesNotCrash() async {
        await #expect(processExitsWith: .success) {
            let grid = makeArrayGrid(tallRows)
            _ = grid.stringValue(x: 0, y: 10)
            _ = grid.value(x: 0, y: 10)
        }
    }

    @Test func settingAValueInAWideGridIsReadBackAtTheSameCoord() {
        let grid = makeArrayGrid(asymmetricRows)
        // x = 3 is a valid column even though the grid is only 3 rows tall.
        grid.setValue("Z", at: AoCCoord2D(x: 3, y: 0))
        #expect(grid.stringValue(at: AoCCoord2D(x: 3, y: 0)) == "Z")
        #expect(grid.stringValue(at: AoCCoord2D(x: 0, y: 3)) == ".")
        grid.setValue("Y", x: 3, y: 2)
        #expect(grid.stringValue(x: 3, y: 2) == "Y")
    }

    @Test func settingAValueInATallGridIsReadBackAtTheSameCoord() {
        let grid = makeArrayGrid(tallRows)
        grid.setValue("Z", at: AoCCoord2D(x: 1, y: 3))
        #expect(grid.stringValue(at: AoCCoord2D(x: 1, y: 3)) == "Z")
        // The cell with x and y swapped is untouched.
        #expect(grid.stringValue(at: AoCCoord2D(x: 3, y: 1)) == ".")
        #expect(grid.stringValue(at: AoCCoord2D(x: 0, y: 3)) == "g")
    }

    @Test func settingAValueOnlyChangesThatCell() {
        let grid = makeArrayGrid(asymmetricRows)
        grid.setValue("Z", at: AoCCoord2D(x: 2, y: 1))
        var expected = asymmetricRows
        expected[1] = "efZh"
        #expect(grid.toString() == makeArrayGrid(expected).toString())
    }

    @Test func settingAValueOutsideTheGridIsIgnored() {
        let grid = makeArrayGrid(asymmetricRows)
        let before = grid.toString()
        grid.setValue("Z", at: AoCCoord2D(x: 4, y: 0))
        grid.setValue("Z", at: AoCCoord2D(x: 0, y: 3))
        grid.setValue("Z", at: AoCCoord2D(x: -1, y: 0))
        grid.setValue("Z", at: AoCCoord2D(x: 0, y: -1))
        #expect(grid.toString() == before)
        #expect(grid.extent == AoCExtent2D.build(0, 0, 3, 2))
        #expect(grid.getCoords(withValue: "Z").isEmpty)
    }

    /// Writing far past the bottom of a tall grid must be ignored, not crash.
    @Test func writingFarOutsideATallGridDoesNotCrash() async {
        await #expect(processExitsWith: .success) {
            let grid = makeArrayGrid(tallRows)
            grid.setValue("Z", x: 0, y: 10)
            grid.clear(x: 0, y: 10)
        }
    }

    @Test func nonStringValuesAreStoredAndRenderedByInterpolation() {
        let grid = makeArrayGrid(["..",
                                  ".."])
        let c = AoCCoord2D(x: 1, y: 0)
        grid.setValue(42, at: c)
        #expect(grid.value(at: c) as? Int == 42)
        #expect(grid.stringValue(at: c) == "42")
    }

    @Test func renderableValuesAreDrawnWithTheirGlyph() {
        let grid = makeArrayGrid(["..",
                                  ".."])
        let c = AoCCoord2D(x: 0, y: 1)
        grid.setValue(TestGlyph(glyph: "@"), at: c)
        #expect(grid.value(at: c) as? TestGlyph == TestGlyph(glyph: "@"))
        #expect(grid.stringValue(at: c) == "@")
    }

    @Test func clearResetsACellToTheDefaultValue() {
        let grid = makeArrayGrid(asymmetricRows)
        grid.clear(at: AoCCoord2D(x: 3, y: 1))
        #expect(grid.stringValue(at: AoCCoord2D(x: 3, y: 1)) == ".")
        #expect(grid.stringValue(at: AoCCoord2D(x: 1, y: 3)) == ".")
        #expect(grid.stringValue(at: AoCCoord2D(x: 2, y: 1)) == "g")
        grid.clear(x: 1, y: 2)
        #expect(grid.stringValue(x: 1, y: 2) == ".")
        #expect(grid.extent == AoCExtent2D.build(0, 0, 3, 2))
    }

    @Test func clearingOutsideTheGridIsHarmless() {
        let grid = makeArrayGrid(asymmetricRows)
        let before = grid.toString()
        grid.clear(at: AoCCoord2D(x: 4, y: 2))
        grid.clear(at: AoCCoord2D(x: -1, y: -1))
        #expect(grid.toString() == before)
    }
}

@Suite("AoCArrayGrid: coords, getCoords and histogram")
struct AoCArrayGridQueryTests {

    /// Every cell of an array grid is stored, so `coords` is every coord in the extent.
    @Test(arguments: [asymmetricRows, tallRows])
    func coordsListsEveryCellExactlyOnce(rows: [String]) throws {
        let grid = makeArrayGrid(rows)
        let ext = try #require(grid.extent)
        #expect(grid.coords.count == ext.area)
        #expect(Set(grid.coords) == Set(ext.allCoords))
    }

    @Test func getCoordsFindsCellsByRenderedValue() {
        let grid = makeArrayGrid(["A.B",
                                  "B.A"])
        #expect(Set(grid.getCoords(withValue: "A")) == Set([AoCCoord2D(x: 0, y: 0), AoCCoord2D(x: 2, y: 1)]))
        #expect(Set(grid.getCoords(withValue: "B")) == Set([AoCCoord2D(x: 2, y: 0), AoCCoord2D(x: 0, y: 1)]))
    }

    /// Each letter appears once, so each lookup pins down exactly one (x, y).
    @Test(arguments: [asymmetricRows, tallRows])
    func getCoordsFindsEveryLetterAtItsOwnCoord(rows: [String]) {
        let grid = makeArrayGrid(rows)
        for y in 0..<rows.count {
            for x in 0..<rows[0].count {
                let v = letter(in: rows, x: x, y: y)
                #expect(grid.getCoords(withValue: v) == [AoCCoord2D(x: x, y: y)], "letter \(v)")
            }
        }
    }

    @Test func getCoordsXYReturnsXThenY() {
        let grid = makeArrayGrid(asymmetricRows)
        let found = grid.getCoordsXY(withValue: "h")
        #expect(found.count == 1)
        #expect(found.first?.0 == 3)
        #expect(found.first?.1 == 1)
    }

    /// Unlike the dictionary grid, default-valued cells are stored and can be found.
    @Test func getCoordsFindsDefaultValuedCells() {
        let grid = makeArrayGrid(["A.B",
                                  "..."])
        #expect(Set(grid.getCoords(withValue: ".")) == Set([AoCCoord2D(x: 1, y: 0),
                                                            AoCCoord2D(x: 0, y: 1),
                                                            AoCCoord2D(x: 1, y: 1),
                                                            AoCCoord2D(x: 2, y: 1)]))
        #expect(grid.getCoords(withValue: "Z").isEmpty)
    }

    @Test func getCoordsMatchesRenderableAndNumericValues() {
        let grid = makeArrayGrid(["...",
                                  "..."])
        grid.setValue(7, at: AoCCoord2D(x: 2, y: 0))
        grid.setValue(TestGlyph(glyph: "@"), at: AoCCoord2D(x: 0, y: 1))
        #expect(grid.getCoords(withValue: "7") == [AoCCoord2D(x: 2, y: 0)])
        #expect(grid.getCoords(withValue: "@") == [AoCCoord2D(x: 0, y: 1)])
    }

    @Test func histogramCountsEveryCell() {
        let grid = makeArrayGrid(["..#",
                                  ".#.",
                                  "#.."])
        #expect(grid.histogram == ["#": 3, ".": 6])
    }

    @Test(arguments: [asymmetricRows, tallRows])
    func histogramOfANonSquareGridCountsEachLetterOnce(rows: [String]) throws {
        let grid = makeArrayGrid(rows)
        let ext = try #require(grid.extent)
        let letters = rows.joined().map { String($0) }
        #expect(grid.histogram == Dictionary(uniqueKeysWithValues: letters.map { ($0, 1) }))
        #expect(grid.histogram.values.reduce(0, +) == ext.area)
    }

    @Test func histogramOfAnEmptyGridIsEmpty() {
        #expect(AoCArrayGrid(defaultValue: ".", rule: .rook).histogram.isEmpty)
    }
}

@Suite("AoCArrayGrid: neighbours")
struct AoCArrayGridNeighbourTests {

    @Test func neighbourOffsetsFollowTheGridsRule() {
        #expect(makeArrayGrid(["#"], rule: .rook).neighbourOffsets.count == 4)
        #expect(makeArrayGrid(["#"], rule: .bishop).neighbourOffsets.count == 4)
        #expect(makeArrayGrid(["#"], rule: .queen).neighbourOffsets.count == 8)
        #expect(makeArrayGrid(["#"], rule: .queen).neighbourOffsets
                == AoCCoord2D.getAdjacentOffsets(rule: .queen))
    }

    @Test func neighbourCoordsAreNotClippedToTheExtent() {
        let grid = makeArrayGrid(["#"])
        let neighbours = grid.neighbourCoords(at: .origin)
        #expect(neighbours.count == 4)
        #expect(neighbours.contains(AoCCoord2D(x: 0, y: -1)))
        #expect(neighbours.contains(AoCCoord2D(x: -1, y: 0)))
    }

    @Test func neighbourCoordsFilteredByValue() {
        let grid = makeArrayGrid(["..#",
                                  ".#.",
                                  "#.."])
        let hashes = grid.neighbourCoords(at: AoCCoord2D(x: 1, y: 0), withValue: "#")
        #expect(Set(hashes) == Set([AoCCoord2D(x: 2, y: 0), AoCCoord2D(x: 1, y: 1)]))
    }

    /// The east-edge cell of a wide grid has neighbours whose x is >= the grid's height.
    @Test func neighboursAtTheEastEdgeOfAWideGrid() {
        let grid = makeArrayGrid(asymmetricRows, rule: .queen)
        let neighbours = grid.neighbourCoords(at: AoCCoord2D(x: 3, y: 1))
        let values = Set(neighbours.map { grid.stringValue(at: $0) })
        #expect(values == Set(["c", "d", "g", "k", "l", "."]))
        #expect(grid.neighbourCoords(at: AoCCoord2D(x: 3, y: 1), withValue: "d") == [AoCCoord2D(x: 3, y: 0)])
    }

    @Test func filteringByTheDefaultValueIncludesCellsOutsideTheExtent() {
        let grid = makeArrayGrid(["#"])
        #expect(grid.neighbourCoords(at: .origin, withValue: ".").count == 4)
    }

    @Test func queenNeighboursIncludeDiagonals() {
        let grid = makeArrayGrid(["#.#",
                                  ".X.",
                                  "#.#"], rule: .queen)
        let centre = AoCCoord2D(x: 1, y: 1)
        #expect(grid.neighbourCoords(at: centre).count == 8)
        #expect(grid.neighbourCoords(at: centre, withValue: "#").count == 4)
    }

    @Test func rookNeighboursExcludeDiagonals() {
        let grid = makeArrayGrid(["#.#",
                                  ".X.",
                                  "#.#"], rule: .rook)
        #expect(grid.neighbourCoords(at: AoCCoord2D(x: 1, y: 1), withValue: "#").isEmpty)
    }
}

@Suite("AoCArrayGrid: rendering")
struct AoCArrayGridRenderingTests {

    @Test func toStringDrawsTheExtentSpaceSeparated() {
        let grid = makeArrayGrid(["#.#",
                                  ".#.",
                                  "#.#"])
        #expect(grid.toString() == "# . #\n. # .\n# . #\n")
    }

    @Test func toStringOfAWideGrid() {
        #expect(makeArrayGrid(asymmetricRows).toString() == "a b c d\ne f g h\ni j k l\n")
    }

    @Test func toStringOfATallGrid() {
        #expect(makeArrayGrid(tallRows).toString() == "a b\nc d\ne f\ng h\n")
    }

    @Test func toStringOfAnEmptyGridIsEmpty() {
        #expect(AoCArrayGrid(defaultValue: ".", rule: .rook).toString() == "")
    }

    @Test func markersOverrideTheStoredValues() {
        let grid = makeArrayGrid(["#.",
                                  ".#"])
        let markers = [AoCCoord2D(x: 0, y: 0): "A", AoCCoord2D(x: 1, y: 0): "B"]
        #expect(grid.toString(markers: markers, drawExtent: nil) == "A B\n. #\n")
    }

    @Test func markersOutsideTheExtentAreNotDrawn() {
        let grid = makeArrayGrid(["#"])
        #expect(grid.toString(markers: [AoCCoord2D(x: 9, y: 9): "!"], drawExtent: nil) == "#\n")
    }

    @Test func aDrawExtentIsOnlyHonouredForTiledGrids() {
        let grid = makeArrayGrid(["#.",
                                  ".#"])
        let wider = AoCExtent2D.build(0, 0, 3, 1)
        // Not tiled: the draw extent is ignored.
        #expect(grid.toString(markers: nil, drawExtent: wider) == "# .\n. #\n")

        grid.isTiledInfinitely = true
        #expect(grid.toString(markers: nil, drawExtent: wider) == "# . # .\n. # . #\n")
    }
}

@Suite("AoCArrayGrid: infinite tiling")
struct AoCArrayGridTilingTests {

    private func tiledGrid() -> AoCArrayGrid {
        let grid = makeArrayGrid(asymmetricRows)
        grid.isTiledInfinitely = true
        return grid
    }

    @Test func coordsInsideTheExtentAreUnaffected() {
        let grid = tiledGrid()
        #expect(grid.stringValue(x: 0, y: 0) == "a")
        #expect(grid.stringValue(x: 3, y: 2) == "l")
    }

    /// The grid is 4 wide and 3 tall, so x wraps every 4 and y wraps every 3.
    @Test func valueWrapsEachAxisByItsOwnSize() {
        let grid = tiledGrid()
        #expect(grid.value(x: 4, y: 0) as? String == "a")
        #expect(grid.value(x: 0, y: 3) as? String == "a")
        #expect(grid.value(x: 5, y: 4) as? String == "f")
        #expect(grid.value(x: -1, y: -1) as? String == "l")
        #expect(grid.value(x: -4, y: -3) as? String == "a")
    }

    @Test func stringValueWrapsLikeValue() {
        let grid = tiledGrid()
        #expect(grid.stringValue(x: 4, y: 0) == "a")
        #expect(grid.stringValue(x: 0, y: 3) == "a")
        #expect(grid.stringValue(at: AoCCoord2D(x: 5, y: 4)) == "f")
        #expect(grid.stringValue(at: AoCCoord2D(x: -1, y: -1)) == "l")
    }

    @Test func tilingIsPeriodicInBothAxes() throws {
        let grid = tiledGrid()
        let ext = try #require(grid.extent)
        for coord in ext.allCoords {
            let shifted = AoCCoord2D(x: coord.x + 3 * ext.width, y: coord.y - 2 * ext.height)
            #expect(grid.stringValue(at: shifted) == grid.stringValue(at: coord))
            #expect(grid.value(at: shifted) as? String == grid.value(at: coord) as? String)
        }
    }

    @Test func withoutTilingOutOfBoundsCoordsAreTheDefaultValue() {
        let grid = makeArrayGrid(asymmetricRows)
        #expect(grid.stringValue(at: AoCCoord2D(x: 4, y: 0)) == ".")
        #expect(grid.value(at: AoCCoord2D(x: -1, y: -1)) as? String == ".")
    }
}

@Suite("AoCArrayGrid: flood fill")
struct AoCArrayGridFillTests {

    @Test func fillingAnEnclosedRegionPaintsEveryInteriorCell() {
        // 7 wide and 4 tall, so the interior includes x values past the height.
        let grid = makeArrayGrid(["#######",
                                  "#.....#",
                                  "#.....#",
                                  "#######"])
        var filled = [AoCCoord2D]()
        let escaped = grid.fill(with: "O", at: AoCCoord2D(x: 5, y: 2), filled: &filled)

        #expect(escaped == false)
        #expect(grid.getCoords(withValue: "O").count == 10)
        #expect(grid.getCoords(withValue: ".").isEmpty)
        #expect(grid.histogram == ["#": 18, "O": 10])
    }

    @Test func fillOnlyReachesCellsConnectedByTheAdjacencyRule() {
        let grid = makeArrayGrid(["#####",
                                  "#.#.#",
                                  "#####"])
        var filled = [AoCCoord2D]()
        let escaped = grid.fill(with: "O", at: AoCCoord2D(x: 3, y: 1), filled: &filled)

        #expect(escaped == false)
        #expect(grid.stringValue(at: AoCCoord2D(x: 3, y: 1)) == "O")
        #expect(grid.stringValue(at: AoCCoord2D(x: 1, y: 1)) == ".")
    }

    @Test func fillingALeakyRegionReportsEscape() {
        let grid = makeArrayGrid(["#####",
                                  "#...#",
                                  "#....",
                                  "#####"])
        var filled = [AoCCoord2D]()
        #expect(grid.fill(with: "O", at: AoCCoord2D(x: 2, y: 1), filled: &filled) == true)
    }

    @Test func fillStartingOutsideTheExtentReportsEscapeAndChangesNothing() {
        let grid = makeArrayGrid(["###",
                                  "#.#",
                                  "###"])
        let before = grid.toString()
        var filled = [AoCCoord2D]()
        let escaped = grid.fill(with: "O", at: AoCCoord2D(x: 3, y: 1), filled: &filled)

        #expect(escaped == true)
        #expect(filled.isEmpty)
        #expect(grid.toString() == before)
    }

    @Test func fillingAnEmptyGridEscapes() {
        let grid = AoCArrayGrid(defaultValue: ".", rule: .rook)
        var filled = [AoCCoord2D]()
        #expect(grid.fill(with: "O", at: .origin, filled: &filled) == true)
    }
}

/// The array grid is a drop-in replacement for the dictionary grid, so for the
/// same input both should answer protocol queries the same way.
@Suite("AoCArrayGrid matches AoCDictionaryGrid")
struct AoCGridParityTests {

    static let inputs: [[String]] = [
        asymmetricRows,
        tallRows,
        ["#"],
        ["L.LL.LL.LL",
         "LLLLLLL.LL",
         "L.L.L..L..",
         "LLLL.LL.LL",
         "L.LL.LL.LL"],
    ]

    @Test(arguments: inputs)
    func bothGridsReadTheSameValues(rows: [String]) throws {
        let dict = makeDictionaryGrid(rows)
        let array = makeArrayGrid(rows)
        #expect(array.extent == dict.extent)
        // Include a one-cell border around the extent to check the edges.
        let ext = try #require(dict.extent)
        for y in (ext.min.y - 1)...(ext.max.y + 1) {
            for x in (ext.min.x - 1)...(ext.max.x + 1) {
                let c = AoCCoord2D(x: x, y: y)
                #expect(array.stringValue(at: c) == dict.stringValue(at: c), "at \(c)")
            }
        }
    }

    @Test(arguments: inputs)
    func bothGridsHaveTheSameHistogramAndRendering(rows: [String]) {
        let dict = makeDictionaryGrid(rows)
        let array = makeArrayGrid(rows)
        #expect(array.histogram == dict.histogram)
        #expect(array.toString() == dict.toString())
    }

    @Test(arguments: inputs)
    func bothGridsFindTheSameNonDefaultCells(rows: [String]) {
        let dict = makeDictionaryGrid(rows)
        let array = makeArrayGrid(rows)
        for v in Set(rows.joined().map { String($0) }) where v != "." {
            #expect(Set(array.getCoords(withValue: v)) == Set(dict.getCoords(withValue: v)), "value \(v)")
        }
    }

    @Test(arguments: inputs)
    func bothGridsCountTheSameQueenNeighbours(rows: [String]) throws {
        let dict = makeDictionaryGrid(rows, rule: .queen)
        let array = makeArrayGrid(rows, rule: .queen)
        let ext = try #require(dict.extent)
        for c in ext.allCoords {
            for v in ["L", "#", "a", "d", "h"] {
                #expect(array.neighbourCoords(at: c, withValue: v).count
                        == dict.neighbourCoords(at: c, withValue: v).count, "at \(c) for \(v)")
            }
        }
    }
}
