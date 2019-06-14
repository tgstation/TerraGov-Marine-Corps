/datum/admins/proc/launch_pod()
	set category = "Fun"
	set name = "Launch Supply Pod"

	if(!check_rights(R_FUN))
		return

	var/datum/podlauncher/P = new(usr)
	if(!P.bay || !P.podarea)
		return

	P.ui_interact(usr)
	usr.set_interaction(P)


/datum/podlauncher
	var/static/list/ignored_atoms = typecacheof(list(null, /mob/dead, /obj/effect/landmark, /obj/docking_port, /obj/effect/particle_effect/sparks, /obj/effect/DPtarget, /obj/effect/supplypod_selector))
	var/turf/oldTurf
	var/client/holder
	var/area/bay
	var/area/podarea
	var/launchClone = FALSE
	var/launchChoice = 1
	var/explosionChoice = 0
	var/damageChoice = 0
	var/launcherActivated = FALSE
	var/effectBurst = FALSE
	var/effectAnnounce = FALSE
	var/numTurfs = 0
	var/launchCounter = 1
	var/atom/specificTarget
	var/list/orderedArea
	var/list/turf/acceptableTurfs
	var/list/launchList
	var/obj/effect/supplypod_selector/selector
	var/obj/structure/closet/supplypod/centcompod/temp_pod


/datum/podlauncher/New(user)
	if(istype(user, /client))
		var/client/C = user
		holder = C
	else if(ismob(user))
		var/mob/M = user
		holder = M.client
	bay =  locate(/area/centcom/supplypod/loading/one) in GLOB.all_areas
	podarea = locate(/area/centcom/supplypod/podStorage) in GLOB.all_areas
	createPod(podarea)
	selector = new()
	launchList = list()
	acceptableTurfs = list()
	orderedArea = createOrderedArea(bay)


/datum/podlauncher/Destroy()
	updateCursor(FALSE)
	QDEL_NULL(temp_pod)
	QDEL_NULL(selector)
	return ..()


/datum/podlauncher/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui, force_open = TRUE, datum/nanoui/master_ui, datum/topic_state/state = GLOB.admin_state)
	var/list/data = list()
	var/B = (istype(bay, /area/centcom/supplypod/loading/one)) ? 1 : (istype(bay, /area/centcom/supplypod/loading/two)) ? 2 : (istype(bay, /area/centcom/supplypod/loading/three)) ? 3 : (istype(bay, /area/centcom/supplypod/loading/four)) ? 4 : (istype(bay, /area/centcom/supplypod/loading/ert)) ? 5 : 0
	data["bay"] = bay
	data["bayNumber"] = B
	data["oldArea"] = (oldTurf ? get_area(oldTurf) : null)
	data["launchClone"] = launchClone
	data["launchChoice"] = launchChoice
	data["explosionChoice"] = explosionChoice
	data["damageChoice"] = damageChoice
	data["fallDuration"] = temp_pod.fallDuration
	data["landingDelay"] = temp_pod.landingDelay
	data["openingDelay"] = temp_pod.openingDelay
	data["departureDelay"] = temp_pod.departureDelay
	data["styleChoice"] = temp_pod.style
	data["effectStun"] = temp_pod.effectStun
	data["effectLimb"] = temp_pod.effectLimb
	data["effectOrgans"] = temp_pod.effectOrgans
	data["effectBluespace"] = temp_pod.bluespace
	data["effectStealth"] = temp_pod.effectStealth
	data["effectQuiet"] = temp_pod.effectQuiet
	data["effectMissile"] = temp_pod.effectMissile
	data["effectCircle"] = temp_pod.effectCircle
	data["effectBurst"] = effectBurst
	data["effectReverse"] = temp_pod.reversing
	data["effectTarget"] = specificTarget
	data["effectName"] = temp_pod.adminNamed
	data["effectAnnounce"] = effectAnnounce
	data["giveLauncher"] = launcherActivated
	data["numObjects"] = numTurfs
	data["fallingSound"] = temp_pod.fallingSound != initial(temp_pod.fallingSound)
	data["landingSound"] = temp_pod.landingSound
	data["openingSound"] = temp_pod.openingSound
	data["leavingSound"] = temp_pod.leavingSound
	data["soundVolume"] = temp_pod.soundVolume != initial(temp_pod.soundVolume)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "podlauncher.tmpl", "Launch Pod", 1000, 700, null, master_ui, state)
		ui.set_initial_data(data)
		ui.open()


/datum/podlauncher/Topic(href, href_list)
	. = ..()
	if(.)
		return


	if(href_list["bay1"])
		bay = locate(/area/centcom/supplypod/loading/one) in GLOB.all_areas
		refreshBay()
		. = TRUE


	else if(href_list["bay2"])
		bay = locate(/area/centcom/supplypod/loading/two) in GLOB.all_areas
		refreshBay()
		. = TRUE


	else if(href_list["bay3"])
		bay = locate(/area/centcom/supplypod/loading/three) in GLOB.all_areas
		refreshBay()
		. = TRUE


	else if(href_list["bay4"])
		bay = locate(/area/centcom/supplypod/loading/four) in GLOB.all_areas
		refreshBay()
		. = TRUE


	else if(href_list["bay5"])
		bay = locate(/area/centcom/supplypod/loading/ert) in GLOB.all_areas
		refreshBay()
		. = TRUE


	else if(href_list["teleportCentcom"])
		var/mob/M = holder.mob
		oldTurf = get_turf(M)
		var/area/A = locate(bay) in GLOB.all_areas
		var/list/turfs = list()
		for(var/turf/T in A)
			turfs.Add(T)
		var/turf/T = safepick(turfs)
		if(!T)
			to_chat(M, "<span class='warning'>Nowhere to jump to!</span>")
			return
		M.forceMove(T)
		log_admin("[key_name(usr)] jumped to [AREACOORD(A)]")
		message_admins("[key_name_admin(usr)] jumped to [AREACOORD(A)]")
		. = TRUE


	else if(href_list["teleportBack"])
		var/mob/M = holder.mob
		if(!oldTurf)
			to_chat(M, "<span class='warning'>Nowhere to jump to!</span>")
			return
		M.forceMove(oldTurf)
		log_admin("[key_name(usr)] jumped to [AREACOORD(oldTurf)]")
		message_admins("[key_name_admin(usr)] jumped to [AREACOORD(oldTurf)]")
		. = TRUE


	else if(href_list["launchClone"])
		launchClone = !launchClone
		. = TRUE


	else if(href_list["launchOrdered"])
		if(launchChoice == 1)
			launchChoice = 0
			updateSelector()
			. = TRUE
			return
		launchChoice = 1
		updateSelector()
		. = TRUE


	else if(href_list["launchRandom"])
		if(launchChoice == 2)
			launchChoice = 0
			updateSelector()
			. = TRUE
			return
		launchChoice = 2
		updateSelector()
		. = TRUE


	else if(href_list["explosionCustom"])
		if(explosionChoice == 1)
			explosionChoice = 0
			temp_pod.explosionSize = list(0, 0, 0, 0)
			. = TRUE
			return
		var/list/expNames = list("Devastation", "Heavy Damage", "Light Damage", "Flash")
		var/list/boomInput = list()
		for(var/i in 1 to length(expNames))
			boomInput.Add(input("[expNames[i]] Range", "Enter the [expNames[i]] range of the explosion. WARNING: This ignores the bomb cap!", 0) as null|num)
			if(isnull(boomInput[i]))
				return
			if(!isnum(boomInput[i]))
				to_chat(holder, "<span class='warning'>That wasnt a number! Value set to zero instead.</span>")
				boomInput = 0
		explosionChoice = 1
		temp_pod.explosionSize = boomInput
		. = TRUE


	else if(href_list["explosionBus"])
		if(explosionChoice == 2)
			explosionChoice = 0
			temp_pod.explosionSize = list(0, 0, 0, 0)
			. = TRUE
			return
		explosionChoice = 2
		temp_pod.explosionSize = list(GLOB.MAX_EX_DEVESTATION_RANGE, GLOB.MAX_EX_HEAVY_RANGE, GLOB.MAX_EX_LIGHT_RANGE, GLOB.MAX_EX_FLAME_RANGE)
		. = TRUE


	else if(href_list["damageCustom"])
		if(damageChoice == 1)
			damageChoice = 0
			temp_pod.damage = 0
			. = TRUE
			return
		var/damageInput = input("How much damage to deal", "Enter the amount of brute damage dealt by getting hit", 0) as null|num
		if(isnull(damageInput))
			return
		if(!isnum(damageInput))
			to_chat(holder, "<span class='warning'>That wasn't a number! Value set to default (zero) instead.</span>")
			damageInput = 0
		damageChoice = 1
		temp_pod.damage = damageInput
		. = TRUE


	else if(href_list["damageGib"])
		if(damageChoice == 2)
			damageChoice = 0
			temp_pod.damage = 0
			temp_pod.effectGib = FALSE
			. = TRUE
			return
		damageChoice = 2
		temp_pod.damage = 5000
		temp_pod.effectGib = TRUE
		. = TRUE


	else if(href_list["effectName"])
		if(temp_pod.adminNamed)
			temp_pod.adminNamed = FALSE
			temp_pod.setStyle(temp_pod.style)
			. = TRUE
			return
		var/nameInput= input("Custom name", "Enter a custom name", POD_STYLES[temp_pod.style][POD_NAME]) as null|text
		if(isnull(nameInput))
			return
		var/descInput = input("Custom description", "Enter a custom desc", POD_STYLES[temp_pod.style][POD_DESC]) as null|text
		if(isnull(descInput))
			return
		temp_pod.name = nameInput
		temp_pod.desc = descInput
		temp_pod.adminNamed = TRUE
		. = TRUE


	else if(href_list["effectStun"])
		temp_pod.effectStun = !temp_pod.effectStun
		. = TRUE


	else if(href_list["effectLimb"])
		temp_pod.effectLimb = !temp_pod.effectLimb
		. = TRUE


	else if(href_list["effectOrgans"])
		temp_pod.effectOrgans = !temp_pod.effectOrgans
		. = TRUE


	else if(href_list["effectBluespace"])
		temp_pod.bluespace = !temp_pod.bluespace
		. = TRUE


	else if(href_list["effectStealth"])
		temp_pod.effectStealth = !temp_pod.effectStealth
		. = TRUE


	else if(href_list["effectQuiet"])
		temp_pod.effectQuiet = !temp_pod.effectQuiet
		. = TRUE


	else if(href_list["effectMissile"])
		temp_pod.effectMissile = !temp_pod.effectMissile
		. = TRUE


	else if(href_list["effectCircle"])
		temp_pod.effectCircle = !temp_pod.effectCircle
		. = TRUE


	else if(href_list["effectBurst"])
		effectBurst = !effectBurst
		. = TRUE


	else if(href_list["effectAnnounce"])
		effectAnnounce = !effectAnnounce
		. = TRUE


	else if(href_list["effectReverse"])
		temp_pod.reversing = !temp_pod.reversing
		. = TRUE


	else if(href_list["effectTarget"])
		if(specificTarget)
			specificTarget = null
			. = TRUE
			return
		var/list/mobs = sortmobs()
		var/inputTarget = input("Select a mob!", "Target", null, null) as null|anything in mobs
		if(isnull(inputTarget))
			return
		var/mob/target = mobs[inputTarget]
		specificTarget = target
		. = TRUE


	else if(href_list["fallDuration"])
		if(temp_pod.fallDuration != initial(temp_pod.fallDuration))
			temp_pod.fallDuration = initial(temp_pod.fallDuration)
			. = TRUE
			return
		var/timeInput = input("Enter the duration of the pod's falling animation, in seconds", "Delay Time",  initial(temp_pod.fallDuration) * 0.1) as null|num
		if(isnull(timeInput))
			return
		if(!isnum(timeInput))
			to_chat(holder, "<span class='warning'>That wasn't a number! Value set to default [initial(temp_pod.fallDuration) * 0.1] instead.</span>")
			timeInput = initial(temp_pod.fallDuration)
		temp_pod.fallDuration = 10 * timeInput
		. = TRUE


	else if(href_list["landingDelay"])
		if(temp_pod.landingDelay != initial(temp_pod.landingDelay))
			temp_pod.landingDelay = initial(temp_pod.landingDelay)
			. = TRUE
			return
		var/timeInput = input("Enter the time it takes for the pod to land, in seconds", "Delay Time", initial(temp_pod.landingDelay) * 0.1) as null|num
		if(isnull(timeInput))
			return
		if(!isnum(timeInput))
			to_chat(holder, "<span class='warning'>That wasnt a number! Value set to default [initial(temp_pod.landingDelay) * 0.1] instead.</span>")
			timeInput = initial(temp_pod.landingDelay)
		temp_pod.landingDelay = 10 * timeInput
		. = TRUE


	else if(href_list["openingDelay"])
		if(temp_pod.openingDelay != initial(temp_pod.openingDelay))
			temp_pod.openingDelay = initial(temp_pod.openingDelay)
			. = TRUE
			return
		var/timeInput = input("Enter the time it takes for the pod to open after landing, in seconds", "Delay Time", initial(temp_pod.openingDelay) * 0.1) as null|num
		if(isnull(timeInput))
			return
		if(!isnum(timeInput))
			to_chat(holder, "<span class='warning'>That wasnt a number! Value set to default [initial(temp_pod.openingDelay) * 0.1] instead.</span>")
			timeInput = initial(temp_pod.openingDelay)
		temp_pod.openingDelay = 10 *  timeInput
		. = TRUE


	else if(href_list["departureDelay"])
		if(temp_pod.departureDelay != initial(temp_pod.departureDelay))
			temp_pod.departureDelay = initial(temp_pod.departureDelay)
			. = TRUE
			return
		var/timeInput = input("Enter the time it takes for the pod to leave after opening, in seconds", "Delay Time", initial(temp_pod.departureDelay) * 0.1) as null|num
		if(isnull(timeInput))
			return
		if(!isnum(timeInput))
			to_chat(holder, "<span class='warning'>That wasnt a number! Value set to default [initial(temp_pod.departureDelay) * 0.1] instead.</span>")
			timeInput = initial(temp_pod.departureDelay)
		temp_pod.departureDelay = 10 * timeInput
		. = TRUE


	else if(href_list["fallingSound"])
		if((temp_pod.fallingSound) != initial(temp_pod.fallingSound))
			temp_pod.fallingSound = initial(temp_pod.fallingSound)
			temp_pod.fallingSoundLength = initial(temp_pod.fallingSoundLength)
			. = TRUE
			return
		var/soundInput = input(holder, "Please pick a sound file to play when the pod lands.", "Pick a Sound File") as null|sound
		if(isnull(soundInput))
			return
		var/timeInput =  input(holder, "What is the exact length of the sound file, in seconds?", "Pick a Sound File", 0.3) as null|num
		if(isnull(timeInput))
			return
		if(!isnum(timeInput))
			to_chat(holder, "<span class='warning'>That wasnt a number! Value set to default [initial(temp_pod.fallingSoundLength) * 0.1] instead.</span>")
		temp_pod.fallingSound = soundInput
		temp_pod.fallingSoundLength = 10 * timeInput
		. = TRUE


	else if(href_list["landingSound"])
		if(!isnull(temp_pod.landingSound))
			temp_pod.landingSound = null
			. = TRUE
			return
		var/soundInput = input(holder, "Please pick a sound file to play when the pod lands! I reccomend a nice \"oh shit, i'm sorry\", incase you hit someone with the pod.", "Pick a Sound File") as null|sound
		if(isnull(soundInput))
			return
		temp_pod.landingSound = soundInput
		. = TRUE


	else if(href_list["openingSound"])
		if(!isnull(temp_pod.openingSound))
			temp_pod.openingSound = null
			. = TRUE
			return
		var/soundInput = input(holder, "Please pick a sound file to play when the pod opens! I reccomend a stock sound effect of kids cheering at a party, incase your pod is full of fun exciting stuff!", "Pick a Sound File") as null|sound
		if(isnull(soundInput))
			return
		temp_pod.openingSound = soundInput
		. = TRUE


	else if(href_list["leavingSound"])
		if(!isnull(temp_pod.leavingSound))
			temp_pod.leavingSound = null
			. = TRUE
			return
		var/soundInput = input(holder, "Please pick a sound file to play when the pod leaves! I reccomend a nice slide whistle sound, especially if you're using the reverse pod effect.", "Pick a Sound File") as null|sound
		if(isnull(soundInput))
			return
		temp_pod.leavingSound = soundInput
		. = TRUE


	else if(href_list["soundVolume"])
		if(temp_pod.soundVolume != initial(temp_pod.soundVolume))
			temp_pod.soundVolume = initial(temp_pod.soundVolume)
			. = TRUE
			return
		var/soundInput = input(holder, "Please pick a volume level between 1 and 100.", "Pick Admin Sound Volume") as null|num
		if(isnull(soundInput))
			return
		temp_pod.soundVolume = soundInput
		. = TRUE


	else if(href_list["styleStandard"])
		temp_pod.setStyle(STYLE_STANDARD)
		. = TRUE


	else if(href_list["styleBluespace"])
		temp_pod.setStyle(STYLE_BLUESPACE)
		. = TRUE


	else if(href_list["styleSyndie"])
		temp_pod.setStyle(STYLE_SYNDICATE)
		. = TRUE


	else if(href_list["styleBlue"])
		temp_pod.setStyle(STYLE_BLUE)
		. = TRUE


	else if(href_list["styleCult"])
		temp_pod.setStyle(STYLE_CULT)
		. = TRUE


	else if(href_list["styleMissile"])
		temp_pod.setStyle(STYLE_MISSILE)
		. = TRUE


	else if(href_list["styleSMissile"])
		temp_pod.setStyle(STYLE_RED_MISSILE)
		. = TRUE


	else if(href_list["styleBox"])
		temp_pod.setStyle(STYLE_BOX)
		. = TRUE


	else if(href_list["styleHONK"])
		temp_pod.setStyle(STYLE_HONK)
		. = TRUE


	else if(href_list["styleFruit"])
		temp_pod.setStyle(STYLE_FRUIT)
		. = TRUE


	else if(href_list["styleInvisible"])
		temp_pod.setStyle(STYLE_INVISIBLE)
		. = TRUE


	else if(href_list["styleGondola"])
		temp_pod.setStyle(STYLE_GONDOLA)
		. = TRUE


	else if(href_list["styleSeeThrough"])
		temp_pod.setStyle(STYLE_SEETHROUGH)
		. = TRUE


	else if(href_list["refresh"])
		refreshBay()
		. = TRUE


	else if(href_list["giveLauncher"])
		launcherActivated = !launcherActivated
		updateCursor(launcherActivated)
		. = TRUE


	else if(href_list["clearBay"])
		if(alert(usr, "This will delete all objs and mobs in [bay]. Are you sure?", "Confirmation", "Yes", "No") != "Yes")
			return

		clearBay()
		refreshBay()
		. = TRUE


/datum/podlauncher/proc/on_set_interaction()
	return

			
/datum/podlauncher/proc/on_unset_interaction()
	qdel(src)


/datum/podlauncher/proc/updateCursor(launching)
	if(holder)
		if(launching)
			holder.mouse_up_icon = 'icons/effects/supplypod_target.dmi'
			holder.mouse_down_icon = 'icons/effects/supplypod_down_target.dmi'
			holder.mouse_pointer_icon = holder.mouse_up_icon
			holder.click_intercept = src
		else
			holder.mouse_up_icon = null
			holder.mouse_down_icon = null
			holder.click_intercept = null
			holder.mouse_pointer_icon = initial(holder.mouse_pointer_icon)


/datum/podlauncher/InterceptClickOn(user, params, atom/target)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	if(launcherActivated)
		if(istype(target,/obj/screen))
			return FALSE

		. = TRUE

		if(left_click)
			preLaunch()
			if(!isnull(specificTarget))
				target = get_turf(specificTarget)
			else if(target)
				target = get_turf(target)
			else
				return
			//if(effectAnnounce)
			//	deadchat_broadcast("<span class='deadsay'>A special package is being launched at the station!</span>", turf_target = target)
			var/list/targets = list()
			for(var/mob/living/M in viewers(0, target))
				targets.Add(M)
			supplypod_log(targets, target)
			if(!effectBurst)
				launch(target)
			else
				for(var/i in 1 to 5)
					if(isnull(target))
						break
					preLaunch()
					var/LZ = locate(target.x + rand(-1, 1), target.y + rand(-1, 1), target.z)
					if(LZ)
						launch(LZ)
					else
						launch(target)
					sleep(rand() * 2)


/datum/podlauncher/proc/refreshBay()
	orderedArea = createOrderedArea(bay)
	preLaunch()


/datum/podlauncher/proc/createPod(area/A)
	if(isnull(A))
		to_chat(holder.mob, "<span class='warning'>No /area/centcom/supplypod/podStorage in the world! You can make one yourself if necessary.</span>")
		return

	temp_pod = new(A)


/datum/podlauncher/proc/createOrderedArea(area/A)
	if(isnull(A))
		to_chat(holder.mob, "<span class='warning'>No /area/centcom/supplypod/loading/ in the world! You can make one yourself if necessary.</span>")
		return

	orderedArea = list()
	if(!isemptylist(A.contents))
		var/startX = A.contents[1].x
		var/endX = A.contents[1].x
		var/startY = A.contents[1].y
		var/endY = A.contents[1].y
		for(var/turf/T in A)
			if(T.x < startX)
				startX = T.x
			else if(T.x > endX)
				endX = T.x
			else if(T.y > startY)
				startY = T.y
			else if(T.y < endY)
				endY = T.y
		for(var/i in endY to startY)
			for(var/j in startX to endX)
				orderedArea.Add(locate(j, startY - (i - endY), 1))
	return orderedArea


/datum/podlauncher/proc/preLaunch()
	numTurfs = 0
	acceptableTurfs = list()
	for(var/turf/T in orderedArea)
		if(length(typecache_filter_list_reverse(T.contents, ignored_atoms)))
			acceptableTurfs.Add(T)
			numTurfs ++

	launchList = list()
	if(!isemptylist(acceptableTurfs) && !temp_pod.reversing && !temp_pod.effectMissile)
		switch(launchChoice)
			if(0)
				for(var/turf/T in acceptableTurfs)
					launchList |= typecache_filter_list_reverse(T.contents, ignored_atoms)
			if(1)
				if(launchCounter > length(acceptableTurfs))
					launchCounter = 1
				for(var/atom/movable/O in acceptableTurfs[launchCounter].contents)
					launchList |= typecache_filter_list_reverse(acceptableTurfs[launchCounter].contents, ignored_atoms)
			if(2)
				launchList |= typecache_filter_list_reverse(pick_n_take(acceptableTurfs).contents, ignored_atoms)
	updateSelector()


/datum/podlauncher/proc/launch(turf/A)
	if(isnull(A))
		return
	var/obj/structure/closet/supplypod/centcompod/toLaunch = DuplicateObject(temp_pod, temp_pod.loc)
	toLaunch.bay = bay
	toLaunch.update_icon()
	var/shippingLane = GLOB.areas_by_type[/area/centcom/supplypod/flyMeToTheMoon]
	toLaunch.forceMove(shippingLane)
	if(launchClone)
		for(var/atom/movable/O in launchList)
			DuplicateObject(O, toLaunch)
		new /obj/effect/DPtarget(A, toLaunch)
	else
		for(var/atom/movable/O in launchList)
			O.forceMove(toLaunch)
		new /obj/effect/DPtarget(A, toLaunch)
	if(launchClone)
		launchCounter++


/datum/podlauncher/proc/updateSelector()
	if(launchChoice == 1 && !isemptylist(acceptableTurfs) && !temp_pod.reversing && !temp_pod.effectMissile)
		var/index = launchCounter + 1
		if(index > length(acceptableTurfs))
			index = 1
		selector.forceMove(acceptableTurfs[index])
	else
		selector.moveToNullspace()


/datum/podlauncher/proc/clearBay()
	for(var/obj/O in bay.GetAllContents())
		qdel(O)
	for(var/mob/M in bay.GetAllContents())
		qdel(M)


/datum/podlauncher/proc/supplypod_log(list/targets, atom/target)
	var/podString = effectBurst ? "5 pods" : "a pod"
	var/whomString = ""
	for(var/i in targets)
		var/mob/M = i
		whomString += "[key_name(M)], "

	var/delayString = temp_pod.landingDelay == initial(temp_pod.landingDelay) ? "" : " Delay=[temp_pod.landingDelay*0.1]s"
	var/damageString = temp_pod.damage == 0 ? "" : " Dmg=[temp_pod.damage]"
	var/explosionString = ""
	var/playerString = specificTarget ? "Target=[ADMIN_TPMONTY(specificTarget)]" : ""
	var/explosion_sum = temp_pod.explosionSize[1] + temp_pod.explosionSize[2] + temp_pod.explosionSize[3] + temp_pod.explosionSize[4]
	var/areaString = "[ADMIN_VERBOSEJMP(target)]"
	if(explosion_sum != 0)
		explosionString = " Boom=|"
		for(var/X in temp_pod.explosionSize)
			explosionString += "[X]|"

	var/msg = "launched [podString][whomString][delayString][damageString][explosionString][playerString][areaString]."
	log_admin("[key_name(usr)] [msg]")
	message_admins("[ADMIN_TPMONTY(usr)] [msg]")
	for(var/i in targets)
		var/mob/M = i
		admin_ticket_log(M, "[key_name_admin(usr)] [msg]")