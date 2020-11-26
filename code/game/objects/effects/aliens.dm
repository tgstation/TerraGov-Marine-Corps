

//Xeno-style acids
//Ideally we'll consolidate all the "effect" objects here
//Also need to change the icons
/obj/effect/xenomorph
	name = "alien thing"
	desc = "You shouldn't be seeing this."
	icon = 'icons/Xeno/effects.dmi'
	layer = FLY_LAYER

/obj/effect/xenomorph/splatter
	name = "splatter"
	desc = "It burns! It burns like hygiene!"
	icon_state = "splatter"
	density = FALSE
	opacity = FALSE
	anchored = TRUE

/obj/effect/xenomorph/splatter/Initialize() //Self-deletes after creation & animation
	. = ..()
	QDEL_IN(src, 8)

/obj/effect/xenomorph/splatterblob
	name = "splatter"
	desc = "It burns! It burns like hygiene!"
	icon_state = "acidblob"
	density = FALSE
	opacity = FALSE
	anchored = TRUE

/obj/effect/xenomorph/splatterblob/Initialize() //Self-deletes after creation & animation
	. = ..()
	QDEL_IN(src, 4 SECONDS)

/obj/effect/xenomorph/spray
	name = "splatter"
	desc = "It burns! It burns like hygiene!"
	icon_state = "acid2"
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	layer = ABOVE_OBJ_LAYER
	mouse_opacity = 0
	flags_pass = PASSTABLE|PASSMOB|PASSGRILLE
	var/slow_amt = 0.8
	var/duration = 10 SECONDS
	var/acid_damage = 14

/obj/effect/xenomorph/spray/Initialize(mapload, duration = 10 SECONDS, damage = 14) //Self-deletes
	. = ..()
	START_PROCESSING(SSprocessing, src)
	QDEL_IN(src, duration + rand(0, 2 SECONDS))
	acid_damage = damage

/obj/effect/xenomorph/spray/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/effect/xenomorph/spray/Crossed(atom/movable/AM)
	. = ..()
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		H.acid_spray_crossed(acid_damage, slow_amt)

/mob/living/carbon/human/proc/acid_spray_crossed(acid_damage, slow_amt)
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_ACID))
		return

	TIMER_COOLDOWN_START(src, COOLDOWN_ACID, 1 SECONDS)
	if(HAS_TRAIT(src, TRAIT_FLOORED))
		take_overall_damage_armored(acid_damage, BURN, "acid")
		UPDATEHEALTH(src)
		to_chat(src, "<span class='danger'>You are scalded by the burning acid!</span>")
		return
	to_chat(src, "<span class='danger'>Your feet scald and burn! Argh!</span>")
	if(!(species.species_flags & NO_PAIN))
		emote("pain")
	next_move_slowdown += slow_amt
	var/datum/limb/affecting = get_limb(BODY_ZONE_PRECISE_L_FOOT)
	var/armor_block = run_armor_check(affecting, "acid")
	if(istype(affecting) && affecting.take_damage_limb(0, acid_damage/2, FALSE, FALSE, armor_block, TRUE))
		UPDATEHEALTH(src)
		UpdateDamageIcon()
	affecting = get_limb(BODY_ZONE_PRECISE_R_FOOT)
	armor_block = run_armor_check(affecting, "acid")
	if(istype(affecting) && affecting.take_damage_limb(0, acid_damage/2, FALSE, FALSE, armor_block, TRUE))
		UPDATEHEALTH(src)
		UpdateDamageIcon()

/obj/effect/xenomorph/spray/process()
	var/turf/T = loc
	if(!istype(T))
		qdel(src)
		return

	for(var/mob/living/carbon/human/H in loc)
		H.acid_spray_crossed(slow_amt)

	for(var/atom/A in loc) //Infrastructure for other interactions
		SEND_SIGNAL(A, COMSIG_ATOM_ACIDSPRAY_ACT, src)

//Medium-strength acid
/obj/effect/xenomorph/acid
	name = "acid"
	desc = "Burbling corrosive stuff. I wouldn't want to touch it."
	icon_state = "acid_normal"
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	var/atom/acid_t
	var/ticks = 0
	var/acid_strength = 1 //100% speed, normal
	var/acid_damage = 125 //acid damage on pick up, subject to armor
	var/strength_t

//Sentinel weakest acid
/obj/effect/xenomorph/acid/weak
	name = "weak acid"
	acid_strength = 0.4 //250% normal speed
	acid_damage = 75
	icon_state = "acid_weak"

//Superacid
/obj/effect/xenomorph/acid/strong
	name = "strong acid"
	acid_strength = 2.5 //20% normal speed
	acid_damage = 175
	icon_state = "acid_strong"

/obj/effect/xenomorph/acid/Initialize(mapload, target)
	. = ..()
	acid_t = target
	strength_t = isturf(acid_t) ? 8:4 // Turf take twice as long to take down.
	START_PROCESSING(SSprocessing, src)

/obj/effect/xenomorph/acid/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	acid_t = null
	. = ..()

/obj/effect/xenomorph/acid/process(delta_time)
	if(!acid_t || !acid_t.loc)
		qdel(src)
		return
	if(loc != acid_t.loc && !isturf(acid_t))
		loc = acid_t.loc
	ticks += ((delta_time*0.1) * (rand(2,3)*0.1) * (acid_strength)) * 0.1
	if(ticks >= strength_t)
		visible_message("<span class='xenodanger'>[acid_t] collapses under its own weight into a puddle of goop and undigested debris!</span>")
		playsound(src, "acid_hit", 25)

		if(istype(acid_t, /turf))
			if(iswallturf(acid_t))
				var/turf/closed/wall/W = acid_t
				new /obj/effect/acid_hole (W)
			else
				var/turf/T = acid_t
				T.ChangeTurf(/turf/open/floor/plating)
		else if (istype(acid_t, /obj/structure/girder))
			var/obj/structure/girder/G = acid_t
			G.deconstruct(FALSE)
		else if(istype(acid_t, /obj/structure/window/framed))
			var/obj/structure/window/framed/WF = acid_t
			WF.deconstruct(FALSE)

		else
			if(acid_t.contents.len) //Hopefully won't auto-delete things inside melted stuff..
				for(var/mob/M in acid_t.contents)
					if(acid_t.loc) M.forceMove(acid_t.loc)
			qdel(acid_t)
			acid_t = null

		qdel(src)
		return

	switch(strength_t - ticks)
		if(6) visible_message("<span class='xenowarning'>\The [acid_t] is barely holding up against the acid!</span>")
		if(4) visible_message("<span class='xenowarning'>\The [acid_t]\s structure is being melted by the acid!</span>")
		if(2) visible_message("<span class='xenowarning'>\The [acid_t] is struggling to withstand the acid!</span>")
		if(0 to 1) visible_message("<span class='xenowarning'>\The [acid_t] begins to crumble under the acid!</span>")
