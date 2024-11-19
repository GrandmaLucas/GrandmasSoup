extends Resource
class_name Recipe

var required_items = {
	"tomato": 5,
	"carrot": 5,
	"onion": 5,
	#"pepper": 0,
}

var max_items = 15

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
	
	# Check required items
	var total_required = max_items
	for item_id in required_items:
		var held = counts.get(item_id, 0)
		var required = required_items[item_id]
		var diff = held - required
		
		if diff > 0:  # Too many of this item
			results.wrong_items += diff
			if diff > worst_over.amount:
				worst_over = {"item": item_id, "amount": diff}
		elif diff < 0:  # Too few of this item
			# Don't add to wrong_items here since we're counting against max_items
			if abs(diff) > worst_under.amount:
				worst_under = {"item": item_id, "amount": abs(diff)}

	# Only extra items (beyond max_items) count as wrong
	if results.total_submitted > max_items:
		results.wrong_items = results.total_submitted - max_items
	
	# Check extra unrequired items
	for item_id in counts:
		if not required_items.has(item_id):
			var amount = counts[item_id]
			results.wrong_items += amount
			if amount > worst_extra.amount:
				worst_extra = {"item": item_id, "amount": amount}
	print(results.wrong_items)
	# Calculate accuracy percentage
	results.accuracy_percentage = (1-(float(results.wrong_items) / total_required)) * 100
	
	# Determine worst case and set feedback
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
