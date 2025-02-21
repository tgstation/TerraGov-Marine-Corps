
/obj/item/clothing/head/helmet/space/tgmc
	name = "\improper TGMC Compression Helmet"
	desc = "A high tech, TGMC designed, dark red space suit helmet. Used for maintenance in space."
	icon_state = "void_helm"
	anti_hug = 3

/obj/item/clothing/suit/space/tgmc
	name = "\improper TGMC Compression Suit"
	icon_state = "void"
	desc = "A high tech, TGMC designed, dark red Space suit. Used for maintenance in space."
	slowdown = 1


/obj/item/clothing/head/helmet/space/capspace
	name = "space helmet"
	icon_state = "capspace"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Only for the most fashionable of military figureheads."
	permeability_coefficient = 0.01
	soft_armor = list(MELEE = 40, BULLET = 50, LASER = 50, ENERGY = 25, BOMB = 50, BIO = 100, FIRE = 25, ACID = 25)

/obj/item/clothing/suit/space/captain
	name = "Captain's armor"
	desc = "A bulky, heavy-duty piece of exclusive Nanotrasen armor. YOU are in charge!"
	icon_state = "caparmor"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	armor_protection_flags = CHEST|GROIN|LEGS|FEET|ARMS
	allowed = list(/obj/item/tank/emergency_oxygen, /obj/item/flashlight,/obj/item/weapon/gun, /obj/item/ammo_magazine, /obj/item/weapon/baton,/obj/item/restraints/handcuffs)
	slowdown = 1.5
	soft_armor = list(MELEE = 40, BULLET = 50, LASER = 50, ENERGY = 25, BOMB = 50, BIO = 100, FIRE = 25, ACID = 25)
	inventory_flags = NOPRESSUREDMAGE
	inv_hide_flags = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	cold_protection_flags = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.7

//space santa
/obj/item/clothing/head/helmet/space/santahat
	name = "Santa's hat"
	desc = "Ho ho ho. Merrry X-mas!"
	icon_state = "santahat"
	inventory_flags = NOPRESSUREDMAGE|BLOCKSHARPOBJ
	inv_hide_flags = HIDEEYES
	armor_protection_flags = HEAD

/obj/item/clothing/suit/space/santa
	name = "Santa's suit"
	desc = "Festive!"
	icon_state = "santa"
	slowdown = 0
	allowed = list(/obj/item) //for stuffing exta special presents

/obj/item/clothing/head/helmet/space/chronos
	name = "\improper Chronos Mk 0 Bluespace helmet"
	desc = "A sleek silver helmet. It almost seems to stem from the future..."
	icon_state = "rig-chronos"
	soft_armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 100, BIO = 100, FIRE = 100, ACID = 100)
	resistance_flags = UNACIDABLE
	siemens_coefficient = 0

/obj/item/clothing/suit/space/chronos
	name = "\improper Chronos Mk 0 Bluespace armor"
	desc = "A sleek silver suit. It almost seems to stem from the future..."
	icon_state = "rig-chronos"
	soft_armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 100, BIO = 100, FIRE = 100, ACID = 100)	//DONT FUCK WITH THIS SENATOR
	resistance_flags = UNACIDABLE
	siemens_coefficient = 0
	slowdown = 0
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/baton,/obj/item/restraints/handcuffs,/obj/item/tank/emergency_oxygen)
