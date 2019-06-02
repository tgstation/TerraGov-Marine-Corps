// Foam
// Similar to smoke, but slower and mobs absorb its reagent through their exposed skin.
#define ALUMINUM_FOAM 1
#define IRON_FOAM 2


/obj/effect/particle_effect/foam
	name = "foam"
	icon_state = "foam"
	opacity = FALSE
	anchored = TRUE
	density = FALSE
	layer = EDGED_TURF_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/amount = 3
	animate_movement = 0
	var/metal = 0
	var/lifetime = 40
	var/reagent_divisor = 7
	var/static/list/blacklisted_turfs = typecacheof(list(
	/turf/open/space/transit))
	var/slippery_foam = TRUE


/obj/effect/particle_effect/foam/metal
	name = "aluminium foam"
	metal = ALUMINUM_FOAM
	icon_state = "mfoam"
	slippery_foam = FALSE

/obj/effect/particle_effect/foam/metal/iron
	name = "iron foam"
	metal = IRON_FOAM


/obj/effect/particle_effect/foam/long_life
	lifetime = 150


/obj/effect/particle_effect/foam/Initialize()
	. = ..()
	create_reagents(1000) //limited by the size of the reagent holder anyway.
	START_PROCESSING(SSfastprocess, src)
	playsound(src, 'sound/effects/bubbles2.ogg', 80, 1, -3)


/obj/effect/particle_effect/foam/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()


/obj/effect/particle_effect/foam/proc/kill_foam()
	STOP_PROCESSING(SSfastprocess, src)
	switch(metal)
		if(ALUMINUM_FOAM)
			new /obj/structure/foamedmetal(get_turf(src))
		if(IRON_FOAM)
			new /obj/structure/foamedmetal/iron(get_turf(src))
	flick("[icon_state]-disolve", src)
	QDEL_IN(src, 5)


/obj/effect/particle_effect/foam/process()
	lifetime--
	if(lifetime < 1)
		kill_foam()
		return

	var/fraction = 1/initial(reagent_divisor)
	for(var/obj/O in range(0,src))
		if(O.type == src.type)
			continue
		if(isturf(O.loc))
			var/turf/T = O.loc
			if(T.intact_tile && O.level == 1) //hidden under the floor
				continue
		if(lifetime % reagent_divisor)
			reagents.reaction(O, VAPOR, fraction)
	var/hit = 0
	for(var/mob/living/L in range(0,src))
		hit += foam_mob(L)
	if(hit)
		lifetime++ //this is so the decrease from mobs hit and the natural decrease don't cumulate.
	var/T = get_turf(src)
	if(lifetime % reagent_divisor)
		reagents.reaction(T, VAPOR, fraction)

	if(--amount < 0)
		return
	spread_foam()

/obj/effect/particle_effect/foam/proc/foam_mob(mob/living/L)
	if(lifetime < 1)
		return FALSE
	if(!istype(L))
		return FALSE
	var/fraction = 1 / initial(reagent_divisor)
	if(lifetime % reagent_divisor)
		reagents.reaction(L, VAPOR, fraction)
	lifetime--
	return TRUE

/obj/effect/particle_effect/foam/proc/spread_foam()
	for(var/direction in GLOB.cardinals)
		var/turf/T = get_step(src, direction)
		var/obj/effect/particle_effect/foam/foundfoam = locate() in T //Don't spread foam where there's already foam!
		if(foundfoam)
			continue

		if(is_type_in_typecache(T, blacklisted_turfs))
			continue

		for(var/mob/living/L in T)
			foam_mob(L)
		var/obj/effect/particle_effect/foam/F = new(T)
		F.amount = amount
		reagents.copy_to(F, (reagents.total_volume))
		F.add_atom_colour(color, FIXED_COLOUR_PRIORITY)
		F.metal = metal


///////////////////////////////////////////////
//FOAM EFFECT DATUM
/datum/effect_system/foam_spread
	var/amount = 10		// the size of the foam spread.
	var/obj/chemholder
	effect_type = /obj/effect/particle_effect/foam
	var/metal = 0


/datum/effect_system/foam_spread/metal
	effect_type = /obj/effect/particle_effect/foam/metal


/datum/effect_system/foam_spread/long
	effect_type = /obj/effect/particle_effect/foam/long_life

/datum/effect_system/foam_spread/New()
	. = ..()
	chemholder = new /obj()
	var/datum/reagents/R = new(1000)
	chemholder.reagents = R
	R.my_atom = chemholder

/datum/effect_system/foam_spread/Destroy()
	QDEL_NULL(chemholder)
	return ..()

/datum/effect_system/foam_spread/set_up(amt=5, loca, datum/reagents/carry = null)
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)

	amount = round(sqrt(amt / 2), 1)
	carry.copy_to(chemholder, carry.total_volume)

/datum/effect_system/foam_spread/metal/set_up(amt=5, loca, datum/reagents/carry = null, metaltype)
	..()
	metal = metaltype

/datum/effect_system/foam_spread/start()
	var/obj/effect/particle_effect/foam/F = new effect_type(location)
	var/foamcolor = mix_color_from_reagents(chemholder.reagents.reagent_list)
	chemholder.reagents.copy_to(F, chemholder.reagents.total_volume/amount)
	F.add_atom_colour(foamcolor, FIXED_COLOUR_PRIORITY)
	F.amount = amount
	F.metal = metal


//////////////////////////////////////////////////////////
// FOAM STRUCTURE. Formed by metal foams. Dense and opaque, but easy to break
/obj/structure/foamedmetal
	icon = 'icons/effects/effects.dmi'
	icon_state = "metalfoam"
	density = TRUE
	opacity = TRUE 	// changed in New()
	anchored = TRUE
	layer = EDGED_TURF_LAYER
	resistance_flags = FIRE_PROOF | ACID_PROOF
	name = "foamed metal"
	desc = "A lightweight foamed metal wall."
	gender = PLURAL
	max_integrity = 20


/obj/structure/foamedmetal/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/foamedmetal/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = NONE)
	playsound(loc, 'sound/weapons/tap.ogg', 100, 1)

/obj/structure/foamedmetal/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
	to_chat(user, "<span class='warning'>You hit [src] but bounce off it!</span>")
	playsound(loc, 'sound/weapons/tap.ogg', 100, 1)

/obj/structure/foamedmetal/CanPass(atom/movable/mover, turf/target)
	return !density

/obj/structure/foamedmetal/iron
	max_integrity = 50
	icon_state = "ironfoam"

#undef ALUMINUM_FOAM
#undef IRON_FOAM
