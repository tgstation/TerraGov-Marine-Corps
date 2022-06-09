///box for storage of ammo and gun
/obj/item/storage/box/tl102
	name = "\improper HSG-102 crate"
	desc = "A large and rusted metal case. It has not seen much use. Written in faded letters on its top, it says, \"This is a HSG-102 heavy smartgun\". There are many other warning labels atop that are too faded to read."
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

///HSG-102, now with full auto. It is not a superclass of deployed guns, however there are a few varients.
/obj/item/weapon/gun/tl102
	name = "\improper HSG-102 mounted heavy smartgun"
	desc = "The HSG-102 heavy machinegun, it's too heavy to be wielded or operated without the tripod. IFF capable. No extra work required, just deploy it with Ctrl-Click. Can be repaired with a blowtorch once deployed."

	w_class = WEIGHT_CLASS_HUGE
	flags_equip_slot = ITEM_SLOT_BACK
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "turret"

	fire_sound = 'sound/weapons/guns/fire/hmg2.ogg'
	reload_sound = 'sound/weapons/guns/interact/minigun_cocked.ogg'

	default_ammo_type = /obj/item/ammo_magazine/tl102

	scatter = 10
	deployed_scatter_change = -10
	fire_delay = 0.25 SECONDS

	burst_amount = 3
	burst_delay = 0.1 SECONDS
	extra_delay = 1 SECONDS
	accuracy_mult = 1.2 //it's got a bipod
	burst_accuracy_mult = 2
	burst_scatter_mult = 0

	flags_item = IS_DEPLOYABLE|TWOHANDED
	flags_gun_features = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY|GUN_IFF
	gun_firemode_list = list(GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC)

	attachable_allowed = list(
		/obj/item/attachable/scope/unremovable/tl102,
	)

	starting_attachment_types = list(
		/obj/item/attachable/scope/unremovable/tl102,
	)

	allowed_ammo_types = list(
		/obj/item/ammo_magazine/tl102,
	)

	deploy_time = 5 SECONDS
	undeploy_time = 3 SECONDS
	deployed_item = /obj/machinery/deployable/mounted

	max_integrity = 200
	soft_armor = list("melee" = 0, "bullet" = 50, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 0, "acid" = 0)

///Unmovable ship mounted version.
/obj/item/weapon/gun/tl102/hsg_nest
	name = "\improper HSG-102 heavy smartgun nest"
	desc = "A HSG-102 heavy smartgun mounted upon a small reinforced post with sandbags to provide a small machinegun nest for all your defense purpose needs.</span>"
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "entrenched"

	default_ammo_type = /obj/item/ammo_magazine/tl102/hsg_nest

	attachable_allowed = list(/obj/item/attachable/scope/unremovable/tl102/nest)
	starting_attachment_types = list(
		/obj/item/attachable/scope/unremovable/tl102/nest,
	)

	allowed_ammo_types = list(
		/obj/item/ammo_magazine/tl102,
		/obj/item/ammo_magazine/tl102/hsg_nest,
	)
	flags_item =  IS_DEPLOYABLE|TWOHANDED|DEPLOYED_NO_PICKUP|DEPLOY_ON_INITIALIZE

///This is my meme version, the first version of the HSG-102 to have auto-fire, revel in its presence.
/obj/item/weapon/gun/tl102/death
	name = "\improper \"Death incarnate\" heavy machine gun"
	desc = "It looks like a regular HSG-102, however glowing archaeic writing glows faintly on its sides and top. It beckons for blood."
	icon = 'icons/Marine/marine-hmg.dmi'

	aim_slowdown = 3
	scatter = 30
	deployed_scatter_change = -27

	fire_delay = 0.5
	burst_amount = 3
	burst_delay = 0.1 SECONDS

	aim_slowdown = 3
	wield_delay = 5 SECONDS

	flags_gun_features = GUN_AMMO_COUNTER|GUN_IFF

// This is a deployed IFF-less MACHINEGUN, has 500 rounds, drums do not fit anywhere but your belt slot and your back slot. But it has 500 rounds. That's nice.

/obj/item/weapon/gun/heavymachinegun
	name = "\improper HMG-08 heavy machinegun"
	desc = "An absolute monster of a weapon, this is a watercooled heavy machinegun modernized by some crazy armorer with a wheeling kit included. Considering the mish mash of parts for the wheeling kit, you think its from another model of the gun. The pinnacle at holding a chokepoint. Holds 500 rounds of 10x28mm caseless in a box case. IS NOT IFF CAPABLE. Aiming carefully recommended. Can be repaired with a blowtorch once deployed. Alt Right click to unanchor and reanchor it."

	w_class = WEIGHT_CLASS_HUGE
	flags_equip_slot = ITEM_SLOT_BACK
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "mg08"

	fire_sound = 'sound/weapons/guns/fire/mg08.ogg'
	reload_sound = 'sound/weapons/guns/interact/minigun_cocked.ogg'
	caliber = CALIBER_10X28

	default_ammo_type = /obj/item/ammo_magazine/heavymachinegun
	allowed_ammo_types = list(/obj/item/ammo_magazine/heavymachinegun)

	scatter = 10
	deployed_scatter_change = -8
	fire_delay = 0.2 SECONDS
	accuracy_mult = 1.1 //it's mounted

	burst_amount = 1

	flags_item = IS_DEPLOYABLE|TWOHANDED
	flags_gun_features = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)

	attachable_allowed = list(
		/obj/item/attachable/scope/unremovable/heavymachinegun,
	)

	starting_attachment_types = list(
		/obj/item/attachable/scope/unremovable/heavymachinegun,
	)

	deploy_time = 8 SECONDS
	undeploy_time = 3 SECONDS
	deployed_item = /obj/machinery/deployable/mounted/moveable

	max_integrity = 200
	soft_armor = list("melee" = 0, "bullet" = 50, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 0, "acid" = 0)



//-------------------------------------------------------
//MG-27 Medium Machine Gun

/obj/item/weapon/gun/standard_mmg
	name = "\improper MG-27 medium machinegun"
	desc = "The MG-27 is the SG-29s aging IFF-less cousin, made for rapid accurate machinegun fire in a short amount of time, you could use it while standing, not a great idea. Use the tripod for actual combat. It uses 10x27mm boxes."
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
	default_ammo_type = /obj/item/ammo_magazine/standard_mmg
	allowed_ammo_types = list(/obj/item/ammo_magazine/standard_mmg)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/heavy_barrel,
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
	attachable_offset = list("muzzle_x" = 45, "muzzle_y" = 19,"rail_x" = 18, "rail_y" = 24, "under_x" = 28, "under_y" = 13, "stock_x" = 0, "stock_y" = 0)

	flags_item = IS_DEPLOYABLE|TWOHANDED
	flags_gun_features = GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY
	deployed_item = /obj/machinery/deployable/mounted
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.1 SECONDS
	aim_speed_modifier = 5
	soft_armor = list("melee" = 0, "bullet" = 50, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 0, "acid" = 0)


	scatter = 30 // you're not firing this standing.
	deployed_scatter_change = -70 // innumerable amount of reduced scatter when deployed,
	recoil = 2
	scatter_unwielded = 45
	accuracy_mult = 1.1 //it's got a bipod
	fire_delay = 0.15 SECONDS
	burst_amount = 1
	deploy_time = 1 SECONDS
	undeploy_time = 0.5 SECONDS
	max_integrity = 200

//-------------------------------------------------------
//AT-36 Anti Tank Gun

/obj/item/weapon/gun/standard_atgun
	name = "\improper AT-36 anti tank gun"
	desc = "The AT-36 is a light dual purpose anti tank and anti personnel weapon used by the TGMC. Used for light vehicle or bunker busting on a short notice. Best used by two people. It can move around with wheels, and has an ammo rack intergral to the weapon. CANNOT BE UNDEPLOYED ONCE DEPLOYED! It uses several types of 37mm shells boxes. Alt-right click on it to anchor it so that it cannot be moved by anyone, then alt-right click again to move it."
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/Marine/marine-atgun.dmi'
	icon_state = "tat36"
	item_state = "tat36"
	caliber = CALIBER_37MM // codex
	max_shells = 1 //codex
	fire_sound = 'sound/weapons/guns/fire/tat36.ogg'
	reload_sound = 'sound/weapons/guns/interact/tat36_reload.ogg'
	default_ammo_type = /obj/item/ammo_magazine/standard_atgun
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/standard_atgun,
		/obj/item/ammo_magazine/standard_atgun/apcr,
		/obj/item/ammo_magazine/standard_atgun/he,
	)
	attachable_offset = list("muzzle_x" = 45, "muzzle_y" = 20,"rail_x" = 18, "rail_y" = 22, "under_x" = 28, "under_y" = 13, "stock_x" = 0, "stock_y" = 0)
	starting_attachment_types = list(/obj/item/attachable/scope/unremovable/standard_atgun)
	attachable_allowed = list(/obj/item/attachable/scope/unremovable/standard_atgun)

	flags_item = IS_DEPLOYABLE|TWOHANDED|DEPLOYED_NO_PICKUP|DEPLOY_ON_INITIALIZE
	flags_gun_features = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY

	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_time = 6 SECONDS
	reciever_flags = AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_AUTO_EJECT
	soft_armor = list("melee" = 60, "bullet" = 50, "laser" = 0, "energy" = 0, "bomb" = 80, "bio" = 100, "rad" = 0, "fire" = 0, "acid" = 0)

	scatter = 0
	recoil = 3
	fire_delay = 3 SECONDS
	burst_amount = 1
	undeploy_time = 2000 SECONDS
	max_integrity = 500
	deployed_item = /obj/machinery/deployable/mounted/moveable/atgun

/obj/machinery/deployable/mounted/moveable/atgun
	var/obj/item/storage/internal/ammo_rack/sponson = /obj/item/storage/internal/ammo_rack
	resistance_flags = XENO_DAMAGEABLE|UNACIDABLE

/obj/item/storage/internal/ammo_rack
	storage_slots = 10
	max_storage_space = 40
	max_w_class = WEIGHT_CLASS_BULKY
	can_hold = list(/obj/item/ammo_magazine/standard_atgun)

/obj/machinery/deployable/mounted/moveable/atgun/Initialize()
	. = ..()
	sponson = new sponson(src)

/obj/machinery/deployable/mounted/moveable/atgun/attack_hand_alternate(mob/living/user)
	return sponson.open(user)

/obj/item/storage/internal/ammo_rack/handle_mousedrop(mob/user, obj/over_object)
	if(!ishuman(user) || user.lying_angle || user.incapacitated())
		return FALSE

	if(over_object == user && Adjacent(user)) //This must come before the screen objects only block
		open(user)
		return FALSE

/obj/machinery/deployable/mounted/moveable/atgun/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(800)
		if(EXPLODE_HEAVY)
			take_damage(rand(150, 200))
		if(EXPLODE_LIGHT)
			take_damage(rand(10, 50))

