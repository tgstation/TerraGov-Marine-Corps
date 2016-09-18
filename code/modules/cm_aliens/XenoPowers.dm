//Xenomorph Powers - Colonial Marines - Apophis775 - Last Edit: 11JUN16

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

	src << "You will now spit [spit_type ? "stunning neurotoxin instead of acid.":"corrosive acid globs."]"
	// Down from +20 to -10.  This should be sort of the base alien "ranged" attack.  Also, Praes/Spitters get lolshit for melee damage
	spit_delay = spit_type ? spit_delay - 10 : spit_delay + 10 //This will make sure aliens don't slow down when switching spits.
	switch(type)
		if(/mob/living/carbon/Xenomorph/Praetorian) ammo = spit_type ? ammo_list[/datum/ammo/xeno/toxin/heavy ]  : ammo_list[/datum/ammo/xeno/acid/heavy]
		if(/mob/living/carbon/Xenomorph/Spitter) ammo = spit_type ? ammo_list[/datum/ammo/xeno/toxin/medium ] : ammo_list[/datum/ammo/xeno/acid/medium]
		else ammo = spit_type ? ammo_list[/datum/ammo/xeno/toxin] : ammo_list[/datum/ammo/xeno/acid]
	spit_type = !spit_type
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
		src << "There's a pod here already!"
		return

	if(check_plasma(75))
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>\The [src] regurgitates a pulsating node and plants it on the ground!</B>"), 1)
		new /obj/effect/alien/weeds/node(loc)
		new /obj/effect/alien/weeds(loc)
		playsound(loc, 'sound/effects/splat.ogg', 30, 1) //splat!
	return

/mob/living/carbon/Xenomorph/proc/Pounce(var/atom/T)

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
		usedPounce = 30 //about 12 seconds
		flags_pass = PASSTABLE
		if(readying_tail) readying_tail = 0
		src.throw_at(T, 6, 2, src) //victim, distance, speed
		spawn(6)
			if(!hardcore)
				flags_pass = initial(flags_pass)//Reset the passtable.
			else
				flags_pass = 0 //Reset the passtable.

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
				M.forceMove(loc)
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

/mob/living/carbon/Xenomorph/proc/transfer_plasma(mob/living/carbon/Xenomorph/M as mob in oview(2))
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

/mob/living/carbon/Xenomorph/proc/build_resin() // -- TLE <---There's a name I haven't heard in a while. ~N
	set name = "Secrete Resin (75)"
	set desc = "Secrete tough malleable resin."
	set category = "Alien"

	if(!check_state())	return

	var/choice = input("Choose what you wish to shape.","Resin building") as null|anything in list("resin door","resin wall","resin membrane","resin nest", "sticky resin", "cancel")

	if(!choice || choice == "cancel")
		return

	var/turf/current_turf = get_turf(src)
	if(!current_turf || !istype(current_turf))
		return

	if(!is_weedable(current_turf))
		src << "Bad place for a garden!"
		return

	var/obj/effect/alien/weeds/alien_weeds = locate() in current_turf

	if(!alien_weeds)
		src << "You can only shape on weeds. Find some resin before you start building!"
		return

	if(!check_alien_construction(current_turf))
		return

	if(!check_plasma(75))
		return

	src << "\green You shape a [choice]."
	for(var/mob/O in viewers(src, null))
		if(O != src)
			O.show_message(text("\red <B>[src] vomits up a thick substance and begins to shape it!</B>"), 1)

	switch(choice)
		if("resin door")
			new /obj/structure/mineral_door/resin(current_turf)
		if("resin wall")
			new /obj/effect/alien/resin/wall(current_turf)
		if("resin membrane")
			new /obj/effect/alien/resin/membrane(current_turf)
		if("resin nest")
			new /obj/structure/stool/bed/nest(current_turf)
		if("sticky resin")
			new /obj/effect/alien/resin/sticky(current_turf)
	return

//Note: All the neurotoxin projectile items are stored in XenoProcs.dm
/mob/living/carbon/Xenomorph/proc/neurotoxin(var/atom/T)
	set name = "Spit Neurotoxin (50/100)"
	set desc = "Spits neurotoxin at someone, paralyzing them for a short time, or globs of acid which burn in an area."
	set category = "Alien"

	if(!check_state())	return

	if(!isturf(loc))
		src << "You can't spit from here!"
		return

	if(has_spat + spit_delay >= world.time)
		src << "You must wait for your neurotoxin glands to refill."
		return

	if(!T)
		var/list/victims = list()
		for(var/mob/living/carbon/human/C in oview(7))
			if(!C.stat)
				victims += C
		victims += "Cancel"
		T = input(src, "Who should you spit towards?") as null|anything in victims

	if(!client || !loc || T == "Cancel") return

	if(T)
		if(!check_plasma(spit_type?100:50)) return

		var/turf/current_turf = get_turf(src)

		if(!current_turf) return

		visible_message("<span class='danger'>\The [src] spits at [T]!</span>","<span class='danger'>You spit at [T]!</span>" )
		var/sound_to_play = pick(1,2) == 1 ? 'sound/voice/alien_spitacid.ogg' : 'sound/voice/alien_spitacid2.ogg'
		playsound(src.loc, sound_to_play, 60, 1)

		var/obj/item/projectile/A = rnew(/obj/item/projectile, current_turf)
		A.generate_bullet(ammo)
		A.permutated += src
		A.def_zone = get_organ_target()
		A.fire_at(T,src,null,ammo.max_range,ammo.shell_speed)
		has_spat = world.time
		cooldown_notification(spit_delay,"spit")
	else src << "You cannot spit at nothing!"

/mob/living/carbon/Xenomorph/proc/cooldown_notification(cooldown, message)
	set waitfor = 0
	sleep(cooldown)
	switch(message)
		if("spit") src << "You feel your glands swell with ichor. You can spit again."

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
	dat += "Total Alive Sisters: [ticker.mode.xenomorphs.len]"

	if(ticker && ticker.mode.xenomorphs.len)
		dat += "<table cellspacing=4>"
		var/mob/living/carbon/Xenomorph/X
		for(var/datum/mind/L in ticker.mode.xenomorphs)
			X = L.current
			if(istype(X)) dat += "<tr><td>[X.name] [X.client ? "" : " <i>(logged out)</i>"][X.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td></tr>"
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
		var/choice = alert(src,"Pheromones provide a buff to all visible Xenos at the cost of some stored plasma every second.\nFrenzy - Increased run speed\nGuard - Reduced incoming damage\nRecovery - Increased plasma and health regeneration","Emit Pheromones", "frenzy", "guard", "recovery")
		if (choice != "cancel")
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

	if(!istype(victim,/mob/living/carbon/human)) return // Runtime fix for attempting to secure Monkeys, which don't need to be cuffed anyway

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
			if(!victim.handcuffed)
				victim.handcuffed = new /obj/item/weapon/handcuffs/xeno(victim)
				victim.xenoCuffed = 1
				src.visible_message("\red <B>[src] finishes securing [victim]'s arms.</b>","\red <B>You finish securing [victim]'s arms!</b>")
			else
				src << "Looks like someone secured them before you!"
				return
			victim.update_icons()
			last_special = world.time + 50

		return

	src << "Nobody like that around here."
	return
