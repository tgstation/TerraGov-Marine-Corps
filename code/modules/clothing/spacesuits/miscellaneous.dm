

//Deathsquad suit
/obj/item/clothing/head/helmet/space/deathsquad
	name = "deathsquad helmet"
	desc = "That's not red paint. That's real blood."
	icon_state = "deathsquad"
	item_state = "deathsquad"
	soft_armor = list(MELEE = 65, BULLET = 55, LASER = 35, ENERGY = 20, BOMB = 30, BIO = 100, FIRE = 20, ACID = 20)
	siemens_coefficient = 0.6

/obj/item/clothing/head/helmet/space/deathsquad/beret
	name = "officer's beret"
	desc = "An armored beret commonly used by special operations officers."
	icon_state = "beret_badge"
	soft_armor = list(MELEE = 65, BULLET = 55, LASER = 35, ENERGY = 20, BOMB = 30, BIO = 30, FIRE = 20, ACID = 20)
	flags_inventory = NOPRESSUREDMAGE|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEYES
	siemens_coefficient = 0.9

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

/obj/item/clothing/suit/costume/snowman
	name = "snowman outfit"
	desc = "Two white spheres covered in white glitter. 'Tis the season."
	icon_state = "snowman"
	item_state = "snowman"
	slowdown = 3
	soft_armor = list(MELEE = 35, BULLET = 35, LASER = 30, ENERGY = 15, BOMB = 30, BIO = 30, FIRE = 0, ACID = 0)
	w_class = WEIGHT_CLASS_NORMAL
	flags_armor_protection = FULL_BODY

/obj/item/clothing/head/snowman
	name = "snowman head"
	desc = "A ball of white styrofoam. So festive."
	icon_state = "snowman_h"
	item_icons = list(
		slot_head_str = 'icons/mob/head_1.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',)
	flags_inv_hide = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEALLHAIR
	soft_armor = list(MELEE = 20, BULLET = 20, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 15, FIRE = 0, ACID = 5)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/helmet/space/compression
	name = "\improper MK.50 compression helmet"
	desc = "A heavy space helmet, designed to be coupled with the MK.50 compression suit, though it is less resilient than the suit. Feels like you could hotbox in here."
	item_state = "compression"
	icon_state = "compression"
	soft_armor = list(MELEE = 40, BULLET = 45, LASER = 40, ENERGY = 55, BOMB = 40, BIO = 100, FIRE = 55, ACID = 55)
	resistance_flags = UNACIDABLE

/obj/item/clothing/suit/space/compression
	name = "\improper MK.50 compression suit"
	desc = "A heavy, bulky civilian space suit, fitted with armored plates. Commonly seen in the hands of mercenaries, explorers, scavengers, and researchers."
	item_state = "compression"
	icon_state = "compression"
	soft_armor = list(MELEE = 40, BULLET = 55, LASER = 65, ENERGY = 70, BOMB = 65, BIO = 100, FIRE = 70, ACID = 70)
	resistance_flags = UNACIDABLE

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
