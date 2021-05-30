/obj/structure/xeno
	///Bitflags specific to xeno structures
	var/xeno_structure_flags = NONE
	///Acid spire the structure is connected to
	var/obj/structure/xeno/resin/acid_spire/connected_spire = null

///Connects the structure to an acid spire
/obj/structure/xeno/proc/connect_to_acid_spire(run_link_action = TRUE)
	var/found_spire = acid_spire_in_range()
	if(!found_spire)
		return FALSE

	connected_spire = found_spire
	xeno_structure_flags |= ACID_SPIRE_CONNECTED
	RegisterSignal(connected_spire, COMSIG_LIVING_ACID_SPIRE_RANGE_CHANGED, .proc/check_spire_connection)
	acid_spire_link(run_link_action)

	return TRUE

///Disconnects the structure from the currently connected acid spire
/obj/structure/xeno/proc/disconnect_from_acid_spire(run_unlink_action = TRUE)
	if(!(xeno_structure_flags & ACID_SPIRE_CONNECTED))
		return

	message_admins("disconnect action")
	acid_spire_unlink(run_unlink_action)
	xeno_structure_flags &= ~ACID_SPIRE_CONNECTED
	UnregisterSignal(connected_spire, COMSIG_LIVING_ACID_SPIRE_RANGE_CHANGED)
	connected_spire = null

/**
 * Checks if the structure can remain connected to the acid spire when its range changes
 * and if not, checks if it can connect to a new one
 */
/obj/structure/xeno/proc/check_spire_connection(datum/source)
	var/obj/structure/xeno/resin/acid_spire/checked_spire = source
	if(get_dist(src, checked_spire) < checked_spire.effective_range)
		return

	//not running link and unlink actions here
	disconnect_from_acid_spire(FALSE)
	if(!connect_to_acid_spire(FALSE)) //run unlink action only if the structure doesn't switch to a different spire
		acid_spire_unlink()

///Checks if an acid spire is in range of the structure and returns it
/obj/structure/xeno/proc/acid_spire_in_range()
	for(var/obj/structure/xeno/resin/acid_spire/checked_spire AS in GLOB.acid_spires)
		var/spire_distance = get_dist(src, checked_spire)
		if(spire_distance > checked_spire.effective_range)
			continue
		return checked_spire

///Does stuff when a structure connects to an acid spire
/obj/structure/xeno/proc/acid_spire_link(should_run = TRUE)
	if(!should_run)
		return FALSE
	return TRUE

///Does stuff when a structure disconnects an acid spire
/obj/structure/xeno/proc/acid_spire_unlink(should_run = TRUE)
	if(!should_run)
		return FALSE
	return TRUE

/**
 * Proc that is ran every time SSacid_spires ticks.
 * If it returns FALSE, the subsystem will disconnect the structure from the acid spires network.
 * This is useful, for example, when making structures that drain acid each tick
 * and automatically stop their effects when not enough acid is available.
 */
/obj/structure/xeno/proc/on_acid_spires_tick()
	return TRUE

/obj/structure/xeno/resin
	hit_sound = "alien_resin_break"
	layer = RESIN_STRUCTURE_LAYER
	resistance_flags = UNACIDABLE


/obj/structure/xeno/resin/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(210)
		if(EXPLODE_HEAVY)
			take_damage(140)
		if(EXPLODE_LIGHT)
			take_damage(70)

/obj/structure/xeno/resin/attack_hand(mob/living/user)
	to_chat(user, "<span class='warning'>You scrape ineffectively at \the [src].</span>")
	return TRUE

/obj/structure/xeno/resin/flamer_fire_act()
	take_damage(10, BURN, "fire")

/obj/structure/xeno/resin/fire_act()
	take_damage(10, BURN, "fire")


/obj/structure/xeno/resin/silo
	name = "resin silo"
	icon = 'icons/Xeno/resin_silo.dmi'
	icon_state = "weed_silo"
	desc = "A slimy, oozy resin bed filled with foul-looking egg-like ...things."
	bound_width = 96
	bound_height = 96
	max_integrity = 1000
	resistance_flags = UNACIDABLE | DROPSHIP_IMMUNE
	///How many larva points one silo produce in one minute
	var/larva_spawn_rate = 0.5
	var/turf/center_turf
	var/datum/hive_status/associated_hive
	var/silo_area
	var/number_silo
	COOLDOWN_DECLARE(silo_damage_alert_cooldown)
	COOLDOWN_DECLARE(silo_proxy_alert_cooldown)

/obj/structure/xeno/resin/silo/Initialize()
	. = ..()
	var/static/number = 1
	name = "[name] [number]"
	number_silo = number
	number++
	GLOB.xeno_resin_silos += src
	center_turf = get_step(src, NORTHEAST)
	if(!istype(center_turf))
		center_turf = loc

	for(var/i in RANGE_TURFS(XENO_SILO_DETECTION_RANGE, src))
		RegisterSignal(i, COMSIG_ATOM_ENTERED, .proc/resin_silo_proxy_alert)

	SSminimaps.add_marker(src, z, hud_flags = MINIMAP_FLAG_XENO, iconstate = "silo")
	return INITIALIZE_HINT_LATELOAD


/obj/structure/xeno/resin/silo/LateInitialize()
	. = ..()
	if(!locate(/obj/effect/alien/weeds) in center_turf)
		new /obj/effect/alien/weeds/node(center_turf)
	associated_hive = GLOB.hive_datums[XENO_HIVE_NORMAL]
	if(associated_hive)
		RegisterSignal(associated_hive, list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK), .proc/is_burrowed_larva_host)
		if(length(GLOB.xeno_resin_silos) == 1)
			associated_hive.give_larva_to_next_in_queue()
		associated_hive.handle_silo_death_timer()
	silo_area = get_area(src)
	var/turf/tunnel_turf = get_step(center_turf, NORTH)
	if(tunnel_turf.can_dig_xeno_tunnel())
		var/obj/structure/xeno/tunnel/newt = new(tunnel_turf)
		newt.tunnel_desc = "[AREACOORD_NO_Z(newt)]"
		newt.name += " [name]"

/obj/structure/xeno/resin/silo/obj_destruction(damage_amount, damage_type, damage_flag)
	. = ..()
	if(associated_hive)
		UnregisterSignal(associated_hive, list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK))
		associated_hive.xeno_message("A resin silo has been destroyed at [AREACOORD_NO_Z(src)]!", "xenoannounce", 5, FALSE,src.loc, 'sound/voice/alien_help2.ogg',FALSE , null, /obj/screen/arrow/silo_damaged_arrow)
		associated_hive.handle_silo_death_timer()
		associated_hive = null
		notify_ghosts("\ A resin silo has been destroyed at [AREACOORD_NO_Z(src)]!", source = get_turf(src), action = NOTIFY_JUMP)
		playsound(loc,'sound/effects/alien_egg_burst.ogg', 75)


/obj/structure/xeno/resin/silo/Destroy()
	GLOB.xeno_resin_silos -= src

	for(var/i in contents)
		var/atom/movable/AM = i
		AM.forceMove(get_step(center_turf, pick(CARDINAL_ALL_DIRS)))

	silo_area = null
	center_turf = null
	STOP_PROCESSING(SSslowprocess, src)
	return ..()


/obj/structure/xeno/resin/silo/examine(mob/user)
	. = ..()
	var/current_integrity = (obj_integrity / max_integrity) * 100
	switch(current_integrity)
		if(0 to 20)
			to_chat(user, "<span class='warning'>It's barely holding, there's leaking oozes all around, and most eggs are broken. Yet it is not inert.</span>")
		if(20 to 40)
			to_chat(user, "<span class='warning'>It looks severely damaged, its movements slow.</span>")
		if(40 to 60)
			to_chat(user, "<span class='warning'>It's quite beat up, but it seems alive.</span>")
		if(60 to 80)
			to_chat(user, "<span class='warning'>It's slightly damaged, but still seems healthy.</span>")
		if(80 to 100)
			to_chat(user, "<span class='info'>It appears in good shape, pulsating healthily.</span>")


/obj/structure/xeno/resin/silo/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()

	//We took damage, so it's time to start regenerating if we're not already processing
	if(!CHECK_BITFIELD(datum_flags, DF_ISPROCESSING))
		START_PROCESSING(SSslowprocess, src)

	resin_silo_damage_alert()

/obj/structure/xeno/resin/silo/proc/resin_silo_damage_alert()
	if(!COOLDOWN_CHECK(src, silo_damage_alert_cooldown))
		return

	associated_hive.xeno_message("Our [name] at [AREACOORD_NO_Z(src)] is under attack! It has [obj_integrity]/[max_integrity] Health remaining.", "xenoannounce", 5, FALSE, src, 'sound/voice/alien_help1.ogg',FALSE, null, /obj/screen/arrow/silo_damaged_arrow)
	COOLDOWN_START(src, silo_damage_alert_cooldown, XENO_SILO_HEALTH_ALERT_COOLDOWN) //set the cooldown.

///Alerts the Hive when hostiles get too close to their resin silo
/obj/structure/xeno/resin/silo/proc/resin_silo_proxy_alert(datum/source, atom/hostile)
	SIGNAL_HANDLER

	if(!COOLDOWN_CHECK(src, silo_proxy_alert_cooldown)) //Proxy alert triggered too recently; abort
		return

	if(!isliving(hostile))
		return

	var/mob/living/living_triggerer = hostile
	if(living_triggerer.stat == DEAD) //We don't care about the dead
		return

	if(isxeno(hostile))
		var/mob/living/carbon/xenomorph/X = hostile
		if(X.hive == associated_hive) //Trigger proxy alert only for hostile xenos
			return

	associated_hive.xeno_message("Our [name] has detected a nearby hostile [hostile] at [get_area(hostile)] (X: [hostile.x], Y: [hostile.y]).", "xenoannounce", 5, FALSE, hostile, 'sound/voice/alien_help1.ogg', FALSE, null, /obj/screen/arrow/leader_tracker_arrow)
	COOLDOWN_START(src, silo_proxy_alert_cooldown, XENO_SILO_DETECTION_COOLDOWN) //set the cooldown.

/obj/structure/xeno/resin/silo/process()
	//Regenerate if we're at less than max integrity
	if(obj_integrity < max_integrity)
		obj_integrity = min(obj_integrity + 25, max_integrity) //Regen 5 HP per sec

/obj/structure/xeno/resin/silo/proc/is_burrowed_larva_host(datum/source, list/mothers, list/silos)
	SIGNAL_HANDLER
	if(associated_hive)
		silos += src


//*******************
//Corpse recyclinging
//*******************
/obj/structure/xeno/resin/silo/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!isxeno(user)) //only xenos can deposit corpses
		return

	if(!istype(I, /obj/item/grab))
		return

	var/obj/item/grab/G = I
	if(!iscarbon(G.grabbed_thing))
		return
	var/mob/living/carbon/victim = G.grabbed_thing
	if(!(ishuman(victim) || ismonkey(victim))) //humans and monkeys only for now
		to_chat(user, "<span class='notice'>[src] can only process humanoid anatomies!</span>")
		return

	if(victim.stat != DEAD)
		to_chat(user, "<span class='notice'>[victim] is not dead!</span>")
		return

	if(victim.chestburst)
		to_chat(user, "<span class='notice'>[victim] has already been exhausted to incubate a sister!</span>")
		return

	if(issynth(victim))
		to_chat(user, "<span class='notice'>[victim] has no useful biomass for us.</span>")
		return

	visible_message("[user] starts putting [victim] into [src].", 3)

	if(!do_after(user, 20, FALSE, victim, BUSY_ICON_DANGER) || QDELETED(src))
		return

	victim.chestburst = 2 //So you can't reuse corpses if the silo is destroyed
	victim.update_burst()
	victim.forceMove(src)

	shake(4 SECONDS)

	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	xeno_job.add_job_points(1.75) //4.5 corpses per burrowed; 8 points per larva

	log_combat(victim, user, "was consumed by a resin silo")
	log_game("[key_name(victim)] was consumed by a resin silo at [AREACOORD(victim.loc)].")

	GLOB.round_statistics.xeno_silo_corpses++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "xeno_silo_corpses")

/// Make the silo shake
/obj/structure/xeno/resin/silo/proc/shake(duration)
	/// How important should be the shaking movement
	var/offset = prob(50) ? -2 : 2
	/// Track the last position of the silo for the animation
	var/old_pixel_x = pixel_x
	/// Sound played when shaking
	var/shake_sound = rand(1, 100) == 1 ? 'sound/machines/blender.ogg' : 'sound/machines/juicer.ogg'
	if(prob(1))
		playsound(src, shake_sound, 25, TRUE)
	animate(src, pixel_x = pixel_x + offset, time = 2, loop = -1) //start shaking
	addtimer(CALLBACK(src, .proc/stop_shake, old_pixel_x), duration)

/// Stop the shaking animation
/obj/structure/xeno/resin/silo/proc/stop_shake(old_px)
	animate(src)
	pixel_x = old_px

/obj/structure/xeno/resin/silo/small_silo
	name = "small resin silo"
	icon_state = "purple_silo"
	max_integrity = 500
	larva_spawn_rate = 0.25

/obj/structure/xeno/resin/xeno_turret
	icon = 'icons/Xeno/acidturret.dmi'
	icon_state = "acid_turret"
	name = "resin acid turret"
	desc = "A menacing looking construct of resin, it seems to be alive. It fires acid against intruders."
	bound_width = 32
	bound_height = 32
	obj_integrity = 600
	max_integrity = 1500
	layer =  ABOVE_MOB_LAYER
	density = TRUE
	resistance_flags = UNACIDABLE | DROPSHIP_IMMUNE
	xeno_structure_flags = ACID_SPIRE_CONNECTABLE
	var/turret_acid_use = 20
	///The hive it belongs to
	var/datum/hive_status/associated_hive
	///What kind of spit it uses
	var/datum/ammo/ammo
	///Range of the turret
	var/range = 7
	///Target of the turret
	var/mob/living/hostile
	///Last target of the turret
	var/mob/living/last_hostile
	///Potential list of targets found by scan
	var/list/mob/living/potential_hostiles
	///Fire rate of the target in ticks
	var/firerate = 5
	///The last time the sentry did a scan
	var/last_scan_time

/obj/structure/xeno/resin/xeno_turret/Initialize(mapload, hivenumber = XENO_HIVE_NORMAL)
	. = ..()
	ammo = GLOB.ammo_list[/datum/ammo/xeno/acid/heavy/turret]
	ammo.max_range = range + 2 //To prevent funny gamers to abuse the turrets that easily
	potential_hostiles = list()
	associated_hive = GLOB.hive_datums[hivenumber]
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/automatedfire/xeno_turret_autofire, firerate)
	RegisterSignal(src, COMSIG_AUTOMATIC_SHOOTER_SHOOT, .proc/shoot)
	RegisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_HIJACKED, .proc/destroy_on_hijack)
	set_light(2, 2, LIGHT_COLOR_GREEN)
	update_icon()

///Signal handler to delete the turret when the alamo is hijacked
/obj/structure/xeno/resin/xeno_turret/proc/destroy_on_hijack()
	SIGNAL_HANDLER
	qdel(src)

/obj/structure/xeno/resin/xeno_turret/obj_destruction(damage_amount, damage_type, damage_flag)
	if(damage_amount) //Spawn the gas only if we actually get destroyed by damage
		var/datum/effect_system/smoke_spread/xeno/smoke = new /datum/effect_system/smoke_spread/xeno/acid(src)
		smoke.set_up(1, get_turf(src))
		smoke.start()
	return ..()

/obj/structure/xeno/resin/xeno_turret/Destroy()
	set_hostile(null)
	set_last_hostile(null)
	STOP_PROCESSING(SSobj, src)
	playsound(loc,'sound/effects/xeno_turret_death.ogg', 70)
	return ..()

/obj/structure/xeno/resin/xeno_turret/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(1500)
		if(EXPLODE_HEAVY)
			take_damage(750)
		if(EXPLODE_LIGHT)
			take_damage(300)

/obj/structure/xeno/resin/xeno_turret/flamer_fire_act()
	take_damage(60, BURN, "fire")
	ENABLE_BITFIELD(resistance_flags, ON_FIRE)

/obj/structure/xeno/resin/xeno_turret/fire_act()
	take_damage(60, BURN, "fire")
	ENABLE_BITFIELD(resistance_flags, ON_FIRE)

/obj/structure/xeno/resin/xeno_turret/update_overlays()
	. = ..()
	if(obj_integrity <= max_integrity / 2)
		. += image('icons/Xeno/acidturret.dmi', src, "+turret_damage")
	if(CHECK_BITFIELD(resistance_flags, ON_FIRE))
		. += image('icons/Xeno/acidturret.dmi', src, "+turret_on_fire")

/obj/structure/xeno/resin/xeno_turret/process()
	//Turrets regen some HP, every 2 sec
	if(obj_integrity < max_integrity)
		obj_integrity = min(obj_integrity + TURRET_HEALTH_REGEN, max_integrity)
		update_icon()
		DISABLE_BITFIELD(resistance_flags, ON_FIRE)
	if(world.time > last_scan_time + TURRET_SCAN_FREQUENCY)
		scan()
		last_scan_time = world.time
	if(!potential_hostiles.len)
		return
	set_hostile(get_target())
	if (!hostile)
		if(last_hostile)
			set_last_hostile(null)
		return
	if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_XENO_TURRETS_ALERT))
		associated_hive.xeno_message("Our [name] is attacking a nearby hostile [hostile] at [get_area(hostile)] (X: [hostile.x], Y: [hostile.y]).", "xenoannounce", 5, FALSE, hostile, 'sound/voice/alien_help1.ogg', FALSE, null, /obj/screen/arrow/turret_attacking_arrow)
		TIMER_COOLDOWN_START(src, COOLDOWN_XENO_TURRETS_ALERT, 20 SECONDS)
	if(hostile != last_hostile)
		set_last_hostile(hostile)
		SEND_SIGNAL(src, COMSIG_AUTOMATIC_SHOOTER_START_SHOOTING_AT)

/obj/structure/xeno/resin/xeno_turret/on_acid_spires_tick()
	. = ..()

	if(obj_integrity == max_integrity)
		return TRUE

	if(!SSacid_spires.use_acid(turret_acid_use))
		return FALSE

	obj_integrity += min(max_integrity * TURRET_ACID_SPIRE_HEALTH_REGEN, max_integrity - obj_integrity)
	update_icon()

/obj/structure/xeno/resin/xeno_turret/attackby(obj/item/I, mob/living/user, params)
	if(I.flags_item & NOBLUDGEON || !isliving(user))
		return attack_hand(user)

	user.changeNext_move(I.attack_speed)
	user.do_attack_animation(src, used_item = I)

	var/damage = I.force
	var/multiplier = 1
	if(I.damtype == "fire") //Burn damage deals extra vs resin structures (mostly welders).
		multiplier += 1

	if(istype(I, /obj/item/tool/pickaxe/plasmacutter) && !user.do_actions)
		var/obj/item/tool/pickaxe/plasmacutter/P = I
		if(P.start_cut(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD))
			multiplier += PLASMACUTTER_RESIN_MULTIPLIER
			P.cut_apart(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD)

	damage *= max(0, multiplier)
	take_damage(damage)
	playsound(src, "alien_resin_break", 25)

///Signal handler for hard del of hostile
/obj/structure/xeno/resin/xeno_turret/proc/unset_hostile()
	SIGNAL_HANDLER
	hostile = null

///Signal handler for hard del of last_hostile
/obj/structure/xeno/resin/xeno_turret/proc/unset_last_hostile()
	SIGNAL_HANDLER
	last_hostile = null

///Setter for hostile with hard del in mind
/obj/structure/xeno/resin/xeno_turret/proc/set_hostile(_hostile)
	if(hostile != _hostile)
		hostile = _hostile
		RegisterSignal(hostile, COMSIG_PARENT_QDELETING, .proc/unset_hostile)

///Setter for last_hostile with hard del in mind
/obj/structure/xeno/resin/xeno_turret/proc/set_last_hostile(_last_hostile)
	if(last_hostile)
		UnregisterSignal(last_hostile, COMSIG_PARENT_QDELETING)
	last_hostile = _last_hostile

///Look for the closest human in range and in light of sight. If no human is in range, will look for xenos of other hives
/obj/structure/xeno/resin/xeno_turret/proc/get_target()
	var/distance = range + 0.5 //we add 0.5 so if a potential target is at range, it is accepted by the system
	var/buffer_distance
	var/list/turf/path = list()
	for (var/mob/living/nearby_hostile AS in potential_hostiles)
		if(nearby_hostile.stat == DEAD)
			continue
		buffer_distance = get_dist(nearby_hostile, src)
		if (distance <= buffer_distance) //If we already found a target that's closer
			continue
		path = getline(src, nearby_hostile)
		path -= get_turf(src)
		if(!path.len) //Can't shoot if it's on the same turf
			continue
		var/blocked = FALSE
		for(var/turf/T AS in path)
			if(IS_OPAQUE_TURF(T) || T.density && T.throwpass == FALSE)
				blocked = TRUE
				break //LoF Broken; stop checking; we can't proceed further.

			for(var/obj/machinery/MA in T)
				if(MA.opacity || MA.density && MA.throwpass == FALSE)
					blocked = TRUE
					break //LoF Broken; stop checking; we can't proceed further.

			for(var/obj/structure/S in T)
				if(S.opacity || S.density && S.throwpass == FALSE )
					blocked = TRUE
					break //LoF Broken; stop checking; we can't proceed further.
		if(!blocked)
			distance = buffer_distance
			. = nearby_hostile

///Return TRUE if a possible target is near
/obj/structure/xeno/resin/xeno_turret/proc/scan()
	potential_hostiles.Cut()
	for (var/mob/living/carbon/human/nearby_human AS in cheap_get_humans_near(src, TURRET_SCAN_RANGE))
		if(nearby_human.stat == DEAD)
			continue
		potential_hostiles += nearby_human
	for (var/mob/living/carbon/xenomorph/nearby_xeno AS in cheap_get_xenos_near(src, range))
		if(associated_hive == nearby_xeno.hive) //Xenomorphs not in our hive will be attacked as well!
			continue
		if(nearby_xeno.stat == DEAD)
			continue
		potential_hostiles += nearby_xeno


///Signal handler to make the turret shoot at its target
/obj/structure/xeno/resin/xeno_turret/proc/shoot()
	SIGNAL_HANDLER
	if(!hostile)
		SEND_SIGNAL(src, COMSIG_AUTOMATIC_SHOOTER_STOP_SHOOTING_AT)
		return
	face_atom(hostile)
	var/obj/projectile/newshot = new(loc)
	newshot.generate_bullet(ammo)
	newshot.permutated += src
	newshot.def_zone = pick(GLOB.base_miss_chance)
	newshot.fire_at(hostile, src, null, ammo.max_range, ammo.shell_speed)

/**
 * TODO
 * Acid spires buff buildings within range
 *  - acid spires' buff is a cumulative amount of all acid spires' strength
 *  - buffed buildings glow brightly green, more than usual
 *  - marines can destroy acid spires, which decreases their strength, but the network remain intact
 *  - marines can put a miner next to destroyed acid spires for req points
 * 		- the miner will be dropped down by a call from an SL
 *  - acid spires increase fill speed of acid wells within their effective range
 *  - xenos have acid reserves that are drained when they rest, in exchange of increased regeneration
 */

#define NODE_RANGE_GROUPING_COEF 4

/obj/structure/xeno/resin/acid_spire
	name = "acid spire"
	icon = 'icons/Xeno/2x2_xeno_structures.dmi'
	icon_state = "tower"
	desc = "A weird glowing spire..."
	bound_width = 64
	bound_height = 64
	max_integrity = 10
	density = TRUE
	resistance_flags = UNACIDABLE | DROPSHIP_IMMUNE
	light_system = STATIC_LIGHT
	///Acid nodes connected to the spire
	var/list/connected_acid_nodes = list()
	///Amount of acid that the spire produces
	var/acid_production_strength = 4
	///Range at which the spire links with other nodes
	var/effective_range = 7
	/**
	 * This makes a map of distances from acid nodes
	 * and a combined acid node strength value of the acid nodes strength
	 * that is received from nodes at a certin distance.
	 *
	 * By using this, I can have effective strength falloff based on distance from the spire and its effective range
	 * and update this efficiently whenever the effective range is changed without checking every node, just the distance
	 * and combined value.
	 */
	var/list/connected_acid_nodes_strength = list()

/obj/structure/xeno/resin/acid_spire/Initialize()
	. = ..()
	GLOB.acid_spires += src
	SSminimaps.add_marker(src, z, hud_flags = MINIMAP_FLAG_XENO, iconstate = "silo")
	set_light(6, 2, LIGHT_COLOR_ELECTRIC_GREEN)

/obj/structure/xeno/resin/acid_spire/examine(mob/user)
	. = ..()
	if(isxeno(user))
		to_chat(user, "<span class='notice'>The network currently contains <b>[SSacid_spires.stored_acid()] units of acid.</b></span>")

///connects an acid node to the spire
/obj/structure/xeno/resin/acid_spire/proc/add_acid_node(obj/effect/alien/acid_node/new_node)
	connected_acid_nodes += new_node

	var/node_index = round(get_dist(src, new_node) / NODE_RANGE_GROUPING_COEF)
	//close distances are grouped in the list
	if(!LAZYACCESS(connected_acid_nodes_strength, node_index))
		var/list/range_entry = list(
			"[node_index]" = 0
		)
		LAZYADD(connected_acid_nodes_strength, range_entry)
	connected_acid_nodes_strength["[node_index]"] += new_node.strength_increase()
	RegisterSignal(new_node, COMSIG_LIVING_ACID_NODE_DESTROYED, .proc/remove_acid_node)

	update_effective_range(new_node.effective_range_increase())

///removes an acid node from the list of nodes and updates the effective range of the spire
/obj/structure/xeno/resin/acid_spire/proc/remove_acid_node(datum/source)
	var/obj/effect/alien/acid_node/removed_node = source
	connected_acid_nodes -= removed_node

	var/node_index = round(get_dist(src, removed_node) / NODE_RANGE_GROUPING_COEF)
	connected_acid_nodes_strength["[node_index]"] -= removed_node.strength_increase()

	update_effective_range(-removed_node.effective_range_increase())

///updates the effective range of the spire with the given amount, then it updates the received strength
/obj/structure/xeno/resin/acid_spire/proc/update_effective_range(update_amount)
	effective_range = max(effective_range + update_amount, 0)
	update_linked_nodes_strength()
	SEND_SIGNAL(src, COMSIG_LIVING_ACID_SPIRE_RANGE_CHANGED)

/obj/structure/xeno/resin/acid_spire/proc/production_strength()
	return acid_production_strength

///Updates connected nodes' provided strength
/obj/structure/xeno/resin/acid_spire/proc/update_linked_nodes_strength()
	//resets and calculates the production strength again
	acid_production_strength = initial(acid_production_strength)

	for(var/range in connected_acid_nodes_strength)
		var/range_to_number = text2num(range)
		var/strength_at_index = connected_acid_nodes_strength[range]
		//strength falloff based on distance from the spire, up tp 50%
		var/effect_strength_falloff = strength_at_index/2 * min(range_to_number*NODE_RANGE_GROUPING_COEF/effective_range, 1)
		var/calculated_strength = strength_at_index - effect_strength_falloff
		acid_production_strength += calculated_strength

#undef NODE_RANGE_GROUPING_COEF
