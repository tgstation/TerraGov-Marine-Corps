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

	l_pocket = null
	r_pocket = null

	back = /obj/item/storage/backpack/marine
	belt = null
	suit_store = null

//---- Squad Marine loadouts
/datum/outfit/quick/beginner_robot/marine
	jobtype = "Squad Marine"

/datum/outfit/quick/beginner_robot/marine/rifleman
	name = "Rifleman"
	desc = "A typical rifleman for the marines. \
	Wields the AR-12, a versatile all-rounder assault rifle with a powerful underbarrel grenade launcher attached. \
	Also carries the strong P-23 sidearm and flares."

	w_uniform = /obj/item/clothing/under/marine/robotic/holster
	wear_suit = /obj/item/clothing/suit/modular/robot/hodgrenades
	head = /obj/item/clothing/head/modular/robot/hod

	l_pocket = /obj/item/storage/holster/flarepouch/full
	r_pocket = /obj/item/storage/pouch/magazine/large

	back = /obj/item/storage/backpack/marine
	belt = /obj/item/storage/belt/marine
	suit_store = /obj/item/weapon/gun/rifle/standard_assaultrifle/medic

	backpack_contents = list(
		/obj/item/stack/cable_coil = 6,
		/obj/item/tool/weldingtool = 6,
	)

	suit_contents = list(
		/obj/item/explosive/grenade = 6,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = 2,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/standard_assaultrifle = 6,
	)

	webbing_contents = list(
		/obj/item/ammo_magazine/pistol/standard_heavypistol = 3,
		/obj/item/weapon/gun/pistol/standard_heavypistol/beginner = 1,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/standard_assaultrifle = 3,
	)


/datum/outfit/quick/beginner_robot/marine/machinegunner
	name = "Machinegunner"
	desc = "The king of suppressive fire. Uses the MG-60, a fully automatic 200 round machine gun with a bipod attached. \
	Excels at denying large areas to the enemy and eliminating those who refuse to leave."

	w_uniform = /obj/item/clothing/under/marine/robotic/black_vest
	wear_suit = /obj/item/clothing/suit/modular/robot/heavy/tyr_onegeneral
	head = /obj/item/clothing/head/modular/robot/heavy/tyr

	l_pocket = /obj/item/storage/holster/flarepouch/full
	r_pocket = /obj/item/storage/pouch/tools

	back = /obj/item/storage/backpack/marine
	belt = /obj/item/storage/belt/sparepouch
	suit_store = /obj/item/weapon/gun/rifle/standard_gpmg/beginner

	backpack_contents = list(
		/obj/item/ammo_magazine/standard_gpmg  = 8,
	)

	suit_contents = list(
		/obj/item/ammo_magazine/standard_gpmg  = 2,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = 2,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/standard_gpmg  = 3,
	)

	webbing_contents = list(
		/obj/item/storage/box/m94 = 5,
	)

	r_pocket_contents = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/tool/weldingtool = 3,
	)

/datum/outfit/quick/beginner_robot/marine/marksman
	name = "Marksman"
	desc = "Quality over quantity. Equipped with the DMR-37, an accurate long-range designated marksman rifle with a scope attached. \
	While subpar in close quarters, the precision of the DMR is unmatched, exceeding at taking out threats from afar."

	w_uniform = /obj/item/clothing/under/marine/robotic/holster
	wear_suit = /obj/item/clothing/suit/modular/robot/lightgeneral
	head = /obj/item/clothing/head/modular/robot

	l_pocket = /obj/item/storage/holster/flarepouch/full
	r_pocket = /obj/item/storage/pouch/magazine/large

	back = /obj/item/storage/backpack/marine
	belt = /obj/item/belt_harness/marine
	suit_store = /obj/item/weapon/gun/rifle/standard_dmr/beginner

	backpack_contents = list(
		/obj/item/stack/cable_coil = 6,
		/obj/item/tool/weldingtool = 6,
	)

	suit_contents = list(
		/obj/item/ammo_magazine/rifle/standard_dmr = 2,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = 2,
	)

	webbing_contents = list(
		/obj/item/ammo_magazine/pistol/vp70 = 3,
		/obj/item/weapon/gun/pistol/vp70/beginner = 1,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/standard_dmr = 3,
	)


/datum/outfit/quick/beginner_robot/marine/shotgunner
	name = "Shotgunner"
	desc = "Up close and personal. Wields the SH-39, a semi-automatic shotgun loaded with slugs. \
	An absolute monster at short to mid range, the shotgun will do heavy damage to any target hit, as well as stunning them briefly, staggering them, and knocking them back."

	w_uniform = /obj/item/clothing/under/marine/robotic/holster
	wear_suit = /obj/item/clothing/suit/modular/robot/lightgeneral
	head = /obj/item/clothing/head/modular/robot

	l_pocket = /obj/item/storage/holster/flarepouch/full
	r_pocket = /obj/item/storage/pouch/shotgun

	back = /obj/item/storage/backpack/marine
	belt = /obj/item/storage/belt/shotgun
	suit_store = /obj/item/weapon/gun/shotgun/combat/standardmarine/beginner

	backpack_contents = list(
		/obj/item/stack/cable_coil = 6,
		/obj/item/tool/weldingtool = 6,
	)

	suit_contents = list(
		/obj/item/storage/box/m94 = 2,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = 2,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/handful/slug = 14,
	)

	webbing_contents = list(
		/obj/item/ammo_magazine/pistol/plasma_pistol = 3,
		/obj/item/weapon/gun/pistol/plasma_pistol/beginner = 1,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/handful/slug = 4,
	)


/datum/outfit/quick/beginner_robot/marine/shocktrooper
	name = "Shocktrooper"
	desc = "The bleeding edge of the corps. \
	Equipped with the experimental battery-fed laser rifle, featuring four different modes that can be freely swapped between, with an underbarrel flamethrower for area denial and clearing mazes."

	w_uniform = /obj/item/clothing/under/marine/robotic/black_vest
	wear_suit = /obj/item/clothing/suit/modular/robot/lightgeneral
	head = /obj/item/clothing/head/modular/robot

	l_pocket = /obj/item/storage/holster/flarepouch/full
	r_pocket = /obj/item/cell/lasgun/volkite/powerpack/marine

	back = /obj/item/storage/backpack/marine
	belt = /obj/item/storage/belt/marine
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle/medic

	backpack_contents = list(
		/obj/item/stack/cable_coil = 6,
		/obj/item/tool/weldingtool = 6,
	)

	suit_contents = list(
		/obj/item/storage/box/m94 = 2,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = 2,
	)

	belt_contents = list(
		/obj/item/cell/lasgun/lasrifle = 6,
	)

	webbing_contents = list(
		/obj/item/ammo_magazine/flamer_tank/mini = 5,
	)


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

	l_pocket = /obj/item/storage/pouch/tools
	r_pocket = /obj/item/storage/pouch/grenade

	back = /obj/item/storage/backpack/marine/radiopack
	belt = /obj/item/belt_harness/marine
	suit_store = /obj/item/weapon/gun/rifle/standard_lmg/beginner

	backpack_contents = list(
		/obj/item/stack/sheet/metal/small_stack = 1,
		/obj/item/stack/sandbags_empty/full = 1,
		/obj/item/tool/shovel/etool = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/ammo_magazine/standard_lmg = 5,
		/obj/item/explosive/plastique = 1,
	)

	suit_contents = list(
		/obj/item/stack/sheet/metal/large_stack = 4,
		/obj/item/stack/sheet/plasteel/medium_stack = 1,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = 2,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/chem_grenade/razorburn_small = 1,
		/obj/item/circuitboard/apc = 1,
		/obj/item/tool/handheld_charger/hicapcell = 1,
		/obj/item/stack/cable_coil = 2,
	)

	l_pocket_contents = list(
		/obj/item/tool/screwdriver = 1,
		/obj/item/tool/wirecutters = 1,
		/obj/item/tool/wrench = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/tool/weldingtool/hugetank = 1,
	)

	r_pocket_contents = list(
		/obj/item/explosive/grenade = 6,
	)


/datum/outfit/quick/beginner_robot/engineer/burnitall
	name = "Flamethrower"
	desc = "For those who truly love to watch the world burn. Equipped with a laser carbine and a flamethrower, you can be certain that none of your enemies will be left un-burnt."

	w_uniform = /obj/item/clothing/under/marine/robotic/brown_vest
	wear_suit = /obj/item/clothing/suit/modular/robot/lightengineer
	glasses = /obj/item/clothing/glasses/meson
	head = /obj/item/clothing/head/modular/robot

	l_pocket = /obj/item/storage/pouch/tools
	r_pocket = /obj/item/storage/pouch/grenade

	back = /obj/item/storage/holster/backholster/flamer
	belt = /obj/item/storage/belt/marine
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine/beginner

	backpack_contents = list(
		/obj/item/weapon/gun/flamer/big_flamer/marinestandard/engineer/beginner = 1,
		/obj/item/storage/box/explosive_mines/large = 1,
		/obj/item/tool/extinguisher = 1,
		/obj/item/explosive/plastique = 2,
		/obj/item/tool/shovel/etool = 1,
	)

	suit_contents = list(
		/obj/item/circuitboard/apc = 1,
		/obj/item/stack/sheet/plasteel/medium_stack = 1,
		/obj/item/stack/sheet/metal/large_stack = 1,
		/obj/item/stack/sheet/metal/medium_stack = 1,
		/obj/item/tool/multitool = 1,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = 2,
	)

	belt_contents = list(
		/obj/item/cell/lasgun/lasrifle = 6,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/chem_grenade/razorburn_small = 1,
		/obj/item/circuitboard/apc = 1,
		/obj/item/tool/handheld_charger/hicapcell = 1,
		/obj/item/stack/cable_coil = 2,
	)

	l_pocket_contents = list(
		/obj/item/tool/screwdriver = 1,
		/obj/item/tool/wirecutters = 1,
		/obj/item/tool/wrench = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/tool/weldingtool/hugetank = 1,
	)

	r_pocket_contents = list(
		/obj/item/explosive/grenade = 6,
	)


/datum/outfit/quick/beginner_robot/engineer/pcenjoyer
	name = "Plasma Cutter"
	desc = "For the open-air enjoyers. Equipped with a plasma cutter, you will be able to cut down all types of walls and obstacles that dare exist within your vicinity."

	w_uniform = /obj/item/clothing/under/marine/robotic/brown_vest
	wear_suit = /obj/item/clothing/suit/modular/robot/lightengineer
	glasses = /obj/item/clothing/glasses/meson
	head = /obj/item/clothing/head/modular/robot

	l_pocket = /obj/item/storage/pouch/tools
	r_pocket = /obj/item/storage/pouch/grenade

	back = /obj/item/storage/backpack/marine/satchel
	belt = /obj/item/belt_harness/marine
	suit_store = /obj/item/tool/pickaxe/plasmacutter

	backpack_contents = list(
		/obj/item/weapon/gun/smg/standard_machinepistol/compact = 1,
		/obj/item/ammo_magazine/smg/standard_machinepistol = 6,
	)

	suit_contents = list(
		/obj/item/stack/sheet/plasteel/medium_stack = 1,
		/obj/item/stack/sheet/metal/large_stack = 3,
		/obj/item/stack/sheet/metal/small_stack = 1,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = 2,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/chem_grenade/razorburn_small = 1,
		/obj/item/circuitboard/apc = 1,
		/obj/item/tool/handheld_charger/hicapcell = 1,
		/obj/item/stack/cable_coil = 2,
	)

	l_pocket_contents = list(
		/obj/item/tool/screwdriver = 1,
		/obj/item/tool/wirecutters = 1,
		/obj/item/tool/wrench = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/tool/weldingtool/hugetank = 1,
	)

	r_pocket_contents = list(
		/obj/item/explosive/grenade = 6,
	)


//---- Squad Corpsman loadouts
/datum/outfit/quick/beginner_robot/corpsman
	jobtype = "Squad Corpsman"
	r_hand = /obj/item/medevac_beacon

/datum/outfit/quick/beginner_robot/corpsman/lifesaver
	name = "Lifesaver"
	desc = "Miracle in progress. \
	Wields the bolt action Leicaster Repeater, and is equipped with a large variety of medicine for keeping the entire corps topped up and in the fight."

	w_uniform = /obj/item/clothing/under/marine/robotic/corpman_vest
	wear_suit = /obj/item/clothing/suit/modular/robot/lightinjector
	glasses = /obj/item/clothing/glasses/hud/health
	head = /obj/item/clothing/head/modular/robot

	l_pocket = /obj/item/storage/pouch/shotgun
	r_pocket = /obj/item/storage/pouch/medkit/medic

	back = /obj/item/storage/backpack/marine/corpsman
	belt = /obj/item/storage/belt/lifesaver/beginner
	suit_store = /obj/item/weapon/gun/shotgun/pump/lever/repeater/beginner
	l_hand = /obj/item/paper/tutorial/lifesaver

	backpack_contents = list(
		/obj/item/storage/box/m94 = 2,
		/obj/item/ammo_magazine/packet/p4570 = 4,
		/obj/item/stack/cable_coil = 2,
		/obj/item/tool/weldingtool = 2,
		/obj/item/defibrillator = 1,
	)

	suit_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 3,
		/obj/item/reagent_containers/hypospray/autoinjector/dexalinplus = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = 3,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = 3,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = 2,
	)

	webbing_contents = list(
		/obj/item/roller = 1,
		/obj/item/bodybag/cryobag = 1,
		/obj/item/reagent_containers/hypospray/advanced/oxycodone = 1,
		/obj/item/reagent_containers/hypospray/advanced/nanoblood = 1,
		/obj/item/roller/medevac = 1,
		/obj/item/tweezers = 1,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/handful/repeater = 4,
	)


/datum/outfit/quick/beginner_robot/corpsman/hypobelt
	name = "Hypobelt"
	desc = "Putting the combat in combat medic. \
	Wields the pump action SH-35 shotgun, and is equipped with a belt full of hyposprays for rapidly treating patients in bad condition."

	w_uniform = /obj/item/clothing/under/marine/robotic/corpman_vest
	wear_suit = /obj/item/clothing/suit/modular/robot/light/lightmedical
	glasses = /obj/item/clothing/glasses/hud/health
	head = /obj/item/clothing/head/modular/robot/light

	l_pocket = /obj/item/storage/pouch/shotgun
	r_pocket = /obj/item/storage/pouch/medkit/medic

	back = /obj/item/storage/backpack/marine/corpsman
	belt = /obj/item/storage/belt/hypospraybelt/beginner
	suit_store = /obj/item/weapon/gun/shotgun/pump/t35/beginner
	l_hand = /obj/item/paper/tutorial/hypobelt

	backpack_contents = list(
		/obj/item/storage/box/m94 = 1,
		/obj/item/defibrillator = 1,
		/obj/item/reagent_containers/food/snacks/protein_pack = 1,
		/obj/item/ammo_magazine/handful/slug = 5,
		/obj/item/stack/cable_coil = 2,
		/obj/item/tool/weldingtool = 2,
	)

	suit_contents = list(
		/obj/item/roller = 1,
		/obj/item/bodybag/cryobag = 1,
		/obj/item/reagent_containers/hypospray/advanced/oxycodone = 1,
		/obj/item/roller/medevac = 1,
		/obj/item/tweezers = 1,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = 2,
	)

	webbing_contents = list(
		/obj/item/stack/medical/splint = 6,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/handful/slug = 4,
	)

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

	l_pocket = /obj/item/storage/holster/flarepouch/full
	r_pocket = /obj/item/storage/pouch/grenade

	back = /obj/item/storage/backpack/marine/satchel
	belt = /obj/item/belt_harness/marine
	suit_store = /obj/item/weapon/gun/rifle/standard_smartmachinegun/pmc

	backpack_contents = list(
		/obj/item/ammo_magazine/standard_smartmachinegun = 2,
		/obj/item/weapon/gun/pistol/smart_pistol = 1,
		/obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol = 2,
	)

	suit_contents = list(
		/obj/item/ammo_magazine/standard_smartmachinegun = 2,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = 2,
	)

	webbing_contents = list(
		/obj/item/storage/box/m94 = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/tool/weldingtool = 2,
	)

	r_pocket_contents = list(
		/obj/item/explosive/grenade = 6,
	)


/datum/outfit/quick/beginner_robot/smartgunner/sg85
	name = "Standard Smartminigun"
	desc = "Lead wall! Wields the SG-85, a specialist minigun that holds one thousand rounds and can shoot through your allies, \
	equipped with a tactical sensor to detect enemies through smoke, walls, and darkness."

	w_uniform = /obj/item/clothing/under/marine/robotic/black_vest
	wear_suit = /obj/item/clothing/suit/modular/robot/lightgeneral
	glasses = /obj/item/clothing/glasses/night/m56_goggles
	head = /obj/item/clothing/head/modular/robot/antenna

	l_pocket = /obj/item/storage/holster/flarepouch/full
	r_pocket = /obj/item/storage/pouch/grenade

	back = /obj/item/ammo_magazine/minigun_powerpack/smartgun
	belt = /obj/item/belt_harness/marine
	suit_store = /obj/item/weapon/gun/minigun/smart_minigun/motion_detector

	suit_contents = list(
		/obj/item/ammo_magazine/packet/smart_minigun = 2,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = 2,
	)

	webbing_contents = list(
		/obj/item/storage/box/m94 = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/tool/weldingtool = 2,
	)

	r_pocket_contents = list(
		/obj/item/explosive/grenade = 6,
	)
