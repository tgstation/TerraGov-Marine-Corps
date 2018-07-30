

//Xeno-style acids
//Ideally we'll consolidate all the "effect" objects here
//Also need to change the icons
/obj/effect/xenomorph
	name = "alien thing"
	desc = "You shouldn't be seeing this."
	icon = 'icons/Xeno/effects.dmi'
	unacidable = 1
	layer = FLY_LAYER

/obj/effect/xenomorph/splatter
	name = "splatter"
	desc = "It burns! It burns like hygiene!"
	icon_state = "splatter"
	density = 0
	opacity = 0
	anchored = 1

/obj/effect/xenomorph/splatter/New() //Self-deletes after creation & animation
	..()
	spawn(8)
		cdel(src)


/obj/effect/xenomorph/splatterblob
	name = "splatter"
	desc = "It burns! It burns like hygiene!"
	icon_state = "acidblob"
	density = 0
	opacity = 0
	anchored = 1

/obj/effect/xenomorph/splatterblob/New() //Self-deletes after creation & animation
	..()
	spawn(40)
		cdel(src)


/obj/effect/xenomorph/spray
	name = "splatter"
	desc = "It burns! It burns like hygiene!"
	icon_state = "acid2"
	density = 0
	opacity = 0
	anchored = 1
	layer = ABOVE_OBJ_LAYER
	mouse_opacity = 0
	flags_pass = PASSTABLE|PASSMOB|PASSGRILLE

/obj/effect/xenomorph/spray/New() //Self-deletes
	..()
	processing_objects.Add(src)
	spawn(100 + rand(0, 20))
		processing_objects.Remove(src)
		cdel(src)
		return

/obj/effect/xenomorph/spray/Crossed(AM as mob|obj)
	..()
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(!H.lying)
			H << "<span class='danger'>Your feet scald and burn! Argh!</span>"
			H.emote("pain")
			H.KnockDown(3)
			var/datum/limb/affecting = H.get_limb("l_foot")
			if(istype(affecting) && affecting.take_damage(0, rand(5, 10)))
				H.UpdateDamageIcon()
			affecting = H.get_limb("r_foot")
			if(istype(affecting) && affecting.take_damage(0, rand(5, 10)))
				H.UpdateDamageIcon()
			H.updatehealth()
		else
			H.adjustFireLoss(rand(2, 5)) //This is ticking damage!
			H << "<span class='danger'>You are scalded by the burning acid!</span>"

/obj/effect/xenomorph/spray/process()
	var/turf/T = loc
	if(!istype(T))
		processing_objects.Remove(src)
		cdel(src)
		return

	for(var/mob/living/carbon/M in loc)
		if(isXeno(M))
			continue
		Crossed(M)

//Medium-strength acid
/obj/effect/xenomorph/acid
	name = "acid"
	desc = "Burbling corrosive stuff. I wouldn't want to touch it."
	icon_state = "acid_normal"
	density = 0
	opacity = 0
	anchored = 1
	unacidable = 1
	var/atom/acid_t
	var/ticks = 0
	var/acid_strength = 1 //100% speed, normal

//Sentinel weakest acid
/obj/effect/xenomorph/acid/weak
	name = "weak acid"
	acid_strength = 2.5 //250% normal speed
	icon_state = "acid_weak"

//Superacid
/obj/effect/xenomorph/acid/strong
	name = "strong acid"
	acid_strength = 0.4 //20% normal speed
	icon_state = "acid_strong"

/obj/effect/xenomorph/acid/New(loc, target)
	..(loc)
	acid_t = target
	var/strength_t = isturf(acid_t) ? 8:4 // Turf take twice as long to take down.
	tick(strength_t)

/obj/effect/xenomorph/acid/Dispose()
	acid_t = null
	. = ..()

/obj/effect/xenomorph/acid/proc/tick(strength_t)
	set waitfor = 0
	if(!acid_t || !acid_t.loc)
		cdel(src)
		return
	if(++ticks >= strength_t)
		visible_message("<span class='xenodanger'>[acid_t] collapses under its own weight into a puddle of goop and undigested debris!</span>")
		playsound(src, "acid_hit", 25)

		if(istype(acid_t, /turf))
			if(istype(acid_t, /turf/closed/wall))
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
			cdel(acid_t)
			acid_t = null

		cdel(src)
		return

	switch(strength_t - ticks)
		if(6) visible_message("<span class='xenowarning'>\The [acid_t] is barely holding up against the acid!</span>")
		if(4) visible_message("<span class='xenowarning'>\The [acid_t]\s structure is being melted by the acid!</span>")
		if(2) visible_message("<span class='xenowarning'>\The [acid_t] is struggling to withstand the acid!</span>")
		if(0 to 1) visible_message("<span class='xenowarning'>\The [acid_t] begins to crumble under the acid!</span>")

	sleep(rand(200,300) * (acid_strength))
	.()