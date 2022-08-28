#define FLAMER_WATER 200

//FLAMETHROWER

/obj/item/weapon/gun/flamer
	name = "flamer"
	desc = "flame go froosh"
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	force = 15
	fire_sound = "gun_flamethrower"
	dry_fire_sound = 'sound/weapons/guns/fire/flamethrower_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/flamethrower_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/flamethrower_reload.ogg'
	muzzle_flash = null
	aim_slowdown = 1.75
	general_codex_key = "flame weapons"
	attachable_allowed = list( //give it some flexibility.
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/flamer_nozzle,
		/obj/item/attachable/flamer_nozzle/wide,
		/obj/item/attachable/flamer_nozzle/wide/red,
		/obj/item/attachable/shoulder_mount,
		)
	attachments_by_slot = list(
		ATTACHMENT_SLOT_MUZZLE,
		ATTACHMENT_SLOT_RAIL,
		ATTACHMENT_SLOT_STOCK,
		ATTACHMENT_SLOT_UNDER,
		ATTACHMENT_SLOT_MAGAZINE,
		ATTACHMENT_SLOT_FLAMER_NOZZLE,
	)
	starting_attachment_types = list(/obj/item/attachable/flamer_nozzle)
	flags_gun_features = GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_WIELDED_STABLE_FIRING_ONLY
	gun_skill_category = GUN_SKILL_HEAVY_WEAPONS
	reciever_flags = AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_DO_NOT_EJECT_HANDFULS|AMMO_RECIEVER_DO_NOT_EMPTY_ROUNDS_AFTER_FIRE
	attachable_offset = list("rail_x" = 12, "rail_y" = 23, "flamer_nozzle_x" = 33, "flamer_nozzle_y" = 20)
	fire_delay = 2 SECONDS

	placed_overlay_iconstate = "flamer"

	ammo_datum_type = /datum/ammo/flamethrower
	default_ammo_type = /obj/item/ammo_magazine/flamer_tank/large
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/flamer_tank,
		/obj/item/ammo_magazine/flamer_tank/large,
		/obj/item/ammo_magazine/flamer_tank/large/X,
		/obj/item/ammo_magazine/flamer_tank/backtank,
		/obj/item/ammo_magazine/flamer_tank/backtank/X,
	)
	///Max range of the flamer in tiles.
	var/flame_max_range = 6
	///Travel speed of the flames in seconds.
	var/flame_spread_time = 0.1 SECONDS
	///Gun based modifier for burn level. Percentage based.
	var/burn_level_mod = 1
	///Gun based modifier for burn time. Percentage based.
	var/burn_time_mod = 1
	///Bitfield flags for flamer specific traits.
	var/flags_flamer_features = NONE
	///Overlay icon state of the pilot light.
	var/lit_overlay_icon_state = "+lit"
	///Pixel offset on the X axis for the pilot light overlay.
	var/lit_overlay_offset_x = 6
	///Pixel offset on the Y axis for the pilot light overlay.
	var/lit_overlay_offset_y = 0
	///Damage multiplier for mobs caught in the initial stream of fire.
	var/mob_flame_damage_mod = 2
	//var for testing
	var/cone_angle = 55

/obj/item/weapon/gun/flamer/Initialize()
	. = ..()
	if(!rounds)
		return
	light_pilot(TRUE)

/obj/item/weapon/gun/flamer/on_attachment_attach(obj/item/attaching_here, mob/attacher)
	. = ..()
	if(!istype(attaching_here, /obj/item/attachable/flamer_nozzle) || !rounds)
		return
	light_pilot(TRUE)

/obj/item/weapon/gun/flamer/on_attachment_detach(obj/item/detaching_here, mob/attacher)
	. = ..()
	if(!istype(detaching_here, /obj/item/attachable/flamer_nozzle))
		return
	light_pilot(FALSE)

/obj/item/weapon/gun/flamer/reload(obj/item/new_mag, mob/living/user)
	. = ..()
	if(!.)
		return
	if(attachments_by_slot[ATTACHMENT_SLOT_FLAMER_NOZZLE])
		light_pilot(TRUE)
	gun_user?.hud_used.update_ammo_hud(gun_user, src)

/obj/item/weapon/gun/flamer/unload(mob/living/user, drop = TRUE, after_fire = FALSE)
	. = ..()
	if(!.)
		return
	light_pilot(FALSE)
	gun_user?.hud_used.update_ammo_hud(gun_user, src)

///Makes the sound of the flamer being lit, and applies the overlay.
/obj/item/weapon/gun/flamer/proc/light_pilot(light)
	if(CHECK_BITFIELD(flags_flamer_features, FLAMER_IS_LIT) && light)
		return
	if(light)
		ENABLE_BITFIELD(flags_flamer_features, FLAMER_IS_LIT)
	else
		DISABLE_BITFIELD(flags_flamer_features, FLAMER_IS_LIT)
	playsound(src, CHECK_BITFIELD(flags_flamer_features, FLAMER_IS_LIT) ? 'sound/weapons/guns/interact/flamethrower_on.ogg' : 'sound/weapons/guns/interact/flamethrower_off.ogg', 25, 1)


	if(CHECK_BITFIELD(flags_flamer_features, FLAMER_NO_LIT_OVERLAY))
		return

	var/image/lit_overlay = image(icon, src, lit_overlay_icon_state)
	lit_overlay.pixel_x += lit_overlay_offset_x
	lit_overlay.pixel_y += lit_overlay_offset_y

	if(!CHECK_BITFIELD(flags_flamer_features, FLAMER_IS_LIT))
		overlays.Cut()
		update_icon()
		return
	overlays += lit_overlay

/obj/item/weapon/gun/flamer/able_to_fire(mob/user)
	. = ..()
	if(!.)
		return
	if(!istype(attachments_by_slot[ATTACHMENT_SLOT_FLAMER_NOZZLE], /obj/item/attachable/flamer_nozzle))
		to_chat(user, span_warning("[src] does not have a nozzle installed!"))
		return FALSE
	return TRUE

/obj/item/weapon/gun/flamer/do_fire(obj/projectile/projectile_to_fire)
	playsound(loc, fire_sound, 50, 1)
	var/obj/item/attachable/flamer_nozzle/nozzle = attachments_by_slot[ATTACHMENT_SLOT_FLAMER_NOZZLE]
	var/burn_type = nozzle.stream_type
	var/old_turfs = list(get_turf(src))
	var/range = flame_max_range
	var/start_location = get_turf(src)
	var/current_target = get_turf(target)
	switch(burn_type)
		if(FLAMER_STREAM_STRAIGHT)
			var/path_to_target = getline(start_location, current_target)
			path_to_target -= start_location
			recursive_flame_straight(1, old_turfs, path_to_target, range, current_target)
		if(FLAMER_STREAM_CONE)
			//direction in degrees
			var/dir_to_target = Get_Angle(src, target)
			//var/dir_to_target = get_dir(start_location, current_target)
			//if(ISDIAGONALDIR(dir_to_target))
			//	range /= 2
			recursive_flame_cone(1, old_turfs, dir_to_target, range, current_target)
		if(FLAMER_STREAM_RANGED)
			return ..()
	return TRUE

#define RECURSIVE_CHECK(old_turfs, range, current_target, iteration) (!length(old_turfs) || iteration > range || !current_target || (current_target in old_turfs))


///Flames recursively a straight path.
/obj/item/weapon/gun/flamer/proc/recursive_flame_straight(iteration, list/turf/old_turfs, list/turf/path_to_target, range, current_target)
	if(!rounds)
		light_pilot(FALSE)
		return

	if(RECURSIVE_CHECK(old_turfs, range, current_target, iteration))
		return

	var/list/turf/turfs_to_ignite = list()
	if(iteration > length(path_to_target))
		return
	if(iteration > 1 && LinkBlocked(path_to_target[iteration - 1], path_to_target[iteration], projectile = TRUE, bypass_xeno = TRUE)) //checks if it's actually possible to get to the next tile in the line
		return
	turfs_to_ignite += path_to_target[iteration]
	if(!burn_list(turfs_to_ignite))
		return
	iteration++
	addtimer(CALLBACK(src, .proc/recursive_flame_straight, iteration, turfs_to_ignite, path_to_target, range, current_target), flame_spread_time)

///Flames recursively a cone.
/obj/item/weapon/gun/flamer/proc/recursive_flame_cone(iteration, list/turf/old_turfs, dir_to_target, range, current_target)
	if(!rounds)
		light_pilot(FALSE)
		return

	if(RECURSIVE_CHECK(old_turfs, range, current_target, iteration))
		return

	var/list/turf/turfs_to_ignite = list()
	if(iteration > flame_max_range) //we've reached max range
		return
	turfs_to_ignite += generate_true_cone(get_turf(src), iteration, 0, cone_angle, dir_to_target, projectile = TRUE, bypass_xeno = TRUE)
	//generate_true_cone(get_turf(src), range, 0, cone_angle, dir_to_target, projectile = TRUE, bypass_xeno = TRUE)
	for(var/turf/turf in turfs_to_ignite)
		if(turf in old_turfs)
			turfs_to_ignite -= turf //we've already ignited this turf
	burn_list(turfs_to_ignite)
	iteration++
	old_turfs += turfs_to_ignite
	addtimer(CALLBACK(src, .proc/recursive_flame_cone, iteration, old_turfs, dir_to_target, range, current_target), flame_spread_time)

#undef RECURSIVE_CHECK

///Checks and lights the turfs in turfs_to_burn
/obj/item/weapon/gun/flamer/proc/burn_list(list/turf/turfs_to_burn)
	for(var/turf/turf_to_check AS in turfs_to_burn)
		if((turf_to_check.density && !istype(turf_to_check, /turf/closed/wall/resin)) || isspaceturf(turf_to_check))
			turfs_to_burn -= turf_to_check
			continue
		//for(var/obj/object in turf_to_check)
		//	if(!object.density || object.throwpass || istype(object, /obj/structure/mineral_door/resin) || istype(object, /obj/structure/xeno) || istype(object, /obj/machinery/deployable) || istype(object, /obj/vehicle) || (object.flags_atom & ON_BORDER && object.dir != get_dir(object, src)))
		//		continue
		//	turfs_to_burn -= turf_to_check

	if(!length(turfs_to_burn) || !length(chamber_items))
		return FALSE

	var/datum/ammo/flamethrower/loaded_ammo = CHECK_BITFIELD(flags_flamer_features, FLAMER_USES_GUN_FLAMES) ? ammo_datum_type : get_magazine_default_ammo(chamber_items[current_chamber_position])
	var/burn_level = initial(loaded_ammo.burnlevel) * burn_level_mod
	var/burn_time = initial(loaded_ammo.burntime) * burn_time_mod
	var/fire_color = initial(loaded_ammo.fire_color)

	for(var/turf/turf_to_ignite AS in turfs_to_burn)
		if(!rounds)
			light_pilot(FALSE)
			return FALSE
		flame_turf(turf_to_ignite, gun_user, burn_time, burn_level, fire_color)
		adjust_current_rounds(chamber_items[current_chamber_position], -1)
		rounds--
	gun_user?.hud_used.update_ammo_hud(gun_user, src)
	return TRUE

///Lights the specific turf on fire and processes melting snow or vines and the like.
/obj/item/weapon/gun/flamer/proc/flame_turf(turf/turf_to_ignite, mob/living/user, burn_time, burn_level, fire_color = "red")
	turf_to_ignite.ignite(burn_time, burn_level, fire_color)

	var/fire_mod
	for(var/mob/living/mob_caught in turf_to_ignite) //Deal bonus damage if someone's caught directly in initial stream
		if(mob_caught.stat == DEAD)
			continue

		fire_mod = mob_caught.get_fire_resist()

		if(isxeno(mob_caught))
			var/mob/living/carbon/xenomorph/xeno_caught = mob_caught
			if(CHECK_BITFIELD(xeno_caught.xeno_caste.caste_flags, CASTE_FIRE_IMMUNE))
				continue

		else if(ishuman(mob_caught))
			var/mob/living/carbon/human/human_caught = mob_caught
			if(user)
				if(!user.mind?.bypass_ff && !human_caught.mind?.bypass_ff && user.faction == human_caught.faction)
					log_combat(user, human_caught, "flamed", src)
					user.ff_check(30, human_caught) // avg between 20/40 dmg
					log_ffattack("[key_name(user)] flamed [key_name(human_caught)] with \a [name] in [AREACOORD(turf_to_ignite)].")
					msg_admin_ff("[ADMIN_TPMONTY(user)] flamed [ADMIN_TPMONTY(human_caught)] with \a [name] in [ADMIN_VERBOSEJMP(turf_to_ignite)].")
				else
					log_combat(user, human_caught, "flamed", src)

			if(human_caught.hard_armor.getRating("fire") >= 100)
				continue

		mob_caught.take_overall_damage(0, rand(burn_level, (burn_level * mob_flame_damage_mod)) * fire_mod, updating_health = TRUE) // Make it so its the amount of heat or twice it for the initial blast.
		mob_caught.adjust_fire_stacks(rand(5, (burn_level * mob_flame_damage_mod)))
		mob_caught.IgniteMob()

		var/burn_message = "Augh! You are roasted by the flames!"
		to_chat(mob_caught, isxeno(mob_caught) ? span_xenodanger(burn_message) : span_highdanger(burn_message))

/obj/item/weapon/gun/flamer/big_flamer
	name = "\improper FL-240 incinerator unit"
	desc = "The FL-240 has proven to be one of the most effective weapons at clearing out soft-targets. This is a weapon to be feared and respected as it is quite deadly."
	icon_state = "m240"
	item_state = "m240"

/obj/item/weapon/gun/flamer/mini_flamer
	name = "mini flamethrower"
	desc = "A weapon-mounted refillable flamethrower attachment.\nIt is designed for short bursts."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "flamethrower"

	flags_gun_features = GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_WIELDED_STABLE_FIRING_ONLY|GUN_IS_ATTACHMENT|GUN_ATTACHMENT_FIRE_ONLY
	flags_flamer_features = FLAMER_NO_LIT_OVERLAY
	w_class = WEIGHT_CLASS_BULKY
	fire_delay = 2.5 SECONDS
	fire_sound = 'sound/weapons/guns/fire/flamethrower3.ogg'

	default_ammo_type = /obj/item/ammo_magazine/flamer_tank/mini
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/flamer_tank/mini,
		/obj/item/ammo_magazine/flamer_tank/backtank,
	)
	starting_attachment_types = list(/obj/item/attachable/flamer_nozzle/unremovable/invisible)
	attachable_allowed = list(
		/obj/item/attachable/flamer_nozzle/unremovable/invisible,
	)
	slot = ATTACHMENT_SLOT_UNDER
	attach_delay = 3 SECONDS
	detach_delay = 3 SECONDS
	pixel_shift_x = 15
	pixel_shift_y = 18

	mob_flame_damage_mod = 1
	burn_level_mod = 0.6
	flame_max_range = 4

	wield_delay_mod	= 0.2 SECONDS

/obj/item/weapon/gun/flamer/mini_flamer/unremovable
	flags_attach_features = NONE


/obj/item/weapon/gun/flamer/big_flamer/marinestandard
	name = "\improper FL-84 flamethrower"
	desc = "The FL-84 flamethrower is the current standard issue flamethrower of the TGMC, and is used for area control and urban combat. Use unique action to use hydro cannon"
	default_ammo_type = /obj/item/ammo_magazine/flamer_tank/large
	icon_state = "tl84"
	item_state = "tl84"
	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_WIELDED_STABLE_FIRING_ONLY
	attachable_offset = list("rail_x" = 10, "rail_y" = 23, "stock_x" = 16, "stock_y" = 13, "flamer_nozzle_x" = 33, "flamer_nozzle_y" = 20)
	attachable_allowed = list(
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/stock/t84stock,
		/obj/item/attachable/hydro_cannon,
		/obj/item/attachable/flamer_nozzle,
		/obj/item/attachable/flamer_nozzle/wide,
		/obj/item/attachable/flamer_nozzle/long,
	)
	starting_attachment_types = list(/obj/item/attachable/flamer_nozzle, /obj/item/attachable/stock/t84stock, /obj/item/attachable/hydro_cannon)
	var/last_use
	///If we are using the hydro cannon when clicking
	var/hydro_active = FALSE
	///How much water the hydro cannon has
	var/water_count = 0

/obj/item/weapon/gun/flamer/big_flamer/marinestandard/Initialize()
	. = ..()
	reagents = new /datum/reagents(FLAMER_WATER)
	reagents.my_atom = src
	reagents.add_reagent(/datum/reagent/water, reagents.maximum_volume)
	water_count = reagents.maximum_volume

/obj/item/weapon/gun/flamer/big_flamer/marinestandard/update_ammo_count()
	if(hydro_active)
		rounds = max(water_count, 0)
		max_rounds = reagents.maximum_volume
		return
	return ..()

/obj/item/weapon/gun/flamer/big_flamer/marinestandard/get_ammo()
	if(hydro_active)
		ammo_datum_type = /datum/ammo/water
		return
	return ..()

/obj/item/weapon/gun/flamer/big_flamer/marinestandard/examine(mob/user)
	. = ..()
	to_chat(user, span_notice("Its hydro cannon contains [reagents.get_reagent_amount(/datum/reagent/water)]/[reagents.maximum_volume] units of water!"))

/obj/item/weapon/gun/flamer/big_flamer/marinestandard/unique_action(mob/user)
	var/obj/item/attachable/hydro_cannon/hydro = LAZYACCESS(attachments_by_slot, ATTACHMENT_SLOT_UNDER)
	if(!istype(hydro))
		return FALSE
	playsound(user, hydro.activation_sound, 15, 1)
	if (hydro.activate(user))
		hydro_active = TRUE
		light_pilot(FALSE)
	else
		hydro_active = FALSE
		if (rounds > 0)
			light_pilot(TRUE)
	user.hud_used.update_ammo_hud(user, src)
	SEND_SIGNAL(src, COMSIG_ITEM_HYDRO_CANNON_TOGGLED)
	return TRUE

/obj/item/weapon/gun/flamer/big_flamer/marinestandard/do_fire(obj/projectile/projectile_to_fire)
	if(!target)
		return
	if(hydro_active && (world.time > last_use + 10))
		INVOKE_ASYNC(src, .proc/extinguish, target, gun_user) //Fire it.
		water_count -= 7//reagents is not updated in this proc, we need water_count for a updated HUD
		last_fired = world.time
		last_use = world.time
		gun_user.hud_used.update_ammo_hud(gun_user, src)
		return
	if(gun_user?.skills.getRating("firearms") < 0)
		switch(windup_checked)
			if(WEAPON_WINDUP_NOT_CHECKED)
				INVOKE_ASYNC(src, .proc/do_windup)
				return
			if(WEAPON_WINDUP_CHECKING)
				return
	return ..()

///Flamer windup called before firing
/obj/item/weapon/gun/flamer/big_flamer/marinestandard/proc/do_windup()
	windup_checked = WEAPON_WINDUP_CHECKING
	if(!do_after(gun_user, 1 SECONDS, TRUE, src))
		windup_checked = WEAPON_WINDUP_NOT_CHECKED
		return
	windup_checked = WEAPON_WINDUP_CHECKED
	Fire()

/obj/item/weapon/gun/flamer/big_flamer/marinestandard/afterattack(atom/target, mob/user)
	. = ..()
	if(istype(target, /obj/structure/reagent_dispensers/watertank) && get_dist(user,target) <= 1)
		var/obj/o = target
		o.reagents.trans_to(src, reagents.maximum_volume)
		water_count = reagents.maximum_volume
		to_chat(user, span_notice("\The [src]'s hydro cannon is refilled with water."))
		playsound(src.loc, 'sound/effects/refill.ogg', 25, 1, 3)
		user.hud_used.update_ammo_hud(user, src)
		return



/turf/proc/ignite(fire_lvl, burn_lvl, f_color, fire_stacks = 0, fire_damage = 0)
	//extinguish any flame present
	var/obj/flamer_fire/F = locate(/obj/flamer_fire) in src
	if(F)
		qdel(F)

	new /obj/flamer_fire(src, fire_lvl, burn_lvl, f_color, fire_stacks, fire_damage)

	for(var/obj/structure/jungle/vines/vines in src)
		QDEL_NULL(vines)

/turf/open/floor/plating/ground/snow/ignite(fire_lvl, burn_lvl, f_color, fire_stacks = 0, fire_damage = 0)
	if(slayer > 0)
		slayer -= 1
		update_icon(1, 0)
	return ..()

//////////////////////////////////////////////////////////////////////////////////////////////////
//Time to redo part of abby's code.
//Create a flame sprite object. Doesn't work like regular fire, ie. does not affect atmos or heat
/obj/flamer_fire
	name = "fire"
	desc = "Ouch!"
	anchored = TRUE
	mouse_opacity = 0
	icon = 'icons/effects/fire.dmi'
	icon_state = "red_2"
	layer = BELOW_OBJ_LAYER
	light_system = MOVABLE_LIGHT
	light_mask_type = /atom/movable/lighting_mask/flicker
	light_on = TRUE
	light_range = 3
	light_power = 3
	light_color = LIGHT_COLOR_LAVA
	var/firelevel = 12 //Tracks how much "fire" there is. Basically the timer of how long the fire burns
	var/burnlevel = 10 //Tracks how HOT the fire is. This is basically the heat level of the fire and determines the temperature.
	var/flame_color = "red"

/obj/flamer_fire/Initialize(mapload, fire_lvl, burn_lvl, f_color, fire_stacks = 0, fire_damage = 0)
	. = ..()

	if(f_color)
		flame_color = f_color

	icon_state = "[flame_color]_2"
	if(fire_lvl)
		firelevel = fire_lvl
	if(burn_lvl)
		burnlevel = burn_lvl
	if(fire_stacks || fire_damage)
		for(var/mob/living/C in get_turf(src))
			C.flamer_fire_act(fire_stacks)

			C.take_overall_damage_armored(fire_damage, BURN, "fire", updating_health = TRUE)
			if(C.IgniteMob())
				C.visible_message(span_danger("[C] bursts into flames!"), isxeno(C) ? span_xenodanger("You burst into flames!") : span_highdanger("You burst into flames!"))

	START_PROCESSING(SSobj, src)

	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_cross,
	)
	AddElement(/datum/element/connect_loc, connections)


/obj/flamer_fire/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/flamer_fire/proc/on_cross(datum/source, mob/living/M, oldloc, oldlocs) //Only way to get it to reliable do it when you walk into it.
	if(istype(M))
		M.flamer_fire_crossed(burnlevel, firelevel)

// override this proc to give different walking-over-fire effects
/mob/living/proc/flamer_fire_crossed(burnlevel, firelevel, fire_mod = 1)
	if(status_flags & (INCORPOREAL|GODMODE))
		return FALSE
	if(!CHECK_BITFIELD(flags_pass, PASSFIRE)) //Pass fire allow to cross fire without being ignited
		adjust_fire_stacks(burnlevel) //Make it possible to light them on fire later.
		IgniteMob()
	fire_mod *= get_fire_resist()
	take_overall_damage(0, round(burnlevel*0.5)* fire_mod, updating_health = TRUE)
	to_chat(src, span_danger("You are burned!"))

/obj/flamer_fire/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!CHECK_BITFIELD(S.smoke_traits, SMOKE_EXTINGUISH)) //Fire suppressing smoke
		return

	firelevel -= 20 //Water level extinguish
	updateicon()
	if(firelevel < 1) //Extinguish if our firelevel is less than 1
		qdel(src)

/mob/living/carbon/human/flamer_fire_crossed(burnlevel, firelevel, fire_mod = 1)
	if(hard_armor.getRating("fire") >= 100)
		take_overall_damage_armored(round(burnlevel * 0.2) * fire_mod, BURN, "fire", updating_health = TRUE)
		return
	. = ..()
	if(isxeno(pulledby))
		var/mob/living/carbon/xenomorph/X = pulledby
		X.flamer_fire_crossed(burnlevel, firelevel)

/mob/living/carbon/xenomorph/flamer_fire_crossed(burnlevel, firelevel, fire_mod = 1)
	if(xeno_caste.caste_flags & CASTE_FIRE_IMMUNE)
		return
	return ..()


/obj/flamer_fire/proc/updateicon()
	var/light_color = "LIGHT_COLOR_LAVA"
	var/light_intensity = 3
	switch(flame_color)
		if("red")
			light_color = LIGHT_COLOR_LAVA
		if("blue")
			light_color = LIGHT_COLOR_CYAN
		if("green")
			light_color = LIGHT_COLOR_GREEN
	switch(firelevel)
		if(1 to 9)
			icon_state = "[flame_color]_1"
			light_intensity = 2
		if(10 to 25)
			icon_state = "[flame_color]_2"
			light_intensity = 4
		if(25 to INFINITY) //Change the icons and luminosity based on the fire's intensity
			icon_state = "[flame_color]_3"
			light_intensity = 6
	set_light_range_power_color(light_intensity, light_power, light_color)

/obj/flamer_fire/process()
	var/turf/T = loc
	firelevel = max(0, firelevel)
	if(!istype(T)) //Is it a valid turf?
		qdel(src)
		return

	updateicon()

	if(!firelevel)
		qdel(src)
		return

	T.flamer_fire_act(burnlevel)

	var/j = 0
	for(var/i in T)
		if(++j >= 11)
			break
		var/atom/A = i
		if(QDELETED(A)) //The destruction by fire of one atom may destroy others in the same turf.
			continue
		A.flamer_fire_act(burnlevel)

	firelevel -= 2 //reduce the intensity by 2 per tick


// override this proc to give different idling-on-fire effects
/mob/living/flamer_fire_act(burnlevel)
	if(!burnlevel)
		return
	var/fire_mod = get_fire_resist()
	if(fire_mod <= 0)
		return
	if(status_flags & (INCORPOREAL|GODMODE)) //Ignore incorporeal/invul targets
		return
	if(hard_armor.getRating("fire") >= 100)
		to_chat(src, span_warning("Your suit protects you from most of the flames."))
		adjustFireLoss(rand(0, burnlevel * 0.25)) //Does small burn damage to a person wearing one of the suits.
		return
	adjust_fire_stacks(burnlevel) //If i stand in the fire i deserve all of this. Also Napalm stacks quickly.
	burnlevel *= fire_mod //Fire stack adjustment is handled in the stacks themselves so this is modified afterwards.
	IgniteMob()
	adjustFireLoss(min(burnlevel, rand(10 , burnlevel))) //Including the fire should be way stronger.
	to_chat(src, span_warning("You are burned!"))


/mob/living/carbon/xenomorph/flamer_fire_act(burnlevel)
	if(xeno_caste.caste_flags & CASTE_FIRE_IMMUNE)
		return
	. = ..()
	updatehealth()

/mob/living/carbon/xenomorph/queen/flamer_fire_act(burnlevel)
	to_chat(src, span_xenowarning("Our extra-thick exoskeleton protects us from the flames."))

/mob/living/carbon/xenomorph/ravager/flamer_fire_act(burnlevel)
	if(stat)
		return
	plasma_stored = xeno_caste.plasma_max
	var/datum/action/xeno_action/charge = actions_by_path[/datum/action/xeno_action/activable/charge]
	if(charge)
		charge.clear_cooldown() //Reset charge cooldown
	to_chat(src, span_xenodanger("The heat of the fire roars in our veins! KILL! CHARGE! DESTROY!"))
	if(prob(70))
		emote("roar")

#undef FLAMER_WATER
