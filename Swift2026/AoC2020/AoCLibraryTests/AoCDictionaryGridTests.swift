//
//  AoCDictionaryGridTests.swift
//  AoCLibraryTests
//

import Testing
import Foundation

@Suite("AoCDictionaryGrid: loading and values")
struct AoCDictionaryGridValueTests {

    @Test func aNewGridIsEmpty() {
        let grid = AoCDictionaryGrid()
        #expect(grid.defaultValue == ".")
        #expect(grid.rule == .rook)
        #expect(grid.extent == nil)
        #expect(grid.isTiledInfinitely == false)
        #expect(grid.coords.isEmpty)
        #expect(grid.values.isEmpty)
        #expect(grid.stringValue(at: .origin) == ".")
    }

    @Test func initTakesADefaultValueAndAnAdjacencyRule() {
        let grid = AoCDictionaryGrid(defaultValue: " ", rule: .queen)
        #expect(grid.defaultValue == " ")
        #expect(grid.rule == .queen)
        #expect(grid.stringValue(at: AoCCoord2D(x: 99, y: 99)) == " ")
    }

    @Test func loadStoresOnlyNonDefaultCells() {
        let grid = makeDictionaryGrid(["..#",
                                       ".#.",
                                       "#.."])
        #expect(grid.coords.count == 3)
        #expect(Set(grid.coords) == Set([AoCCoord2D(x: 2, y: 0),
                                         AoCCoord2D(x: 1, y: 1),
                                         AoCCoord2D(x: 0, y: 2)]))
        #expect(grid.stringValue(at: AoCCoord2D(x: 2, y: 0)) == "#")
        #expect(grid.stringValue(at: AoCCoord2D(x: 0, y: 0)) == ".")
    }

    @Test func loadUsesColumnForXAndRowForY() {
        let grid = makeDictionaryGrid(["...",
                                       "..#"])
        #expect(grid.stringValue(at: AoCCoord2D(x: 2, y: 1)) == "#")
        #expect(grid.stringValue(at: AoCCoord2D(x: 1, y: 2)) == ".")
    }

    @Test func loadPlacesEveryCellOfANonSquareGrid() {
        let grid = makeDictionaryGrid(asymmetricRows)
        for y in 0..<3 {
            for x in 0..<4 {
                #expect(grid.stringValue(at: AoCCoord2D(x: x, y: y)) == letter(in: asymmetricRows, x: x, y: y))
            }
        }
    }

    /// Default cells are not stored, but the extent still covers the whole input,
    /// including a border made entirely of the default character.
    @Test func extentCoversTheWholeInput() throws {
        let grid = makeDictionaryGrid(["....",
                                       ".##.",
                                       "...."])
        let ext = try #require(grid.extent)
        #expect(ext == AoCExtent2D.build(0, 0, 3, 2))
        #expect(ext.width == 4)
        #expect(ext.height == 3)
        #expect(grid.coords.count == 2)
        #expect(grid.histogram == ["#": 2, ".": 10])
    }

    @Test func extentCoversTheWholeInputEvenWhenNothingIsStored() {
        let grid = makeDictionaryGrid(["...",
                                       "..."])
        #expect(grid.extent == AoCExtent2D.build(0, 0, 2, 1))
        #expect(grid.coords.isEmpty)
        #expect(grid.histogram == [".": 6])
    }

    @Test func loadingNoRowsLeavesTheGridEmpty() {
        #expect(makeDictionaryGrid([]).extent == nil)
        #expect(makeDictionaryGrid([""]).extent == nil)
    }

    @Test func loadHandlesRaggedRows() {
        let grid = makeDictionaryGrid(["#",
                                       "..#",
                                       ".#"])
        #expect(grid.extent == AoCExtent2D.build(0, 0, 2, 2))
    }

    @Test func settingAValueGrowsTheExtent() {
        let grid = AoCDictionaryGrid()
        grid.setValue("A", at: AoCCoord2D(x: 3, y: 3))
        #expect(grid.extent == AoCExtent2D.build(3, 3, 3, 3))
        grid.setValue("B", at: AoCCoord2D(x: -1, y: 5))
        #expect(grid.extent == AoCExtent2D.build(-1, 3, 3, 5))
        grid.setValue("C", at: AoCCoord2D(x: 0, y: 4))
        #expect(grid.extent == AoCExtent2D.build(-1, 3, 3, 5))
    }

    @Test func settingAValueTwiceOverwritesIt() {
        let grid = AoCDictionaryGrid()
        let c = AoCCoord2D(x: 1, y: 1)
        grid.setValue("A", at: c)
        grid.setValue("B", at: c)
        #expect(grid.stringValue(at: c) == "B")
        #expect(grid.coords.count == 1)
    }

    @Test func nonStringValuesAreStoredAndRenderedByInterpolation() {
        let grid = AoCDictionaryGrid()
        let c = AoCCoord2D(x: 0, y: 0)
        grid.setValue(42, at: c)
        #expect(grid.value(at: c) as? Int == 42)
        #expect(grid.stringValue(at: c) == "42")
    }

    @Test func renderableValuesAreDrawnWithTheirGlyph() {
        let grid = AoCDictionaryGrid()
        let c = AoCCoord2D(x: 0, y: 0)
        grid.setValue(TestGlyph(glyph: "@"), at: c)
        #expect(grid.value(at: c) as? TestGlyph == TestGlyph(glyph: "@"))
        #expect(grid.stringValue(at: c) == "@")
    }

    @Test func unsetCellsReturnTheDefaultValue() {
        let grid = makeDictionaryGrid(["#"])
        #expect(grid.stringValue(at: AoCCoord2D(x: 100, y: -100)) == ".")
        #expect(grid.value(at: AoCCoord2D(x: 100, y: -100)) as? String == ".")
    }

    @Test func valuesReturnsOneEntryPerStoredCell() {
        let grid = makeDictionaryGrid(["#.#",
                                       ".#."])
        #expect(grid.values.count == 3)
        #expect(grid.values.compactMap { $0 as? String } == ["#", "#", "#"])
    }

    @Test func getCoordsFindsCellsByRenderedValue() {
        let grid = makeDictionaryGrid(["A.B",
                                       "B.A"])
        #expect(Set(grid.getCoords(withValue: "A")) == Set([AoCCoord2D(x: 0, y: 0), AoCCoord2D(x: 2, y: 1)]))
        #expect(Set(grid.getCoords(withValue: "B")) == Set([AoCCoord2D(x: 2, y: 0), AoCCoord2D(x: 0, y: 1)]))
    }

    /// Default-valued cells are never stored, so they are invisible to getCoords.
    @Test func getCoordsNeverReturnsDefaultCells() {
        let grid = makeDictionaryGrid(["A.B"])
        #expect(grid.getCoords(withValue: ".").isEmpty)
        #expect(grid.getCoords(withValue: "Z").isEmpty)
    }

    @Test func getCoordsMatchesRenderableAndNumericValues() {
        let grid = AoCDictionaryGrid()
        grid.setValue(7, at: AoCCoord2D(x: 0, y: 0))
        grid.setValue(TestGlyph(glyph: "@"), at: AoCCoord2D(x: 1, y: 0))
        #expect(grid.getCoords(withValue: "7") == [AoCCoord2D(x: 0, y: 0)])
        #expect(grid.getCoords(withValue: "@") == [AoCCoord2D(x: 1, y: 0)])
    }

    @Test func histogramCountsEveryCellInsideTheExtent() {
        let grid = makeDictionaryGrid(["..#",
                                       ".#.",
                                       "#.."])
        #expect(grid.histogram == ["#": 3, ".": 6])
    }

    @Test func histogramOfAnEmptyGridIsEmpty() {
        #expect(AoCDictionaryGrid().histogram.isEmpty)
    }

    @Test func histogramTotalsTheExtentArea() throws {
        let grid = makeDictionaryGrid(["#ab",
                                       "cd#"])
        let ext = try #require(grid.extent)
        #expect(grid.histogram.values.reduce(0, +) == ext.area)
    }

    @Test func clearRemovesACellButKeepsTheExtentByDefault() {
        let grid = makeDictionaryGrid(["#.#",
                                       "...",
                                       "#.#"])
        let before = grid.extent
        grid.clear(at: AoCCoord2D(x: 2, y: 2))
        #expect(grid.stringValue(at: AoCCoord2D(x: 2, y: 2)) == ".")
        #expect(grid.coords.count == 3)
        #expect(grid.extent == before)
    }

    @Test func clearCanRecomputeTheExtent() {
        let grid = makeDictionaryGrid(["#.#",
                                       "...",
                                       "#.#"])
        grid.clear(at: AoCCoord2D(x: 2, y: 2), resetExtent: true)
        #expect(grid.extent == AoCExtent2D.build(0, 0, 2, 2))
        grid.clear(at: AoCCoord2D(x: 2, y: 0), resetExtent: true)
        #expect(grid.extent == AoCExtent2D.build(0, 0, 0, 2))
    }

    @Test func clearingACellThatWasNeverSetIsHarmless() {
        let grid = makeDictionaryGrid(["#"])
        grid.clear(at: AoCCoord2D(x: 50, y: 50))
        #expect(grid.coords.count == 1)
    }
}

@Suite("AoCDictionaryGrid: neighbours")
struct AoCDictionaryGridNeighbourTests {

    @Test func neighbourOffsetsFollowTheGridsRule() {
        #expect(makeDictionaryGrid(["#"], rule: .rook).neighbourOffsets.count == 4)
        #expect(makeDictionaryGrid(["#"], rule: .bishop).neighbourOffsets.count == 4)
        #expect(makeDictionaryGrid(["#"], rule: .queen).neighbourOffsets.count == 8)
        #expect(makeDictionaryGrid(["#"], rule: .queen).neighbourOffsets
                == AoCCoord2D.getAdjacentOffsets(rule: .queen))
    }

    @Test func neighbourCoordsAreNotClippedToTheExtent() {
        let grid = makeDictionaryGrid(["#"])
        let neighbours = grid.neighbourCoords(at: .origin)
        #expect(neighbours.count == 4)
        #expect(neighbours.contains(AoCCoord2D(x: 0, y: -1)))
        #expect(neighbours.contains(AoCCoord2D(x: -1, y: 0)))
    }

    @Test func neighbourCoordsFilteredByValue() {
        let grid = makeDictionaryGrid(["..#",
                                       ".#.",
                                       "#.."])
        let hashes = grid.neighbourCoords(at: AoCCoord2D(x: 1, y: 0), withValue: "#")
        #expect(Set(hashes) == Set([AoCCoord2D(x: 2, y: 0), AoCCoord2D(x: 1, y: 1)]))
    }

    @Test func filteringByTheDefaultValueIncludesCellsOutsideTheExtent() {
        let grid = makeDictionaryGrid(["#"])
        #expect(grid.neighbourCoords(at: .origin, withValue: ".").count == 4)
    }

    @Test func queenNeighboursIncludeDiagonals() {
        let grid = makeDictionaryGrid(["#.#",
                                       ".X.",
                                       "#.#"], rule: .queen)
        let centre = AoCCoord2D(x: 1, y: 1)
        #expect(grid.neighbourCoords(at: centre).count == 8)
        #expect(grid.neighbourCoords(at: centre, withValue: "#").count == 4)
    }

    @Test func rookNeighboursExcludeDiagonals() {
        let grid = makeDictionaryGrid(["#.#",
                                       ".X.",
                                       "#.#"], rule: .rook)
        #expect(grid.neighbourCoords(at: AoCCoord2D(x: 1, y: 1), withValue: "#").isEmpty)
    }
}

@Suite("AoCDictionaryGrid: rendering")
struct AoCDictionaryGridRenderingTests {

    @Test func toStringDrawsTheExtentSpaceSeparated() {
        let grid = makeDictionaryGrid(["#.#",
                                       ".#.",
                                       "#.#"])
        #expect(grid.toString() == "# . #\n. # .\n# . #\n")
    }

    @Test func toStringDrawsRowsTopToBottom() {
        let grid = makeDictionaryGrid(asymmetricRows)
        #expect(grid.toString() == "a b c d\ne f g h\ni j k l\n")
    }

    @Test func toStringOfAnEmptyGridIsEmpty() {
        #expect(AoCDictionaryGrid().toString() == "")
    }

    @Test func toStringOnlyDrawsTheExtent() {
        let grid = AoCDictionaryGrid()
        grid.setValue("#", at: AoCCoord2D(x: 5, y: 5))
        #expect(grid.toString() == "#\n")
    }

    @Test func markersOverrideTheStoredValues() {
        let grid = makeDictionaryGrid(["#.",
                                       ".#"])
        let markers = [AoCCoord2D(x: 0, y: 0): "A", AoCCoord2D(x: 1, y: 0): "B"]
        #expect(grid.toString(markers: markers, drawExtent: nil) == "A B\n. #\n")
    }

    @Test func markersOutsideTheExtentAreNotDrawn() {
        let grid = makeDictionaryGrid(["#"])
        #expect(grid.toString(markers: [AoCCoord2D(x: 9, y: 9): "!"], drawExtent: nil) == "#\n")
    }

    @Test func aDrawExtentIsOnlyHonouredForTiledGrids() {
        let grid = makeDictionaryGrid(["#.",
                                       ".#"])
        let wider = AoCExtent2D.build(0, 0, 3, 1)
        // Not tiled: the draw extent is ignored.
        #expect(grid.toString(markers: nil, drawExtent: wider) == "# .\n. #\n")

        grid.isTiledInfinitely = true
        #expect(grid.toString(markers: nil, drawExtent: wider) == "# . # .\n. # . #\n")
    }
}

@Suite("AoCDictionaryGrid: infinite tiling")
struct AoCDictionaryGridTilingTests {

    private func tiledGrid() -> AoCDictionaryGrid {
        let grid = makeDictionaryGrid(["#..",
                                       "...",
                                       "..#"])
        grid.isTiledInfinitely = true
        return grid
    }

    @Test func theSampleGridSpansTheOrigin() {
        #expect(tiledGrid().extent == AoCExtent2D.build(0, 0, 2, 2))
    }

    @Test func coordsInsideTheExtentAreUnaffected() {
        let grid = tiledGrid()
        #expect(grid.stringValue(at: AoCCoord2D(x: 0, y: 0)) == "#")
        #expect(grid.stringValue(at: AoCCoord2D(x: 2, y: 2)) == "#")
        #expect(grid.stringValue(at: AoCCoord2D(x: 1, y: 1)) == ".")
    }

    @Test func coordsPastTheEastAndSouthEdgesWrap() {
        let grid = tiledGrid()
        #expect(grid.stringValue(at: AoCCoord2D(x: 3, y: 3)) == "#")
        #expect(grid.stringValue(at: AoCCoord2D(x: 3, y: 0)) == "#")
        #expect(grid.stringValue(at: AoCCoord2D(x: 30, y: 30)) == "#")
        #expect(grid.stringValue(at: AoCCoord2D(x: 4, y: 4)) == ".")
    }

    @Test func coordsPastTheWestAndNorthEdgesWrap() {
        let grid = tiledGrid()
        #expect(grid.stringValue(at: AoCCoord2D(x: -1, y: -1)) == "#")
        #expect(grid.stringValue(at: AoCCoord2D(x: -3, y: -3)) == "#")
        #expect(grid.stringValue(at: AoCCoord2D(x: -2, y: -2)) == ".")
    }

    @Test func tilingIsPeriodicInBothAxes() throws {
        let grid = tiledGrid()
        let ext = try #require(grid.extent)
        for coord in ext.allCoords {
            let shifted = AoCCoord2D(x: coord.x + 3 * ext.width, y: coord.y - 2 * ext.height)
            #expect(grid.stringValue(at: shifted) == grid.stringValue(at: coord))
        }
    }

    /// A non-square grid catches width and height being swapped in the wrap.
    @Test func tilingANonSquareGridWrapsEachAxisByItsOwnSize() {
        let grid = makeDictionaryGrid(asymmetricRows)
        grid.isTiledInfinitely = true
        #expect(grid.stringValue(at: AoCCoord2D(x: 4, y: 0)) == "a")
        #expect(grid.stringValue(at: AoCCoord2D(x: 0, y: 3)) == "a")
        #expect(grid.stringValue(at: AoCCoord2D(x: 5, y: 4)) == "f")
        #expect(grid.stringValue(at: AoCCoord2D(x: -1, y: -1)) == "l")
    }

    /// Wrapping is relative to the extent's own origin, so a grid that does not
    /// start at [0,0] still tiles correctly.
    @Test func tilingWorksForGridsAwayFromTheOrigin() {
        let grid = AoCDictionaryGrid()
        grid.setValue("#", at: AoCCoord2D(x: 10, y: 20))
        grid.setValue("@", at: AoCCoord2D(x: 12, y: 22))
        grid.isTiledInfinitely = true
        #expect(grid.extent == AoCExtent2D.build(10, 20, 12, 22))

        // One full period east and south of each stored cell.
        #expect(grid.stringValue(at: AoCCoord2D(x: 13, y: 23)) == "#")
        #expect(grid.stringValue(at: AoCCoord2D(x: 15, y: 25)) == "@")
        // One full period west and north.
        #expect(grid.stringValue(at: AoCCoord2D(x: 7, y: 17)) == "#")
        #expect(grid.stringValue(at: AoCCoord2D(x: 9, y: 19)) == "@")
        #expect(grid.stringValue(at: AoCCoord2D(x: 14, y: 24)) == ".")
    }

    @Test func tiledLookupsArePeriodicForAnOffsetGrid() throws {
        let grid = makeDictionaryGrid(["#..",
                                       "...",
                                       "..@"])
        grid.setValue("#", at: AoCCoord2D(x: 5, y: 5))
        grid.isTiledInfinitely = true
        let ext = try #require(grid.extent)
        for coord in ext.allCoords {
            let shifted = AoCCoord2D(x: coord.x + 2 * ext.width, y: coord.y - 3 * ext.height)
            #expect(grid.stringValue(at: shifted) == grid.stringValue(at: coord))
        }
    }

    @Test func withoutTilingOutOfBoundsCoordsAreTheDefaultValue() {
        let grid = makeDictionaryGrid(["#..",
                                       "...",
                                       "..#"])
        #expect(grid.stringValue(at: AoCCoord2D(x: 3, y: 3)) == ".")
        #expect(grid.stringValue(at: AoCCoord2D(x: -1, y: -1)) == ".")
    }
}

@Suite("AoCDictionaryGrid: flood fill")
struct AoCDictionaryGridFillTests {

    @Test func fillingAnEnclosedRegionPaintsEveryInteriorCell() {
        let grid = makeDictionaryGrid(["#####",
                                       "#...#",
                                       "#...#",
                                       "#...#",
                                       "#####"])
        var filled = [AoCCoord2D]()
        let escaped = grid.fill(with: "O", at: AoCCoord2D(x: 2, y: 2), filled: &filled)

        #expect(escaped == false)
        #expect(grid.getCoords(withValue: "O").count == 9)
        #expect(grid.getCoords(withValue: "#").count == 16)
        #expect(grid.histogram == ["#": 16, "O": 9])
    }

    @Test func fillOnlyReachesCellsConnectedByTheAdjacencyRule() {
        // Two interior rooms separated by a wall: filling one leaves the other.
        let grid = makeDictionaryGrid(["#####",
                                       "#.#.#",
                                       "#####"])
        var filled = [AoCCoord2D]()
        let escaped = grid.fill(with: "O", at: AoCCoord2D(x: 1, y: 1), filled: &filled)

        #expect(escaped == false)
        #expect(grid.stringValue(at: AoCCoord2D(x: 1, y: 1)) == "O")
        #expect(grid.stringValue(at: AoCCoord2D(x: 3, y: 1)) == ".")
    }

    @Test func fillStartingOutsideTheExtentReportsEscapeAndChangesNothing() {
        let grid = makeDictionaryGrid(["###",
                                       "#.#",
                                       "###"])
        var filled = [AoCCoord2D]()
        let escaped = grid.fill(with: "O", at: AoCCoord2D(x: 99, y: 99), filled: &filled)

        #expect(escaped == true)
        #expect(filled.isEmpty)
        #expect(grid.getCoords(withValue: "O").isEmpty)
        #expect(grid.coords.count == 8)
    }

    @Test func fillingAnEmptyGridEscapesWithoutTrapping() {
        let grid = AoCDictionaryGrid()
        var filled = [AoCCoord2D]()
        #expect(grid.fill(with: "O", at: .origin, filled: &filled) == true)
        #expect(filled.isEmpty)
        #expect(grid.coords.isEmpty)
    }
}
