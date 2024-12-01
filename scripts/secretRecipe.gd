extends Resource
class_name Recipe

signal perfect_recipe

var required_items = {
	"tomato": 3,
	"carrot": 2,
	"onion": 1,
	"potato": 3,
	"pepper": 1,
	"mushroom": 2,
	"meat": 2,
	"broth": 4,
}
var required_total = 18  # Total items required by the recipe
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

	var correct_items = 0
	var over_submitted = 0
	var wrong_items = 0
	var total_required = 0

	var worst_under = {"item": "", "amount": 0}
	var worst_over = {"item": "", "amount": 0}
	var worst_extra = {"item": "", "amount": 0}

	# Calculate correct items and over-submitted items
	for item_id in required_items.keys():
		var required = required_items[item_id]
		var held = counts.get(item_id, 0)
		total_required += required

		if held <= required:
			correct_items += held
			var under_amount = required - held
			if under_amount > worst_under.amount:
				worst_under = {"item": item_id, "amount": under_amount}
		else:
			correct_items += required
			var over_amount = held - required
			over_submitted += over_amount
			if over_amount > worst_over.amount:
				worst_over = {"item": item_id, "amount": over_amount}

	# Identify wrong (extra) items not in the recipe
	for item_id in counts.keys():
		if not required_items.has(item_id):
			wrong_items += counts[item_id]
			if counts[item_id] > worst_extra.amount:
				worst_extra = {"item": item_id, "amount": counts[item_id]}

	# Total deductions (over-submitted and wrong items)
	var total_deductions = over_submitted + wrong_items

	# Calculate accuracy percentage based on correct items vs total submitted
	var accuracy = float(correct_items) / results.total_submitted * 100.0
	results.accuracy_percentage = clamp(accuracy, 0.0, 100.0)

	# Determine if the attempt is perfect
	results.is_perfect = (
		results.accuracy_percentage == 100.0 and
		over_submitted == 0 and
		wrong_items == 0 and
		results.total_submitted == total_required
	)

	# Update wrong_items count
	results.wrong_items = wrong_items + over_submitted

	# Determine feedback
	if worst_extra.amount > 0:
		results.feedback = "There is no %s in this recipe." % worst_extra.item
	elif worst_over.amount > worst_under.amount:
		results.feedback = "Needs less %s" % worst_over.item
	elif worst_under.amount > 0:
		results.feedback = "Needs more %s" % worst_under.item
	else:
		results.feedback = "Perfect!"
		emit_signal("perfect_recipe")

	return results
