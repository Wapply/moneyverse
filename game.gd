extends Control

var money = 100 # Start with some money
var selected_quantity = 1 # Default quantity

var animals = {
	"Conejos": {"price": 1, "quantity": 0, "sale_time": 3, "current_sale_time": 3, "base_price": 1, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Gallinas": {"price": 5, "quantity": 0, "sale_time": 5, "current_sale_time": 5, "base_price": 5, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Cerdos": {"price": 10, "quantity": 0, "sale_time": 7, "current_sale_time": 7, "base_price": 10, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Caballos": {"price": 20, "quantity": 0, "sale_time": 10, "current_sale_time": 10, "base_price": 20, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Vacas": {"price": 50, "quantity": 0, "sale_time": 15, "current_sale_time": 15, "base_price": 50, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Perros": {"price": 100, "quantity": 0, "sale_time": 20, "current_sale_time": 20, "base_price": 100, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Gatos": {"price": 200, "quantity": 0, "sale_time": 25, "current_sale_time": 25, "base_price": 200, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Águilas": {"price": 500, "quantity": 0, "sale_time": 30, "current_sale_time": 30, "base_price": 500, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Osos": {"price": 1000, "quantity": 0, "sale_time": 35, "current_sale_time": 35, "base_price": 1000, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Elefantes": {"price": 5000, "quantity": 0, "sale_time": 60, "current_sale_time": 60, "base_price": 5000, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0}
}

# Corrected paths for @onready variables
@onready var money_label = get_node("Header/MoneyLabel")
@onready var quantity_button = get_node("Header/QuantityButton")

var animal_labels = {}
var animal_buy_buttons = {}

var quantities = [1, 10, 100, "MAX"]
var quantity_index = 0

func _ready():
	initialize_animal_nodes()
	update_money_display()
	setup_animal_timers()
	update_sale_info_labels()
	update_quantity_button_text()

func initialize_animal_nodes():
	# Corrected paths for column nodes, relative to "Control"
	var column1_node = get_node_or_null("AnimalsContainer/Column1")
	var column2_node = get_node_or_null("AnimalsContainer/Column2")

	if not column1_node:
		printerr("Error: Node 'AnimalsContainer/Column1' not found.")
	if not column2_node:
		printerr("Error: Node 'AnimalsContainer/Column2' not found.")

	var animal_names = animals.keys()

	for i in range(animal_names.size()):
		var animal_name = animal_names[i]
		var parent_column_node_for_this_animal 
		
		if i < 5: # First 5 animals in the 'animals' dict (indices 0-4) go to Column1
			parent_column_node_for_this_animal = column1_node
		else: # The rest go to Column2
			parent_column_node_for_this_animal = column2_node

		if not parent_column_node_for_this_animal:
			printerr("Warning: Parent column for '", animal_name, "' not found. Skipping UI setup.")
			continue
		
		# Corrected base path construction for animal UI elements, relative to "Control"
		var animal_vbox_base_path = "AnimalsContainer/" + parent_column_node_for_this_animal.name + "/" + animal_name

		var name_label_node = get_node_or_null(animal_vbox_base_path + "/TopRow/" + animal_name + "NameLabel")
		var quantity_label_node = get_node_or_null(animal_vbox_base_path + "/TopRow/" + animal_name + "QuantityLabel")
		var sale_info_label_node = get_node_or_null(animal_vbox_base_path + "/BottomRow/" + animal_name + "SaleInfoLabel")
		var buy_button_node = get_node_or_null(animal_vbox_base_path + "/BottomRow/" + animal_name + "BuyButton")
		
		# Store nodes (or null if not found)
		animal_labels[animal_name + "NameLabel"] = name_label_node
		animal_labels[animal_name + "QuantityLabel"] = quantity_label_node
		animal_labels[animal_name + "SaleInfoLabel"] = sale_info_label_node
		animal_buy_buttons[animal_name + "BuyButton"] = buy_button_node

		if not name_label_node or not quantity_label_node or not sale_info_label_node or not buy_button_node:
			# This will log for "Gallinas" as its UI isn't at the expected path
			printerr("Warning: Some UI elements for animal '", animal_name, "' were not found at base path '", animal_vbox_base_path, "'. Check scene structure if this animal should be visible.")
		
func setup_animal_timers():
	print("Setting up animal timers...")
	for animal_name in animals:
		if not animals[animal_name].has("timer") or animals[animal_name]["timer"] == null: # Ensure timer is not already set up if this can be called multiple times
			# Use create_timer instead of Timer.new()
			var timer = create_timer(animals[animal_name]["current_sale_time"])
			animals[animal_name]["timer"] = timer # Store the timer reference
			timer.timeout.connect(Callable(self, "sell_animal").bind(animal_name))
			print("Timer set up for ", animal_name, " with wait time ", timer.wait_time)
		else:
			print("Timer already exists for ", animal_name)
	print("Animal timer setup complete.")

func buy_animal(animal_name):
	var animal = animals[animal_name]
	var quantity_to_buy
	if str(selected_quantity) == "MAX":
		quantity_to_buy = floor(money / animal.price) # Buy as many as possible
	else:
		quantity_to_buy = selected_quantity

	var cost = animal.price * quantity_to_buy
	if money >= cost and quantity_to_buy > 0:
		money -= cost
		animal.quantity += quantity_to_buy
		update_money_display()
		update_animal_display(animal_name)
		check_speed_threshold(animal_name)
		# Increase the animal's price by 7% (ONLY for buying) 
		animal.price = animal.price * 1.07 # Ensure floating point multiplication
		# Update the animals dictionary with the new price (already done as 'animal' is a reference to dict entry)
		update_sale_info_labels() # Update all labels as prices might change for others too potentially if logic changes
	else:
		print("Not enough money to buy ", quantity_to_buy, " ", animal_name, ". Money: ", money, ", Cost: ", cost)

func sell_animal(animal_name): # animal_name is bound from timer
	print("sell_animal called with animal_name: ", animal_name, " quantity: ", animals[animal_name].quantity)
	var animal = animals[animal_name]
	if animal.quantity > 0:
		money += animal.price * animal.quantity  # Use base_price for selling
		update_money_display()
	# else: # No need to print if no animals to sell every tick
		# print("No ", animal_name, " to sell.")
	# No need to update sale info labels here unless selling changes them.

func update_money_display():
	if money_label: # Check if node exists
		money_label.text = "Money: $" + str(money)

func update_animal_display(animal_name):
	var animal = animals[animal_name]
	var quantity_label_key = animal_name + "QuantityLabel"
	
	if animal_labels.has(quantity_label_key) and animal_labels[quantity_label_key] != null:
		var quantity_label = animal_labels[quantity_label_key]
		quantity_label.text = "Quantity: " + str(animal.quantity)

func update_sale_info_labels():
	for animal_name in animals:
		var animal = animals[animal_name]
		var sale_info_label_key = animal_name + "SaleInfoLabel"
		if animal_labels.has(sale_info_label_key) and animal_labels[sale_info_label_key] != null:
			var sale_info_label = animal_labels[sale_info_label_key]
			sale_info_label.text = "Sale Price: $" + str(int(animal.price)) + " | Time: " + str(round(animal.current_sale_time * 10.0) / 10.0) + "s"

func check_speed_threshold(animal_name):
	var animal = animals[animal_name]
	if animal.current_threshold_index < animal.speed_thresholds.size():
		var threshold = animal.speed_thresholds[animal.current_threshold_index]
		if animal.quantity >= threshold:
			animal.current_sale_time = max(0.5, animal.current_sale_time / 2.0)
			if animal.timer != null: # Check if timer exists
				animal.timer.wait_time = animal.current_sale_time
				animal.timer.start()  # Restart the timer with the new speed
			animal.current_threshold_index += 1
			update_sale_info_labels() # Sale time changed, so update relevant label

func _on_quantity_button_pressed():
	quantity_index = (quantity_index + 1) % quantities.size()
	selected_quantity = quantities[quantity_index]
	update_quantity_button_text()

func update_quantity_button_text():
	if quantity_button: # Check if node exists
		quantity_button.text = "Quantity: " + str(selected_quantity)

func _on_animal_buy_button_pressed(animal_name):
	print("_on_animal_buy_button_pressed called with animal_name: ", animal_name)
	buy_animal(animal_name)
