extends Resource
class_name Recipe

var required_items = {
	"tomato": 10,
	"carrot": 3,
	"onion": 2
}

var max_items = 20

func validate_items(held_items: Array) -> Dictionary:
	var counts = {}
	var results = {
		"correct_items": 0,
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
	
	# Calculate correct and wrong items
	var total_required = 0
	for item_id in required_items:
		total_required += required_items[item_id]
		var held_count = counts.get(item_id, 0)
		
		if held_count > required_items[item_id]:
			results.wrong_items += held_count - required_items[item_id]
			results.correct_items += required_items[item_id]
		else:
			results.correct_items += held_count
	
	# Count extra items not in recipe
	for item_id in counts:
		if not required_items.has(item_id):
			results.wrong_items += counts[item_id]
	
	# Calculate accuracy percentage
	results.accuracy_percentage = (float(results.correct_items) / total_required) * 100
	
	# Generate feedback
	var feedback_parts = []
	for item_id in required_items:
		var held = counts.get(item_id, 0)
		var required = required_items[item_id]
		var diff = held - required
		
		if diff < 0:
			feedback_parts.append("Need %d more %s" % [abs(diff), item_id])
		elif diff > 0:
			feedback_parts.append("Too many %s (+%d)" % [item_id, diff])
	
	for item_id in counts:
		if not required_items.has(item_id):
			feedback_parts.append("%s not needed" % item_id)
	
	results.feedback = "\n".join(feedback_parts)
	results.is_perfect = results.correct_items == total_required and results.wrong_items == 0
	
	return results
