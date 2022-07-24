/* This is an attempt to make some easily reusable "particle" type effect, to stop the code
constantly having to be rewritten. An item like the jetpack that uses the ion_trail_follow system, just has one
defined, then set up when it is created with New(). Then this same system can just be reused each time
it needs to create more trails.A beaker could have a steam_trail_follow system set up, then the steam
would spawn and follow the beaker, even if it is carried or thrown.
*/

/proc/do_sparks(n, c, source)
	// n - number of sparks
	// c - cardinals, bool, do the sparks only move in cardinal directions?
	// source - source of the sparks.

	new /datum/effect_system/spark_spread(source, null, n, c, TRUE, 10 SECONDS)

/datum/effect_system
	var/number = 3
	var/cardinals = 0
	var/turf/location
	var/atom/holder
	var/setup = 0

/datum/effect_system/New(atom/atom, turf/location, n = 3, c = 0, setup_and_start = FALSE, self_delete)
	. = ..()
	if(atom)
		attach(atom)
	if(setup_and_start)
		src.location = get_turf(location)
		number = min(n, 10)
		cardinals = c
		setup = TRUE
		INVOKE_ASYNC(src, .proc/start)

		if(self_delete)
			QDEL_IN(src, self_delete)

/datum/effect_system/proc/set_up(n = 3, c = 0, turf/loca)
	if(n > 10)
		n = 10
	number = n
	cardinals = c
	location = loca
	setup = 1

/datum/effect_system/proc/attach(atom/atom)
	holder = atom

/datum/effect_system/proc/start()
	for(var/i in 1 to number)
		INVOKE_ASYNC(src, .proc/spawn_particle)

/datum/effect_system/proc/spawn_particle()
	return

/datum/effect_system/Destroy()
	holder = null
	return ..()


/////////////////////////////////////////////
// GENERIC STEAM SPREAD SYSTEM

//Usage: set_up(number of bits of steam, use North/South/East/West only, spawn location)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like a smoking beaker, so then you can just call start() and the steam
// will always spawn at the items location, even if it's moved.

/* Example:
// var/datum/effect_system/steam_spread/steam = new /datum/effect_system/steam_spread() -- creates new system
steam.set_up(5, 0, mob.loc) -- sets up variables
OPTIONAL: steam.attach(mob)
steam.start() -- spawns the effect
*/
/////////////////////////////////////////////
/atom/movable/effect/particle_effect/steam
	name = "steam"
	icon = 'icons/effects/effects.dmi'
	icon_state = "extinguish"
	density = FALSE

/datum/effect_system/steam_spread

/datum/effect_system/steam_spread/spawn_particle()
	if(holder)
		location = get_turf(holder)
	var/atom/movable/effect/particle_effect/steam/steam = new /atom/movable/effect/particle_effect/steam(location)
	var/direction
	if(cardinals)
		direction = pick(GLOB.cardinals)
	else
		direction = pick(GLOB.alldirs)
	for(var/i in 1 to pick(1,2,3))
		sleep(5) // sleep is fine here, invoked async
		step(steam,direction)
	QDEL_IN(steam, 2 SECONDS)

/////////////////////////////////////////////
//SPARK SYSTEM (like steam system)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like the RCD, so then you can just call start() and the sparks
// will always spawn at the items location.
/////////////////////////////////////////////

/atom/movable/effect/particle_effect/sparks
	name = "sparks"
	icon_state = "sparks"
	anchored = TRUE
	mouse_opacity = 0
	light_on = TRUE
	light_power = 1
	light_range = 1
	light_color = COLOR_VERY_SOFT_YELLOW

/atom/movable/effect/particle_effect/sparks/Initialize()
	. = ..()
	playsound(src.loc, "sparks", 25, 1)
	QDEL_IN(src, 10 SECONDS)


/datum/effect_system/spark_spread

/datum/effect_system/spark_spread/spawn_particle()
	if(holder)
		location = get_turf(holder)
	var/atom/movable/effect/particle_effect/sparks/sparks = new /atom/movable/effect/particle_effect/sparks(location)
	var/direction
	if(src.cardinals)
		direction = pick(GLOB.cardinals)
	else
		direction = pick(GLOB.alldirs)
	for(var/i in pick(1,2,3))
		sleep(5)
		step(sparks,direction)
	QDEL_IN(sparks, 2 SECONDS)

// trails
/datum/effect_system/trail
	var/turf/oldposition
	var/processing = TRUE
	var/on = TRUE

/datum/effect_system/trail/set_up(atom/atom)
	attach(atom)
	oldposition = get_turf(atom)

/datum/effect_system/trail/start(set_processing)
	if(set_processing)
		if(!on)
			return
		processing = TRUE
	if(!on)
		on = TRUE
		processing = TRUE
	if(processing)
		processing = FALSE
		INVOKE_ASYNC(src, .proc/spawn_particle)

/datum/effect_system/trail/proc/stop()
	processing = FALSE
	on = FALSE

/////////////////////////////////////////////
//////// Attach an Ion trail to any object, that spawns when it moves (like for the jetpack)
/// just pass in the object to attach it to in set_up
/// Then do start() to start it and stop() to stop it, obviously
/// and don't call start() in a loop that will be repeated otherwise it'll get spammed!
/////////////////////////////////////////////

/atom/movable/effect/particle_effect/ion_trails
	name = "ion trails"
	icon_state = "ion_trails"
	anchored = TRUE

/datum/effect_system/trail/ion_trail_follow/spawn_particle()
	var/turf/T = get_turf(holder)
	if(T != oldposition)
		if(isspaceturf(T))
			var/atom/movable/effect/particle_effect/ion_trails/I = new /atom/movable/effect/particle_effect/ion_trails(oldposition)
			oldposition = T
			I.setDir(holder.dir)
			flick("ion_fade", I)
			I.icon_state = "blank"
			QDEL_IN(I, 2 SECONDS)

	addtimer(CALLBACK(src, .proc/start, TRUE), 0.2 SECONDS)

/////////////////////////////////////////////
//////// Attach a steam trail to an object (eg. a reacting beaker) that will follow it
// even if it's carried of thrown.
/////////////////////////////////////////////

/datum/effect_system/trail/steam_trail_follow/spawn_particle()
	if(number < 3)
		var/atom/movable/effect/particle_effect/steam/I = new /atom/movable/effect/particle_effect/steam(oldposition)
		number++
		oldposition = get_turf(holder)
		I.setDir(holder.dir)
		addtimer(CALLBACK(src, .proc/decay, I), 1 SECONDS)

	addtimer(CALLBACK(src, .proc/start, TRUE), 0.2 SECONDS)

/datum/effect_system/trail/steam_trail_follow/proc/decay(atom/movable/effect/particle_effect/steam/I)
	qdel(I)
	number--
