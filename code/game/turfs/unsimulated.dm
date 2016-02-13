/turf/unsimulated
	intact = 1
	name = "command"
	can_bloody = 1
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD

/turf/unsimulated/Entered(atom/A, atom/OL)
	if(movement_disabled && usr.ckey != movement_disabled_exception)
		usr << "\red Movement is admin-disabled." //This is to identify lag problems
		return

	if (istype(A,/mob/living/carbon))
		var/mob/living/carbon/M = A
		if(M.lying)
			..()
			return
		/*
		dirt++
		var/obj/effect/decal/cleanable/dirt/dirtoverlay = locate(/obj/effect/decal/cleanable/dirt, src)
		if (dirt >= 50)
			if (!dirtoverlay)
				dirtoverlay = new/obj/effect/decal/cleanable/dirt(src)
				dirtoverlay.alpha = 15
			else if (dirt > 50)
				dirtoverlay.alpha = min(dirtoverlay.alpha+5, 255)
		*/
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			/*
			if(istype(H.shoes, /obj/item/clothing/shoes/clown_shoes))
				var/obj/item/clothing/shoes/clown_shoes/O = H.shoes
				if(H.m_intent == "run")
					if(O.footstep >= 2)
						O.footstep = 0
						playsound(src, "clownstep", 50, 1) // this will get annoying very fast.
					else
						O.footstep++
				else
					playsound(src, "clownstep", 20, 1)
			*/
			// Tracking blood
			var/list/bloodDNA = null
			var/bloodcolor=""
			if(H.shoes)
				var/obj/item/clothing/shoes/S = H.shoes
				if(S.track_blood && S.blood_DNA)
					bloodDNA = S.blood_DNA
					bloodcolor=S.blood_color
					S.track_blood--
			else
				if(H.track_blood && H.feet_blood_DNA)
					bloodDNA = H.feet_blood_DNA
					bloodcolor=H.feet_blood_color
					H.track_blood--

			if (bloodDNA)
				src.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints,bloodDNA,H.dir,0,bloodcolor) // Coming
				var/turf/from = get_step(H,reverse_direction(H.dir))
				if(istype(from) && from)
					from.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints,bloodDNA,0,H.dir,bloodcolor) // Going

				bloodDNA = null
/*
//		var/noslip = 0
		if(M.buckled && istype(M.buckled,/obj/structure/stool/bed/chair))
			return
//		for (var/obj/structure/stool/bed/chair/C in loc)
//			if (C.buckled_mob == M)
//				noslip = 1
//		if (noslip)
//			return // no slipping while sitting in a chair, plz

//We wont do this yet.
		switch (src.wet)
			if(1)
				if(istype(M, /mob/living/carbon/human)) // Added check since monkeys don't have shoes
					if ((M.m_intent == "run") && !(istype(M:shoes, /obj/item/clothing/shoes) && M:shoes.flags&NOSLIP))
						M.stop_pulling()
						step(M, M.dir)
						M << "\blue You slipped on the wet floor!"
						playsound(src, 'sound/misc/slip.ogg', 50, 1, -3)
						M.Stun(5)
						M.Weaken(3)
					else
						M.inertia_dir = 0
						return
				else if(!istype(M, /mob/living/carbon/slime) && !istype(M, /mob/living/carbon/Xenomorph) )
					if (M.m_intent == "run")
						M.stop_pulling()
						step(M, M.dir)
						M << "\blue You slipped on the wet floor!"
						playsound(src, 'sound/misc/slip.ogg', 50, 1, -3)
						M.Stun(5)
						M.Weaken(3)
					else
						M.inertia_dir = 0
						return

			if(2) //lube                //can cause infinite loops - needs work
				if(!istype(M, /mob/living/carbon/slime) && !M.buckled && !istype(M, /mob/living/carbon/Xenomorph))
					M.stop_pulling()
					step(M, M.dir)
					spawn(1) step(M, M.dir)
					spawn(2) step(M, M.dir)
					spawn(3) step(M, M.dir)
					spawn(4) step(M, M.dir)
					M.take_organ_damage(2) // Was 5 -- TLE
					M << "\blue You slipped on the floor!"
					playsound(src, 'sound/misc/slip.ogg', 50, 1, -3)
					M.Weaken(10)
			if(3) // Ice
				if(istype(M, /mob/living/carbon/human)) // Added check since monkeys don't have shoes
					if ((M.m_intent == "run") && !(istype(M:shoes, /obj/item/clothing/shoes) && M:shoes.flags&NOSLIP) && prob(30))
						M.stop_pulling()
						step(M, M.dir)
						M << "\blue You slipped on the icy floor!"
						playsound(src, 'sound/misc/slip.ogg', 50, 1, -3)
						M.Stun(4)
						M.Weaken(3)
					else
						M.inertia_dir = 0
						return
				else if(!istype(M, /mob/living/carbon/slime) && !istype(M, /mob/living/carbon/Xenomorph))
					if (M.m_intent == "run" && prob(30))
						M.stop_pulling()
						step(M, M.dir)
						M << "\blue You slipped on the icy floor!"
						playsound(src, 'sound/misc/slip.ogg', 50, 1, -3)
						M.Stun(4)
						M.Weaken(3)
					else
						M.inertia_dir = 0
						return
*/
	..()