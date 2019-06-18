

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
	density = 0
	opacity = 0
	anchored = TRUE

/obj/effect/xenomorph/splatter/New() //Self-deletes after creation & animation
	..()
	spawn(8)
		qdel(src)


/obj/effect/xenomorph/splatterblob
	name = "splatter"
	desc = "It burns! It burns like hygiene!"
	icon_state = "acidblob"
	density = 0
	opacity = 0
	anchored = TRUE

/obj/effect/xenomorph/splatterblob/New() //Self-deletes after creation & animation
	..()
	spawn(40)
		qdel(src)


/obj/effect/xenomorph/spray
	name = "splatter"
	desc = "It burns! It burns like hygiene!"
	icon_state = "acid2"
	density = 0
	opacity = 0
	anchored = TRUE
	layer = ABOVE_OBJ_LAYER
	mouse_opacity = 0
	flags_pass = PASSTABLE|PASSMOB|PASSGRILLE
	var/slow_amt = 8
	var/duration = 100

/obj/effect/xenomorph/spray/New(loc, duration = 100) //Self-deletes
	. = ..()
	START_PROCESSING(SSobj, src)
	spawn(duration + rand(0, 20))
		STOP_PROCESSING(SSobj, src)
		qdel(src)
		return

/obj/effect/xenomorph/spray/Crossed(AM as mob|obj)
	..()
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		var/armor_block
		if(H.acid_process_cooldown > world.time - 10) //one second reprieve
			return
		H.acid_process_cooldown = world.time
		if(!H.lying)
			to_chat(H, "<span class='danger'>Your feet scald and burn! Argh!</span>")
			H.emote("pain")
			H.next_move_slowdown += slow_amt
			var/datum/limb/affecting = H.get_limb("l_foot")
			armor_block = H.run_armor_check(affecting, "acid")
			if(istype(affecting) && affecting.take_damage_limb(0, rand(14, 18), FALSE, FALSE, armor_block))
				H.UpdateDamageIcon()
			affecting = H.get_limb("r_foot")
			armor_block = H.run_armor_check(affecting, "acid")
			if(istype(affecting) && affecting.take_damage_limb(0, rand(14, 18), FALSE, FALSE, armor_block))
				H.UpdateDamageIcon()
			H.updatehealth()
		else
			armor_block = H.run_armor_check("chest", "acid")
			H.take_overall_damage(null, rand(12, 14), null, null, null, armor_block) //This is ticking damage!
			to_chat(H, "<span class='danger'>You are scalded by the burning acid!</span>")

/obj/effect/xenomorph/spray/process()
	var/turf/T = loc
	if(!istype(T))
		STOP_PROCESSING(SSobj, src)
		qdel(src)
		return

	for(var/mob/living/carbon/M in loc)
		if(isxeno(M))
			continue
		Crossed(M)

//Medium-strength acid
/obj/effect/xenomorph/acid
	name = "acid"
	desc = "Burbling corrosive stuff. I wouldn't want to touch it."
	icon_state = "acid_normal"
	density = 0
	opacity = 0
	anchored = TRUE
	var/atom/acid_t
	var/ticks = 0
	var/acid_strength = 1 //100% speed, normal
	var/acid_damage = 125 //acid damage on pick up, subject to armor

//Sentinel weakest acid
/obj/effect/xenomorph/acid/weak
	name = "weak acid"
	acid_strength = 2.5 //250% normal speed
	acid_damage = 75
	icon_state = "acid_weak"

//Superacid
/obj/effect/xenomorph/acid/strong
	name = "strong acid"
	acid_strength = 0.4 //20% normal speed
	acid_damage = 175
	icon_state = "acid_strong"

/obj/effect/xenomorph/acid/New(loc, target)
	..(loc)
	acid_t = target
	var/strength_t = isturf(acid_t) ? 8:4 // Turf take twice as long to take down.
	tick(strength_t)

/obj/effect/xenomorph/acid/Destroy()
	acid_t = null
	. = ..()

/obj/effect/xenomorph/acid/proc/tick(strength_t)
	set waitfor = 0
	if(!acid_t || !acid_t.loc)
		qdel(src)
		return
	if(loc != acid_t.loc && !isturf(acid_t))
		loc = acid_t.loc
	if(++ticks >= strength_t)
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
			G.dismantle()
		else if(istype(acid_t, /obj/structure/window/framed))
			var/obj/structure/window/framed/WF = acid_t
			WF.drop_window_frame()

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

	sleep(rand(200,300) * (acid_strength))
	.()
