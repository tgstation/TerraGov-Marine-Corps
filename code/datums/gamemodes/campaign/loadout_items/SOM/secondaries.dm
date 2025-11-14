/datum/loadout_item/secondary/gun/som
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_CORPSMAN, SOM_SQUAD_ENGINEER, SOM_SQUAD_LEADER, SOM_SQUAD_VETERAN, SOM_FIELD_COMMANDER)
	item_whitelist = list(
		/obj/item/storage/holster/belt/pistol/m4a3/som = ITEM_SLOT_BELT,
		/obj/item/storage/holster/belt/pistol/m4a3/som/fancy = ITEM_SLOT_BELT,
		/obj/item/storage/backpack/satchel/som = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/lightpack/som = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/marine/engineerpack/som = ITEM_SLOT_BACK,
	)
	req_desc = "Requires a pistol holster or some kind of back storage."

/datum/loadout_item/secondary/gun/som/standard_pistol
	name = "V-11"
	desc = "The standard sidearm used by the Sons of Mars. A reliable and simple weapon that is often seen on the export market on the outer colonies. \
	Typically chambered in 9mm armor piercing rounds."
	ui_icon = "v11"
	item_typepath = /obj/item/weapon/gun/pistol/som/standard
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_CORPSMAN, SOM_SQUAD_ENGINEER, SOM_SQUAD_VETERAN)

/datum/loadout_item/secondary/gun/som/extended_pistol
	name = "V-11e"
	desc = "The standard sidearm used by the Sons of Mars. A reliable and simple weapon that is often seen on the export market on the outer colonies. \
	Typically chambered in 9mm armor piercing rounds. This one is configures for burstfire, and loaded with extended mags."
	ui_icon = "v11"
	item_typepath = /obj/item/weapon/gun/pistol/som/burst
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_CORPSMAN, SOM_SQUAD_ENGINEER, SOM_SQUAD_VETERAN, SOM_SQUAD_LEADER, SOM_FIELD_COMMANDER)
	loadout_item_flags = NONE

/datum/loadout_item/secondary/gun/som/highpower
	name = "Highpower"
	desc = "A powerful semi-automatic pistol chambered in the devastating .50 AE caliber rounds. Used for centuries by law enforcement and criminals alike, recently recreated with this new model."
	ui_icon = "highpower"
	item_typepath = /obj/item/weapon/gun/pistol/highpower/standard
	loadout_item_flags = NONE

/datum/loadout_item/secondary/gun/som/serpenta
	name = "VX-12 Serpenta"
	desc = "The 'serpenta' is a volkite energy pistol typically seen in the hands of SOM officers and some NCOs, and is quite dangerous for it's size."
	ui_icon = "vx12"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta
	jobs_supported = list(SOM_SQUAD_LEADER, SOM_STAFF_OFFICER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/secondary/gun/som/serpenta_custom
	name = "VX-12c Serpenta"
	desc = "The 'serpenta' is a volkite energy pistol typically seen in the hands of SOM officers and some NCOs, and is quite dangerous for it's size. \
	This particular weapon appears to be a custom model with improved performance."
	ui_icon = "vx12"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta/custom
	jobs_supported = list(SOM_FIELD_COMMANDER, SOM_COMMANDER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/secondary/gun/som/sawn_off
	name = "Sawn-off shotgun"
	desc = "A double barreled shotgun whose barrel has been artificially shortened to reduce range for further CQC potiential. Extremely powerful at close range, but is very difficult to handle."
	ui_icon = "sshotgun"
	item_typepath = /obj/item/weapon/gun/shotgun/double/sawn
	jobs_supported = list(SOM_SQUAD_VETERAN)
	item_whitelist = list(
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/culverin/magharness = ITEM_SLOT_SUITSTORE,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/tacsensor = ITEM_SLOT_SUITSTORE,
	)
	req_desc = "Requires a VX-42 or VX-33P."

/datum/loadout_item/secondary/gun/som/sawn_off/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new item_typepath(wearer), SLOT_BELT)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun/buckshot, SLOT_L_HAND)
	default_load(wearer, loadout, holder)

/datum/loadout_item/secondary/esword
	name = "Energy sword"
	desc = "A SOM energy sword. Designed to cut through armored plate. An uncommon primary weapon, typically seen wielded by so called 'blink assault' troops. \
	Can be used defensively to great effect, mainly against opponents trying to strike you in melee, although some users report varying levels of success in blocking ranged projectiles."
	ui_icon = "machete"
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_ENGINEER, SOM_SQUAD_VETERAN, SOM_SQUAD_LEADER)
	item_typepath = /obj/item/weapon/energy/sword/som
	loadout_item_flags = NONE
	item_whitelist = null
	req_desc = null

/datum/loadout_item/secondary/esword/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new item_typepath(wearer), SLOT_BELT)
	if(!isstorageobj(wearer.back))
		return
	default_load(wearer, loadout, holder)

//kits
/datum/loadout_item/secondary/kit/he_nades/som
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_CORPSMAN, SOM_SQUAD_ENGINEER, SOM_SQUAD_LEADER, SOM_SQUAD_VETERAN, SOM_FIELD_COMMANDER)

/datum/loadout_item/secondary/kit/he_nades/som/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/binoculars/som
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_CORPSMAN, SOM_SQUAD_ENGINEER, SOM_SQUAD_VETERAN)

/datum/loadout_item/secondary/kit/binoculars/som/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars/fire_support/campaign/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/som_engineer
	jobs_supported = list(SOM_SQUAD_ENGINEER)

/datum/loadout_item/secondary/kit/som_engineer/sentry
	name = "COPE Sentry"
	desc = "A powerful sentry gun. Throw like a grenade to deploy."
	ui_icon = "sentry"
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/secondary/kit/som_engineer/sentry/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/som_engineer/large_mines
	name = "Claymores"
	desc = "Two large boxes of claymores. Mines are extremely effective for creating deadzones or setting up traps. Great on the defence."
	ui_icon = "claymore"

/datum/loadout_item/secondary/kit/som_engineer/large_mines/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/explosive_mines/large, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/explosive_mines/large, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/som_engineer/materials
	name = "Metal/plasteel"
	desc = "A full stack of metal and plasteel. For maximum construction."
	ui_icon = "materials"

/datum/loadout_item/secondary/kit/som_engineer/materials/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/large_stack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/som_engineer/probe
	name = "Probe"
	desc = "A deployable Seraphim's Eye probe, along with remote control. While lacking any weaponry, it is able to fly over enemy cades and scout their position. Capable of cloaking when not in motion. \
	WARNING: while fireproof, it is still fragile. Avoid explosions."
	purchase_cost = 15
	ui_icon = "default"

/datum/loadout_item/secondary/kit/som_engineer/probe/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/deployable_vehicle/tiny/martian, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/deployable_vehicle/tiny/martian, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/unmanned_vehicle_remote, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/som_engineer/detpack
	name = "Detpacks"
	desc = "Detpacks, for blowing things up."
	ui_icon = "default"

/datum/loadout_item/secondary/kit/som_engineer/detpack/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack/marine/engineerpack/som))
		wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	else
		wearer.equip_to_slot_or_del(new /obj/item/assembly/signaler, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/som_corpsman
	jobs_supported = list(SOM_SQUAD_CORPSMAN)

/datum/loadout_item/secondary/kit/som_corpsman/advanced
	name = "Advanced meds"
	desc = "A variety of advanced medical injectors including Russian Red, rezadone and Re-Grow, allowing for the treatment of cloneloss and missing limbs."
	ui_icon = "medkit"
	purchase_cost = 30

/datum/loadout_item/secondary/kit/som_corpsman/advanced/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/rezadone, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/regrow, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/antitox_mix, SLOT_IN_BACKPACK)
