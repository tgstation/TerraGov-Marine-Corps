
/obj/vehicle/unmanned
	name = "unmanned vehicle"
	desc = "A small remote-controllable vehicle, usually owned by the TGMC and other major armies."
	icon = 'icons/obj/unmanned_vehicles.dmi'
	icon_state = "light_uv"
	anchored = FALSE
	buckle_flags = null
	light_range = 6
	light_power = 3
	light_system = MOVABLE_LIGHT
	move_delay = 2.5	//set this to limit the speed of the vehicle
	max_integrity = 300
	hud_possible = list(MACHINE_HEALTH_HUD, MACHINE_AMMO_HUD)
	resistance_flags = XENO_DAMAGEABLE
	flags_atom = BUMP_ATTACKABLE
	soft_armor = list("melee" = 25, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 25, "acid" = 25)
	/// Path of "turret" attached
	var/obj/item/uav_turret/turret_path
	/// Type of the turret attached
	var/turret_type
	///Turret types we're allowed to attach
	var/turret_pattern = PATTERN_TRACKED
	///Delay in byond ticks between weapon fires
	var/fire_delay = 5
	///Ammo remaining for the robot
	var/current_rounds = 0
	///max ammo the robot can hold
	var/max_rounds = 0
	///Buller type we fire, declared as type but set to a reference in Initialize
	var/datum/ammo/bullet/ammo
	///The currently loaded and ready to fire projectile
	var/obj/projectile/in_chamber = null
	///Sound file or string type for playing the shooting sound
	var/gunnoise = "gun_smartgun"
	/// Serial number of the vehicle
	var/static/serial = 1
	/// If the vehicle should spawn with a weapon allready installed
	var/obj/item/uav_turret/spawn_equipped_type = null
	/// If something is already controlling the vehicle
	var/controlled = FALSE
	/// Flags for unmanned vehicules
	var/unmanned_flags = OVERLAY_TURRET|HAS_LIGHTS|UNDERCARRIAGE
	/// Iff flags, to prevent friendly fire from sg and aiming marines
	var/iff_signal = TGMC_LOYALIST_IFF
	COOLDOWN_DECLARE(fire_cooldown)

/obj/vehicle/unmanned/Initialize()
	. = ..()
	ammo = GLOB.ammo_list[ammo]
	name += " " + num2text(serial)
	serial++
	GLOB.unmanned_vehicles += src
	prepare_huds()
	for(var/datum/atom_hud/squad/sentry_status_hud in GLOB.huds) //Add to the squad HUD
		sentry_status_hud.add_to_hud(src)
	hud_set_machine_health()
	if(spawn_equipped_type)
		turret_path = spawn_equipped_type
		turret_type = initial(spawn_equipped_type.turret_type)
		ammo = GLOB.ammo_list[initial(spawn_equipped_type.ammo_type)]
		fire_delay = initial(spawn_equipped_type.fire_delay)
		current_rounds = initial(spawn_equipped_type.max_rounds)
		max_rounds = initial(spawn_equipped_type.max_rounds)
		update_icon()
	hud_set_uav_ammo()


/obj/vehicle/unmanned/Destroy()
	. = ..()
	GLOB.unmanned_vehicles -= src

/obj/vehicle/unmanned/take_damage(damage_amount, damage_type, damage_flag, effects, attack_dir, armour_penetration)
	. = ..()
	hud_set_machine_health()

/obj/vehicle/unmanned/repair_damage(repair_amount)
	. = ..()
	hud_set_machine_health()

/obj/vehicle/unmanned/update_overlays()
	. = ..()
	if(!(unmanned_flags & OVERLAY_TURRET))
		return
	switch(turret_type)
		if(TURRET_TYPE_HEAVY)
			. += image('icons/obj/unmanned_vehicles.dmi', src, "heavy_cannon")
		if(TURRET_TYPE_LIGHT)
			. += image('icons/obj/unmanned_vehicles.dmi', src, "light_cannon")
		if(TURRET_TYPE_EXPLOSIVE)
			. += image('icons/obj/unmanned_vehicles.dmi', src, "bomb")
		if(TURRET_TYPE_DROIDLASER)
			. += image('icons/obj/unmanned_vehicles.dmi', src, "droidlaser")

/obj/vehicle/unmanned/examine(mob/user, distance, infix, suffix)
	. = ..()
	if(ishuman(user))
		to_chat(user, "It has [current_rounds] ammo left.")

/obj/vehicle/unmanned/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/uav_turret) || istype(I, /obj/item/explosive/plastique))
		return equip_turret(I, user)
	if(istype(I, /obj/item/ammo_magazine))
		return reload_turret(I, user)

/obj/vehicle/unmanned/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if((unmanned_flags & UNDERCARRIAGE) && istype(mover) && CHECK_BITFIELD(mover.flags_pass, PASSTABLE))
		return TRUE

///Try to desequip the turret
/obj/vehicle/unmanned/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(!turret_path)
		to_chat(user,"<span class='warning'>There is nothing to remove from [src]!</span>")
		return
	user.visible_message(span_notice("[user] starts to remove [initial(turret_path.name)] from [src]"),	span_notice("You start to remove [initial(turret_path.name)] from [src]"))
	if(!do_after(user, 3 SECONDS, TRUE, src))
		return
	var/obj/item/equipment = new turret_path
	user.visible_message(span_notice("[user] removes [equipment] from [src]."),
	span_notice("You remove [equipment] from [src]."))
	user.put_in_hands(equipment)
	if(istype(equipment, /obj/item/uav_turret))
		var/obj/item/uav_turret/turret = equipment
		turret.current_rounds = current_rounds
	turret_path = null
	turret_type = null
	current_rounds = 0
	max_rounds = 0
	update_icon()
	hud_set_uav_ammo()
	return

///Try to reload the turret of our vehicule
/obj/vehicle/unmanned/proc/reload_turret(obj/item/ammo_magazine/ammo, mob/user)
	if(!ispath(turret_path, ammo.gun_type))
		to_chat(user, span_warning("This is not the right ammo!"))
		return
	user.visible_message(span_notice("[user] starts to reload [src] with [ammo]."), span_notice("You start to reload [src] with [ammo]."))
	if(!do_after(user, 3 SECONDS, TRUE, src))
		return
	user.visible_message(span_notice("[user] reloads [src] with [ammo]."), span_notice("You reload [src] with [ammo]."))
	current_rounds = min(current_rounds + ammo.current_rounds, max_rounds)
	playsound(loc, 'sound/weapons/guns/interact/smartgun_unload.ogg', 25, 1)
	qdel(ammo)

/// Try to equip a turret on the vehicle
/obj/vehicle/unmanned/proc/equip_turret(obj/item/I, mob/user)
	if(turret_path)
		to_chat(user, span_notice("There's already something attached!"))
		return
	if(istype(I, /obj/item/uav_turret))
		var/obj/item/uav_turret/turret = I
		if(turret_pattern != turret.turret_pattern)
			to_chat(user, span_notice("You can't attach that type of turret!"))
			return
	user.visible_message(span_notice("[user] starts to attach [I] to [src]."),
	span_notice("You start to attach [I] to [src]."))
	if(!do_after(user, 3 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
		return
	turret_path = I.type
	if(istype(I, /obj/item/uav_turret))
		var/obj/item/uav_turret/turret = I
		ammo = GLOB.ammo_list[turret.ammo_type]
		turret_type = turret.turret_type
		fire_delay = turret.fire_delay
		current_rounds = turret.current_rounds
		max_rounds = turret.max_rounds
		hud_set_uav_ammo()
	else
		turret_type = TURRET_TYPE_EXPLOSIVE
	user.visible_message(span_notice("[user] attaches [I] to [src]."),
	span_notice("You attach [I] to [src]."))
	update_icon()
	SEND_SIGNAL(src, COMSIG_UNMANNED_TURRET_UPDATED, turret_type)
	qdel(I)

/**
 * Called when the drone is unlinked from a remote control
 */
/obj/vehicle/unmanned/proc/on_link(atom/remote_controller)
	SHOULD_CALL_PARENT(TRUE)
	RegisterSignal(src, COMSIG_REMOTECONTROL_CHANGED, .proc/on_remote_toggle)
	controlled = TRUE

/**
 * Called when the drone is linked to a remote control
 */
/obj/vehicle/unmanned/proc/on_unlink(atom/remote_controller)
	SHOULD_CALL_PARENT(TRUE)
	UnregisterSignal(src, COMSIG_REMOTECONTROL_CHANGED)
	controlled = FALSE

///Called when remote control is taken
/obj/vehicle/unmanned/proc/on_remote_toggle(datum/source, is_on, mob/user)
	SIGNAL_HANDLER
	if(unmanned_flags & HAS_LIGHTS)
		set_light_on(is_on)
	if(unmanned_flags & GIVE_NIGHT_VISION)
		if(is_on)
			ADD_TRAIT(user, TRAIT_SEE_IN_DARK, UNMANNED_VEHICLE)
		else
			REMOVE_TRAIT(user, TRAIT_SEE_IN_DARK, UNMANNED_VEHICLE)

///Checks if we can or already have a bullet loaded that we can shoot
/obj/vehicle/unmanned/proc/load_into_chamber()
	if(in_chamber)
		return TRUE //Already set!
	if(current_rounds <= 0)
		return FALSE
	in_chamber = new /obj/projectile(src) //New bullet!
	in_chamber.generate_bullet(ammo)
	return TRUE


///Check if we have/create a new bullet and fire it at an atom target
/obj/vehicle/unmanned/proc/fire_shot(atom/target, mob/user)
	if(!COOLDOWN_CHECK(src, fire_cooldown))
		return FALSE
	if(load_into_chamber() && istype(in_chamber, /obj/projectile))
		//Setup projectile
		in_chamber.original_target = target
		in_chamber.def_zone = pick("chest","chest","chest","head")
		//Shoot at the thing
		playsound(loc, gunnoise, 75, 1)
		in_chamber.fire_at(target, src, null, ammo.max_range, ammo.shell_speed)
		in_chamber = null
		COOLDOWN_START(src, fire_cooldown, fire_delay)
		current_rounds--
		hud_set_uav_ammo()
	return TRUE

/obj/vehicle/unmanned/post_crush_act(mob/living/carbon/xenomorph/charger, datum/action/xeno_action/ready_charge/charge_datum)
	take_damage(charger.xeno_caste.melee_damage * charger.xeno_melee_damage_modifier, BRUTE, "melee")

/obj/vehicle/unmanned/punch_act(mob/living/carbon/xenomorph/X, damage, target_zone)
	X.do_attack_animation(src, ATTACK_EFFECT_YELLOWPUNCH)
	X.do_attack_animation(src, ATTACK_EFFECT_DISARM2)
	attack_generic(X, damage * 4, BRUTE, "", FALSE) //Deals 4 times regular damage to uavs
	X.visible_message(span_xenodanger("\The [X] smashes [src] with a devastating punch!"), \
		span_xenodanger("We smash [src] with a devastating punch!"), visible_message_flags = COMBAT_MESSAGE)
	playsound(src, pick('sound/effects/bang.ogg','sound/effects/metal_crash.ogg','sound/effects/meteorimpact.ogg'), 50, 1)
	Shake(4, 4, 2 SECONDS)

/obj/vehicle/unmanned/flamer_fire_act()
	take_damage(20, BURN, "fire")

/obj/vehicle/unmanned/fire_act()
	take_damage(20, BURN, "fire")

/obj/vehicle/unmanned/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_ACID))
		take_damage(20 * S.strength)

/obj/vehicle/unmanned/medium
	name = "medium unmanned vehicle"
	icon_state = "medium_uv"
	move_delay = 3
	max_rounds = 200
	max_integrity = 400

/obj/vehicle/unmanned/heavy
	name = "heavy unmanned vehicle"
	icon_state = "heavy_uv"
	move_delay = 3.5
	max_rounds = 200
	max_integrity = 600
