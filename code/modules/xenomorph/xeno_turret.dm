
/obj/structure/xeno/xeno_turret
	icon = 'icons/Xeno/acid_turret.dmi'
	icon_state = XENO_TURRET_ACID_ICONSTATE
	name = "acid turret"
	desc = "A menacing looking construct of resin, it seems to be alive. It fires acid against intruders."
	bound_width = 32
	bound_height = 32
	obj_integrity = 600
	max_integrity = 1500
	layer = ABOVE_MOB_LAYER
	density = TRUE
	resistance_flags = UNACIDABLE | DROPSHIP_IMMUNE |PORTAL_IMMUNE
	xeno_structure_flags = IGNORE_WEED_REMOVAL|HAS_OVERLAY
	allow_pass_flags = PASS_AIR|PASS_THROW
	///What kind of spit it uses
	var/datum/ammo/ammo = /datum/ammo/xeno/acid/heavy/turret
	///Range of the turret
	var/range = 7
	///Target of the turret
	var/atom/hostile
	///Last target of the turret
	var/atom/last_hostile
	///Potential list of targets found by scan
	var/list/atom/potential_hostiles
	///Fire rate of the target in ticks
	var/firerate = 5
	///The last time the sentry did a scan
	var/last_scan_time
	///light color that gets set in initialize
	var/light_initial_color = LIGHT_COLOR_GREEN
	///For minimap icon change if sentry is firing
	var/firing

///Change minimap icon if its firing or not firing
/obj/structure/xeno/xeno_turret/update_minimap_icon()
	SSminimaps.remove_marker(src)
	SSminimaps.add_marker(src, MINIMAP_FLAG_XENO, image('icons/UI_icons/map_blips.dmi', null, "xeno_turret[firing ? "_firing" : "_passive"]", MINIMAP_BLIPS_LAYER))

/obj/structure/xeno/xeno_turret/Initialize(mapload, _hivenumber)
	. = ..()
	ammo = GLOB.ammo_list[ammo]
	potential_hostiles = list()
	LAZYADDASSOC(GLOB.xeno_resin_turrets_by_hive, hivenumber, src)
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/automatedfire/xeno_turret_autofire, firerate)
	RegisterSignal(src, COMSIG_AUTOMATIC_SHOOTER_SHOOT, PROC_REF(shoot))
	RegisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_HIJACKED, PROC_REF(destroy_on_hijack))
	if(light_initial_color)
		set_light(2, 2, light_initial_color)
	update_minimap_icon()
	update_icon()

///Signal handler to delete the turret when the alamo is hijacked
/obj/structure/xeno/xeno_turret/proc/destroy_on_hijack()
	SIGNAL_HANDLER
	qdel(src)

/obj/structure/xeno/xeno_turret/obj_destruction(damage_amount, damage_type, damage_flag, mob/living/blame_mob)
	if(damage_amount) //Spawn the gas only if we actually get destroyed by damage
		var/datum/effect_system/smoke_spread/xeno/acid/opaque/smoke = new(get_turf(src))
		smoke.set_up(1, get_turf(src))
		smoke.start()
	return ..()

/obj/structure/xeno/xeno_turret/Destroy()
	GLOB.xeno_resin_turrets_by_hive[hivenumber] -= src
	set_hostile(null)
	set_last_hostile(null)
	STOP_PROCESSING(SSobj, src)
	playsound(loc,'sound/effects/alien/turret_death.ogg', 70)
	return ..()

/obj/structure/xeno/xeno_turret/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(1500, BRUTE, BOMB)
		if(EXPLODE_HEAVY)
			take_damage(750, BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(300, BRUTE, BOMB)

/obj/structure/xeno/xeno_turret/fire_act(burn_level)
	take_damage(burn_level * 2, BURN, FIRE)
	ENABLE_BITFIELD(resistance_flags, ON_FIRE)

/obj/structure/xeno/xeno_turret/update_overlays()
	. = ..()
	if(!(xeno_structure_flags & HAS_OVERLAY))
		return
	if(obj_integrity <= max_integrity / 2)
		. += image('icons/Xeno/acid_turret.dmi', src, "+turret_damage")
	if(CHECK_BITFIELD(resistance_flags, ON_FIRE))
		. += image('icons/Xeno/acid_turret.dmi', src, "+turret_on_fire")

/obj/structure/xeno/xeno_turret/process()
	//Turrets regen some HP, every 2 sec
	if(obj_integrity < max_integrity)
		obj_integrity = min(obj_integrity + TURRET_HEALTH_REGEN, max_integrity)
		update_icon()
		DISABLE_BITFIELD(resistance_flags, ON_FIRE)
	if(world.time > last_scan_time + TURRET_SCAN_FREQUENCY)
		scan()
		last_scan_time = world.time
	if(!length(potential_hostiles))
		return
	set_hostile(get_target())
	if (!hostile)
		if(last_hostile)
			set_last_hostile(null)
		return
	if(TIMER_COOLDOWN_FINISHED(src, COOLDOWN_XENO_TURRETS_ALERT))
		GLOB.hive_datums[hivenumber].xeno_message("Our [name] is attacking a nearby hostile [hostile] at [get_area(hostile)] (X: [hostile.x], Y: [hostile.y]).", "xenoannounce", 5, FALSE, hostile, 'sound/voice/alien/help1.ogg', FALSE, null, /atom/movable/screen/arrow/turret_attacking_arrow)
		TIMER_COOLDOWN_START(src, COOLDOWN_XENO_TURRETS_ALERT, 20 SECONDS)
	if(hostile != last_hostile)
		set_last_hostile(hostile)
		SEND_SIGNAL(src, COMSIG_AUTOMATIC_SHOOTER_START_SHOOTING_AT)

/obj/structure/xeno/xeno_turret/attackby(obj/item/I, mob/living/user, params)
	if(I.item_flags & NOBLUDGEON || !isliving(user))
		return attack_hand(user)

	user.changeNext_move(I.attack_speed)
	user.do_attack_animation(src, used_item = I)

	var/damage = I.force
	var/multiplier = 1
	if(I.damtype == BURN) //Burn damage deals extra vs resin structures (mostly welders).
		multiplier += 1

	damage *= max(0, multiplier)
	take_damage(damage, I.damtype, MELEE)
	playsound(src, SFX_ALIEN_RESIN_BREAK, 25)

///Signal handler for hard del of hostile
/obj/structure/xeno/xeno_turret/proc/unset_hostile()
	SIGNAL_HANDLER
	hostile = null

///Signal handler for hard del of last_hostile
/obj/structure/xeno/xeno_turret/proc/unset_last_hostile()
	SIGNAL_HANDLER
	last_hostile = null

///Setter for hostile with hard del in mind
/obj/structure/xeno/xeno_turret/proc/set_hostile(_hostile)
	if(hostile != _hostile)
		hostile = _hostile
		RegisterSignal(hostile, COMSIG_QDELETING, PROC_REF(unset_hostile))

///Setter for last_hostile with hard del in mind
/obj/structure/xeno/xeno_turret/proc/set_last_hostile(_last_hostile)
	if(last_hostile)
		UnregisterSignal(last_hostile, COMSIG_QDELETING)
	last_hostile = _last_hostile

///Look for the closest human in range and in light of sight. If no human is in range, will look for xenos of other hives
/obj/structure/xeno/xeno_turret/proc/get_target()
	var/distance = range + 0.5 //we add 0.5 so if a potential target is at range, it is accepted by the system
	var/buffer_distance
	for (var/atom/nearby_hostile AS in potential_hostiles)
		if(isliving(nearby_hostile))
			var/mob/living/nearby_living_hostile = nearby_hostile
			if(nearby_living_hostile.stat == DEAD)
				continue
		if(HAS_TRAIT(nearby_hostile, TRAIT_TURRET_HIDDEN))
			continue
		buffer_distance = get_dist(nearby_hostile, src)
		if(distance <= buffer_distance) //If we already found a target that's closer
			continue
		if(check_path(get_step_towards(src, nearby_hostile), nearby_hostile, PASS_PROJECTILE) != get_turf(nearby_hostile)) //xeno turret seems to not care about actual sight, for whatever reason
			continue
		distance = buffer_distance
		. = nearby_hostile

///Populates the target list on process
/obj/structure/xeno/xeno_turret/proc/scan()
	potential_hostiles.Cut()
	for (var/mob/living/carbon/human/nearby_human AS in cheap_get_humans_near(src, TURRET_SCAN_RANGE))
		if(nearby_human.stat == DEAD)
			continue
		if(nearby_human.get_xeno_hivenumber() == hivenumber)
			continue
		potential_hostiles += nearby_human
	for (var/mob/living/carbon/xenomorph/nearby_xeno AS in cheap_get_xenos_near(src, TURRET_SCAN_RANGE))
		if(GLOB.hive_datums[hivenumber] == nearby_xeno.hive)
			continue
		if(nearby_xeno.stat == DEAD)
			continue
		potential_hostiles += nearby_xeno
	for(var/obj/vehicle/unmanned/vehicle AS in GLOB.unmanned_vehicles)
		if(vehicle.z == z && get_dist(vehicle, src) <= TURRET_SCAN_RANGE)
			potential_hostiles += vehicle
	for(var/obj/vehicle/sealed/mecha/mech AS in GLOB.mechas_list)
		if(mech.z == z && get_dist(mech, src) <= TURRET_SCAN_RANGE)
			potential_hostiles += mech

///Signal handler to make the turret shoot at its target
/obj/structure/xeno/xeno_turret/proc/shoot()
	SIGNAL_HANDLER
	if(!hostile)
		SEND_SIGNAL(src, COMSIG_AUTOMATIC_SHOOTER_STOP_SHOOTING_AT)
		firing = FALSE
		update_minimap_icon()
		return
	face_atom(hostile)
	var/atom/movable/projectile/newshot = new(loc)
	newshot.generate_bullet(ammo)
	newshot.def_zone = pick(GLOB.base_miss_chance)
	newshot.fire_at(hostile, null, src, ammo.max_range, ammo.shell_speed)
	if(istype(ammo, /datum/ammo/xeno/hugger))
		var/datum/ammo/xeno/hugger/hugger_ammo = ammo
		newshot.color = initial(hugger_ammo.hugger_type.color)
		hugger_ammo.hivenumber = hivenumber
	firing = TRUE
	update_minimap_icon()

/obj/structure/xeno/xeno_turret/sticky
	name = "Sticky resin turret"
	icon = 'icons/Xeno/acid_turret.dmi'
	icon_state = XENO_TURRET_STICKY_ICONSTATE
	desc = "A menacing looking construct of resin, it seems to be alive. It fires resin against intruders."
	light_initial_color = LIGHT_COLOR_PURPLE
	ammo = /datum/ammo/xeno/sticky/turret
	firerate = 5

/obj/structure/xeno/xeno_turret/hugger_turret
	name = "hugger turret"
	icon_state = "hugger_turret"
	desc = "A menacing looking construct of resin, it seems to be alive. It fires huggers against intruders."
	obj_integrity = 400
	max_integrity = 400
	light_initial_color = LIGHT_COLOR_BROWN
	ammo = /datum/ammo/xeno/hugger
	firerate = 5 SECONDS
