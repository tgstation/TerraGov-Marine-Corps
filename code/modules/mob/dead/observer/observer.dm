/mob/dead
	var/voted_this_drop = 0

/mob/dead/observer
	name = "ghost"
	desc = "It's a g-g-g-g-ghooooost!" //jinkies!
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"
	stat = DEAD
	density = 0
	canmove = 0
	anchored = 1	//  don't get pushed around
	invisibility = INVISIBILITY_OBSERVER
	layer = ABOVE_FLY_LAYER
	var/can_reenter_corpse
	var/datum/hud/living/carbon/hud = null // hud
	var/bootime = 0
	var/started_as_observer //This variable is set to 1 when you enter the game as an observer.
							//If you died in the game and are a ghsot - this will remain as null.
							//Note that this is not a reliable way to determine if admins started as observers, since they change mobs a lot.
//	var/has_enabled_antagHUD = 0
	var/ghost_medhud = 0
	var/ghost_sechud = 0
	var/ghost_squadhud = 0
	var/ghost_xenohud = 0
	//	var/antagHUD = 0
	universal_speak = 1
	var/atom/movable/following = null

/mob/dead/observer/Login()
	if(!client)
		return
	client.prefs.load_preferences()
	ghost_medhud = client.prefs.ghost_medhud
	ghost_sechud = client.prefs.ghost_sechud
	ghost_squadhud = client.prefs.ghost_squadhud
	ghost_xenohud = client.prefs.ghost_xenohud
	client.prefs.save_preferences()
	var/datum/mob_hud/H
	if(ghost_medhud)
		H = huds[MOB_HUD_MEDICAL_OBSERVER]
		H.add_hud_to(src)
	if(ghost_sechud)
		H = huds[MOB_HUD_SECURITY_ADVANCED]
		H.add_hud_to(src)
	if(ghost_squadhud)
		H = huds[MOB_HUD_SQUAD]
		H.add_hud_to(src)
	if(ghost_xenohud)
		H = huds[MOB_HUD_XENO_STATUS]
		H.add_hud_to(src)
	return ..()

/mob/dead/observer/New(mob/body)
	sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS|SEE_SELF
	see_invisible = SEE_INVISIBLE_OBSERVER
	see_in_dark = 100
	verbs += /mob/dead/observer/proc/dead_tele

	stat = DEAD

	var/turf/T
	if(ismob(body))
		T = get_turf(body)

		if (ishuman(body))
			var/mob/living/carbon/human/H = body
			icon = H.stand_icon
			overlays = H.overlays_standing
			underlays = H.underlays_standing
		else
			icon = body.icon
			icon_state = body.icon_state
			overlays = body.overlays

		alpha = 127

		gender = body.gender
		if(body.mind && body.mind.name)
			name = body.mind.name
		else
			if(body.real_name)
				name = body.real_name
			else
				if(gender == MALE)
					name = capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))
				else
					name = capitalize(pick(first_names_female)) + " " + capitalize(pick(last_names))

		mind = body.mind	//we don't transfer the mind but we keep a reference to it.

	if(!T)	T = pick(latejoin)			//Safety in case we cannot find the body's position
	loc = T

	if(!name)							//To prevent nameless ghosts
		name = capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))
	real_name = name
	Login()
	..()
	if(ticker && ticker.mode && ticker.mode.flags_round_type & MODE_PREDATOR)
		addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, src, "<span class='warning'>This is a <b>PREDATOR ROUND</b>! If you are whitelisted, you may Join the Hunt!</span>"), 20)

/mob/dead/observer/Topic(href, href_list)
	if(href_list["reentercorpse"])
		if(isobserver(usr))
			var/mob/dead/observer/A = usr
			A.reenter_corpse()
	if(href_list["track"])
		var/mob/target = locate(href_list["track"]) in GLOB.mob_list
		if(target)
			ManualFollow(target)

/mob/dead/CanPass(atom/movable/mover, turf/target)
	return 1
/*
Transfer_mind is there to check if mob is being deleted/not going to have a body.
Works together with spawning an observer, noted above.
*/

/mob/dead/observer/Life()
	..()
	if(!loc) return
	if(!client) return 0

//	if(antagHUD)
//		var/list/target_list = list()
//		for(var/mob/living/target in oview(src, 14))
//			if(target.mind&&(target.mind.special_role||issilicon(target)) )
//				target_list += target
//		if(target_list.len)
//			assess_targets(target_list, src)

///mob/dead/proc/assess_targets(list/target_list, mob/dead/observer/U)
//	var/client/C = U.client
//	for(var/mob/living/carbon/human/target in target_list)
//		C.images += target.hud_list[SPECIALROLE_HUD]


/*
		else//If the silicon mob has no law datum, no inherent laws, or a law zero, add them to the hud.
			var/mob/living/silicon/silicon_target = target
			if(!silicon_target.laws||(silicon_target.laws&&(silicon_target.laws.zeroth||!silicon_target.laws.inherent.len))||silicon_target.mind.special_role=="traitor")
				if(iscyborg(silicon_target))//Different icons for robutts and AI.
					U.client.images += image(tempHud,silicon_target,"hudmalborg")
				else
					U.client.images += image(tempHud,silicon_target,"hudmalai")
*/
	return 1

/mob/proc/ghostize(var/can_reenter_corpse = 1)
	if(key)
		var/mob/dead/observer/ghost = new(src)	//Transfer safety to observer spawning proc.
		ghost.can_reenter_corpse = can_reenter_corpse
		ghost.timeofdeath = src.timeofdeath //BS12 EDIT
		ghost.key = key
		if(!can_reenter_corpse)
			away_timer = 300 //they'll never come back, so we can max out the timer right away.
		if(ghost.client)
			ghost.client.change_view(world.view) //reset view range to default
			ghost.client.pixel_x = 0 //recenters our view
			ghost.client.pixel_y = 0
//		if(!ghost.client.holder && !config.antag_hud_allowed)		// For new ghosts we remove the verb from even showing up if it's not allowed.
//			ghost.verbs -= /mob/dead/observer/verb/toggle_antagHUD	// Poor guys, don't know what they are missing!
		return ghost

/*
This is the proc mobs get to turn into a ghost. Forked from ghostize due to compatibility issues.
*/
/mob/living/verb/ghost()
	set category = "OOC"
	set name = "Ghost"
	set desc = "Relinquish your life and enter the land of the dead."

	if(stat == DEAD)
		ghostize(1)
	else
		var/response = alert(src, "Are you -sure- you want to ghost?\n(You are alive. If you ghost, you won't be able to return to your body. You can't change your mind so choose wisely!)","Are you sure you want to ghost?","Ghost","Stay in body")
		if(response != "Ghost")	return	//didn't want to ghost after-all
		resting = 1
		var/turf/location = get_turf(src)
		log_game("[key_name(usr)] has ghosted.")
		if(location) //to avoid runtime when a mob ends up in nullspace
			message_admins("[ADMIN_TPMONTY(usr)] has ghosted.")
		var/mob/dead/observer/ghost = ghostize(0)						//0 parameter is so we can never re-enter our body, "Charlie, you can never come baaaack~" :3
		if(ghost) //Could be null if no key
			ghost.timeofdeath = world.time // Because the living mob won't have a time of death and we want the respawn timer to work properly.
	return

/mob/dead/observer/proc/unfollow()
	following?.followers -= src
	following = null

/mob/dead/observer/Move(NewLoc, direct)
	unfollow()
	dir = direct
	if(NewLoc)
		loc = NewLoc
		for(var/obj/effect/step_trigger/S in NewLoc)
			S.Crossed(src)

		return
	loc = get_turf(src) //Get out of closets and such as a ghost
	if((direct & NORTH) && y < world.maxy)
		y++
	else if((direct & SOUTH) && y > 1)
		y--
	if((direct & EAST) && x < world.maxx)
		x++
	else if((direct & WEST) && x > 1)
		x--

	for(var/obj/effect/step_trigger/S in locate(x, y, z))	//<-- this is dumb
		S.Crossed(src)

/mob/dead/observer/examine(mob/user)
	to_chat(user, desc)

/mob/dead/observer/can_use_hands()
	return 0

/mob/dead/observer/Stat()
	. = ..()

	if(statpanel("Stats"))
		if(EvacuationAuthority)
			var/eta_status = EvacuationAuthority.get_status_panel_eta()
			if(eta_status)
				stat(null, eta_status)

/mob/dead/observer/verb/reenter_corpse()
	set category = "Ghost"
	set name = "Re-enter Corpse"
	if(!client)	return
	if(!mind || !mind.current || mind.current.gc_destroyed || !can_reenter_corpse)
		to_chat(src, "<span class='warning'>You have no body.</span>")
		return
	if(mind.current.key && copytext(mind.current.key,1,2)!="@")	//makes sure we don't accidentally kick any clients
		to_chat(usr, "<span class='warning'>Another consciousness is in your body...It is resisting you.</span>")
		return
	mind.current.key = key
	if(mind.current.client) mind.current.client.change_view(world.view)
	return 1

/mob/dead/observer/verb/toggle_HUDs()
	set category = "Ghost"
	set name = "Toggle HUDs"
	set desc = "Toggles various HUDs."
	if(!client)
		return
	var/list/listed_huds = list("Medical HUD", "Security HUD", "Squad HUD", "Xeno Status HUD")
	var/hud_choice = input("Choose a HUD to toggle", "Toggle HUD", null) as null|anything in listed_huds
	if(!client)
		return
	client.prefs.load_preferences()
	ghost_medhud = client.prefs.ghost_medhud
	ghost_sechud = client.prefs.ghost_sechud
	ghost_squadhud = client.prefs.ghost_squadhud
	ghost_xenohud = client.prefs.ghost_xenohud
	client.prefs.save_preferences()
	var/datum/mob_hud/H

	switch(hud_choice)
		if("Medical HUD")
			ghost_medhud = !ghost_medhud
			H = huds[MOB_HUD_MEDICAL_OBSERVER]
			ghost_medhud ? H.add_hud_to(src) : H.remove_hud_from(src)
			client.prefs.ghost_medhud = ghost_medhud
			client.prefs.save_preferences()
			to_chat(src, "<span class='boldnotice'>[hud_choice] [ghost_medhud?"Enabled":"Disabled"]</span>")
		if("Security HUD")
			ghost_sechud = !ghost_sechud
			H = huds[MOB_HUD_SECURITY_ADVANCED]
			ghost_sechud ? H.add_hud_to(src) : H.remove_hud_from(src)
			client.prefs.ghost_sechud = ghost_sechud
			client.prefs.save_preferences()
			to_chat(src, "<span class='boldnotice'>[hud_choice] [ghost_sechud?"Enabled":"Disabled"]</span>")
		if("Squad HUD")
			ghost_squadhud = !ghost_squadhud
			H = huds[MOB_HUD_SQUAD]
			ghost_squadhud ? H.add_hud_to(src) : H.remove_hud_from(src)
			client.prefs.ghost_squadhud = ghost_squadhud
			client.prefs.save_preferences()
			to_chat(src, "<span class='boldnotice'>[hud_choice] [ghost_squadhud?"Enabled":"Disabled"]</span>")
		if("Xeno Status HUD")
			ghost_xenohud = !ghost_xenohud
			H = huds[MOB_HUD_XENO_STATUS]
			ghost_xenohud ? H.add_hud_to(src) : H.remove_hud_from(src)
			client.prefs.ghost_xenohud = ghost_xenohud
			client.prefs.save_preferences()
			to_chat(src, "<span class='boldnotice'>[hud_choice] [ghost_xenohud?"Enabled":"Disabled"]</span>")


/mob/dead/observer/proc/dead_tele()
	set category = "Ghost"
	set name = "Teleport"
	set desc= "Teleport to a location"
	if(!isobserver(usr))
		to_chat(usr, "Not when you're not dead!")
		return
	var/A
	A = input("Area to jump to", "BOOYEA", A) as null|anything in ghostteleportlocs
	var/area/thearea = ghostteleportlocs[A]
	if(!thearea)	return

	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		L+=T

	if(!L || !L.len)
		to_chat(usr, "No area available.")

	usr.loc = pick(L)
	unfollow()

/mob/dead/observer/verb/follow()
	set category = "Ghost"
	set name = "Follow" // "Haunt"
	set desc = "Follow and haunt a mob."

	var/list/mobs = getmobs()
	var/input = input("Please select a mob:", "Haunt", null, null) as null|anything in mobs
	var/mob/target = mobs[input]
	ManualFollow(target)

/mob/dead/observer/verb/follow_xeno()
	set category = "Ghost"
	set name = "Follow Xeno" // "Haunt"
	set desc = "Follow a living Xeno."

	var/list/mobs = getxenos()
	var/input = input("Please select a living Xeno:", "Haunt", null, null) as null|anything in mobs

	if(mobs.len == 0)
		to_chat(usr, "<span class='warning'>There aren't any living Xenos.</span>")
		return

	var/mob/target = mobs[input]
	ManualFollow(target)

/mob/dead/observer/verb/follow_pred()
	set category = "Ghost"
	set name = "Follow Predator" // "Haunt"
	set desc = "Follow a living Predator."

	var/list/mobs = getpreds()
	var/input = input("Please select a living Predator:", "Haunt", null, null) as null|anything in mobs

	if(mobs.len == 0)
		to_chat(usr, "<span class='warning'>There aren't any living Predators.</span>")
		return

	var/mob/target = mobs[input]
	ManualFollow(target)

/mob/dead/observer/verb/follow_human()
	set category = "Ghost"
	set name = "Follow Human" // "Haunt"
	set desc = "Follow a living Human."

	var/list/mobs = getlivinghumans()
	var/input = input("Please select a living Human:", "Haunt", null, null) as null|anything in mobs

	if(mobs.len == 0)
		to_chat(usr, "<span class='warning'>There aren't any living Humans.</span>")
		return

	var/mob/target = mobs[input]
	ManualFollow(target)

/atom/movable
	var/list/mob/dead/observer/followers = list()

/atom/movable/Moved()
	..()

	if(followers.len)
		for(var/_F in followers)
			var/mob/dead/observer/F = _F //Read this was faster than var/typepath/F in list
			F.loc = loc

// This is the ghost's follow verb with an argument
/mob/dead/observer/proc/ManualFollow(var/atom/movable/target)
	if(target && target != src)
		if(following && following == target)
			return
		unfollow()
		target.followers += src
		following = target
		loc = target.loc
		to_chat(src, "<span class='notice'>Now following [target]</span>")
		spawn(0) //Backup
			while(target && following == target && client)
				var/turf/T = get_turf(target)
				if(!T)
					break
				// To stop the ghost flickering.
				if(loc != T)
					loc = T
				sleep(15)

/mob/dead/observer/verb/jumptomob() //Moves the ghost instead of just changing the ghosts's eye -Nodrak
	set category = "Ghost"
	set name = "Jump to Mob"
	set desc = "Teleport to a mob"

	if(isobserver(usr)) //Make sure they're an observer!


		var/list/dest = list() //List of possible destinations (mobs)
		var/target = null	   //Chosen target.

		dest += getmobs() //Fill list, prompt user with list
		target = input("Please, select a player!", "Jump to Mob", null, null) as null|anything in dest

		if (!target)//Make sure we actually have a target
			return
		else
			var/mob/M = dest[target] //Destination mob
			var/mob/A = src			 //Source mob
			var/turf/T = get_turf(M) //Turf of the destination mob

			if(T && isturf(T))	//Make sure the turf exists, then move the source to that destination.
				A.loc = T
				unfollow()
			else
				to_chat(A, "This mob is not located in the game world.")
/*
/mob/dead/observer/verb/boo()
	set category = "Ghost"
	set name = "Boo!"
	set desc= "Scare your crew members because of boredom!"

	if(bootime > world.time) return
	var/obj/machinery/light/L = locate(/obj/machinery/light) in view(1, src)
	if(L)
		L.flicker()
		bootime = world.time + 600
		return
	//Maybe in the future we can add more <i>spooky</i> code here!
	return
*/

/mob/dead/observer/memory()
	set hidden = 1
	to_chat(src, "<span class='warning'>You are dead! You have no mind to store memory!</span>")

/mob/dead/observer/add_memory()
	set hidden = 1
	to_chat(src, "<span class='warning'>You are dead! You have no mind to store memory!</span>")

/mob/dead/observer/verb/analyze_air()
	set name = "Analyze Air"
	set category = "Ghost"

	if(!isobserver(usr)) return

	// Shamelessly copied from the Gas Analyzers
	if (!( istype(loc, /turf) ))
		return

	var/turf/T = loc

	var/pressure = T.return_pressure()
	var/env_temperature = T.return_temperature()
	var/env_gas = T.return_gas()

	to_chat(src, "<span class='boldnotice'>Results:</span>")
	if(abs(pressure - ONE_ATMOSPHERE) < 10)
		to_chat(src, "<span class='notice'>Pressure: [round(pressure,0.1)] kPa</span>")
	else
		to_chat(src, "<span class='warning'>Pressure: [round(pressure,0.1)] kPa</span>")

	to_chat(src, "<span class='notice'>Gas type: [env_gas]</span>")
	to_chat(src, "<span class='notice'>Temperature: [round(env_temperature-T0C,0.1)]&deg;C</span>")


/mob/dead/observer/verb/toggle_zoom()
	set name = "Toggle Zoom"
	set category = "Ghost"

	if(client)
		if(client.view != world.view)
			client.change_view(world.view)
		else
			client.change_view(14)


/mob/dead/observer/verb/toggle_darkness()
	set name = "Toggle Darkness"
	set category = "Ghost"

	if (see_invisible == SEE_INVISIBLE_OBSERVER_NOLIGHTING)
		see_invisible = SEE_INVISIBLE_OBSERVER
	else
		see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING

/mob/dead/observer/verb/hive_status()
	set name = "Show Hive Status"
	set desc = "Check the status of the hive."
	set category = "Ghost"

	check_hive_status()


/*/mob/dead/observer/verb/become_mouse()
	set name = "Become mouse"
	set category = "Ghost"

//	if(config.disable_player_mice)
	to_chat(src, "<span class='warning'>Spawning as a mouse is currently disabled.</span>")
	return*/
/*
	var/mob/dead/observer/M = usr
	if(config.antag_hud_restricted && M.has_enabled_antagHUD == 1)
		to_chat(src, "<span class='warning'>antagHUD restrictions prevent you from spawning in as a mouse.</span>")
		return

	var/timedifference = world.time - client.time_died_as_mouse
	if(client.time_died_as_mouse && timedifference <= mouse_respawn_time * 600)
		var/timedifference_text
		timedifference_text = time2text(mouse_respawn_time * 600 - timedifference,"mm:ss")
		to_chat(src, "<span class='warning'>You may only spawn again as a mouse more than [mouse_respawn_time] minutes after your death. You have [timedifference_text] left.</span>")
		return

	var/response = alert(src, "Are you -sure- you want to become a mouse?","Are you sure you want to squeek?","Squeek!","Nope!")
	if(response != "Squeek!") return  //Hit the wrong key...again.


	//find a viable mouse candidate
	var/mob/living/simple_animal/mouse/host
	var/obj/machinery/atmospherics/unary/vent_pump/vent_found
	var/list/found_vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/v in machines)
		if(!v.welded && v.z == src.z)
			found_vents.Add(v)
	if(found_vents.len)
		vent_found = pick(found_vents)
		host = new /mob/living/simple_animal/mouse(vent_found.loc)
	else
		to_chat(src, "<span class='warning'>Unable to find any unwelded vents to spawn mice at.</span>")

	if(host)
		if(config.uneducated_mice)
			host.universal_understand = 0
		host.ckey = src.ckey
		to_chat(host, "<span class='info'>You are now a mouse. Try to avoid interaction with players, and do not give hints away that you are more than a simple rodent.</span>")
*/
/mob/dead/observer/verb/view_manifest()
	set name = "View Crew Manifest"
	set category = "Ghost"

	var/dat
	dat += "<h4>Crew Manifest</h4>"
	dat += data_core.get_manifest()

	src << browse(dat, "window=manifest;size=370x420;can_close=1")

//Used for drawing on walls with blood puddles as a spooky ghost.
/*/mob/dead/verb/bloody_doodle()

	set category = "Ghost"
	set name = "Write in blood"
	set desc = "If the round is sufficiently spooky, write a short message in blood on the floor or a wall. Remember, no IC in OOC or OOC in IC."

	if(!(config.cult_ghostwriter))
		to_chat(src, "<span class='warning'>That verb is not currently permitted.</span>")
		return

	if (!src.stat)
		return

	if (usr != src)
		return 0 //something is terribly wrong

	var/ghosts_can_write
	if(ticker.mode.name == "cult")
		var/datum/game_mode/cult/C = ticker.mode
		if(C.cult.len > config.cult_ghostwriter_req_cultists)
			ghosts_can_write = 1

	if(!ghosts_can_write)
		to_chat(src, "<span class='warning'>The veil is not thin enough for you to do that.</span>")
		return

	var/list/choices = list()
	for(var/obj/effect/decal/cleanable/blood/B in view(1,src))
		if(B.amount > 0)
			choices += B

	if(!choices.len)
		to_chat(src, "<span class = 'warning'>There is no blood to use nearby.</span>")
		return

	var/obj/effect/decal/cleanable/blood/choice = input(src,"What blood would you like to use?") in null|choices

	var/direction = input(src,"Which way?","Tile selection") as anything in list("Here","North","South","East","West")
	var/turf/T = src.loc
	if (direction != "Here")
		T = get_step(T,text2dir(direction))

	if (!istype(T))
		to_chat(src, "<span class='warning'>You cannot doodle there.</span>")
		return

	if(!choice || choice.amount == 0 || !(src.Adjacent(choice)))
		return

	var/doodle_color = (choice.basecolor) ? choice.basecolor : "#A10808"

	var/num_doodles = 0
	for (var/obj/effect/decal/cleanable/blood/writing/W in T)
		num_doodles++
	if (num_doodles > 4)
		to_chat(src, "<span class='warning'>There is no space to write on!</span>")
		return

	var/max_length = 50

	var/message = stripped_input(src,"Write a message. It cannot be longer than [max_length] characters.","Blood writing", "")

	if (message)

		if (length(message) > max_length)
			message += "-"
			to_chat(src, "<span class='warning'>You ran out of blood to write with!</span>")

		var/obj/effect/decal/cleanable/blood/writing/W = new(T)
		W.basecolor = doodle_color
		W.update_icon()
		W.message = message
		W.add_hiddenprint(src)
		W.visible_message("<span class='warning'> Invisible fingers crudely paint something in blood on [T]...</span>")*/

/mob/dead/verb/join_as_alien()
	set category = "Ghost"
	set name = "Join as Xeno"
	set desc = "Select an alive but logged-out Xenomorph to rejoin the game."

	if (!stat || !client)
		return

	if(!ticker || ticker.current_state < GAME_STATE_PLAYING || !ticker.mode)
		to_chat(src, "<span class='warning'>The game hasn't started yet!</span>")
		return

	if(ticker.mode.check_xeno_late_join(src))
		var/mob/new_xeno = ticker.mode.attempt_to_join_as_xeno(src)
		if(new_xeno)
			ticker.mode.transfer_xeno(src, new_xeno)

/mob/dead/verb/join_as_larva()
	set category = "Ghost"
	set name = "Join as Larva"
	set desc = "Attempt to be born as a burrowed larva should a Queen be in ovi."
	if (!stat || !client || !ticker.mode.check_xeno_late_join(src))
		return FALSE
	if(!ticker || ticker.current_state < GAME_STATE_PLAYING || !ticker.mode)
		to_chat(src, "<span class='warning'>The game hasn't started yet!</span>")
		return FALSE
	var/mob/living/carbon/Xenomorph/Queen/mother = ticker.mode.attempt_to_join_as_larva(src)
	if(!mother)
		return FALSE
	else
		ticker.mode.spawn_larva(src, mother)
		return TRUE

/mob/dead/verb/join_as_zombie() //Adapted from join as hellhoud
	set category = "Ghost"
	set name = "Join as Zombie"
	set desc = "Select an alive but logged-out Zombie to rejoin the game."

	if (!stat || !client)
		return

	if(!ticker || ticker.current_state < GAME_STATE_PLAYING || !ticker.mode)
		to_chat(src, "<span class='warning'>The game hasn't started yet!</span?>")
		return

	var/list/zombie_list = list()

	for(var/mob/living/carbon/human/A in GLOB.alive_human_list)
		if(iszombie(A) && !A.client && A.regenZ)
			var/player_in_decap_head
			//when decapitated the human mob is clientless,
			//we must check whether the player is still manning the brain in the decap'd head,
			//so their body isn't stolen by another player.
			var/datum/limb/head/h = A.get_limb("head")
			if(h && (h.status & LIMB_DESTROYED))
				for (var/obj/item/limb/head/HD in GLOB.item_list)
					if(HD.brainmob)
						if(HD.brainmob.real_name == A.real_name)
							if(HD.brainmob.client)
								player_in_decap_head = TRUE
								break
			if(!player_in_decap_head)
				zombie_list += A.real_name


	if(zombie_list.len == 0)
		to_chat(src, "<span class='green'> There are no available zombies or all empty zombies have been fed the cure.</span>")
		return

	var/choice = input("Pick a Zombie:") as null|anything in zombie_list
	if(!choice || choice == "Cancel")
		return

	if(!client)
		return

	for(var/mob/living/carbon/human/Z in GLOB.alive_human_list)
		if(choice == Z.real_name)
			if(Z.gc_destroyed) //should never occur,just to be sure.
				return
			if(!Z.regenZ)
				to_chat(src, "<span class='warning'>That zombie has been cured!</span>")
				return
			if(Z.client)
				to_chat(src, "<span class='warning'>That player is still connected.</span>")
				return

			var/datum/limb/head/h = Z.get_limb("head")
			if(h && (h.status & LIMB_DESTROYED))
				for (var/obj/item/limb/head/HD in GLOB.item_list)
					if(HD.brainmob)
						if(HD.brainmob.real_name == Z.real_name)
							if(HD.brainmob.client)
								to_chat(src, "<span class='warning'>That player is still connected!</span>")
								return

			var/mob/ghostmob = client.mob

			Z.ghostize(0) //Make sure previous owner does not get a free respawn.
			Z.ckey = usr.ckey
			if(Z.client) //so players don't keep their ghost zoom view.
				Z.client.change_view(world.view)

			log_admin("[key_name(Z)] has joined as a zombie.")
			message_admins("[ADMIN_TPMONTY(Z)] has joined as a zombie.")

			if(isobserver(ghostmob) )
				qdel(ghostmob)
			return





/mob/dead/verb/join_as_hellhound()
	set category = "Ghost"
	set name = "Join as Hellhound"
	set desc = "Select an alive and available Hellhound. THIS COMES WITH STRICT RULES. READ THEM OR GET BANNED."

	var/mob/L = src

	if(ticker.current_state < GAME_STATE_PLAYING)
		to_chat(usr, "<span class='warning'>The game hasn't started yet!</span>")
		return

	if (!usr.stat) // Make sure we're an observer
		// to_chat(usr, "!usr.stat")
		return

	if (usr != src)
		// to_chat(usr, "usr != src")
		return 0 // Something is terribly wrong

	if(jobban_isbanned(usr,"Alien")) // User is jobbanned
		to_chat(usr, "<span class='warning'>You are banned from playing aliens and cannot spawn as a Hellhound.</span>")
		return

	var/list/hellhound_list = list()

	for(var/mob/living/carbon/hellhound/A in GLOB.alive_mob_list)
		if(istype(A) && !A.client)
			hellhound_list += A.real_name

	if(hellhound_list.len == 0)
		to_chat(usr, "<span class='warning'>There aren't any available Hellhounds.</span>")
		return

	var/choice = input("Pick a Hellhound:") as null|anything in hellhound_list
	if (isnull(choice) || choice == "Cancel")
		return

	for(var/mob/living/carbon/hellhound/X in GLOB.alive_mob_list)
		if(choice == X.real_name)
			L = X
			break

	if(!L || L.gc_destroyed)
		to_chat(usr, "Not a valid mob!")
		return

	if(!istype(L, /mob/living/carbon/hellhound))
		to_chat(usr, "<span class='warning'>That's not a Hellhound.</span>")
		return

	if(L.stat == DEAD)  // DEAD
		to_chat(usr, "<span class='warning'>It's dead.</span>")
		return

	if(L.client) // Larva player is still online
		to_chat(usr, "<span class='warning'>That player is still connected.</span>")
		return

	if (alert(usr, "Everything checks out. Are you sure you want to transfer yourself into this hellhound?", "Confirmation", "Yes", "No") == "Yes")

		if(L.client || L.stat == DEAD) // Do it again, just in case
			to_chat(usr, "<span class='warning'>Oops. That mob can no longer be controlled. Sorry.</span>")
			return

		var/mob/ghostmob = usr.client.mob
		message_admins("[usr.ckey] has joined as a [L].")
		log_admin("[usr.ckey] has joined as a [L].")
		L.ckey = usr.ckey
		if(L.client) L.client.change_view(world.view)

		if( isobserver(ghostmob) )
			qdel(ghostmob)
		spawn(15)
			to_chat(L, "<span class='danger'>Attention!! You are playing as a hellhound. You can get server banned if you are shitty so listen up!</span>")
			to_chat(L, "<span class='warning'>You MUST listen to and obey the Predator's commands at all times. Die if they demand it. Not following them is unthinkable to a hellhound.</span>")
			to_chat(L, "<span class='warning'>You are not here to go hog wild rambo. You're here to be part of something rare, a Predator hunt.</span>")
			to_chat(L, "<span class='warning'>The Predator players must follow a strict code of role-play and you are expected to as well.</span>")
			to_chat(L, "<span class='warning'>The Predators cannot understand your speech. They can only give you orders and expect you to follow them. They have a camera that allows them to see you remotely, so you are excellent for scouting missions.</span>")
			to_chat(L, "<span class='warning'>Hellhounds are fiercely protective of their masters and will never leave their side if under attack.</span>")
			to_chat(L, "<span class='warning'>Note that ANY Predator can give you orders. If they conflict, follow the latest one. If they dislike your performance they can ask for another ghost and everyone will mock you. So do a good job!</span>")
	return

/mob/dead/verb/join_as_yautja()
	set category = "Ghost"
	set name = "Join the Hunt"
	set desc = "If you are whitelisted, and it is the right type of round, join in."

	if (!stat || !client)
		return

	if(!ticker || ticker.current_state < GAME_STATE_PLAYING || !ticker.mode)
		to_chat(src, "<span class='warning'>The game hasn't started yet!</span>")
		return

	if(ticker.mode.check_predator_late_join(src))
		if(jobban_isbanned(src, "Predator"))
			to_chat(src, "<span class='warning'>You have been jobbanned from playing predator! Jobbans are only lifted upon request.</span>")
			return
		else
			ticker.mode.attempt_to_join_as_predator(src)

/mob/dead/verb/drop_vote()
	set category = "Ghost"
	set name = "Spectator Vote"
	set desc = "If it's on Hunter Games gamemode, vote on who gets a supply drop!"

	if(!ticker || ticker.current_state < GAME_STATE_PLAYING || !ticker.mode)
		to_chat(usr, "<span class='warning'>The game hasn't started yet!</span>")
		return

	if(!istype(ticker.mode,/datum/game_mode/huntergames))
		to_chat(usr, "Wrong game mode. You have to be observing a Hunter Games round.")
		return

	if(!waiting_for_drop_votes)
		to_chat(usr, "There's no drop vote currently in progress. Wait for a supply drop to be announced!")
		return

	if(voted_this_drop)
		to_chat(usr, "You voted for this one already. Only one please!")
		return

	var/list/mobs = GLOB.alive_mob_list
	var/target = null

	for(var/mob/living/M in mobs)
		if(!istype(M,/mob/living/carbon/human) || M.stat || isyautja(M)) mobs -= M


	target = input("Please, select a contestant!", "Cake Time", null, null) as null|anything in mobs

	if (!target)//Make sure we actually have a target
		return
	else
		to_chat(usr, "Your vote for [target] has been counted!")
		ticker.mode:supply_votes += target
		voted_this_drop = 1
		spawn(200)
			voted_this_drop = 0
		return




/mob/dead/observer/verb/edit_characters()
	set category = "Ghost"
	set name = "Edit Characters"
	set desc = "Edit your characters in your preferences."

	can_reenter_corpse = FALSE //no coming back if you edit your preferences.
	client.prefs.ShowChoices(src)

/mob/dead/observer/Topic(href, href_list)
	..()
	if(href_list["preference"])
		if(client)
			client.prefs.process_link(src, href_list)


/mob/dead/observer/verb/observe()
	set name = "Observe"
	set category = "Ghost"

	if(client.eye != client.mob)
		client.perspective = MOB_PERSPECTIVE
		client.eye = client.mob
		return

	var/list/mobs = getmobs()
	var/input = input("Please select a mob:", "Observe", null, null) as null|anything in mobs
	var/mob/target = mobs[input]

	if(!target)
		return

	if(client && target)
		client.perspective = EYE_PERSPECTIVE
		client.eye = target
