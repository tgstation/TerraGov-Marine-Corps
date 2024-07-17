/obj/item/reagent_containers/food/snacks/tortilla
	name = "tortilla"
	desc = "The base for all your burritos."
	icon = 'icons/obj/items/food/food_ingredients.dmi'
	icon_state = "tortilla"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("tortilla" = 1)
	w_class = WEIGHT_CLASS_TINY

/obj/item/reagent_containers/food/snacks/mexican
	icon = 'icons/obj/items/food/mexican.dmi'

/obj/item/reagent_containers/food/snacks/mexican/burrito
	name = "burrito"
	desc = "Tortilla wrapped goodness."
	icon_state = "openburrito"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("torilla" = 2, "beans" = 3)
	w_class = WEIGHT_CLASS_SMALL

/obj/item/reagent_containers/food/snacks/mexican/cheesyburrito
	name = "cheesy burrito"
	desc = "It's a burrito filled with cheese."
	icon_state = "cheesyburrito"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("torilla" = 2, "beans" = 3, "cheese" = 1)
	w_class = WEIGHT_CLASS_SMALL

/obj/item/reagent_containers/food/snacks/mexican/carneburrito
	name = "carne asada burrito"
	desc = "The best burrito for meat lovers."
	icon_state = "carneburrito"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("torilla" = 2, "meat" = 4)
	w_class = WEIGHT_CLASS_SMALL

/obj/item/reagent_containers/food/snacks/mexican/fuegoburrito
	name = "fuego plasma burrito"
	desc = "A super spicy burrito."
	icon_state = "fuegoburrito"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/capsaicin = 5, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("torilla" = 2, "beans" = 3, "hot peppers" = 1)
	w_class = WEIGHT_CLASS_SMALL

/obj/item/reagent_containers/food/snacks/mexican/nachos
	name = "nachos"
	desc = "Chips from Space Mexico."
	icon_state = "nachos"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("nachos" = 1)
	w_class = WEIGHT_CLASS_SMALL

/obj/item/reagent_containers/food/snacks/mexican/cheesynachos
	name = "cheesy nachos"
	desc = "The delicious combination of nachos and melting cheese."
	icon_state = "cheesynachos"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/protein = 1, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("nachos" = 2, "cheese" = 1)
	w_class = WEIGHT_CLASS_SMALL

/obj/item/reagent_containers/food/snacks/mexican/cubannachos
	name = "Cuban nachos"
	desc = "That's some dangerously spicy nachos."
	icon_state = "cubannachos"
	list_reagents = list(/datum/reagent/consumable/nutriment = 7, /datum/reagent/consumable/capsaicin = 8, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("nachos" = 2, "hot pepper" = 1)
	w_class = WEIGHT_CLASS_SMALL

/obj/item/reagent_containers/food/snacks/mexican/taco
	name = "classic taco"
	desc = "A traditional taco with meat, cheese, and lettuce."
	icon_state = "taco"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("taco" = 4, "meat" = 2, "cheese" = 2, "lettuce" = 1)
	w_class = WEIGHT_CLASS_SMALL

/obj/item/reagent_containers/food/snacks/mexican/taco/plain
	name = "plain taco"
	desc = "A traditional taco with meat and cheese, minus the rabbit food."
	icon_state = "taco_plain"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("taco" = 4, "meat" = 2, "cheese" = 2)

/obj/item/reagent_containers/food/snacks/mexican/enchiladas
	name = "enchiladas"
	desc = "Viva La Mexico!"
	icon_state = "enchiladas"
	bitesize = 4
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 7, /datum/reagent/consumable/capsaicin = 6, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("hot peppers" = 1, "meat" = 3, "cheese" = 1, "sour cream" = 1)
	w_class = WEIGHT_CLASS_SMALL
