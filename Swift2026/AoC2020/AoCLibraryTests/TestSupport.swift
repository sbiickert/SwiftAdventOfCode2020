//
//  TestSupport.swift
//  AoCLibraryTests
//
//  Shared helpers for the AoC library test suites.
//

import Foundation

/// A value that renders itself in a grid through `AoCGridRenderable`.
struct TestGlyph: AoCGridRenderable, Equatable {
    let glyph: String
}

/// Builds a dictionary-backed grid from rows of text, mirroring how the solutions load puzzle input.
func makeDictionaryGrid(_ rows: [String],
                        defaultValue: String = ".",
                        rule: AoCAdjacencyRule = .rook) -> AoCDictionaryGrid {
    let grid = AoCDictionaryGrid(defaultValue: defaultValue, rule: rule)
    grid.load(data: rows)
    return grid
}

/// Builds an array-backed grid from rows of text, mirroring how the solutions load puzzle input.
func makeArrayGrid(_ rows: [String],
                   defaultValue: String = ".",
                   rule: AoCAdjacencyRule = .rook) -> AoCArrayGrid {
    let grid = AoCArrayGrid(defaultValue: defaultValue, rule: rule)
    grid.load(data: rows)
    return grid
}

/// A 4-wide, 3-tall grid in which every cell holds a different letter, so a
/// transposed or shifted read returns the wrong letter instead of a lucky match.
/// The letter at (x, y) is `asymmetricRows[y][x]`.
let asymmetricRows = ["abcd",
                      "efgh",
                      "ijkl"]

/// The same idea, but 2-wide and 4-tall.
let tallRows = ["ab",
                "cd",
                "ef",
                "gh"]

/// The expected letter at (x, y) in a grid loaded from `rows`.
func letter(in rows: [String], x: Int, y: Int) -> String {
    return String(rows[y][rows[y].index(rows[y].startIndex, offsetBy: x)])
}
