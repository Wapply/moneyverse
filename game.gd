extends Control

var money = 5

var animals = {
	"Conejos": {"price": 1, "quantity": 0, "sale_time": 3, "current_sale_time": 3, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Gallinas": {"price": 5, "quantity": 0, "sale_time": 5, "current_sale_time": 5, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Cerdos": {"price": 10, "quantity": 0, "sale_time": 7, "current_sale_time": 7, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Caballos": {"price": 20, "quantity": 0, "sale_time": 10, "current_sale_time": 10, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Vacas": {"price": 50, "quantity": 0, "sale_time": 15, "current_sale_time": 15, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Perros": {"price": 100, "quantity": 0, "sale_time": 20, "current_sale_time": 20, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Gatos": {"price": 200, "quantity": 0, "sale_time": 25, "current_sale_time": 25, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Águilas": {"price": 500, "quantity": 0, "sale_time": 30, "current_sale_time": 30, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Osos": {"price": 1000, "quantity": 0, "sale_time": 35, "current_sale_time": 35, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0},
	"Elefantes": {"price": 5000, "quantity": 0, "sale_time": 60, "current_sale_time": 60, "timer": null, "speed_thresholds": [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600], "current_threshold_index": 0}
}

@onready var money_label = get_node("VBoxContainer/MoneyLabel")

# Removed @onready vars for Conejos buttons as we will connect signals in editor

func _ready():
	update_money_display()
	setup_animal_timers()

func setup_animal_timers():
	for animal_name in animals:
		var timer = Timer.new()
		add_child(timer)
		animals[animal_name]["timer"] = timer
		timer.wait_time = animals[animal_name]["current_sale_time"]
		timer.autostart = true
		timer.timeout.connect(func(): sell_animal(animal_name))

func buy_animal(animal_name, quantity_to_buy):
	var animal = animals[animal_name]
	var cost = animal.price * quantity_to_buy
	if money >= cost:
		money -= cost
		animal.quantity += quantity_to_buy
		update_money_display()
		update_animal_display(animal_name)
		check_speed_threshold(animal_name)
	else:
		print("Not enough money to buy ", quantity_to_buy, " ", animal_name) # Replace with a proper UI notification

func sell_animal(animal_name):
	var animal = animals[animal_name]
	if animal.quantity > 0:
		money += animal.price * animal.quantity
		update_money_display()

func update_money_display():
	print("Attempting to update money display.")
	print("MoneyLabel node:", money_label)
	if money_label != null:
		money_label.text = "Money: $" + str(money)
	else:
		print("Error: MoneyLabel node is null!")

func update_animal_display(animal_name):
	var animal = animals[animal_name]
	print("Getting quantity label for:", animal_name)
	var quantity_label = get_node("VBoxContainer/" + animal_name + "QuantityLabel")
	print("Quantity label node:", quantity_label)
	if quantity_label != null:
		quantity_label.text = str(animal.quantity)
	else:
		print("Error: Quantity label node is null for", animal_name + "QuantityLabel")

func check_speed_threshold(animal_name):
	var animal = animals[animal_name]
	if animal.current_threshold_index < animal.speed_thresholds.size():
		var threshold = animal.speed_thresholds[animal.current_threshold_index]
		if animal.quantity >= threshold:
			animal.current_sale_time = max(0.5, animal.current_sale_time / 2.0)
			animal.timer.wait_time = animal.current_sale_time
			animal.timer.start() # Restart the timer with the new speed
			animal.current_threshold_index += 1
			print(animal_name, " speed increased! New sale time: ", animal.current_sale_time) # Replace with UI notification

# Functions for each Conejos buy button
func _on_ConejosBuyButton_x1_pressed():
	buy_animal("Conejos", 1)

func _on_ConejosBuyButton_x5_pressed():
	buy_animal("Conejos", 5)

func _on_ConejosBuyButton_x10_pressed():
	buy_animal("Conejos", 10)

func _on_ConejosBuyButton_x100_pressed():
	buy_animal("Conejos", 100)

# Example buy functions for other animals (connect these to buttons)
func _on_GallinasBuyButton_pressed(quantity):
	buy_animal("Gallinas", quantity)

func _on_CerdosBuyButton_pressed(quantity):
	buy_animal("Cerdos", quantity)

func _on_CaballosBuyButton_pressed(quantity):
	buy_animal("Caballos", quantity)

func _on_VacasBuyButton_pressed(quantity):
	buy_animal("Vacas", quantity)

func _on_PerrosBuyButton_pressed(quantity):
	buy_animal("Perros", quantity)

func _on_GatosBuyButton_pressed(quantity):
	buy_animal("Gatos", quantity)

func _on_AguilasBuyButton_pressed(quantity):
	buy_animal("Águilas", quantity)

func _on_OsosBuyButton_pressed(quantity):
	buy_animal("Osos", quantity)

func _on_ElefantesBuyButton_pressed(quantity):
	buy_animal("Elefantes", quantity)
