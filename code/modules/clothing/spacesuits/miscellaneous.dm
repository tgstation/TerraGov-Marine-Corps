

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

//Space santa outfit suit
/obj/item/clothing/head/helmet/space/santahat
	name = "Santa's hat"
	desc = "Ho ho ho. Merrry X-mas!"
	icon_state = "santahat2"
	flags_inventory = NOPRESSUREDMAGE|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEYES
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 10, BIO = 5, FIRE = 5, ACID = 5)
	flags_item_map_variant = NONE
	flags_armor_features = ARMOR_NO_DECAP


/obj/item/clothing/head/helmet/space/elf
	name = "elf hat"
	desc = "A slightly floppy hat worn by Santa's workforce, a careful look reveals a tag with the words 'Made on Mars' inside."
	icon_state = "elfhat"
	soft_armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 15, BIO = 10, FIRE = 10, ACID = 10)
	flags_item = NODROP|DELONDROP
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/suit/space/santa
	name = "Santa's suit"
	desc = "Festive!"
	icon_state = "santa"
	item_state = "santa"
	slowdown = 0
	allowed = list(/obj/item) //for stuffing exta special presents

/obj/item/clothing/suit/space/santa/special //for ERT, when santa has to give presents to REALLY naughty children
	desc = "That's not red dye. That's red blood."
	soft_armor = list(MELEE = 85, BULLET = 90, LASER = 90, ENERGY = 85, BOMB = 120, BIO = 85, FIRE = 75, ACID = 40)
	slowdown = 1
	flags_item = NODROP|DELONDROP
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	flags_heat_protection = CHEST|GROIN|ARMS|LEGS|FEET|HANDS
	supporting_limbs = CHEST | GROIN | ARM_LEFT | ARM_RIGHT | HAND_LEFT | HAND_RIGHT | LEG_LEFT | LEG_RIGHT | FOOT_LEFT | FOOT_RIGHT | HEAD
	resistance_flags = UNACIDABLE

/obj/item/clothing/head/helmet/space/santahat/special
	name = "Santa's hat"
	desc = "Ho ho ho. Merrry X-mas to all! Now you're all gonna die!"
	soft_armor = list(MELEE = 85, BULLET = 90, LASER = 90, ENERGY = 85, BOMB = 120, BIO = 85, FIRE = 75, ACID = 40)
	flags_item = NODROP|DELONDROP
	flags_inventory = COVEREYES|COVERMOUTH|BLOCKSHARPOBJ|BLOCKGASEFFECT

/obj/item/clothing/suit/space/elf
	name = "Elf suit"
	desc = "Festive!"
	icon_state = "elfcostume"
	item_state = "elfcostume"
	soft_armor = list(MELEE = 35, BULLET = 15, LASER = 15, ENERGY = 10, BOMB = 20, BIO = 30, FIRE = 20, ACID = 10)
	flags_item = NODROP|DELONDROP

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
