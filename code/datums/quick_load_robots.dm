/*!
 * Any loadout that is intended for the new player loadout vendor FOR ROBOTS
 */

///When making new loadouts, remember to also add the typepath to the list under init_robot_loadouts() or else it won't show up in the vendor

/datum/outfit/quick/beginner_robot
	name = "Robot loadout base"
	desc = "The base loadout for beginners. You shouldn't be able to see this"
	jobtype = null //Override this, this is not optional

	//Radio and undersuit never change for robots
	w_uniform = /obj/item/clothing/under/marine/robotic
	ears = /obj/item/radio/headset/mainship/marine

	//template
	wear_suit = null
	glasses = null
	head = null

	r_store = null
	l_store = null

	back = null
	belt = null
	suit_store = null

/datum/outfit/quick/beginner_robot/marine/shotgunner
	name = "Shotgunner"
	desc = "You want to know why I used the shotgun? That's because it doesn't miss" //placeholder
	jobtype = "Squad Marine"

	w_uniform = /obj/item/clothing/under/marine/robotic/webbing
	wear_suit = /obj/item/clothing/suit/modular/robot/light
	head = /obj/item/clothing/head/modular/robot/light

	r_store = /obj/item/storage/pouch/shotgun
	l_store = /obj/item/storage/pouch/shotgun

	back = /obj/item/storage/backpack/marine
	belt = /obj/item/storage/belt/shotgun
	suit_store = /obj/item/weapon/gun/shotgun/combat/standardmarine/beginner

/datum/outfit/quick/beginner_robot/marine/shotgunner/post_equip(mob/living/carbon/human/H, visualsOnly)
	for(var/amount_to_fill in 1 to 6)
		H.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BACKPACK)
	for(var/amount_to_fill in 1 to 6)
		H.equip_to_slot_or_del(new /obj/item/tool/weldingtool, SLOT_IN_BACKPACK)

	for(var/amount_to_fill in 1 to 14)
		H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BELT)
	for(var/amount_to_fill in 1 to 4)
		H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_L_POUCH)
	for(var/amount_to_fill in 1 to 4)
		H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_R_POUCH)
