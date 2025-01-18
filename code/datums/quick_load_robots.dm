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
	jobtype = SQUAD_MARINE

/datum/outfit/quick/beginner_robot/marine/rifleman
	name = "Rifleman"
	desc = "A typical rifleman for the marines. \
	Wields the AR-12, a versatile all-rounder assault rifle with a powerful underbarrel grenade launcher attached. \
	Also carries the strong P-23 sidearm and flares."

	w_uniform = /obj/item/clothing/under/marine/robotic/holster
	wear_suit = /obj/item/clothing/suit/modular/robot/hodgrenades
	head = /obj/item/clothing/head/modular/robot/hod

	l_store = /obj/item/storage/holster/flarepouch/full
	r_store = /obj/item/storage/pouch/magazine/large

	back = /obj/item/storage/backpack/marine
	belt = /obj/item/storage/belt/marine
	suit_store = /obj/item/weapon/gun/rifle/standard_assaultrifle/medic

/datum/outfit/quick/beginner_robot/marine/rifleman/post_equip(mob/living/carbon/human/robot_user, visualsOnly)
	for(var/amount_to_fill in 1 to 6)
		robot_user.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BACKPACK)
	for(var/amount_to_fill in 1 to 6)
		robot_user.equip_to_slot_or_del(new /obj/item/tool/weldingtool, SLOT_IN_BACKPACK)

	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)

	for(var/amount_to_fill in 1 to 6)
		robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)
	for(var/amount_to_fill in 1 to 3)
		robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_R_POUCH)

	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol/beginner(robot_user), SLOT_IN_ACCESSORY)

	for(var/amount_to_fill in 1 to 6)
		robot_user.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_SUIT)

/datum/outfit/quick/beginner_robot/marine/machinegunner
	name = "Machinegunner"
	desc = "The king of suppressive fire. Uses the MG-60, a fully automatic 200 round machine gun with a bipod attached. \
	Excels at denying large areas to the enemy and eliminating those who refuse to leave."

	w_uniform = /obj/item/clothing/under/marine/robotic/black_vest
	wear_suit = /obj/item/clothing/suit/modular/robot/heavy/tyr_onegeneral
	head = /obj/item/clothing/head/modular/robot/heavy/tyr

	l_store = /obj/item/storage/holster/flarepouch/full
	r_store = /obj/item/storage/pouch/tools

	back = /obj/item/storage/backpack/marine
	belt = /obj/item/storage/belt/sparepouch
	suit_store = /obj/item/weapon/gun/rifle/standard_gpmg/beginner

/datum/outfit/quick/beginner_robot/marine/machinegunner/post_equip(mob/living/carbon/human/robot_user, visualsOnly)
	for(var/amount_to_fill in 1 to 8)
		robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_gpmg , SLOT_IN_BACKPACK)

	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)

	for(var/amount_to_fill in 1 to 5)
		robot_user.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_ACCESSORY)

	for(var/amount_to_fill in 1 to 3)
		robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_gpmg , SLOT_IN_BELT)
	for(var/amount_to_fill in 1 to 2)
		robot_user.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_R_POUCH)
	for(var/amount_to_fill in 1 to 3)
		robot_user.equip_to_slot_or_del(new /obj/item/tool/weldingtool, SLOT_IN_R_POUCH)

	for(var/amount_to_fill in 1 to 2)
		robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_gpmg , SLOT_IN_SUIT)

/datum/outfit/quick/beginner_robot/marine/marksman
	name = "Marksman"
	desc = "Quality over quantity. Equipped with the DMR-37, an accurate long-range designated marksman rifle with a scope attached. \
	While subpar in close quarters, the precision of the DMR is unmatched, exceeding at taking out threats from afar."

	w_uniform = /obj/item/clothing/under/marine/robotic/holster
	wear_suit = /obj/item/clothing/suit/modular/robot/lightgeneral
	head = /obj/item/clothing/head/modular/robot

	l_store = /obj/item/storage/holster/flarepouch/full
	r_store = /obj/item/storage/pouch/magazine/large

	back = /obj/item/storage/backpack/marine
	belt = /obj/item/belt_harness/marine
	suit_store = /obj/item/weapon/gun/rifle/standard_dmr/beginner

/datum/outfit/quick/beginner_robot/marine/marksman/post_equip(mob/living/carbon/human/robot_user, visualsOnly)
	for(var/amount_to_fill in 1 to 6)
		robot_user.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BACKPACK)
	for(var/amount_to_fill in 1 to 6)
		robot_user.equip_to_slot_or_del(new /obj/item/tool/weldingtool, SLOT_IN_BACKPACK)

	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)

	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70/beginner(robot_user), SLOT_IN_ACCESSORY)

	for(var/amount_to_fill in 1 to 3)
		robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_dmr, SLOT_IN_R_POUCH)

	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_dmr, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_dmr, SLOT_IN_SUIT)

/datum/outfit/quick/beginner_robot/marine/shotgunner
	name = "Shotgunner"
	desc = "Up close and personal. Wields the SH-39, a semi-automatic shotgun loaded with slugs. \
	An absolute monster at short to mid range, the shotgun will do heavy damage to any target hit, as well as stunning them briefly, staggering them, and knocking them back."

	w_uniform = /obj/item/clothing/under/marine/robotic/holster
	wear_suit = /obj/item/clothing/suit/modular/robot/lightgeneral
	head = /obj/item/clothing/head/modular/robot

	l_store = /obj/item/storage/holster/flarepouch/full
	r_store = /obj/item/storage/pouch/shotgun

	back = /obj/item/storage/backpack/marine
	belt = /obj/item/storage/belt/shotgun
	suit_store = /obj/item/weapon/gun/shotgun/combat/standardmarine/beginner

/datum/outfit/quick/beginner_robot/marine/shotgunner/post_equip(mob/living/carbon/human/robot_user, visualsOnly)
	for(var/amount_to_fill in 1 to 6)
		robot_user.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BACKPACK)
	for(var/amount_to_fill in 1 to 6)
		robot_user.equip_to_slot_or_del(new /obj/item/tool/weldingtool, SLOT_IN_BACKPACK)

	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)

	for(var/amount_to_fill in 1 to 14)
		robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BELT)
	for(var/amount_to_fill in 1 to 4)
		robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_R_POUCH)

	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/plasma_pistol/beginner(robot_user), SLOT_IN_ACCESSORY)

	robot_user.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_SUIT)

/datum/outfit/quick/beginner_robot/marine/shocktrooper
	name = "Shocktrooper"
	desc = "The bleeding edge of the corps. \
	Equipped with the experimental battery-fed laser rifle, featuring four different modes that can be freely swapped between, with an underbarrel flamethrower for area denial and clearing mazes."

	w_uniform = /obj/item/clothing/under/marine/robotic/black_vest
	wear_suit = /obj/item/clothing/suit/modular/robot/lightgeneral
	head = /obj/item/clothing/head/modular/robot

	l_store = /obj/item/storage/holster/flarepouch/full
	r_store = /obj/item/cell/lasgun/volkite/powerpack/marine

	back = /obj/item/storage/backpack/marine
	belt = /obj/item/storage/belt/marine
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle/medic

/datum/outfit/quick/beginner_robot/marine/shocktrooper/post_equip(mob/living/carbon/human/robot_user, visualsOnly)
	for(var/amount_to_fill in 1 to 6)
		robot_user.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BACKPACK)
	for(var/amount_to_fill in 1 to 6)
		robot_user.equip_to_slot_or_del(new /obj/item/tool/weldingtool, SLOT_IN_BACKPACK)

	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)

	for(var/amount_to_fill in 1 to 6)
		robot_user.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)

	for(var/amount_to_fill in 1 to 5)
		robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)

	robot_user.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_SUIT)

//---- Squad Engineer loadouts
/datum/outfit/quick/beginner_robot/engineer
	jobtype = "Squad Engineer"

/datum/outfit/quick/beginner_robot/engineer/builder
	name = "Engineer Standard"
	desc = "Born to build. Equipped with a metric ton of metal, you can be certain that a lack of barricades is not a possibility with you around."

	w_uniform = /obj/item/clothing/under/marine/robotic/brown_vest
	wear_suit = /obj/item/clothing/suit/modular/robot/heavy/lightengineer
	glasses = /obj/item/clothing/glasses/meson
	head = /obj/item/clothing/head/modular/robot/heavy

	l_store = /obj/item/storage/pouch/tools
	r_store = /obj/item/storage/pouch/grenade

	back = /obj/item/storage/backpack/marine/radiopack
	belt = /obj/item/belt_harness/marine
	suit_store = /obj/item/weapon/gun/rifle/standard_lmg/beginner

/datum/outfit/quick/beginner_robot/engineer/builder/post_equip(mob/living/carbon/human/robot_user, visualsOnly)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/small_stack, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/sandbags_empty/full, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/shovel/etool, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_lmg, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_lmg, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_lmg, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_lmg, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_lmg, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)

	robot_user.equip_to_slot_or_del(new /obj/item/explosive/grenade/chem_grenade/razorburn_small, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/circuitboard/apc, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/handheld_charger/hicapcell, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_ACCESSORY)

	robot_user.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/medium_stack, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)

	robot_user.equip_to_slot_or_del(new /obj/item/tool/screwdriver, SLOT_IN_L_POUCH)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/wirecutters, SLOT_IN_L_POUCH)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/wrench, SLOT_IN_L_POUCH)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_L_POUCH)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/weldingtool/hugetank, SLOT_IN_L_POUCH)

	for(var/amount_to_fill in 1 to 6)
		robot_user.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)

/datum/outfit/quick/beginner_robot/engineer/burnitall
	name = "Flamethrower"
	desc = "For those who truly love to watch the world burn. Equipped with a laser carbine and a flamethrower, you can be certain that none of your enemies will be left un-burnt."

	w_uniform = /obj/item/clothing/under/marine/robotic/brown_vest
	wear_suit = /obj/item/clothing/suit/modular/robot/lightengineer
	glasses = /obj/item/clothing/glasses/meson
	head = /obj/item/clothing/head/modular/robot

	l_store = /obj/item/storage/pouch/tools
	r_store = /obj/item/storage/pouch/grenade

	back = /obj/item/storage/holster/backholster/flamer
	belt = /obj/item/storage/belt/marine
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine/beginner

/datum/outfit/quick/beginner_robot/engineer/burnitall/post_equip(mob/living/carbon/human/robot_user, visualsOnly)
	robot_user.equip_to_slot_or_del(new /obj/item/weapon/gun/flamer/big_flamer/marinestandard/engineer/beginner(robot_user), SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/storage/box/explosive_mines/large, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/shovel/etool, SLOT_IN_BACKPACK)

	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)

	robot_user.equip_to_slot_or_del(new /obj/item/explosive/grenade/chem_grenade/razorburn_small, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/circuitboard/apc, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/handheld_charger/hicapcell, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_ACCESSORY)

	robot_user.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/medium_stack, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/circuitboard/apc, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/multitool, SLOT_IN_SUIT)

	robot_user.equip_to_slot_or_del(new /obj/item/tool/screwdriver, SLOT_IN_L_POUCH)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/wirecutters, SLOT_IN_L_POUCH)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/wrench, SLOT_IN_L_POUCH)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_L_POUCH)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/weldingtool/hugetank, SLOT_IN_L_POUCH)

	for(var/amount_to_fill in 1 to 6)
		robot_user.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)

	for(var/amount_to_fill in 1 to 6)
		robot_user.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)

/datum/outfit/quick/beginner_robot/engineer/pcenjoyer
	name = "Plasma Cutter"
	desc = "For the open-air enjoyers. Equipped with a plasma cutter, you will be able to cut down all types of walls and obstacles that dare exist within your vicinity."

	w_uniform = /obj/item/clothing/under/marine/robotic/brown_vest
	wear_suit = /obj/item/clothing/suit/modular/robot/lightengineer
	glasses = /obj/item/clothing/glasses/meson
	head = /obj/item/clothing/head/modular/robot

	l_store = /obj/item/storage/pouch/tools
	r_store = /obj/item/storage/pouch/grenade

	back = /obj/item/storage/backpack/marine/satchel
	belt = /obj/item/belt_harness/marine
	suit_store = /obj/item/tool/pickaxe/plasmacutter

/datum/outfit/quick/beginner_robot/engineer/pcenjoyer/post_equip(mob/living/carbon/human/robot_user, visualsOnly)
	robot_user.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/standard_machinepistol/compact(robot_user), SLOT_IN_BACKPACK)
	for(var/amount_to_fill in 1 to 6)
		robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BACKPACK)

	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)

	robot_user.equip_to_slot_or_del(new /obj/item/explosive/grenade/chem_grenade/razorburn_small, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/circuitboard/apc, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/handheld_charger/hicapcell, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_ACCESSORY)

	robot_user.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/medium_stack, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/small_stack, SLOT_IN_SUIT)

	robot_user.equip_to_slot_or_del(new /obj/item/tool/screwdriver, SLOT_IN_L_POUCH)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/wirecutters, SLOT_IN_L_POUCH)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/wrench, SLOT_IN_L_POUCH)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_L_POUCH)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/weldingtool/hugetank, SLOT_IN_L_POUCH)

	for(var/amount_to_fill in 1 to 6)
		robot_user.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)

//---- Squad Corpsman loadouts
/datum/outfit/quick/beginner_robot/corpsman
	jobtype = "Squad Corpsman"

/datum/outfit/quick/beginner_robot/corpsman/lifesaver
	name = "Lifesaver"
	desc = "Miracle in progress. \
	Wields the bolt action Leicaster Repeater, and is equipped with a large variety of medicine for keeping the entire corps topped up and in the fight."

	w_uniform = /obj/item/clothing/under/marine/robotic/corpman_vest
	wear_suit = /obj/item/clothing/suit/modular/robot/lightinjector
	glasses = /obj/item/clothing/glasses/hud/health
	head = /obj/item/clothing/head/modular/robot

	l_store = /obj/item/storage/pouch/shotgun
	r_store = /obj/item/storage/pouch/medkit/medic

	back = /obj/item/storage/backpack/marine/corpsman
	belt = /obj/item/storage/belt/lifesaver/beginner
	suit_store = /obj/item/weapon/gun/shotgun/pump/lever/repeater/beginner

/datum/outfit/quick/beginner_robot/corpsman/lifesaver/post_equip(mob/living/carbon/human/robot_user, visualsOnly)
	robot_user.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p4570, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p4570, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p4570, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p4570, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/weldingtool, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/weldingtool, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)

	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)

	robot_user.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/bodybag/cryobag, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/oxycodone, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/nanoblood, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/roller/medevac, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/tweezers, SLOT_IN_ACCESSORY)

	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dexalinplus, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_SUIT)

	for(var/amount_to_fill in 1 to 4)
		robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/repeater, SLOT_IN_L_POUCH)

/datum/outfit/quick/beginner_robot/corpsman/hypobelt
	name = "Hypobelt"
	desc = "Putting the combat in combat medic. \
	Wields the pump action SH-35 shotgun, and is equipped with a belt full of hyposprays for rapidly treating patients in bad condition."

	w_uniform = /obj/item/clothing/under/marine/robotic/corpman_vest
	wear_suit = /obj/item/clothing/suit/modular/robot/light/lightmedical
	glasses = /obj/item/clothing/glasses/hud/health
	head = /obj/item/clothing/head/modular/robot/light

	l_store = /obj/item/storage/pouch/shotgun
	r_store = /obj/item/storage/pouch/medkit/medic

	back = /obj/item/storage/backpack/marine/corpsman
	belt = /obj/item/storage/belt/hypospraybelt/beginner
	suit_store = /obj/item/weapon/gun/shotgun/pump/t35/beginner

/datum/outfit/quick/beginner_robot/corpsman/hypobelt/post_equip(mob/living/carbon/human/robot_user, visualsOnly)
	robot_user.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/protein_pack, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/weldingtool, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/weldingtool, SLOT_IN_BACKPACK)

	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)

	for(var/amount_to_fill in 1 to 6)
		robot_user.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_ACCESSORY)

	robot_user.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/bodybag/cryobag, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/oxycodone, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/roller/medevac, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/tweezers, SLOT_IN_SUIT)

	for(var/amount_to_fill in 1 to 4)
		robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/slug, SLOT_IN_L_POUCH)

//---- Squad Smartgunner loadouts
/datum/outfit/quick/beginner_robot/smartgunner
	jobtype = "Squad Smartgunner"

/datum/outfit/quick/beginner_robot/smartgunner/sg29
	name = "Standard Smartmachinegun"
	desc = "Tactical support fire. \
	Uses the SG-29, a specialist light machine gun that will shoot through your allies, \
	equipped with a tactical sensor to detect enemies through smoke, walls, and darkness."

	w_uniform = /obj/item/clothing/under/marine/robotic/black_vest
	wear_suit = /obj/item/clothing/suit/modular/robot/lightgeneral
	glasses = /obj/item/clothing/glasses/night/m56_goggles
	head = /obj/item/clothing/head/modular/robot/antenna

	l_store = /obj/item/storage/holster/flarepouch/full
	r_store = /obj/item/storage/pouch/grenade

	back = /obj/item/storage/backpack/marine/satchel
	belt = /obj/item/belt_harness/marine
	suit_store = /obj/item/weapon/gun/rifle/standard_smartmachinegun/pmc

/datum/outfit/quick/beginner_robot/smartgunner/sg29/post_equip(mob/living/carbon/human/robot_user, visualsOnly)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/smart_pistol, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol, SLOT_IN_BACKPACK)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol, SLOT_IN_BACKPACK)

	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)

	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_SUIT)

	robot_user.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/weldingtool, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/weldingtool, SLOT_IN_ACCESSORY)

	for(var/amount_to_fill in 1 to 6)
		robot_user.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)

/datum/outfit/quick/beginner_robot/smartgunner/sg85
	name = "Standard Smartminigun"
	desc = "Lead wall! Wields the SG-85, a specialist minigun that holds one thousand rounds and can shoot through your allies, \
	equipped with a tactical sensor to detect enemies through smoke, walls, and darkness."

	w_uniform = /obj/item/clothing/under/marine/robotic/black_vest
	wear_suit = /obj/item/clothing/suit/modular/robot/lightgeneral
	glasses = /obj/item/clothing/glasses/night/m56_goggles
	head = /obj/item/clothing/head/modular/robot/antenna

	l_store = /obj/item/storage/holster/flarepouch/full
	r_store = /obj/item/storage/pouch/grenade

	back = /obj/item/ammo_magazine/minigun_powerpack/smartgun
	belt = /obj/item/belt_harness/marine
	suit_store = /obj/item/weapon/gun/minigun/smart_minigun/motion_detector

/datum/outfit/quick/beginner_robot/smartgunner/sg85/post_equip(mob/living/carbon/human/robot_user, visualsOnly)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)
	robot_user.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_HEAD)

	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/smart_minigun, SLOT_IN_SUIT)
	robot_user.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/smart_minigun, SLOT_IN_SUIT)

	robot_user.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/weldingtool, SLOT_IN_ACCESSORY)
	robot_user.equip_to_slot_or_del(new /obj/item/tool/weldingtool, SLOT_IN_ACCESSORY)

	for(var/amount_to_fill in 1 to 6)
		robot_user.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
