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
	set name = "Toggle Spit Type (20)"
	set desc = "Toggles between a lighter, single-target stun spit or a heavier area acid that burns. The heavy version requires more plasma."
	set category = "Alien"

	if(!check_plasma(20)) return

	if(!spit_type)
		src << "You will now spit corrosive acid globs."
		spit_type = 1
		ammo.icon_state = "neurotoxin"
		ammo.damage = 10
		ammo.stun = 0
		ammo.weaken = 0
		ammo.shell_speed = 1
		spit_delay = (initial(spit_delay) + 20) //Takes longer to recharge.
		if(istype(src,/mob/living/carbon/Xenomorph/Praetorian))
			//Bigger and badder!
			ammo.damage += 15
		else if(istype(src,/mob/living/carbon/Xenomorph/Spitter))
			ammo.damage += 5
			ammo.shell_speed = 2 //Super fast!
	else
		src << "You will now spit stunning neurotoxin instead of acid."
		spit_type = 0
		ammo.icon_state = "toxin"
		ammo.damage = 0
		ammo.stun = 1
		ammo.weaken = 2
		ammo.shell_speed = 1
		spit_delay = initial(spit_delay)
		if(istype(src,/mob/living/carbon/Xenomorph/Praetorian))
			//Bigger and badder!
			ammo.stun += 2
			ammo.weaken += 2
		else if(istype(src,/mob/living/carbon/Xenomorph/Spitter))
			ammo.stun += 1
			ammo.weaken += 1
			ammo.shell_speed = 2 //Super fast!
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

	if(T.slayer > 0)
		src << "It requires a solid ground. Dig it up!"
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
		spawn(6)
			pass_flags = initial(pass_flags)//Reset the passtable.
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

	if (get_dist(src,M) >= 3)//Double Check
		src << "\green You need to be closer."
		return

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

	if(!ammo) return

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

		var/turf/Turf = get_turf(src)
		var/turf/Target_Turf = get_turf(T)

		if(!Target_Turf || !Turf)
			return

		if(Turf == Target_Turf)
			src << "Too close!"
			return

		visible_message("\red <B>\The [src] spits at [T]!</B>","\red <b> You spit at [T]!</B>" )

		var/obj/item/projectile/A = new(Turf)
		A.permutated.Add(src)
		A.def_zone = get_organ_target()
		A.ammo = ammo //This always must be set.
		A.icon = A.ammo.icon
		A.icon_state = A.ammo.icon_state
		A.damage = A.ammo.damage
		A.damage_type = A.ammo.damage_type

		spawn()
			A.fire_at(T,src,null,ammo.max_range,ammo.shell_speed) //Ptui!
//		src.next_move += 2 //Lags you out a bit, spitting.
		has_spat = 1
		spawn(spit_delay)
			has_spat = 0
			src << "You feel your glands swell with ichor. You can spit again."
	else
		src << "You cannot spit at nothing!"
	return

//Corrosive acid is consolidated -- it checks for specific castes for strength now, but works identically to each other.
//The acid items are stored in XenoProcs.
/mob/living/carbon/Xenomorph/proc/corrosive_acid(O as obj|turf in oview(1)) //If they right click to corrode, an error will flash if its an invalid target./N
	set name = "Corrosive Acid (variable)"
	set desc = "Drench an object in acid. Drones/Sentinel cost 75, Boilers 200, everything else 100."
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
		if(istype(T,/turf/unsimulated/floor) || istype(T, /turf/simulated/shuttle) || istype(T, /turf/simulated/floor) || istype(T,/turf/simulated/mineral) || istype(T,/turf/unsimulated/wall/gm) || istype(T,/turf/simulated/wall/r_wall/unmeltable))
			src << "\green You cannot dissolve this."
			return
		if(istype(T, /turf/simulated/wall/r_wall) && !istype(src,/mob/living/carbon/Xenomorph/Boiler))
			src << "\green This wall is too tough to be melted by your weak acid."
			return
	else
		src << "\green You cannot dissolve this object."
		return

	if(isnull(O) || isnull(get_turf(O))) //Some logic.
		return

	if(istype(src,/mob/living/carbon/Xenomorph/Sentinel) || istype(src,/mob/living/carbon/Xenomorph/Drone) ) //weak level
		if(!check_plasma(75)) return
		var/obj/effect/xenomorph/acid/weak/A = new (get_turf(O), O)
		A.layer = O:layer + 0.6

	else if(istype(src,/mob/living/carbon/Xenomorph/Boiler)) //strong level
		if(!check_plasma(200)) return
		var/obj/effect/xenomorph/acid/strong/A = new (get_turf(O), O)
		A.layer = O:layer + 0.6

	else
		if(!check_plasma(100)) return
		var/obj/effect/xenomorph/acid/A = new (get_turf(O), O)
		A.layer = O:layer + 0.6

	if(!isturf(O))
		msg_admin_attack("[src.name] ([src.ckey]) spat acid on [O].")
	visible_message("\green <B>[src] vomits globs of vile stuff all over [O]. It begins to sizzle and melt under the bubbling mess of acid!</B>")
	return


/mob/living/carbon/Xenomorph/proc/claw_toggle()
	set name = "Permit/Disallow Slashing"
	set desc = "Allows you to permit the hive to harm."
	set category = "Alien"

	if(stat)
		src << "You can't do that now."
		return

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

/mob/living/carbon/Xenomorph/proc/toggle_auras()
	set name = "Emit Pheromones (30)"
	set desc = "Emit pheromones in the area around you. Nearby xenomorphs will be enhanced in some way. This drains plasma to keep active."
	set category = "Alien"

	if(!check_state()) return

	if(isnull(current_aura))
		if(!check_plasma(30))
			return
		var/choice = alert(src,"Which pheromone would you like to emit?","Auras", "frenzy", "guard","recovery")
		current_aura = choice
		visible_message("<B>[src] begins to emit strange-smelling pheromones.</b>","<b>You begin to emit '[choice]' pheromones.</b>")
		return
	else
		current_aura = null
		src << "<b>You stop emitting pheromones.</b>"
		return

/mob/living/carbon/Xenomorph/proc/secure_host(mob/living/carbon/human/victim as mob in view(2))
	set name = "Secure Host (50)"
	set desc = "Spin some resin to further secure a host within the nest."
	set category = "Alien"

	if(last_special > world.time) return

	if(!check_state()) return

	if(!victim)
		var/list/victims = list()
		for(var/mob/living/carbon/human/C in view(2))
			if(C.lying && (!C.handcuffed || !C.legcuffed))
				victims += C

		victim = input(src, "Who to secure?") as null|anything in victims

	if(victim && get_dist(src,victim) <= 2)
		if(!check_plasma(50)) return
		if(!victim.lying)
			src << "Your victim has to be lying down."
			return
		if(!victim.buckled || !istype(victim.buckled,/obj/structure/stool/bed/nest))
			src << "Your victim must be nested."
			return
		if(victim.handcuffed && victim.legcuffed)
			src << "They're already secured."
			return

		src.visible_message("\red [src] begins securing [victim] with resin!","\red You begin securing [victim] with resin.. Hold still!")
		if(do_after(src,40))
			src.visible_message("\red [src] continues securing [victim] with resin..","\red You continue securing [victim] with resin.. almost there.")
		if(do_after(src,80))
			if(victim.handcuffed && !victim.legcuffed)
				victim.legcuffed = new /obj/item/weapon/legcuffs/xeno(victim)
				src.visible_message("\red <B>[src] finishes binding [victim]'s legs.</b>","\red <B>You finish binding [victim]'s legs!</b>")
			else if(!victim.handcuffed)
				victim.handcuffed = new /obj/item/weapon/handcuffs/xeno(victim)
				src.visible_message("\red <B>[src] finishes securing [victim]'s arms.</b>","\red <B>You finish securing [victim]'s arms!</b>")
			else
				src << "Looks like someone secured them before you!"
				return
			victim.update_icons()
			last_special = world.time + 50

		return

	src << "Nobody like that around here."
	return