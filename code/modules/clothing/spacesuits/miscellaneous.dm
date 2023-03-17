

//Space santa outfit suit
/obj/item/clothing/head/helmet/space/santahat
	name = "Santa's hat"
	desc = "Ho ho ho. Merrry X-mas!"
	icon_state = "santahat"
	flags_inventory = NOPRESSUREDMAGE|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEYES
	flags_armor_protection = HEAD

/obj/item/clothing/suit/space/santa
	name = "Santa's suit"
	desc = "Festive!"
	icon_state = "santa"
	item_state = "santa"
	slowdown = 0
	allowed = list(/obj/item) //for stuffing exta special presents

//Space pirate outfit
/obj/item/clothing/head/helmet/space/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	soft_armor = list(MELEE = 60, BULLET = 50, LASER = 30, ENERGY = 15, BOMB = 30, BIO = 30, FIRE = 15, ACID = 15)
	flags_inventory = NOPRESSUREDMAGE|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEYES
	flags_armor_protection = NONE
	siemens_coefficient = 0.9

/obj/item/clothing/suit/space/pirate
	name = "pirate coat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/baton,/obj/item/restraints/handcuffs,/obj/item/tank/emergency_oxygen)
	slowdown = 0
	soft_armor = list(MELEE = 60, BULLET = 50, LASER = 30, ENERGY = 15, BOMB = 30, BIO = 30, FIRE = 15, ACID = 15)
	siemens_coefficient = 0.9
	flags_armor_protection = CHEST|ARMS

/obj/item/clothing/head/helmet/space/chronos
	name = "\improper Chronos Mk 0 Bluespace helmet"
	desc = "A sleek silver helmet. It almost seems to stem from the future..."
	item_state = "chronos"
	icon_state = "chronos"
	soft_armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 100, BIO = 100, FIRE = 100, ACID = 100)
	resistance_flags = UNACIDABLE
	siemens_coefficient = 0

/obj/item/clothing/suit/space/chronos
	name = "\improper Chronos Mk 0 Bluespace armor"
	desc = "A sleek silver suit. It almost seems to stem from the future..."
	item_state = "chronos"
	icon_state = "chronos"
	soft_armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 100, BIO = 100, FIRE = 100, ACID = 100)	//DONT FUCK WITH THIS SENATOR
	resistance_flags = UNACIDABLE
	siemens_coefficient = 0
	slowdown = 0
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/baton,/obj/item/restraints/handcuffs,/obj/item/tank/emergency_oxygen)
