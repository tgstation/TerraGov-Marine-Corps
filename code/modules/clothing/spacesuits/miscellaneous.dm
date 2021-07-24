

//Deathsquad suit
/obj/item/clothing/head/helmet/space/deathsquad
	name = "deathsquad helmet"
	desc = "That's not red paint. That's real blood."
	icon_state = "deathsquad"
	item_state = "deathsquad"
	soft_armor = list("melee" = 65, "bullet" = 55, "laser" = 35, "energy" = 20, "bomb" = 30, "bio" = 100, "rad" = 60, "fire" = 20, "acid" = 20)
	siemens_coefficient = 0.6

/obj/item/clothing/head/helmet/space/deathsquad/beret
	name = "officer's beret"
	desc = "An armored beret commonly used by special operations officers."
	icon_state = "beret_badge"
	soft_armor = list("melee" = 65, "bullet" = 55, "laser" = 35, "energy" = 20, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 20, "acid" = 20)
	flags_inventory = NOPRESSUREDMAGE|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEYES
	siemens_coefficient = 0.9

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
	soft_armor = list("melee" = 60, "bullet" = 50, "laser" = 30, "energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 15, "acid" = 15)
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
	soft_armor = list("melee" = 60, "bullet" = 50, "laser" = 30, "energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 15, "acid" = 15)
	siemens_coefficient = 0.9
	flags_armor_protection = CHEST|ARMS



/obj/item/clothing/head/helmet/space/compression
	name = "\improper MK.50 compression helmet"
	desc = "A heavy space helmet, designed to be coupled with the MK.50 compression suit, though it is less resilient than the suit. Feels like you could hotbox in here."
	item_state = "compression"
	icon_state = "compression"
	soft_armor = list("melee" = 40, "bullet" = 45, "laser" = 40, "energy" = 55, "bomb" = 40, "bio" = 100, "rad" = 50, "fire" = 55, "acid" = 55)
	resistance_flags = UNACIDABLE

/obj/item/clothing/suit/space/compression
	name = "\improper MK.50 compression suit"
	desc = "A heavy, bulky civilian space suit, fitted with armored plates. Commonly seen in the hands of mercenaries, explorers, scavengers, and researchers."
	item_state = "compression"
	icon_state = "compression"
	soft_armor = list("melee" = 40, "bullet" = 55, "laser" = 65, "energy" = 70, "bomb" = 65, "bio" = 100, "rad" = 70, "fire" = 70, "acid" = 70)
	resistance_flags = UNACIDABLE

/obj/item/clothing/head/helmet/space/chronos
	name = "\improper Chronos Mk 0 Bluespace helmet"
	desc = "A sleek silver helmet. It almost seems to stem from the future..."
	item_state = "chronos"
	icon_state = "chronos"
	soft_armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
	resistance_flags = UNACIDABLE
	siemens_coefficient = 0

/obj/item/clothing/suit/space/chronos
	name = "\improper Chronos Mk 0 Bluespace armor"
	desc = "A sleek silver suit. It almost seems to stem from the future..."
	item_state = "chronos"
	icon_state = "chronos"
	soft_armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)	//DONT FUCK WITH THIS SENATOR
	resistance_flags = UNACIDABLE
	siemens_coefficient = 0
	slowdown = 0
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/baton,/obj/item/restraints/handcuffs,/obj/item/tank/emergency_oxygen)
