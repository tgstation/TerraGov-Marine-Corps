/datum/outfit/quick
	///Description of the loadout
	var/desc = "Description here"
	///How much of this loadout there is. infinite by default
	var/quantity = -1
	///What job this loadout is associated with. Used for tabs and access.
	var/jobtype = "Squad Marine"
	///Restricts loadouts to a specific job. Set to false to allow any job to take the loadout.
	var/require_job = TRUE
	///Secondary weapon
	var/secondary_weapon

/datum/outfit/quick/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	//Start with uniform,suit,backpack for additional slots. Deletes any existing equipped item to avoid accidentally losing half your loadout. Not suitable for standard gamemodes!
	if(w_uniform)
		qdel(H.w_uniform)
	if(wear_suit)
		qdel(H.wear_suit)
	if(back)
		qdel(H.back)
	if(belt)
		qdel(H.belt)
	if(gloves)
		qdel(H.gloves)
	if(shoes)
		qdel(H.shoes)
	if(head)
		qdel(H.head)
	if(mask)
		qdel(H.wear_mask)
	if(ears)
		qdel(H.wear_ear)
	if(glasses)
		qdel(H.glasses)
	if(suit_store)
		qdel(H.s_store)
	if(l_hand)
		qdel(H.l_hand)

	if(r_hand)
		qdel(H.r_hand)

	return ..()

////TGMC/////

//Base TGMC outfit
/datum/outfit/quick/tgmc
	name = "TGMC base"
	desc = "This is the base typepath for all TGMC quick vendor outfits. You shouldn't see this."

//Base TGMC marine outfit
/datum/outfit/quick/tgmc/marine
	name = "TGMC Squad Marine"
	jobtype = "Squad Marine"

	ears = /obj/item/radio/headset/mainship/marine
	w_uniform = /obj/item/clothing/under/marine/black_vest
	shoes = /obj/item/clothing/shoes/marine/full
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/heavy/shield
	gloves = /obj/item/clothing/gloves/marine
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/m10x
	r_pocket = /obj/item/storage/pouch/firstaid/combat_patrol
	l_pocket = /obj/item/storage/pouch/grenade/combat_patrol
	back = /obj/item/storage/backpack/marine/satchel

	suit_contents = list(
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/isotonic = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
	)

/datum/outfit/quick/tgmc/marine/standard_assaultrifle
	name = "AR-12 rifleman"
	desc = "The classic line rifleman. Equipped with an AR-12 assault rifle with UGL, heavy armor, and plenty of grenades and ammunition. A solid all-rounder."

	suit_store = /obj/item/weapon/gun/rifle/standard_assaultrifle/rifleman
	belt = /obj/item/storage/belt/marine/t12

	backpack_contents = list(
		/obj/item/weapon/shield/riot/marine/deployable = 1,
		/obj/item/ammo_magazine/packet/p10x24mm = 1,
		/obj/item/ammo_magazine/pistol/standard_heavypistol = 2,
		/obj/item/weapon/gun/pistol/standard_heavypistol/tactical = 1,
		/obj/item/storage/box/MRE = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/sticky = 2,
		/obj/item/explosive/grenade = 2,
		/obj/item/explosive/grenade/incendiary = 1,
	)


/datum/outfit/quick/tgmc/marine/standard_laserrifle
	name = "Laser Rifleman"
	desc = "For when bullets don't cut the mustard. Laser rifle with miniflamer and heavy armor. Lasers are more effective against SOM armor, but cannot break bones and damage organs."

	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle/rifleman
	belt = /obj/item/storage/belt/marine/te_cells

	backpack_contents = list(
		/obj/item/cell/lasgun/lasrifle = 3,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol/tactical = 1,
		/obj/item/storage/box/MRE = 1,
	)

	webbing_contents = list(
		/obj/item/ammo_magazine/flamer_tank/mini = 2,
		/obj/item/explosive/grenade = 2,
		/obj/item/tool/extinguisher/mini = 1,
	)


/datum/outfit/quick/tgmc/marine/standard_carbine
	name = "AR-18 Rifleman"
	desc = "The modern line rifleman. Equipped with an AR-18 carbine with UGL, heavy armor, and plenty of grenades and ammunition. Boasts better mobility and damage output than the AR-12, but suffers with a smaller magazine and worse performance at longer ranges."

	suit_store = /obj/item/weapon/gun/rifle/standard_carbine/standard
	belt = /obj/item/storage/belt/marine/t18

	backpack_contents = list(
		/obj/item/ammo_magazine/packet/p10x24mm = 1,
		/obj/item/ammo_magazine/pistol/standard_heavypistol = 2,
		/obj/item/ammo_magazine/rifle/standard_carbine = 1,
		/obj/item/weapon/gun/pistol/standard_heavypistol/tactical = 1,
		/obj/item/storage/box/MRE = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/sticky = 2,
		/obj/item/explosive/grenade = 2,
		/obj/item/explosive/grenade/incendiary = 1,
	)


/datum/outfit/quick/tgmc/marine/combat_rifle
	name = "AR-11 Rifleman"
	desc = "The old rifleman. Equipped with an AR-11 combat rifle with heavy armor, and plenty of grenades and ammunition. Has a large capacity with deadly damage output at all ranges, but lacks many attachment options of more modern weapons and somewhat more cumbersome to handle."

	suit_store = /obj/item/weapon/gun/rifle/tx11/standard
	belt = /obj/item/storage/belt/marine/combat_rifle

	backpack_contents = list(
		/obj/item/ammo_magazine/packet/p492x34mm = 2,
		/obj/item/ammo_magazine/pistol/standard_heavypistol = 2,
		/obj/item/weapon/gun/pistol/standard_heavypistol/tactical = 1,
		/obj/item/storage/box/MRE = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade = 3,
		/obj/item/explosive/grenade/incendiary = 1,
		/obj/item/tool/extinguisher/mini = 1,
	)


/datum/outfit/quick/tgmc/marine/standard_battlerifle
	name = "BR-64 Rifleman"
	desc = "Heavier firepower for the discerning rifleman. Equipped with an BR-64 battle rifle with UGL, heavy armor, and plenty of grenades and ammunition. Higher damage and penetration, at the cost of a more bulky weapon."

	suit_store = /obj/item/weapon/gun/rifle/standard_br/standard
	belt = /obj/item/storage/belt/marine/standard_battlerifle

	backpack_contents = list(
		/obj/item/weapon/shield/riot/marine/deployable = 1,
		/obj/item/ammo_magazine/packet/p10x265mm = 1,
		/obj/item/ammo_magazine/pistol/standard_heavypistol = 2,
		/obj/item/weapon/gun/pistol/standard_heavypistol/tactical = 1,
		/obj/item/storage/box/MRE = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/sticky = 2,
		/obj/item/explosive/grenade = 2,
		/obj/item/explosive/grenade/incendiary = 1,
	)


/datum/outfit/quick/tgmc/marine/standard_skirmishrifle
	name = "AR-21 Rifleman"
	desc = "Better stopping power at the cost of lower rate of fire. Equipped with an AR-21 skirmish rifle with UGL, heavy armor, and plenty of grenades and ammunition. Rewards good aim with its heavy rounds."

	suit_store = /obj/item/weapon/gun/rifle/standard_skirmishrifle/standard
	belt = /obj/item/storage/belt/marine/standard_skirmishrifle

	backpack_contents = list(
		/obj/item/weapon/shield/riot/marine/deployable = 1,
		/obj/item/ammo_magazine/packet/p10x25mm = 1,
		/obj/item/ammo_magazine/pistol/standard_heavypistol = 2,
		/obj/item/weapon/gun/pistol/standard_heavypistol/tactical = 1,
		/obj/item/storage/box/MRE = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/sticky = 2,
		/obj/item/explosive/grenade = 2,
		/obj/item/explosive/grenade/incendiary = 1,
	)


/datum/outfit/quick/tgmc/marine/alf_shocktrooper
	name = "ALF-51B Shocktrooper"
	desc = "Shock assault loadout. Equipped with an ALF-51B machinecarbine, heavy armor reinforced with a Mk.II 'Tyr' module, and plenty of grenades and ammunition. Offers excellent damage output and superior protection, however the ALF-51B's cutdown size means it suffers from severe damage falloff. Best used up close."

	head = /obj/item/clothing/head/modular/m10x/tyr
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/heavy/tyr_two
	suit_store = /obj/item/weapon/gun/rifle/alf_machinecarbine/assault
	belt = /obj/item/storage/belt/marine/alf_machinecarbine

	backpack_contents = list(
		/obj/item/ammo_magazine/rifle/alf_machinecarbine = 2,
		/obj/item/weapon/gun/pistol/standard_heavypistol/tactical = 1,
		/obj/item/storage/box/MRE = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
		/obj/item/explosive/plastique = 1,
		/obj/item/tool/extinguisher/mini = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade = 2,
		/obj/item/explosive/grenade/flashbang/stun = 1,
		/obj/item/ammo_magazine/pistol/standard_heavypistol = 2,
	)


/datum/outfit/quick/tgmc/marine/standard_machinegunner
	name = "MG-60 Machinegunner"
	desc = "The old reliable workhorse of the TGMC. Equipped with an MG-60 machinegun with bipod, heavy armor and some basic construction supplies. Good for holding ground and providing firesupport, and the cost of some mobility."

	belt = /obj/item/storage/belt/sparepouch
	suit_store = /obj/item/weapon/gun/rifle/standard_gpmg/machinegunner
	l_pocket = /obj/item/storage/pouch/construction

	backpack_contents = list(
		/obj/item/weapon/shield/riot/marine/deployable = 1,
		/obj/item/ammo_magazine/standard_gpmg = 1,
		/obj/item/weapon/gun/pistol/standard_heavypistol/tactical = 1,
		/obj/item/ammo_magazine/pistol/standard_heavypistol = 3,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/standard_gpmg = 3,
	)

	webbing_contents = list(
		/obj/item/storage/box/MRE = 1,
		/obj/item/explosive/grenade/smokebomb = 2,
		/obj/item/explosive/grenade/incendiary = 1,
		/obj/item/explosive/grenade/flashbang/stun = 1,
	)

	l_pocket_contents = list(
		/obj/item/tool/shovel/etool = 1,
		/obj/item/stack/sandbags_empty/half = 1,
		/obj/item/stack/sandbags/large_stack = 1,
		/obj/item/stack/barbed_wire/half_stack = 1,
	)


/datum/outfit/quick/tgmc/marine/medium_machinegunner
	name = "MG-27 Machinegunner"
	desc = "For when you need the biggest gun you can carry. Equipped with an MG-27 machinegun and miniscope and a MR-25 SMG as a side arm, as well as medium armor and a small amount of construction supplies. Allows for devestating, albeit static firepower."

	belt = /obj/item/storage/holster/m25
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/shield
	suit_store = /obj/item/weapon/gun/standard_mmg/machinegunner
	l_pocket = /obj/item/storage/pouch/construction
	glasses = /obj/item/clothing/glasses/mgoggles

	backpack_contents = list(
		/obj/item/ammo_magazine/standard_mmg = 3,
		/obj/item/explosive/grenade/smokebomb = 2,
		/obj/item/explosive/grenade/flashbang/stun = 1,
	)

	webbing_contents = list(
		/obj/item/storage/box/MRE = 1,
		/obj/item/ammo_magazine/smg/m25 = 4,
	)

	l_pocket_contents = list(
		/obj/item/tool/shovel/etool = 1,
		/obj/item/stack/sandbags_empty/half = 1,
		/obj/item/stack/sandbags/large_stack = 1,
		/obj/item/stack/barbed_wire/half_stack = 1,
	)

	belt_contents = list(
		/obj/item/weapon/gun/smg/m25/holstered = 1,
	)


/datum/outfit/quick/tgmc/marine/standard_lasermg
	name = "Laser Machinegunner"
	desc = "Mess free fire superiority. Laser machinegun with underbarrel grenade launcher and heavy armor. Comparatively light for a machinegun, with variable firemodes makes this weapon a flexible and dangerous weapon. Lasers are more effective against SOM armor, but cannot break bones and damage organs."

	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_mlaser/patrol
	belt = /obj/item/storage/belt/marine/te_cells

	backpack_contents = list(
		/obj/item/cell/lasgun/lasrifle = 3,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol/tactical = 1,
		/obj/item/storage/box/MRE = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/incendiary = 1,
		/obj/item/explosive/grenade = 3,
		/obj/item/tool/extinguisher/mini = 1,
	)

/datum/outfit/quick/tgmc/marine/pyro
	name = "FL-84 Flamethrower Operator"
	desc = "For burning enemies, and sometimes friends. Equipped with an FL-84 flamethrower and wide nozzle, SMG-25 secondary weapon, heavy armor upgraded with a 'Surt' fireproof module, and a backtank of fuel. Can burn down large areas extremely quickly both to flush out the enemy and to cover flanks. Is very slow however, ineffective at long range, and can expend all available fuel quickly if used excessively."

	wear_suit = /obj/item/clothing/suit/modular/xenonauten/heavy/surt
	mask = /obj/item/clothing/mask/gas/tactical
	head = /obj/item/clothing/head/modular/m10x/surt
	belt = /obj/item/storage/holster/m25
	back = /obj/item/ammo_magazine/flamer_tank/backtank
	suit_store = /obj/item/weapon/gun/flamer/big_flamer/marinestandard/wide

	webbing_contents = list(
		/obj/item/storage/box/MRE = 1,
		/obj/item/ammo_magazine/smg/m25/extended = 3,
		/obj/item/ammo_magazine/packet/p10x20mm = 1,
	)

	belt_contents = list(
		/obj/item/weapon/gun/smg/m25 = 1,
	)


/datum/outfit/quick/tgmc/marine/standard_shotgun
	name = "SH-35 Scout"
	desc = "For getting too close for comfort. Equipped with a SH-35 shotgun with buckshot and flechette rounds, a MP-19 sidearm, a good amount of grenades and light armor with a cutting edge 'svallin' shield module. Provides for excellent mobility and devestating close range firepower, but will falter against sustained firepower."

	wear_suit = /obj/item/clothing/suit/modular/xenonauten/light/shield
	suit_store = /obj/item/weapon/gun/shotgun/pump/t35/standard
	belt = /obj/item/storage/belt/shotgun/mixed

	backpack_contents = list(
		/obj/item/ammo_magazine/smg/standard_machinepistol = 3,
		/obj/item/ammo_magazine/packet/p10x20mm = 1,
		/obj/item/explosive/plastique = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/synaptizine = 1,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/weapon/gun/smg/standard_machinepistol/compact = 1,
	)

	webbing_contents = list(
		/obj/item/storage/box/MRE = 1,
		/obj/item/binoculars = 1,
		/obj/item/explosive/grenade/incendiary = 1,
		/obj/item/explosive/grenade = 2,
	)


/datum/outfit/quick/tgmc/marine/standard_lasercarbine
	name = "Laser Carbine Scout"
	desc = "Highly mobile light infantry. Equipped with a laser carbine with UGL and a laser pistol sidearm, plenty of grenades and light armor with a cutting edge 'svallin' shield module. Excellent mobility, but not suited for sustained combat."

	wear_suit = /obj/item/clothing/suit/modular/xenonauten/light/shield
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine/scout
	belt = /obj/item/storage/belt/marine/te_cells

	backpack_contents = list(
		/obj/item/cell/lasgun/lasrifle = 3,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol/tactical = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/synaptizine = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
		/obj/item/explosive/plastique = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/sticky = 3,
		/obj/item/storage/box/MRE = 1,
		/obj/item/binoculars = 1,
	)


/datum/outfit/quick/tgmc/marine/light_carbine
	name = "AR-18 Scout"
	desc = "High damage and high speed. Equipped with an AR-18 carbine with UGL, light armor with a cutting edge 'svallin' shield module, and plenty of grenades and ammunition. Great mobility and damage output, but low magazine capacity and weak armor without the shield active means this loadout is best suited to hit and run tactics."

	wear_suit = /obj/item/clothing/suit/modular/xenonauten/light/shield
	suit_store = /obj/item/weapon/gun/rifle/standard_carbine/scout
	belt = /obj/item/storage/belt/marine/t18

	backpack_contents = list(
		/obj/item/ammo_magazine/packet/p10x24mm = 2,
		/obj/item/ammo_magazine/rifle/standard_carbine = 1,
		/obj/item/weapon/gun/pistol/standard_heavypistol/tactical = 1,
		/obj/item/storage/box/MRE = 1,
		/obj/item/explosive/plastique = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/sticky = 3,
		/obj/item/ammo_magazine/pistol/standard_heavypistol = 2,
	)


/datum/outfit/quick/tgmc/marine/shield_tank
	name = "SMG-25 Guardian"
	desc = "Professional bullet catcher. Equipped with an SMG-25 submachine gun, a TL-172 defensive shield and heavy armor reinforced with a 'Tyr' module. Designed to absorb as much incoming damage as possible to protect your squishier comrades, however your mobility and damage output are notably diminished. Also of note: the excellent thermal mass of the TL-172 means it is unusually effective against the SOM's volkite weaponry."

	head = /obj/item/clothing/head/modular/m10x/tyr
	glasses = /obj/item/clothing/glasses/welding
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/heavy/tyr_two
	suit_store = /obj/item/weapon/gun/smg/m25/magharness
	belt = /obj/item/storage/belt/marine/secondary
	r_hand = /obj/item/weapon/shield/riot/marine

	backpack_contents = list(
		/obj/item/tool/extinguisher = 1,
		/obj/item/tool/weldingtool/largetank = 1,
		/obj/item/ammo_magazine/smg/m25/extended = 1,
		/obj/item/ammo_magazine/packet/p10x20mm = 2,
		/obj/item/explosive/grenade/smokebomb/cloak = 1,
		/obj/item/storage/box/MRE = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/sticky = 2,
		/obj/item/explosive/grenade/incendiary = 1,
		/obj/item/explosive/grenade = 2,
	)


/datum/outfit/quick/tgmc/marine/machete
	name = "Assault Marine"
	desc = "This doesn't look standard issue... Equipped with a SMG-25 submachine gun, machete and heavy lift jetpack, along with light armor upgraded with a 'svallin' shield module. It's not clear why this is here, nevertheless it has excellent mobility, and would likely be devastating against anyone you manage to actually reach."

	wear_suit = /obj/item/clothing/suit/modular/xenonauten/light/shield
	back = /obj/item/jetpack_marine/heavy
	belt = /obj/item/storage/holster/blade/machete/full
	suit_store = /obj/item/weapon/gun/smg/m25/magharness

	webbing_contents = list(
		/obj/item/ammo_magazine/smg/m25/extended = 2,
		/obj/item/ammo_magazine/smg/m25 = 3,
	)


/datum/outfit/quick/tgmc/marine/scout
	name = "BR-8 Scout"
	desc = "IFF scout. Equipped with a BR-8 with a good amount of grenades and light armor with a cutting edge 'svallin' shield module. Provides for good mobility and powerful IFF damage, but the BR-8 is difficult to bring to bear at close range, and light armor wilts under sustained fire."
	quantity = 2

	wear_suit = /obj/item/clothing/suit/modular/xenonauten/light/shield
	suit_store = /obj/item/weapon/gun/rifle/tx8/scout
	belt = /obj/item/storage/belt/marine/tx8

	backpack_contents = list(
		/obj/item/ammo_magazine/smg/standard_machinepistol = 3,
		/obj/item/weapon/gun/smg/standard_machinepistol/scanner = 1,
		/obj/item/ammo_magazine/rifle/tx8 = 2,
	)

	webbing_contents = list(
		/obj/item/storage/box/MRE = 1,
		/obj/item/binoculars = 1,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/explosive/grenade/m15 = 2,
	)


//Base TGMC engineer outfit
/datum/outfit/quick/tgmc/engineer
	name = "TGMC Squad Engineer"
	jobtype = "Squad Engineer"

	ears = /obj/item/radio/headset/mainship/marine
	glasses = /obj/item/clothing/glasses/meson
	w_uniform = /obj/item/clothing/under/marine/engineer/black_vest
	shoes = /obj/item/clothing/shoes/marine/full
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/engineer
	gloves = /obj/item/clothing/gloves/marine/insulated
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/m10x/welding
	r_pocket = /obj/item/storage/pouch/firstaid/combat_patrol
	l_pocket = /obj/item/storage/pouch/tools/full
	back = /obj/item/storage/backpack/marine/engineerpack

	suit_contents = list(
		/obj/item/circuitboard/apc = 1,
		/obj/item/cell/high = 1,
		/obj/item/stack/sheet/plasteel/medium_stack = 1,
		/obj/item/stack/sheet/metal/large_stack = 1,
		/obj/item/stack/barbed_wire/half_stack = 1,
	)

	head_contents = list(
		/obj/item/explosive/plastique = 2,
	)

/datum/outfit/quick/tgmc/engineer/rrengineer
	name = "Rocket Specialist"
	desc = "Bringing the big guns. Equipped with a AR-18 carbine and RL-160 along with the standard engineer kit. Excellent against groups of enemy infantry or light armor, but only has limited ammunition."
	quantity = 2

	suit_store = /obj/item/weapon/gun/rifle/standard_carbine/engineer
	back = /obj/item/storage/holster/backholster/rpg/low_impact
	belt = /obj/item/storage/belt/marine/t18

	webbing_contents = list(
		/obj/item/storage/box/MRE = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/explosive/grenade/chem_grenade/razorburn_large = 1,
		/obj/item/explosive/grenade/smokebomb = 1,
	)


/datum/outfit/quick/tgmc/engineer/sentry
	name = "Sentry Technician"
	desc = "Firing more guns than you have hands. Equipped with a AR-12 assault rifle with miniflamer, and two minisentries along with the standard engineer kit. Allows the user to quickly setup strong points and lock areas down, with some sensible placement."

	suit_store = /obj/item/weapon/gun/rifle/standard_assaultrifle/engineer
	belt = /obj/item/storage/belt/marine/t12

	backpack_contents = list(
		/obj/item/weapon/gun/sentry/mini/combat_patrol = 2,
		/obj/item/ammo_magazine/minisentry = 2,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
	)

	webbing_contents = list(
		/obj/item/storage/box/MRE = 1,
		/obj/item/ammo_magazine/flamer_tank/mini = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/explosive/grenade/chem_grenade/razorburn_large = 1,
		/obj/item/explosive/grenade/smokebomb = 1,
	)

/datum/outfit/quick/tgmc/engineer/demolition
	name = "Demolition Specialist"
	desc = "Boom boom, shake the room. Equipped with a SH-15 auto shotgun and UGL and an impressive array of mines, detpacks and grenades, along with the standard engineer kit. Excellent for blasting through any obstacle, and mining areas to restrict enemy movement."

	suit_store = /obj/item/weapon/gun/rifle/standard_autoshotgun/engineer
	back = /obj/item/storage/backpack/marine/tech
	belt = /obj/item/storage/belt/marine/auto_shotgun

	backpack_contents = list(
		/obj/item/minelayer = 1,
		/obj/item/storage/box/explosive_mines/large = 1,
		/obj/item/storage/box/explosive_mines = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/detpack = 3,
		/obj/item/explosive/plastique = 2,
		/obj/item/storage/box/MRE = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
		/obj/item/explosive/grenade/smokebomb = 1,
	)

	webbing_contents = list(
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/assembly/signaler = 1,
		/obj/item/explosive/grenade/sticky = 3,
	)


//Base TGMC corpsman outfit
/datum/outfit/quick/tgmc/corpsman
	name = "TGMC Squad Corpsman"
	jobtype = "Squad Corpsman"

	belt = /obj/item/storage/belt/lifesaver/quick
	ears = /obj/item/radio/headset/mainship/marine
	glasses = /obj/item/clothing/glasses/hud/health
	w_uniform = /obj/item/clothing/under/marine/corpsman/corpman_vest
	shoes = /obj/item/clothing/shoes/marine/full
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/mimir
	gloves = /obj/item/clothing/gloves/marine
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/m10x/mimir
	r_pocket = /obj/item/storage/pouch/magazine/large
	l_pocket = /obj/item/storage/pouch/grenade/combat_patrol
	back = /obj/item/storage/backpack/marine/corpsman

	suit_contents = list(
		/obj/item/tool/extinguisher = 1,
		/obj/item/defibrillator = 1,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/isotonic = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/neuraline = 1,
	)

	webbing_contents = list(
		/obj/item/bodybag/cryobag = 1,
		/obj/item/roller = 1,
		/obj/item/tweezers_advanced = 1,
		/obj/item/reagent_containers/hypospray/advanced/nanoblood = 1,
		/obj/item/storage/pill_bottle/spaceacillin = 1,
		/obj/item/reagent_containers/hypospray/advanced/combat_advanced = 1,
	)


/datum/outfit/quick/tgmc/corpsman/standard_medic
	name = "AR-12 Corpsman"
	desc = "Keeping everone else in the fight. Armed with an AR-12 assault rifle with underbarrel grenade launcher, an impressive array of tools for healing your team, and a 'Mimir' biological protection module to allow you to continue operating in hazardous environments. With medivacs out of the question, you are the only thing standing between your buddies and an early grave."

	suit_store = /obj/item/weapon/gun/rifle/standard_assaultrifle/medic

	backpack_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = 2,
		/obj/item/explosive/grenade = 1,
		/obj/item/explosive/grenade/sticky = 2,
		/obj/item/explosive/grenade/incendiary = 1,
		/obj/item/ammo_magazine/packet/p10x24mm = 1,
		/obj/item/ammo_magazine/rifle/standard_assaultrifle = 3,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/standard_assaultrifle = 3,
	)


/datum/outfit/quick/tgmc/corpsman/standard_smg
	name = "SMG-90 Corpsman"
	desc = "Keeping everone else in the fight. Armed with an SMG-90 submachine gun to maintain good mobility, an impressive array of tools for healing your team, and a 'Mimir' biological protection module to allow you to continue operating in hazardous environments. With medivacs out of the question, you are the only thing standing between your buddies and an early grave."

	suit_store = /obj/item/weapon/gun/smg/standard_smg/tactical

	backpack_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = 2,
		/obj/item/ammo_magazine/smg/standard_smg = 5,
		/obj/item/explosive/grenade = 2,
		/obj/item/explosive/grenade/incendiary = 2,
		/obj/item/ammo_magazine/packet/p10x20mm = 1,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/smg/standard_smg = 3,
	)


/datum/outfit/quick/tgmc/corpsman/standard_skirmishrifle
	name = "AR-21 Corpsman"
	desc = "Keeping everone else in the fight. Armed with an AR-21 skirmish rifle with underbarrel grenade launcher, an impressive array of tools for healing your team, and a 'Mimir' biological protection module to allow you to continue operating in hazardous environments. With medivacs out of the question, you are the only thing standing between your buddies and an early grave."

	suit_store = /obj/item/weapon/gun/rifle/standard_skirmishrifle/standard

	backpack_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = 2,
		/obj/item/explosive/grenade = 2,
		/obj/item/explosive/grenade/sticky = 2,
		/obj/item/ammo_magazine/packet/p10x25mm = 1,
		/obj/item/ammo_magazine/rifle/standard_skirmishrifle = 3,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/standard_skirmishrifle = 3,
	)


/datum/outfit/quick/tgmc/corpsman/auto_shotgun
	name = "SH-15 Corpsman"
	desc = "Keeping everone else in the fight. Armed with a SH-15 auto shotgun with underbarrel grenade launcher, an impressive array of tools for healing your team, and a 'Mimir' biological protection module to allow you to continue operating in hazardous environments. With medivacs out of the question, you are the only thing standing between your buddies and an early grave."

	suit_store = /obj/item/weapon/gun/rifle/standard_autoshotgun/engineer

	backpack_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = 2,
		/obj/item/explosive/grenade = 2,
		/obj/item/explosive/grenade/sticky = 2,
		/obj/item/explosive/grenade/incendiary = 1,
		/obj/item/ammo_magazine/rifle/tx15_slug = 2,
		/obj/item/ammo_magazine/rifle/tx15_flechette = 1,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/tx15_slug = 1,
		/obj/item/ammo_magazine/rifle/tx15_flechette = 2,
	)


/datum/outfit/quick/tgmc/corpsman/laser_medic
	name = "Laser Rifle Corpsman"
	desc = "Keeping everone else in the fight. Armed with an laser rifle with miniflamer, an impressive array of tools for healing your team, and a 'Mimir' biological protection module to allow you to continue operating in hazardous environments. With medivacs out of the question, you are the only thing standing between your buddies and an early grave."

	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle/medic

	backpack_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = 2,
		/obj/item/ammo_magazine/flamer_tank/mini = 2,
		/obj/item/cell/lasgun/lasrifle = 5,
	)

	r_pocket_contents = list(
		/obj/item/cell/lasgun/lasrifle = 3,
	)


/datum/outfit/quick/tgmc/corpsman/laser_carbine
	name = "Laser Carbine Corpsman"
	desc = "Keeping everone else in the fight. Armed with an laser carbine with underbarrel grenade launcher, an impressive array of tools for healing your team, and a 'Mimir' biological protection module to allow you to continue operating in hazardous environments. With medivacs out of the question, you are the only thing standing between your buddies and an early grave."

	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine/scout

	backpack_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = 2,
		/obj/item/explosive/grenade/sticky = 2,
		/obj/item/explosive/grenade = 2,
		/obj/item/cell/lasgun/lasrifle = 4,
	)

	r_pocket_contents = list(
		/obj/item/cell/lasgun/lasrifle = 3,
	)


//Base TGMC smartgunner outfit
/datum/outfit/quick/tgmc/smartgunner
	name = "TGMC Squad Smartgunner"
	jobtype = "Squad Smartgunner"

	belt = /obj/item/belt_harness/marine
	ears = /obj/item/radio/headset/mainship/marine
	glasses = /obj/item/clothing/glasses/night/m56_goggles
	w_uniform = /obj/item/clothing/under/marine/black_vest
	shoes = /obj/item/clothing/shoes/marine/full
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/heavy/tyr_two
	gloves = /obj/item/clothing/gloves/marine
	mask = /obj/item/clothing/mask/gas/tactical
	head = /obj/item/clothing/head/modular/m10x/tyr
	r_pocket = /obj/item/storage/pouch/firstaid/combat_patrol
	l_pocket = /obj/item/storage/pouch/grenade/combat_patrol
	back = /obj/item/storage/backpack/marine/satchel

	suit_contents = list(
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/isotonic = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
	)


/datum/outfit/quick/tgmc/smartgunner/standard_sg
	name = "SG29 Smart Machinegunner"
	desc = "A gun smarter than the average bear, or marine. Equipped with an SG-29 smart machine gun and heavy armor upgraded with a 'Tyr' extra armor mdule, the SG is responsible for providing mobile, accurate firesupport thanks to your IFF ammunition."

	suit_store = /obj/item/weapon/gun/rifle/standard_smartmachinegun/patrol

	backpack_contents = list(
		/obj/item/ammo_magazine/standard_smartmachinegun = 4,
		/obj/item/weapon/gun/pistol/vp70/tactical = 1,
	)

	webbing_contents = list(
		/obj/item/storage/box/MRE = 1,
		/obj/item/ammo_magazine/pistol/vp70 = 4,
	)


/datum/outfit/quick/tgmc/smartgunner/minigun_sg
	name = "SG85 Smart Machinegunner"
	desc = "More bullets than sense. Equipped with an SG-85 smart gatling gun, an MP-19 sidearm, heavy armor upgraded with a 'Tyr' extra armor mdule and a whole lot of bullets. For when you want to unleash a firehose of firepower. Try not to run out of ammo."

	belt = /obj/item/storage/belt/sparepouch
	suit_store = /obj/item/weapon/gun/minigun/smart_minigun/motion_detector
	back = /obj/item/ammo_magazine/minigun_powerpack/smartgun

	belt_contents = list(
		/obj/item/ammo_magazine/packet/smart_minigun = 2,
		/obj/item/weapon/gun/smg/standard_machinepistol/compact = 1,
	)

	webbing_contents = list(
		/obj/item/storage/box/MRE = 1,
		/obj/item/ammo_magazine/smg/standard_machinepistol = 4,
	)

/datum/outfit/quick/tgmc/smartgunner/target_rifle
	name = "SG62 Smart Machinegunner"
	desc = "Flexibility and precision. Equipped with an SG-62 smart target rifle and heavy armor upgraded with a 'Tyr' extra armor mdule. The integrated spotting rifle comes with a variety of flexible ammo types, which combined with high damage, penetration and IFF, makes for a dangerous support loadout."

	belt = /obj/item/storage/belt/marine/target_rifle
	suit_store = /obj/item/weapon/gun/rifle/standard_smarttargetrifle/motion

	backpack_contents = list(
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/incendiary = 2,
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/tungsten = 2,
		/obj/item/ammo_magazine/pistol/vp70 = 3,
		/obj/item/weapon/gun/pistol/vp70/tactical = 1,
	)

	webbing_contents = list(
		/obj/item/storage/box/MRE = 1,
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/highimpact = 4,
	)


//Base TGMC leader outfit
/datum/outfit/quick/tgmc/leader
	name = "TGMC Squad Leader"
	jobtype = "Squad Leader"

	ears = /obj/item/radio/headset/mainship/marine
	glasses = /obj/item/clothing/glasses/hud/health
	w_uniform = /obj/item/clothing/under/marine/black_vest
	shoes = /obj/item/clothing/shoes/marine/full
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/heavy/leader
	gloves = /obj/item/clothing/gloves/marine
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/m10x/leader
	r_pocket = /obj/item/storage/pouch/firstaid/combat_patrol_leader
	l_pocket = /obj/item/storage/pouch/grenade/combat_patrol
	back = /obj/item/storage/backpack/lightpack

	suit_contents = list(
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/isotonic = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
	)


/datum/outfit/quick/tgmc/leader/standard_assaultrifle
	name = "AR-12 Patrol Leader"
	desc = "Gives the orders. Equipped with an AR-12 assault rifle with UGL, plenty of grenades, some support kit such as deployable cameras, as well as heavy armor with a 'valkyrie' autodoc module. You can provide excellent support to your squad thanks to your kit and order shouting talents."

	suit_store = /obj/item/weapon/gun/rifle/standard_assaultrifle/rifleman
	belt = /obj/item/storage/belt/marine/t12

	backpack_contents = list(
		/obj/item/deployable_camera = 1,
		/obj/item/ammo_magazine/packet/p10x24mm = 1,
		/obj/item/explosive/plastique = 2,
		/obj/item/explosive/grenade/smokebomb/cloak = 1,
		/obj/item/explosive/grenade/incendiary = 1,
		/obj/item/storage/box/MRE = 1,
		/obj/item/ammo_magazine/pistol/vp70 = 2,
		/obj/item/weapon/gun/pistol/vp70/tactical = 1,
		/obj/item/tool/extinguisher/mini = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/sticky = 2,
		/obj/item/explosive/grenade = 2,
		/obj/item/binoculars/fire_support/campaign = 1,
	)

/datum/outfit/quick/tgmc/leader/standard_assaultrifle/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/hud_tablet(H, /datum/job/terragov/squad/leader, H.assigned_squad), SLOT_IN_BACKPACK)

/datum/outfit/quick/tgmc/leader/standard_carbine
	name = "AR-18 Patrol Leader"
	desc = "Gives the orders. Equipped with an AR-18 carbine with plasma pistol attachment, plenty of grenades, as well as heavy armor with a 'valkyrie' autodoc module. You can provide excellent support to your squad thanks to your kit and order shouting talents, while unleashing excellent damage at medium range."

	suit_store = /obj/item/weapon/gun/rifle/standard_carbine/plasma_pistol
	belt = /obj/item/storage/belt/marine/t18

	backpack_contents = list(
		/obj/item/ammo_magazine/pistol/plasma_pistol = 3,
		/obj/item/ammo_magazine/packet/p10x24mm = 1,
		/obj/item/explosive/plastique = 2,
		/obj/item/explosive/grenade/smokebomb/cloak = 1,
		/obj/item/storage/box/MRE = 1,
		/obj/item/ammo_magazine/pistol/vp70 = 2,
		/obj/item/weapon/gun/pistol/vp70/tactical = 1,
		/obj/item/tool/extinguisher/mini = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade = 2,
		/obj/item/explosive/grenade/m15 = 1,
		/obj/item/explosive/grenade/incendiary = 1,
		/obj/item/binoculars/fire_support/campaign = 1,
	)


/datum/outfit/quick/tgmc/leader/combat_rifle
	name = "AR-11 Patrol Leader"
	desc = "Gives the orders. Equipped with an AR-11 combat rifle, plenty of grenades, as well as heavy armor with a 'valkyrie' autodoc module. You can provide excellent support to your squad thanks to your kit and order shouting talents, with excellent damage at all ranges."

	suit_store = /obj/item/weapon/gun/rifle/tx11/standard
	belt = /obj/item/storage/belt/marine/combat_rifle

	backpack_contents = list(
		/obj/item/deployable_camera = 2,
		/obj/item/ammo_magazine/packet/p492x34mm = 1,
		/obj/item/explosive/plastique = 2,
		/obj/item/explosive/grenade/smokebomb/cloak = 1,
		/obj/item/storage/box/MRE = 1,
		/obj/item/ammo_magazine/pistol/vp70 = 2,
		/obj/item/weapon/gun/pistol/vp70/tactical = 1,
		/obj/item/tool/extinguisher/mini = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade = 2,
		/obj/item/explosive/grenade/m15 = 1,
		/obj/item/explosive/grenade/incendiary = 1,
		/obj/item/binoculars/fire_support/campaign = 1,
	)

/datum/outfit/quick/tgmc/leader/combat_rifle/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/hud_tablet(H, /datum/job/terragov/squad/leader, H.assigned_squad), SLOT_IN_BACKPACK)

/datum/outfit/quick/tgmc/leader/standard_battlerifle
	name = "BR-64 Patrol Leader"
	desc = "Gives the orders. Equipped with an BR-64 battle rifle with UGL, plenty of grenades, as well as heavy armor with a 'valkyrie' autodoc module. The battle rifle offers improved damage and penetration compared to more common rifles, but still retains a grenade launcher that the AR-11 lacks."

	suit_store = /obj/item/weapon/gun/rifle/standard_br/standard
	belt = /obj/item/storage/belt/marine/standard_battlerifle

	backpack_contents = list(
		/obj/item/ammo_magazine/packet/p10x265mm = 2,
		/obj/item/explosive/plastique = 2,
		/obj/item/explosive/grenade/smokebomb/cloak = 1,
		/obj/item/explosive/grenade/incendiary = 1,
		/obj/item/storage/box/MRE = 1,
		/obj/item/ammo_magazine/pistol/vp70 = 2,
		/obj/item/weapon/gun/pistol/vp70/tactical = 1,
		/obj/item/tool/extinguisher = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade = 2,
		/obj/item/explosive/grenade/sticky = 2,
		/obj/item/binoculars/fire_support/campaign = 1,
	)


/datum/outfit/quick/tgmc/leader/auto_shotgun
	name = "SH-15 Patrol Leader"
	desc = "Gives the orders. Equipped with an SH-15 auto shotgun, plenty of grenades, as well as heavy armor with a 'valkyrie' autodoc module. You can provide excellent support to your squad thanks to your kit and order shouting talents, with strong damage and control."

	suit_store = /obj/item/weapon/gun/rifle/standard_autoshotgun/plasma_pistol
	belt = /obj/item/storage/belt/marine/auto_shotgun

	backpack_contents = list(
		/obj/item/ammo_magazine/rifle/tx15_slug = 1,
		/obj/item/ammo_magazine/rifle/tx15_flechette = 1,
		/obj/item/ammo_magazine/pistol/plasma_pistol = 3,
		/obj/item/explosive/plastique = 2,
		/obj/item/storage/box/MRE = 1,
		/obj/item/ammo_magazine/pistol/vp70 = 2,
		/obj/item/weapon/gun/pistol/vp70/tactical = 1,
		/obj/item/tool/extinguisher = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/m15 = 2,
		/obj/item/explosive/grenade/incendiary = 1,
		/obj/item/explosive/grenade/smokebomb/cloak = 1,
		/obj/item/binoculars/fire_support/campaign = 1,
	)


/datum/outfit/quick/tgmc/leader/standard_laserrifle
	name = "Laser Rifle Patrol Leader"
	desc = "Gives the orders. Equipped with a laser rifle with UGL for better armor penetration against SOM, some support kit such as deployable cameras, as well as heavy armor with a 'valkyrie' autodoc module. You can provide excellent support to your squad thanks to your kit and order shouting talents."

	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle/rifleman
	belt = /obj/item/storage/belt/marine/te_cells

	backpack_contents = list(
		/obj/item/deployable_camera = 2,
		/obj/item/cell/lasgun/lasrifle = 1,
		/obj/item/explosive/plastique = 2,
		/obj/item/explosive/grenade/smokebomb/cloak = 1,
		/obj/item/storage/box/MRE = 1,
		/obj/item/ammo_magazine/pistol/vp70 = 2,
		/obj/item/weapon/gun/pistol/vp70/tactical = 1,
		/obj/item/tool/extinguisher/mini = 1,
	)

	webbing_contents = list(
		/obj/item/ammo_magazine/flamer_tank/mini = 2,
		/obj/item/explosive/grenade = 2,
		/obj/item/binoculars/fire_support/campaign = 1,
	)

/datum/outfit/quick/tgmc/leader/standard_laserrifle/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/hud_tablet(H, /datum/job/terragov/squad/leader, H.assigned_squad), SLOT_IN_BACKPACK)

/datum/outfit/quick/tgmc/leader/oicw
	name = "AR-55 Patrol Leader"
	desc = "Gives the orders. Equipped with an AR-55 OICW with plenty of grenades for its integrated grenade launcher, some support kit such as deployable cameras, as well as heavy armor with a 'valkyrie' autodoc module. You can provide excellent support to your squad thanks to your kit and order shouting talents."
	quantity = 2

	suit_store = /obj/item/weapon/gun/rifle/tx55/combat_patrol
	belt = /obj/item/storage/belt/marine/oicw

	backpack_contents = list(
		/obj/item/ammo_magazine/packet/p10x24mm = 2,
		/obj/item/ammo_magazine/rifle/standard_carbine = 2,
		/obj/item/ammo_magazine/rifle/tx54 = 2,
		/obj/item/weapon/gun/pistol/vp70/tactical = 1,
		/obj/item/tool/extinguisher = 1,
	)

	webbing_contents = list(
		/obj/item/ammo_magazine/pistol/vp70 = 2,
		/obj/item/storage/box/MRE = 1,
		/obj/item/explosive/plastique = 1,
		/obj/item/binoculars/fire_support/campaign = 1,
	)


//// SOM loadouts ////

//Base SOM outfit
/datum/outfit/quick/som
	name = "SOM base"
	desc = "This is the base typepath for all SOM quick vendor outfits. You shouldn't see this."

//Base SOM marine outfit
/datum/outfit/quick/som/marine
	name = "SOM Squad Marine"
	jobtype = "SOM Squad Standard"

	ears = /obj/item/radio/headset/mainship/som
	w_uniform = /obj/item/clothing/under/som/webbing
	shoes = /obj/item/clothing/shoes/marine/som/knife
	wear_suit = /obj/item/clothing/suit/modular/som/shield
	gloves = /obj/item/clothing/gloves/marine/som
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/som
	r_pocket = /obj/item/storage/pouch/firstaid/som/combat_patrol
	l_pocket = /obj/item/storage/pouch/grenade/som/combat_patrol
	back = /obj/item/storage/backpack/satchel/som

	suit_contents = list(
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/isotonic = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
	)


/datum/outfit/quick/som/marine/standard_assaultrifle
	name = "V-31 Infantryman"
	desc = "The typical SOM infantryman. Equipped with a V-31 assault rifle with integrated 'micro grenade' rail launcher, medium armor and a good selection of grenades. The rail launcher fires grenades that must arm mid flight, so are ineffective at close ranges, but add significant tactical options at medium range."

	suit_store = /obj/item/weapon/gun/rifle/som/standard
	belt = /obj/item/storage/belt/marine/som/som_rifle

	backpack_contents = list(
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/ammo_magazine/pistol/som = 2,
		/obj/item/weapon/gun/pistol/som/standard = 1,
		/obj/item/ammo_magazine/rifle/som = 2,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 1,
		/obj/item/ammo_magazine/handful/micro_grenade = 1,
		/obj/item/ammo_magazine/handful/micro_grenade/dragonbreath = 1,
		/obj/item/ammo_magazine/handful/micro_grenade/cluster = 1,
		/obj/item/ammo_magazine/handful/micro_grenade/smoke_burst = 1,
	)


/datum/outfit/quick/som/marine/mpi
	name = "MPI_KM Infantryman"
	desc = "A call back to an earlier time. Equipped with an MPI_KM assault rifle, with under barrel grenade launcher and a large supply of grenades. An old weapon that was a common sight during the original Martian rebellion, the MPI's good stopping power, reliability and a healthy dose of nostalgia means it is still seen in use by some among the SOM despite its age."

	suit_store = /obj/item/weapon/gun/rifle/mpi_km/black/grenadier
	belt = /obj/item/storage/belt/marine/som/mpi_black

	backpack_contents = list(
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/ammo_magazine/pistol/som = 2,
		/obj/item/weapon/gun/pistol/som/standard = 1,
		/obj/item/ammo_magazine/rifle/mpi_km/black = 2,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 4,
		/obj/item/explosive/grenade/incendiary/som = 1,
	)


/datum/outfit/quick/som/marine/light_carbine
	name = "V-34 Light Infantryman"
	desc = "Mobile and dangerous. Equipped with a V-34 carbine, light armor with an 'Aegis' shield module and a large supply of grenades. The V-34 is a modern update of an old weapon that was a common sight during the original Martian rebellion. Very reliable and excellent stopping power in a small, lightweight package. Brought into service as a much cheaper alternative to the VX-32."

	wear_suit = /obj/item/clothing/suit/modular/som/light/shield
	suit_store = /obj/item/weapon/gun/rifle/som_carbine/black/standard
	belt = /obj/item/storage/belt/marine/som/carbine_black

	backpack_contents = list(
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/ammo_magazine/pistol/som = 2,
		/obj/item/weapon/gun/pistol/som/standard = 1,
		/obj/item/ammo_magazine/rifle/mpi_km/carbine/black = 2,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 4,
		/obj/item/explosive/grenade/incendiary/som = 1,
	)


/datum/outfit/quick/som/marine/scout
	name = "V-21 Light Infantryman"
	desc = "Highly mobile scouting configuration. Equipped with a V-21 submachine gun with variable firerate allowing for extreme rates of fire when properly wielded, light armor with an 'Aegis' shield module and a good selection of grenades. Allows for exceptional mobility and blistering firepower, it will falter in extended engagements where low armor and the V-21's high rate of fire can become liabilities."

	wear_suit = /obj/item/clothing/suit/modular/som/light/shield
	suit_store = /obj/item/weapon/gun/smg/som/scout
	belt = /obj/item/storage/belt/marine/som/som_smg

	backpack_contents = list(
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/ammo_magazine/pistol/som = 2,
		/obj/item/weapon/gun/pistol/som/standard = 1,
		/obj/item/ammo_magazine/smg/som = 3,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 2,
		/obj/item/explosive/grenade/incendiary/som = 2,
		/obj/item/binoculars = 1,
	)


/datum/outfit/quick/som/marine/shotgunner
	name = "V-51 Pointman"
	desc = "For close encounters. Equipped with a V-51 semi-automatic shotgun, light armor with an 'Aegis' shield module and a large selection of grenades. Allows for good mobility and dangerous CQC firepower."

	belt = /obj/item/storage/belt/shotgun/som/mixed
	wear_suit = /obj/item/clothing/suit/modular/som/light/shield
	suit_store = /obj/item/weapon/gun/shotgun/som/standard

	backpack_contents = list(
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/ammo_magazine/pistol/som = 3,
		/obj/item/weapon/gun/pistol/som/standard = 1,
		/obj/item/explosive/grenade/flashbang/stun = 2,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 2,
		/obj/item/explosive/grenade/incendiary/som = 2,
		/obj/item/binoculars = 1,
	)


/datum/outfit/quick/som/marine/pyro
	name = "V-62 Flamethrower Operator"
	desc = "Smells like victory. Equipped with an V-62 incinerator and wide nozzle, V-11 equipped for rapid burst fire, heavy armor upgraded with a 'Hades' fireproof module, and a backtank of fuel. Has better than average range and can quickly burn down large areas. It suffers from significant slowdown, lacks an integrated extinguisher, and undisciplined use can result in rapidly consuming all available fuel."

	head = /obj/item/clothing/head/modular/som/hades
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/pyro
	belt = /obj/item/storage/holster/belt/pistol/m4a3/som
	back = /obj/item/ammo_magazine/flamer_tank/backtank
	suit_store = /obj/item/weapon/gun/flamer/som/mag_harness

	webbing_contents = list(
		/obj/item/ammo_magazine/pistol/som/extended = 2,
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/explosive/grenade/som = 1,
	)

	belt_contents = list(
		/obj/item/weapon/gun/pistol/som/burst = 1,
		/obj/item/ammo_magazine/pistol/som/extended = 6,
	)


/datum/outfit/quick/som/marine/breacher
	name = "V-21 Breacher"
	desc = "Heavy armored breaching configuration. Equipped with a V-21 submachine gun with variable firerate allowing for extreme rates of fire when properly wielded, heavy armor, a boarding shield and a good selection of grenades. Offers outstanding protection although damage may be lacking, particular at longer range."

	glasses = /obj/item/clothing/glasses/welding
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/shield
	suit_store = /obj/item/weapon/gun/smg/som/one_handed
	belt = /obj/item/storage/belt/marine/som/som_smg
	r_hand = /obj/item/weapon/shield/riot/marine/som

	backpack_contents = list(
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/tool/weldingtool/largetank = 1,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
		/obj/item/ammo_magazine/smg/som = 4,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 2,
		/obj/item/explosive/grenade/incendiary/som = 2,
		/obj/item/explosive/grenade/flashbang/stun = 1,
	)


/datum/outfit/quick/som/marine/breacher_melee
	name = "CQC Breacher"
	desc = "For when a complete lack of subtlety is required. Equipped with 'Lorica' enhanced heavy armor and armed with a monsterous two handed breaching axe, designed to cut through heavy armor. When properly wielded, it also provides a degree of protection."

	head = /obj/item/clothing/head/modular/som/lorica
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/lorica
	suit_store = /obj/item/weapon/twohanded/fireaxe/som
	belt = /obj/item/storage/holster/belt/pistol/m4a3/som

	backpack_contents = list(
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/ammo_magazine/pistol/som = 2,
		/obj/item/explosive/plastique = 3,
		/obj/item/tool/extinguisher = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/synaptizine = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 4,
		/obj/item/explosive/grenade/incendiary/som = 1,
	)

	belt_contents = list(
		/obj/item/weapon/gun/pistol/som/burst = 1,
		/obj/item/ammo_magazine/pistol/som/extended = 6,
	)


/datum/outfit/quick/som/marine/machine_gunner
	name = "V-41 Machinegunner"
	desc = "Heavy static firesupport. Equipped with a V-41 machine gun, burst fire V-11 sidearm and some basic building supplies. While often ill suited to the SOM's standard doctrine of mobility and aggression, the V-41 is typically seen in defensive positions or second line units where its poor mobility is a minor drawback compared to its sustained firepower."

	suit_store = /obj/item/weapon/gun/rifle/som_mg/standard
	belt = /obj/item/storage/holster/belt/pistol/m4a3/som
	l_pocket = /obj/item/storage/pouch/construction/som

	backpack_contents = list(
		/obj/item/ammo_magazine/som_mg = 4,
		/obj/item/tool/extinguisher = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 2,
		/obj/item/explosive/grenade/smokebomb/som = 1,
		/obj/item/explosive/grenade/smokebomb/satrapine = 1,
		/obj/item/storage/box/MRE/som = 1,
	)

	l_pocket_contents = list(
		/obj/item/tool/shovel/etool = 1,
		/obj/item/stack/sandbags_empty/half = 1,
		/obj/item/stack/sandbags/large_stack = 1,
		/obj/item/stack/barbed_wire/half_stack = 1,
	)

	belt_contents = list(
		/obj/item/weapon/gun/pistol/som/burst = 1,
		/obj/item/ammo_magazine/pistol/som/extended = 6,
	)


/datum/outfit/quick/som/marine/charger
	name = "Charger Infantryman"
	desc = "The future infantryman of the SOM. Equipped with a volkite charger, medium armor and a good variety of grenades. Volkite weapons are exceptionally dangerous, especially against poorly armored or tightly grouped opponents. The charger is the SOM's premier close/medium range weapon, with good mobility, and can be used (with some difficulty) one handed when required."
	quantity = 4

	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/magharness
	belt = /obj/item/storage/belt/marine/som/volkite

	backpack_contents = list(
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/ammo_magazine/pistol/som = 2,
		/obj/item/weapon/gun/pistol/som/standard = 1,
		/obj/item/cell/lasgun/volkite = 2,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 2,
		/obj/item/explosive/grenade/incendiary/som = 2,
		/obj/item/tool/extinguisher/mini = 1,
	)


//Base SOM engineer outfit
/datum/outfit/quick/som/engineer
	name = "SOM Squad Engineer"
	jobtype = "SOM Squad Engineer"

	ears = /obj/item/radio/headset/mainship/som
	w_uniform = /obj/item/clothing/under/som/webbing
	shoes = /obj/item/clothing/shoes/marine/som/knife
	wear_suit = /obj/item/clothing/suit/modular/som/engineer
	gloves = /obj/item/clothing/gloves/marine/som/insulated
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/som/engineer
	glasses = /obj/item/clothing/glasses/meson
	r_pocket = /obj/item/storage/pouch/firstaid/som/combat_patrol
	l_pocket = /obj/item/storage/pouch/tools/som/full
	back = /obj/item/storage/backpack/lightpack/som

	suit_contents = list(
		/obj/item/circuitboard/apc = 1,
		/obj/item/cell/high = 1,
		/obj/item/stack/sheet/plasteel/medium_stack = 1,
		/obj/item/stack/sheet/metal/large_stack = 1,
		/obj/item/stack/barbed_wire/half_stack = 1,
	)

	head_contents = list(
		/obj/item/explosive/plastique = 2,
	)


/datum/outfit/quick/som/engineer/standard_assaultrifle
	name = "V-31 Engineer"
	desc = "Battlefield engineer; building up and tearing down. Equipped with a V-31 assault rifle with integrated 'micro grenade' rail launcher, medium armor, a deployable COPE sentry and a selection of explosives. Has a variety of supplies and equipment to build, repair or apply demolitions in the field. A valuable support asset to a well rounded combat force. The rail launcher fires grenades that must arm mid flight, so are ineffective at close ranges, but add significant tactical options at medium range."

	suit_store = /obj/item/weapon/gun/rifle/som/standard
	belt = /obj/item/storage/belt/marine/som/som_rifle

	backpack_contents = list(
		/obj/item/tool/extinguisher = 1,
		/obj/item/assembly/signaler = 1,
		/obj/item/detpack = 4,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope = 1,
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/explosive/plastique = 2,
	)

	webbing_contents = list(
		/obj/item/ammo_magazine/handful/micro_grenade = 1,
		/obj/item/ammo_magazine/handful/micro_grenade/dragonbreath = 1,
		/obj/item/ammo_magazine/handful/micro_grenade/cluster = 2,
		/obj/item/explosive/grenade/smokebomb/satrapine = 1,
	)


/datum/outfit/quick/som/engineer/mpi
	name = "MPI-KM Engineer"
	desc = "Battlefield engineer; building up and tearing down. Equipped with an MPI_KM assault rifle, medium armor, a deployable COPE sentry and a selection of explosives. Has a variety of supplies and equipment to build, repair or apply demolitions in the field. A valuable support asset to a well rounded combat force. An old weapon that was a common sight during the original Martian rebellion, the MPI's good stopping power, reliability and a healthy dose of nostalgia means it is still seen in use by some among the SOM despite its age."

	suit_store = /obj/item/weapon/gun/rifle/mpi_km/black/magharness
	belt = /obj/item/storage/belt/marine/som/mpi_black

	backpack_contents = list(
		/obj/item/tool/extinguisher = 1,
		/obj/item/assembly/signaler = 1,
		/obj/item/detpack = 4,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope = 1,
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/explosive/plastique = 2,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 3,
		/obj/item/explosive/grenade/smokebomb/som = 1,
		/obj/item/explosive/grenade/smokebomb/satrapine = 1,
	)


/datum/outfit/quick/som/engineer/standard_carbine
	name = "V-34 Engineer"
	desc = "Battlefield engineer; building up and tearing down. Equipped with a V-34 carbine, medium armor, a deployable COPE sentry and a selection of explosives. Has a variety of supplies and equipment to build, repair or apply demolitions in the field. A valuable support asset to a well rounded combat force. The V-34 is a modern update of an old weapon that was a common sight during the original Martian rebellion. Very reliable and excellent stopping power in a small, lightweight package. Brought into service as a much cheaper alternative to the VX-32."

	suit_store = /obj/item/weapon/gun/rifle/som_carbine/black/standard
	belt = /obj/item/storage/belt/marine/som/carbine_black

	backpack_contents = list(
		/obj/item/tool/extinguisher = 1,
		/obj/item/assembly/signaler = 1,
		/obj/item/detpack = 4,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope = 1,
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/explosive/plastique = 2,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 3,
		/obj/item/explosive/grenade/smokebomb/som = 1,
		/obj/item/explosive/grenade/smokebomb/satrapine = 1,
	)


/datum/outfit/quick/som/engineer/standard_smg
	name = "V-21 Engineer"
	desc = "Battlefield engineer; building up and tearing down. Equipped with a V-21 submachine gun with variable firerate allowing for extreme rates of fire when properly wielded, medium armor, a deployable COPE sentry and a selection of explosives. Has a variety of supplies and equipment to build, repair or apply demolitions in the field. A valuable support asset to a well rounded combat force. "

	suit_store = /obj/item/weapon/gun/smg/som/support
	belt = /obj/item/storage/belt/marine/som/som_smg

	backpack_contents = list(
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/assembly/signaler = 1,
		/obj/item/detpack = 3,
		/obj/item/ammo_magazine/smg/som = 2,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope = 1,
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/explosive/plastique = 2,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/smokebomb/som = 2,
		/obj/item/explosive/grenade/flashbang/stun = 1,
		/obj/item/explosive/grenade/som = 1,
		/obj/item/explosive/grenade/smokebomb/satrapine = 1,
	)

/datum/outfit/quick/som/engineer/standard_shotgun
	name = "V-51 Engineer"
	desc = "Battlefield engineer; building up and tearing down. Equipped with a V-51 semi-automatic shotgun, medium armor, a deployable COPE sentry and a selection of explosives. Has a variety of supplies and equipment to build, repair or apply demolitions in the field. A valuable support asset to a well rounded combat force. "

	belt = /obj/item/storage/belt/shotgun/som/flechette
	suit_store = /obj/item/weapon/gun/shotgun/som/support

	backpack_contents = list(
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/assembly/signaler = 1,
		/obj/item/detpack = 3,
		/obj/item/ammo_magazine/handful/buckshot = 2,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope = 1,
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/explosive/plastique = 2,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/smokebomb/som = 2,
		/obj/item/explosive/grenade/flashbang/stun = 1,
		/obj/item/explosive/grenade/som = 1,
		/obj/item/explosive/grenade/smokebomb/satrapine = 1,
	)


//Base SOM medic outfit
/datum/outfit/quick/som/medic
	name = "SOM Squad Medic"
	jobtype = "SOM Squad Medic"

	belt = /obj/item/storage/belt/lifesaver/som/quick
	ears = /obj/item/radio/headset/mainship/som
	w_uniform = /obj/item/clothing/under/som/medic/vest
	shoes = /obj/item/clothing/shoes/marine/som/knife
	wear_suit = /obj/item/clothing/suit/modular/som/medic
	gloves = /obj/item/clothing/gloves/marine/som
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/som
	glasses = /obj/item/clothing/glasses/hud/health
	r_pocket = /obj/item/storage/pouch/magazine/large/som
	l_pocket = /obj/item/storage/pouch/grenade/som/combat_patrol
	back = /obj/item/storage/backpack/lightpack/som

	suit_contents = list(
		/obj/item/tool/extinguisher = 1,
		/obj/item/defibrillator = 1,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = 1,
	)

	webbing_contents = list(
		/obj/item/roller = 1,
		/obj/item/tweezers_advanced = 1,
		/obj/item/storage/pill_bottle/spaceacillin = 1,
		/obj/item/reagent_containers/hypospray/advanced/nanoblood = 1,
		/obj/item/bodybag/cryobag = 1,
		/obj/item/reagent_containers/hypospray/advanced/combat_advanced = 1,
	)


/datum/outfit/quick/som/medic/standard_assaultrifle
	name = "V-31 Medic"
	desc = "Keeping your buddies alive and in the fight. Equipped with a V-31 assault rifle with integrated 'micro grenade' rail launcher, medium armor and a good selection of grenades. Packs a large amount of medical supplies, the squad medic is vital to maintaining combat viability. The rail launcher fires grenades that must arm mid flight, so are ineffective at close ranges, but add significant tactical options at medium range."

	suit_store = /obj/item/weapon/gun/rifle/som/standard

	backpack_contents = list(
		/obj/item/ammo_magazine/rifle/som = 3,
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/ammo_magazine/handful/micro_grenade/smoke_burst = 1,
		/obj/item/ammo_magazine/handful/micro_grenade/dragonbreath = 1,
		/obj/item/ammo_magazine/handful/micro_grenade = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = 1,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/som = 3,
	)


/datum/outfit/quick/som/medic/mpi
	name = "MPI_KM Medic"
	desc = "Keeping your buddies alive and in the fight. Equipped with an MPI_KM assault rifle, medium armor and a good selection of grenades. Packs a large amount of medical supplies, the squad medic is vital to maintaining combat viability. An old weapon that was a common sight during the original Martian rebellion, the MPI's good stopping power, reliability and a healthy dose of nostalgia means it is still seen in use by some among the SOM despite its age."

	suit_store = /obj/item/weapon/gun/rifle/mpi_km/black/magharness

	backpack_contents = list(
		/obj/item/ammo_magazine/rifle/mpi_km/black = 4,
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/explosive/grenade/som = 3,
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = 1,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/mpi_km/black = 3,
	)


/datum/outfit/quick/som/medic/standard_carbine
	name = "V-34 Medic"
	desc = "Keeping your buddies alive and in the fight. Equipped with an V-34 carbine, medium armor for massive firepower and mobility, but poor ammo economy and range. Packs a large amount of medical supplies, the squad medic is vital to maintaining combat viability. The V-34 is a modern update of an old weapon that was a common sight during the original Martian rebellion. Very reliable and excellent stopping power in a small, lightweight package. Brought into service as a much cheaper alternative to the VX-32."

	suit_store = /obj/item/weapon/gun/rifle/som_carbine/black/standard

	backpack_contents = list(
		/obj/item/ammo_magazine/rifle/mpi_km/carbine/black = 4,
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/explosive/grenade/som = 3,
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = 1,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/mpi_km/carbine/black = 3,
	)


/datum/outfit/quick/som/medic/standard_smg
	name = "V-21 Medic"
	desc = "Keeping your buddies alive and in the fight. Equipped with a V-21 submachine gun with variable firerate allowing for extreme rates of fire when properly wielded, medium armor and a good selection of grenades. Packs a large amount of medical supplies, the squad medic is vital to maintaining combat viability."

	suit_store = /obj/item/weapon/gun/smg/som/support

	backpack_contents = list(
		/obj/item/ammo_magazine/smg/som = 6,
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/explosive/grenade/som = 3,
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = 1,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/smg/som = 3,
	)


/datum/outfit/quick/som/medic/standard_shotgun
	name = "V-51 Medic"
	desc = "Keeping your buddies alive and in the fight. Equipped with a V-51 semi-automatic shotgun, medium armor and a good selection of grenades. Packs a large amount of medical supplies, the squad medic is vital to maintaining combat viability."

	r_pocket = /obj/item/storage/pouch/shotgun/som
	suit_store = /obj/item/weapon/gun/shotgun/som/support

	backpack_contents = list(
		/obj/item/ammo_magazine/handful/flechette = 7,
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/explosive/grenade/som = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = 1,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/handful/flechette = 4,
	)


//Base SOM veteran outfit
/datum/outfit/quick/som/veteran
	name = "SOM Squad Veteran"
	jobtype = "SOM Squad Veteran"

	ears = /obj/item/radio/headset/mainship/som
	w_uniform = /obj/item/clothing/under/som/veteran/webbing
	shoes = /obj/item/clothing/shoes/marine/som/knife
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/shield
	gloves = /obj/item/clothing/gloves/marine/som/veteran
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/som/veteran
	glasses = /obj/item/clothing/glasses/meson
	r_pocket = /obj/item/storage/pouch/firstaid/som/combat_patrol
	l_pocket = /obj/item/storage/pouch/grenade/som/combat_patrol
	back = /obj/item/storage/backpack/satchel/som

	suit_contents = list(
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/isotonic = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
	)


/datum/outfit/quick/som/veteran/standard_assaultrifle
	name = "V-31 Veteran Infantryman"
	desc = "Heavily armed and armored SOM elite. Equipped with a V-31 assault rifle with integrated 'micro grenade' rail launcher, heavy armor, a large variety of grenades as well as AP ammunition. Excellent performance against heavily armored targets, while the plentiful grenade provide greater tactical flexibility."

	back = /obj/item/storage/backpack/lightpack/som
	suit_store = /obj/item/weapon/gun/rifle/som/veteran
	belt = /obj/item/storage/belt/marine/som/som_rifle_ap

	backpack_contents = list(
		/obj/item/explosive/plastique = 1,
		/obj/item/ammo_magazine/pistol/som = 2,
		/obj/item/weapon/gun/pistol/som/standard = 1,
		/obj/item/ammo_magazine/rifle/som/ap = 2,
		/obj/item/explosive/grenade/som = 2,
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/ammo_magazine/handful/micro_grenade/smoke_burst = 1,
	)

	webbing_contents = list(
		/obj/item/ammo_magazine/handful/micro_grenade = 1,
		/obj/item/ammo_magazine/handful/micro_grenade/dragonbreath = 2,
		/obj/item/ammo_magazine/handful/micro_grenade/cluster = 2,
	)


/datum/outfit/quick/som/veteran/standard_smg
	name = "V-21 Veteran Infantryman"
	desc = "Close range high damage, high speed. Equipped with a V-21 submachine gun with variable firerate allowing for extreme rates of fire when properly wielded, heavy armor, a good variety of grenades and AP ammunition. Allows for excellent close to medium range firepower, especially against heavily armored targets, and is surprisingly mobile."

	suit_store = /obj/item/weapon/gun/smg/som/veteran
	belt = /obj/item/storage/belt/marine/som/som_smg_ap

	backpack_contents = list(
		/obj/item/explosive/plastique = 1,
		/obj/item/ammo_magazine/pistol/som = 2,
		/obj/item/weapon/gun/pistol/som/standard = 1,
		/obj/item/ammo_magazine/smg/som/ap = 3,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 2,
		/obj/item/explosive/grenade/incendiary/som = 1,
		/obj/item/explosive/grenade/flashbang/stun = 1,
		/obj/item/storage/box/MRE/som = 1,
	)


/datum/outfit/quick/som/veteran/breacher
	name = "Charger Veteran Breacher"
	desc = "Heavy armored breaching configuration. Equipped with a volkite charger configured for better one handed use, heavy armor upgraded with 'Lorica' armor reinforcements, a boarding shield and a good selection of grenades. Premier protection and deadly close range firepower."

	head = /obj/item/clothing/head/modular/som/lorica
	glasses = /obj/item/clothing/glasses/welding
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/lorica
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/somvet
	belt = /obj/item/storage/belt/marine/som/volkite
	r_hand = /obj/item/weapon/shield/riot/marine/som

	backpack_contents = list(
		/obj/item/tool/weldingtool/largetank = 1,
		/obj/item/explosive/plastique = 3,
		/obj/item/cell/lasgun/volkite = 3,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 2,
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/explosive/grenade/incendiary/som = 1,
		/obj/item/tool/extinguisher/mini = 1,
	)


/datum/outfit/quick/som/veteran/charger
	name = "Charger Veteran Infantryman"
	desc = "Heavily armed and armored SOM elite. Equipped with a volkite charger with motion sensor and gyrostabiliser for better one handed use, heavy armor and a good variety of grenades. Volkite weapons are exceptionally dangerous, especially against poorly armored or tightly grouped opponents. The charger is the SOM's premier close/medium range weapon, with good mobility, and can be used (with some difficulty) one handed."

	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/scout
	belt = /obj/item/storage/belt/marine/som/volkite

	backpack_contents = list(
		/obj/item/ammo_magazine/pistol/som = 2,
		/obj/item/weapon/gun/pistol/som/standard = 1,
		/obj/item/explosive/plastique = 1,
		/obj/item/cell/lasgun/volkite = 2,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 2,
		/obj/item/explosive/grenade/incendiary/som = 1,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/storage/box/MRE/som = 1,
	)

/datum/outfit/quick/som/veteran/caliver
	name = "Caliver Veteran Infantryman"
	desc = "Heavily armed and armored SOM elite. Equipped with a volkite caliver, heavy armor and a good variety of grenades. Volkite weapons are exceptionally dangerous, especially against poorly armored or tightly grouped opponents. The caliver provides deadly firepower at all ranges. Approach with caution."

	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/standard
	belt = /obj/item/storage/belt/marine/som/volkite

	backpack_contents = list(
		/obj/item/ammo_magazine/pistol/som = 2,
		/obj/item/weapon/gun/pistol/som/standard = 1,
		/obj/item/explosive/plastique = 1,
		/obj/item/cell/lasgun/volkite = 2,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 2,
		/obj/item/explosive/grenade/incendiary/som = 1,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/storage/box/MRE/som = 1,
	)

/datum/outfit/quick/som/veteran/caliver_pack
	name = "Caliver Veteran Rifleman"
	desc = "Heavily armed and armored SOM elite. Equipped with a volkite caliver with motion sensor, heavy armor, plenty of grenades and a back mounted self charging power supply. Volkite weapons are exceptionally dangerous, especially against poorly armored or tightly grouped opponents. The caliver provides deadly firepower at all ranges, and the power pack allows for sustained period of fire, although over extended periods of time the recharge may struggle to keep up with the demands of the weapon."
	quantity = 2

	belt = /obj/item/storage/belt/grenade/som
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/tacsensor
	l_pocket = /obj/item/storage/pouch/pistol/som
	back = /obj/item/cell/lasgun/volkite/powerpack

	belt_contents = list(
		/obj/item/explosive/grenade/smokebomb/som = 2,
		/obj/item/explosive/grenade/smokebomb/satrapine = 2,
		/obj/item/explosive/grenade/flashbang/stun = 2,
		/obj/item/explosive/grenade/som = 2,
		/obj/item/explosive/grenade/incendiary/som = 1,
	)

	webbing_contents = list(
		/obj/item/ammo_magazine/pistol/som = 3,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/storage/box/MRE/som = 1,
	)

	l_pocket_contents = list(
		/obj/item/weapon/gun/pistol/som/standard = 1,
	)


/datum/outfit/quick/som/veteran/mpi
	name = "MPI_KM Veteran Infantryman"
	desc = "Heavily armed and armored SOM elite, with a taste for nostalgia. Equipped with an MPI_KM assault rifle, with under barrel grenade launcher and a large supply of grenades. An old weapon that was a common sight during the original Martian rebellion, the MPI's good stopping power, reliability and a healthy dose of nostalgia means it is still seen in use by some among the SOM despite its age."

	suit_store = /obj/item/weapon/gun/rifle/mpi_km/grenadier
	belt = /obj/item/storage/belt/marine/som/mpi_plum

	backpack_contents = list(
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/ammo_magazine/pistol/som = 2,
		/obj/item/weapon/gun/pistol/som/standard = 1,
		/obj/item/ammo_magazine/rifle/mpi_km/extended = 1,
		/obj/item/tool/extinguisher = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 4,
		/obj/item/explosive/grenade/incendiary/som = 1,
	)

/datum/outfit/quick/som/veteran/carbine
	name = "V-34 Veteran Infantryman"
	desc = "Heavily armed and armored SOM elite, with a taste for nostalgia. Equipped with an heirloom V-34 carbine, and a large supply of grenades. An old weapon that saw extensive use during the original Martian rebellion, this one has been preserved and passed down the generations. The V-34 is largely surpassed by the VX-32, however with its high calibre rounds and good rate of fire, it cannot be underestimated."

	suit_store = /obj/item/weapon/gun/rifle/som_carbine/mag_harness
	belt = /obj/item/storage/belt/marine/som/carbine

	backpack_contents = list(
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/ammo_magazine/pistol/som = 2,
		/obj/item/weapon/gun/pistol/som/standard = 1,
		/obj/item/ammo_magazine/rifle/mpi_km/carbine = 1,
		/obj/item/tool/extinguisher = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 4,
		/obj/item/explosive/grenade/incendiary/som = 1,
	)

/datum/outfit/quick/som/veteran/culverin
	name = "Culverin Veteran Machinegunner"
	desc = "Heavily armored heavy firesupport. Equipped with a volkite culverin and self charging backpack power unit, and a shotgun sidearm. The culverin is the most powerful man portable weapon the SOM have been seen to field. Capabable of laying down a tremendous barrage of firepower for extended periods of time. Although the back-mounted powerpack is self charging, it cannot keep up with the immense power requirements of the gun, so sustained, prolonged use can degrade the weapon's effectiveness greatly."
	quantity = 2

	belt = /obj/item/weapon/gun/shotgun/double/sawn
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/culverin/magharness
	back = /obj/item/cell/lasgun/volkite/powerpack

	webbing_contents = list(
		/obj/item/ammo_magazine/handful/buckshot = 3,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/storage/box/MRE/som = 1,
	)


/datum/outfit/quick/som/veteran/rocket_man
	name = "V-71 Rocket Veteran"
	desc = "War crimes have never been so easy. Equipped with a V-71 RPG and both incendiary and rad warheads, as well as a V-21 submachine gun with radioactive ammunition, heavy armor with a 'Mithridatius' environmental protection system, and rad grenades. Designed to inspire fear in the enemy and cripple them with deadly incendiary and radiological effects, providing excellent anti infantry support."
	quantity = 2

	head = /obj/item/clothing/head/modular/som/bio
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/mithridatius
	suit_store = /obj/item/weapon/gun/smg/som/support
	belt = /obj/item/storage/belt/marine/som
	back = /obj/item/storage/holster/backholster/rpg/som/war_crimes
	l_pocket = /obj/item/storage/pouch/grenade/som

	belt_contents = list(
		/obj/item/ammo_magazine/smg/som = 2,
		/obj/item/ammo_magazine/smg/som/rad = 4,
	)

	webbing_contents = list(
		/obj/item/ammo_magazine/packet/p10x20mm = 1,
		/obj/item/ammo_magazine/smg/som/incendiary = 1,
		/obj/item/binoculars = 1,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/storage/box/MRE/som = 1,
	)

	l_pocket_contents = list(
		/obj/item/explosive/grenade/smokebomb/satrapine = 3,
		/obj/item/explosive/grenade/rad = 3,
	)

/datum/outfit/quick/som/veteran/blinker
	name = "Blink Assault Veteran"
	desc = "Shock melee assault class. Equipped with a blink drive and energy sword, light armor and a backup burstfire V-11. The blink drive allows for short range teleports at some risk to the user, but allows them to effortless close the distance to cut down enemies when used correctly."
	quantity = 2

	wear_suit = /obj/item/clothing/suit/modular/som/light/shield
	belt = /obj/item/storage/holster/belt/pistol/m4a3/som
	suit_store = /obj/item/weapon/energy/sword/som
	back = /obj/item/blink_drive

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 3,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/storage/box/MRE/som = 1,
	)

	belt_contents = list(
		/obj/item/weapon/gun/pistol/som/burst = 1,
		/obj/item/ammo_magazine/pistol/som/extended = 6,
	)


//Base SOM leader outfit
/datum/outfit/quick/som/squad_leader
	name = "SOM Squad Leader"
	jobtype = "SOM Squad Leader"

	ears = /obj/item/radio/headset/mainship/som
	w_uniform = /obj/item/clothing/under/som/leader/webbing
	shoes = /obj/item/clothing/shoes/marine/som/knife
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/leader/valk
	gloves = /obj/item/clothing/gloves/marine/som/veteran
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/som/leader
	glasses = /obj/item/clothing/glasses/hud/health
	r_pocket = /obj/item/storage/pouch/firstaid/som/combat_patrol_leader
	l_pocket = /obj/item/storage/pouch/grenade/som/combat_patrol
	back = /obj/item/storage/backpack/satchel/som

	suit_contents = list(
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/isotonic = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
	)


/datum/outfit/quick/som/squad_leader/standard_assaultrifle
	name = "V-31 Squad Leader"
	desc = "Tactical utility. Equipped with a V-31 assault rifle with integrated 'micro grenade' rail launcher, Gorgon heavy armor with 'Valkyrie' autodoctor module, a large variety of grenades as well as AP ammunition. Excellent performance against heavily armored targets, while the plentiful grenade provide greater tactical flexibility."

	back = /obj/item/storage/backpack/lightpack/som
	suit_store = /obj/item/weapon/gun/rifle/som/veteran
	belt = /obj/item/storage/belt/marine/som/som_rifle_ap

	backpack_contents = list(
		/obj/item/explosive/plastique = 3,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta = 1,
		/obj/item/ammo_magazine/rifle/som/ap = 2,
		/obj/item/ammo_magazine/handful/micro_grenade = 1,
		/obj/item/ammo_magazine/handful/micro_grenade/dragonbreath = 2,
		/obj/item/ammo_magazine/handful/micro_grenade/cluster = 2,
		/obj/item/ammo_magazine/handful/micro_grenade/smoke_burst = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 2,
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/cell/lasgun/volkite/small = 1,
		/obj/item/binoculars/fire_support/campaign/som = 1,
	)

/datum/outfit/quick/som/squad_leader/standard_smg
	name = "V-21 Squad Leader"
	desc = "Close range high damage, high speed. Equipped with a V-21 submachine gun with variable firerate allowing for extreme rates of fire when properly wielded, Gorgon heavy armor with 'Valkyrie' autodoctor module, a good variety of grenades and AP ammunition. Allows for excellent close to medium range firepower, especially against heavily armored targets, and is surprisingly mobile."

	suit_store = /obj/item/weapon/gun/smg/som/veteran
	belt = /obj/item/storage/belt/marine/som/som_smg_ap

	backpack_contents = list(
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta = 1,
		/obj/item/cell/lasgun/volkite/small = 1,
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/explosive/plastique = 2,
		/obj/item/ammo_magazine/smg/som/ap = 1,
		/obj/item/ammo_magazine/smg/som/incendiary = 2,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 3,
		/obj/item/explosive/grenade/flashbang/stun = 1,
		/obj/item/binoculars/fire_support/campaign/som = 1,
	)


/datum/outfit/quick/som/squad_leader/charger
	name = "Charger Squad Leader"
	desc = "For the leader that prefers to be up close and personal. Equipped with a volkite charger with motion sensor and gyrostabiliser for better one handed use, Gorgon heavy armor with 'Valkyrie' autodoctor module and a good variety of grenades. Allows for excellent close to medium range firepower, with first rate survivability. Very dangerous."

	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/scout
	belt = /obj/item/storage/belt/marine/som/volkite

	backpack_contents = list(
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta = 1,
		/obj/item/cell/lasgun/volkite/small = 1,
		/obj/item/tool/extinguisher = 1,
		/obj/item/explosive/plastique = 1,
		/obj/item/cell/lasgun/volkite = 2,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 2,
		/obj/item/binoculars/fire_support/campaign/som = 1,
		/obj/item/explosive/grenade/flashbang/stun = 1,
		/obj/item/storage/box/MRE/som = 1,
	)


/datum/outfit/quick/som/squad_leader/caliver
	name = "Caliver Squad Leader"
	desc = "Victory through superior firepower. Equipped with a volkite caliver and motion sensor, Gorgon heavy armor with 'Valkyrie' autodoctor module and a good variety of grenades. Allows for excellent damage at all ranges, with first rate survivability. Very dangerous."

	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/tacsensor
	belt = /obj/item/storage/belt/marine/som/volkite

	backpack_contents = list(
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta = 1,
		/obj/item/cell/lasgun/volkite/small = 1,
		/obj/item/tool/extinguisher = 1,
		/obj/item/explosive/plastique = 1,
		/obj/item/cell/lasgun/volkite = 2,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 2,
		/obj/item/binoculars/fire_support/campaign/som = 1,
		/obj/item/explosive/grenade/flashbang/stun = 1,
		/obj/item/storage/box/MRE/som = 1,
	)


/datum/outfit/quick/som/squad_leader/mpi
	name = "MPI_KM Squad Leader"
	desc = "For the leader with a taste for nostalgia. Equipped with an MPI_KM assault rifle, with under barrel grenade launcher, Gorgon heavy armor with 'Valkyrie' autodoctor module and a large supply of grenades. An old weapon that was a common sight during the original Martian rebellion, the MPI's good stopping power, reliability and a healthy dose of nostalgia means it is still seen in use by some among the SOM despite its age."

	suit_store = /obj/item/weapon/gun/rifle/mpi_km/grenadier
	belt = /obj/item/storage/belt/marine/som/mpi_plum

	backpack_contents = list(
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta = 1,
		/obj/item/cell/lasgun/volkite/small = 2,
		/obj/item/ammo_magazine/rifle/mpi_km/extended = 1,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/explosive/plastique = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 4,
		/obj/item/binoculars/fire_support/campaign/som = 1,
	)
