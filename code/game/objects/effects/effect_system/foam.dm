


// Foam
// Similar to smoke, but spreads out more
//foam effect

/obj/effect/particle_effect/foam
	name = "foam"
	icon_state = "greyscalefoam"
	opacity = FALSE
	anchored = TRUE
	density = FALSE
	layer = BELOW_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	animate_movement = NO_STEPS
	///How much the foam expands.
	var/spread_amount = 3
	///How much long the foam lasts, 1 second = 5 since this uses fast processing which ticks 5 times in 1 second..
	var/lifetime = 75
	///How much the reagents in the foam are divided when applying and how much it can apply per proccess.
	var/reagent_divisor = 7
	///flags for the foam, such as RAZOR_FOAM and METAL_FOAM.
	var/foam_flags = NONE

/obj/effect/particle_effect/foam/Initialize(mapload)
	. = ..()
	create_reagents(1000) //limited by the size of the reagent holder anyway.
	START_PROCESSING(SSfastprocess, src)
	playsound(src, 'sound/effects/bubbles2.ogg', 25, 1, 5)
	AddComponent(/datum/component/slippery, 0.5 SECONDS, 0.2 SECONDS)

/obj/effect/particle_effect/foam/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

///Finishes the foam, stopping it from processing and doing whatever it has to do.
/obj/effect/particle_effect/foam/proc/kill_foam()
	STOP_PROCESSING(SSfastprocess, src)
	if(foam_flags & METAL_FOAM)
		new /obj/structure/foamedmetal(loc)
	if(foam_flags & RAZOR_FOAM)
		var/turf/mystery_turf = get_turf(loc)
		if(!isopenturf(mystery_turf))
			return

		var/turf/open/T = mystery_turf
		if(T.allow_construction) //No loopholes.
			new /obj/structure/razorwire(loc)
	flick("[icon_state]-disolve", src)
	QDEL_IN(src, 5)

/obj/effect/particle_effect/foam/process()
	lifetime--
	if(lifetime < 1)
		kill_foam()
		return

	var/fraction = 1/reagent_divisor
	var/turf/our_turf = get_turf(src)
	var/mob_iterated = FALSE
	for(var/atom/movable/thing in our_turf)
		if(thing.type == src.type)
			continue
		if(lifetime % reagent_divisor)
			reagents.reaction(thing, VAPOR, fraction)
		if(isliving(thing))
			if(mob_iterated)
				lifetime--
			else
				mob_iterated = TRUE
	if(lifetime % reagent_divisor)
		reagents.reaction(our_turf, VAPOR, fraction)
	if(--spread_amount < 0)
		return
	spread_foam()

///Spreads the foam in the 4 cardinal directions and gives them the reagents and all.
/obj/effect/particle_effect/foam/proc/spread_foam()
	for(var/direction in GLOB.cardinals)
		var/turf/T = get_step(src, direction)
		if(!T)
			continue
		if(!T.Enter(src))
			continue
		var/obj/effect/particle_effect/foam/oldF = locate() in T
		if(oldF)
			continue

		for(var/mob/living/L in T)
			if(lifetime < 1)
				break
			reagents.reaction(L, VAPOR, 1/reagent_divisor)
			lifetime--

		var/obj/effect/particle_effect/foam/F = new type(T)
		F.spread_amount = spread_amount
		reagents.copy_to(F, reagents.total_volume)
		F.color = color
		F.foam_flags = foam_flags

// foam disolves when heated
// except metal foams
/obj/effect/particle_effect/foam/fire_act(exposed_temperature, exposed_volume)
	if(!(foam_flags & METAL_FOAM|RAZOR_FOAM) && prob(max(0, exposed_temperature - 475)))
		kill_foam()

/obj/effect/particle_effect/foam/can_slip()
	. = ..()
	if(foam_flags & METAL_FOAM|RAZOR_FOAM)
		return FALSE

//datum effect system

/datum/effect_system/foam_spread
	///The size of the foam spread
	var/spread_amount = 5
	/// the IDs of reagents present when the foam was mixed
	var/list/carried_reagents
	///Holder that holds the chems the foam will have
	var/datum/reagents/carrying_reagents
	///Flags for the foam.
	var/foam_flags = NONE

/datum/effect_system/foam_spread/New()
	..()
	carrying_reagents = new(1000)

/datum/effect_system/foam_spread/Destroy()
	QDEL_NULL(carrying_reagents)
	return ..()

/datum/effect_system/foam_spread/set_up(spread_amount = 5, atom/location, datum/reagents/carry = null, foam_flags = NONE, lifetime = 75)
	if(isturf(location))
		src.location = WEAKREF(location)
	else
		src.location = WEAKREF(get_turf(location))

	src.spread_amount = round(sqrt(spread_amount / 3), 1)
	carry.copy_to(carrying_reagents, carry.total_volume)
	src.foam_flags = foam_flags

/datum/effect_system/foam_spread/start()
	if(spread_amount < 0)
		return
	var/obj/effect/particle_effect/foam/F = new(location.resolve())
	var/foamcolor = mix_color_from_reagents(carrying_reagents.reagent_list)
	carrying_reagents.copy_to(F, spread_amount ? carrying_reagents.total_volume/spread_amount : carrying_reagents.total_volume) //this magically duplicates chems
	F.add_atom_colour(foamcolor, FIXED_COLOUR_PRIORITY)
	F.spread_amount = spread_amount
	F.foam_flags = foam_flags

// wall formed by metal foams
// dense and opaque, but easy to break

/obj/structure/foamedmetal
	icon = 'icons/obj/smooth_objects/foamwall.dmi'
	icon_state = "foamwall-icon"
	base_icon_state = "foamwall"
	density = TRUE
	opacity = FALSE 	// changed in New()
	anchored = TRUE
	allow_pass_flags = NONE
	name = "foamed metal"
	desc = "A lightweight foamed metal wall."
	resistance_flags = XENO_DAMAGEABLE
	max_integrity = 120
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(
		SMOOTH_GROUP_FOAM_WALL,
	)
	canSmoothWith = list(
		SMOOTH_GROUP_FOAM_WALL,
	)

/obj/structure/foamedmetal/fire_act() //flamerwallhacks go BRRR
	take_damage(10, BURN, FIRE)

