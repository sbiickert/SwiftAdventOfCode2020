import Foundation

public class Day21 {
	
	private static let nutritionRedef = "([a-z ]+) \\(contains ([a-z, ]+)\\)"
	private static var nutritionRegex: NSRegularExpression?
	private static var allergens = Set<String>()
	private static var ingredients = Dictionary<String, Ingredient>()
	private static var recipes = [Recipe]()

	public static func solve(testing: Bool) {
		if createRegularExpressions() == false { return }
		let allInput = readGroupedInputFile(named: "Day21_Input")
		let input = testing ? allInput[0] : allInput[1]
		
		readNutrition(from: input)
		//for recipe in recipes {
			//print(recipe)
		//}
		
		assignAllergensToIngredients()
		let dangerousIngredients = ingredients.values.filter({ $0.allergen != nil }).sorted(by: {$0.allergen! < $1.allergen!})
		let safeIngredients = ingredients.values.filter({ $0.allergen == nil })
		print("Ingredients with allergens: \(dangerousIngredients)")
		//print("Ingredients without allergens: \(safeIngredients)")
		var countNonAllergenic = 0
		for ingr in safeIngredients {
			countNonAllergenic += recipesContaining(ingredient: ingr).count
		}
		print("Answer: \(countNonAllergenic)")
		
		let dangerousIngredientNames = dangerousIngredients.map({$0.name})
		print("Dangerous ingredient list: \(dangerousIngredientNames.joined(separator: ","))")
	}
	
	static func assignAllergensToIngredients() {
		var allergenToRecipe = Dictionary<String, [Recipe]>()
		for a in allergens {
			allergenToRecipe[a] = recipesContaining(allergen: a)
		}
		let allergensSortedByFreq = allergens.sorted(by: {allergenToRecipe[$0]!.count > allergenToRecipe[$1]!.count})
		var allergensToPossibleIngredients = Dictionary<String, [String]>()
		for a in allergensSortedByFreq {
			let ingrNamesInCommon = Recipe.ingredientsInCommon(recipes: allergenToRecipe[a]!)
			allergensToPossibleIngredients[a] = ingrNamesInCommon
			print("\(a) might be in \(ingrNamesInCommon)")
		}
		while allergensToPossibleIngredients.count > 0 {
			var foundIngredientName = ""
			for allergen in allergensToPossibleIngredients.keys {
				if allergensToPossibleIngredients[allergen]?.count == 1 {
					foundIngredientName = allergensToPossibleIngredients[allergen]!.first!
					print("Allergen \(allergen) is in \(foundIngredientName)")
					var ingr = ingredients[foundIngredientName]!
					ingr.allergen = allergen
					ingredients[foundIngredientName] = ingr
					allergensToPossibleIngredients.removeValue(forKey: allergen)
					break
				}
			}
			for allergen in allergensToPossibleIngredients.keys {
				let filtered = allergensToPossibleIngredients[allergen]?.filter({$0 != foundIngredientName})
				allergensToPossibleIngredients[allergen] = filtered
			}
		}
	}
	
	private static func recipesContaining(ingredient: Ingredient) -> [Recipe] {
		return recipes.filter({$0.ingredients.contains(ingredient.name)})
	}
	
	private static func recipesContaining(ingredientNamed name: String) -> [Recipe] {
		return recipes.filter({$0.ingredients.contains(name)})
	}

	private static func recipesContaining(allergen: String) -> [Recipe] {
		return recipes.filter({$0.allergens.contains(allergen)})
	}
	
	private static func ingredientContaining(allergen: String) -> Ingredient? {
		for ingr in ingredients.values {
			if ingr.allergen == allergen {
				return ingr
			}
		}
		return nil
	}

	static func readNutrition(from input: [String]) {
		for (i, line) in input.enumerated() {
			let range = NSRange(location: 0, length: line.utf16.count)
			if let match = nutritionRegex?.firstMatch(in: line, options: [], range: range) {
				if let rIngredients = Range(match.range(at: 1), in: line),
				   let rAllergens = Range(match.range(at: 2), in: line) {

					let iList = String(line[rIngredients]).components(separatedBy: " ")
					let aList = String(line[rAllergens]).components(separatedBy: ", ")
					
					var recipeIngredientNames = [String]()
					for iName in iList {
						let i = Ingredient(name: iName, allergen: nil)
						recipeIngredientNames.append(iName)
						ingredients[iName] = i
					}
					for a in aList {
						allergens.insert(a)
					}
					
					let r = Recipe(id: i, ingredients: recipeIngredientNames, allergens: aList)
					recipes.append(r)
				}
			}
		}
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
	static func createRegularExpressions() -> Bool {
		do {
			nutritionRegex = try NSRegularExpression(pattern: nutritionRedef, options: [])
		} catch {
			print("Error creating regular expression.")
			return false
		}
		return true
	}
}

private struct Recipe: CustomStringConvertible {
	var description: String {
		var desc = "Recipe \(id)\n"
		desc += "Ingredients: \(ingredients)\n"
		desc += "Allergens: \(allergens)"
		return desc
	}
	
	var id: Int
	var ingredients: [String]
	var allergens: [String]
	
	static func ingredientsInCommon(recipes: [Recipe]) -> [String] {
		var sets = [Set<String>]()
		for r in recipes {
			var s = Set<String>()
			for ingr in r.ingredients {
				s.insert(ingr)
			}
			sets.append(s)
		}
		var common = sets[0]
		for i in 1..<sets.count {
			common = common.intersection(sets[i])
		}
		return Array(common)
	}
}

private struct Ingredient: Equatable, CustomStringConvertible {
	var description: String {
		return "(\(name) -> \(allergen ?? "nil"))"
	}
	
	let name: String
	var allergen: String?
}
