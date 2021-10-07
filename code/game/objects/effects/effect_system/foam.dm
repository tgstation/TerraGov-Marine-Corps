


// Foam
// Similar to smoke, but spreads out more
// metal foams leave behind a foamed metal wall

#define METAL_FOAM 1
#define RAZOR_FOAM 2


//foam effect

/obj/effect/particle_effect/foam
	name = "foam"
	icon_state = "foam"
	opacity = FALSE
	anchored = TRUE
	density = FALSE
	layer = BELOW_MOB_LAYER
	mouse_opacity = 0
	///How much tiles the foam expands on.
	var/amount = 3
	///How much long the foam lasts
	var/lifetime = 40
	///How much the reagents in the foam are divided when applying and how much it can apply per proccess.
	var/reagent_divisor = 7
	animate_movement = NO_STEPS
	var/metal = 0

/obj/effect/particle_effect/foam/Initialize()
	. = ..()
	create_reagents(1000) //limited by the size of the reagent holder anyway.
	START_PROCESSING(SSfastprocess, src)
	playsound(src, 'sound/effects/bubbles2.ogg', 25, 1, 5)

/obj/effect/particle_effect/foam/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

///Finishes the foam, stopping it from processing and doing whatever it has to do.
/obj/effect/particle_effect/foam/proc/kill_foam()
	STOP_PROCESSING(SSfastprocess, src)
	switch(metal)
		if(METAL_FOAM)
			new /obj/structure/foamedmetal(loc)
		if(RAZOR_FOAM)
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

	var/fraction = 1/initial(reagent_divisor)
	for(var/obj/O in range(0, src))
		if(O.type == src.type)
			continue
		if(lifetime % reagent_divisor)
			reagents.reaction(O, VAPOR, fraction)
	var/hit = 0
	for(var/mob/living/L in range(0, src))
		hit += foam_mob(L)
	if(hit)
		lifetime++
	var/T = get_turf(src)
	if(lifetime % reagent_divisor)
		reagents.reaction(T, VAPOR, fraction)
	if(--amount < 0)
		return
	spread_foam()

///Applies foam reagents reaction on the mob OR anything overrided by some foam type.
/obj/effect/particle_effect/foam/proc/foam_mob(mob/living/L)
	if(lifetime < 1)
		return FALSE
	if(!isliving(L))
		return FALSE
	var/fraction = 1/initial(reagent_divisor)
	if(lifetime % reagent_divisor)
		reagents.reaction(L, VAPOR, fraction)
	lifetime--
	return TRUE

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
			foam_mob(L)
		var/obj/effect/particle_effect/foam/F = new src.type(T)
		F.amount = amount
		reagents.copy_to(F, reagents.total_volume)
		F.color = color
		F.metal = metal

// foam disolves when heated
// except metal foams
/obj/effect/particle_effect/foam/fire_act(exposed_temperature, exposed_volume)
	if(!metal && prob(max(0, exposed_temperature - 475)))
		kill_foam()


/obj/effect/particle_effect/foam/Crossed(atom/movable/AM)
	. = ..()
	if(metal)
		return
	if (iscarbon(AM))
		var/mob/living/carbon/C = AM
		C.slip("foam", 5, 2)



//datum effect system

/datum/effect_system/foam_spread
	var/amount = 5				// the size of the foam spread.
	var/list/carried_reagents	// the IDs of reagents present when the foam was mixed
	var/obj/chemholder
	var/metal = 0				// 0=foam, 1=metalfoam, 2=razorburn

/datum/effect_system/foam_spread/New()
	..()
	chemholder = new /obj()
	var/datum/reagents/R = new/datum/reagents(1000)
	chemholder.reagents = R
	R.my_atom = chemholder

/datum/effect_system/foam_spread/Destroy()
	qdel(chemholder)
	chemholder = null
	return ..()

/datum/effect_system/foam_spread/set_up(amt=5, loca, datum/reagents/carry = null, metalfoam = 0)
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)

	amount = round(sqrt(amt / 3), 1)
	carry.copy_to(chemholder, carry.total_volume)
	if(metalfoam)
		metal = metalfoam

/datum/effect_system/foam_spread/start()
	var/obj/effect/particle_effect/foam/F = new(location)
	var/foamcolor = mix_color_from_reagents(chemholder.reagents.reagent_list)
	chemholder.reagents.copy_to(F, chemholder.reagents.total_volume/amount)
	F.add_atom_colour(foamcolor, FIXED_COLOUR_PRIORITY)
	F.amount = amount
	F.metal = metal

// wall formed by metal foams
// dense and opaque, but easy to break

/obj/structure/foamedmetal
	icon = 'icons/effects/effects.dmi'
	icon_state = "metalfoam"
	density = TRUE
	opacity = FALSE 	// changed in New()
	anchored = TRUE
	name = "foamed metal"
	desc = "A lightweight foamed metal wall."
	resistance_flags = XENO_DAMAGEABLE
	max_integrity = 200

/obj/structure/foamedmetal/fire_act() //flamerwallhacks go BRRR
	take_damage(10, BURN, "fire")

#undef METAL_FOAM
#undef RAZOR_FOAM
