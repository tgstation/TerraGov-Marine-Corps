/* Exotic mines - Rather than just explode, these have special effects */
/obj/item/mine/radiation
	name = "\improper MOPe radiation mine"
	desc = "The Marine Operation Penalizer irradiates the surrounding area when triggered. Uses sheets of uranium as a source of fuel. More fuel increases the range of the radiation field."
	icon_state = "radiation"
	detonation_message = "clicks, emitting a low hum."
	range = 2
	angle = 360
	duration = -1
	disarm_delay = 5 SECONDS
	undeploy_delay = 4 SECONDS	//You turn it off veeeery carefully
	deploy_delay = 2 SECONDS
	mine_features = MINE_STANDARD_FLAGS|MINE_REUSABLE|MINE_ILLEGAL|MINE_VOLATILE_DAMAGE|MINE_VOLATILE_EXPLOSION
	///Base damage of the radiation pulse, and determines severity of effects; see extra_effects()
	var/radiation_damage = 10
	///Radius of the radiation field
	var/radiation_range = 4
	///How many units of fuel are inside; each unit is 1 pulse
	var/current_fuel = 0
	///The maximum capacity of fuel units
	var/max_fuel = 3
	///Time between pulses
	var/time_between_pulses = 10 SECONDS
	///Stored reference to the timer that determines when extra_effects() is called again
	var/pulse_timer

	//Light-related vars for when the radiation glow is emitted
	light_power = 10
	light_color = COLOR_GREEN
	light_system = HYBRID_LIGHT
	light_mask_type = /atom/movable/lighting_mask/flicker

/obj/item/mine/radiation/examine(mob/user)
	. = ..()
	. += "Currently has [span_bold("[current_fuel]")] out of [span_bold("[max_fuel]")] fuel."

/obj/item/mine/radiation/attackby(obj/item/I, mob/user, params)
	. = ..()
	//While we could use a var/fuel_type instead of hard coded to use uranium, it would be a headache since only /stack/ use amount vars
	//Also no other /stack/ type apart from maybe phoron would be a good fuel candidate so why bother
	if(istype(I, /obj/item/stack/sheet/mineral/uranium))
		if(current_fuel >= max_fuel)
			balloon_alert(user, "Already full!")
			return

		var/obj/item/stack/uranium = I
		var/amount_to_transfer = max(1, min(uranium.amount, max_fuel - current_fuel))
		if(!uranium.use(amount_to_transfer))
			balloon_alert(user, "Not enough fuel!")
			return

		current_fuel += amount_to_transfer
		balloon_alert(user, current_fuel == max_fuel ? "Full!" : "[current_fuel]/[max_fuel] fuel!")
		return

/obj/item/mine/radiation/setup(mob/living/user)
	if(!current_fuel)
		balloon_alert(user, "No fuel!")
		return
	. = ..()

/obj/item/mine/radiation/disarm()
	deltimer(pulse_timer)
	light_range = 0	//Hybrid lights don't actually turn off, just have to change light_range and update
	update_light()
	return ..()

/obj/item/mine/radiation/trip_mine(atom/movable/victim)
	if(!current_fuel)
		return FALSE
	return ..()

/obj/item/mine/radiation/extra_effects(atom/movable/victim)
	if(!current_fuel)
		disarm()
		return

	current_fuel--
	new /obj/effect/temp_visual/shockwave(get_turf(src), radiation_range * 1.5)
	light_range = radiation_range * 1.5
	set_light(light_range, light_power, light_color)

	//Radiation SHALL NOT pass through walls (too much cope)
	var/list/exclusion_zone = generate_true_cone(get_turf(src), radiation_range, cone_width = angle, projectile = TRUE, air_pass = TRUE)
	for(var/turf/irradiated_turf in exclusion_zone)
		//If someone is on this turf so that the rad effect starts running Process() on creation
		var/turf_has_victim = FALSE
		for(var/atom in irradiated_turf.contents)
			//Delete any present radiation effect, the new one will replace it
			if(istype(atom, /obj/effect/temp_visual/radiation))
				qdel(atom)
				continue

			if(!iscarbon(atom))
				continue

			var/mob/living/carbon/radiation_victim = atom
			if(radiation_victim.stat == DEAD)
				continue

			//Apply initial damages of the detonation evenly in BURN and TOX, then do a fifth of it in cellular damage
			radiation_victim.apply_damages(0, radiation_damage/2, radiation_damage/2, 0, radiation_damage/5, ishuman(radiation_victim) ? pick(GLOB.human_body_parts) : null, BIO)
			radiation_victim.adjust_stagger((radiation_damage/5) SECONDS)
			radiation_victim.adjust_radiation((radiation_damage/5) SECONDS)
			turf_has_victim = TRUE

		//Delete them before the next pulse otherwise they will be iterated over in the for loops, which is unnecessary
		new /obj/effect/temp_visual/radiation(irradiated_turf, time_between_pulses - 1, turf_has_victim)

	if(!current_fuel)
		deletion_timer = addtimer(CALLBACK(src, PROC_REF(disarm)), time_between_pulses - 1, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
		return

	pulse_timer = addtimer(CALLBACK(src, PROC_REF(extra_effects)), time_between_pulses, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)

/obj/item/mine/radiation/fueled/Initialize(mapload)
	. = ..()
	current_fuel = max_fuel

/obj/effect/temp_visual/radiation
	randomdir = FALSE
	///How much damage each tick does
	var/radiation_damage = 5
	///Reference to the radiation particle effect
	var/obj/effect/abstract/particle_holder/particle_holder

/obj/effect/temp_visual/radiation/Initialize(mapload, effect_duration, turf_has_victim)
	. = ..()
	//Override the timerid value set on the object; the duration is determined by the radiation mine
	deltimer(timerid)
	timerid = QDEL_IN_STOPPABLE(src, effect_duration)
	particle_holder = new(src, /particles/radiation)
	var/static/list/connections = list(COMSIG_ATOM_ENTERED = PROC_REF(on_cross))
	AddElement(/datum/element/connect_loc, connections)
	//Begin Process() on init because it's possible someone could just not move and then the radiation functions would never start
	if(turf_has_victim)
		START_PROCESSING(SSobj, src)

///Called when an atom enters the tile this radiation effect is on
/obj/effect/temp_visual/radiation/proc/on_cross(datum/source, atom/A, oldloc, oldlocs)
	if(!isliving(A))
		return FALSE
	if(irradiate(A))
		START_PROCESSING(SSobj, src)

/obj/effect/temp_visual/radiation/process()
	if(!irradiate())
		STOP_PROCESSING(SSobj, src)

///Proc to run the radiation effects on mobs that are on the same tile as this radiation effect
/obj/effect/temp_visual/radiation/proc/irradiate(mob/living/crosser)
	var/turf/turf_to_check = get_turf(src)
	var/list/radiation_victims = turf_to_check.contents.Copy()
	var/result = FALSE	//For determining if process() should keep going

	if(crosser)
		radiation_victims.Remove(crosser)	//Remove the crosser from the list, they are already going to take damage
		result = inflict_radiation(crosser, TRUE)

		/*
		It occurred to me that if someone steps on the same tile as say, someone unconscious already dying from rads,
		they would take damage twice from the irradiate() called by Process() and then called again when a mob enters the tile
		So to prevent this unfair double dipping, we will check if this effect is already processing and skip the rest if it is
		*/
		if(datum_flags & DF_ISPROCESSING)
			return result

	for(var/mob/living/victim in radiation_victims)
		result = inflict_radiation(victim) ? TRUE : result	//In case there are multiple mobs on the same tile and one happens to be dead

	//The radiation effect will continue or start Process() if someone alive was on the tile, otherwise cease
	return result

///Separate proc to consolidate the application of radiation damage and status effects
/obj/effect/temp_visual/radiation/proc/inflict_radiation(mob/living/victim, crossing)
	if(victim.stat == DEAD)	//I still protest making the dead invulnerable to spicy air
		return FALSE

	//Not as punishing if you are just running through a radiation field
	victim.apply_damage(crossing ? radiation_damage/2 : radiation_damage, BURN, ishuman(victim) ? pick(GLOB.human_body_parts) : null, BIO)
	victim.adjust_radiation((crossing ? radiation_damage/5 : radiation_damage) SECONDS)

	if(isxeno(victim))	//Benos are immune to the radiation status effect so let's just give them a bit of stagger
		victim.adjust_stagger(radiation_damage/5 SECONDS)

	return TRUE

//Radiation dust effects
/particles/radiation
	icon = 'icons/effects/particles/generic_particles.dmi'
	icon_state = "cross"
	width = 100
	height = 100
	count = 1000
	spawning = 0.5
	lifespan = 30
	fade = 5
	fadein = 5
	position = generator(GEN_CIRCLE, 10, 10, NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(-0.01, -0.03), list(0.01, 0.03))
	scale = list(0.5, 0.5)
	spin = 5
	color = COLOR_GREEN

/obj/item/mine/shock
	name = "tesla mine"
	desc = "Delivers high voltage arcs of lightning at nearby conductive targets. Can be recharged."
	icon_state = "tesla"
	range = 3
	angle = 360
	duration = -1
	disarm_delay = 4 SECONDS
	undeploy_delay = 5 SECONDS
	deploy_delay = 5 SECONDS
	mine_features = MINE_STANDARD_FLAGS|MINE_REUSABLE|MINE_VOLATILE_DAMAGE|MINE_VOLATILE_EMP
	///The internal cell powering it
	var/obj/item/cell/battery
	///How much energy is drained from the internal cell
	var/energy_cost = 100	//Average cell holds 1000, so 10 shots
	///How long between each shot
	var/fire_delay = 0.75 SECONDS
	///Damage dealt per shot
	var/damage = 50

/obj/item/mine/shock/Initialize()
	. = ..()
	if(battery)
		battery = new battery(src)

/obj/item/mine/shock/examine(mob/user)
	. = ..()
	. += span_notice("[battery ? "Battery Charge - [PERCENT(battery.charge/battery.maxcharge)]%" : "No battery installed."]")

/obj/item/mine/shock/attackby(obj/item/I, mob/user, params)
	if(!iscell(I))
		return ..()
	if(battery)
		balloon_alert(user, "Already has one!")
		return
	user.transferItemToLoc(I, src)
	battery = I
	update_icon()

/obj/item/mine/shock/screwdriver_act(mob/living/user, obj/item/I)
	if(!battery)
		balloon_alert(user, "No battery installed!")
		return
	user.put_in_hands(battery)
	battery = null
	update_icon()

/obj/item/mine/shock/trip_mine(atom/movable/victim)
	if(!battery?.charge)
		return FALSE
	return ..()

/obj/item/mine/shock/extra_effects(atom/movable/victim)
	if(!battery?.charge || battery.charge < energy_cost)
		playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, sound_range = 7)
		balloon_alert_to_viewers("Out of charge!")
		disarm()
		return

	//Grab a list of nearby objects, shuffle it, then see if they are an eligible victim
	var/target
	var/target_is_living = FALSE	//Probably better to keep track of a boolean than repeating isliving() more than once
	var/list/turf/turfs_in_range = shuffle(generate_true_cone(get_turf(src), range, cone_width = angle, projectile = TRUE))	//Get a list of turfs in range
	var/list/possible_targets = list()	//List to hold the actual objects in range
	for(var/turf/turf in turfs_in_range)	//Iterate through the turfs in range to find objects for the mine to target
		for(var/atom in turf.contents)
			possible_targets += atom

	possible_targets -= src	//Prevent the mine from committing suicide
	possible_targets = shuffle(possible_targets)

	//What the lightning bolts should hit: living mobs and conductive objects (items/structures/etc); it should NOT hit turfs, invisible objects, or effects
	//This loop will keep iterating until it finds a valid target, then it will break
	for(var/atom in possible_targets)
		//Mob checks
		if(isliving(atom))
			target_is_living = TRUE
			if(isxeno(atom))
				target = atom
				break	//Xeno are extra conductive!
			target = atom
			continue	//Keep looping in case we find a xeno

		//Check if it's an object that's NOT an effect and if there isn't already a living target chosen
		if(!target_is_living && isobj(atom) && !iseffect(atom))
			var/obj/lightning_rod = atom
			//Prevents targeting things like wiring under floor tiles and makes it so only conductive objects will attract lightning
			if(lightning_rod.invisibility > SEE_INVISIBLE_LIVING || !CHECK_BITFIELD(lightning_rod.atom_flags, CONDUCT))
				continue
			target = atom

	//Do get_turf() on every target before dealing damage because some things will disappear on death/destruction, causing runtime
	if(target_is_living)
		if(ishuman(target))
			var/mob/living/carbon/human/human_victim = target
			target = get_turf(target)
			//Will shock a random body part on humans
			human_victim.apply_damage(damage, BURN, pick(GLOB.human_body_parts), ENERGY)
		else
			var/mob/living/living_victim = target
			target = get_turf(target)
			living_victim.apply_damage(damage, BURN, blocked = ENERGY)

	else if(target)
		var/obj/lightning_rod = target
		target = get_turf(target)
		lightning_rod.take_damage(damage, BURN, ENERGY)

	//In the rare event of no valid target, just grab a turf and zap it for the cool effect and to signal it is active
	//Was considering it not doing anything but then you could exploit it by triggering and having it be active indefinitely
	else
		for(var/turf in turfs_in_range)
			target = turf
			break

		//The mine is either in some kind of void or something very horrible has happened, so just disarm it
		if(!target)
			disarm()
			return

	playsound(loc, "sparks", 100, sound_range = 7)
	//There should always be a target, hence the get_turf() procs and the else block above
	beam(target, "lightning[rand(1,12)]", time = 0.25 SECONDS)
	battery.charge -= energy_cost
	addtimer(CALLBACK(src, PROC_REF(extra_effects)), fire_delay)

/obj/item/mine/shock/battery_included
	battery = /obj/item/cell
