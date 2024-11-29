extends Resource
class_name Recipe

var required_items = {
	"tomato": 2,
	"carrot": 2,
	"onion": 1,
	"potato": 2,
	"pepper": 1,
	"mushroom": 3,
	"meat": 1,
	"broth": 5,
}
var required_total = 17  # Total items required by the recipe
var max_items = 20       # Maximum items that can be submitted

func validate_items(held_items: Array) -> Dictionary:
	var counts = {}
	var results = {
		"wrong_items": 0,
		"accuracy_percentage": 0.0,
		"feedback": "",
		"is_perfect": false,
		"total_submitted": 0
	}
	
	# Count held items
	for item_data in held_items:
		var item_id = item_data["item_type"].id
		counts[item_id] = counts.get(item_id, 0) + 1
		results.total_submitted += 1
	
	# Track worst differences
	var worst_extra = {"item": "", "amount": 0}
	var worst_over = {"item": "", "amount": 0}
	var worst_under = {"item": "", "amount": 0}
	
	# Track correct matches for accuracy calculation
	var correct_matches = 0
	
	# Check required items
	for item_id in required_items:
		var held = counts.get(item_id, 0)
		var required = required_items[item_id]
		
		# Count correct matches (cannot exceed required amount)
		correct_matches += min(held, required)
		
		var diff = held - required
		if diff > 0:  # Too many of this item
			results.wrong_items += diff
			if diff > worst_over.amount:
				worst_over = {"item": item_id, "amount": diff}
		elif diff < 0:  # Too few of this item
			results.wrong_items += abs(diff)
			if abs(diff) > worst_under.amount:
				worst_under = {"item": item_id, "amount": abs(diff)}
	
	# Check extra unrequired items
	for item_id in counts:
		if not required_items.has(item_id):
			var amount = counts[item_id]
			results.wrong_items += amount
			if amount > worst_extra.amount:
				worst_extra = {"item": item_id, "amount": amount}
	
	# Calculate accuracy percentage as ratio of correct matches to required total
	results.accuracy_percentage = (float(correct_matches) / required_total) * 100
	
	# Determine feedback
	if worst_extra.amount > 0:
		results.feedback = "There is no %s in this recipe" % worst_extra.item
	elif worst_over.amount > worst_under.amount:
		results.feedback = "Needs less %s" % worst_over.item
	elif worst_under.amount > 0:
		results.feedback = "Needs more %s" % worst_under.item
	else:
		results.feedback = "Perfect!"
	
	results.is_perfect = (results.wrong_items == 0)
	
	return results
