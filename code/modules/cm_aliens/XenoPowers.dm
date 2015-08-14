//Xenomorph Super - Colonial Marines - Apophis775 - Last Edit: 8FEB2015

//Their verbs are all actually procs, so we don't need to add them like 4 times copypaste for different species
//Just add the name to the caste's inherent_verbs() list

/mob/living/carbon/Xenomorph/verb/middle_mousetoggle()
	set name = "Toggle Middle Clicking"
	set desc = "Toggles middle mouse button for hugger throwing, neuro spit, and other abilities."
	set category = "Alien"

	if(!middle_mouse_toggle)
		src << "You turn middle mouse clicking ON for certain xeno abilities."
		middle_mouse_toggle = 1
	else
		src << "You turn middle mouse clicking OFF. Middle mouse button will instead change active hands."
		middle_mouse_toggle = 0

	return

/mob/living/carbon/Xenomorph/verb/shift_mousetoggle()
	set name = "Toggle Shift Clicking"
	set desc = "Toggles shift + mouse button for hugger throwing, neuro spit, and other abilities."
	set category = "Alien"

	if(!shift_mouse_toggle)
		src << "You turn shift clicking ON for certain xeno abilities."
		shift_mouse_toggle = 1
	else
		src << "You turn shift clicking OFF. Shift click will instead examine."
		shift_mouse_toggle = 0

	return

/mob/living/carbon/Xenomorph/proc/shift_spits()
	set name = "Toggle Spit Type"
	set desc = "Toggles between a lighter, single-target stun spit or a heavier area acid that burns. The heavy version requires more plasma."
	set category = "Alien"

	if(!spit_type)
		src << "You will now spit heavier globs of acid instead of neurotoxin."
		spit_type = 1
		spit_delay = (initial(spit_delay) + 20) //Takes longer to recharge.
		if(istype(src,/mob/living/carbon/Xenomorph/Praetorian))
			spit_projectile = /obj/item/projectile/energy/neuro/acid/heavy
		else
			spit_projectile = /obj/item/projectile/energy/neuro/acid/
	else
		src << "You will now spit lighter neurotoxin instead of acid."
		spit_type = 0
		spit_projectile = initial(spit_projectile)
		spit_delay = initial(spit_delay)
	return

/mob/living/carbon/Xenomorph/proc/plant()
	set name = "Plant Weeds (75)"
	set desc = "Plants some alien weeds"
	set category = "Alien"

	if(!check_state()) return

	var/turf/T = src.loc

	if(!istype(T) || isnull(T))
		src << "You can't do that here."
		return

	if(!is_weedable(T))
		src << "Bad place for a garden!"
		return

	if(locate(/obj/effect/alien/weeds/node) in T)
		src << "There's a pod here already.!"
		return

	if(check_plasma(75))
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>\The [src] regurgitates a pulsating node and plants it on the ground!</B>"), 1)
		new /obj/effect/alien/weeds/node(loc)
		playsound(loc, 'sound/effects/splat.ogg', 30, 1) //splat!
	return

/mob/living/carbon/Xenomorph/proc/lay_egg()

	set name = "Lay Egg (100)"
	set desc = "Lay an egg to produce huggers to impregnate prey with."
	set category = "Alien"

	if(!check_state()) return

	var/turf/T = src.loc

	if(!istype(T) || isnull(T))
		src << "You can't do that here."
		return

	if(locate(/obj/effect/alien/egg) in get_turf(src) || locate(/obj/royaljelly) in get_turf(src)) //Turn em off for now
		src << "There's already an egg or royal jelly here."
		return

	if(!locate(/obj/effect/alien/weeds) in T)
		src << "Your eggs wouldn't grow well enough here. Lay them on resin."
		return

	if(check_plasma(100)) //New plasma check proc, removes/updates plasma automagically
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>\The [src] has laid an egg!</B>"), 1)
		new /obj/effect/alien/egg(T)
	return

/obj/royaljelly
	name = "royal jelly"
	desc = "A greenish-yellow blob of slime that encourages xenomorph evolution."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "jelly"
	anchored = 1
	opacity = 0
	density = 0
	layer = 3.4 //On top of most things

/obj/royaljelly/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	if(!istype(M,/mob/living/carbon/Xenomorph) || istype(M,/mob/living/carbon/Xenomorph/Larva))
		return

	if(M.jelly)
		M << "You're already filled with delicious jelly."
		return

	if(!M.jellyMax)
		M << "Doesn't smell very good to you. You aren't able to evolve further using jelly."
		return

	M.jelly = 1
	visible_message("\green [M] greedily devours the [src].","You greedily gulp down the [src].")
	del(src)

/mob/living/carbon/Xenomorph/proc/produce_jelly()

	set name = "Produce Jelly (350)"
	set desc = "Squirt out some royal jelly for hive advancement."
	set category = "Alien"

	if(!check_state())
		return

	var/turf/T = src.loc

	if(!istype(T) || isnull(T))
		src << "You can't do that here."
		return

	if(locate(/obj/effect/alien/egg) in get_turf(src) || locate(/obj/royaljelly) in get_turf(src))
		src << "There's already an egg or royal jelly here."
		return

	if(!locate(/obj/effect/alien/weeds) in T)
		src << "Your jelly would rot here. Lay them on resin."
		return

	if(check_plasma(350)) //New plasma check proc, removes/updates plasma automagically
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>\The [src] squirts out a greenish blob of jelly.</B>"), 1)
		new /obj/royaljelly(T)
	return

/mob/living/carbon/Xenomorph/proc/Pounce(var/atom/T)
	set name = "Pounce (10)"
	set desc = "Pounce on someone. Click a turf to just leap there."
	set category = "Alien"

	if(!check_state())	return

	if(usedPounce)
		src << "\red You must wait before pouncing."
		return

	if(!check_plasma(10))
		return

	if(!T)
		var/list/victims = list()
		for(var/mob/living/carbon/human/C in oview(7))
			if(C && istype(C) && !C.stat && !C.lying )
				victims += C
		T = input(src, "Who should you pounce towards?") as null|anything in victims

	if(T)
		visible_message("\red <B>[src] pounces at [T]!</B>","\red <b> You leap at [T]!</B>" )
		usedPounce = 180 //about 12 seconds
		pass_flags = PASSTABLE
		if(readying_tail) readying_tail = 0
		src.throw_at(T, 6, 2, src) //victim, distance, speed
		spawn(12)
			pass_flags = 0 //Reset the passtable.
		spawn(usedPounce)
			usedPounce = 0
			src << "You get ready to pounce again."
	else
		storedplasma += 5 //Since we already stole 5
		src << "\blue You cannot pounce at nothing!"
	return

/mob/living/carbon/Xenomorph/proc/vent_crawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Alien"
	if(!check_state())	return
	handle_ventcrawl()
	return

/mob/living/carbon/Xenomorph/proc/xenohide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Alien"
	if(stat || paralysis || stunned || weakened || lying || restrained() || buckled)
		src << "You cannot do this in your current state."
		return
	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		src << text("\blue You are now hiding.")
	else
		layer = MOB_LAYER
		src << text("\blue You have stopped hiding.")

/mob/living/carbon/Xenomorph/proc/gut()
	set category = "Alien"
	set name = "Gut (200)"
	set desc = "While pulling someone, rip their guts out or tear them apart."

	if(!check_state())	return

	if(last_special > world.time)
		return

	var/mob/living/carbon/victim = src.pulling
	if(!victim || isnull(victim) || !istype(victim))
		src << "You're not pulling anyone that can be gutted."
		return

	if(locate(/obj/item/alien_embryo) in victim || locate(/obj/item/alien_embryo) in victim.contents) // Maybe they ate it??
		src << "Not with a widdle alium inside! How cruel!"
		return

	if(istype(victim,/mob/living/carbon/Xenomorph))
		src << "Hey now, that's just not cool."
		return

	var/turf/cur_loc = victim.loc
	if(!cur_loc) return //logic
	if(!cur_loc || !istype(cur_loc)) return

	if(!check_plasma(200))
		return

	last_special = world.time + 50

	visible_message("<span class='warning'><b>\The [src]</b> lifts [victim] into the air...</span>")
	if(do_after(src,80))
		if(!victim || isnull(victim)) return
		if(victim.loc != cur_loc) return
		visible_message("<span class='warning'><b>\The [src]</b> viciously wrenches [victim] apart!</span>")
		emote("roar")
		src.attack_log += text("\[[time_stamp()]\] <font color='red'>gibbed [victim.name] ([victim.ckey])</font>")
		victim.attack_log += text("\[[time_stamp()]\] <font color='orange'>was gibbed by [src.name] ([src.ckey])</font>")
		victim.gib() //Splut


/mob/living/carbon/Xenomorph/proc/regurgitate()
	set name = "Regurgitate"
	set desc = "Empties the contents of your stomach"
	set category = "Alien"

	if(!check_state())	return

	if(stomach_contents.len)
		for(var/mob/M in src)
			if(M in stomach_contents)
				stomach_contents.Remove(M)
				M.loc = loc
		src.visible_message("\red <B>\The [src] hurls out the contents of their stomach!</B>")
	else
		src << "There's nothing in your belly that needs regurgitating."
	return

/mob/living/carbon/Xenomorph/proc/psychic_whisper(mob/M as mob in oview())
	set name = "Psychic Whisper"
	set desc = "Whisper silently to someone over a distance."
	set category = "Alien"

	if(!check_state())	return

	var/msg = sanitize(input("Message:", "Psychic Whisper") as text|null)
	if(msg)
		log_say("PsychicWhisper: [key_name(src)]->[M.key] : [msg]")
		M << "\green You hear a strange, alien voice in your head... \italic [msg]"
		src << "\green You said: \"[msg]\" to [M]"
	return

/mob/living/carbon/Xenomorph/proc/transfer_plasma(mob/living/carbon/Xenomorph/M as mob in oview(1))
	set name = "Transfer Plasma"
	set desc = "Transfer Plasma to another alien"
	set category = "Alien"

	if(!check_state())	return

	if(!M || !istype(M)) return

	if (get_dist(src,M) >= 3)
		src << "\green You need to be closer."
		return

	var/amount = input("Amount:", "Transfer Plasma to [M]") as num
	if (amount)
		amount = abs(round(amount))
		if(storedplasma < amount)
			amount = storedplasma //Just use all of it
		storedplasma -= amount
		M.storedplasma += amount
		if(M.storedplasma > M.maxplasma) M.storedplasma = M.maxplasma
		M << "\green [src] has transfered [amount] plasma to you. You now have [M.storedplasma]."
		src << "\green You have transferred [amount] plasma to [M]. You now have [src.storedplasma]."
	return

/mob/living/carbon/Xenomorph/proc/build_resin() // -- TLE
	set name = "Secrete Resin (75)"
	set desc = "Secrete tough malleable resin."
	set category = "Alien"

	if(!check_state())	return

	if(!is_weedable(loc))
		src << "Bad place for a garden!"
		return

	var/turf/T = loc
	var/turf/T2 = null
	if(!T || !istype(T)) //logic
		return

	if(!locate(/obj/effect/alien/weeds) in T)
		src << "You can only shape on weeds. Find some resin before you start building!"
		return
	if(locate(/obj/structure/mineral_door) in T || locate(/obj/effect/alien/resin) in T)
		src << "There's something built here already."
		return
	if(locate(/obj/structure/stool/) in T)
		src << "There's something here already."
		return

	var/choice = input("Choose what you wish to shape.","Resin building") as null|anything in list("resin door","resin wall","resin membrane","resin nest", "sticky resin", "cancel")

	if(!choice || choice == "cancel")
		return

	T2 = loc

	if(T != T2 || !isturf(T2))
		src << "You have to stand still when making your selection."
		return
	//Another check, in case someone built where they were standing somehow.
	if(!locate(/obj/effect/alien/weeds) in T2)
		src << "You can only shape on weeds. Find some resin before you start building!"
		return
	if(locate(/obj/structure/mineral_door) in T2 || locate(/obj/effect/alien/resin) in T2)
		src << "There's something built here already."
		return
	if(locate(/obj/structure/stool) in T)
		src << "There's something here already."
		return

	if(!check_plasma(75))
		return

	src << "\green You shape a [choice]."
	for(var/mob/O in viewers(src, null))
		if(O != src)
			O.show_message(text("\red <B>[src] vomits up a thick substance and begins to shape it!</B>"), 1)

	switch(choice)
		if("resin door")
			new /obj/structure/mineral_door/resin(T)
		if("resin wall")
			new /obj/effect/alien/resin/wall(T)
		if("resin membrane")
			new /obj/effect/alien/resin/membrane(T)
		if("resin nest")
			new /obj/structure/stool/bed/nest(T)
		if("sticky resin")
			new /obj/effect/alien/resin/sticky(T)
	return

//Note: All the neurotoxin projectile items are stored in XenoProcs.dm
/mob/living/carbon/Xenomorph/proc/neurotoxin(var/atom/T)
	set name = "Spit Neurotoxin (50/100)"
	set desc = "Spits neurotoxin at someone, paralyzing them for a short time, or globs of acid which burn in an area."
	set category = "Alien"

	if(!check_state())	return

	if(has_spat)
		usr << "You must wait for your neurotoxin glands to refill."
		return

	if(!isturf(usr.loc))
		usr << "You can't spit from here!"
		return

	if(!spit_projectile) return

	if(!T)
		var/list/victims = list()
		for(var/mob/living/carbon/human/C in oview(7))
			if(!C.stat)
				victims += C
		victims += "Cancel"
		T = input(src, "Who should you spit towards?") as null|anything in victims
	if(T == "Cancel")
		return

	if(T)
		if(spit_type)
			if(!check_plasma(100))
				return
		else
			if(!check_plasma(50))
				return

		visible_message("\red <B>\The [src] spits at [T]!</B>","\red <b> You spit at [T]!</B>" )

		var/turf/Turf = get_turf(src)
		var/turf/Target_Turf = get_turf(T)

		if(!Target_Turf || !Turf)
			return

		var/obj/item/projectile/energy/neuro/A = new spit_projectile(Turf)
		if(is_robotic && isturf(src.loc))
			playsound(src.loc,'sound/weapons/pulse.ogg',75,1)
		A.current = Target_Turf
		A.yo = Target_Turf.y - Turf.y
		A.xo = Target_Turf.x - Turf.x
		A.def_zone = get_organ_target()
		A.firer = src
		A.original= T
		spawn(1)
			A.process()

		has_spat = 1
		spawn(spit_delay)
			has_spat = 0
			src << "You feel your glands swell with ichor. You can spit again."
	else
		src << "You cannot spit at nothing!"
	return

/mob/living/carbon/Xenomorph/proc/throw_hugger(var/mob/living/carbon/T)
	set name = "Throw Facehugger"
	set desc = "Throw one of your facehuggers. MIDDLE MOUSE BUTTON quick-throws."
	set category = "Alien"

	if(!check_state())	return

	var/mob/living/carbon/Xenomorph/Carrier/X = src
	if(!istype(X))
		src << "How did you get this verb??" //Lel. Shouldn't be possible, butcha never know. Since this uses carrier-only vars
		return

	if(X.huggers_cur <= 0)
		src << "\red You don't have any facehuggers to throw!"
		return

	if(!X.threw_a_hugger)
		if(!T)
			var/list/victims = list()
			for(var/mob/living/carbon/human/C in oview(7))
				victims += C
			T = input(src, "Who should you throw at?") as null|anything in victims

		if(T)
			var/obj/item/clothing/mask/facehugger/throw = new()
			X.huggers_cur -= 1
			throw.loc = src.loc
			throw.throw_at(T, 5, X.throwspeed)
			src << "You throw a facehugger at [throw]."
			visible_message("\red <B>[src] throws something towards [T]!</B>")
			X.threw_a_hugger = 1
			spawn(40)
				X.threw_a_hugger = 0
		else
			src << "\blue You cannot throw at nothing!"
	return

/mob/living/carbon/Xenomorph/proc/charge(var/atom/T)
	set name = "Charge (20)"
	set desc = "Charge towards something! Raaaugh!"
	set category = "Alien"

	if(!check_state())	return

	if(!istype(src,/mob/living/carbon/Xenomorph/Ravager))
		src << "How did you get this verb??" //Shouldn't be possible. Ravagers have some vars here that aren't in other castes.
		return

	//Hate using :
	var/mob/living/carbon/Xenomorph/Ravager/X = src

	if(!usedPounce)
		if(!T)
			var/list/victims = list()
			for(var/mob/living/carbon/human/C in oview(6))
				if(C && istype(C) && !C.lying && !C.stat)
					victims += C
			T = input(X, "Who should you charge towards?") as null|anything in victims

		if(T)
			if(!check_plasma(20))
				return
			visible_message("\red <B>[X] charges towards [T]!</B>","\red <b> You charge at [T]!</B>" )
			emote("roar") //heheh
			X.pass_flags = PASSTABLE
			X.usedPounce = 1 //This has to come before throw_at, which checks impact. So we don't do end-charge specials when thrown
			if(readying_tail) readying_tail = 0
			X.throw_at(T, X.CHARGEDISTANCE, X.CHARGESPEED, src)
			spawn(10)
				X.pass_flags = 0
			spawn(X.CHARGECOOLDOWN)
				X.usedPounce = 0
				X << "Your exoskeleton quivers as you get ready to charge again."

		else
			X << "\blue You cannot charge at nothing!"

/mob/living/carbon/Xenomorph/proc/screech()
	set name = "Screech (250)"
	set desc = "Emit a screech that stuns prey."
	set category = "Alien"

	if(!check_state()) return

	if(has_screeched)
		src << "\red Your vocal chords are not yet prepared."
		return

	if(!check_plasma(250))
		return

	has_screeched = 1
	spawn(500)
		has_screeched = 0
		src << "You feel your throat muscles vibrate. You are ready to screech again."

	playsound(loc, 'sound/voice/alien_queen_screech.ogg', 100, 0, 100, -1)
	visible_message("\red <B> \The [src] emits an ear-splitting guttural roar!</B>")
	create_shriekwave() //Adds the visual effect. Wom wom wom

	for(var/mob/M in view())
		if(M && M.client)
			if(istype(M,/mob/living/carbon/Xenomorph))
				shake_camera(M, 10, 1)
			else
				shake_camera(M, 30, 1) // 50 deciseconds, SORRY 5 seconds was way too long. 3 seconds now

	for (var/mob/living/carbon/human/M in oview())
		if(istype(M.l_ear, /obj/item/clothing/ears/earmuffs) || istype(M.r_ear, /obj/item/clothing/ears/earmuffs))
			continue
		var/dist = get_dist(src,M)
		if (dist <= 4)
			M << "\blue An ear-splitting guttural roar shakes the ground beneath your feet!"
			M.stunned += 4 //Seems the effect lasts between 3-8 seconds.
			M.Weaken(1)
//			M.drop_l_hand() //Weaken will drop them on the floor anyway
//			M.drop_r_hand()
			if(!M.ear_deaf)
				M.ear_deaf += 8 //Deafens them temporarily
		else if(dist >= 5 && dist < 7)
			M.stunned += 3
			M << "\blue The sound stuns you!"
	return

//Corrosive acid is consolidated -- it checks for specific castes for strength now, but works identically to each other.
//The acid items are stored in XenoProcs.
/mob/living/carbon/Xenomorph/proc/corrosive_acid(O as obj|turf in oview(1)) //If they right click to corrode, an error will flash if its an invalid target./N
	set name = "Corrosive Acid (variable)"
	set desc = "Drench an object in acid. Drones/Sentinel cost 75, Praetorians 200, everything else 100."
	set category = "Alien"

	if(!check_state())	return

	if(!O in oview(1))
		src << "\green [O] is too far away."
		return

	// OBJ CHECK
	if(isobj(O))
		var/obj/I = O
		if(I.unacidable || istype(I,/obj/machinery/computer) || istype(I,/obj/effect))	//So the aliens don't destroy energy fields/singularies/other aliens/etc with their acid.
			src << "\green You cannot dissolve this object." // ^^ Note for obj/effect.. this might check for unwanted stuff. Oh well
			return

	// TURF CHECK
	else if(istype(O, /turf/simulated))
		var/turf/T = O
		// R WALL
		if(istype(T,/turf/unsimulated/floor) || istype(T, /turf/simulated/shuttle) || istype(T, /turf/simulated/floor) || istype(T,/turf/simulated/mineral))
			src << "\green You cannot dissolve this."
			return
		if(istype(T, /turf/simulated/wall/r_wall) && !istype(src,/mob/living/carbon/Xenomorph/Praetorian))
			src << "\green This wall is too tough to be melted by your weak acid."
			return
	else
		src << "\green You cannot dissolve this object."
		return

	if(istype(src,/mob/living/carbon/Xenomorph/Sentinel) || istype(src,/mob/living/carbon/Xenomorph/Drone) ) //weak level
		if(!check_plasma(75)) return
		new /obj/effect/xenomorph/acid/weak(get_turf(O), O)

	else if(istype(src,/mob/living/carbon/Xenomorph/Praetorian)) //strong level
		if(!check_plasma(200)) return
		new /obj/effect/xenomorph/acid/strong(get_turf(O), O)

	else
		if(!check_plasma(100)) return
		new /obj/effect/xenomorph/acid(get_turf(O), O) //Everything else? Medium.
	if(!isturf(O))
		msg_admin_attack("[src.name] ([src.ckey]) spat acid on [O].")
	visible_message("\green <B>[src] vomits globs of vile stuff all over [O]. It begins to sizzle and melt under the bubbling mess of acid!</B>")
	return

/mob/living/carbon/Xenomorph/proc/build_tunnel() // -- TLE
	set name = "Dig Tunnel (200)"
	set desc = "Place a start or end tunnel. You must place both parts before it is useable and they can NOT be moved. Choose carefully!"
	set category = "Alien"

	if(!check_state())	return

	var/turf/T = loc
	if(!T) //logic
		src << "You can only do this on a turf."
		return

	if(istype(T,/turf/simulated/floor/gm/river))
		src << "What, you want to flood your fellow xenos?"
		return

	if(!istype(T,/turf/simulated/floor/gm))
		src << "You scrape around, but nothing happens. You can only place these on open ground."
		return

	if(locate(/obj/structure/tunnel) in src.loc)
		src << "There's already a tunnel here. Go somewhere else."
		return

	if(tunnel_delay)
		src << "You are not yet ready to fashion a new tunnel. Be patient! Tunneling is hard work!"
		return

	if(!check_plasma(200))
		return

	visible_message("\blue [src] begins carefully digging out a huge, wide tunnel.","\blue You begin carefully digging out a tunnel..")
	if(do_after(src,100))
		if(!start_dig) //Let's start a new one.
			src << "\blue You dig out the beginning of a new tunnel. Go somewhere else and dig a new one to finish it!"
			start_dig = new /obj/structure/tunnel(T)
		else
			src << "\blue You finish digging out the two tunnels and connect them together!"
			var/obj/structure/tunnel/newt = new /obj/structure/tunnel(T)
			newt.other = start_dig
			start_dig.other = newt //Link the two together
			start_dig = null //Now clear it
			tunnel_delay = 1
			spawn(2400)
				src << "\blue Your claws are ready to dig a new tunnel."
				src.tunnel_delay = 0
		playsound(loc, 'sound/weapons/pierce.ogg', 30, 1)
	else
		src << "You were interrupted, and your tunnel collapses, you irresponsible monster you."
		src.storedplasma += 100 //refund half their plasma
	return

/mob/living/carbon/Xenomorph/proc/claw_toggle()
	set name = "Permit/Disallow Slashing"
	set desc = "Allows you to permit the hive to harm."
	set category = "Alien"

	if(pslash_delay)
		src << "You must wait a bit before you can toggle this again."
		return

	spawn(300)
		pslash_delay = 0

	pslash_delay = 1


	var/choice = input("Choose which level of slashing hosts to permit to your hive.","Harming") as null|anything in list("Allow","Restricted - less damage","Forbid")

	if(choice == "Allow")
		src << "You allow slashing."
		xeno_message("The Queen has <b>permitted</b> the harming of hosts! Go hog wild!",3)
		slashing_allowed = 1
	else if(choice == "Restricted - less damage")
		src << "You restrict slashing."
		xeno_message("The Queen has <b>restricted</b> the harming of hosts. You will do less damage when slashing.",3)
		slashing_allowed = 2
	else if(choice == "Forbid")
		src << "You forbid slashing entirely."
		xeno_message("The Queen has <b>forbidden</b> the harming of hosts. You can no longer slash your enemies.",3)
		slashing_allowed = 0
	else
		return

/mob/living/carbon/Xenomorph/verb/hive_status()
	set name = "Hive Status"
	set desc = "Check the status of your current hive."
	set category = "Alien"

	var/dat = "<html><head><title>Hive Status</title></head><body>"

	if(ticker && ticker.mode.aliens.len)
		dat += "<table cellspacing=4>"
		for(var/datum/mind/L in ticker.mode.aliens)
			var/mob/M = L.current
			if(M && istype(M,/mob/living/carbon/Xenomorph))
				dat += "<tr><td>[M.name] [M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td></tr>"
		dat += "</table></body>"
	usr << browse(dat, "window=roundstatus;size=400x300")
	return

/mob/living/carbon/Xenomorph/proc/tail_attack()
	set name = "Ready Tail Attack (20)"
	set desc = "Wind up your tail for a devastating stab on your next harm attack. Drains plasma when active."
	set category = "Alien"

	if(!check_state()) return //Nope

	if(!readying_tail)
		if(!check_plasma(20)) return
		visible_message("\blue \The [src]'s tail starts to coil like a spring..","\blue You begin to ready your tail for a vicious attack. This will drain plasma to keep active.")
		readying_tail = 1
	else
		src << "\blue You relax your tail. You are no longer readying a tail attack."
		readying_tail = 0
	return

/*/mob/living/carbon/Xenomorph/proc/bestial_roar()
	set name = "Bestial Roar"
	set desc = "Shake the ground with a roar from the underworld."
	set category = "Alien"

	for(var/mob/M in view(50))
		if(M.client)
		// playsound(var/atom/source, soundin, vol as num, vary, extrarange as num, falloff, var/is_global)
			playsound(M, 'sound/voice/alien_bestial_roar.ogg', 100, 0, 100, -1) //About as loud as it can possibly get
			shake_camera(M, 50, 1) // 50 deciseconds, the exact length of the sound
			M << "<span class='warning'>An ear-splitting guttural roar shakes the ground beneath your feet!</span>"
*/


/mob/living/carbon/Xenomorph/proc/stomp()
	set name = "Stomp (50)"
	set desc = "Strike the earth!"
	set category = "Alien"

	if(!check_state()) return

	if(has_screeched) //Sure, let's use this.
		src << "\red You are not yet prepared to shake the ground."
		return

	if(!check_plasma(100))
		return

	has_screeched = 1
	spawn(200) //20 seconds
		has_screeched = 0
		src << "You feel ready to shake the earth again."

	playsound(loc, 'sound/effects/bang.ogg', 50, 0, 100, -1)
	visible_message("\red <B> \The [src] smashes the ground!</B>","\red <b>You smash the ground!</b>")
	create_shriekwave() //Adds the visual effect. Wom wom wom
	explosion(src.loc,-1,-1,1,0)
	for (var/mob/living/carbon/human/M in oview())
		var/dist = get_dist(src,M)
		if(M && M.client && dist < 7)
			shake_camera(M, 5, 1)
		if (dist < 5 && !M.lying && M.stat)
			M << "<span class='warning'><B>The earth moves beneath your feet!</span></b>"
			M.Weaken(rand(2,3))
	return

/mob/living/carbon/Xenomorph/proc/ready_charge()
	set name = "Toggle Charging"
	set desc = "Stop auto-charging when you move."
	set category = "Alien"

	if(!check_state()) return //Nope

	if(!istype(src,/mob/living/carbon/Xenomorph/Crusher)) //Logic. Other mobs don't have the verb
		return

	if(!src:is_charging) //We're using tail because they don't have the verb anyway (crushers)
		src << "\blue You will now charge when moving."
		src:is_charging = 1
	else
		src << "\blue You will no longer charge when moving."
		src:is_charging = 0
	return
