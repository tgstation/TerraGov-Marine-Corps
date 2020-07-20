/mob/living/carbon/xenomorph/verb/hive_status()
	set name = "Hive Status"
	set desc = "Check the status of your current hive."
	set category = "Alien"

	check_hive_status(src)


/proc/xeno_status_output(list/xenolist, can_overwatch = FALSE, ignore_leads = TRUE, user)
	var/xenoinfo = ""
	var/leadprefix = (ignore_leads?"":"<b>(-L-)</b>")
	for(var/i in xenolist)
		var/mob/living/carbon/xenomorph/X = i
		if(ignore_leads && X.queen_chosen_lead)
			continue
		if(can_overwatch)
			xenoinfo += "<tr><td>[leadprefix]<a href=?src=\ref[user];watch_xeno_number=[X.nicknumber]>[X.name]</a> "
		else
			xenoinfo += "<tr><td>[leadprefix][X.name] "
		if(!X.client)
			xenoinfo += " <i>(SSD)</i>"
		else if(X.client.prefs.xeno_name && X.client.prefs.xeno_name != "Undefined")
			xenoinfo += "- [X.client.prefs.xeno_name]"

		var/area/A = get_area(X)
		xenoinfo += " <b><font color=green>([A ? A.name : null])</b></td></tr>"

	return xenoinfo

/proc/check_hive_status(mob/user)
	if(!SSticker)
		return
	var/dat = "<br>"

	var/datum/hive_status/hive
	if(isxeno(user))
		var/mob/living/carbon/xenomorph/xeno_user = user
		if(xeno_user.hive)
			hive = xeno_user.hive
	else
		hive = GLOB.hive_datums[XENO_HIVE_NORMAL]

	if(!hive)
		CRASH("couldnt find a hive in check_hive_status")

	var/xenoinfo = ""
	var/can_overwatch = FALSE

	var/tier3counts = ""
	var/tier2counts = ""
	var/tier1counts = ""

	if(isxenoqueen(user))
		can_overwatch = TRUE

	xenoinfo += xeno_status_output(hive.xenos_by_typepath[/mob/living/carbon/xenomorph/queen], FALSE, TRUE)

	xenoinfo += xeno_status_output(hive.xeno_leader_list, can_overwatch, FALSE, user)

	for(var/typepath in hive.xenos_by_typepath)
		var/mob/living/carbon/xenomorph/T = typepath
		var/datum/xeno_caste/XC = GLOB.xeno_caste_datums[typepath][XENO_UPGRADE_BASETYPE]
		if(XC.caste_flags & CASTE_HIDE_IN_STATUS)
			continue

		switch(initial(T.tier))
			if(XENO_TIER_ZERO)
				continue
			if(XENO_TIER_THREE)
				tier3counts += " | [initial(T.name)]s: [length(hive.xenos_by_typepath[typepath])]"
			if(XENO_TIER_TWO)
				tier2counts += " | [initial(T.name)]s: [length(hive.xenos_by_typepath[typepath])]"
			if(XENO_TIER_ONE)
				tier1counts += " | [initial(T.name)]s: [length(hive.xenos_by_typepath[typepath])]"

		xenoinfo += xeno_status_output(hive.xenos_by_typepath[typepath], can_overwatch, TRUE, user)

	xenoinfo += xeno_status_output(hive.xenos_by_typepath[/mob/living/carbon/xenomorph/larva], can_overwatch, TRUE, user)

	var/hivemind_text = length(hive.xenos_by_typepath[/mob/living/carbon/xenomorph/hivemind]) > 0 ? "Active" : "Inactive"

	dat += "<b>Total Living Sisters: [hive.get_total_xeno_number()]</b><BR>"
	dat += "<b>Tier 3: [length(hive.xenos_by_tier[XENO_TIER_THREE])] Sisters</b>[tier3counts]<BR>"
	dat += "<b>Tier 2: [length(hive.xenos_by_tier[XENO_TIER_TWO])] Sisters</b>[tier2counts]<BR>"
	dat += "<b>Tier 1: [length(hive.xenos_by_tier[XENO_TIER_ONE])] Sisters</b>[tier1counts]<BR>"
	dat += "<b>Larvas: [length(hive.xenos_by_typepath[/mob/living/carbon/xenomorph/larva])] Sisters<BR>"
	dat += "<b>Hivemind: [hivemind_text]<BR>"
	if(hive.hivenumber == XENO_HIVE_NORMAL)
		var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
		dat += "<b>Burrowed Larva: [xeno_job.total_positions - xeno_job.current_positions] Sisters<BR>"
	dat += "<table cellspacing=4>"
	dat += xenoinfo
	dat += "</table>"
	var/datum/browser/popup = new(user, "roundstatus", "<div align='center'>Hive Status</div>", 600, 600)
	popup.set_content(dat)
	popup.open(FALSE)


//Send a message to all xenos.
/proc/xeno_message(message = null, size = 3, hivenumber = XENO_HIVE_NORMAL)
	if(!message)
		return

	if(!GLOB.hive_datums[hivenumber])
		CRASH("xeno_message called with invalid hivenumber")

	var/datum/hive_status/HS = GLOB.hive_datums[hivenumber]
	HS.xeno_message(message, size)

/mob/living/carbon/xenomorph/proc/upgrade_possible()
	return (upgrade != XENO_UPGRADE_INVALID && upgrade != XENO_UPGRADE_THREE)

//Adds stuff to your "Status" pane -- Specific castes can have their own, like carrier hugger count
//Those are dealt with in their caste files.
/mob/living/carbon/xenomorph/Stat()
	. = ..()

	if(!statpanel("Game"))
		return

	if(!(xeno_caste.caste_flags & CASTE_EVOLUTION_ALLOWED))
		stat("Evolve Progress:", "(FINISHED)")
	else if(!hive.check_ruler())
		stat("Evolve Progress:", "(HALTED - NO RULER)")
	else
		stat("Evolve Progress:", "[evolution_stored]/[xeno_caste.evolution_threshold]")

	if(upgrade_possible())
		stat("Upgrade Progress:", "[upgrade_stored]/[xeno_caste.upgrade_threshold]")
	else //Upgrade process finished or impossible
		stat("Upgrade Progress:", "(FINISHED)")

	if(xeno_caste.plasma_max > 0)
		stat("Plasma:", "[plasma_stored]/[xeno_caste.plasma_max]")

	if(hivenumber != XENO_HIVE_CORRUPTED)
		if(hive.slashing_allowed == XENO_SLASHING_ALLOWED)
			stat("Slashing of hosts status:", "ALLOWED")
		else if(hive.slashing_allowed == XENO_SLASHING_RESTRICTED)
			stat("Slashing of hosts status:","RESTRICTED")
		else
			stat("Slashing of hosts status:","FORBIDDEN")

	//Very weak <= 1.0, weak <= 2.0, no modifier 2-3, strong <= 3.5, very strong <= 4.5
	var/msg_holder = ""
	if(frenzy_aura)
		switch(frenzy_aura)
			if(-INFINITY to 1.0)
				msg_holder = "Very weak"
			if(1.1 to 2.0)
				msg_holder = "Weak"
			if(2.1 to 2.9)
				msg_holder = "Medium"
			if(3.0 to 3.9)
				msg_holder = "Strong"
			if(4.0 to INFINITY)
				msg_holder = "Very strong"
		stat("Frenzy pheromone strength:", msg_holder)
	if(warding_aura)
		switch(warding_aura)
			if(-INFINITY to 1.0)
				msg_holder = "Very weak"
			if(1.1 to 2.0)
				msg_holder = "Weak"
			if(2.1 to 2.9)
				msg_holder = "Medium"
			if(3.0 to 3.9)
				msg_holder = "Strong"
			if(4.0 to INFINITY)
				msg_holder = "Very strong"
		stat("Warding pheromone strength:", msg_holder)
	if(recovery_aura)
		switch(recovery_aura)
			if(-INFINITY to 1.0)
				msg_holder = "Very weak"
			if(1.1 to 2.0)
				msg_holder = "Weak"
			if(2.1 to 2.9)
				msg_holder = "Medium"
			if(3.0 to 3.9)
				msg_holder = "Strong"
			if(4.0 to INFINITY)
				msg_holder = "Very strong"
		stat("Recovery pheromone strength:", msg_holder)

	switch(hivenumber)
		if(XENO_HIVE_NORMAL)
			if(hive.hive_orders && hive.hive_orders != "")
				stat("Hive Orders:", hive.hive_orders)
			var/countdown = SSticker.mode?.get_hivemind_collapse_countdown()
			if(countdown)
				stat("<b>Orphan hivemind collapse timer:</b>", countdown)
		if(XENO_HIVE_CORRUPTED)
			stat("Hive Orders:","Follow the instructions of our masters")

//A simple handler for checking your state. Used in pretty much all the procs.
/mob/living/carbon/xenomorph/proc/check_state()
	if(incapacitated() || lying_angle || buckled)
		to_chat(src, "<span class='warning'>We cannot do this in our current state.</span>")
		return 0
	return 1

//Checks your plasma levels and gives a handy message.
/mob/living/carbon/xenomorph/proc/check_plasma(value, silent = FALSE)
	if(stat)
		if(!silent)
			to_chat(src, "<span class='warning'>We cannot do this in our current state.</span>")
		return FALSE

	if(value)
		if(plasma_stored < value)
			if(!silent)
				to_chat(src, "<span class='warning'>We do not have enough plasma to do this. We require [value] plasma but have only [plasma_stored] stored.</span>")
			return FALSE
	return TRUE

/mob/living/carbon/xenomorph/proc/use_plasma(value)
	plasma_stored = max(plasma_stored - value, 0)
	update_action_button_icons()

/mob/living/carbon/xenomorph/proc/gain_plasma(value)
	plasma_stored = min(plasma_stored + value, xeno_caste.plasma_max)
	update_action_button_icons()




//Strip all inherent xeno verbs from your caste. Used in evolution.
/mob/living/carbon/xenomorph/proc/remove_inherent_verbs()
	if(inherent_verbs)
		for(var/verb_path in inherent_verbs)
			verbs -= verb_path

//Add all your inherent caste verbs and procs. Used in evolution.
/mob/living/carbon/xenomorph/proc/add_inherent_verbs()
	if(inherent_verbs)
		for(var/verb_path in inherent_verbs)
			verbs |= verb_path


//Adds or removes a delay to movement based on your caste. If speed = 0 then it shouldn't do much.
//Runners are -2, -4 is BLINDLINGLY FAST, +2 is fat-level
/mob/living/carbon/xenomorph/proc/setXenoCasteSpeed(new_speed)
	if(new_speed == 0)
		remove_movespeed_modifier(MOVESPEED_ID_XENO_CASTE_SPEED)
		return
	add_movespeed_modifier(MOVESPEED_ID_XENO_CASTE_SPEED, TRUE, 0, NONE, TRUE, new_speed)


//Stealth handling


/mob/living/carbon/xenomorph/proc/update_progression()
	if(upgrade_possible()) //upgrade possible
		if(client && ckey) // pause for ssd/ghosted
			if(!hive?.living_xeno_ruler || hive.living_xeno_ruler.loc.z == loc.z)
				if(upgrade_stored >= xeno_caste.upgrade_threshold)
					if(health == maxHealth && !incapacitated() && !handcuffed)
						upgrade_xeno(upgrade_next())
				else
					// Upgrade is increased based on marine to xeno population taking stored_larva as a modifier.
					var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
					var/stored_larva = xeno_job.total_positions - xeno_job.current_positions
					var/upgrade_points = 1 + (FLOOR(stored_larva / 3, 1))
					upgrade_stored = min(upgrade_stored + upgrade_points, xeno_caste.upgrade_threshold)

/mob/living/carbon/xenomorph/proc/update_evolving()
	if(!client || !ckey) // stop evolve progress for ssd/ghosted xenos
		return
	if(evolution_stored >= xeno_caste.evolution_threshold || !(xeno_caste.caste_flags & CASTE_EVOLUTION_ALLOWED))
		return
	if(!hive.check_ruler())
		return

	// Evolution is increased based on marine to xeno population taking stored_larva as a modifier.
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	var/stored_larva = xeno_job.total_positions - xeno_job.current_positions
	var/evolution_points = 1 + (FLOOR(stored_larva / 3, 1))
	evolution_stored = min(evolution_stored + evolution_points, xeno_caste.evolution_threshold)

	if(evolution_stored == xeno_caste.evolution_threshold)
		to_chat(src, "<span class='xenodanger'>Our carapace crackles and our tendons strengthen. We are ready to evolve!</span>")
		SEND_SOUND(src, sound('sound/effects/xeno_evolveready.ogg'))


/mob/living/carbon/xenomorph/show_inv(mob/user)
	return


//This deals with "throwing" xenos -- ravagers, hunters, and runners in particular. Everyone else defaults to normal
//Pounce, charge both use throw_at, so we need extra code to do stuff rather than just push people aside.
/mob/living/carbon/xenomorph/throw_impact(atom/hit_atom, speed)
	set waitfor = 0

	// TODO: remove charge_type check
	if(!xeno_caste.charge_type || stat || (!throwing && usedPounce)) //No charge type, unconscious or dead, or not throwing but used pounce.
		..() //Do the parent instead.
		return FALSE

	if(isobj(hit_atom)) //Deal with smacking into dense objects. This overwrites normal throw code.
		var/obj/O = hit_atom
		if(!O.density)
			return FALSE//Not a dense object? Doesn't matter then, pass over it.
		if(!O.anchored)
			step(O, dir) //Not anchored? Knock the object back a bit. Ie. canisters.
		SEND_SIGNAL(src, COMSIG_XENO_OBJ_THROW_HIT, O, speed)
		return TRUE

	if(isliving(hit_atom)) //Hit a mob! This overwrites normal throw code.
		if(SEND_SIGNAL(src, COMSIG_XENO_LIVING_THROW_HIT, hit_atom) & COMPONENT_KEEP_THROWING)
			return FALSE
		set_throwing(FALSE) //Resert throwing since something was hit.
		return TRUE
	SEND_SIGNAL(src, COMSIG_XENO_NONE_THROW_HIT)
	set_throwing(FALSE) //Resert throwing since something was hit.
	return ..() //Do the parent otherwise, for turfs.


//Bleuugh

/mob/living/carbon/xenomorph/proc/empty_gut(warning = FALSE, content_cleanup = FALSE)
	if(warning)
		if(LAZYLEN(stomach_contents))
			visible_message("<span class='xenowarning'>\The [src] hurls out the contents of their stomach!</span>", \
			"<span class='xenowarning'>We hurl out the contents of our stomach!</span>", null, 5)
		else
			to_chat(src, "<span class='warning'>There is nothing to regurgitate.</span>")

	for(var/i in stomach_contents)
		do_regurgitate(i)

	if(content_cleanup)
		for(var/x in contents) //Get rid of anything that may be stuck inside us as well
			var/atom/movable/stowaway = x
			stowaway.forceMove(get_turf(src))
			stack_trace("[stowaway] found in [src]'s contents. It shouldn't have ended there.")


/mob/living/carbon/xenomorph/proc/do_devour(mob/living/carbon/prey)
	LAZYADD(stomach_contents, prey)
	prey.Paralyze(12 MINUTES)
	prey.adjust_tinttotal(TINT_BLIND)
	prey.forceMove(src)
	SEND_SIGNAL(prey, COMSIG_CARBON_DEVOURED_BY_XENO)


/mob/living/carbon/xenomorph/proc/do_regurgitate(mob/living/carbon/prey)
	LAZYREMOVE(stomach_contents, prey)
	prey.forceMove(get_turf(src))
	prey.adjust_tinttotal(-TINT_BLIND)
	SEND_SIGNAL(prey, COMSIG_MOVABLE_RELEASED_FROM_STOMACH, src)


/mob/living/carbon/xenomorph/proc/toggle_nightvision(new_lighting_alpha)
	if(!new_lighting_alpha)
		switch(lighting_alpha)
			if(LIGHTING_PLANE_ALPHA_NV_TRAIT)
				new_lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
			if(LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
				new_lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
			if(LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
				new_lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
			else
				new_lighting_alpha = LIGHTING_PLANE_ALPHA_NV_TRAIT

	switch(new_lighting_alpha)
		if(LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE, LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE, LIGHTING_PLANE_ALPHA_INVISIBLE)
			ENABLE_BITFIELD(sight, SEE_MOBS)
			ENABLE_BITFIELD(sight, SEE_OBJS)
			ENABLE_BITFIELD(sight, SEE_TURFS)
		if(LIGHTING_PLANE_ALPHA_NV_TRAIT)
			ENABLE_BITFIELD(sight, SEE_MOBS)
			DISABLE_BITFIELD(sight, SEE_OBJS)
			DISABLE_BITFIELD(sight, SEE_TURFS)

	lighting_alpha = new_lighting_alpha

	update_sight()


/mob/living/carbon/xenomorph/proc/zoom_in(tileoffset = 5, viewsize = 12)
	if(stat || resting)
		if(is_zoomed)
			is_zoomed = 0
			zoom_out()
			return
		return
	if(is_zoomed)
		return
	if(!client)
		return
	zoom_turf = get_turf(src)
	is_zoomed = 1
	client.change_view(VIEW_NUM_TO_STRING(viewsize))
	var/viewoffset = 32 * tileoffset
	switch(dir)
		if(NORTH)
			client.pixel_x = 0
			client.pixel_y = viewoffset
		if(SOUTH)
			client.pixel_x = 0
			client.pixel_y = -viewoffset
		if(EAST)
			client.pixel_x = viewoffset
			client.pixel_y = 0
		if(WEST)
			client.pixel_x = -viewoffset
			client.pixel_y = 0

/mob/living/carbon/xenomorph/proc/zoom_out()
	is_zoomed = 0
	zoom_turf = null
	if(!client)
		return
	client.change_view(WORLD_VIEW)
	client.pixel_x = 0
	client.pixel_y = 0

/mob/living/carbon/xenomorph/drop_held_item()
	if(status_flags & INCORPOREAL)
		return FALSE
	var/obj/item/clothing/mask/facehugger/F = get_active_held_item()
	if(istype(F))
		if(locate(/turf/closed/wall/resin) in loc)
			to_chat(src, "<span class='warning'>We decide not to drop [F] after all.</span>")
			return

	. = ..()


//When the Queen's pheromones are updated, or we add/remove a leader, update leader pheromones
/mob/living/carbon/xenomorph/proc/handle_xeno_leader_pheromones(mob/living/carbon/xenomorph/queen/Q)
	if(QDELETED(Q) || !queen_chosen_lead || !Q.current_aura || Q.loc.z != loc.z) //We are no longer a leader, or the Queen attached to us has dropped from her ovi, disabled her pheromones or even died
		leader_aura_strength = 0
		leader_current_aura = ""
		to_chat(src, "<span class='xenowarning'>Our pheromones wane. The Queen is no longer granting us her pheromones.</span>")
	else
		leader_aura_strength = Q.xeno_caste.aura_strength
		leader_current_aura = Q.current_aura
		to_chat(src, "<span class='xenowarning'>Our pheromones have changed. The Queen has new plans for the Hive.</span>")


/mob/living/carbon/xenomorph/proc/update_spits()
	if(!ammo && length(xeno_caste.spit_types))
		ammo = GLOB.ammo_list[xeno_caste.spit_types[1]]
	if(!ammo || !xeno_caste.spit_types || !xeno_caste.spit_types.len) //Only update xenos with ammo and spit types.
		return
	for(var/i in 1 to xeno_caste.spit_types.len)
		var/datum/ammo/A = GLOB.ammo_list[xeno_caste.spit_types[i]]
		if(ammo.icon_state == A.icon_state)
			ammo = A
			return
	ammo = GLOB.ammo_list[xeno_caste.spit_types[1]] //No matching projectile time; default to first spit type
	return

/mob/living/carbon/xenomorph/proc/handle_decay()
	if(prob(7+(3*tier)+(3*upgrade_as_number()))) // higher level xenos decay faster, higher plasma storage.
		use_plasma(min(rand(1,2), plasma_stored))



// this mess will be fixed by obj damage refactor
/atom/proc/acid_spray_act(mob/living/carbon/xenomorph/X)
	return TRUE

/obj/structure/acid_spray_act(mob/living/carbon/xenomorph/X)
	if(!is_type_in_typecache(src, GLOB.acid_spray_hit))
		return TRUE // normal density flag
	take_damage(45 + SPRAY_STRUCTURE_UPGRADE_BONUS(X), "acid", "acid")
	return TRUE // normal density flag

/obj/structure/razorwire/acid_spray_act(mob/living/carbon/xenomorph/X)
	. = ..()
	return FALSE // not normal density flag

/obj/vehicle/multitile/root/cm_armored/acid_spray_act(mob/living/carbon/xenomorph/X)
	take_damage_type(45 + SPRAY_STRUCTURE_UPGRADE_BONUS(X), "acid", src)
	healthcheck()
	return TRUE

/mob/living/carbon/acid_spray_act(mob/living/carbon/xenomorph/X)
	ExtinguishMob()
	if(isnestedhost(src))
		return

	if(COOLDOWN_CHECK(src, COOLDOWN_ACID))
		return
	COOLDOWN_START(src, COOLDOWN_ACID, 2 SECONDS)

	if(isxenopraetorian(X))
		GLOB.round_statistics.praetorian_spray_direct_hits++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "praetorian_spray_direct_hits")

	var/armor_block = run_armor_check("chest", "acid")
	var/damage = rand(30,40) + SPRAY_MOB_UPGRADE_BONUS(X)
	apply_acid_spray_damage(damage, armor_block)
	to_chat(src, "<span class='xenodanger'>\The [X] showers you in corrosive acid!</span>")

/mob/living/carbon/proc/apply_acid_spray_damage(damage, armor_block)
	apply_damage(damage, BURN, null, armor_block)
	UPDATEHEALTH(src)

/mob/living/carbon/human/apply_acid_spray_damage(damage, armor_block)
	take_overall_damage(0, damage, armor_block)
	UPDATEHEALTH(src)
	emote("scream")
	Paralyze(20)

/mob/living/carbon/xenomorph/acid_spray_act(mob/living/carbon/xenomorph/X)
	ExtinguishMob()

/obj/flamer_fire/acid_spray_act(mob/living/carbon/xenomorph/X)
	Destroy()

// Vent Crawl
/mob/living/carbon/xenomorph/proc/vent_crawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Alien"
	if(!check_state())
		return
	var/pipe = start_ventcrawl()
	if(pipe)
		handle_ventcrawl(pipe)

/mob/living/carbon/xenomorph/proc/xeno_salvage_plasma(atom/A, amount, salvage_delay, max_range)
	if(!isxeno(A) || !check_state() || A == src)
		return

	var/mob/living/carbon/xenomorph/target = A

	if(!isturf(loc))
		to_chat(src, "<span class='warning'>We can't salvage plasma from here!</span>")
		return

	if(plasma_stored >= xeno_caste.plasma_max)
		to_chat(src, "<span class='notice'>Our plasma reserves are already at full capacity and can't hold any more.</span>")
		return

	if(target.stat != DEAD)
		to_chat(src, "<span class='warning'>We can't steal plasma from living sisters, ask for some to a drone or a hivelord instead!</span>")
		return

	if(get_dist(src, target) > max_range)
		to_chat(src, "<span class='warning'>We need to be closer to [target].</span>")
		return

	if(!(target.plasma_stored))
		to_chat(src, "<span class='notice'>[target] doesn't have any plasma left to salvage.</span>")
		return

	to_chat(src, "<span class='notice'>We start salvaging plasma from [target].</span>")

	while(target.plasma_stored && plasma_stored < xeno_caste.plasma_max)
		if(!do_after(src, salvage_delay, TRUE, null, BUSY_ICON_HOSTILE) || !check_state())
			break

		if(!isturf(loc))
			to_chat(src, "<span class='warning'>We can't absorb plasma from here!</span>")
			break

		if(get_dist(src, target) > max_range)
			to_chat(src, "<span class='warning'>We need to be closer to [target].</span>")
			break

		if(stagger)
			to_chat(src, "<span class='xenowarning'>Our muscles fail to respond as we try to shake up the shock!</span>")
			break

		if(target.plasma_stored < amount)
			amount = target.plasma_stored //Just take it all.

		var/absorbed_amount = amount
		target.use_plasma(amount)
		gain_plasma(absorbed_amount)
		to_chat(src, "<span class='xenowarning'>We salvage [absorbed_amount] units of plasma from [target]. We have [plasma_stored]/[xeno_caste.plasma_max] stored now.</span>")
		playsound(src, "alien_drool", 25)



/mob/living/carbon/xenomorph/verb/toggle_xeno_mobhud()
	set name = "Toggle Xeno Status HUD"
	set desc = "Toggles the health and plasma hud appearing above Xenomorphs."
	set category = "Alien"

	xeno_mobhud = !xeno_mobhud
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_XENO_STATUS]
	if(xeno_mobhud)
		H.add_hud_to(src)
	else
		H.remove_hud_from(src)
	to_chat(src, "<span class='notice'>You have [xeno_mobhud ? "enabled" : "disabled"] the Xeno Status HUD.</span>")


/mob/living/carbon/xenomorph/proc/recurring_injection(mob/living/carbon/C, toxin = /datum/reagent/toxin/xeno_neurotoxin, channel_time = XENO_NEURO_CHANNEL_TIME, transfer_amount = XENO_NEURO_AMOUNT_RECURRING, count = 3)
	if(!C?.can_sting() || !toxin)
		return FALSE
	var/datum/reagent/body_tox
	var/i = 1
	do
		face_atom(C)
		if(stagger)
			return FALSE
		body_tox = C.reagents.get_reagent(toxin)
		if(CHECK_BITFIELD(C.status_flags, XENO_HOST) && body_tox && body_tox.volume > body_tox.overdose_threshold)
			to_chat(src, "<span class='warning'>We sense the infected host is saturated with [body_tox.name] and cease our attempt to inoculate it further to preserve the little one inside.</span>")
			return FALSE
		do_attack_animation(C)
		playsound(C, 'sound/effects/spray3.ogg', 15, TRUE)
		playsound(C, "alien_drool", 15, TRUE)
		C.reagents.add_reagent(toxin, transfer_amount)
		if(!body_tox) //Let's check this each time because depending on the metabolization rate it can disappear between stings.
			body_tox = C.reagents.get_reagent(toxin)
		to_chat(C, "<span class='danger'>You feel a tiny prick.</span>")
		to_chat(src, "<span class='xenowarning'>Our stinger injects our victim with [body_tox.name]!</span>")
		if(body_tox.volume > body_tox.overdose_threshold)
			to_chat(src, "<span class='danger'>We sense the host is saturated with [body_tox.name].</span>")
	while(i++ < count && do_after(src, channel_time, TRUE, C, BUSY_ICON_HOSTILE))
	return TRUE


/atom/proc/can_sting()
	return FALSE

/mob/living/carbon/monkey/can_sting()
	if(stat != DEAD)
		return TRUE
	return FALSE

/mob/living/carbon/human/can_sting()
	if(species?.species_flags & IS_SYNTHETIC)
		return FALSE
	if(stat != DEAD)
		return TRUE
	return FALSE

/mob/living/carbon/xenomorph/proc/setup_verbs()
	verbs += /mob/living/proc/lay_down

/mob/living/carbon/xenomorph/hivemind/setup_verbs()
	return

/mob/living/carbon/xenomorph/adjust_sunder(adjustment)
	. = ..()
	if(.)
		return
	sunder = clamp(sunder + adjustment, 0, xeno_caste.sunder_max)

/mob/living/carbon/xenomorph/set_sunder(new_sunder)
	. = ..()
	if(.)
		return
	sunder = clamp(new_sunder, 0, xeno_caste.sunder_max)

/mob/living/carbon/xenomorph/get_sunder()
	. = ..()
	if(.)
		return
	return (sunder * -0.01) + 1
