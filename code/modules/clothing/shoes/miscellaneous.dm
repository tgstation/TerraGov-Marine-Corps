/obj/item/clothing/shoes/proc/step_action() //this was made to rewrite clown shoes squeaking
	SEND_SIGNAL(src, COMSIG_SHOES_STEP_ACTION)


/obj/item/clothing/shoes/syndigaloshes
	desc = "A pair of brown shoes. They seem to have extra grip."
	name = "brown shoes"
	icon_state = "brown"
	item_state = "brown"
	permeability_coefficient = 0.05
	flags_inventory = NOSLIPPING
	var/list/clothing_choices = list()
	siemens_coefficient = 0.8

/obj/item/clothing/shoes/mime
	name = "mime shoes"
	icon_state = "mime"

/obj/item/clothing/shoes/swat
	name = "\improper SWAT shoes"
	desc = "When you want to turn up the heat."
	icon_state = "swat"
	soft_armor = list("melee" = 80, "bullet" = 60, "laser" = 50, "energy" = 25, "bomb" = 50, "bio" = 10, "rad" = 0, "fire" = 25, "acid" = 25)
	flags_inventory = NOSLIPPING
	flags_item = SYNTH_RESTRICTED
	siemens_coefficient = 0.6

/obj/item/clothing/shoes/ruggedboot
	name = "Rugged Boots"
	desc = "A pair of boots used by workers in dangerous environments."
	icon_state = "swat"
	soft_armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 25, "bomb" = 20, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 20)
	flags_inventory = NOSLIPPING
	flags_item = SYNTH_RESTRICTED
	siemens_coefficient = 0.6

/obj/item/clothing/shoes/combat //Basically SWAT shoes combined with galoshes.
	name = "combat boots"
	desc = "When you REALLY want to turn up the heat"
	icon_state = "swat"
	flags_item = SYNTH_RESTRICTED
	soft_armor = list("melee" = 80, "bullet" = 60, "laser" = 50, "energy" = 25, "bomb" = 50, "bio" = 10, "rad" = 0, "fire" = 25, "acid" = 25)
	flags_inventory = NOSLIPPING
	siemens_coefficient = 0.6

	flags_cold_protection = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	flags_heat_protection = FEET
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/shoes/space_ninja
	name = "ninja shoes"
	desc = "A pair of running shoes. Excellent for running and even better for smashing skulls."
	icon_state = "s-ninja"
	permeability_coefficient = 0.01
	flags_inventory = NOSLIPPING
	soft_armor = list("melee" = 60, "bullet" = 50, "laser" = 30, "energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 15, "acid" = 15)
	siemens_coefficient = 0.2

	flags_cold_protection = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	flags_heat_protection = FEET
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/shoes/sandal
	desc = "A pair of rather plain, wooden sandals."
	name = "sandals"
	icon_state = "wizard"
	flags_armor_protection = NONE

/obj/item/clothing/shoes/sandal/marisa
	desc = "A pair of magic, black shoes."
	name = "magic shoes"
	icon_state = "black"
	flags_armor_protection = FEET

/obj/item/clothing/shoes/galoshes
	desc = "Rubber boots"
	name = "galoshes"
	icon_state = "galoshes"
	permeability_coefficient = 0.05
	flags_inventory = NOSLIPPING
	slowdown = SHOES_SLOWDOWN+1

/obj/item/clothing/shoes/clown_shoes
	desc = "The prankster's standard-issue clowning shoes. Damn they're huge!"
	name = "clown shoes"
	icon_state = "clown"
	item_state = "clown"
	slowdown = SHOES_SLOWDOWN + 1


/obj/item/clothing/shoes/clown_shoes/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/clownstep1.ogg', 'sound/effects/clownstep2.ogg'), 50)


/obj/item/clothing/shoes/jackboots
	name = "jackboots"
	desc = "Security combat boots for combat scenarios or combat situations. All combat, all the time."
	icon_state = "jackboots"
	item_state = "jackboots"
	siemens_coefficient = 0.7

/obj/item/clothing/shoes/cult
	name = "boots"
	desc = "A pair of boots worn by the followers of Nar-Sie."
	icon_state = "cult"
	item_state = "cult"
	siemens_coefficient = 0.7

	flags_cold_protection = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	flags_heat_protection = FEET
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/shoes/cyborg
	name = "cyborg boots"
	desc = "Shoes for a cyborg costume"
	icon_state = "boots"

/obj/item/clothing/shoes/slippers
	name = "bunny slippers"
	desc = "Fluffy!"
	icon_state = "slippers"
	item_state = "slippers"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/shoes/slippers_worn
	name = "worn bunny slippers"
	desc = "Fluffy..."
	icon_state = "slippers_worn"
	item_state = "slippers_worn"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/shoes/laceup
	name = "laceup shoes"
	desc = "The height of fashion, and they're pre-polished!"
	icon_state = "laceups"

/obj/item/clothing/shoes/swimmingfins
	desc = "Help you swim good."
	name = "swimming fins"
	icon_state = "flippers"
	flags_inventory = NOSLIPPING
	slowdown = SHOES_SLOWDOWN+1


/obj/item/clothing/shoes/snow
	name = "snow boots"
	desc = "When you feet are as cold as your heart"
	icon_state = "swat"
	siemens_coefficient = 0.6
	flags_cold_protection = FEET
	flags_heat_protection = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/shoes/techpriest
	name = "Techpriest boots"
	desc = "Praise the machine spirit!"
	icon_state = "tp_boots"
	item_state = "tp_boots"
	flags_inventory = NOSLIPPING


