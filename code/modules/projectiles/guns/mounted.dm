
//I didnt know where else to put this, so Im bringing it from the deleted smartgun_mount.dm
/obj/item/coin/marine/engineer
	name = "marine engineer support token"
	desc = "Insert this into a engineer vendor in order to access a support artillery weapon."
	flags_token = TOKEN_ENGI

///box for storage of ammo and gun
/obj/item/storage/box/tl102
	name = "\improper TL-102 crate"
	desc = "A large and rusted metal case. It has not seen much use. Written in faded letters on its top, it says, \"This is a TL-102 heavy smartgun\". There are many other warning labels atop that are too faded to read."
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "crate"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 7
	bypass_w_limit = list(
		/obj/item/weapon/gun/tl102,
		/obj/item/ammo_magazine/tl102,
	)

/obj/item/storage/box/tl102/Initialize()
	. = ..()
	new /obj/item/weapon/gun/tl102(src) //gun itself
	new /obj/item/ammo_magazine/tl102(src) //ammo for the gun

///TL-102, now with full auto. It is not a superclass of deployed guns, however there are a few varients.
/obj/item/weapon/gun/tl102
	name = "\improper TL-102 mounted heavy smartgun"
	desc = "The TL-102 heavy machinegun, it's too heavy to be wielded or operated without the tripod. IFF capable. No extra work required, just deploy it with Ctrl-Click. Can be repaired with a blowtorch once deployed."

	w_class = WEIGHT_CLASS_HUGE
	flags_equip_slot = ITEM_SLOT_BACK
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "turret"

	fire_sound = 'sound/weapons/guns/fire/hmg2.ogg'
	reload_sound = 'sound/weapons/guns/interact/minigun_cocked.ogg'

	current_mag = /obj/item/ammo_magazine/tl102

	scatter = 20
	fire_delay = 0.25 SECONDS

	burst_amount = 3
	burst_delay = 0.1 SECONDS
	extra_delay = 1 SECONDS
	burst_accuracy_mult = 2
	burst_scatter_mult = -2

	flags_item = IS_DEPLOYABLE|TWOHANDED
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY|GUN_IFF
	gun_firemode_list = list(GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC)

	attachable_allowed = list(
		/obj/item/attachable/scope/unremovable/tl102,
	)

	starting_attachment_types = list(
		/obj/item/attachable/scope/unremovable/tl102,
	)

	deploy_time = 5 SECONDS
	undeploy_time = 3 SECONDS

	max_integrity = 125
	soft_armor = list("melee" = 0, "bullet" = 50, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 0, "acid" = 0)

///This and get_ammo_count is to make sure the ammo counter functions.
/obj/item/weapon/gun/tl102/get_ammo_type()
	if(!ammo)
		return list("unknown", "unknown")
	return list(ammo.hud_state, ammo.hud_state_empty)

/obj/item/weapon/gun/tl102/get_ammo_count()
	if(!current_mag)
		return in_chamber ? 1 : 0
	return in_chamber ? (current_mag.current_rounds + 1) : current_mag.current_rounds

///Unmovable ship mounted version.
/obj/item/weapon/gun/tl102/hsg_nest
	name = "\improper TL-102 heavy smartgun nest"
	desc = "A TL-102 heavy smartgun mounted upon a small reinforced post with sandbags to provide a small machinegun nest for all your defense purpose needs.</span>"
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "entrenched"

	current_mag = /obj/item/ammo_magazine/tl102/hsg_nest

	attachable_allowed = list(/obj/item/attachable/scope/unremovable/tl102/nest)
	starting_attachment_types = list(
		/obj/item/attachable/scope/unremovable/tl102/nest,
	)

	flags_item =  IS_DEPLOYABLE|TWOHANDED|DEPLOYED_NO_PICKUP|DEPLOY_ON_INITIALIZE

///This is my meme version, the first version of the TL-102 to have auto-fire, revel in its presence.
/obj/item/weapon/gun/tl102/death
	name = "\improper \"Death incarnate\" heavy machine gun"
	desc = "It looks like a regular TL-102, however glowing archaeic writing glows faintly on its sides and top. It beckons for blood."
	icon = 'icons/Marine/marine-hmg.dmi'

	aim_slowdown = 3
	scatter = 30

	fire_delay = 0.5
	burst_amount = 3
	burst_delay = 0.1

	aim_slowdown = 3
	wield_delay = 5 SECONDS

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER|GUN_IFF

// This is a deployed IFF-less MACHINEGUN, has 500 rounds, drums do not fit anywhere but your belt slot and your back slot. But it has 500 rounds. That's nice.

/obj/item/weapon/gun/heavymachinegun
	name = "\improper MG-08/495 heavy machinegun"
	desc = "An absolute monster of a weapon, this is a watercooled heavy machinegun modernized by some crazy armorer. The pinnacle at holding a chokepoint. Holds 500 rounds of 10x28mm caseless in a box case. IS NOT IFF CAPABLE. Aiming carefully recommended. Can be repaired with a blowtorch once deployed."

	w_class = WEIGHT_CLASS_HUGE
	flags_equip_slot = ITEM_SLOT_BACK
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "mg08"

	fire_sound = 'sound/weapons/guns/fire/mg08.ogg'
	reload_sound = 'sound/weapons/guns/interact/minigun_cocked.ogg'
	caliber = CALIBER_10X28

	current_mag = /obj/item/ammo_magazine/heavymachinegun


	scatter = 25
	fire_delay = 0.2 SECONDS

	burst_amount = 1

	flags_item = IS_DEPLOYABLE|TWOHANDED
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)

	attachable_allowed = list(
		/obj/item/attachable/scope/unremovable/heavymachinegun,
	)

	starting_attachment_types = list(
		/obj/item/attachable/scope/unremovable/heavymachinegun,
	)

	deploy_time = 8 SECONDS
	undeploy_time = 3 SECONDS

	max_integrity = 150
	soft_armor = list("melee" = 0, "bullet" = 50, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 0, "acid" = 0)



//-------------------------------------------------------
//T-27 Medium Machine Gun

/obj/item/weapon/gun/standard_mmg
	name = "\improper T-27 medium machinegun"
	desc = "The T-27 is the T-29s aging IFF-less cousin, made for rapid accurate machinegun fire in a short amount of time, you could use it while standing, not a great idea. Use the tripod for actual combat. It uses 10x27mm boxes."
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/Marine/marine-mmg.dmi'
	icon_state = "t27"
	item_state = "t27"
	caliber = CALIBER_10X25_CASELESS // codex
	max_shells = 100 //codex
	force = 40
	aim_slowdown = 1.2
	wield_delay = 2 SECONDS
	fire_sound =  'sound/weapons/guns/fire/t27.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/T42_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/T42_reload.ogg'
	current_mag = /obj/item/ammo_magazine/standard_mmg
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/stock/irremoveable/t27,
	)

	starting_attachment_types = list(/obj/item/attachable/stock/irremoveable/t27)
	attachable_offset = list("muzzle_x" = 45, "muzzle_y" = 20,"rail_x" = 18, "rail_y" = 22, "under_x" = 28, "under_y" = 13, "stock_x" = 0, "stock_y" = 0)

	flags_item = IS_DEPLOYABLE|TWOHANDED
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER|GUN_WIELDED_FIRING_ONLY
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.1 SECONDS
	aim_speed_modifier = 5
	soft_armor = list("melee" = 0, "bullet" = 50, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 0, "acid" = 0)


	scatter = 80 // you're not firing this standing.
	deployed_scatter_change = -70 // innumerable amount of reduced scatter when deployed,
	recoil = 3
	scatter_unwielded = 85
	fire_delay = 0.15 SECONDS
	burst_amount = 1
	deploy_time = 1 SECONDS
	undeploy_time = 0.5 SECONDS
	max_integrity = 200
