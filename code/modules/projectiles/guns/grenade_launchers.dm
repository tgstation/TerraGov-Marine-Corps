/*
This file contains:
The Grenade Launchers
*/

//GRENADE LAUNCHERS

/obj/item/weapon/gun/grenade_launcher
	w_class = WEIGHT_CLASS_BULKY
	gun_skill_category = GUN_SKILL_FIREARMS
	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	reciever_flags = NONE
	throw_speed = 2
	throw_range = 10
	force = 5
	caliber = CALIBER_40MM //codex
	load_method = SINGLE_CASING //codex
	fire_sound = 'sound/weapons/guns/fire/grenadelauncher.ogg'
	fire_rattle = 'sound/weapons/guns/fire/grenadelauncher.ogg'
	cocked_sound = 'sound/weapons/guns/interact/m92_cocked.ogg'
	general_codex_key = "explosive weapons"
	default_ammo_type = /obj/item/explosive/grenade

	allowed_ammo_types = list(
		/obj/item/explosive/grenade,
		/obj/item/explosive/grenade/training,
		/obj/item/explosive/grenade/PMC,
		/obj/item/explosive/grenade/m15,
		/obj/item/explosive/grenade/stick,
		/obj/item/explosive/grenade/upp,
		/obj/item/explosive/grenade/sectoid,
		/obj/item/explosive/grenade/incendiary,
		/obj/item/explosive/grenade/incendiary/molotov,
		/obj/item/explosive/grenade/smokebomb,
		/obj/item/explosive/grenade/smokebomb/cloak,
		/obj/item/explosive/grenade/smokebomb/drain,
		/obj/item/explosive/grenade/phosphorus,
		/obj/item/explosive/grenade/phosphorus/upp,
		/obj/item/explosive/grenade/impact,
		/obj/item/explosive/grenade/sticky,
		/obj/item/explosive/grenade/flare,
		/obj/item/explosive/grenade/flare/cas,
		/obj/item/explosive/grenade/chem_grenade,
		/obj/item/explosive/grenade/chem_grenade/large,
		/obj/item/explosive/grenade/chem_grenade/metalfoam,
		/obj/item/explosive/grenade/chem_grenade/razorburn_smol,
		/obj/item/explosive/grenade/chem_grenade/razorburn_large,
		/obj/item/explosive/grenade/chem_grenade/incendiary,
		/obj/item/explosive/grenade/chem_grenade/teargas,
	)
	reciever_flags = NONE

	///the maximum range the launcher can fling the grenade, by default 15 tiles
	var/max_range = 15

/obj/item/weapon/gun/grenade_launcher/able_to_fire(mob/user)
	. = ..()
	if(!.)
		return FALSE
	if(get_dist(target, gun_user) <= 2)
		to_chat(gun_user, span_warning("[src] beeps a warning noise. You are too close!"))
		return FALSE


/obj/item/weapon/gun/grenade_launcher/do_fire(obj/object_to_fire)
	if(!istype(object_to_fire, /obj/item/explosive/grenade))
		return FALSE
	var/obj/item/explosive/grenade/grenade_to_launch = object_to_fire
	var/turf/user_turf = get_turf(src)
	grenade_to_launch.forceMove(user_turf)
	gun_user?.visible_message(span_danger("[gun_user] fired a grenade!"), span_warning("You fire [src]!"))
	log_explosion("[key_name(gun_user)] fired a grenade ([grenade_to_launch]) from [src] at [AREACOORD(user_turf)].")
	log_combat(gun_user, src, "fired a grenade ([grenade_to_launch]) from [src]")
	play_fire_sound(loc)
	grenade_to_launch.det_time = min(10, grenade_to_launch.det_time)
	grenade_to_launch.launched = TRUE
	grenade_to_launch.activate(gun_user)
	grenade_to_launch.throwforce += grenade_to_launch.launchforce
	grenade_to_launch.throw_at(target, max_range, 3, (gun_user ? gun_user : loc))
	if(fire_animation)
		flick("[fire_animation]", src)
	return TRUE

/obj/item/weapon/gun/grenade_launcher/get_ammo_list()
	if(!in_chamber)
		return ..()
	var/obj/item/explosive/grenade/grenade = in_chamber
	return list(grenade.hud_state, grenade.hud_state_empty)

//-------------------------------------------------------
//GL-70 Grenade Launcher.

/obj/item/weapon/gun/grenade_launcher/multinade_launcher
	name = "\improper GL-70 grenade launcher"
	desc = "The GL-70 is the standard grenade launcher used by the TerraGov Marine Corps for area denial and big explosions."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "t70"
	item_state = "t70"
	fire_animation = "t70_fire"
	flags_equip_slot = ITEM_SLOT_BACK
	max_shells = 6 //codex
	wield_delay = 1 SECONDS
	fire_sound = 'sound/weapons/guns/fire/underbarrel_grenadelauncher.ogg'
	fire_rattle = 'sound/weapons/guns/fire/underbarrel_grenadelauncher.ogg'
	aim_slowdown = 1.2
	attachable_allowed = list(
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/stock/t70stock,
	)
	starting_attachment_types = list(/obj/item/attachable/stock/t70stock)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 14, "rail_y" = 22, "under_x" = 19, "under_y" = 14, "stock_x" = 11, "stock_y" = 12)
	fire_delay = 1.2 SECONDS
	max_chamber_items = 5


/obj/item/weapon/gun/grenade_launcher/underslung
	name = "underslung grenade launcher"
	desc = "A weapon-mounted, reloadable, two-shot grenade launcher."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "grenade"
	max_shells = 2 //codex
	max_chamber_items = 1
	fire_delay = 1 SECONDS
	fire_sound = 'sound/weapons/guns/fire/underbarrel_grenadelauncher.ogg'
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 14, "rail_y" = 22, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	attachable_allowed = list()
	max_range = 7

	slot = ATTACHMENT_SLOT_UNDER
	attach_delay = 3 SECONDS
	detach_delay = 3 SECONDS
	flags_gun_features = GUN_AMMO_COUNTER|GUN_IS_ATTACHMENT|GUN_ATTACHMENT_FIRE_ONLY|GUN_WIELDED_STABLE_FIRING_ONLY|GUN_WIELDED_FIRING_ONLY
	pixel_shift_x = 14
	pixel_shift_y = 18
	allowed_ammo_types = list(
		/obj/item/explosive/grenade,
		/obj/item/explosive/grenade/training,
		/obj/item/explosive/grenade/stick,
		/obj/item/explosive/grenade/upp,
		/obj/item/explosive/grenade/incendiary,
		/obj/item/explosive/grenade/incendiary/molotov,
		/obj/item/explosive/grenade/smokebomb,
		/obj/item/explosive/grenade/smokebomb/cloak,
		/obj/item/explosive/grenade/smokebomb/drain,
		/obj/item/explosive/grenade/phosphorus,
		/obj/item/explosive/grenade/phosphorus/upp,
		/obj/item/explosive/grenade/flare,
		/obj/item/explosive/grenade/flare/cas,
		/obj/item/explosive/grenade/impact,
		/obj/item/explosive/grenade/sticky,
	)

	wield_delay_mod	= 0.2 SECONDS

/obj/item/weapon/gun/grenade_launcher/underslung/invisible
	flags_attach_features = NONE

/obj/item/weapon/gun/grenade_launcher/single_shot
	name = "\improper GL-81 grenade launcher"
	desc = "A lightweight, single-shot grenade launcher used by the TerraGov Marine Corps for area denial and big explosions."
	icon_state = "m81"
	item_state = "m81"
	max_shells = 1 //codex
	flags_equip_slot = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	wield_delay = 0.2 SECONDS
	aim_slowdown = 1
	flags_gun_features = GUN_AMMO_COUNTER
	attachable_allowed = list()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 14, "rail_y" = 22, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	fire_delay = 1.05 SECONDS
	max_chamber_items = 0
	max_range = 10


/obj/item/weapon/gun/grenade_launcher/single_shot/riot
	name = "\improper GL-81 riot grenade launcher"
	desc = "A lightweight, single-shot grenade launcher to launch tear gas grenades. Used by Nanotrasen security during riots."
	default_ammo_type = null
	allowed_ammo_types = list(/obj/item/explosive/grenade/chem_grenade)
	req_access = list(ACCESS_MARINE_BRIG)

/obj/item/weapon/gun/grenade_launcher/single_shot/flare
	name = "flare gun"
	desc = "A gun that fires flares. Replace with flares. Simple! Equipped with long range irons."
	icon_state = "flaregun"
	item_state = "gun"
	fire_sound = 'sound/weapons/guns/fire/flare.ogg'
	fire_sound = 'sound/weapons/guns/fire/flare.ogg'
	w_class = WEIGHT_CLASS_TINY
	flags_gun_features = NONE
	gun_skill_category = GUN_SKILL_PISTOLS
	fire_delay = 0.5 SECONDS
	default_ammo_type = /obj/item/explosive/grenade/flare
	allowed_ammo_types = list(/obj/item/explosive/grenade/flare, /obj/item/explosive/grenade/flare/cas)
	attachable_allowed = list(/obj/item/attachable/scope/unremovable/flaregun)
	starting_attachment_types = list(/obj/item/attachable/scope/unremovable/flaregun)

/obj/item/weapon/gun/grenade_launcher/single_shot/flare/marine
	name = "M30E2 flare gun"
	desc = "A very tiny flaregun that fires flares equipped with long range irons, the mass amounts of markings on the back and barrel denote it as owned by the TGMC."
	icon_state = "marine_flaregun"
