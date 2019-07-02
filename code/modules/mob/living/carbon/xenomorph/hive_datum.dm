/datum/hive_status
	var/name = "Normal"
	var/hivenumber = XENO_HIVE_NORMAL
	var/mob/living/carbon/xenomorph/queen/living_xeno_queen
	var/mob/living/carbon/xenomorph/living_xeno_ruler
	var/slashing_allowed = XENO_SLASHING_ALLOWED //This initial var allows the queen to turn on or off slashing. Slashing off means harm intent does much less damage.
	var/queen_time = QUEEN_DEATH_TIMER //5 minutes between queen deaths
	var/xeno_queen_timer
	var/xenos_per_queen = 8 //Minimum number of xenos to support a queen.
	var/hive_orders = "" //What orders should the hive have
	var/color = null
	var/prefix = ""
	var/list/xeno_leader_list
	var/list/list/xenos_by_typepath
	var/list/list/xenos_by_tier
	var/list/list/xenos_by_upgrade
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

	for(var/t in subtypesof(/mob/living/carbon/xenomorph))
		var/mob/living/carbon/xenomorph/X = t
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

/datum/hive_status/proc/post_add(mob/living/carbon/xenomorph/X)
	X.color = color

/datum/hive_status/proc/post_removal(mob/living/carbon/xenomorph/X)
	X.color = null

// for clean transfers between hives
/mob/living/carbon/xenomorph/proc/transfer_to_hive(hivenumber)
	if (hive.hivenumber == hivenumber)
		return // If we are in that hive already
	if(!GLOB.hive_datums[hivenumber])
		CRASH("invalid hivenumber passed to transfer_to_hive")

	var/datum/hive_status/HS = GLOB.hive_datums[hivenumber]
	if(hivenumber != XENO_HIVE_NONE)
		remove_from_hive()

	add_to_hive(HS)


/datum/hive_status/proc/can_hive_have_a_queen()
	return get_total_xeno_number() < xenos_per_queen


// ***************************************
// *********** List getters
// ***************************************
/datum/hive_status/proc/get_all_xenos(queen = TRUE)
	var/list/xenos = list()
	for(var/typepath in xenos_by_typepath)
		if(!queen && typepath == /mob/living/carbon/xenomorph/queen) // hardcoded check for now
			continue
		xenos += xenos_by_typepath[typepath]
	return xenos

// doing this by type means we get a pseudo sorted list
/datum/hive_status/proc/get_watchable_xenos()
	var/list/xenos = list()
	for(var/typepath in xenos_by_typepath)
		if(typepath == /mob/living/carbon/xenomorph/queen) // hardcoded check for now
			continue
		for(var/i in xenos_by_typepath[typepath])
			var/mob/living/carbon/xenomorph/X = i
			if(is_centcom_level(X.z))
				continue
			xenos += X
	return xenos

/datum/hive_status/proc/get_ssd_xenos(only_away=FALSE)
	var/list/xenos = list()
	for(var/typepath in xenos_by_typepath)
		for(var/i in xenos_by_typepath[typepath])
			var/mob/living/carbon/xenomorph/X = i
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
/datum/hive_status/proc/add_xeno(mob/living/carbon/xenomorph/X) // should only be called by add_to_hive below
	if(X.stat == DEAD)
		dead_xenos += X
	else
		add_to_lists(X)

	post_add(X)
	return TRUE

// helper function
/datum/hive_status/proc/add_to_lists(mob/living/carbon/xenomorph/X)
	xenos_by_tier[X.tier] += X
	xenos_by_upgrade[X.upgrade] += X

	if(!xenos_by_typepath[X.caste_base_type])
		stack_trace("trying to add an invalid typepath into hivestatus list [X.caste_base_type]")
		return FALSE

	xenos_by_typepath[X.caste_base_type] += X

	return TRUE

/mob/living/carbon/xenomorph/proc/add_to_hive(datum/hive_status/HS, force=FALSE)
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

/mob/living/carbon/xenomorph/queen/add_to_hive(datum/hive_status/HS, force=FALSE) // override to ensure proper queen/hive behaviour
	. = ..()
	if(HS.living_xeno_queen) // theres already a queen
		return

	HS.living_xeno_queen = src

	HS.update_ruler()


/mob/living/carbon/xenomorph/shrike/add_to_hive(datum/hive_status/HS, force = FALSE) // override to ensure proper queen/hive behaviour
	. = ..()

	if(HS.living_xeno_ruler)
		return
	HS.update_ruler()


/mob/living/carbon/xenomorph/proc/add_to_hive_by_hivenumber(hivenumber, force=FALSE) // helper function to add by given hivenumber
	if(!GLOB.hive_datums[hivenumber])
		CRASH("add_to_hive_by_hivenumber called with invalid hivenumber")
	var/datum/hive_status/HS = GLOB.hive_datums[hivenumber]
	add_to_hive(HS, force)

// This is a special proc called only when a xeno is first created to set their hive and name properly
/mob/living/carbon/xenomorph/proc/set_initial_hivenumber()
	add_to_hive_by_hivenumber(hivenumber, force=TRUE)

// ***************************************
// *********** Removing xenos
// ***************************************
/datum/hive_status/proc/remove_xeno(mob/living/carbon/xenomorph/X) // should only be called by remove_from_hive
	if(X.stat == DEAD)
		if(!dead_xenos.Remove(X))
			stack_trace("failed to remove a dead xeno from hive status dead list, nothing was removed!?")
			return FALSE
	else
		remove_from_lists(X)

	post_removal(X)
	return TRUE

// helper function
/datum/hive_status/proc/remove_from_lists(mob/living/carbon/xenomorph/X)
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

/mob/living/carbon/xenomorph/proc/remove_from_hive()
	if(!istype(hive))
		CRASH("tried to remove a xeno from a hive that didnt have a hive to be removed from")

	if(!hive.remove_xeno(src))
		CRASH("failed to remove xeno from a hive")

	if(queen_chosen_lead || src in hive.xeno_leader_list)
		hive.remove_leader(src)

	hive = null
	hivenumber = XENO_HIVE_NONE // failsafe value

/mob/living/carbon/xenomorph/queen/remove_from_hive() // override to ensure proper queen/hive behaviour
	var/datum/hive_status/hive_removed_from = hive
	if(hive_removed_from.living_xeno_queen == src)
		hive_removed_from.living_xeno_queen = null
		
	. = ..()

	if(hive_removed_from.living_xeno_ruler == src)
		hive_removed_from.set_ruler(null)
		hive_removed_from.update_ruler() //Try to find a successor.



/mob/living/carbon/xenomorph/shrike/remove_from_hive()
	var/datum/hive_status/hive_removed_from = hive
		
	. = ..()

	if(hive_removed_from.living_xeno_ruler == src)
		hive_removed_from.set_ruler(null)
		hive_removed_from.update_ruler() //Try to find a successor.


// ***************************************
// *********** Xeno leaders
// ***************************************
/datum/hive_status/proc/add_leader(mob/living/carbon/xenomorph/X)
	xeno_leader_list += X
	X.queen_chosen_lead = TRUE

/datum/hive_status/proc/remove_leader(mob/living/carbon/xenomorph/X)
	xeno_leader_list -= X
	X.queen_chosen_lead = FALSE

/datum/hive_status/proc/update_leader_pheromones() // helper function to easily trigger an update of leader pheromones
	for(var/i in xeno_leader_list)
		var/mob/living/carbon/xenomorph/X = i
		X.handle_xeno_leader_pheromones(living_xeno_queen)

// ***************************************
// *********** Xeno upgrades
// ***************************************
/datum/hive_status/proc/upgrade_xeno(mob/living/carbon/xenomorph/X, oldlevel, newlevel) // called by Xenomorph/proc/upgrade_xeno()
	xenos_by_upgrade[oldlevel] -= X
	xenos_by_upgrade[newlevel] += X

// ***************************************
// *********** Xeno death
// ***************************************
/datum/hive_status/proc/on_xeno_death(mob/living/carbon/xenomorph/X)
	if(living_xeno_queen?.observed_xeno == X)
		living_xeno_queen.set_queen_overwatch(X, TRUE)

	remove_from_lists(X)
	dead_xenos += X

	SEND_SIGNAL(X, COMSIG_HIVE_XENO_DEATH)

	if(X == living_xeno_ruler)
		on_ruler_death(X)

	return TRUE


/datum/hive_status/proc/on_xeno_revive(mob/living/carbon/xenomorph/X)
	dead_xenos -= X
	add_to_lists(X)
	return TRUE


// ***************************************
// *********** Ruler
// ***************************************

/datum/hive_status/proc/on_ruler_death(mob/living/carbon/xenomorph/ruler)
	if(living_xeno_ruler == ruler)
		set_ruler(null)
	var/announce = TRUE
	if(SSticker.current_state == GAME_STATE_FINISHED || SSticker.current_state == GAME_STATE_SETTING_UP)
		announce = FALSE
	if(announce)
		xeno_message("<span class='xenoannounce'>A sudden tremor ripples through the hive... \the [ruler] has been slain! Vengeance!</span>", 3, TRUE)
	if(slashing_allowed != XENO_SLASHING_ALLOWED)
		if(announce)
			xeno_message("<span class='xenoannounce'>The slashing of hosts is now permitted.</span>", 2, TRUE)
		slashing_allowed = XENO_SLASHING_ALLOWED
	notify_ghosts("\The <b>[ruler]</b> has been slain!", source = ruler, action = NOTIFY_JUMP)
	update_ruler()
	return TRUE


// This proc attempts to find a new ruler to lead the hive.
/datum/hive_status/proc/update_ruler()
	if(living_xeno_ruler)
		return TRUE //No succession required.

	var/mob/living/carbon/xenomorph/successor

	var/list/candidates = xenos_by_typepath[/mob/living/carbon/xenomorph/queen]
	if(length(candidates)) //Priority to the queens.
		successor = candidates[1] //First come, first serve.
	else
		candidates = xenos_by_typepath[/mob/living/carbon/xenomorph/shrike]
		if(length(candidates))
			successor = candidates[1]

	var/announce = TRUE
	if(SSticker.current_state == GAME_STATE_FINISHED || SSticker.current_state == GAME_STATE_SETTING_UP)
		announce = FALSE

	set_ruler(successor)

	if(!living_xeno_ruler) //Succession failed.
		start_ruler_timer()
		return TRUE

	if(announce)
		xeno_message("<span class='xenoannounce'>\A [successor] has risen to lead the Hive! Rejoice!</span>", 3)
		notify_ghosts("\The [successor] has risen to lead the Hive!", source = successor, action = NOTIFY_ORBIT)


/datum/hive_status/proc/set_ruler(mob/living/carbon/xenomorph/successor)
	SSdirection.clear_leader(hivenumber)
	if(!isnull(successor))
		SSdirection.set_leader(hivenumber, successor)
		SEND_SIGNAL(successor, COMSIG_HIVE_BECOME_RULER)
	living_xeno_ruler = successor


/mob/living/carbon/xenomorph/queen/proc/on_becoming_ruler()
	hive.update_leader_pheromones()


/datum/hive_status/proc/start_ruler_timer()
	return


// safe for use by gamemode code, this allows per hive overrides
/datum/hive_status/proc/check_queen_timer()
	if(xeno_queen_timer && --xeno_queen_timer <= 1)
		xeno_message("The Hive is ready for a new ruler to evolve.", 3, TRUE)


// ***************************************
// *********** Queen
// ***************************************

// These are defined for per-hive behaviour
/datum/hive_status/proc/on_queen_death(mob/living/carbon/xenomorph/queen/Q)
	if(living_xeno_queen != Q)
		return FALSE
	living_xeno_queen = null

/mob/living/carbon/xenomorph/larva/proc/burrow()
	if(ckey && client)
		return
	hive?.burrow_larva(src)

/datum/hive_status/proc/burrow_larva(mob/living/carbon/xenomorph/larva/L)
	return

/datum/hive_status/proc/unbury_all_larva()
	return

/datum/hive_status/proc/on_queen_life(mob/living/carbon/xenomorph/queen/Q)
	return


// ***************************************
// *********** Xeno messaging
// ***************************************
/datum/hive_status/proc/can_xeno_message() // This is defined for per-hive overrides
	return living_xeno_ruler

/*

This is for hive-wide announcements like the queen dying

The force parameter is for messages that should ignore a dead queen

to_chat will check for valid clients itself already so no need to double check for clients

*/
/datum/hive_status/proc/xeno_message(message = null, size = 3, force = FALSE)
	if(!force && !can_xeno_message())
		return
	for(var/i in get_all_xenos())
		var/mob/living/carbon/xenomorph/X = i
		if(X.stat) // dead/crit cant hear
			continue
		to_chat(X, "<span class='xenodanger'><font size=[size]> [message]</font></span>")

// This is to simplify the process of talking in hivemind, this will invoke the receive proc of all xenos in this hive
/datum/hive_status/proc/hive_mind_message(mob/living/carbon/xenomorph/sender, message)
	for(var/i in get_all_xenos())
		var/mob/living/carbon/xenomorph/X = i
		X.receive_hivemind_message(sender, message)

// ***************************************
// *********** Normal Xenos
// ***************************************
/datum/hive_status/normal // subtype for easier typechecking and overrides
	var/stored_larva = 0 // this hive has special burrowed larva
	var/last_larva_time = 0

/datum/hive_status/normal/on_queen_death(mob/living/carbon/xenomorph/queen/Q)
	if(living_xeno_queen != Q)
		return FALSE

	if(!stored_larva) // no larva to deal with
		return ..()

	stored_larva = round(stored_larva * QUEEN_DEATH_LARVA_MULTIPLIER(Q))

	if(isdistress(SSticker?.mode))
		INVOKE_ASYNC(src, .proc/unbury_all_larva) // this is potentially a lot of calls so do it async

	return ..()

/datum/hive_status/normal/unbury_all_larva()
	var/turf/larva_spawn
	while(stored_larva > 0) // still some left
		larva_spawn = pick(GLOB.xeno_spawn)
		new /mob/living/carbon/xenomorph/larva(larva_spawn)
		stored_larva--
		CHECK_TICK // lets not lag everything

/datum/hive_status/normal/start_ruler_timer()
	if(!isdistress(SSticker?.mode))
		return
	var/datum/game_mode/distress/D = SSticker.mode

	if(length(xenos_by_typepath[/mob/living/carbon/xenomorph/larva]) || length(xenos_by_typepath[/mob/living/carbon/xenomorph/drone]))
		D.queen_death_countdown = world.time + QUEEN_DEATH_COUNTDOWN
		addtimer(CALLBACK(D, /datum/game_mode.proc/check_queen_status, queen_time), QUEEN_DEATH_COUNTDOWN)
	else
		D.queen_death_countdown = world.time + QUEEN_DEATH_NOLARVA
		addtimer(CALLBACK(D, /datum/game_mode.proc/check_queen_status, queen_time), QUEEN_DEATH_NOLARVA)


/datum/hive_status/normal/on_queen_life(mob/living/carbon/xenomorph/queen/Q)
	if(living_xeno_queen != Q || !is_ground_level(Q.z))
		return
	if(stored_larva && (last_larva_time + 1 MINUTES) < world.time) // every minute
		last_larva_time = world.time
		var/mob/picked = get_alien_candidate()
		if(picked)
			var/mob/living/carbon/xenomorph/larva/new_xeno = new /mob/living/carbon/xenomorph/larva(Q.loc)
			new_xeno.visible_message("<span class='xenodanger'>A larva suddenly burrows out of the ground!</span>",
			"<span class='xenodanger'>We burrow out of the ground and awaken from our slumber. For the Hive!</span>")
			SEND_SOUND(new_xeno, sound('sound/effects/xeno_newlarva.ogg'))
			picked.mind.transfer_to(new_xeno, TRUE)

			to_chat(new_xeno, "<span class='xenoannounce'>We are a xenomorph larva awakened from slumber!</span>")
			SEND_SOUND(new_xeno, sound('sound/effects/xeno_newlarva.ogg'))

			stored_larva--

	for(var/mob/living/carbon/xenomorph/larva/L in range(1, Q))
		L.burrow()

/datum/hive_status/normal/burrow_larva(mob/living/carbon/xenomorph/larva/L)
	if(!is_ground_level(L.z))
		return
	L.visible_message("<span class='xenodanger'>[L] quickly burrows into the ground.</span>")
	stored_larva++
	GLOB.round_statistics.total_xenos_created-- // keep stats sane
	qdel(L)


// This proc checks for available mothers and offers a choice if there's more than one.
/datum/hive_status/normal/proc/attempt_to_spawn_larva(mob/xeno_candidate)
	if(!xeno_candidate?.client)
		return FALSE

	if(!stored_larva)
		to_chat(xeno_candidate, "<span class='warning'>There are no burrowed larvas.</span>")
		return FALSE

	var/list/possible_mothers = list()
	SEND_SIGNAL(src, COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, possible_mothers) //List variable passed by reference, and hopefully populated.

	if(!length(possible_mothers))
		to_chat(xeno_candidate, "<span class='warning'>There are no mothers currently available to receive new larvas.</span>")
		return FALSE

	var/mob/living/carbon/xenomorph/chosen_mother = input("Available Mothers") as null|anything in possible_mothers
	if(length(possible_mothers) > 1)
		chosen_mother = input("Available Mothers") as null|anything in (possible_mothers + "Cancel")
	else
		chosen_mother = possible_mothers[1]

	if(chosen_mother == "Cancel" || QDELETED(chosen_mother) || !xeno_candidate?.client)
		return FALSE

	if(!isnewplayer(xeno_candidate) && !DEATHTIME_CHECK(xeno_candidate))
		DEATHTIME_MESSAGE(xeno_candidate)
		return FALSE

	return spawn_larva(xeno_candidate, chosen_mother)


/datum/hive_status/normal/proc/spawn_larva(mob/xeno_candidate, mob/living/carbon/xenomorph/mother)
	if(!xeno_candidate?.mind)
		return FALSE

	if(QDELETED(mother) || !istype(mother))
		to_chat(xeno_candidate, "<span class='warning'>Something went awry with mom. Can't spawn at the moment.</span>")
		return FALSE

	if(!stored_larva)
		to_chat(xeno_candidate, "<span class='warning'>There are no longer burrowed larvas available.</span>")
		return FALSE

	var/list/possible_mothers = list()
	SEND_SIGNAL(src, COMSIG_HIVE_XENO_MOTHER_CHECK, possible_mothers) //List variable passed by reference, and hopefully populated.

	if(!(mother in possible_mothers))
		to_chat(xeno_candidate, "<span class='warning'>This mother is not in a state to receive us.</span>")
		return FALSE

	var/mob/living/carbon/xenomorph/larva/new_xeno = new /mob/living/carbon/xenomorph/larva(mother.loc)
	new_xeno.visible_message("<span class='xenodanger'>A larva suddenly burrows out of the ground!</span>",
	"<span class='xenodanger'>We burrow out of the ground and awaken from our slumber. For the Hive!</span>")

	xeno_candidate.mind.transfer_to(new_xeno, TRUE)
	SEND_SOUND(new_xeno, 'sound/effects/xeno_newlarva.ogg')
	to_chat(new_xeno, "<span class='xenoannounce'>We are a xenomorph larva awakened from slumber!</span>")
	stored_larva--

	log_game("[key_name(new_xeno)] has joined as [new_xeno].")
	message_admins("[ADMIN_TPMONTY(new_xeno)] has joined as [new_xeno].")

	return TRUE


// ***************************************
// *********** Corrupted Xenos
// ***************************************
/datum/hive_status/corrupted
	name = "Corrupted"
	hivenumber = XENO_HIVE_CORRUPTED
	prefix = "Corrupted "
	color = "#00ff80"

// Make sure they can understand english
/datum/hive_status/corrupted/post_add(mob/living/carbon/xenomorph/X)
	. = ..()
	X.grant_language(/datum/language/common)

/datum/hive_status/corrupted/post_removal(mob/living/carbon/xenomorph/X)
	. = ..()
	X.remove_language(/datum/language/common)

/datum/hive_status/corrupted/can_xeno_message()
	return TRUE // can always talk in hivemind

/mob/living/carbon/xenomorph/queen/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

// ***************************************
// *********** Misc Xenos
// ***************************************
/datum/hive_status/alpha
	name = "Alpha"
	hivenumber = XENO_HIVE_ALPHA
	prefix = "Alpha "
	color = "#cccc00"

/mob/living/carbon/xenomorph/queen/Alpha
	hivenumber = XENO_HIVE_ALPHA

/datum/hive_status/beta
	name = "Beta"
	hivenumber = XENO_HIVE_BETA
	prefix = "Beta "
	color = "#9999ff"

/mob/living/carbon/xenomorph/queen/Beta
	hivenumber = XENO_HIVE_BETA

/datum/hive_status/zeta
	name = "Zeta"
	hivenumber = XENO_HIVE_ZETA
	prefix = "Zeta "
	color = "#606060"

/mob/living/carbon/xenomorph/queen/Zeta
	hivenumber = XENO_HIVE_ZETA

/datum/hive_status/admeme
	name = "Admeme"
	hivenumber = XENO_HIVE_ADMEME
	prefix = "Admeme "

/mob/living/carbon/xenomorph/queen/admeme
	hivenumber = XENO_HIVE_ADMEME

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

/mob/living/carbon/xenomorph/get_xeno_hivenumber()
	return hivenumber
