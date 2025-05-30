extends Control

var money = 100
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

@onready var money_label = get_node("VBoxContainer/PanelContainer/MoneyLabel")
@onready var conejos_sale_info_label = get_node("VBoxContainer/PanelContainer/ConejosSaleInfoLabel")
@onready var quantity_button = get_node("VBoxContainer/QuantityButton") # Reference to the Quantity Button

var quantities = ["1", "10", "100", "MAX"]
var quantity_index = 0

func _ready():
	update_money_display()
	setup_animal_timers()
	update_sale_info_labels()
	update_quantity_button_text()

func setup_animal_timers():
	print("Setting up animal timers...")
	for animal_name in animals:
		var timer = Timer.new()
		add_child(timer)
		animals[animal_name]["timer"] = timer
		timer.wait_time = animals[animal_name]["current_sale_time"]
		timer.autostart = true
		timer.timeout.connect(func():
			print("Timer for ", animal_name, " timed out!")
			sell_animal(animal_name)
		)
		timer.start()  # Explicitly start the timer
		print("Timer set up and started for ", animal_name, " with wait time ", timer.wait_time)
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
		animal.price *= 1.07
		# Update the animals dictionary with the new price
		animals[animal_name]["price"] = animal.price
		print("Bought ", quantity_to_buy, " ", animal_name, ". Current quantity: ", animal.quantity, ". New price: ", animal.price)
		update_sale_info_labels()
	else:
		print("Not enough money to buy ", quantity_to_buy, " ", animal_name, ". Money: ", money, ", Cost: ", cost)

func sell_animal(animal_name):
	var animal = animals[animal_name]
	print("Attempting to sell ", animal_name, ". Quantity: ", animal.quantity)
	if animal.quantity > 0:
		money += animal.base_price * animal.quantity  # Use base_price for selling
		update_money_display()
		print("Sold ", animal.quantity, " ", animal_name, ". Gained: ", animal.base_price * animal.quantity, ". New money: ", money)
	else:
		print("No ", animal_name, " to sell.")
	update_sale_info_labels()

func update_money_display():
	money_label.text = "Money: $" + str(money)

func update_animal_display(animal_name):
	var animal = animals[animal_name]
	var quantity_label = get_node("VBoxContainer/" + animal_name + "QuantityLabel")
	quantity_label.text = str(animal.quantity)

func update_sale_info_labels():
	conejos_sale_info_label.text = "Sale Price: $" + str(animals["Conejos"]["price"])

func check_speed_threshold(animal_name):
	var animal = animals[animal_name]
	if animal.current_threshold_index < animal.speed_thresholds.size():
		var threshold = animal.speed_thresholds[animal.current_threshold_index]
		if animal.quantity >= threshold:
			animal.current_sale_time = max(0.5, animal.current_sale_time / 2.0)
			animal.timer.wait_time = animal.current_sale_time
			animal.timer.start()  # Restart the timer with the new speed
			animal.current_threshold_index += 1
			print(animal_name, " speed increased! New sale time: ", animal.current_sale_time)  # Replace with UI notification

func _on_quantity_button_pressed():
	quantity_index = (quantity_index + 1) % quantities.size()
	selected_quantity = quantities[quantity_index]
	update_quantity_button_text()
	print("Selected quantity: ", selected_quantity)

func update_quantity_button_text():
	quantity_button.text = "Quantity: " + str(selected_quantity)

#Generic buy function to be connected for all animals
func _on_animal_buy_button_pressed(animal_name):
	buy_animal(animal_name)


func _on_conejos_buy_button_pressed(Conejos):
	buy_animal(Conejos)
