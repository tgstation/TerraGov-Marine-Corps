#define HUNTER_GOOD_ITEM  pick(\
								200; /obj/item/weapon/claymore/mercsword/machete, \
								170; /obj/item/clothing/suit/armor/vest/security, \
								165; /obj/item/clothing/head/helmet/riot, \
								160; /obj/item/clothing/gloves/marine/veteran/PMC, \
								150; /obj/item/weapon/claymore/mercsword, \
								125; /obj/item/weapon/twohanded/fireaxe, \
								100; /obj/item/storage/backpack/commando, \
								100; /obj/item/storage/belt/knifepouch, \
								100; /obj/item/storage/belt/utility/full, \
								100; /obj/item/clothing/tie/storage/webbing, \
								100; /obj/item/weapon/claymore, \
								100; /obj/item/weapon/katana, \
								100; /obj/item/binoculars, \
								100; /obj/item/explosive/grenade/frag, \
								100; /obj/item/explosive/grenade/incendiary, \
								75; /obj/item/storage/box/wy_mre, \
								50; /obj/item/flash, \
								50; /obj/item/explosive/plastique, \
								50; /obj/item/weapon/shield/riot, \
								50; /obj/item/storage/firstaid/regular, \
								50; /obj/item/storage/firstaid/fire, \
								25; /obj/item/explosive/grenade/flashbang)

#define HUNTER_OKAY_ITEM  pick(\
								400; /obj/item/weapon/twohanded/spear, \
								300; /obj/item/tool/crowbar, \
								300; /obj/item/tool/hatchet, \
								200; /obj/item/weapon/baseballbat, \
								200; /obj/item/weapon/throwing_knife, \
								250; /obj/item/explosive/grenade/flare, \
								100; /obj/item/weapon/baseballbat/metal, \
								100; /obj/item/weapon/butterfly, \
								100; /obj/item/weapon/harpoon, \
								100; /obj/item/tool/scythe, \
								100; /obj/item/tool/kitchen/knife/butcher, \
								100; /obj/item/cell/high, \
								100; /obj/item/tool/wirecutters, \
								100; /obj/item/tool/weldingtool, \
								100; /obj/item/tool/wrench, \
								100; /obj/item/multitool, \
								100; /obj/item/storage/backpack, \
								100; /obj/item/storage/backpack/cultpack, \
								100; /obj/item/storage/backpack/satchel, \
								100; /obj/item/clothing/suit/storage/CMB, \
								75; /obj/item/storage/pill_bottle/tramadol, \
								75; /obj/item/weapon/combat_knife, \
								75; /obj/item/flashlight, \
								75; /obj/item/flashlight/combat, \
								75; /obj/item/stack/medical/bruise_pack, \
								75; /obj/item/stack/medical/ointment, \
								75; /obj/item/reagent_container/food/snacks/donkpocket, \
								75; /obj/item/clothing/gloves/brown, \
								50; /obj/item/weapon/katana/replica, \
								50; /obj/item/explosive/grenade/smokebomb, \
								50; /obj/item/explosive/grenade/empgrenade, \
								25; /obj/item/bananapeel, \
								25; /obj/item/tool/soap)

// names are for mapper ease of use only
/obj/effect/landmark/random_item
	icon_state = "random_loot"
	var/item_quality = NONE

/obj/effect/landmark/random_item/Initialize()
	. = ..()
	GLOB.landmarks_round_start += src

/obj/effect/landmark/random_item/Destroy()
	GLOB.landmarks_round_start -= src
	return ..()

/obj/effect/landmark/random_item/proc/spawn_item()
	return

/obj/effect/landmark/random_item/after_round_start(flags_round_type=NONE,flags_landmarks=NONE)
	if(flags_landmarks & MODE_LANDMARK_RANDOM_ITEMS)
		spawn_item()
	qdel(src)

/obj/effect/landmark/random_item/crap
	name = "Random Crap Item"
	item_quality = HG_RANDOM_ITEM_CRAP

/obj/effect/landmark/random_item/crap/spawn_item()
	var/typepath = HUNTER_OKAY_ITEM
	new typepath(loc)

/obj/effect/landmark/random_item/good
	name = "Random Good Item"
	item_quality = HG_RANDOM_ITEM_GOOD

/obj/effect/landmark/random_item/good/spawn_item()
	var/typepath = HUNTER_GOOD_ITEM
	new typepath(loc)

#undef HUNTER_GOOD_ITEM
#undef HUNTER_OKAY_ITEM
