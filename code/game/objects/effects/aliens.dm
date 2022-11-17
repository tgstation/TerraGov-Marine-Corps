

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
	var/acid_damage = XENO_DEFAULT_ACID_PUDDLE_DAMAGE
	/// Who created that spray
	var/mob/xeno_owner

/obj/effect/xenomorph/spray/Initialize(mapload, duration = 10 SECONDS, damage = XENO_DEFAULT_ACID_PUDDLE_DAMAGE, mob/living/_xeno_owner) //Self-deletes
	. = ..()
	START_PROCESSING(SSprocessing, src)
	QDEL_IN(src, duration + rand(0, 2 SECONDS))
	acid_damage = damage
	xeno_owner = _xeno_owner
	RegisterSignal(xeno_owner, COMSIG_PARENT_QDELETING, .proc/clean_mob_owner)
	RegisterSignal(loc, COMSIG_ATOM_ENTERED, .proc/atom_enter_turf)
	TIMER_COOLDOWN_START(src, COOLDOWN_PARALYSE_ACID, 5)

/obj/effect/xenomorph/spray/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	xeno_owner = null
	return ..()

/// Signal handler to check if an human is entering the acid spray turf
/obj/effect/xenomorph/spray/proc/atom_enter_turf(datum/source, atom/movable/moved_in, direction)
	SIGNAL_HANDLER
	if(!ishuman(moved_in))
		return
	var/mob/living/carbon/human/victim = moved_in
	if(victim.flags_pass & HOVERING)
		return
	victim.acid_spray_entered(null, src, acid_damage, slow_amt)

/// Set xeno_owner to null to avoid hard del
/obj/effect/xenomorph/spray/proc/clean_mob_owner()
	UnregisterSignal(xeno_owner, COMSIG_PARENT_QDELETING)
	xeno_owner = null

/// Signal handler to burn and maybe stun the human entering the acid spray
/mob/living/carbon/human/proc/acid_spray_entered(datum/source, obj/effect/xenomorph/spray/acid_spray, acid_damage, slow_amt)
	SIGNAL_HANDLER
	if(CHECK_MULTIPLE_BITFIELDS(flags_pass, HOVERING) || stat == DEAD)
		return

	if(acid_spray.xeno_owner && TIMER_COOLDOWN_CHECK(acid_spray, COOLDOWN_PARALYSE_ACID)) //To prevent being able to walk "over" acid sprays
		acid_spray_act(acid_spray.xeno_owner)
		return

	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_ACID))
		return

	TIMER_COOLDOWN_START(src, COOLDOWN_ACID, 1 SECONDS)
	if(HAS_TRAIT(src, TRAIT_FLOORED))
		INVOKE_ASYNC(src, .proc/take_overall_damage_armored, acid_damage, BURN, "acid", FALSE, FALSE, TRUE)
		to_chat(src, span_danger("You are scalded by the burning acid!"))
		return
	to_chat(src, span_danger("Your feet scald and burn! Argh!"))
	if(!(species.species_flags & NO_PAIN))
		INVOKE_ASYNC(src, .proc/emote, "pain")

	next_move_slowdown += slow_amt
	var/datum/limb/affecting = get_limb(BODY_ZONE_PRECISE_L_FOOT)
	var/armor_block = get_soft_armor("acid", affecting)
	INVOKE_ASYNC(affecting, /datum/limb/.proc/take_damage_limb, 0, acid_damage/2, FALSE, FALSE, armor_block)

	affecting = get_limb(BODY_ZONE_PRECISE_R_FOOT)
	armor_block = get_soft_armor("acid", affecting)
	INVOKE_ASYNC(affecting, /datum/limb/.proc/take_damage_limb, 0, acid_damage/2, FALSE, FALSE, armor_block, TRUE)


/obj/effect/xenomorph/spray/process()
	var/turf/T = loc
	if(!istype(T))
		qdel(src)
		return

	SEND_SIGNAL(T, COMSIG_ATOM_ACIDSPRAY_ACT, src) //Signal the turf
	for(var/H in T)

		var/atom/A = H
		SEND_SIGNAL(A, COMSIG_ATOM_ACIDSPRAY_ACT, src, acid_damage, slow_amt)

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
	var/acid_strength = 0.04 //base speed, normal
	var/acid_damage = 125 //acid damage on pick up, subject to armor
	var/strength_t

//Sentinel weakest acid
/obj/effect/xenomorph/acid/weak
	name = "weak acid"
	acid_strength = 0.016 //40% of base speed
	acid_damage = 75
	icon_state = "acid_weak"

//Superacid
/obj/effect/xenomorph/acid/strong
	name = "strong acid"
	acid_strength = 0.1 //250% normal speed
	acid_damage = 175
	icon_state = "acid_strong"

/obj/effect/xenomorph/acid/Initialize(mapload, target)
	. = ..()
	acid_t = target
	strength_t = isturf(acid_t) ? 8:4 // Turf take twice as long to take down.
	START_PROCESSING(SSslowprocess, src)

/obj/effect/xenomorph/acid/Destroy()
	STOP_PROCESSING(SSslowprocess, src)
	acid_t = null
	return ..()

/obj/effect/xenomorph/acid/process(delta_time)
	if(!acid_t || !acid_t.loc)
		qdel(src)
		return
	if(loc != acid_t.loc && !isturf(acid_t))
		loc = acid_t.loc
	ticks += delta_time * acid_strength
	if(ticks >= strength_t)
		visible_message(span_xenodanger("[acid_t] collapses under its own weight into a puddle of goop and undigested debris!"))
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
				for(var/atom/movable/M in acid_t.contents)
					if(acid_t.loc) M.forceMove(acid_t.loc)
			qdel(acid_t)
			acid_t = null

		qdel(src)
		return

	switch(strength_t - ticks)
		if(6) visible_message(span_xenowarning("\The [acid_t] is barely holding up against the acid!"))
		if(4) visible_message(span_xenowarning("\The [acid_t]\s structure is being melted by the acid!"))
		if(2) visible_message(span_xenowarning("\The [acid_t] is struggling to withstand the acid!"))
		if(0 to 1) visible_message(span_xenowarning("\The [acid_t] begins to crumble under the acid!"))

/obj/effect/xenomorph/warp_shadow
	name = "warp shadow"
	desc = "A strange rift in space and time. You probably shouldn't touch this."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Wraith Walking"
	color = COLOR_BLACK
	alpha = 128 //Translucent
	density = FALSE
	opacity = FALSE
	anchored = TRUE

/obj/effect/xenomorph/warp_shadow/Initialize(mapload, target)
	. = ..()
	add_filter("wraith_warp_shadow", 4, list("type" = "blur", 5)) //Cool filter appear
