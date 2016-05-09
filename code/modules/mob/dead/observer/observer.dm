/mob/dead
	var/voted_this_drop = 0

/mob/dead/observer
	name = "ghost"
	desc = "It's a g-g-g-g-ghooooost!" //jinkies!
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"
	layer = 4
	stat = DEAD
	density = 0
	canmove = 0
	blinded = 0
	anchored = 1	//  don't get pushed around
	invisibility = INVISIBILITY_OBSERVER
	var/can_reenter_corpse
	var/datum/hud/living/carbon/hud = null // hud
	var/bootime = 0
	var/started_as_observer //This variable is set to 1 when you enter the game as an observer.
							//If you died in the game and are a ghsot - this will remain as null.
							//Note that this is not a reliable way to determine if admins started as observers, since they change mobs a lot.
//	var/has_enabled_antagHUD = 0
	var/medHUD = 0
//	var/antagHUD = 0
	universal_speak = 1
	var/atom/movable/following = null

/mob/dead/observer/New(mob/body)
	sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	see_invisible = SEE_INVISIBLE_OBSERVER
	see_in_dark = 100
	verbs += /mob/dead/observer/proc/dead_tele

	stat = DEAD

	var/turf/T
	if(ismob(body))
		T = get_turf(body)				//Where is the body located?
		attack_log = body.attack_log	//preserve our attack logs by copying them to our ghost

		if (ishuman(body))
			var/mob/living/carbon/human/H = body
			icon = H.stand_icon
			overlays = H.overlays_standing
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
	..()
	if(is_alien_whitelisted(src,"Yautja") && ticker && ticker.mode && istype(ticker.mode,/datum/game_mode/colonialmarines))
		if(ticker.mode:is_pred_round)
			spawn(20)
				src << "\red It is a PREDATOR ROUND! Use Join The Hunt to enlist!"
				return



/mob/dead/observer/Topic(href, href_list)
	if (href_list["track"])
		var/mob/target = locate(href_list["track"]) in mob_list
		if(target)
			ManualFollow(target)



/mob/dead/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/weapon/book/tome))
		var/mob/dead/M = src
		if(src.invisibility != 0)
			M.invisibility = 0
			user.visible_message( \
				"\red [user] drags ghost, [M], to our plan of reality!", \
				"\red You drag [M] to our plan of reality!" \
			)
		else
			user.visible_message ( \
				"\red [user] just tried to smash his book into that ghost!  It's not very effective", \
				"\red You get the feeling that the ghost can't become any more visible." \
			)


/mob/dead/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return 1
/*
Transfer_mind is there to check if mob is being deleted/not going to have a body.
Works together with spawning an observer, noted above.
*/

/mob/dead/observer/Life()
	..()
	if(!loc) return
	if(!client) return 0


	if(client.images.len)
		for(var/image/hud in client.images)
			if(copytext(hud.icon_state,1,4) == "hud")
				client.images.Remove(hud)

//	if(antagHUD)
//		var/list/target_list = list()
//		for(var/mob/living/target in oview(src, 14))
//			if(target.mind&&(target.mind.special_role||issilicon(target)) )
//				target_list += target
//		if(target_list.len)
//			assess_targets(target_list, src)
	if(medHUD)
		process_medHUD(src)


/mob/dead/proc/process_medHUD(var/mob/M)
	var/client/C = M.client
	for(var/mob/living/carbon/human/patient in oview(M, 14))
		C.images += patient.hud_list[HEALTH_HUD]
		C.images += patient.hud_list[STATUS_HUD_OOC]

///mob/dead/proc/assess_targets(list/target_list, mob/dead/observer/U)
//	var/client/C = U.client
//	for(var/mob/living/carbon/human/target in target_list)
//		C.images += target.hud_list[SPECIALROLE_HUD]


/*
		else//If the silicon mob has no law datum, no inherent laws, or a law zero, add them to the hud.
			var/mob/living/silicon/silicon_target = target
			if(!silicon_target.laws||(silicon_target.laws&&(silicon_target.laws.zeroth||!silicon_target.laws.inherent.len))||silicon_target.mind.special_role=="traitor")
				if(isrobot(silicon_target))//Different icons for robutts and AI.
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
		var/response = alert(src, "Are you -sure- you want to ghost?\n(You are alive. If you ghost, you won't be able to play this round for at least 5 minutes. You can't change your mind so choose wisely!)","Are you sure you want to ghost?","Ghost","Stay in body")
		if(response != "Ghost")	return	//didn't want to ghost after-all
		resting = 1
		var/turf/location = get_turf(src)
		message_admins("[key_name_admin(usr)] has ghosted. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[location.x];Y=[location.y];Z=[location.z]'>JMP</a>)")
		log_game("[key_name_admin(usr)] has ghosted.")
		var/mob/dead/observer/ghost = ghostize(0)						//0 parameter is so we can never re-enter our body, "Charlie, you can never come baaaack~" :3
		if(ghost) //Could be null if no key
			ghost.timeofdeath = world.time // Because the living mob won't have a time of death and we want the respawn timer to work properly.
	return


/mob/dead/observer/Move(NewLoc, direct)
	following = null
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

/mob/dead/observer/examine()
	if(usr)
		usr << desc

/mob/dead/observer/can_use_hands()	return 0
/mob/dead/observer/is_active()		return 0

/mob/dead/observer/Stat()
	..()
	statpanel("Status")
	if (client.statpanel == "Status")
		stat(null, "Station Time: [worldtime2text()]")
		if(ticker)
			if(ticker.mode)
				//world << "DEBUG: ticker not null"
				if(ticker.mode.name == "AI malfunction")
					//world << "DEBUG: malf mode ticker test"
					if(ticker.mode:malf_mode_declared)
						stat(null, "Time left: [max(ticker.mode:AI_win_timeleft/(ticker.mode:apcs/3), 0)]")
		if(emergency_shuttle)
			var/eta_status = emergency_shuttle.get_status_panel_eta()
			if(eta_status)
				stat(null, eta_status)

/mob/dead/observer/verb/reenter_corpse()
	set category = "Ghost"
	set name = "Re-enter Corpse"
	if(!client)	return
	if(!(mind && mind.current && can_reenter_corpse))
		src << "<span class='warning'>You have no body.</span>"
		return
	if(mind.current.key && copytext(mind.current.key,1,2)!="@")	//makes sure we don't accidentally kick any clients
		usr << "<span class='warning'>Another consciousness is in your body...It is resisting you.</span>"
		return
	if(mind.current.ajourn && mind.current.stat != DEAD)	//check if the corpse is astral-journeying (it's client ghosted using a cultist rune).
		var/obj/effect/rune/R = locate() in mind.current.loc	//whilst corpse is alive, we can only reenter the body if it's on the rune
		if(!(R && R.word1 == cultwords["hell"] && R.word2 == cultwords["travel"] && R.word3 == cultwords["self"]))	//astral journeying rune
			usr << "<span class='warning'>The astral cord that ties your body and your spirit has been severed. You are likely to wander the realm beyond until your body is finally dead and thus reunited with you.</span>"
			return
	mind.current.ajourn=0
	mind.current.key = key
	return 1

/mob/dead/observer/verb/toggle_medHUD()
	set category = "Ghost"
	set name = "Toggle MedicHUD"
	set desc = "Toggles Medical HUD allowing you to see how everyone is doing"
	if(!client)
		return
	if(medHUD)
		medHUD = 0
		src << "\blue <B>Medical HUD Disabled</B>"
	else
		medHUD = 1
		src << "\blue <B>Medical HUD Enabled</B>"

/mob/dead/observer/proc/dead_tele()
	set category = "Ghost"
	set name = "Teleport"
	set desc= "Teleport to a location"
	if(!istype(usr, /mob/dead/observer))
		usr << "Not when you're not dead!"
		return
	usr.verbs -= /mob/dead/observer/proc/dead_tele
	spawn(30)
		usr.verbs += /mob/dead/observer/proc/dead_tele
	var/A
	A = input("Area to jump to", "BOOYEA", A) as null|anything in ghostteleportlocs
	var/area/thearea = ghostteleportlocs[A]
	if(!thearea)	return

	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		L+=T

	if(!L || !L.len)
		usr << "No area available."

	usr.loc = pick(L)
	following = null

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
		usr << "\red There aren't any living Xenos."
		return

	var/mob/target = mobs[input]
	ManualFollow(target)

// /mob/dead/observer/verb/follow_pred()
// 	set category = "Ghost"
// 	set name = "Follow Predator" // "Haunt"
// 	set desc = "Follow a living Predator."
//
// 	var/list/mobs = getpreds()
// 	var/input = input("Please select a living Predator:", "Haunt", null, null) as null|anything in mobs
//
// 	if(mobs.len == 0)
// 		usr << "\red There aren't any living Predators."
// 		return
//
// 	var/mob/target = mobs[input]
// 	ManualFollow(target)

// This is the ghost's follow verb with an argument
/mob/dead/observer/proc/ManualFollow(var/atom/movable/target)
	if(target && target != src)
		if(following && following == target)
			return
		following = target
		src << "\blue Now following [target]"
		spawn(0)
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

	if(istype(usr, /mob/dead/observer)) //Make sure they're an observer!


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
				following = null
			else
				A << "This mob is not located in the game world."
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
	src << "\red You are dead! You have no mind to store memory!"

/mob/dead/observer/add_memory()
	set hidden = 1
	src << "\red You are dead! You have no mind to store memory!"

/mob/dead/observer/verb/analyze_air()
	set name = "Analyze Air"
	set category = "Ghost"

	if(!istype(usr, /mob/dead/observer)) return

	// Shamelessly copied from the Gas Analyzers
	if (!( istype(usr.loc, /turf) ))
		return

	var/datum/gas_mixture/environment = usr.loc.return_air()

	var/pressure = environment.return_pressure()
	var/total_moles = environment.total_moles

	src << "\blue <B>Results:</B>"
	if(abs(pressure - ONE_ATMOSPHERE) < 10)
		src << "\blue Pressure: [round(pressure,0.1)] kPa"
	else
		src << "\red Pressure: [round(pressure,0.1)] kPa"
	if(total_moles)
		for(var/g in environment.gas)
			src << "\blue [gas_data.name[g]]: [round((environment.gas[g] / total_moles) * 100)]% ([round(environment.gas[g], 0.01)] moles)"
		src << "\blue Temperature: [round(environment.temperature-T0C,0.1)]&deg;C"
		src << "\blue Heat Capacity: [round(environment.heat_capacity(),0.1)]"


/mob/dead/observer/verb/toggle_darkness()
	set name = "Toggle Darkness"
	set category = "Ghost"

	if (see_invisible == SEE_INVISIBLE_OBSERVER_NOLIGHTING)
		see_invisible = SEE_INVISIBLE_OBSERVER
	else
		see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING

/*/mob/dead/observer/verb/become_mouse()
	set name = "Become mouse"
	set category = "Ghost"

//	if(config.disable_player_mice)
	src << "<span class='warning'>Spawning as a mouse is currently disabled.</span>"
	return*/
/*
	var/mob/dead/observer/M = usr
	if(config.antag_hud_restricted && M.has_enabled_antagHUD == 1)
		src << "<span class='warning'>antagHUD restrictions prevent you from spawning in as a mouse.</span>"
		return

	var/timedifference = world.time - client.time_died_as_mouse
	if(client.time_died_as_mouse && timedifference <= mouse_respawn_time * 600)
		var/timedifference_text
		timedifference_text = time2text(mouse_respawn_time * 600 - timedifference,"mm:ss")
		src << "<span class='warning'>You may only spawn again as a mouse more than [mouse_respawn_time] minutes after your death. You have [timedifference_text] left.</span>"
		return

	var/response = alert(src, "Are you -sure- you want to become a mouse?","Are you sure you want to squeek?","Squeek!","Nope!")
	if(response != "Squeek!") return  //Hit the wrong key...again.


	//find a viable mouse candidate
	var/mob/living/simple_animal/mouse/host
	var/obj/machinery/atmospherics/unary/vent_pump/vent_found
	var/list/found_vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/v in world)
		if(!v.welded && v.z == src.z)
			found_vents.Add(v)
	if(found_vents.len)
		vent_found = pick(found_vents)
		host = new /mob/living/simple_animal/mouse(vent_found.loc)
	else
		src << "<span class='warning'>Unable to find any unwelded vents to spawn mice at.</span>"

	if(host)
		if(config.uneducated_mice)
			host.universal_understand = 0
		host.ckey = src.ckey
		host << "<span class='info'>You are now a mouse. Try to avoid interaction with players, and do not give hints away that you are more than a simple rodent.</span>"
*/
/mob/dead/observer/verb/view_manfiest()
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
		src << "\red That verb is not currently permitted."
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
		src << "\red The veil is not thin enough for you to do that."
		return

	var/list/choices = list()
	for(var/obj/effect/decal/cleanable/blood/B in view(1,src))
		if(B.amount > 0)
			choices += B

	if(!choices.len)
		src << "<span class = 'warning'>There is no blood to use nearby.</span>"
		return

	var/obj/effect/decal/cleanable/blood/choice = input(src,"What blood would you like to use?") in null|choices

	var/direction = input(src,"Which way?","Tile selection") as anything in list("Here","North","South","East","West")
	var/turf/simulated/T = src.loc
	if (direction != "Here")
		T = get_step(T,text2dir(direction))

	if (!istype(T))
		src << "<span class='warning'>You cannot doodle there.</span>"
		return

	if(!choice || choice.amount == 0 || !(src.Adjacent(choice)))
		return

	var/doodle_color = (choice.basecolor) ? choice.basecolor : "#A10808"

	var/num_doodles = 0
	for (var/obj/effect/decal/cleanable/blood/writing/W in T)
		num_doodles++
	if (num_doodles > 4)
		src << "<span class='warning'>There is no space to write on!</span>"
		return

	var/max_length = 50

	var/message = stripped_input(src,"Write a message. It cannot be longer than [max_length] characters.","Blood writing", "")

	if (message)

		if (length(message) > max_length)
			message += "-"
			src << "<span class='warning'>You ran out of blood to write with!</span>"

		var/obj/effect/decal/cleanable/blood/writing/W = new(T)
		W.basecolor = doodle_color
		W.update_icon()
		W.message = message
		W.add_hiddenprint(src)
		W.visible_message("\red Invisible fingers crudely paint something in blood on [T]...")*/

/mob/dead/verb/join_as_alien()
	set category = "Ghost"
	set name = "Join as Xeno"
	set desc = "Select an alive but logged-out Xenomorph to rejoin the game."

	var/mob/L = src

	if(ticker.current_state < GAME_STATE_PLAYING)
		usr << "\red The game hasn't started yet!"
		return

	if (!usr.stat) // Make sure we're an observer
		// usr << "!usr.stat"
		return

	if (usr != src)
		// usr << "usr != src"
		return 0 // Something is terribly wrong

	if(jobban_isbanned(usr,"Alien")) // User is jobbanned
		usr << "\red You are banned from playing aliens and cannot spawn as a Xeno."
		return

	var/list/alien_list = list()

	for(var/mob/living/carbon/Xenomorph/A in living_mob_list)
		if(isXeno(A) && !A.client)
			alien_list += A.name

	if(alien_list.len == 0)
		usr << "\red There aren't any available Xenomorphs."

	var/choice = input("Pick a Xeno:") as null|anything in alien_list
	if (isnull(choice) || choice == "Cancel")
		return

	for(var/mob/living/carbon/Xenomorph/X in living_mob_list)
		if(choice == X.name)
			L = X
			break

	if(!L || isnull( L ))
		usr << "Not a valid mob!"
		return

	if(!istype(L, /mob/living/carbon/Xenomorph))
		usr << "\red That's not a Xeno."
		return

	if(L.stat == DEAD)  // Xeno is dead. Dead.
		usr << "\red It's dead."
		return

	if(L.client) // Xeno player is still online
		usr << "\red That player has reconnected."
		return

	var/deathtime = world.time - usr.timeofdeath
	var/deathtimeminutes = round(deathtime / 600)
	var/pluralcheck = "minute"
	if(deathtimeminutes == 0)
		pluralcheck = ""
	else if(deathtimeminutes == 1)
		pluralcheck = " [deathtimeminutes] minute and"
	else if(deathtimeminutes > 1)
		pluralcheck = " [deathtimeminutes] minutes and"
	var/deathtimeseconds = round((deathtime - deathtimeminutes * 600) / 10,1)

	if (deathtime < 3000 && (!usr.client.holder || !(usr.client.holder.rights & R_ADMIN))) // To prevent players from ghosting/suiciding and then immediately becoming a Xeno - Ignored for Admins, cause we're special
		usr << "\red You have been dead for[pluralcheck] [deathtimeseconds] seconds."
		usr << "\red You must wait 5 minutes before rejoining the game!"
		return

	if(L.away_timer < 300) // away_timer in mob.dm's Life() proc is not high enough. NOT ignored for Admins, cause that player might actually log back in.
		usr << "\red That player hasn't been away long enough. Please wait [300 - L.away_timer] more seconds."
		return

	if (alert(usr, "Everything checks out. Are you sure you want to transfer yourself into this [L]?", "Confirmation", "Yes", "No") == "Yes")

		if(L.client || L.stat == DEAD) // Do it again, just in case
			usr << "\red Oops. That mob can no longer be controlled. Sorry."
			return

		var/mob/ghostmob = usr.client.mob
		message_admins("[usr.ckey] has joined as [L].")
		log_admin("[usr.ckey] has joined as [L].")
		L.ckey = usr.ckey
		// L.client = usr.client
		if( isobserver(ghostmob) )
			del(ghostmob)

	return

/mob/dead/verb/join_as_hellhound()
	set category = "Ghost"
	set name = "Join as Hellhound"
	set desc = "Select an alive and available Hellhound. THIS COMES WITH STRICT RULES. READ THEM OR GET BANNED."

	var/mob/L = src

	if(ticker.current_state < GAME_STATE_PLAYING)
		usr << "\red The game hasn't started yet!"
		return

	if (!usr.stat) // Make sure we're an observer
		// usr << "!usr.stat"
		return

	if (usr != src)
		// usr << "usr != src"
		return 0 // Something is terribly wrong

	if(jobban_isbanned(usr,"Alien")) // User is jobbanned
		usr << "\red You are banned from playing aliens and cannot spawn as a Hellhound."
		return

	var/list/hellhound_list = list()

	for(var/mob/living/carbon/hellhound/A in living_mob_list)
		if(istype(A) && !A.client)
			hellhound_list += A.name

	if(hellhound_list.len == 0)
		usr << "\red There aren't any available Hellhounds."
		return

	var/choice = input("Pick a Hellhound:") as null|anything in hellhound_list
	if (isnull(choice) || choice == "Cancel")
		return

	for(var/mob/living/carbon/hellhound/X in living_mob_list)
		if(choice == X.name)
			L = X
			break

	if(!L || isnull( L ))
		usr << "Not a valid mob!"
		return

	if(!istype(L, /mob/living/carbon/hellhound))
		usr << "\red That's not a Hellhound."
		return

	if(L.stat == DEAD)  // DEAD
		usr << "\red It's dead."
		return

	if(L.client) // Larva player is still online
		usr << "\red That player is still connected."
		return

	if (alert(usr, "Everything checks out. Are you sure you want to transfer yourself into this hellhound?", "Confirmation", "Yes", "No") == "Yes")

		if(L.client || L.stat == DEAD) // Do it again, just in case
			usr << "\red Oops. That mob can no longer be controlled. Sorry."
			return

		var/mob/ghostmob = usr.client.mob
		message_admins("[usr.ckey] has joined as a [L].")
		log_admin("[usr.ckey] has joined as a [L].")
		L.ckey = usr.ckey

		if( isobserver(ghostmob) )
			del(ghostmob)
		spawn(15)
			L << "\red <B>Attention!! You are playing as a hellhound. You can get server banned if you are shitty so listen up!</b>"
			L << "\red You MUST listen to and obey the Predator's commands at all times. Die if they demand it. Not following them is unthinkable to a hellhound."
			L << "\red You are not here to go hog wild rambo. You're here to be part of something rare, a Predator hunt."
			L << "\red The Predator players must follow a strict code of role-play and you are expected to as well."
			L << "\red The Predators cannot understand your speech. They can only give you orders and expect you to follow them. They have a camera that allows them to see you remotely, so you are excellent for scouting missions."
			L << "\red Hellhounds are fiercely protective of their masters and will never leave their side if under attack."
			L << "\red Note that ANY Predator can give you orders. If they conflict, follow the latest one. If they dislike your performance they can ask for another ghost and everyone will mock you. So do a good job!"
	return

/mob/dead/verb/join_as_yautja()
	set category = "Ghost"
	set name = "Join as Predator"
	set desc = "If you are whitelisted, and it is the right type of round, join in."

	if(!ticker || ticker.current_state < GAME_STATE_PLAYING || !ticker.mode)
		usr << "\red The game hasn't started yet!"
		return

	if(!istype(ticker.mode,/datum/game_mode/colonialmarines))
		usr << "Gamemode mismatch. Consider asking an Admin to spawn you."
		return

	if (!usr.stat || !client) // Make sure we're an observer
		// usr << "!usr.stat"
		return

	if (usr != src)
		// usr << "usr != src"
		return 0 // Something is terribly wrong

	if(jobban_isbanned(usr,"Alien")) // User is jobbanned
		usr << "\red You are banned from playing aliens and cannot spawn as a Predator."
		return

	if(!is_alien_whitelisted(usr,"Yautja") && !is_alien_whitelisted(usr,"Yautja Elder"))
		usr << "You are not whitelisted."
		return

	if(ticker.mode:is_pred_round == 0)
		usr << "You are whitelisted, but there are no hunts this round. Maybe if you prayed real hard an Admin could spawn you in."
		return

	if(ticker.mode:numpreds >= 3)
		usr << "Already full up. There can only be 3 per round."
		return

	if((src.client && src.client.was_a_predator))
		usr << "You already were a Yautja! Give someone else a chance."
		return

	var/I

	for(I in ticker.mode.pred_keys)
		if(uppertext(I) == uppertext(usr.key)) //case doesn't matter.
			usr << "You already were Yautja, you bum."
			return

	var/mob/old = src
	var/mob/living/carbon/human/M = new(pick(pred_spawn))
	M.key = src.key

	M.set_species("Yautja")
	if(src.client && src.client.prefs) //Fuckit, one of these must be right.
		M.real_name = src.client.prefs.predator_name
		M.gender = src.client.prefs.predator_gender
	else if(M.client && M.client.prefs)
		if(M.client.prefs.predator_gender)
			if(M.client.prefs.predator_gender == "male")
				M.gender = "male"
			else
				M.gender = "female"
		else
			M.gender = "male"

		M.real_name = M.client.prefs.predator_name

	if(!M.gender) M.gender = "male"
	M.update_icons()
	log_admin("[src] [src.key], became a new Yautja, [M.real_name].")
	message_admins("[src] ([src.key]) joined as Yautja, [M.real_name].")

	if(is_alien_whitelisted(M,"Yautja Elder"))
		M.real_name = "Elder [M.real_name]"
		M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/yautja/full(M), slot_wear_suit)
		M.equip_to_slot_or_del(new /obj/item/weapon/twohanded/glaive(M), slot_l_hand)
		M << "<B>You come equipped as an Elder should, with bonus glaive and heavy armor.</b>"

	ticker.mode.predators += M.mind
	ticker.mode.pred_keys += usr.key
	ticker.mode:numpreds++
	M.mind.assigned_role = "MODE"
	M.mind.special_role = "Predator"
	if(M.client) M.client.was_a_predator = 1
	if(old) del(old) //Wipe the old ghost.
	return

/mob/dead/verb/drop_vote()
	set category = "Ghost"
	set name = "Spectator Vote"
	set desc = "If it's on Hunter Games gamemode, vote on who gets a supply drop!"

	if(!ticker || ticker.current_state < GAME_STATE_PLAYING || !ticker.mode)
		usr << "\red The game hasn't started yet!"
		return

	if(!istype(ticker.mode,/datum/game_mode/huntergames))
		usr << "Wrong game mode. You have to be observing a Hunter Games round."
		return

	if(!waiting_for_drop_votes)
		usr << "There's no drop vote currently in progress. Wait for a supply drop to be announced!"
		return

	if(voted_this_drop)
		usr << "You voted for this one already. Only one please!"
		return

	var/list/mobs = living_mob_list
	var/target = null

	for(var/mob/living/M in mobs)
		if(!istype(M,/mob/living/carbon/human) || M.stat || isYautja(M)) mobs -= M


	target = input("Please, select a contestant!", "Cake Time", null, null) as null|anything in mobs

	if (!target)//Make sure we actually have a target
		return
	else
		usr << "Your vote for [target] has been counted!"
		ticker.mode:supply_votes += target
		voted_this_drop = 1
		spawn(200)
			voted_this_drop = 0
		return