
GLOBAL_LIST_EMPTY(hive_datums) // init by makeDatumRefLists()

/datum/hive_status
	var/name = "Normal"
	var/hivenumber = XENO_HIVE_NORMAL
	var/mob/living/carbon/Xenomorph/Queen/living_xeno_queen
	var/slashing_allowed = XENO_SLASHING_ALLOWED //This initial var allows the queen to turn on or off slashing. Slashing off means harm intent does much less damage.
	var/queen_time = QUEEN_DEATH_TIMER //5 minutes between queen deaths
	var/xeno_queen_timer
	var/hive_orders = "" //What orders should the hive have
	var/color = null
	var/prefix = ""
	var/list/xeno_leader_list
	var/list/xenos_by_typepath
	var/list/xenos_by_tier

/datum/hive_status/New()
	. = ..()
	xeno_leader_list = list()
	xenos_by_typepath = list()
	xenos_by_tier = list()

	for(var/mob/living/carbon/Xenomorph/X in subtypesof(/mob/living/carbon/Xenomorph))
		xenos_by_typepath[initial(X.caste_base_type)] = list()

	for(var/tier in GLOB.xenotiers)
		xenos_by_tier[tier] = list()

/datum/hive_status/proc/remove_leader(var/mob/living/carbon/Xenomorph/X)
	xeno_leader_list -= X
	X.queen_chosen_lead = FALSE

/datum/hive_status/proc/add_leader(var/mob/living/carbon/Xenomorph/X)
	xeno_leader_list += X
	X.queen_chosen_lead = TRUE

/datum/hive_status/proc/get_total_xeno_number()
	. = 0
	for(var/t in xenos_by_tier)
		. += length(xenos_by_tier[t])

// doing this by type means we get a pseudo sorted list
/datum/hive_status/proc/get_watchable_xenos()
	var/list/xenos = list()
	for(var/typepath in xenos_by_typepath)
		if(typepath == /mob/living/carbon/Xenomorph/Queen) // hardcoded check for now
			continue
		for(var/i in xenos_by_typepath[typepath])
			var/mob/living/carbon/Xenomorph/X = i
			if(is_centcom_level(X.z))
				continue
			xenos += X
	return xenos

/datum/hive_status/proc/update_leader_pheromones()
	for(var/i in xeno_leader_list)
		var/mob/living/carbon/Xenomorph/X = i
		X.handle_xeno_leader_pheromones(living_xeno_queen)

/datum/hive_status/proc/update_queen()
	if(living_xeno_queen)
		return TRUE
	if(length(xenos_by_typepath[/mob/living/carbon/Xenomorph/Queen]))
		for(var/i in xenos_by_typepath[/mob/living/carbon/Xenomorph/Queen])
			var/mob/living/carbon/Xenomorph/Queen/Q = i
			if(is_centcom_level(Q.z))
				continue
			living_xeno_queen = Q
			xeno_message("<span class='xenoannounce'>A new Queen has risen to lead the Hive! Rejoice!</span>",3)
			update_leader_pheromones()
			return TRUE
	xeno_message("<span class='xenoannounce'>A sudden tremor ripples through the hive... the Queen has been slain! Vengeance!</span>",3)
	xeno_message("<span class='xenoannounce'>The slashing of hosts is now permitted.</span>",2)
	slashing_allowed = XENO_SLASHING_ALLOWED
	update_leader_pheromones()
	return TRUE

/datum/hive_status/proc/on_queen_death(mob/living/carbon/Xenomorph/Queen/Q)
	return

/datum/hive_status/proc/can_xeno_message() // override to let corrupted hives still talk
	return living_xeno_queen

// to_chat will check for valid clients itself already so no need to double check for clients
/datum/hive_status/proc/xeno_message(message = null, size = 3)
	if(!can_xeno_message())
		return
	for(var/tier in GLOB.xenotiers)
		for(var/i in xenos_by_tier[tier])
			var/mob/living/carbon/Xenomorph/X = i
			if(X.stat) // dead/crit cant hear
				continue
			to_chat(X, "<span class='xenodanger'><font size=[size]> [message]</font></span>")

/datum/hive_status/proc/hive_mind_message(mob/living/carbon/Xenomorph/sender, message)
	for(var/t in xenos_by_tier)
		for(var/i in xenos_by_tier[t])
			var/mob/living/carbon/Xenomorph/X = i
			X.receive_hivemind_message(sender, message)

/datum/hive_status/proc/post_add(mob/living/carbon/Xenomorph/X)
	X.color = color
	return

/datum/hive_status/proc/post_removal(mob/living/carbon/Xenomorph/X)
	X.color = null
	return

/datum/hive_status/proc/add_xeno(mob/living/carbon/Xenomorph/X)
	xenos_by_tier[X.tier] += X

	if(!xenos_by_typepath[X.caste_base_type])
		stack_trace("trying to add an invalid typepath into hivestatus list")
		return FALSE

	xenos_by_typepath[X.caste_base_type].Add(X)

	post_add(X)
	return TRUE

/datum/hive_status/proc/remove_xeno(var/mob/living/carbon/Xenomorph/X)
	// Remove() returns 1 if it removes an element from a list
	if(!xenos_by_tier[X.tier].Remove(X))
		stack_trace("failed to remove a xeno from hive status tier list, nothing was removed!?")
		return FALSE

	if(!xenos_by_typepath[X.caste_base_type])
		stack_trace("trying to remove an invalid typepath from hivestatus list")
		return FALSE

	if(!xenos_by_typepath[X.caste_base_type].Remove(X))
		stack_trace("failed to remove a xeno from hive status typepath list, nothing was removed!?")
		return FALSE

	post_removal(X)
	return TRUE

/datum/hive_status/proc/unbury_all_larva()
	return

/datum/hive_status/proc/start_queen_timer()
	return

/datum/hive_status/normal

/datum/hive_status/normal/on_queen_death(var/mob/living/carbon/Xenomorph/Queen/Q)
	if(living_xeno_queen != Q)
		return

	if(!SSticker.mode.stored_larva)
		return

	SSticker.mode.stored_larva = round(SSticker.mode.stored_larva * QUEEN_DEATH_LARVA_MULTIPLIER)

	INVOKE_ASYNC(src, .proc/unbury_all_larva) // this is potentially a lot of calls so do it async

/datum/hive_status/normal/unbury_all_larva()
	var/turf/larva_spawn
	while(SSticker.mode.stored_larva > 0) // stil some left
		larva_spawn = pick(GLOB.xeno_spawn)
		new /mob/living/carbon/Xenomorph/Larva(larva_spawn)
		SSticker.mode.stored_larva--
		CHECK_TICK // lets not lag everything

	start_queen_timer() // spawning is done now start it

/datum/hive_status/normal/start_queen_timer()
	if(!SSticker?.mode)
		return
	if(length(xenos_by_typepath[/mob/living/carbon/Xenomorph/Larva]) || length(xenos_by_typepath[/mob/living/carbon/Xenomorph/Drone]))
		SSticker.mode.queen_death_countdown = world.time + QUEEN_DEATH_COUNTDOWN
		addtimer(CALLBACK(SSticker.mode, /datum/game_mode.proc/check_queen_status, queen_time), QUEEN_DEATH_COUNTDOWN)
	else
		SSticker.mode.queen_death_countdown = world.time + QUEEN_DEATH_NOLARVA
		addtimer(CALLBACK(SSticker.mode, /datum/game_mode.proc/check_queen_status, queen_time), QUEEN_DEATH_NOLARVA)

/datum/hive_status/corrupted
	name = "Corrupted"
	hivenumber = XENO_HIVE_CORRUPTED
	prefix = "Corrupted "
	color = "#00ff80"

/datum/hive_status/corrupted/post_add(var/mob/living/carbon/Xenomorph/X)
	. = ..()
	X.add_language("English")

/datum/hive_status/corrupted/post_removal(var/mob/living/carbon/Xenomorph/X)
	. = ..()
	X.remove_language("English")

/datum/hive_status/alpha
	name = "Alpha"
	hivenumber = XENO_HIVE_ALPHA
	prefix = "Alpha "
	color = "#cccc00"

/datum/hive_status/beta
	name = "Beta"
	hivenumber = XENO_HIVE_BETA
	prefix = "Beta "
	color = "#9999ff"

/datum/hive_status/zeta
	name = "Zeta"
	hivenumber = XENO_HIVE_ZETA
	prefix = "Zeta "
	color = "#606060"

/mob/living/carbon/Xenomorph/proc/set_initial_hivenumber()
	add_to_hive_by_hivenumber(hivenumber, force=TRUE)

	if(isxenolarva(src))
		var/mob/living/carbon/Xenomorph/Larva/L = src
		L.update_icons() // larva renaming done differently
	else
		generate_name()

/mob/living/carbon/Xenomorph/proc/add_to_hive_by_hivenumber(var/hivenumber, force=FALSE)
	if(!GLOB.hive_datums[hivenumber])
		CRASH("add_to_hive_by_hivenumber called with invalid hivenumber")
	var/datum/hive_status/HS = GLOB.hive_datums[hivenumber]
	add_to_hive(HS, force)

/mob/living/carbon/Xenomorph/proc/add_to_hive(var/datum/hive_status/HS, force=FALSE)
	if(!force && hivenumber != XENO_HIVE_NONE)
		CRASH("trying to do a dirty add_to_hive")

	if(!istype(HS))
		CRASH("invalid hive_status passed to add_to_hive()")

	if(!HS.add_xeno(src))
		CRASH("failed to add xeno to a hive")

	hive = HS
	hivenumber = HS.hivenumber // just to be sure

/mob/living/carbon/Xenomorph/Queen/add_to_hive(var/datum/hive_status/HS, force=FALSE)
	. = ..()
	if(HS.living_xeno_queen) // theres already a queen
		return
	HS.living_xeno_queen = src
	xeno_message("<span class='xenoannounce'>A new Queen has risen to lead the Hive! Rejoice!</span>",3,HS.hivenumber)

/mob/living/carbon/Xenomorph/proc/remove_from_hive(death=FALSE)
	if(!istype(hive))
		CRASH("tried to remove a xeno from a hive that didnt have a hive to be removed from")

	if(!hive.remove_xeno())
		CRASH("failed to remove xeno from a hive")

	if(queen_chosen_lead || src in hive.xeno_leader_list)
		hive.remove_leader(src)

	hive = null
	if(!death) // dead xenos get removed but if ahealed we want to preserve what hive they were in
		hivenumber = XENO_HIVE_NONE // failsafe value

/mob/living/carbon/Xenomorph/Queen/remove_from_hive(death=FALSE)
	var/datum/hive_status/HS = hive
	if(HS.living_xeno_queen == src)
		HS.living_xeno_queen = null
	. = ..()
	HS.update_queen()

/mob/living/carbon/Xenomorph/proc/transfer_to_hive(var/hivenumber)
	if(!GLOB.hive_datums[hivenumber])
		CRASH("invalid hivenumber passed to transfer_to_hive")

	var/datum/hive_status/HS = GLOB.hive_datums[hivenumber]
	if(hivenumber != XENO_HIVE_NONE)
		remove_from_hive()

	add_to_hive(HS)

// atom level because of /obj/item/projectile/var/atom/firer
/atom/proc/issamexenohive(atom/A)
	if(!get_xeno_hivenumber() || !A.get_xeno_hivenumber())
		return FALSE
	return get_xeno_hivenumber() == A.get_xeno_hivenumber()

/atom/proc/get_xeno_hivenumber()
	return FALSE

/obj/effect/alien/egg/get_xeno_hivenumber()
	return hivenumber

/obj/item/xeno_egg/get_xeno_hivenumber()
	return hivenumber

/obj/item/alien_embryo/get_xeno_hivenumber()
	return hivenumber

/obj/item/clothing/mask/facehugger/get_xeno_hivenumber()
	return hivenumber

/mob/living/carbon/Xenomorph/get_xeno_hivenumber()
	return hivenumber
