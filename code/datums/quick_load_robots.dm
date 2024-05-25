/*!
 * Any loadout that is intended for the new player loadout vendor FOR ROBOTS
 */

// When making new loadouts, remember to also add the typepath to the list under init_robot_loadouts() or else it won't show up in the vendor
// There is expected to be a bit of copy-paste throughout the loadouts. This is fine and is done to maintain readability

/datum/outfit/quick/beginner_robot
	name = "Robot loadout base"
	desc = "The base loadout for beginners. You shouldn't be able to see this"
	jobtype = null //Override this, this is not optional

	//All loadouts get a radio
	ears = /obj/item/radio/headset/mainship/marine

	/**
	 * Template, loadout rules are as follows:
	 *
	 * * Loudouts remain simple, 1 gun with 1 sidearm at max
	 * * Always have some form of healing, blowtorch/cables somewhere
	 * * Always have spare ammo for any gun that gets carried
	 * * Avoid using gear that a marine cannot reasonably obtain, even 1 hour into a round
	 * * Recommended: Some flares/inaprovaline, this enforces good behaviour in beginners to carry items that don't directly benefit them
	 */
	w_uniform = /obj/item/clothing/under/marine/robotic
	wear_suit = /obj/item/clothing/suit/modular/robot
	glasses = null
	head = /obj/item/clothing/head/modular/robot

	l_store = null
	r_store = null

	back = /obj/item/storage/backpack/marine
	belt = null
	suit_store = null

//---- Squad Marine loadouts
/datum/outfit/quick/beginner_robot/marine
	jobtype = "Squad Marine"

/datum/outfit/quick/beginner_robot/marine/rifleman
	name = "Rifleman"
	desc = "Rifleman"

	w_uniform = /obj/item/clothing/under/marine/robotic/holster
	wear_suit = /obj/item/clothing/suit/modular/robot/hodgrenades
	head = /obj/item/clothing/head/modular/robot/hod

	l_store = /obj/item/storage/holster/flarepouch/full
	r_store = /obj/item/storage/pouch/magazine/large

	back = /obj/item/storage/backpack/marine
	belt = /obj/item/storage/belt/marine
	suit_store = /obj/item/weapon/gun/rifle/standard_assaultrifle/medic

/datum/outfit/quick/beginner_robot/marine/rifleman/post_equip(mob/living/carbon/human/H, visualsOnly)
	for(var/amount_to_fill in 1 to 6)
		H.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BACKPACK)
	for(var/amount_to_fill in 1 to 6)
		H.equip_to_slot_or_del(new /obj/item/tool/weldingtool, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)

	for(var/amount_to_fill in 1 to 6)
		H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)
	for(var/amount_to_fill in 1 to 3)
		H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol/beginner(H), SLOT_IN_ACCESSORY)

	for(var/amount_to_fill in 1 to 6)
		H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_SUIT)

/datum/outfit/quick/beginner_robot/marine/machinegunner
	name = "Machinegunner"
	desc = "Machinegunner"

	w_uniform = /obj/item/clothing/under/marine/robotic/black_vest
	wear_suit = /obj/item/clothing/suit/modular/robot/heavy/tyr_onegeneral
	head = /obj/item/clothing/head/modular/robot/heavy/tyr

	l_store = /obj/item/storage/holster/flarepouch/full
	r_store = /obj/item/storage/pouch/tools

	back = /obj/item/storage/backpack/marine
	belt = /obj/item/storage/belt/sparepouch
	suit_store = /obj/item/weapon/gun/rifle/standard_gpmg/beginner

/datum/outfit/quick/beginner_robot/marine/machinegunner/post_equip(mob/living/carbon/human/H, visualsOnly)
	for(var/amount_to_fill in 1 to 8)
		H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_gpmg , SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)

	for(var/amount_to_fill in 1 to 5)
		H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_ACCESSORY)

	for(var/amount_to_fill in 1 to 3)
		H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_gpmg , SLOT_IN_BELT)
	for(var/amount_to_fill in 1 to 2)
		H.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_R_POUCH)
	for(var/amount_to_fill in 1 to 3)
		H.equip_to_slot_or_del(new /obj/item/tool/weldingtool, SLOT_IN_R_POUCH)

	for(var/amount_to_fill in 1 to 2)
		H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_gpmg , SLOT_IN_SUIT)

/datum/outfit/quick/beginner_robot/marine/marksman
	name = "Marksman"
	desc = "Marksman"

	w_uniform = /obj/item/clothing/under/marine/robotic/holster
	wear_suit = /obj/item/clothing/suit/modular/robot/lightgeneral
	head = /obj/item/clothing/head/modular/robot

	l_store = /obj/item/storage/holster/flarepouch/full
	r_store = /obj/item/storage/pouch/magazine/large

	back = /obj/item/storage/backpack/marine
	belt = /obj/item/belt_harness/marine
	suit_store = /obj/item/weapon/gun/rifle/standard_dmr/beginner

/datum/outfit/quick/beginner_robot/marine/marksman/post_equip(mob/living/carbon/human/H, visualsOnly)
	for(var/amount_to_fill in 1 to 6)
		H.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BACKPACK)
	for(var/amount_to_fill in 1 to 6)
		H.equip_to_slot_or_del(new /obj/item/tool/weldingtool, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70/beginner(H), SLOT_IN_ACCESSORY)

	for(var/amount_to_fill in 1 to 3)
		H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_dmr, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_dmr, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_dmr, SLOT_IN_SUIT)

/datum/outfit/quick/beginner_robot/marine/shotgunner
	name = "Shotgunner"
	desc = "Shotgunner" //placeholder

	w_uniform = /obj/item/clothing/under/marine/robotic/holster
	wear_suit = /obj/item/clothing/suit/modular/robot/lightgeneral
	head = /obj/item/clothing/head/modular/robot

	l_store = /obj/item/storage/holster/flarepouch/full
	r_store = /obj/item/storage/pouch/shotgun

	back = /obj/item/storage/backpack/marine
	belt = /obj/item/storage/belt/shotgun
	suit_store = /obj/item/weapon/gun/shotgun/combat/standardmarine/beginner

/datum/outfit/quick/beginner_robot/marine/shotgunner/post_equip(mob/living/carbon/human/H, visualsOnly)
	for(var/amount_to_fill in 1 to 6)
		H.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BACKPACK)
	for(var/amount_to_fill in 1 to 6)
		H.equip_to_slot_or_del(new /obj/item/tool/weldingtool, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)

	for(var/amount_to_fill in 1 to 14)
		H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BELT)
	for(var/amount_to_fill in 1 to 4)
		H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/plasma_pistol/beginner(H), SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_SUIT)

/datum/outfit/quick/beginner_robot/marine/shocktrooper
	name = "Shocktrooper"
	desc = "Shocktrooper"

	w_uniform = /obj/item/clothing/under/marine/robotic/black_vest
	wear_suit = /obj/item/clothing/suit/modular/robot/lightgeneral
	head = /obj/item/clothing/head/modular/robot

	l_store = /obj/item/storage/holster/flarepouch/full
	r_store = /obj/item/cell/lasgun/volkite/powerpack/marine

	back = /obj/item/storage/backpack/marine
	belt = /obj/item/storage/belt/marine
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle/medic

/datum/outfit/quick/beginner_robot/marine/shocktrooper/post_equip(mob/living/carbon/human/H, visualsOnly)
	for(var/amount_to_fill in 1 to 6)
		H.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BACKPACK)
	for(var/amount_to_fill in 1 to 6)
		H.equip_to_slot_or_del(new /obj/item/tool/weldingtool, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)

	for(var/amount_to_fill in 1 to 6)
		H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)

	for(var/amount_to_fill in 1 to 5)
		H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_SUIT)

//---- Squad Engineer loadouts
/datum/outfit/quick/beginner_robot/engineer
	jobtype = "Squad Engineer"

/datum/outfit/quick/beginner_robot/engineer/builder
	name = "Engineer Standard"
	desc = "Born to build. Equipped with a metric ton of metal, you can be certain that a lack of barricades is not a possibility with you around."

	w_uniform = /obj/item/clothing/under/marine/robotic
	wear_suit = /obj/item/clothing/suit/modular/robot/heavy
	glasses = /obj/item/clothing/glasses/meson
	head = /obj/item/clothing/head/modular/robot

	l_store = /obj/item/storage/pouch/tools
	r_store = null

	back = /obj/item/storage/backpack/marine/radiopack
	belt = /obj/item/belt_harness/marine
	suit_store = /obj/item/weapon/gun/rifle/standard_lmg/beginner

/datum/outfit/quick/beginner_robot/engineer/builder/post_equip(mob/living/carbon/human/H, visualsOnly)
	H.equip_to_slot_or_del(new /obj/item/tool/screwdriver, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/tool/wirecutters, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/tool/wrench, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/tool/weldingtool/hugetank, SLOT_IN_L_POUCH)

/datum/outfit/quick/beginner_robot/engineer/burnitall
	name = "Flamethrower"
	desc = "For those who truly love to watch the world burn. Equipped with a laser carbine and a flamethrower, you can be certain that none of your enemies will be left un-burnt."

	w_uniform = /obj/item/clothing/under/marine/robotic
	wear_suit = /obj/item/clothing/suit/modular/robot/lightengineer
	glasses = /obj/item/clothing/glasses/meson
	head = /obj/item/clothing/head/modular/robot

	l_store = /obj/item/storage/pouch/tools
	r_store = null

	back = /obj/item/storage/holster/backholster/flamer
	belt = null
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine/beginner

/datum/outfit/quick/beginner_robot/engineer/burnitall/post_equip(mob/living/carbon/human/H, visualsOnly)
	H.equip_to_slot_or_del(new /obj/item/tool/screwdriver, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/tool/wirecutters, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/tool/wrench, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/tool/weldingtool/hugetank, SLOT_IN_L_POUCH)

/datum/outfit/quick/beginner_robot/engineer/pcenjoyer
	name = "Plasma Cutter"
	desc = "For the open-air enjoyers. Equipped with a plasma cutter, you will be able to cut down all types of walls and obstacles that dare exist within your vicinity."

	w_uniform = /obj/item/clothing/under/marine/robotic
	wear_suit = /obj/item/clothing/suit/modular/robot
	glasses = /obj/item/clothing/glasses/meson
	head = /obj/item/clothing/head/modular/robot

	l_store = /obj/item/storage/pouch/tools
	r_store = null

	back = /obj/item/storage/backpack/marine
	belt = /obj/item/belt_harness/marine
	suit_store = /obj/item/tool/pickaxe/plasmacutter

/datum/outfit/quick/beginner_robot/engineer/pcenjoyer/post_equip(mob/living/carbon/human/H, visualsOnly)
	H.equip_to_slot_or_del(new /obj/item/tool/screwdriver, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/tool/wirecutters, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/tool/wrench, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/tool/weldingtool/hugetank, SLOT_IN_L_POUCH)

//---- Squad Corpsman loadouts
/datum/outfit/quick/beginner_robot/corpsman
	jobtype = "Squad Corpsman"

//---- Squad Smartgunner loadouts
/datum/outfit/quick/beginner_robot/smartgunner
	jobtype = "Squad Smartgunner"
