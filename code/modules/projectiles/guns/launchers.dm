/*
This file contains: 
The Grenade Launchers
The Rocket Launchers
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

/obj/item/weapon/gun/grenade_launcher/m92
	name = "\improper T-26 grenade launcher"
	desc = "A heavy, 6-shot grenade launcher used by the TerraGov Marine Corps for area denial and big explosions."
	icon_state = "m92"
	item_state = "m92"
	max_shells = 6
	wield_delay = 0.6 SECONDS
	aim_slowdown = 1
	attachable_allowed = list(/obj/item/attachable/magnetic_harness, /obj/item/attachable/scope/mini)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 14, "rail_y" = 22, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	fire_delay = 1.8 SECONDS
	max_grenades = 6

/obj/item/weapon/gun/grenade_launcher/m92/Initialize()
	. = ..()
	for(var/i in 1 to max_grenades)
		grenades += new /obj/item/explosive/grenade(src)

/obj/item/weapon/gun/grenade_launcher/m92/update_icon(mob/user)
	update_item_state(user)
	update_mag_overlay(user)

/obj/item/weapon/gun/grenade_launcher/m92/examine_ammo_count(mob/user)
	if(!length(grenades) || (get_dist(user, src) > 2 && user != loc))
		return
	to_chat(user, span_notice("It is loaded with <b>[length(grenades)] / [max_grenades]</b> grenades."))

//-------------------------------------------------------
//T-70 Grenade Launcher.

/obj/item/weapon/gun/grenade_launcher/m92/standardmarine
	name = "\improper T-70 grenade launcher"
	desc = "The T-70 is the standard grenade launcher used by the TerraGov Marine Corps for area denial and big explosions."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "t70"
	item_state = "t70"
	fire_animation = "t70_fire"
	flags_equip_slot = ITEM_SLOT_BACK
	wield_delay = 1 SECONDS
	fire_sound = 'sound/weapons/guns/fire/underbarrel_grenadelauncher.ogg'
	fire_rattle = 'sound/weapons/guns/fire/underbarrel_grenadelauncher.ogg'
	aim_slowdown = 1.2
	attachable_allowed = list(/obj/item/attachable/magnetic_harness, /obj/item/attachable/flashlight, /obj/item/attachable/scope/mini)
	starting_attachment_types = list(/obj/item/attachable/stock/t70stock)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 14, "rail_y" = 22, "under_x" = 19, "under_y" = 14, "stock_x" = 11, "stock_y" = 12)
	fire_delay = 1.2 SECONDS

/obj/item/weapon/gun/grenade_launcher/m92/standardmarine/Initialize()
	. = ..()
	grenades.Cut(1,0)

/obj/item/weapon/gun/grenade_launcher/underslung
	name = "underslung grenade launcher"
	desc = "A weapon-mounted, reloadable, two-shot grenade launcher."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "grenade"
	max_shells = 2
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
		/obj/item/explosive/grenade/incendiary, 
		/obj/item/explosive/grenade/smokebomb, 
		/obj/item/explosive/grenade/phosphorus,
		/obj/item/explosive/grenade/impact,
		/obj/item/explosive/grenade/flare,
	)

/obj/item/weapon/gun/grenade_launcher/underslung/update_icon(mob/user)
	update_mag_overlay(user)

/obj/item/weapon/gun/grenade_launcher/underslung/invisible
	flags_attach_features = NONE

/obj/item/weapon/gun/grenade_launcher/m81
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

/obj/item/weapon/gun/grenade_launcher/m81/update_icon()
	icon_state = "[base_gun_icon][length(grenades) ? "" : "_e"]"

/obj/item/weapon/gun/grenade_launcher/m81/examine_ammo_count(mob/user)
	if(!length(grenades) || (get_dist(user, src) > 2 && user != loc))
		return
	to_chat(user, span_notice("It is loaded with [grenades[1]]."))

/obj/item/weapon/gun/grenade_launcher/m81/riot
	name = "\improper M81 riot grenade launcher"
	desc = "A lightweight, single-shot grenade launcher to launch tear gas grenades. Used by Nanotrasen security during riots."
	grenade_type_allowed = /obj/item/explosive/grenade/chem_grenade
	req_access = list(ACCESS_MARINE_BRIG)


//-------------------------------------------------------
//M5 RPG

/obj/item/weapon/gun/launcher/rocket
	name = "\improper M-5 rocket launcher"
	desc = "The M-5 is the primary anti-armor used around the galaxy. Used to take out light-tanks and enemy structures, the M-5 rocket launcher is a dangerous weapon with a variety of combat uses. Uses a variety of 84mm rockets."
	icon_state = "m5"
	item_state = "m5"
	max_shells = 1 //codex
	caliber = CALIBER_84MM //codex
	load_method = SINGLE_CASING //codex
	materials = list(/datum/material/metal = 10000)
	current_mag = /obj/item/ammo_magazine/rocket
	flags_equip_slot = NONE
	w_class = WEIGHT_CLASS_HUGE
	force = 15
	wield_delay = 12
	wield_penalty = 1.6 SECONDS
	aim_slowdown = 1.75
	general_codex_key = "explosive weapons"
	attachable_allowed = list(
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/buildasentry,
	)

	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	gun_skill_category = GUN_SKILL_FIREARMS
	dry_fire_sound = 'sound/weapons/guns/fire/launcher_empty.ogg'
	reload_sound = 'sound/weapons/guns/interact/launcher_reload.ogg'
	unload_sound = 'sound/weapons/guns/interact/launcher_reload.ogg'
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 6, "rail_y" = 19, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	fire_delay = 1 SECONDS
	recoil = 3
	scatter = -100
	placed_overlay_iconstate = "sadar"
	///the smoke effect after firing
	var/datum/effect_system/smoke_spread/smoke

/obj/item/weapon/gun/launcher/rocket/Initialize(mapload, spawn_empty)
	. = ..()
	smoke = new(src, FALSE)

/obj/item/weapon/gun/launcher/rocket/Destroy()
	QDEL_NULL(smoke)
	return ..()

/obj/item/weapon/gun/launcher/rocket/Fire()
	if((!CHECK_BITFIELD(flags_item, IS_DEPLOYED) && !able_to_fire(gun_user)) || gun_user?.do_actions)
		return

	if(gun_on_cooldown(gun_user))
		return

	if(windup_checked == WEAPON_WINDUP_NOT_CHECKED)
		INVOKE_ASYNC(src, .proc/do_windup)
		return TRUE
	else if (windup_checked == WEAPON_WINDUP_CHECKING)//We are already in windup, abort
		return TRUE

	. = ..()

	//loaded_rocket.current_rounds = max(loaded_rocket.current_rounds - 1, 0)

	if(current_mag && !current_mag.current_rounds)
		current_mag.loc = get_turf(src)
		current_mag.update_icon()
		current_mag = null
	log_combat(gun_user, gun_user, "fired the [src].")
	log_explosion("[gun_user] fired the [src] at [AREACOORD(loc)].")

///Windup before shooting
/obj/item/weapon/gun/launcher/rocket/proc/do_windup()
	windup_checked = WEAPON_WINDUP_CHECKING
	var/delay = 0.1 SECONDS
	if(has_attachment(/obj/item/attachable/scope/mini))
		delay += 0.2 SECONDS

	if(gun_user && gun_user.skills.getRating("firearms") < 0)
		delay += 0.6 SECONDS

	if(gun_user)
		if(!do_after(gun_user, delay, TRUE, src, BUSY_ICON_DANGER)) //slight wind up
			windup_checked = WEAPON_WINDUP_NOT_CHECKED
			return
		finish_windup()
		return

	addtimer(CALLBACK(src, .proc/finish_windup), delay)

///Proc that finishes the windup, this fires the gun.
/obj/item/weapon/gun/launcher/rocket/proc/finish_windup()
	windup_checked = WEAPON_WINDUP_CHECKED
	if(Fire())
		playsound(loc,'sound/weapons/guns/fire/launcher.ogg', 50, TRUE)
		return
	windup_checked = WEAPON_WINDUP_NOT_CHECKED


/obj/item/weapon/gun/launcher/rocket/examine_ammo_count(mob/user)
	if(current_mag?.current_rounds)
		to_chat(user, "It's ready to rocket.")
	else
		to_chat(user, "It's empty.")


/obj/item/weapon/gun/launcher/rocket/load_into_chamber(mob/user)
	return ready_in_chamber()


//No such thing
/obj/item/weapon/gun/launcher/rocket/reload_into_chamber(mob/user)
	return TRUE


/obj/item/weapon/gun/launcher/rocket/delete_bullet(obj/projectile/projectile_to_fire, refund = FALSE)
	qdel(projectile_to_fire)
	if(refund)
		current_mag.current_rounds++
	return TRUE


/obj/item/weapon/gun/launcher/rocket/replace_magazine(mob/user, obj/item/ammo_magazine/magazine)
	user.transferItemToLoc(magazine, src) //Click!
	current_mag = magazine
	ammo = GLOB.ammo_list[current_mag.default_ammo]
	user.visible_message(span_notice("[user] loads [magazine] into [src]!"),
	span_notice("You load [magazine] into [src]!"), null, 3)
	if(reload_sound)
		playsound(user, reload_sound, 25, 1, 5)
	update_icon()


/obj/item/weapon/gun/launcher/rocket/unload(mob/user)
	if(!user)
		return FALSE
	if(!current_mag || current_mag.loc != src)
		to_chat(user, span_warning("[src] is already empty!"))
		return TRUE
	to_chat(user, span_notice("You begin unloading [src]."))
	if(!do_after(user, current_mag.reload_delay * 0.5, TRUE, src, BUSY_ICON_GENERIC))
		to_chat(user, span_warning("Your unloading was interrupted!"))
		return TRUE
	if(!user) //If we want to drop it on the ground or there's no user.
		current_mag.loc = get_turf(src) //Drop it on the ground.
	else
		user.put_in_hands(current_mag)

	playsound(user, unload_sound, 25, 1, 5)
	user.visible_message(span_notice("[user] unloads [current_mag] from [src]."),
	span_notice("You unload [current_mag] from [src]."), null, 4)
	current_mag.update_icon()
	current_mag = null

	return TRUE


//Adding in the rocket backblast. The tile behind the specialist gets blasted hard enough to down and slightly wound anyone
/obj/item/weapon/gun/launcher/rocket/apply_gun_modifiers(obj/projectile/projectile_to_fire, atom/target)
	. = ..()
	var/turf/blast_source = get_turf(src)
	var/thrown_dir = REVERSE_DIR(get_dir(blast_source, target))
	var/turf/backblast_loc = get_step(blast_source, thrown_dir)
	smoke.set_up(0, backblast_loc)
	smoke.start()
	for(var/mob/living/carbon/victim in backblast_loc)
		if(victim.lying_angle || victim.stat == DEAD) //Have to be standing up to get the fun stuff
			continue
		victim.adjustBruteLoss(15) //The shockwave hurts, quite a bit. It can knock unarmored targets unconscious in real life
		victim.Paralyze(60) //For good measure
		victim.emote("pain")
		victim.throw_at(get_step(backblast_loc, thrown_dir), 1, 2)


/obj/item/weapon/gun/launcher/rocket/get_ammo_type()
	if(!ammo)
		return list("unknown", "unknown")
	else
		return list(ammo.hud_state, ammo.hud_state_empty)

/obj/item/weapon/gun/launcher/rocket/get_ammo_count()
	if(!current_mag)
		return 0
	else
		return current_mag.current_rounds

//-------------------------------------------------------
//T-152 RPG

/obj/item/weapon/gun/launcher/rocket/sadar
	name = "\improper T-152 rocket launcher"
	desc = "The T-152 is the primary anti-armor weapon of the TGMC. Used to take out light-tanks and enemy structures, the T-152 rocket launcher is a dangerous weapon with a variety of combat uses. Uses a variety of 84mm rockets."
	icon_state = "m5"
	item_state = "m5"
	max_shells = 1 //codex
	caliber = CALIBER_84MM //codex
	load_method = SINGLE_CASING //codex
	materials = list(/datum/material/metal = 10000)
	current_mag = /obj/item/ammo_magazine/rocket/sadar
	flags_equip_slot = NONE
	w_class = WEIGHT_CLASS_HUGE
	force = 15
	wield_delay = 12
	wield_penalty = 1.6 SECONDS
	aim_slowdown = 1.75
	general_codex_key = "explosive weapons"
	attachable_allowed = list(
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/buildasentry,
	)

	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	gun_skill_category = GUN_SKILL_FIREARMS
	dry_fire_sound = 'sound/weapons/guns/fire/launcher_empty.ogg'
	reload_sound = 'sound/weapons/guns/interact/launcher_reload.ogg'
	unload_sound = 'sound/weapons/guns/interact/launcher_reload.ogg'
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 6, "rail_y" = 19, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)

	fire_delay = 1 SECONDS
	recoil = 3
	scatter = -100

/obj/item/weapon/gun/launcher/rocket/sadar/Initialize(mapload, spawn_empty)
	. = ..()
	SSmonitor.stats.sadar_in_use += src

/obj/item/weapon/gun/launcher/rocket/sadar/Destroy()
	SSmonitor.stats.sadar_in_use -= src
	return ..()

//-------------------------------------------------------
//M5 RPG'S MEAN FUCKING COUSIN

/obj/item/weapon/gun/launcher/rocket/m57a4
	name = "\improper M57A4 quad thermobaric launcher"
	desc = "The M57A4 is posssibly the most destructive man-portable weapon ever made. It is a 4-barreled missile launcher capable of burst-firing 4 thermobaric missiles. Enough said."
	icon_state = "m57a4"
	item_state = "m57a4"
	max_shells = 4 //codex
	caliber = CALIBER_ROCKETARRAY //codex
	load_method = MAGAZINE //codex
	current_mag = /obj/item/ammo_magazine/rocket/m57a4/ds
	aim_slowdown = 2.75
	attachable_allowed = list(
		/obj/item/attachable/buildasentry,
	)
	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	general_codex_key = "explosive weapons"

	fire_delay = 0.6 SECONDS
	burst_delay = 0.4 SECONDS
	burst_amount = 4
	accuracy_mult = 0.8

	placed_overlay_iconstate = "thermo"

/obj/item/weapon/gun/launcher/rocket/m57a4/t57
	name = "\improper T-57 quad thermobaric launcher"
	desc = "The T-57 is posssibly the most awful man portable weapon. It is a 4-barreled missile launcher capable of burst-firing 4 thermobaric missiles with nearly no force to the rocket. Enough said."
	icon_state = "t57"
	item_state = "t57"
	current_mag = /obj/item/ammo_magazine/rocket/m57a4



//-------------------------------------------------------
//T-160 Recoilless Rifle. Its effectively an RPG codewise.

/obj/item/weapon/gun/launcher/rocket/recoillessrifle
	name = "\improper T-160 recoilless rifle"
	desc = "The T-160 recoilless rifle is a long range explosive ordanance device used by the TGMC used to fire explosive shells at far distances. Uses a variety of 67mm shells designed for various purposes."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "t160"
	item_state = "t160"
	max_shells = 1 //codex
	caliber = CALIBER_67MM //codex
	load_method = SINGLE_CASING //codex
	materials = list(/datum/material/metal = 10000)
	current_mag = /obj/item/ammo_magazine/rocket/recoilless
	flags_equip_slot = NONE
	w_class = WEIGHT_CLASS_HUGE
	force = 15
	wield_delay = 1 SECONDS
	recoil = 1
	wield_penalty = 1.6 SECONDS
	aim_slowdown = 1
	general_codex_key = "explosive weapons"
	attachable_allowed = list(
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/buildasentry,
	)

	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	gun_skill_category = GUN_SKILL_FIREARMS
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 15, "rail_y" = 19, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)

	fire_delay = 1 SECONDS
	recoil = 3
	scatter = -100

//-------------------------------------------------------
//Disposable RPG

/obj/item/weapon/gun/launcher/rocket/oneuse
	name = "\improper T-72 disposable rocket launcher"
	desc = "This is the premier disposable rocket launcher used throughout the galaxy, it cannot be reloaded or unloaded on the field. This one fires an 84mm explosive rocket."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "t72"
	item_state = "t72"
	max_shells = 1 //codex
	caliber = CALIBER_84MM //codex
	load_method = SINGLE_CASING //codex
	current_mag = /obj/item/ammo_magazine/rocket/oneuse
	flags_equip_slot = ITEM_SLOT_BELT
	attachable_allowed = list(/obj/item/attachable/magnetic_harness)

	dry_fire_sound = 'sound/weapons/guns/fire/launcher_empty.ogg'
	reload_sound = 'sound/weapons/guns/interact/launcher_reload.ogg'
	unload_sound = 'sound/weapons/guns/interact/launcher_reload.ogg'
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 6, "rail_y" = 19, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	fire_delay = 1 SECONDS
	recoil = 3
	scatter = -100

/obj/item/weapon/gun/launcher/rocket/oneuse/unload(mob/user) // Unsurprisngly you can't unload this.
	to_chat(user, span_warning("You can't unload this!"))
	return FALSE


/obj/item/weapon/gun/launcher/rocket/oneuse/examine_ammo_count(mob/user)
	if(current_mag?.current_rounds)
		to_chat(user, "It's loaded.")
	else
		to_chat(user, "It's empty.")

//-------------------------------------------------------
//TX-220 Railgun

/obj/item/weapon/gun/rifle/railgun
	name = "\improper TX-220 railgun"
	desc = "The TX-220 is a specialized heavy duty railgun made to shred through hard armor to allow for follow up attacks. Uses specialized canisters to reload."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "railgun"
	item_state = "railgun"
	max_shells = 1 //codex
	caliber = CALIBER_RAILGUN
	fire_sound = 'sound/weapons/guns/fire/railgun.ogg'
	fire_rattle = 'sound/weapons/guns/fire/railgun.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/sniper_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/sniper_reload.ogg'
	current_mag = /obj/item/ammo_magazine/railgun
	force = 40
	wield_delay = 1.75 SECONDS //You're not quick drawing this.
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 20, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	attachable_allowed = list(
		/obj/item/attachable/magnetic_harness,
	)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER

	fire_delay = 1 SECONDS
	burst_amount = 1
	accuracy_mult = 2
	recoil = 0
