extends Control

var money = 10 # Start with some money
var selected_quantity = 1 # Default quantity

var animals = {
	"Conejos": {"price": 1, "quantity": 0, "sale_time": 3, "current_sale_time": 3, "base_price": 1, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Gallinas": {"price": 60, "quantity": 0, "sale_time": 5, "current_sale_time": 5, "base_price": 5, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Cerdos": {"price": 720, "quantity": 0, "sale_time": 7, "current_sale_time": 7, "base_price": 10, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Caballos": {"price": 8640, "quantity": 0, "sale_time": 10, "current_sale_time": 10, "base_price": 20, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Vacas": {"price": 103680, "quantity": 0, "sale_time": 15, "current_sale_time": 15, "base_price": 50, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Perros": {"price": 1244160, "quantity": 0, "sale_time": 20, "current_sale_time": 20, "base_price": 100, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Gatos": {"price": 14929920, "quantity": 0, "sale_time": 25, "current_sale_time": 25, "base_price": 200, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Águilas": {"price": 179159040, "quantity": 0, "sale_time": 30, "current_sale_time": 30, "base_price": 500, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Osos": {"price": 2149908480, "quantity": 0, "sale_time": 35, "current_sale_time": 35, "base_price": 1000, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Elefantes": {"price": 25798901760, "quantity": 0, "sale_time": 60, "current_sale_time": 60, "base_price": 5000, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0}
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
	# Initialize labels and buttons for each animal
	for animal_name in animals:
		# Determine the column based on the animal name
		var column_name = "Column1" if animal_name in ["Conejos", "Gallinas", "Cerdos", "Caballos", "Vacas"] else "Column2"
		var base_path = "AnimalsContainer/" + column_name + "/" + animal_name

		# Get the quantity label
		var quantity_label_path = base_path + "/TopRow/" + animal_name + "QuantityLabel"
		var quantity_label = get_node_or_null(quantity_label_path)
		if quantity_label == null:
			printerr("Error: QuantityLabel not found at path: ", quantity_label_path)
		else:
			animal_labels[animal_name + "QuantityLabel"] = quantity_label

		# Get the buy button
		var buy_button_path = base_path + "/BottomRow/" + animal_name + "BuyButton"
		var buy_button = get_node_or_null(buy_button_path)
		if buy_button == null:
			printerr("Error: BuyButton not found at path: ", buy_button_path)
		else:
			animal_buy_buttons[animal_name + "BuyButton"] = buy_button

func setup_animal_timers():
	for animal_name in animals:
		var animal = animals[animal_name]
		animal.timer = Timer.new()
		add_child(animal.timer)
		animal.timer.wait_time = animal.sale_time  # Set wait time from the animal's sale_time
		animal.timer.timeout.connect(sell_animal.bind(animal_name)) # Bind the animal_name to the sell_animal function
		animal.timer.set_one_shot(false) # Set to auto-restart
		animal.timer.start()

func update_sale_info_labels():
	for animal_name in animals:
		# Determine the column based on the animal name
		var column_name = "Column1" if animal_name in ["Conejos", "Gallinas", "Cerdos", "Caballos", "Vacas"] else "Column2"
		var base_path = "AnimalsContainer/" + column_name + "/" + animal_name

		# Get the sale info label
		var sale_info_label_path = base_path + "/BottomRow/" + animal_name + "SaleInfoLabel"
		var sale_info_label = get_node_or_null(sale_info_label_path)
		if sale_info_label:
			sale_info_label.text = "Price: $" + str("%.2f" % animals[animal_name].price) # Format as needed
		else:
			printerr("Error: SaleInfoLabel not found at path: ", sale_info_label_path)

func update_quantity_button_text():
	quantity_button.text = "Buy " + str(quantities[quantity_index])

func _on_quantity_button_pressed():
	quantity_index = (quantity_index + 1) % quantities.size()
	selected_quantity = quantities[quantity_index]
	update_quantity_button_text()

func buy_animal(animal_name):
	var animal = animals[animal_name]
	var quantity_to_buy
	if str(selected_quantity) == "MAX":
		quantity_to_buy = floor(money / animal.price)
	else:
		quantity_to_buy = selected_quantity

	var total_cost = 0
	var temp_price = animal.price

	# Calculamos el costo total con aumento progresivo
	for i in range(quantity_to_buy):
		if money >= total_cost + temp_price:
			total_cost += temp_price
			temp_price *= 1.07
		else:
			quantity_to_buy = i
			break

	if money >= total_cost and quantity_to_buy > 0:
		money -= total_cost
		animal.quantity += quantity_to_buy
		animal.price = temp_price  # nuevo precio tras el último incremento
		update_money_display()
		update_animal_display(animal_name)
		check_speed_threshold(animal_name)
		update_sale_info_labels()
	else:
		print("No alcanza la plata para comprar ", quantity_to_buy, " ", animal_name, ". Money: ", money, ", Cost: ", total_cost)

func sell_animal(animal_name): # animal_name is bound from timer
	print("sell_animal called with animal_name: ", animal_name, " quantity: ", animals[animal_name].quantity)
	var animal = animals[animal_name]
	if animal.quantity > 0:
		money += animal.base_price * animal.quantity  # Use base_price for selling
		update_money_display()
	# else: # No need to print if no animals to sell every tick
		# print("No ", animal_name, " to sell.")
	# No need to update sale info labels here unless selling changes them.

func update_money_display():
	if money_label: # Check if node exists
		money_label.text = "Money: $" + str("%.2f" % money)

func update_animal_display(animal_name):
	var animal = animals[animal_name]
	var quantity_label_key = animal_name + "QuantityLabel"
	
	if animal_labels.has(quantity_label_key) and animal_labels[quantity_label_key] != null:
		var quantity_label = animal_labels[quantity_label_key]
		quantity_label.text = str(animal.quantity)

func check_speed_threshold(animal_name):
	var animal = animals[animal_name]
	# Check if the animal has reached the next speed threshold
	if animal.current_threshold_index < animal.speed_thresholds.size() and animal.quantity >= animal.speed_thresholds[animal.current_threshold_index]:
		# Increase the animal's sale speed by reducing the timer wait time
		animal.sale_time = animal.sale_time * 0.9  # Reduce sale_time by 10%
		# Ensure the sale_time does not go below a minimum value (e.g., 0.1 seconds)
		animal.sale_time = max(animal.sale_time, 0.1)
		# Update the timer with the new wait_time
		animal.timer.wait_time = animal.sale_time
		# Move to the next threshold
		animal.current_threshold_index += 1
		print(animal_name, " reached speed threshold, new sale_time: ", animal.sale_time)


func _on_animal_buy_button_pressed(animal_name):
	buy_animal(animal_name)
