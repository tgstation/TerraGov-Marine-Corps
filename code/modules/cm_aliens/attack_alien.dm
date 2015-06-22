//This file deals with xenos clicking on stuff in general. Including mobs, objects, general atoms, etc.
//Abby

/mob/living/carbon/Xenomorph/RestrainedClickOn(var/atom/A) //If we're restrained, do nothing
	return

/mob/living/carbon/Xenomorph/UnarmedAttack(var/atom/A) //The generic CLICK A THING proc
	A.attack_alien(src)

/atom/proc/attack_alien(mob/user as mob) //The initial proc, defaults to mankeys
	return ..(attack_paw(user))

/mob/living/carbon/human/attack_alien(mob/living/carbon/Xenomorph/M as mob)

	if(istype(M,/mob/living/carbon/Xenomorph/Larva)) //Larva can't do shit-all
		visible_message("\red <B>[M] nudges its head against [src].</B>")
		return 0

	switch(M.a_intent)
		if ("help")
			visible_message(text("\blue \The [M] caresses [src] with its scythe like arm."))
			return 0

		if ("grab") //Defaults to ctrl-click pull. Grabs are fucked up!
			if(M == src || anchored)
				return
			if(check_shields(0, M.name) && rand(0,4) != 0) //Bit of a bonus
				visible_message("\red <B>\The [M]'s grab is blocked by [src]'s shield!</B>")
				return 0

			if(Adjacent(M)) //Logic!
				M.start_pulling(src)
				update_icons(M) //To immediately show the grab

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			visible_message(text("\red [] has grabbed []!", M, src))
		if("hurt")
			if(check_shields(0, M.name) && rand(0,4) != 0) //Bit of a bonus
				visible_message("\red <B>\The [M]'s slash is blocked by [src]'s shield!</B>")
				return 0
			var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
			if(!damage)
				playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1, -1)
				visible_message("\red <B>\The [M] has lunged at [src]!</B>")
				return 0
			var/datum/organ/external/affecting
//			if(istype(M, /mob/living/carbon/alien/humanoid/ravager))
//				affecting = get_organ(ran_zone("head", 95))
//			else
			affecting = get_organ(ran_zone(M.zone_sel.selecting,90))
			if(!affecting) //No organ, just get a random one
				affecting = get_organ(ran_zone(null,0))
			if(!affecting) //Still nothing??
				affecting = get_organ("chest") // Gotta have a torso?!

			var/armor_block = run_armor_check(affecting, "melee")

			playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
			visible_message("\red <B>\The [M] has slashed at [src]!</B>")
			M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [M.name] ([M.ckey])</font>")
//			if (src.stat != 2)
//				score_slashes_made++

			apply_damage(damage, BRUTE, affecting, armor_block, sharp=1, edge=1) //This should slicey dicey
			updatehealth()

		if("disarm")
			if(check_shields(0, M.name) && rand(0,7) != 0) //Bit of a bonus
				visible_message("\red <B> \The [M]'s tackle is blocked by [src]'s shield!</B>")
				return 0
			if(weakened)
				if (prob(20))
					playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
					Weaken(rand(M.tacklemin,M.tacklemax))//Min and max tackle strenght. They are located in individual caste files.
//					if (src.stat != 2)
//						score_tackles_made++
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("\red <B>\The [] has tackled down []!</B>", M, src), 1)
				else
					playsound(loc, 'sound/weapons/punchmiss.ogg', 50, 1, -1)
					visible_message(text("\red <B>\The [] tried to tackle [], but they're already down!</B>", M, src))

			else
				if (prob(M.tackle_chance)) //Tackle_chance is now a special var for each caste.
					playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
					Weaken(rand(M.tacklemin,M.tacklemax))
//					if (src.stat != 2)
//						score_tackles_made++
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("\red <B>\The [] has tackled down []!</B>", M, src), 1)
				else
					playsound(loc, 'sound/weapons/punchmiss.ogg', 50, 1, -1)
					visible_message(text("\red \The [] tried to tackle []!", M, src))
	return

//Every other type of nonhuman mob
/mob/living/attack_alien(mob/living/carbon/Xenomorph/M as mob)

	if(istype(M,/mob/living/carbon/Xenomorph/Larva))
		visible_message("\red <B>[M] nudges its head against [src].</B>")
		return 0

	switch(M.a_intent)
		if ("help")
			visible_message(text("\blue [M] caresses [src] with its scythe like arm. Ooh la la!"))

		if ("grab")
			if(M == src || anchored)
				return

			if(Adjacent(M)) //Logic!
				M.start_pulling(src)
				update_icons(M) //To immediately show the grab
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				visible_message(text("\red \The [] has grabbed [] passively!", M, src))

		if("hurt")//Can't slash other xenos for now. SORRY
			if(istype(src,/mob/living/carbon/Xenomorph))
				visible_message("\red \The [M] nibbles at [src].")
				return
			var/damage = rand(5,20) //Who cares, it's just Ian and the Monkeys (that would make a great band name)
			visible_message("\red \The [M] bites at \the [src]!")
			apply_damage(damage, BRUTE)

		if("disarm")
			playsound(loc, 'sound/weapons/punchmiss.ogg', 50, 1, -1)
			visible_message(text("\red [] shoves [].", M, src))
			if(ismonkey(src))
				src.Weaken(8)
	return

//This is a generic "attack an object" proc that doesn't use attack_alien.
//It's 1 step below the /atom/ proc of the same name, and a step above the specific item procs, like structures.
//Technically this proc isn't even necessary since most things are taken care of by specific sub-procs.
//Mostly used to stop xenos from picking stuff up.
/obj/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	if(istype(src,/obj/item/clothing/mask/facehugger)) //dealt with in hugger code
		src.attack_hand(M)
		return

	if(istype(src,/obj/item)) //Can't pick up anything but huggies
		return

	..() //Default to generic atom proc for everything else
	return

//Closets -- just make em like humans
/obj/structure/closet/attack_alien(mob/user as mob)
	if(isXenoLarva(user)) return //Larvae can't do shit
	return src.attack_hand(user)

//Breaking tables & racks. Other stuff do nothing - if you want to make it interact, make a new attack_alien sub-proc for it.
/obj/structure/table/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	if(isXenoLarva(M)) return //Larvae can't do shit
	if(breakable)
		src.health -= M.melee_damage_lower
		if(src.health <= 0)
			visible_message("<span class='danger'>[M] slices [src] apart!</span>")
			destroy()
		else
			visible_message("<span class='danger'>[M] slashes at [src]!</span>")

/obj/structure/rack/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	if(isXenoLarva(M)) return //Larvae can't do shit
	visible_message("<span class='danger'>[M] slices [src] apart!</span>")
	new /obj/item/weapon/rack_parts( src.loc )
	del(src)

//Default "structure" proc. This should be overwritten by sub procs.
//If we sent it to monkey we'd get some weird shit happening.
/obj/structure/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	return

//Smashing lights
/obj/machinery/light/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	if(isXenoLarva(M)) return //Larvae can't do shit
	if(status == 2) return //Broken - Just to be safe

	for(var/mob/Q in viewers(src))
		Q.show_message("\red [M.name] smashed the light!", 3, "You hear a tinkle of breaking glass", 2)
	broken() //smashola!

//Smashing windows
/obj/structure/window/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	if(isXenoLarva(M)) return //Larvae can't do shit
	if (M.a_intent == "hurt")
		attack_generic(M,M.melee_damage_lower / 3)
		return
	else
		playsound(src.loc, 'sound/effects/glassknock.ogg', 80, 1)
		M.visible_message("[M.name] taps on the [src.name] with a huge claw.", \
							"You creepily tap on the [src.name].", \
							"You hear a tap-tap-tapping sound.")

//Slashing turrets
/obj/machinery/turret/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	if(isXenoLarva(M)) return //Larvae can't do shit
	if(!(stat & BROKEN))
		playsound(src.loc, 'sound/weapons/slash.ogg', 25, 1, -1)
		visible_message("\red <B>[M] has slashed at [src]!</B>")
		src.take_damage(15)

//Slashing bots
/obj/machinery/bot/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	if(isXenoLarva(M)) return //Larvae can't do shit
	src.health -= rand(15,30)
	src.visible_message("\red <B>[M] has slashed [src]!</B>")
	playsound(src.loc, 'sound/weapons/slice.ogg', 25, 1, -1)
	if(prob(10))
		new /obj/effect/decal/cleanable/blood/oil(src.loc)
	healthcheck()

//Slashing cameras
/obj/machinery/camera/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	if(isXenoLarva(M)) return //Larvae can't do shit
	if(status)
		status = 0
		visible_message("<span class='warning'>\The [M] slashes at [src]!</span>")
		playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
		icon_state = "[initial(icon_state)]1"
		add_hiddenprint(M)
		deactivate(M,0)

//Slashing windoors
/obj/machinery/door/window/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	if(isXenoLarva(M)) return //Larvae can't do shit
	playsound(src.loc, 'sound/effects/Glasshit.ogg', 75, 1)
	visible_message("\red <B>[M] smashes against the [src.name].</B>", 1)
	take_damage(25)
	return

//Slashing mechas
/obj/mecha/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	if(isXenoLarva(M)) return //Larvae can't do shit
	src.log_message("Attack by claw. Attacker - [M].",1)

	if(!prob(src.deflect_chance))
		src.take_damage((rand(M.melee_damage_lower,M.melee_damage_upper)/2))
		src.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
		playsound(src.loc, 'sound/weapons/slash.ogg', 50, 1, -1)
		M << "\red You slash at the armored suit!"
		visible_message("\red [M] slashes at [src.name]'s armor!")
	else
		src.log_append_to_last("Armor saved.")
		playsound(src.loc, 'sound/weapons/slash.ogg', 50, 1, -1)
		M << "\green Your claws had no effect!"
		src.occupant_message("\blue The [M]'s claws are stopped by the armor.")
		visible_message("\blue The [M] rebounds off [src.name]'s armor!")
	return

//Slashin grilles
/obj/structure/grille/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	var/damage_dealt = 5
	M.visible_message("<span class='warning'>[M] mangles [src].</span>", \
		 "<span class='warning'>You mangle [src].</span>", \
		 "You hear twisting metal.")

	if(shock(M, 70))
		M.visible_message("<span class='warning'>ZAP! [M] spazzes wildly and there's the smell of burnt ozone.</span>", \
		 "<span class='warning'>ZAP! You twitch and dance like a monkey on hyperzine!</span>", \
		 "You hear a sharp ZAP and a smell of ozone.")
		return

	health -= damage_dealt
	healthcheck()
	return

//Slashin mirrors
/obj/structure/mirror/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	if(isXenoLarva(M)) return //Larvae can't do shit
	if(shattered)
		playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		return

	if(M.a_intent == "hurt")
		M.visible_message("<span class='danger'>[M] smashes [src]!</span>")
		shatter()
	else
		M << "Oooh la la, aren't you pretty?!" //lel
	return

//Foamed metal
/obj/structure/foamedmetal/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	if (rand(0,2) == 0)
		M << "\blue You slice through the metal foam wall."
		for(var/mob/O in oviewers(M))
			if ((O.client && !( O.blinded )))
				O << "\red [M] slice through the foamed metal."
		del(src)
		return
	else
		M << "\blue You try to slice through the foamed metal, but only tear off little shreds."
	return

//Wooden barricades
/obj/structure/barricade/wooden/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	if(isXenoLarva(M)) return //Larvae can't do shit
	src.health -= rand(M.melee_damage_lower,M.melee_damage_upper)
	M.visible_message("<span class='warning'>[M] slashes at [src.name]!</span>", \
		 "<span class='warning'>You slash at the barricade!</span>")
	if(src.health <= 0)
		visible_message("\red The [src.name]falls apart!")
		del(src)

//Prying open doors
/obj/machinery/door/airlock/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	var/turf/cur_loc = M.loc
	if(locked)
		M << "\blue The airlock's bolts prevent it from being forced."
		return
	if(welded)
		M << "\blue The airlock seems to be welded shut."
		return
	if(!istype(cur_loc)) return //Some basic logic here
	if(!density)
		M << "It's already open!"
		return

	if(isXenoLarva(M)) //Larvae cannot pry open doors, but they CAN squeeze under them.
		M.visible_message("\The [M] scuttles underneath [src.name]!","You squeeze and scuttle underneath the [src.name].")
		if(!isnull(src.loc)) //logic
			M.loc = src.loc
			return

	playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
	M.visible_message("<span class='warning'> \The [M] digs into [src.name] and begins to pry it open.</span>", \
		 			"<span class='warning'>You begin to pry open [src.name].</span>")

	if(do_after(M,40))
		if(M.loc != cur_loc) return //Make sure we're still there
		if(density) //Make sure it's still closed
			spawn(0)
				open(1)

//Prying open FIREdoors
/obj/machinery/door/firedoor/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	var/turf/cur_loc = M.loc
	if(!istype(cur_loc)) return //Some basic logic here
	if(!density)
		M << "It's already open!"
		return
	if(isXenoLarva(M)) return //Larvae can't do shit

	playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
	M.visible_message("<span class='warning'> \The [M] digs into [src.name] and begins to pry it open.</span>", \
		 			"<span class='warning'>You begin to pry open [src.name].</span>")

	if(do_after(M,30))
		if(M.loc != cur_loc) return //Make sure we're still there
		if(density) //Make sure it's still closed
			spawn(0)
				open(1)

//Beds, nests and chairs - unbuckling
/obj/structure/stool/bed/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	if(isXenoLarva(M)) return //Larvae can't do shit
	attack_hand(M)
	return

//clicking on resin doors attacks them, or opens them without harm intent
/obj/structure/mineral_door/resin/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	var/turf/cur_loc = M.loc
	if(!istype(cur_loc)) return //Some basic logic here
	if(M.a_intent != "hurt")
		TryToSwitchState(M)
		return

	M.visible_message("<span class='warning'> \red [M] digs into [src.name] and begins ripping it down. </span>", \
		 			"<span class='warning'> \red You begin to rip down [src.name]. Hold still.. </span>")
	if(do_after(M,80))
		if(M.loc != cur_loc) return //Make sure we're still there
		if(!src) return //Someone already destroyed it, do_after should check this but best to be safe
		M.visible_message("<span class='warning'> \red [M] rips down [src.name]! </span>", \
		 			"<span class='warning'> \red You rip down [src.name]! </span>")
		del(src)
	return

//Computers -- Queens can use any consoles!
//Others do nothing.
/obj/machinery/computer/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	if(!M.is_intelligent || !istype(src,/obj/machinery/computer/shuttle))
		M << "You stare at [src.name] cluelessly."
		return
	else
		return attack_hand(M)

//APCs. Don't slash em for now, we'll deal with that later.
/obj/machinery/power/apc/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	if(!M)
		return

	M.visible_message("\red [M.name] slashes at the [src.name]!", "\blue You slash at the [src.name]!")
	playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
	var/allcut = 1
	for(var/wire in apcwirelist)
		if(!isWireCut(apcwirelist[wire]))
			allcut = 0
			break
	if(beenhit >= pick(3, 4) && wiresexposed != 1)
		wiresexposed = 1
		src.update_icon()
		src.visible_message("\red The [src.name]'s cover flies open, exposing the wires!")

	else if(wiresexposed == 1 && allcut == 0)
		for(var/wire in apcwirelist)
			cut(apcwirelist[wire])
		src.update_icon()
		src.visible_message("\red The [src.name]'s wires are shredded!")
	else
		beenhit += 1
	return

//Some generic defaults
/obj/machinery/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	M << "You stare at [src.name] cluelessly."
	return

/obj/structure/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	return