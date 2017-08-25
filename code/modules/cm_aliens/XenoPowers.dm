//Xenomorph Powers - Colonial Marines - Apophis775 - Last Edit: 11JUN16

//Their verbs are all actually procs, so we don't need to add them like 4 times copypaste for different species
//Just add the name to the caste's inherent_verbs() list

/mob/living/carbon/Xenomorph/verb/middle_mousetoggle()
	set name = "Toggle Middle Clicking"
	set desc = "Toggles middle mouse button for hugger throwing, neuro spit, and other abilities."
	set category = "Alien"

	if(!middle_mouse_toggle)
		src << "<span class='notice'>You turn middle mouse clicking ON for certain xeno abilities.</span>"
		middle_mouse_toggle = 1
	else
		src << "<span class='notice'>You turn middle mouse clicking OFF. Middle mouse button will instead change active hands.</span>"
		middle_mouse_toggle = 0

/mob/living/carbon/Xenomorph/verb/shift_mousetoggle()
	set name = "Toggle Shift Clicking"
	set desc = "Toggles shift + mouse button for hugger throwing, neuro spit, and other abilities."
	set category = "Alien"

	if(!shift_mouse_toggle)
		src << "<span class='notice'>You turn shift clicking ON for certain xeno abilities.</span>"
		shift_mouse_toggle = 1
	else
		src << "<span class='notice'>You turn shift clicking OFF. Shift click will instead examine.</span>"
		shift_mouse_toggle = 0

/mob/living/carbon/Xenomorph/proc/shift_spits()
	set name = "Toggle Spit Type (20)"
	set desc = "Toggles between a lighter, single-target stun spit or a heavier area acid that burns. The heavy version requires more plasma."
	set category = "Alien"

	if(!check_plasma(20))
		return

	src << "<span class='notice'>You will now spit [spit_type ? "stunning neurotoxin instead of acid.":"corrosive acid globs."]</span>"
	// Down from +20 to -10.  This should be sort of the base alien "ranged" attack.  Also, Praes/Spitters get lolshit for melee damage
	spit_delay = spit_type ? spit_delay - 10 : spit_delay + 10 //This will make sure aliens don't slow down when switching spits.
	switch(type)
		if(/mob/living/carbon/Xenomorph/Praetorian)
			ammo = spit_type ? ammo_list[/datum/ammo/xeno/toxin/heavy ]  : ammo_list[/datum/ammo/xeno/acid/heavy]
		if(/mob/living/carbon/Xenomorph/Spitter)
			ammo = spit_type ? ammo_list[/datum/ammo/xeno/toxin/medium ] : ammo_list[/datum/ammo/xeno/acid/medium]
		else
			ammo = spit_type ? ammo_list[/datum/ammo/xeno/toxin] : ammo_list[/datum/ammo/xeno/acid]
	spit_type = !spit_type

/mob/living/carbon/Xenomorph/proc/plant()
	set name = "Plant Weeds (75)"
	set desc = "Plants some alien weeds"
	set category = "Alien"

	if(!check_state()) return

	var/turf/T = loc

	if(!istype(T))
		src << "<span class='warning'>You can't do that here.</span>"
		return

	if(T.slayer > 0)
		src << "<span class='warning'>It requires a solid ground. Dig it up!</span>"
		return

	if(!is_weedable(T))
		src << "<span class='warning'>Bad place for a garden!</span>"
		return

	if(locate(/obj/effect/alien/weeds/node) in T)
		src << "<span class='warning'>There's a pod here already!</span>"
		return

	if(check_plasma(75))
		visible_message("<span class='xenonotice'>\The [src] regurgitates a pulsating node and plants it on the ground!</span>", \
		"<span class='xenonotice'>You regurgitate a pulsating node and plant it on the ground!</span>")
		new /obj/effect/alien/weeds/node(loc, src)
		playsound(loc, 'sound/effects/splat.ogg', 15, 1) //Splat!

/mob/living/carbon/Xenomorph/proc/Pounce(var/atom/T)

	if(!check_state())
		return

	if(usedPounce)
		src << "<span class='warning'>You must wait before pouncing.</span>"
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
		visible_message("<span class='xenowarning'>\The [src] pounces at \the [T]!</span>", \
		"<span class='xenowarning'>You pounce at \the [T]!</span>")
		usedPounce = 30 //About 12 seconds
		flags_pass = PASSTABLE
		if(readying_tail)
			readying_tail = 0
		throw_at(T, 6, 2, src) //Victim, distance, speed
		spawn(6)
			if(!hardcore)
				flags_pass = initial(flags_pass) //Reset the passtable.
			else
				flags_pass = 0 //Reset the passtable.

		spawn(usedPounce)
			usedPounce = 0
			src << "<span class='notice'>You get ready to pounce again.</span>"
		return 1
	else
		storedplasma += 5 //Since we already stole 5
		src << "<span class='notice'>You cannot pounce at nothing!</span>"

/mob/living/carbon/Xenomorph/proc/vent_crawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Alien"
	if(!check_state())
		return
	var/pipe = start_ventcrawl()
	if(pipe)
		handle_ventcrawl(pipe)

/mob/living/carbon/Xenomorph/proc/regurgitate()
	set name = "Regurgitate"
	set desc = "Empties the contents of your stomach"
	set category = "Alien"

	if(!check_state())
		return

	if(!isturf(loc))
		src << "<span class='warning'>You cannot regurgitate here.</span>"
		return

	if(stomach_contents.len)
		for(var/mob/M in src)
			if(M in stomach_contents)
				stomach_contents.Remove(M)
				M.forceMove(loc)
		visible_message("<span class='xenowarning'>\The [src] hurls out the contents of their stomach!</span>", \
		"<span class='xenowarning'>You hurl out the contents of your stomach!</span>")
	else
		src << "<span class='warning'>There's nothing in your belly that needs regurgitating.</span>"

/mob/living/carbon/Xenomorph/proc/psychic_whisper(mob/M as mob in oview())
	set name = "Psychic Whisper"
	set desc = "Whisper silently to someone over a distance."
	set category = "Alien"

	if(!check_state())
		return

	var/msg = sanitize(input("Message:", "Psychic Whisper") as text|null)
	if(msg)
		log_say("PsychicWhisper: [key_name(src)]->[M.key] : [msg]")
		M << "<span class='alien'>You hear a strange, alien voice in your head. \italic \"[msg]\"</span>"
		src << "<span class='xenonotice'>You said: \"[msg]\" to [M]</span>"

/mob/living/carbon/Xenomorph/proc/transfer_plasma(mob/living/carbon/Xenomorph/M in oview(2))
	set name = "Transfer Plasma"
	set desc = "Transfer Plasma to another alien"
	set category = "Alien"

	if(!check_state())
		return

	if(!M || !istype(M))
		return

	if(get_dist(src, M) >= 3)
		src << "<span class='warning'>You need to be closer.</span>"
		return

	var/amount = input("Amount:", "Transfer Plasma to [M]") as num

	if(get_dist(src, M) >= 3)//Double Check
		src << "<span class='warning'>You need to be closer.</span>"
		return

	if(amount)
		amount = abs(round(amount))
		if(storedplasma < amount)
			amount = storedplasma //Just use all of it
		storedplasma -= amount
		M.storedplasma += amount
		if(M.storedplasma > M.maxplasma)
			M.storedplasma = M.maxplasma
		M << "<span class='xenowarning'>\The [src] has transfered [amount] plasma to you. You now have [M.storedplasma].</span>"
		src << "<span class='xenowarning'>You have transferred [amount] plasma to \the [M]. You now have [storedplasma].</span>"

/mob/living/carbon/Xenomorph/proc/build_resin() // -- TLE <---There's a name I haven't heard in a while. ~N
	set name = "Secrete Resin (75)"
	set desc = "Secrete tough malleable resin."
	set category = "Alien"

	if(!check_state())
		return

	var/turf/T = loc

	if(!istype(T))
		src << "<span class='warning'>You can't do that here.</span>"
		return

	var/choice = input("Choose what you wish to shape.","Resin building") as null|anything in list("resin door", "resin wall", "resin membrane", "resin nest", "sticky resin", "cancel")

	if(!choice || choice == "cancel")
		return

	var/turf/current_turf = loc
	if(!istype(current_turf))
		src << "<span class='warning'>You can't do that here.</span>"
		return

	if(!is_weedable(current_turf) || istype(get_area(src.loc),/area/shuttle/drop1/lz1 || istype(get_area(src.loc),/area/shuttle/drop2/lz2)) || istype(get_area(src.loc),/area/sulaco/hangar)) //Bandaid for atmospherics bug when Xenos build around the shuttles
		src << "<span class='warning'>You sense this is not a suitable area for expanding the hive.</span>"
		return

	var/obj/effect/alien/weeds/alien_weeds = locate() in current_turf

	if(!alien_weeds)
		src << "<span class='warning'>You can only shape on weeds. Find some resin before you start building!</span>"
		return

	if(!check_alien_construction(current_turf))
		return

	if(!check_plasma(75))
		return

	visible_message("<span class='xenonotice'>\The [src] regurgitates a thick substance and shapes it into \a [choice]!</span>", \
	"<span class='xenonotice'>You regurgitate some resin and shape it into \a [choice].</span>")
	playsound(loc, 'sound/effects/splat.ogg', 15, 1) //Splat!

	switch(choice)
		if("resin door")
			if (caste == "Hivelord")
				new /obj/structure/mineral_door/resin/thick(current_turf)
			else
				new /obj/structure/mineral_door/resin(current_turf)
		if("resin wall")
			if (caste == "Hivelord")
				new /turf/simulated/wall/resin/thick(current_turf)
			else
				new /turf/simulated/wall/resin(current_turf)
		if("resin membrane")
			if (caste == "Hivelord")
				new /turf/simulated/wall/resin/membrane/thick(current_turf)
			else
				new /turf/simulated/wall/resin/membrane(current_turf)
		if("resin nest")
			new /obj/structure/stool/bed/nest(current_turf)
		if("sticky resin")
			new /obj/effect/alien/resin/sticky(current_turf)

//Note: All the neurotoxin projectile items are stored in XenoProcs.dm
/mob/living/carbon/Xenomorph/proc/neurotoxin(var/atom/T)
	set name = "Spit Neurotoxin (50/100)"
	set desc = "Spits neurotoxin at someone, paralyzing them for a short time, or globs of acid which burn in an area."
	set category = "Alien"

	if(!check_state())
		return

	if(!isturf(loc))
		src << "<span class='warning'>You can't spit from here!</span>"
		return

	if(has_spat + spit_delay >= world.time)
		src << "<span class='warning'>You must wait for your neurotoxin glands to refill.</span>"
		return

	if(!T)
		var/list/victims = list()
		for(var/mob/living/carbon/human/C in oview(7))
			if(!C.stat)
				victims += C
		victims += "Cancel"
		T = input(src, "Who should you spit towards?") as null|anything in victims

	if(!client || !loc || T == "Cancel")
		return

	if(T)
		if(!check_plasma(spit_type ? 100:50))
			return

		var/turf/current_turf = get_turf(src)

		if(!current_turf)
			return

		visible_message("<span class='xenowarning'>\The [src] spits at \the [T]!</span>", \
		"<span class='xenowarning'>You spit at \the [T]!</span>" )
		var/sound_to_play = pick(1, 2) == 1 ? 'sound/voice/alien_spitacid.ogg' : 'sound/voice/alien_spitacid2.ogg'
		playsound(src.loc, sound_to_play, 25, 1)

		var/obj/item/projectile/A = rnew(/obj/item/projectile, current_turf)
		A.generate_bullet(ammo)
		A.permutated += src
		A.def_zone = get_organ_target()
		A.fire_at(T, src, null, ammo.max_range, ammo.shell_speed)
		has_spat = world.time
		cooldown_notification(spit_delay, "spit")
	else
		src << "<span class='warning'>You have nothing to spit at!</span>"

/mob/living/carbon/Xenomorph/proc/cooldown_notification(cooldown, message)
	set waitfor = 0
	sleep(cooldown)
	switch(message)
		if("spit")
			src << "<span class='notice'>You feel your glands swell with ichor. You can spit again.</span>"

//Corrosive acid is consolidated -- it checks for specific castes for strength now, but works identically to each other.
//The acid items are stored in XenoProcs.
/mob/living/carbon/Xenomorph/proc/corrosive_acid(var/atom/O as obj|turf in oview(1)) //If they right click to corrode, an error will flash if its an invalid target./N
	set name = "Corrosive Acid (variable)"
	set desc = "Drench an object in acid. Drones/Sentinel cost 75, Boilers 200, everything else 100."
	set category = "Alien"

	if(!check_state())
		return

	if(!O in oview(1))
		src << "<span class='warning'>\The [O] is too far away.</span>"
		return

	var/wait_time = 10

	//OBJ CHECK
	if(isobj(O))
		var/obj/I = O
		if(I.unacidable || istype(I, /obj/machinery/computer) || istype(I, /obj/effect)) //So the aliens don't destroy energy fields/singularies/other aliens/etc with their acid.
			src << "<span class='warning'>You cannot dissolve \the [I].</span>" // ^^ Note for obj/effect.. this might check for unwanted stuff. Oh well
			return

	//TURF CHECK
	else if(istype(O, /turf/simulated) || istype(O, /turf/unsimulated))
		var/turf/T = O
		//R WALL
		if(istype(T, /turf/unsimulated/floor) || istype(T, /turf/simulated/shuttle) || istype(T, /turf/simulated/floor) || istype(T,/turf/simulated/mineral) || istype(T,/turf/unsimulated/wall/gm) || istype(T,/turf/simulated/wall/r_wall/unmeltable) || istype(T,/turf/simulated/wall/sulaco/unmeltable) || istype(T, /turf/simulated/wall/almayer/outer) || istype(T, /turf/simulated/wall/almayer/research))
			src << "<span class='warning'>You cannot dissolve \the [T].</span>"
			return
		if(istype(T, /turf/simulated/wall/r_wall) && !istype(src,/mob/living/carbon/Xenomorph/Boiler))
			src << "<span class='warning'>This [T.name] is too tough to be melted by your weak acid.</span>"
			return

		if (istype(T, /turf/simulated/wall/r_wall))
			src << "<span class='xenowarning'>You begin generating enough acid to melt through \the [T].</span>"
			wait_time = 100
		else if (istype(T, /turf/simulated/wall) || istype(T, /turf/unsimulated/wall))
			src << "<span class='xenowarning'>You begin generating enough acid to melt through \the [T].</span>"
			wait_time = 50

	else
		src << "<span class='warning'>You cannot dissolve \the [O].</span>"
		return

	if(!do_after(src, wait_time, TRUE, 5, BUSY_ICON_CLOCK))
		return

	if(!check_state())
		return


	if(isnull(O) || isnull(get_turf(O))) //Some logic.
		return

	if(isXenoSentinel(src) || isXenoDrone(src)) //Weak level
		if(!check_plasma(75))
			return
		var/obj/effect/xenomorph/acid/weak/A = new(get_turf(O), O)
		A.icon_state = "acid_weak[isturf(O) ? "_wall":""]"
		if(istype(O, /obj/structure) || istype(O, /obj/machinery)) //Always appears above machinery
			A.layer = O.layer + 0.1
		else //If not, appear on the floor (turf layer is 2, vents are 2.4)
			A.layer = 2.41

	else if(isXenoBoiler(src)) //Strong level
		if(!check_plasma(200))
			return
		var/obj/effect/xenomorph/acid/strong/A = new(get_turf(O), O)
		A.icon_state = "acid_strong[isturf(O) ? "_wall":""]"
		if(istype(O, /obj/structure) || istype(O, /obj/machinery)) //Always appears above machinery
			A.layer = O.layer + 0.1
		else //If not, appear on the floor (turf layer is 2, vents are 2.4)
			A.layer = 2.41

	else
		if(!check_plasma(100))
			return
		var/obj/effect/xenomorph/acid/A = new(get_turf(O), O)
		A.icon_state = "acid_normal[isturf(O) ? "_wall":""]"
		if(istype(O, /obj/structure) || istype(O, /obj/machinery)) //Always appears above machinery
			A.layer = O.layer + 0.1
		else //If not, appear on the floor (turf layer is 2, vents are 2.4)
			A.layer = 2.41

	if(!isturf(O))
		msg_admin_attack("[src.name] ([src.ckey]) spat acid on [O].")
		attack_log += text("\[[time_stamp()]\] <font color='green'>Spat acid on [O]</font>")
	visible_message("<span class='xenowarning'>\The [src] vomits globs of vile stuff all over \the [O]. It begins to sizzle and melt under the bubbling mess of acid!</span>", \
	"<span class='xenowarning'>You vomit globs of vile stuff all over \the [O]. It begins to sizzle and melt under the bubbling mess of acid!</span>")

/mob/living/carbon/Xenomorph/proc/claw_toggle()
	set name = "Permit/Disallow Slashing"
	set desc = "Allows you to permit the hive to harm."
	set category = "Alien"

	if(stat)
		src << "<span class='warning'>You can't do that now.</span>"
		return

	if(pslash_delay)
		src << "<span class='warning'>You must wait a bit before you can toggle this again.</span>"
		return

	spawn(300)
		pslash_delay = 0

	pslash_delay = 1


	var/choice = input("Choose which level of slashing hosts to permit to your hive.","Harming") as null|anything in list("Allowed", "Restricted - Less Damage", "Forbidden")

	if(choice == "Allowed")
		src << "<span class='xenonotice'>You allow slashing.</span>"
		xeno_message("The Queen has <b>permitted</b> the harming of hosts! Go hog wild!", 3)
		slashing_allowed = 1
	else if(choice == "Restricted - Less Damage")
		src << "<span class='xenonotice'>You restrict slashing.</span>"
		xeno_message("The Queen has <b>restricted</b> the harming of hosts. You will only slash when hurt.", 3)
		slashing_allowed = 2
	else if(choice == "Forbidden")
		src << "<span class='xenonotice'>You forbid slashing entirely.</span>"
		xeno_message("The Queen has <b>forbidden</b> the harming of hosts. You can no longer slash your enemies.", 3)
		slashing_allowed = 0

/mob/living/carbon/Xenomorph/verb/hive_status()
	set name = "Hive Status"
	set desc = "Check the status of your current hive."
	set category = "Alien"

	var/dat = "<html><head><title>Hive Status</title></head><body>"

	var/count = 0
	var/queen_list = ""
	//var/exotic_list = ""
	//var/exotic_count = 0
	var/boiler_list = ""
	var/boiler_count = 0
	var/crusher_list = ""
	var/crusher_count = 0
	var/praetorian_list = ""
	var/praetorian_count = 0
	var/ravager_list = ""
	var/ravager_count = 0
	var/carrier_list = ""
	var/carrier_count = 0
	var/hivelord_list = ""
	var/hivelord_count = 0
	var/hunter_list = ""
	var/hunter_count = 0
	var/spitter_list = ""
	var/spitter_count = 0
	var/drone_list = ""
	var/drone_count = 0
	var/runner_list = ""
	var/runner_count = 0
	var/sentinel_list = ""
	var/sentinel_count = 0
	var/larva_list = ""
	var/larva_count = 0
	for(var/mob/living/carbon/Xenomorph/X in living_mob_list)
		var/area/A = get_area(X)
		if(isXenoQueen(X))
			queen_list += "<tr><td>[X.name] [X.client ? "" : " <i>(SSD)</i>"][X.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : " <b><font color=green>([A ? A.name : null])</b>"]</td></tr>"
		if(isXenoBoiler(X))
			boiler_list += "<tr><td>[X.name] [X.client ? "" : " <i>(SSD)</i>"][X.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : " <b><font color=green>([A ? A.name : null])</b>"]</td></tr>"
			boiler_count++
		if(isXenoCrusher(X))
			crusher_list += "<tr><td>[X.name] [X.client ? "" : " <i>(SSD)</i>"][X.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : " <b><font color=green>([A ? A.name : null])</b>"]</td></tr>"
			crusher_count++
		if(isXenoPraetorian(X))
			praetorian_list += "<tr><td>[X.name] [X.client ? "" : " <i>(SSD)</i>"][X.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : " <b><font color=green>([A ? A.name : null])</b>"]</td></tr>"
			praetorian_count++
		if(isXenoRavager(X))
			ravager_list += "<tr><td>[X.name] [X.client ? "" : " <i>(SSD)</i>"][X.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : " <b><font color=green>([A ? A.name : null])</b>"]</td></tr>"
			ravager_count++
		if(isXenoCarrier(X))
			carrier_list += "<tr><td>[X.name] [X.client ? "" : " <i>(SSD)</i>"][X.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : " <b><font color=green>([A ? A.name : null])</b>"]</td></tr>"
			carrier_count++
		if(isXenoHivelord(X))
			hivelord_list += "<tr><td>[X.name] [X.client ? "" : " <i>(SSD)</i>"][X.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : " <b><font color=green>([A ? A.name : null])</b>"]</td></tr>"
			hivelord_count++
		if(isXenoHunter(X))
			hunter_list += "<tr><td>[X.name] [X.client ? "" : " <i>(SSD)</i>"][X.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : " <b><font color=green>([A ? A.name : null])</b>"]</td></tr>"
			hunter_count++
		if(isXenoSpitter(X))
			spitter_list += "<tr><td>[X.name] [X.client ? "" : " <i>(SSD)</i>"][X.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : " <b><font color=green>([A ? A.name : null])</b>"]</td></tr>"
			spitter_count++
		if(isXenoDrone(X))
			drone_list += "<tr><td>[X.name] [X.client ? "" : " <i>(SSD)</i>"][X.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : " <b><font color=green>([A ? A.name : null])</b>"]</td></tr>"
			drone_count++
		if(isXenoRunner(X))
			runner_list += "<tr><td>[X.name] [X.client ? "" : " <i>(SSD)</i>"][X.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : " <b><font color=green>([A ? A.name : null])</b>"]</td></tr>"
			runner_count++
		if(isXenoSentinel(X))
			sentinel_list += "<tr><td>[X.name] [X.client ? "" : " <i>(SSD)</i>"][X.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : " <b><font color=green>([A ? A.name : null])</b>"]</td></tr>"
			sentinel_count++
		if(isXenoLarva(X))
			larva_list += "<tr><td>[X.name] [X.client ? "" : " <i>(SSD)</i>"][X.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : " <b><font color=green>([A ? A.name : null])</b>"]</td></tr>"
			larva_count++
		//else
			//exotic_list += "<tr><td>[X.name] [X.client ? "" : " <i>(SSD)</i>"][X.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : "<b>(<font color=green>[A ? A.name : null])</b>"]</td></tr>"
			//exotic_count++
		if(!(X.stat & DEAD)) count++ //Dead players shouldn't be on this list, but who knows

	dat += "<b>Total Living Sisters: [count]</b><BR>"
	//if(exotic_count != 0) //Exotic Xenos in the Hive like Predalien or Xenoborg
		//dat += "<b>Ultimate Tier:</b> [exotic_count] Sisters</b><BR>"
	dat += "<b>Tier 3: [boiler_count + crusher_count + praetorian_count + ravager_count] Sisters</b> | Boilers: [boiler_count] | Crushers: [crusher_count] | Praetorians: [praetorian_count] | Ravagers: [ravager_count]<BR>"
	dat += "<b>Tier 2: [carrier_count + hivelord_count + hunter_count + spitter_count] Sisters</b> | Carriers: [carrier_count] | Hivelords: [hivelord_count] | Hunters: [hunter_count] | Spitters: [spitter_count]<BR>"
	dat += "<b>Tier 1: [drone_count + runner_count + sentinel_count] Sisters</b> | Drones: [drone_count] | Runners: [runner_count] | Sentinels: [sentinel_count]<BR>"
	dat += "<b>Larvas: [larva_count] Sisters<BR>"
	dat += "<table cellspacing=4>"
	dat += queen_list + boiler_list + crusher_list + praetorian_list + ravager_list + carrier_list + hivelord_list + hunter_list + spitter_list + drone_list + runner_list + sentinel_list + larva_list
	dat += "</table></body>"
	usr << browse(dat, "window=roundstatus;size=500x500")

/mob/living/carbon/Xenomorph/proc/tail_attack()
	set name = "Ready Tail Attack (20)"
	set desc = "Wind up your tail for a devastating stab on your next harm attack. Drains plasma when active."
	set category = "Alien"

	if(!check_state())
		return

	if(!readying_tail)
		if(!check_plasma(20))
			return
		visible_message("<span class='warning'>\The [src]'s tail starts to coil like a spring.</span>", \
		"<span class='notice'>You begin to ready your tail for a vicious attack. This will drain plasma to keep active.</span>")
		readying_tail = 1
	else
		visible_message("<span class='notice'>\The [src]'s tail relaxes.</span>", \
		"<span class='notice'>You relax your tail. You are no longer readying a tail attack.</span>")
		readying_tail = 0

/mob/living/carbon/Xenomorph/proc/toggle_auras()
	set name = "Emit Pheromones (30)"
	set desc = "Emit pheromones in the area around you. Nearby xenomorphs will be enhanced in some way. This drains plasma to keep active."
	set category = "Alien"

	if(!check_state())
		return

	if(isnull(current_aura))
		var/choice = input(src, "Choose a pheromone") in aura_allowed + "help" + "cancel"
		if(choice == "help")
			src << "<span class='notice'><br>Pheromones provide a buff to all Xenos in range at the cost of some stored plasma every second, as follows:<br><B>Frenzy</B> - Increased run speed and tackle chance.<br><B>Warding</B> - Increased armor, reduced incoming damage and critical bleedout.<br><B>Recovery</B> - Increased plasma and health regeneration.<br></span>"
			return
		if(choice != "cancel")
			if(!isnull(current_aura)) //If they are stacking windows, disable all input
				return
			if(!check_plasma(30))
				return
			current_aura = choice
			visible_message("<span class='xenowarning'>\The [src] begins to emit strange-smelling pheromones.</span>", \
			"<span class='xenowarning'>You begin to emit '[choice]' pheromones.</span>")
			return
	else
		current_aura = null
		visible_message("<span class='xenowarning'>\The [src] stops emitting pheromones.</span>", \
		"<span class='xenowarning'>You stop emitting pheromones.</span>")



/mob/living/carbon/Xenomorph/verb/toggle_xeno_mobhud()
	set name = "Toggle Xeno status HUD"
	set desc = "Toggles the health and plasma hud appearing above Xenomorphs."
	set category = "Alien"

	xeno_mobhud = !xeno_mobhud
	var/datum/mob_hud/H = huds[MOB_HUD_XENO_STATUS]
	if(xeno_mobhud)
		H.add_hud_to(usr)
	else
		H.remove_hud_from(usr)



