/////////////////////////////////////////////
// Chem smoke
/////////////////////////////////////////////
/obj/effect/particle_effect/smoke/chem
	lifetime = 10
	var/fraction
/obj/effect/particle_effect/smoke/chem/spread_smoke()
	fraction = INVERSE(lifetime)
	return ..()

/obj/effect/particle_effect/smoke/chem/apply_smoke_effect(turf/T)
	. = ..()
	reagents.reaction(T, TOUCH, fraction)

/obj/effect/particle_effect/smoke/chem/effect_contact(mob/living/carbon/C)
	reagents.reaction(C, TOUCH, fraction)

/obj/effect/particle_effect/smoke/chem/effect_inhale(mob/living/carbon/C)
	reagents.copy_to(C, fraction * reagents.total_volume)
	reagents.reaction(C, INGEST, fraction)

/datum/effect_system/smoke_spread/chem
	var/obj/chemholder
	smoke_type = /obj/effect/particle_effect/smoke/chem

/datum/effect_system/smoke_spread/chem/New()
	..()
	chemholder = new /obj()
	var/datum/reagents/R = new/datum/reagents(500)
	chemholder.reagents = R
	R.my_atom = chemholder

/datum/effect_system/smoke_spread/chem/Destroy()
	qdel(chemholder)
	chemholder = null
	return ..()

/datum/effect_system/smoke_spread/chem/set_up(datum/reagents/carry = null, radius = 1, loca, smoke_time, silent = FALSE)
	if(! ..())
		return

	carry.copy_to(chemholder, carry.total_volume)

	if(!silent)
		var/contained = ""
		for(var/reagent in carry.reagent_list)
			contained += " [reagent] "
		if(contained)
			contained = "\[[contained]\]"
		var/area/A = get_area(location)

		var/where = "[A.name]|[location.x], [location.y]"
		var/whereLink = "<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[location.x];Y=[location.y];Z=[location.z]'>[where]</a>"

		if(carry.my_atom.fingerprintslast)
			var/mob/M = get_mob_by_key(carry.my_atom.fingerprintslast)
			var/more = ""
			if(M)
				more = "(<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</a>)"
			message_admins("A chemical smoke reaction has taken place in ([whereLink])[contained]. Last associated key is [carry.my_atom.fingerprintslast][more].", 0, 1)
			log_game("A chemical smoke reaction has taken place in ([where])[contained]. Last associated key is [carry.my_atom.fingerprintslast].")
		else
			message_admins("A chemical smoke reaction has taken place in ([whereLink]). No associated key.", 0, 1)
			log_game("A chemical smoke reaction has taken place in ([where])[contained]. No associated key.")


/datum/effect_system/smoke_spread/chem/spawn_smoke(turf/T, icon/I)
	var/color = mix_color_from_reagents(chemholder.reagents.reagent_list)
	if(color)
		I = icon('icons/effects/chemsmoke.dmi')
		I += color
	var/obj/effect/particle_effect/smoke/chem/S = new smoke_type(location)
	if(chemholder.reagents.total_volume > 1) // can't split 1 very well
		chemholder.reagents.copy_to(S, chemholder.reagents.total_volume)
	if(lifetime)
		S.lifetime = lifetime
	S.spread_smoke(T, I)