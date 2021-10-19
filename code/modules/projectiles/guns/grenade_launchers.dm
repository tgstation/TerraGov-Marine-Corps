/*
This file contains: 
The Grenade Launchers
*/

//GRENADE LAUNCHERS

/obj/item/weapon/gun/grenade_launcher
	w_class = WEIGHT_CLASS_BULKY
	gun_skill_category = GUN_SKILL_FIREARMS
	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	throw_speed = 2
	throw_range = 10
	force = 5
	caliber = CALIBER_40MM //codex
	load_method = SINGLE_CASING //codex
	fire_sound = 'sound/weapons/guns/fire/grenadelauncher.ogg'
	fire_rattle = 'sound/weapons/guns/fire/grenadelauncher.ogg'
	cocked_sound = 'sound/weapons/guns/interact/m92_cocked.ogg'
	general_codex_key = "explosive weapons"
	///a list of the grenades in the chamber
	var/list/obj/item/explosive/grenade/grenades = list()
	///the maximum number of grenades the grenade launcher can hold
	var/max_grenades = 0
	///list of allowed grenade types
	var/list/grenade_type_allowed = list()
	///the maximum range the launcher can fling the grenade, by default 15 tiles
	var/max_range = 15

///proc that handles firing the grenade itself
/obj/item/weapon/gun/grenade_launcher/proc/fire_grenade(atom/target, mob/user)
	last_fired = world.time
	var/obj/item/explosive/grenade/grenade = grenades[1]
	var/turf/userturf = get_turf(user)
	if(!userturf)
		return
	grenades -= grenade
	grenade.loc = userturf
	user.visible_message(span_danger("[user] fired a grenade!"), span_warning("You fire [src]!"))
	log_explosion("[key_name(user)] fired a grenade ([grenade]) from [src] at [AREACOORD(userturf)].")
	log_combat(user, src, "fired a grenade ([grenade]) from [src]")
	playsound(user, fire_sound, 50, 1)
	grenade.det_time = min(10, grenade.det_time)
	grenade.launched = TRUE
	grenade.activate(user)
	grenade.throwforce += grenade.launchforce
	grenade.throw_at(target, max_range, 3, user)
	if(fire_animation)
		flick("[fire_animation]", src)
	update_icon()

/obj/item/weapon/gun/grenade_launcher/Fire()
	if(CHECK_BITFIELD(flags_gun_features, GUN_DEPLOYED_FIRE_ONLY) && !CHECK_BITFIELD(flags_item, IS_DEPLOYED))
		to_chat(gun_user, span_notice("You cannot fire [src] while it is not deployed."))
		return
	if(CHECK_BITFIELD(flags_gun_features, GUN_IS_ATTACHMENT) && !master_gun && CHECK_BITFIELD(flags_gun_features, GUN_ATTACHMENT_FIRE_ONLY))
		to_chat(gun_user, span_notice("You cannot fire [src] without it attached to a gun!"))
		return
	if(!gun_user || !target)
		return
	if(gun_user.do_actions)
		return
	if(!able_to_fire(gun_user))
		return
	if(gun_on_cooldown(gun_user))
		return
	if(gun_user.skills.getRating("firearms") < 0 && !do_after(gun_user, 0.8 SECONDS, TRUE, src))
		return
	if(get_dist(target, gun_user) <= 2)
		to_chat(gun_user, span_warning("[src] beeps a warning noise. You are too close!"))
		return
	if(!length(grenades))
		to_chat(gun_user, span_warning("[src] is empty."))
		return
	fire_grenade(target, gun_user)
	gun_user.hud_used.update_ammo_hud(gun_user, src)
	return TRUE

/obj/item/weapon/gun/grenade_launcher/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/explosive/grenade))
		return ..()
	if(length(grenades) >= max_grenades)
		to_chat(user, span_warning("[src] cannot hold more grenades!"))
		return
	if(length(grenade_type_allowed) && !(I.type in grenade_type_allowed)) //doesn't work yet
		to_chat(user, span_warning("[src] cannot hold [I]!"))
		return
	if(!user.transferItemToLoc(I, src))
		return
	grenades += I
	playsound(user, 'sound/weapons/guns/interact/shotgun_shell_insert.ogg', 25, 1)
	to_chat(user, span_notice("You put [I] in [src]."))
	to_chat(user, span_info("Now storing: [grenades.len] / [max_grenades] grenades."))
	update_icon()
	user.hud_used.update_ammo_hud(user, src)
	return ..()

/obj/item/weapon/gun/grenade_launcher/unload(mob/user)
	if(!length(grenades))
		to_chat(user, span_warning("It's empty!"))
		return
	var/obj/item/explosive/grenade/nade = grenades[length(grenades)] //Grab the last one.
	if(user)
		user.put_in_hands(nade)
		playsound(user, unload_sound, 25, 1)
	else
		nade.loc = get_turf(src)
	grenades -= nade
	user.hud_used.update_ammo_hud(user, src)
	update_icon()
	return TRUE

/obj/item/weapon/gun/grenade_launcher/get_ammo_type()
	if(!length(grenades))
		return list("empty", "empty")
	else
		var/obj/item/explosive/grenade/F = grenades[1]
		return list(F.hud_state, F.hud_state_empty)

/obj/item/weapon/gun/grenade_launcher/get_ammo_count()
	return length(grenades)

//Doesn't use most of any of these. Listed for reference.
/obj/item/weapon/gun/grenade_launcher/load_into_chamber()
	return

/obj/item/weapon/gun/grenade_launcher/reload_into_chamber()
	return

//-------------------------------------------------------
//T-70 Grenade Launcher.

/obj/item/weapon/gun/grenade_launcher/multinade_launcher
	name = "\improper T-70 grenade launcher"
	desc = "The T-70 is the standard grenade launcher used by the TerraGov Marine Corps for area denial and big explosions."
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
	max_grenades = 6

/obj/item/weapon/gun/grenade_launcher/multinade_launcher/examine_ammo_count(mob/user)
	if(!length(grenades) || (get_dist(user, src) > 2 && user != loc))
		return
	to_chat(user, span_notice("It is loaded with <b>[length(grenades)] / [max_grenades]</b> grenades."))

/obj/item/weapon/gun/grenade_launcher/underslung
	name = "underslung grenade launcher"
	desc = "A weapon-mounted, reloadable, two-shot grenade launcher."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "grenade"
	max_shells = 2 //codex
	max_grenades = 2
	fire_delay = 1 SECONDS
	fire_sound = 'sound/weapons/guns/fire/underbarrel_grenadelauncher.ogg'
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 14, "rail_y" = 22, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	attachable_allowed = list()
	max_range = 7

	slot = ATTACHMENT_SLOT_UNDER
	attach_delay = 3 SECONDS
	detach_delay = 3 SECONDS
	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_AMMO_COUNTER|GUN_IS_ATTACHMENT|GUN_ATTACHMENT_FIRE_ONLY|GUN_WIELDED_STABLE_FIRING_ONLY
	pixel_shift_x = 14
	pixel_shift_y = 18
	grenade_type_allowed = list(
		/obj/item/explosive/grenade,
		/obj/item/explosive/grenade/incendiary, 
		/obj/item/explosive/grenade/smokebomb, 
		/obj/item/explosive/grenade/phosphorus,
		/obj/item/explosive/grenade/impact,
		/obj/item/explosive/grenade/flare,
	)

/obj/item/weapon/gun/grenade_launcher/underslung/invisible
	flags_attach_features = NONE

/obj/item/weapon/gun/grenade_launcher/single_shot
	name = "\improper T-81 grenade launcher"
	desc = "A lightweight, single-shot grenade launcher used by the TerraGov Marine Corps for area denial and big explosions."
	icon_state = "m81"
	item_state = "m81"
	max_shells = 1 //codex
	flags_equip_slot = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	wield_delay = 0.2 SECONDS
	aim_slowdown = 1
	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_AMMO_COUNTER
	attachable_allowed = list()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 14, "rail_y" = 22, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	fire_delay = 1.05 SECONDS
	max_grenades = 1
	max_range = 10

/obj/item/weapon/gun/grenade_launcher/single_shot/update_icon_state()
	icon_state = "[base_gun_icon][length(grenades) ? "" : "_e"]"

/obj/item/weapon/gun/grenade_launcher/single_shot/examine_ammo_count(mob/user)
	if(!length(grenades) || (get_dist(user, src) > 2 && user != loc))
		return
	to_chat(user, span_notice("It is loaded with [grenades[1]]."))

/obj/item/weapon/gun/grenade_launcher/single_shot/riot
	name = "\improper M81 riot grenade launcher"
	desc = "A lightweight, single-shot grenade launcher to launch tear gas grenades. Used by Nanotrasen security during riots."
	grenade_type_allowed = /obj/item/explosive/grenade/chem_grenade
	req_access = list(ACCESS_MARINE_BRIG)

/obj/item/weapon/gun/grenade_launcher/single_shot/flare
	name = "flare gun"
	desc = "A gun that fires flares. Replace with flares. Simple! Equipped with long range irons."
	icon_state = "flaregun"
	item_state = "gun"
	fire_sound = 'sound/weapons/guns/fire/flare.ogg'
	fire_sound = 'sound/weapons/guns/fire/flare.ogg'
	w_class = WEIGHT_CLASS_TINY
	flags_gun_features = GUN_UNUSUAL_DESIGN
	gun_skill_category = GUN_SKILL_PISTOLS
	fire_delay = 0.5 SECONDS
	grenade_type_allowed = /obj/item/explosive/grenade/flare
	starting_attachment_types = list(/obj/item/attachable/scope/unremovable/flaregun)

/obj/item/weapon/gun/grenade_launcher/single_shot/flare/examine_ammo_count(mob/user)
	if(!length(grenades) || (get_dist(user, src) > 2 && user != loc))
		return
	to_chat(user, span_notice("It is loaded with a flare."))

/obj/item/weapon/gun/grenade_launcher/single_shot/flare/marine
	name = "M30E2 flare gun"
	desc = "A very tiny flaregun that fires flares equipped with long range irons, the mass amounts of markings on the back and barrel denote it as owned by the TGMC."
	icon_state = "marine_flaregun"
