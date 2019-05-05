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
	var/list/xenos_by_upgrade
	var/list/dead_xenos // xenos that are still assigned to this hive but are dead.

// ***************************************
// *********** Init
// ***************************************
/datum/hive_status/New()
	. = ..()
	xeno_leader_list = list()
	xenos_by_typepath = list()
	xenos_by_tier = list()
	xenos_by_upgrade = list()
	dead_xenos = list()

	for(var/t in subtypesof(/mob/living/carbon/Xenomorph))
		var/mob/living/carbon/Xenomorph/X = t
		xenos_by_typepath[initial(X.caste_base_type)] = list()

	for(var/tier in GLOB.xenotiers)
		xenos_by_tier[tier] = list()

	for(var/upgrade in GLOB.xenoupgradetiers)
		xenos_by_upgrade[upgrade] = list()

// ***************************************
// *********** Helpers
// ***************************************
/datum/hive_status/proc/get_total_xeno_number() // unsafe for use by gamemode code
	. = 0
	for(var/t in xenos_by_tier)
		. += length(xenos_by_tier[t])

/datum/hive_status/proc/post_add(mob/living/carbon/Xenomorph/X)
	X.color = color

/datum/hive_status/proc/post_removal(mob/living/carbon/Xenomorph/X)
	X.color = null

// for clean transfers between hives
/mob/living/carbon/Xenomorph/proc/transfer_to_hive(hivenumber)
	if(!GLOB.hive_datums[hivenumber])
		CRASH("invalid hivenumber passed to transfer_to_hive")

	var/datum/hive_status/HS = GLOB.hive_datums[hivenumber]
	if(hivenumber != XENO_HIVE_NONE)
		remove_from_hive()

	add_to_hive(HS)

// ***************************************
// *********** List getters
// ***************************************
/datum/hive_status/proc/get_all_xenos(queen = TRUE)
	var/list/xenos = list()
	for(var/typepath in xenos_by_typepath)
		if(!queen && typepath == /mob/living/carbon/Xenomorph/Queen) // hardcoded check for now
			continue
		xenos += xenos_by_typepath[typepath]
	return xenos

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

/datum/hive_status/proc/get_ssd_xenos(only_away=FALSE)
	var/list/xenos = list()
	for(var/typepath in xenos_by_typepath)
		for(var/i in xenos_by_typepath[typepath])
			var/mob/living/carbon/Xenomorph/X = i
			if(is_centcom_level(X.z))
				continue
			if(X.client)
				continue
			if(!X.away_time) //To prevent adminghosted xenos to be snatched.
				continue
			if(only_away && world.time - X.away_time < XENO_AFK_TIMER)
				continue
			xenos += X
	return xenos

// ***************************************
// *********** Adding xenos
// ***************************************
/datum/hive_status/proc/add_xeno(mob/living/carbon/Xenomorph/X) // should only be called by add_to_hive below
	if(X.stat == DEAD)
		dead_xenos += X
	else
		add_to_lists(X)

	post_add(X)
	return TRUE

// helper function
/datum/hive_status/proc/add_to_lists(mob/living/carbon/Xenomorph/X)
	xenos_by_tier[X.tier] += X
	xenos_by_upgrade[X.upgrade] += X

	if(!xenos_by_typepath[X.caste_base_type])
		stack_trace("trying to add an invalid typepath into hivestatus list [X.caste_base_type]")
		return FALSE

	xenos_by_typepath[X.caste_base_type] += X

	return TRUE

/mob/living/carbon/Xenomorph/proc/add_to_hive(datum/hive_status/HS, force=FALSE)
	if(!force && hivenumber != XENO_HIVE_NONE)
		CRASH("trying to do a dirty add_to_hive")

	if(!istype(HS))
		CRASH("invalid hive_status passed to add_to_hive()")

	if(!HS.add_xeno(src))
		CRASH("failed to add xeno to a hive")

	hive = HS
	hivenumber = HS.hivenumber // just to be sure
	generate_name()

	SSdirection.start_tracking(HS.hivenumber, src)

/mob/living/carbon/Xenomorph/Queen/add_to_hive(datum/hive_status/HS, force=FALSE) // override to ensure proper queen/hive behaviour
	. = ..()
	HS.update_queen()

	if(HS.living_xeno_queen) // theres already a queen
		return

	HS.set_queen(src)

/mob/living/carbon/Xenomorph/proc/add_to_hive_by_hivenumber(hivenumber, force=FALSE) // helper function to add by given hivenumber
	if(!GLOB.hive_datums[hivenumber])
		CRASH("add_to_hive_by_hivenumber called with invalid hivenumber")
	var/datum/hive_status/HS = GLOB.hive_datums[hivenumber]
	add_to_hive(HS, force)

// This is a special proc called only when a xeno is first created to set their hive and name properly
/mob/living/carbon/Xenomorph/proc/set_initial_hivenumber()
	add_to_hive_by_hivenumber(hivenumber, force=TRUE)

// ***************************************
// *********** Removing xenos
// ***************************************
/datum/hive_status/proc/remove_xeno(mob/living/carbon/Xenomorph/X) // should only be called by remove_from_hive
	if(X.stat == DEAD)
		if(!dead_xenos.Remove(X))
			stack_trace("failed to remove a dead xeno from hive status dead list, nothing was removed!?")
			return FALSE
	else
		remove_from_lists(X)

	post_removal(X)
	return TRUE

// helper function
/datum/hive_status/proc/remove_from_lists(mob/living/carbon/Xenomorph/X)
	// Remove() returns 1 if it removes an element from a list
	if(!xenos_by_tier[X.tier].Remove(X))
		stack_trace("failed to remove a xeno from hive status tier list, nothing was removed!?")
		return FALSE

	if(!xenos_by_upgrade[X.upgrade].Remove(X))
		stack_trace("trying to remove a xeno from hivestatus upgrade list, nothing was removed!?")
		return FALSE

	if(!xenos_by_typepath[X.caste_base_type])
		stack_trace("trying to remove an invalid typepath from hivestatus list")
		return FALSE

	if(!xenos_by_typepath[X.caste_base_type].Remove(X))
		stack_trace("failed to remove a xeno from hive status typepath list, nothing was removed!?")
		return FALSE

	remove_leader(X)

	return TRUE

/mob/living/carbon/Xenomorph/proc/remove_from_hive()
	if(!istype(hive))
		CRASH("tried to remove a xeno from a hive that didnt have a hive to be removed from")

	if(!hive.remove_xeno(src))
		CRASH("failed to remove xeno from a hive")

	if(queen_chosen_lead || src in hive.xeno_leader_list)
		hive.remove_leader(src)

	hive = null
	hivenumber = XENO_HIVE_NONE // failsafe value

/mob/living/carbon/Xenomorph/Queen/remove_from_hive() // override to ensure proper queen/hive behaviour
	var/datum/hive_status/HS = hive
	if(HS.living_xeno_queen == src)
		HS.living_xeno_queen = null
	. = ..()
	HS.update_queen()

// ***************************************
// *********** Xeno leaders
// ***************************************
/datum/hive_status/proc/add_leader(mob/living/carbon/Xenomorph/X)
	xeno_leader_list += X
	X.queen_chosen_lead = TRUE

/datum/hive_status/proc/remove_leader(mob/living/carbon/Xenomorph/X)
	xeno_leader_list -= X
	X.queen_chosen_lead = FALSE

/datum/hive_status/proc/update_leader_pheromones() // helper function to easily trigger an update of leader pheromones
	for(var/i in xeno_leader_list)
		var/mob/living/carbon/Xenomorph/X = i
		X.handle_xeno_leader_pheromones(living_xeno_queen)

// ***************************************
// *********** Xeno upgrades
// ***************************************
/datum/hive_status/proc/upgrade_xeno(mob/living/carbon/Xenomorph/X, oldlevel, newlevel) // called by Xenomorph/proc/upgrade_xeno()
	xenos_by_upgrade[oldlevel] -= X
	xenos_by_upgrade[newlevel] += X

// ***************************************
// *********** Xeno death
// ***************************************
/datum/hive_status/proc/on_xeno_death(mob/living/carbon/Xenomorph/X)
	if(living_xeno_queen?.observed_xeno == X)
		living_xeno_queen.set_queen_overwatch(X, TRUE)

	remove_from_lists(X)
	dead_xenos += X

	if(isxenoqueen(X))
		on_queen_death(X)
	return TRUE

/datum/hive_status/proc/on_xeno_revive(mob/living/carbon/Xenomorph/X)
	dead_xenos -= X
	add_to_lists(X)
	return TRUE

// ***************************************
// *********** Queen
// ***************************************

// This proc attempts to find a new queen to lead the hive, if there isnt then it will announce her death
/datum/hive_status/proc/update_queen()
	if(living_xeno_queen)
		return TRUE
	var/announce = TRUE
	if(SSticker.current_state == GAME_STATE_FINISHED || SSticker.current_state == GAME_STATE_SETTING_UP)
		announce = FALSE
	for(var/i in xenos_by_typepath[/mob/living/carbon/Xenomorph/Queen])
		var/mob/living/carbon/Xenomorph/Queen/Q = i
		if(is_centcom_level(Q.z))
			continue
		set_queen(Q)
		if(announce)
			xeno_message("<span class='xenoannounce'>A new Queen has risen to lead the Hive! Rejoice!</span>",3)
		update_leader_pheromones()
		return TRUE
	if(announce)
		xeno_message("<span class='xenoannounce'>A sudden tremor ripples through the hive... the Queen has been slain! Vengeance!</span>",3,TRUE)
		xeno_message("<span class='xenoannounce'>The slashing of hosts is now permitted.</span>",2,TRUE)
	slashing_allowed = XENO_SLASHING_ALLOWED
	update_leader_pheromones()
	start_queen_timer()
	return TRUE

/datum/hive_status/proc/set_queen(mob/living/carbon/Xenomorph/Queen/Q)
	SSdirection.clear_leader(hivenumber)
	if (Q != null)
		SSdirection.set_leader(hivenumber, Q)
	living_xeno_queen = Q


// These are defined for per-hive behaviour
/datum/hive_status/proc/on_queen_death(mob/living/carbon/Xenomorph/Queen/Q)
	if(living_xeno_queen == Q)
		set_queen(null)
	update_queen()
	return TRUE

/datum/hive_status/proc/start_queen_timer()
	return

/mob/living/carbon/Xenomorph/Larva/proc/burrow()
	if(ckey && client)
		return
	hive?.burrow_larva(src)

/datum/hive_status/proc/burrow_larva(mob/living/carbon/Xenomorph/Larva/L)
	return

/datum/hive_status/proc/unbury_all_larva()
	return

/datum/hive_status/proc/on_queen_life(mob/living/carbon/Xenomorph/Queen/Q)
	return

// safe for use by gamemode code, this allows per hive overrides
/datum/hive_status/proc/check_queen_timer()
	if(xeno_queen_timer && --xeno_queen_timer <= 1)
		xeno_message("The Hive is ready for a new Queen to evolve.",3,TRUE)

// ***************************************
// *********** Xeno messaging
// ***************************************
/datum/hive_status/proc/can_xeno_message() // This is defined for per-hive overrides
	return living_xeno_queen

/*

This is for hive-wide announcements like the queen dying

The force parameter is for messages that should ignore a dead queen

to_chat will check for valid clients itself already so no need to double check for clients

*/
/datum/hive_status/proc/xeno_message(message = null, size = 3, force = FALSE)
	if(!force && !can_xeno_message())
		return
	for(var/i in get_all_xenos())
		var/mob/living/carbon/Xenomorph/X = i
		if(X.stat) // dead/crit cant hear
			continue
		to_chat(X, "<span class='xenodanger'><font size=[size]> [message]</font></span>")

// This is to simplify the process of talking in hivemind, this will invoke the receive proc of all xenos in this hive
/datum/hive_status/proc/hive_mind_message(mob/living/carbon/Xenomorph/sender, message)
	for(var/i in get_all_xenos())
		var/mob/living/carbon/Xenomorph/X = i
		X.receive_hivemind_message(sender, message)

// ***************************************
// *********** Normal Xenos
// ***************************************
/datum/hive_status/normal // subtype for easier typechecking and overrides
	var/stored_larva = 0 // this hive has special burrowed larva
	var/last_larva_time = 0

/datum/hive_status/normal/on_queen_death(mob/living/carbon/Xenomorph/Queen/Q)
	if(living_xeno_queen != Q)
		return FALSE

	if(!stored_larva) // no larva to deal with
		return ..()

	stored_larva = round(stored_larva * QUEEN_DEATH_LARVA_MULTIPLIER(Q)

	if(isdistress(SSticker?.mode))
		INVOKE_ASYNC(src, .proc/unbury_all_larva) // this is potentially a lot of calls so do it async

	return ..()

/datum/hive_status/normal/unbury_all_larva()
	var/turf/larva_spawn
	while(stored_larva > 0) // still some left
		larva_spawn = pick(GLOB.xeno_spawn)
		new /mob/living/carbon/Xenomorph/Larva(larva_spawn)
		stored_larva--
		CHECK_TICK // lets not lag everything

/datum/hive_status/normal/start_queen_timer()
	if(!isdistress(SSticker?.mode))
		return
	var/datum/game_mode/distress/D = SSticker.mode

	if(length(xenos_by_typepath[/mob/living/carbon/Xenomorph/Larva]) || length(xenos_by_typepath[/mob/living/carbon/Xenomorph/Drone]))
		D.queen_death_countdown = world.time + QUEEN_DEATH_COUNTDOWN
		addtimer(CALLBACK(D, /datum/game_mode.proc/check_queen_status, queen_time), QUEEN_DEATH_COUNTDOWN)
	else
		D.queen_death_countdown = world.time + QUEEN_DEATH_NOLARVA
		addtimer(CALLBACK(D, /datum/game_mode.proc/check_queen_status, queen_time), QUEEN_DEATH_NOLARVA)

/datum/hive_status/normal/on_queen_life(mob/living/carbon/Xenomorph/Queen/Q)
	if(living_xeno_queen != Q || !is_ground_level(Q.z))
		return
	if(stored_larva && (last_larva_time + 1 MINUTES) < world.time) // every minute
		last_larva_time = world.time
		var/picked = get_alien_candidate()
		if(picked)
			var/mob/living/carbon/Xenomorph/Larva/new_xeno = new /mob/living/carbon/Xenomorph/Larva(Q.loc)
			new_xeno.visible_message("<span class='xenodanger'>A larva suddenly burrows out of the ground!</span>",
			"<span class='xenodanger'>You burrow out of the ground and awaken from your slumber. For the Hive!</span>")
			SEND_SOUND(new_xeno, sound('sound/effects/xeno_newlarva.ogg'))
			new_xeno.key = picked

			if(new_xeno.client)
				new_xeno.client.change_view(world.view)

			to_chat(new_xeno, "<span class='xenoannounce'>You are a xenomorph larva awakened from slumber!</span>")
			SEND_SOUND(new_xeno, sound('sound/effects/xeno_newlarva.ogg'))

			stored_larva--

	for(var/mob/living/carbon/Xenomorph/Larva/L in range(1, Q))
		L.burrow()

/datum/hive_status/normal/burrow_larva(mob/living/carbon/Xenomorph/Larva/L)
	if(!is_ground_level(L.z))
		return
	L.visible_message("<span class='xenodanger'>[L] quickly burrows into the ground.</span>")
	stored_larva++
	round_statistics.total_xenos_created-- // keep stats sane
	qdel(L)

// ***************************************
// *********** Corrupted Xenos
// ***************************************
/datum/hive_status/corrupted
	name = "Corrupted"
	hivenumber = XENO_HIVE_CORRUPTED
	prefix = "Corrupted "
	color = "#00ff80"

// Make sure they can understand english
/datum/hive_status/corrupted/post_add(mob/living/carbon/Xenomorph/X)
	. = ..()
	X.grant_language(/datum/language/common)

/datum/hive_status/corrupted/post_removal(mob/living/carbon/Xenomorph/X)
	. = ..()
	X.remove_language(/datum/language/common)

/datum/hive_status/corrupted/can_xeno_message()
	return TRUE // can always talk in hivemind

/mob/living/carbon/Xenomorph/Queen/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

// ***************************************
// *********** Misc Xenos
// ***************************************
/datum/hive_status/alpha
	name = "Alpha"
	hivenumber = XENO_HIVE_ALPHA
	prefix = "Alpha "
	color = "#cccc00"

/mob/living/carbon/Xenomorph/Queen/Alpha
	hivenumber = XENO_HIVE_ALPHA

/datum/hive_status/beta
	name = "Beta"
	hivenumber = XENO_HIVE_BETA
	prefix = "Beta "
	color = "#9999ff"

/mob/living/carbon/Xenomorph/Queen/Beta
	hivenumber = XENO_HIVE_BETA

/datum/hive_status/zeta
	name = "Zeta"
	hivenumber = XENO_HIVE_ZETA
	prefix = "Zeta "
	color = "#606060"

/mob/living/carbon/Xenomorph/Queen/Zeta
	hivenumber = XENO_HIVE_ZETA

// ***************************************
// *********** Xeno hive compare helpers
// ***************************************

// Everything below can have a hivenumber set and these ensure easy hive comparisons can be made

// atom level because of /obj/item/projectile/var/atom/firer
/atom/proc/issamexenohive(atom/A)
	if(!get_xeno_hivenumber() || !A?.get_xeno_hivenumber())
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
