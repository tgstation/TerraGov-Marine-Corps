

/mob/living/carbon/Xenomorph/proc/Pounce(atom/T)

	if(!T) return

	if(!isturf(loc))
		src << "<span class='warning'>You can't pounce from here!</span>"
		return

	if(!check_state())
		return

	if(usedPounce)
		src << "<span class='warning'>You must wait before pouncing.</span>"
		return

	if(!check_plasma(10))
		return

	visible_message("<span class='xenowarning'>\The [src] pounces at \the [T]!</span>", \
	"<span class='xenowarning'>You pounce at \the [T]!</span>")
	usedPounce = 30 //About 12 seconds
	flags_pass = PASSTABLE
	use_plasma(10)
	throw_at(T, 6, 2, src) //Victim, distance, speed
	spawn(6)
		if(!hardcore)
			flags_pass = initial(flags_pass) //Reset the passtable.
		else
			flags_pass = 0 //Reset the passtable.

	spawn(usedPounce)
		usedPounce = 0
		src << "<span class='notice'>You get ready to pounce again.</span>"
		for(var/X in actions)
			var/datum/action/A = X
			A.update_button_icon()

	return 1

/mob/living/carbon/Xenomorph/proc/vent_crawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Alien"
	if(!check_state())
		return
	var/pipe = start_ventcrawl()
	if(pipe)
		handle_ventcrawl(pipe)





/mob/living/carbon/Xenomorph/proc/xeno_transfer_plasma(atom/A, amount = 50, transfer_delay = 20, max_range = 2)
	if(!istype(A, /mob/living/carbon/Xenomorph))
		return
	var/mob/living/carbon/Xenomorph/target = A

	if(!check_state())
		return

	if(!isturf(loc))
		src << "<span class='warning'>You can't transfer plasma from here!</span>"
		return

	if(get_dist(src, target) > max_range)
		src << "<span class='warning'>You need to be closer to [target].</span>"
		return

	src << "<span class='notice'>You start focusing your plasma towards [target].</span>"
	if(!do_after(src, transfer_delay, TRUE, 5, BUSY_ICON_CLOCK))
		return

	if(!check_state())
		return

	if(!isturf(loc))
		src << "<span class='warning'>You can't transfer plasma from here!</span>"
		return

	if(get_dist(src, target) > max_range)
		src << "<span class='warning'>You need to be closer to [target].</span>"
		return

	if(storedplasma < amount)
		amount = storedplasma //Just use all of it
	use_plasma(amount)
	target.gain_plasma(amount)
	target << "<span class='xenowarning'>\The [src] has transfered [amount] plasma to you. You now have [target.storedplasma].</span>"
	src << "<span class='xenowarning'>You have transferred [amount] plasma to \the [target]. You now have [storedplasma].</span>"




//Tail stab. Checked during a slash, after the above.
//Deals a monstrous amount of damage based on how long it's been charging, but charging it drains plasma.
//Toggle is in XenoPowers.dm.
/mob/living/carbon/Xenomorph/proc/tail_attack(mob/living/carbon/human/M)
	if(!ismob(M))
		return

	if(!readying_tail)
		return 0 //Tail attack not prepared, or not available.


	if(!isturf(loc))
		src << "<span class='warning'>You can't attack [M] from here!</span>"
		return

	if(get_dist(src, M) > 1)
		return

	if(!istype(M))
		src << "<span class='xenowarning'>Tail attacks only work on humans.</span>"
		return 0

	if(M.stat == DEAD)
		src << "<span class='warning'>[M] is dead, why would you want to touch it?</span>"
		return 0

	next_move = world.time + 3 //so you can't instantly combo tail+slash

	var/dmg = (round(readying_tail * 2.5)) + rand(5, 10) //Ready max is 20
	if(mob_size == MOB_SIZE_BIG)
		dmg += 10
	var/datum/limb/affecting
	var/tripped = 0

	if(M.lying)
		dmg += 10 //More damage when hitting downed people.

	affecting = M.get_limb(ran_zone(zone_selected,75))
	if(!affecting) //No organ, just get a random one
		affecting = M.get_limb(ran_zone(null, 0))
	if(!affecting) //Still nothing??
		affecting = M.get_limb("chest") // Gotta have a torso?!
	var/armor_block = M.run_armor_check(affecting, "melee")

	var/miss_chance = 15
	if(isXenoHivelord(src))
		miss_chance += 20 //Fuck hivelords

	animation_attack_on(M)
	if(prob(miss_chance))
		playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1)
		visible_message("<span class='danger'>\The [src] lashes out with its tail but misses \the [M]!", \
		"<span class='danger'>You snap your tail out but miss \the [M]!</span>")
		readying_tail = 0
		selected_ability.button.icon_state = "template"
		selected_ability = null
		return

	//Selecting feet? Drop the damage and trip them.
	if(zone_selected == "r_leg" || zone_selected == "l_leg" || zone_selected == "l_foot" || zone_selected == "r_foot")
		if(prob(60) && !M.lying)
			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1)
			visible_message("<span class='danger'>\The [src] lashes out with its tail and \the [M] goes down!</span>", \
			"<span class='danger'>You snap your tail out and trip \the [M]!</span>")
			M.KnockDown(5)
			dmg = dmg / 2 //Half damage for a tail strike.
			tripped = 1


	flick_attack_overlay(M, "tail")
	playsound(loc, 'sound/weapons/wristblades_hit.ogg', 25, 1) //Stolen from Yautja! Owned!
	if(!tripped)
		visible_message("<span class='danger'>\The [M] is suddenly impaled by \the [src]'s sharp tail!</span>", \
		"<span class='danger'>You violently impale \the [M] with your tail!</span>")
	M.attack_log += text("\[[time_stamp()]\] <font color='red'>tail-stabbed [M.name] ([M.ckey])</font>")
	attack_log += text("\[[time_stamp()]\] <font color='orange'>was tail-stabbed by [src.name] ([src.ckey])</font>")

	M.apply_damage(dmg, BRUTE, affecting, armor_block, sharp = 1, edge = 1) //This should slicey dicey
	M.updatehealth()
	readying_tail = 0
	selected_ability.button.icon_state = "template"
	selected_ability = null
	return 1


//Note: All the neurotoxin projectile items are stored in XenoProcs.dm
/mob/living/carbon/Xenomorph/proc/xeno_spit(atom/T)

	if(!check_state())
		return

	if(!isturf(loc))
		src << "<span class='warning'>You can't spit from here!</span>"
		return

	if(has_spat > world.time)
		src << "<span class='warning'>You must wait for your spit glands to refill.</span>"
		return

	if(!check_plasma(ammo.spit_cost))
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
	has_spat = world.time + spit_delay + ammo.added_spit_delay
	use_plasma(ammo.spit_cost)
	cooldown_notification(spit_delay + ammo.added_spit_delay, "spit")

	return TRUE

/mob/living/carbon/Xenomorph/proc/cooldown_notification(cooldown, message)
	set waitfor = 0
	sleep(cooldown)
	switch(message)
		if("spit")
			src << "<span class='notice'>You feel your neurotoxin glands swell with ichor. You can spit again.</span>"
	for(var/X in actions)
		var/datum/action/A = X
		A.update_button_icon()



/mob/living/carbon/Xenomorph/proc/build_resin(atom/A, resin_plasma_cost)
	if(!check_state())
		return
	if(!check_plasma(resin_plasma_cost))
		return
	var/turf/current_turf = loc
	if (caste == "Hivelord") //hivelords can thicken existing resin structures.
		if(get_dist(src,A) <= 1)
			if(istype(A, /turf/simulated/wall/resin))
				var/turf/simulated/wall/resin/WR = A
				if(WR.walltype == "resin")
					visible_message("<span class='xenonotice'>\The [src] regurgitates a thick substance and thickens [WR].</span>", \
					"<span class='xenonotice'>You regurgitate some resin and thicken [WR].</span>")
					var/prev_oldturf = WR.oldTurf
					WR.ChangeTurf(/turf/simulated/wall/resin/thick)
					WR.oldTurf = prev_oldturf
					use_plasma(resin_plasma_cost)
					playsound(loc, 'sound/effects/splat.ogg', 15, 1) //Splat!
				else if(WR.walltype == "membrane")
					var/prev_oldturf = WR.oldTurf
					WR.ChangeTurf(/turf/simulated/wall/resin/membrane/thick)
					WR.oldTurf = prev_oldturf
					use_plasma(resin_plasma_cost)
					playsound(loc, 'sound/effects/splat.ogg', 15, 1) //Splat!
				else
					src << "<span class='xenowarning'>[WR] can't be made thicker.</span>"
				return

			else if(istype(A, /obj/structure/mineral_door/resin))
				var/obj/structure/mineral_door/resin/DR = A
				if(DR.hardness == 1.5) //non thickened
					var/oldloc = DR.loc
					visible_message("<span class='xenonotice'>\The [src] regurgitates a thick substance and thickens [DR].</span>", \
						"<span class='xenonotice'>You regurgitate some resin and thicken [DR].</span>")
					cdel(DR)
					new /obj/structure/mineral_door/resin/thick (oldloc)
					playsound(loc, 'sound/effects/splat.ogg', 15, 1) //Splat!
					use_plasma(resin_plasma_cost)
				else
					src << "<span class='xenowarning'>[DR] can't be made thicker.</span>"
				return

			else
				current_turf = get_turf(A) //Hivelords can secrete resin on adjacent turfs.


	if(!istype(current_turf) || !current_turf.is_weedable())
		src << "<span class='warning'>You can't do that here.</span>"
		return

	var/area/AR = get_area(current_turf)
	if(istype(AR,/area/shuttle/drop1/lz1) || istype(AR,/area/shuttle/drop2/lz2) || istype(AR,/area/sulaco/hangar)) //Bandaid for atmospherics bug when Xenos build around the shuttles
		src << "<span class='warning'>You sense this is not a suitable area for expanding the hive.</span>"
		return

	var/obj/effect/alien/weeds/alien_weeds = locate() in current_turf

	if(!alien_weeds)
		src << "<span class='warning'>You can only shape on weeds. Find some resin before you start building!</span>"
		return

	if(!check_alien_construction(current_turf))
		return

	var/wait_time = 5
	if(caste == "Drone")
		wait_time = 10

	if(!do_after(src, wait_time, TRUE, 5, BUSY_ICON_CLOCK))
		return
	if(!check_state())
		return
	if(!check_plasma(resin_plasma_cost))
		return

	if(!istype(current_turf) || !current_turf.is_weedable())
		return

	AR = get_area(current_turf)
	if(istype(AR,/area/shuttle/drop1/lz1 || istype(AR,/area/shuttle/drop2/lz2)) || istype(AR,/area/sulaco/hangar)) //Bandaid for atmospherics bug when Xenos build around the shuttles
		return

	alien_weeds = locate() in current_turf
	if(!alien_weeds)
		return

	if(!check_alien_construction(current_turf))
		return

	use_plasma(resin_plasma_cost)
	visible_message("<span class='xenonotice'>\The [src] regurgitates a thick substance and shapes it into \a [selected_resin]!</span>", \
	"<span class='xenonotice'>You regurgitate some resin and shape it into \a [selected_resin].</span>")
	playsound(loc, 'sound/effects/splat.ogg', 15, 1) //Splat!

	switch(selected_resin)
		if("resin door")
			if (caste == "Hivelord")
				new /obj/structure/mineral_door/resin/thick(current_turf)
			else
				new /obj/structure/mineral_door/resin(current_turf)
		if("resin wall")
			if (caste == "Hivelord")
				current_turf.ChangeTurf(/turf/simulated/wall/resin/thick)
			else
				current_turf.ChangeTurf(/turf/simulated/wall/resin)
		if("resin membrane")
			if (caste == "Hivelord")
				current_turf.ChangeTurf(/turf/simulated/wall/resin/membrane/thick)
			else
				current_turf.ChangeTurf(/turf/simulated/wall/resin/membrane)

		if("resin nest")
			new /obj/structure/stool/bed/nest(current_turf)
		if("sticky resin")
			new /obj/effect/alien/resin/sticky(current_turf)




//Corrosive acid is consolidated -- it checks for specific castes for strength now, but works identically to each other.
//The acid items are stored in XenoProcs.
/mob/living/carbon/Xenomorph/proc/corrosive_acid(atom/O, acid_type, plasma_cost)

	if(!O.Adjacent(src))
		src << "<span class='warning'>\The [O] is too far away.</span>"
		return

	if(!isturf(loc))
		src << "<span class='warning'>You can't melt [O] from here!</span>"
		return

	face_atom(O)

	var/wait_time = 10

	//OBJ CHECK
	if(isobj(O))
		var/obj/I = O
		if(I.unacidable || istype(I, /obj/machinery/computer) || istype(I, /obj/effect)) //So the aliens don't destroy energy fields/singularies/other aliens/etc with their acid.
			src << "<span class='warning'>You cannot dissolve \the [I].</span>" // ^^ Note for obj/effect.. this might check for unwanted stuff. Oh well
			return
		if(istype(O, /obj/structure/window_frame/almayer/colony/reinforced) && acid_type != /obj/effect/xenomorph/acid/strong)
			src << "<span class='warning'>This [O.name] is too tough to be melted by your weak acid.</span>"
			return
	//TURF CHECK
	else if(isturf(O))
		var/turf/T = O
		var/dissolvability = T.can_be_dissolved()
		switch(dissolvability)
			if(0)
				src << "<span class='warning'>You cannot dissolve \the [T].</span>"
				return
			if(1)
				wait_time = 50
			if(2)
				if(acid_type != /obj/effect/xenomorph/acid/strong)
					src << "<span class='warning'>This [T.name] is too tough to be melted by your weak acid.</span>"
					return
				wait_time = 100
			else
				return
		src << "<span class='xenowarning'>You begin generating enough acid to melt through \the [T].</span>"
	else
		src << "<span class='warning'>You cannot dissolve \the [O].</span>"
		return

	if(!do_after(src, wait_time, TRUE, 5, BUSY_ICON_CLOCK))
		return

	if(!check_state())
		return

	if(!O || !get_turf(O)) //Some logic.
		return

	if(!check_plasma(plasma_cost))
		return
	use_plasma(plasma_cost)

	var/obj/effect/xenomorph/acid/A = new acid_type(get_turf(O), O)
	if(isturf(O))
		A.icon_state += "_wall"

	if(istype(O, /obj/structure) || istype(O, /obj/machinery)) //Always appears above machinery
		A.layer = O.layer + 0.1
	else //If not, appear on the floor (turf layer is 2, vents are 2.4)
		A.layer = XENO_FLOOR_ACID_LAYER

	if(!isturf(O))
		msg_admin_attack("[src.name] ([src.ckey]) spat acid on [O].")
		attack_log += text("\[[time_stamp()]\] <font color='green'>Spat acid on [O]</font>")
	visible_message("<span class='xenowarning'>\The [src] vomits globs of vile stuff all over \the [O]. It begins to sizzle and melt under the bubbling mess of acid!</span>", \
	"<span class='xenowarning'>You vomit globs of vile stuff all over \the [O]. It begins to sizzle and melt under the bubbling mess of acid!</span>")






/mob/living/carbon/Xenomorph/verb/hive_status()
	set name = "Hive Status"
	set desc = "Check the status of your current hive."
	set category = "Alien"

	check_hive_status()


/proc/check_hive_status()
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
		var/xenoinfo = "<tr><td>[X.name] "
		if(!X.client) xenoinfo += " <i>(SSD)</i>"
		if(X.stat == DEAD)
			xenoinfo += " <b><font color=red>(DEAD)</font></b></td></tr>"
		else
			count++ //Dead players shouldn't be on this list
			xenoinfo += " <b><font color=green>([A ? A.name : null])</b></td></tr>"

		if(isXenoQueen(X))
			queen_list += xenoinfo
		if(isXenoBoiler(X))
			boiler_list += xenoinfo
			boiler_count++
		if(isXenoCrusher(X))
			crusher_list += xenoinfo
			crusher_count++
		if(isXenoPraetorian(X))
			praetorian_list += xenoinfo
			praetorian_count++
		if(isXenoRavager(X))
			ravager_list += xenoinfo
			ravager_count++
		if(isXenoCarrier(X))
			carrier_list += xenoinfo
			carrier_count++
		if(isXenoHivelord(X))
			hivelord_list += xenoinfo
			hivelord_count++
		if(isXenoHunter(X))
			hunter_list += xenoinfo
			hunter_count++
		if(isXenoSpitter(X))
			spitter_list += xenoinfo
			spitter_count++
		if(isXenoDrone(X))
			drone_list += xenoinfo
			drone_count++
		if(isXenoRunner(X))
			runner_list += xenoinfo
			runner_count++
		if(isXenoSentinel(X))
			sentinel_list += xenoinfo
			sentinel_count++
		if(isXenoLarva(X))
			larva_list += xenoinfo
			larva_count++

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


/mob/living/carbon/Xenomorph/verb/toggle_xeno_mobhud()
	set name = "Toggle Xeno Status HUD"
	set desc = "Toggles the health and plasma hud appearing above Xenomorphs."
	set category = "Alien"

	xeno_mobhud = !xeno_mobhud
	var/datum/mob_hud/H = huds[MOB_HUD_XENO_STATUS]
	if(xeno_mobhud)
		H.add_hud_to(usr)
	else
		H.remove_hud_from(usr)


/mob/living/carbon/Xenomorph/verb/middle_mousetoggle()
	set name = "Toggle Middle/Shift Clicking"
	set desc = "Toggles between using middle mouse click and shift click for selected abilitiy use."
	set category = "Alien"

	middle_mouse_toggle = !middle_mouse_toggle
	if(!middle_mouse_toggle)
		src << "<span class='notice'>The selected xeno ability will now be activated with shift clicking.</span>"
	else
		src << "<span class='notice'>The selected xeno ability will now be activated with middle mouse clicking.</span>"

