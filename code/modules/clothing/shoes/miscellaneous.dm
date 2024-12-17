/obj/item/clothing/shoes/proc/step_action() //this was made to rewrite clown shoes squeaking
	SEND_SIGNAL(src, COMSIG_SHOES_STEP_ACTION)


/obj/item/clothing/shoes/syndigaloshes
	desc = "A pair of brown shoes. They seem to have extra grip."
	name = "brown shoes"
	icon_state = "brown"
	worn_icon_state = "brown"
	permeability_coefficient = 0.05
	inventory_flags = NOSLIPPING
	var/list/clothing_choices = list()
	siemens_coefficient = 0.8

/obj/item/clothing/shoes/mime
	name = "mime shoes"
	icon_state = "mime"

/obj/item/clothing/shoes/swat
	name = "\improper SWAT shoes"
	desc = "When you want to turn up the heat."
	icon_state = "swat"
	soft_armor = list(MELEE = 80, BULLET = 60, LASER = 50, ENERGY = 25, BOMB = 50, BIO = 10, FIRE = 25, ACID = 25)
	inventory_flags = NOSLIPPING
	item_flags = SYNTH_RESTRICTED
	siemens_coefficient = 0.6

/obj/item/clothing/shoes/ruggedboot
	name = "Rugged Boots"
	desc = "A pair of boots used by workers in dangerous environments."
	icon_state = "swat"
	soft_armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 25, BOMB = 20, BIO = 20, FIRE = 20, ACID = 20)
	inventory_flags = NOSLIPPING
	item_flags = SYNTH_RESTRICTED
	siemens_coefficient = 0.6

/obj/item/clothing/shoes/space_ninja
	name = "ninja shoes"
	desc = "A pair of running shoes. Excellent for running and even better for smashing skulls."
	icon_state = "s-ninja"
	permeability_coefficient = 0.01
	inventory_flags = NOSLIPPING
	soft_armor = list(MELEE = 60, BULLET = 50, LASER = 30, ENERGY = 15, BOMB = 30, BIO = 30, FIRE = 15, ACID = 15)
	siemens_coefficient = 0.2

	cold_protection_flags = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection_flags = FEET
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/shoes/sandal
	desc = "A pair of rather plain, wooden sandals."
	name = "sandals"
	icon_state = "wizard"
	armor_protection_flags = NONE

/obj/item/clothing/shoes/sandal/marisa
	desc = "A pair of magic, black shoes."
	name = "magic shoes"
	icon_state = "black"
	armor_protection_flags = FEET

/obj/item/clothing/shoes/galoshes
	desc = "Rubber boots"
	name = "galoshes"
	icon_state = "galoshes"
	permeability_coefficient = 0.05
	inventory_flags = NOSLIPPING
	slowdown = SHOES_SLOWDOWN+1

/obj/item/clothing/shoes/clown_shoes
	desc = "The prankster's standard-issue clowning shoes. Damn they're huge!"
	name = "clown shoes"
	icon_state = "clown"
	worn_icon_state = "clown"
	slowdown = SHOES_SLOWDOWN + 1


/obj/item/clothing/shoes/galoshes/santa //santa has to wear galoshes to avoid slipping in all the blood he spills on Christmas
	name = "Santa's boots"
	desc = "Made from high quality reindeer leather, Santa owns only the finest footwear."
	icon_state = "santa_galoshes"
	soft_armor = list(MELEE = 80, BULLET = 90, LASER = 90, ENERGY = 85, BOMB = 120, BIO = 85, FIRE = 75, ACID = 40)
	armor_protection_flags = FEET
	slowdown = SLOWDOWN_ARMOR_VERY_LIGHT
	item_flags = DELONDROP
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.2
	resistance_flags = UNACIDABLE

/obj/item/clothing/shoes/galoshes/santa/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_SANTA_CLAUS)

/obj/item/clothing/shoes/clown_shoes/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/clownstep1.ogg', 'sound/effects/clownstep2.ogg'), 50)

/obj/item/clothing/shoes/clown_shoes/erp
	desc ="The prankster's military-standard-issue clowning shoes. Damn they're huge! And reinforced!"
	name = "reinforced clown shoes"
	armor_protection_flags = FEET
	cold_protection_flags = FEET
	heat_protection_flags = FEET
	inventory_flags = NOQUICKEQUIP|NOSLIPPING
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.7

/obj/item/clothing/shoes/jackboots
	name = "jackboots"
	desc = "Security combat boots for combat scenarios or combat situations. All combat, all the time."
	icon_state = "jackboots"
	worn_icon_state = "jackboots"
	siemens_coefficient = 0.7

/obj/item/clothing/shoes/cult
	name = "boots"
	desc = "A pair of boots worn by the followers of Nar-Sie."
	icon_state = "cult"
	worn_icon_state = "cult"
	siemens_coefficient = 0.7

	cold_protection_flags = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection_flags = FEET
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/shoes/cyborg
	name = "cyborg boots"
	desc = "Shoes for a cyborg costume"
	icon_state = "boots"

/obj/item/clothing/shoes/slippers
	name = "bunny slippers"
	desc = "Fluffy!"
	icon_state = "slippers"
	worn_icon_state = "slippers"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/shoes/slippers_worn
	name = "worn bunny slippers"
	desc = "Fluffy..."
	icon_state = "slippers_worn"
	worn_icon_state = "slippers_worn"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/shoes/laceup
	name = "laceup shoes"
	desc = "The height of fashion, and they're pre-polished!"
	icon_state = "laceups"

/obj/item/clothing/shoes/swimmingfins
	desc = "Help you swim good."
	name = "swimming fins"
	icon_state = "flippers"
	inventory_flags = NOSLIPPING
	slowdown = SHOES_SLOWDOWN+1


/obj/item/clothing/shoes/snow
	name = "snow boots"
	desc = "When you feet are as cold as your heart"
	icon_state = "swat"
	siemens_coefficient = 0.6
	cold_protection_flags = FEET
	heat_protection_flags = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/shoes/techpriest
	name = "Techpriest boots"
	desc = "Praise the machine spirit!"
	icon_state = "tp_boots"
	worn_icon_state = "tp_boots"
	inventory_flags = NOSLIPPING


//Deathsquad suit
/obj/item/clothing/head/helmet/space/deathsquad
	name = "deathsquad helmet"
	desc = "That's not red paint. That's real blood."
	icon_state = "deathsquad"
	worn_icon_state = "deathsquad"
	soft_armor = list(MELEE = 65, BULLET = 55, LASER = 35, ENERGY = 20, BOMB = 30, BIO = 100, FIRE = 20, ACID = 20)
	siemens_coefficient = 0.6

/obj/item/clothing/head/helmet/space/deathsquad/beret
	name = "officer's beret"
	desc = "An armored beret commonly used by special operations officers."
	icon_state = "beret_badge"
	soft_armor = list(MELEE = 65, BULLET = 55, LASER = 35, ENERGY = 20, BOMB = 30, BIO = 30, FIRE = 20, ACID = 20)
	inventory_flags = NOPRESSUREDMAGE|BLOCKSHARPOBJ
	inv_hide_flags = HIDEEYES
	siemens_coefficient = 0.9

//Space pirate outfit
/obj/item/clothing/head/helmet/space/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	worn_icon_state = "pirate"
	soft_armor = list(MELEE = 60, BULLET = 50, LASER = 30, ENERGY = 15, BOMB = 30, BIO = 30, FIRE = 15, ACID = 15)
	inventory_flags = NOPRESSUREDMAGE|BLOCKSHARPOBJ
	inv_hide_flags = HIDEEYES
	armor_protection_flags = NONE
	siemens_coefficient = 0.9

/obj/item/clothing/suit/space/pirate
	name = "pirate coat"
	desc = "Yarr."
	icon_state = "pirate"
	worn_icon_state = "pirate"
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/baton,/obj/item/restraints/handcuffs,/obj/item/tank/emergency_oxygen)
	slowdown = 0
	soft_armor = list(MELEE = 60, BULLET = 50, LASER = 30, ENERGY = 15, BOMB = 30, BIO = 30, FIRE = 15, ACID = 15)
	siemens_coefficient = 0.9
	armor_protection_flags = CHEST|ARMS

/obj/item/clothing/head/helmet/space/compression
	name = "\improper MK.50 compression helmet"
	desc = "A heavy space helmet, designed to be coupled with the MK.50 compression suit, though it is less resilient than the suit. Feels like you could hotbox in here."
	worn_icon_state = "compression"
	icon_state = "compression"
	soft_armor = list(MELEE = 40, BULLET = 45, LASER = 40, ENERGY = 55, BOMB = 40, BIO = 100, FIRE = 55, ACID = 55)
	resistance_flags = UNACIDABLE

/obj/item/clothing/suit/space/compression
	name = "\improper MK.50 compression suit"
	desc = "A heavy, bulky civilian space suit, fitted with armored plates. Commonly seen in the hands of mercenaries, explorers, scavengers, and researchers."
	worn_icon_state = "compression"
	icon_state = "compression"
	soft_armor = list(MELEE = 40, BULLET = 55, LASER = 65, ENERGY = 70, BOMB = 65, BIO = 100, FIRE = 70, ACID = 70)
	resistance_flags = UNACIDABLE

/obj/item/clothing/head/helmet/space/chronos
	name = "\improper Chronos Mk 0 Bluespace helmet"
	desc = "A sleek silver helmet. It almost seems to stem from the future..."
	worn_icon_state = "chronos"
	icon_state = "chronos"
	soft_armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 100, BIO = 100, FIRE = 100, ACID = 100)
	resistance_flags = UNACIDABLE
	siemens_coefficient = 0

/obj/item/clothing/suit/space/chronos
	name = "\improper Chronos Mk 0 Bluespace armor"
	desc = "A sleek silver suit. It almost seems to stem from the future..."
	worn_icon_state = "chronos"
	icon_state = "chronos"
	soft_armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 100, BIO = 100, FIRE = 100, ACID = 100)	//DONT FUCK WITH THIS SENATOR
	resistance_flags = UNACIDABLE
	siemens_coefficient = 0
	slowdown = 0
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/baton,/obj/item/restraints/handcuffs,/obj/item/tank/emergency_oxygen)

