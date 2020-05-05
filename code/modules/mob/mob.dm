
/mob/Destroy()//This makes sure that mobs with clients/keys are not just deleted from the game.
	GLOB.mob_list -= src
	GLOB.dead_mob_list -= src
	GLOB.offered_mob_list -= src
	for(var/alert in alerts)
		clear_alert(alert, TRUE)
	if(length(observers))
		for(var/i in observers)
			var/mob/dead/D = i
			D.reset_perspective(null)
	ghostize()
	clear_fullscreens()
	if(mind)
		stack_trace("Found a reference to an undeleted mind in mob/Destroy()")
		mind = null
	if(hud_used)
		QDEL_NULL(hud_used)
	for(var/a in actions)
		var/datum/action/action_to_remove = a
		action_to_remove.remove_action(src)
	return ..()

/mob/Initialize()
	GLOB.mob_list += src
	if(stat == DEAD)
		GLOB.dead_mob_list += src
	set_focus(src)
	prepare_huds()
	. = ..()
	if(islist(skills))
		skills = getSkills(arglist(skills))
	else if(!skills)
		skills = getSkills()
	else if(!istype(skills, /datum/skills))
		stack_trace("Invalid type [skills.type] found in .skills during /mob Initialize()")
	update_config_movespeed()
	update_movespeed(TRUE)


/mob/Stat()
	. = ..()
	if(statpanel("Status"))
		if(GLOB.round_id)
			stat("Round ID:", GLOB.round_id)
		stat("Operation Time:", worldtime2text())
		stat("Current Map:", length(SSmapping.configs) ? SSmapping.configs[GROUND_MAP].map_name : "Loading...")
		stat("Current Ship:", length(SSmapping.configs) ? SSmapping.configs[SHIP_MAP].map_name : "Loading...")

	if(statpanel("Game"))
		if(client)
			stat("Ping:", "[round(client.lastping, 1)]ms (Average: [round(client.avgping, 1)]ms)")
		stat("Time Dilation:", "[round(SStime_track.time_dilation_current,1)]% AVG:([round(SStime_track.time_dilation_avg_fast,1)]%, [round(SStime_track.time_dilation_avg,1)]%, [round(SStime_track.time_dilation_avg_slow,1)]%)")

	if(client?.holder?.rank?.rights)
		if(client.holder.rank.rights & (R_ADMIN|R_DEBUG))
			if(statpanel("MC"))
				stat("CPU:", "[world.cpu]")
				stat("Instances:", "[num2text(length(world.contents), 10)]")
				stat("World Time:", "[world.time]")
				GLOB.stat_entry()
				config.stat_entry()
				GLOB.cameranet.stat_entry()
				stat(null)
				if(Master)
					Master.stat_entry()
				else
					stat("Master Controller:", "ERROR")
				if(Failsafe)
					Failsafe.stat_entry()
				else
					stat("Failsafe Controller:", "ERROR")
				if(Master)
					stat(null)
					for(var/datum/controller/subsystem/SS in Master.subsystems)
						SS.stat_entry()
		if(client.holder.rank.rights & (R_ADMIN|R_MENTOR))
			if(statpanel("Tickets"))
				GLOB.ahelp_tickets.stat_entry()
		if(length(GLOB.sdql2_queries))
			if(statpanel("SDQL2"))
				stat("Access Global SDQL2 List", GLOB.sdql2_vv_statobj)
				for(var/i in GLOB.sdql2_queries)
					var/datum/SDQL2_query/Q = i
					Q.generate_stat()

	if(listed_turf && client)
		if(!TurfAdjacent(listed_turf))
			listed_turf = null
		else
			statpanel(listed_turf.name, null, listed_turf)
			var/list/overrides = list()
			for(var/image/I in client.images)
				if(I.loc && I.loc.loc == listed_turf && I.override)
					overrides += I.loc
			for(var/atom/A in listed_turf)
				if(!A.mouse_opacity)
					continue
				if(A.invisibility > see_invisible)
					continue
				if(length(overrides) && (A in overrides))
					continue
				statpanel(listed_turf.name, null, A)


/mob/proc/prepare_huds()
	hud_list = new
	for(var/hud in hud_possible) //Providing huds.
		hud_list[hud] = image('icons/mob/hud.dmi', src, "")


/mob/proc/show_message(msg, type, alt_msg, alt_type)
	if(!client)
		return

	msg = copytext_char(msg, 1, MAX_MESSAGE_LEN)

	to_chat(src, msg)


/mob/living/show_message(msg, type, alt_msg, alt_type)
	if(!client)
		return

	msg = copytext_char(msg, 1, MAX_MESSAGE_LEN)

	if(type)
		if(type == EMOTE_VISIBLE && eye_blind) //Vision related
			if(!alt_msg)
				return
			else
				msg = alt_msg
				type = alt_type

		if(type == EMOTE_AUDIBLE && isdeaf(src)) //Hearing related
			if(!alt_msg)
				return
			else
				msg = alt_msg
				type = alt_type
				if(type == EMOTE_VISIBLE && eye_blind)
					return

	if(stat == UNCONSCIOUS && type == EMOTE_AUDIBLE)
		to_chat(src, "<i>... You can almost hear something ...</i>")
	else
		to_chat(src, msg)

// Show a message to all player mobs who sees this atom
// Show a message to the src mob (if the src is a mob)
// Use for atoms performing visible actions
// message is output to anyone who can see, e.g. "The [src] does something!"
// self_message (optional) is what the src mob sees e.g. "You do something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
// vision_distance (optional) define how many tiles away the message can be seen.
// ignored_mob (optional) doesn't show any message to a given mob if TRUE.

/atom/proc/visible_message(message, self_message, blind_message, vision_distance, ignored_mob)
	var/turf/T = get_turf(src)
	if(!T)
		return

	var/range = 7
	if(vision_distance)
		range = vision_distance

	for(var/mob/M in get_hearers_in_view(range, src))
		if(!M.client)
			continue
		if(M == ignored_mob)
			continue

		var/msg = message

		if(M == src && self_message) //the src always see the main message or self message
			msg = self_message

		else if(M.see_invisible < invisibility || (T != loc && T != src)) //if src is invisible to us or is inside something (and isn't a turf),
			if(!blind_message) // then people see blind message if there is one, otherwise nothing.
				continue

			msg = blind_message

		M.show_message(msg, EMOTE_VISIBLE, blind_message, EMOTE_AUDIBLE)


// Show a message to all mobs in earshot of this one
// This would be for audible actions by the src mob
// message is the message output to anyone who can hear.
// self_message (optional) is what the src mob hears.
// deaf_message (optional) is what deaf people will see.
// hearing_distance (optional) is the range, how many tiles away the message can be heard.

/mob/audible_message(message, deaf_message, hearing_distance, self_message)
	var/range = 7
	if(hearing_distance)
		range = hearing_distance

	for(var/mob/M in get_hearers_in_view(range, src))
		var/msg = message
		if(self_message && M == src)
			msg = self_message
		M.show_message(msg, EMOTE_AUDIBLE, deaf_message, EMOTE_VISIBLE)


// Show a message to all mobs in earshot of this atom
// Use for objects performing audible actions
// message is the message output to anyone who can hear.
// deaf_message (optional) is what deaf people will see.
// hearing_distance (optional) is the range, how many tiles away the message can be heard.
/atom/proc/audible_message(message, deaf_message, hearing_distance)
	var/range = 7
	if(hearing_distance)
		range = hearing_distance

	for(var/mob/M in get_hearers_in_view(range, src))
		M.show_message(message, EMOTE_AUDIBLE, deaf_message, EMOTE_VISIBLE)


//This proc is called whenever someone clicks an inventory ui slot.
/mob/proc/attack_ui(slot)
	var/obj/item/W = get_active_held_item()
	if(istype(W))
		equip_to_slot_if_possible(W, slot, FALSE) // equiphere

/mob/proc/put_in_any_hand_if_possible(obj/item/W as obj, del_on_fail = FALSE, warning = FALSE, redraw_mob = TRUE)
	if(equip_to_slot_if_possible(W, SLOT_L_HAND, TRUE, del_on_fail, warning, redraw_mob))
		return TRUE
	else if(equip_to_slot_if_possible(W, SLOT_R_HAND, TRUE, del_on_fail, warning, redraw_mob))
		return TRUE
	return FALSE

//This is a SAFE proc. Use this instead of equip_to_splot()!
//set del_on_fail to have it delete W if it fails to equip
//unset redraw_mob to prevent the mob from being redrawn at the end.
/mob/proc/equip_to_slot_if_possible(obj/item/W, slot, ignore_delay = TRUE, del_on_fail = FALSE, warning = TRUE, redraw_mob = TRUE, permanent = FALSE)
	if(!istype(W))
		return FALSE
	if(!W.mob_can_equip(src, slot, warning))
		if(del_on_fail)
			qdel(W)
			return FALSE
		if(warning)
			to_chat(src, "<span class='warning'>You are unable to equip that.</span>")
		return FALSE
	if(W.time_to_equip && !ignore_delay)
		if(!do_after(src, W.time_to_equip, TRUE, W, BUSY_ICON_FRIENDLY))
			to_chat(src, "You stop putting on \the [W]")
			return FALSE
		equip_to_slot(W, slot, redraw_mob) //This proc should not ever fail.
		if(permanent)
			W.flags_item |= NODROP
			//This will unzoom and unwield items -without- triggering lights.
		if(W.zoom)
			W.zoom(src)
		if(CHECK_BITFIELD(W.flags_item, TWOHANDED))
			W.unwield(src)
		return TRUE
	else
		equip_to_slot(W, slot, redraw_mob) //This proc should not ever fail.
		if(permanent)
			W.flags_item |= NODROP
		//This will unzoom and unwield items -without- triggering lights.
		if(W.zoom)
			W.zoom(src)
		if(CHECK_BITFIELD(W.flags_item, TWOHANDED))
			W.unwield(src)
		return TRUE

//This is an UNSAFE proc. It merely handles the actual job of equipping. All the checks on whether you can or can't eqip need to be done before! Use mob_can_equip() for that task.
//In most cases you will want to use equip_to_slot_if_possible()
/mob/proc/equip_to_slot(obj/item/W as obj, slot)
	return

//This is just a commonly used configuration for the equip_to_slot_if_possible() proc, used to equip people when the rounds starts and when events happen and such.
/mob/proc/equip_to_slot_or_del(obj/item/W, slot, permanent = FALSE)
	return equip_to_slot_if_possible(W, slot, TRUE, TRUE, FALSE, FALSE, permanent)


/mob/proc/equip_to_appropriate_slot(obj/item/W, ignore_delay = TRUE)
	if(!istype(W))
		return FALSE

	for(var/slot in SLOT_EQUIP_ORDER)
		if(equip_to_slot_if_possible(W, slot, ignore_delay, FALSE, FALSE, FALSE))
			return TRUE

	return FALSE


/mob/proc/draw_from_slot_if_possible(slot)
	if(!slot)
		return FALSE

	var/obj/item/I = get_item_by_slot(slot)

	if(!I)
		return FALSE

	if(istype(I, /obj/item/storage/belt/gun))
		var/obj/item/storage/belt/gun/B = I
		if(!B.current_gun)
			return FALSE
		var/obj/item/W = B.current_gun
		B.remove_from_storage(W)
		put_in_hands(W)
		return TRUE
	else if(istype(I, /obj/item/clothing/shoes/marine))
		var/obj/item/clothing/shoes/marine/S = I
		if(!S.knife)
			return FALSE
		put_in_hands(S.knife)
		S.knife = null
		S.update_icon()
		return TRUE
	else if(istype(I, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = I
		if(!U.hastie)
			return FALSE
		var/obj/item/clothing/tie/storage/T = U.hastie
		if(!istype(T) || !T.hold)
			return FALSE
		var/obj/item/storage/internal/S = T.hold
		if(!length(S.contents))
			return FALSE
		var/obj/item/W = S.contents[length(S.contents)]
		S.remove_from_storage(W)
		put_in_hands(W)
		return TRUE
	else if(istype(I, /obj/item/clothing/suit/storage))
		var/obj/item/clothing/suit/storage/S = I
		if(!S.pockets)
			return FALSE
		var/obj/item/storage/internal/P = S.pockets
		if(!length(P.contents))
			return FALSE
		var/obj/item/W = P.contents[length(P.contents)]
		P.remove_from_storage(W)
		put_in_hands(W)
		return TRUE
	else if(istype(I, /obj/item/storage))
		var/obj/item/storage/S = I
		if(!length(S.contents))
			return FALSE
		var/obj/item/W = S.contents[length(S.contents)]
		S.remove_from_storage(W)
		put_in_hands(W)
		return TRUE
	else
		temporarilyRemoveItemFromInventory(I)
		put_in_hands(I)
		return TRUE


/mob/proc/show_inv(mob/user)
	user.set_interaction(src)
	var/dat = {"
	<BR><B>Head(Mask):</B> <A href='?src=\ref[src];item=[SLOT_WEAR_MASK]'>[(wear_mask ? wear_mask : "Nothing")]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=[SLOT_L_HAND]'>[(l_hand ? l_hand  : "Nothing")]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=[SLOT_R_HAND]'>[(r_hand ? r_hand : "Nothing")]</A>
	<BR><A href='?src=\ref[src];item=pockets'>Empty Pockets</A>
	<BR><A href='?src=\ref[user];refresh=1'>Refresh</A>
	<BR>"}
	var/datum/browser/popup = new(user, "mob[REF(src)]", "<div align='center'>[src]</div>", 325, 500)
	popup.set_content(dat)
	popup.open()


/mob/vv_get_dropdown()
	. = ..()
	. += "---"
	.["Player Panel"] = "?_src_=vars;[HrefToken()];playerpanel=[REF(src)]"


/client/verb/changes()
	set name = "Changelog"
	set category = "OOC"

	var/datum/asset/changelog = get_asset_datum(/datum/asset/simple/changelog)
	changelog.send(src)
	src << browse('html/changelog.html', "window=changes;size=675x650")
	if(prefs.lastchangelog != GLOB.changelog_hash)
		prefs.lastchangelog = GLOB.changelog_hash
		prefs.save_preferences()
		winset(src, "infowindow.changelog", "font-style=;")

/mob/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["default_language"])
		var/language = text2path(href_list["default_language"])
		var/datum/language_holder/H = get_language_holder()

		if(!H.has_language(language))
			return

		H.selected_default_language = language
		if(isliving(src))
			var/mob/living/L = src
			L.language_menu()


/**
  * Handle the result of a click drag onto this mob
  *
  * For mobs this just shows the inventory
  */
/mob/MouseDrop_T(atom/dropping, atom/user)
	. = ..()
	if(.)
		return
	if(dropping != user && ismob(dropping) && !isxeno(user) && !isxeno(dropping))
		var/mob/dragged = dropping
		dragged.show_inv(user)

/mob/living/carbon/xenomorph/MouseDrop_T(atom/dropping, atom/user)
	return


/mob/living/start_pulling(atom/movable/AM, suppress_message = FALSE)
	if(QDELETED(AM) || QDELETED(usr) || src == AM || !isturf(loc) || !Adjacent(AM))	//if there's no person pulling OR the person is pulling themself OR the object being pulled is inside something: abort!
		return FALSE

	if(!AM.can_be_pulled(src))
		return FALSE

	if(throwing || incapacitated())
		return FALSE

	if(pulling)
		var/pulling_old = pulling
		stop_pulling()
		// Are we pulling the same thing twice? Just stop pulling.
		if(pulling_old == AM)
			return FALSE
	else if(l_hand && r_hand)
		if(!suppress_message)
			to_chat(src, "<span class='warning'>Cannot grab, lacking free hands to do so!</span>")
		return FALSE

	AM.add_fingerprint(src, "pull")

	changeNext_move(CLICK_CD_GRABBING)

	if(AM.pulledby)
		if(!suppress_message)
			AM.visible_message("<span class='danger'>[src] has pulled [AM] from [AM.pulledby]'s grip.</span>",
				"<span class='danger'>[src] has pulled you from [AM.pulledby]'s grip.</span>", null, null, src)
			to_chat(src, "<span class='notice'>You pull [AM] from [AM.pulledby]'s grip!</span>")
		log_combat(AM, AM.pulledby, "pulled from", src)
		AM.pulledby.stop_pulling() //an object can't be pulled by two mobs at once.

	var/atom/movable/buckle = AM.is_buckled()
	if(buckle)
		if(buckle.anchored)
			return
		return start_pulling(buckle)
	
	AM.set_glide_size(glide_size)

	pulling = AM
	AM.pulledby = src
	AM.glide_modifier_flags |= GLIDE_MOD_PULLED

	var/obj/item/grab/grab_item = new /obj/item/grab()
	grab_item.grabbed_thing = AM
	if(!put_in_hands(grab_item)) //placing the grab in hand failed, grab is dropped, deleted, and we stop pulling automatically.
		CRASH("Failed to put grab_item in the hands of [src]")

	if(!suppress_message)
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, TRUE, 7)

	if(hud_used?.pull_icon)
		hud_used.pull_icon.icon_state = "pull"

	if(ismob(AM))
		var/mob/pulled_mob = AM
		log_combat(src, pulled_mob, "grabbed")
		do_attack_animation(pulled_mob, ATTACK_EFFECT_GRAB)

		if(!suppress_message)
			visible_message("<span class='warning'>[src] has grabbed [pulled_mob] passively!</span>", null, null, 5)

		if(pulled_mob.mob_size > MOB_SIZE_HUMAN || !(pulled_mob.status_flags & CANPUSH))
			grab_item.icon_state = "!reinforce"
		
		set_pull_offsets(pulled_mob)

	update_pull_movespeed()

	return AM.pull_response(src) //returns true if the response doesn't break the pull

//how a movable atom reacts to being pulled.
//returns true if the pull isn't severed by the response
/atom/movable/proc/pull_response(mob/puller)
	return TRUE

/**
  * Buckle to another mob
  *
  * You can buckle on mobs if you're next to them since most are dense
  *
  * Turns you to face the other mob too
  */
/mob/buckle_mob(mob/living/buckling_mob, force = FALSE, check_loc = TRUE, lying_buckle = FALSE, hands_needed = 0, target_hands_needed = 0, silent)
	if(buckling_mob.buckled)
		return FALSE
	if(buckling_mob.loc != loc && !buckling_mob.forceMove(loc))
		return FALSE
	return ..()

///Call back post buckle to a mob to offset your visual height
/mob/post_buckle_mob(mob/living/M)
	var/height = M.get_mob_buckling_height(src)
	M.pixel_y = initial(M.pixel_y) + height
	if(M.layer < layer)
		M.layer = layer + 0.1
///Call back post unbuckle from a mob, (reset your visual height here)
/mob/post_unbuckle_mob(mob/living/M)
	M.layer = initial(M.layer)
	M.pixel_y = initial(M.pixel_y)

///returns the height in pixel the mob should have when buckled to another mob.
/mob/proc/get_mob_buckling_height(mob/seat)
	. = 9
	if(!isliving(seat))
		return
	var/mob/living/L = seat
	if(L.mob_size <= MOB_SIZE_SMALL) //being on top of a small mob doesn't put you very high.
		return 0


/mob/GenerateTag()
	tag = "mob_[next_mob_id++]"


/mob/proc/get_paygrade()
	return ""

// facing verbs
/mob/proc/canface()
	if(!canmove)
		return FALSE
	if(stat == DEAD)
		return FALSE
	if(anchored)
		return FALSE
	if(notransform)
		return FALSE
	if(restrained())
		return FALSE
	return TRUE


/mob/proc/facedir(ndir)
	if(!canface())
		return FALSE
	setDir(ndir)
	if(buckled && !buckled.anchored)
		buckled.setDir(ndir)
	return TRUE


/proc/is_species(A, species_datum)
	. = FALSE
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(istype(H.species, species_datum))
			. = TRUE

/mob/proc/get_species()
	return ""

/mob/proc/flash_weak_pain()
	overlay_fullscreen("pain", /obj/screen/fullscreen/pain, 1)
	clear_fullscreen("pain")

///Called to update the stat var, returns a boolean to indicate if it has been handled.
/mob/proc/update_stat()
	return FALSE

/mob/proc/can_inject()
	return reagents

/mob/proc/get_idcard(hand_first)
	return

/mob/proc/slip(slip_source_name, stun_level, weaken_level, run_only, override_noslip, slide_steps)
	return FALSE

/mob/forceMove(atom/destination)
	. = ..()
	if(!.)
		return
	stop_pulling()
	if(buckled)
		buckled.unbuckle_mob(src)


/mob/proc/trainteleport(atom/destination)
	if(!destination || anchored)
		return FALSE //Gotta go somewhere and be able to move
	if(!pulling)
		return forceMove(destination) //No need for a special proc if there's nothing being pulled.
	pulledby?.stop_pulling() //The leader of the choo-choo train breaks the pull
	var/list/conga_line = list()
	var/end_of_conga = FALSE
	var/mob/S = src
	conga_line += S
	if(S.buckled)
		if(S.buckled.anchored)
			S.buckled.unbuckle_mob(S) //Unbuckle the first of the line if anchored.
		else
			conga_line += S.buckled
	while(!end_of_conga)
		var/atom/movable/A = S.pulling
		if(A in conga_line || A.anchored) //No loops, nor moving anchored things.
			end_of_conga = TRUE
			break
		conga_line += A
		var/mob/M = A
		if(istype(M)) //Is a mob
			if(M.buckled && !(M.buckled in conga_line))
				if(M.buckled.anchored)
					conga_line -= A //Remove from the conga line if on anchored buckles.
					end_of_conga = TRUE //Party is over, they won't be dragging anyone themselves.
					break
				else
					conga_line += M.buckled //Or bring the buckles along.
			var/mob/living/L = M
			if(istype(L))
				L.smokecloak_off()
			if(M.pulling)
				S = M
			else
				end_of_conga = TRUE
		else if(isobj(A)) //Not a mob.
			var/obj/O = A
			for(var/m in O.buckled_mobs)
				conga_line += m
				var/mob/buckled_mob = m
				if(!buckled_mob.pulling)
					continue
				buckled_mob.stop_pulling() //No support for wheelchair trains yet.
			var/obj/structure/bed/B = O
			if(istype(B) && B.buckled_bodybag)
				conga_line += B.buckled_bodybag
			end_of_conga = TRUE //Only mobs can continue the cycle.
	var/area/new_area = get_area(destination)
	for(var/atom/movable/AM in conga_line)
		var/oldLoc
		if(AM.loc)
			oldLoc = AM.loc
			AM.loc.Exited(AM,destination)
		AM.loc = destination
		AM.loc.Entered(AM,oldLoc)
		var/area/old_area
		if(oldLoc)
			old_area = get_area(oldLoc)
		if(new_area && old_area != new_area)
			new_area.Entered(AM,oldLoc)
		for(var/atom/movable/CR in destination)
			if(CR in conga_line)
				continue
			CR.Crossed(AM)
		if(oldLoc)
			AM.Moved(oldLoc)
		var/mob/M = AM
		if(istype(M))
			M.reset_perspective(destination)
	return TRUE


/mob/proc/set_interaction(atom/movable/AM)
	if(interactee)
		if(interactee == AM) //already set
			return
		else
			unset_interaction()
	interactee = AM
	interactee.on_set_interaction(src)


/mob/proc/unset_interaction()
	if(interactee)
		interactee.on_unset_interaction(src)
		interactee = null


/mob/proc/add_emote_overlay(image/emote_overlay, remove_delay = TYPING_INDICATOR_LIFETIME)
	emote_overlay.appearance_flags = APPEARANCE_UI_TRANSFORM
	emote_overlay.plane = ABOVE_HUD_PLANE
	emote_overlay.layer = ABOVE_HUD_LAYER
	overlays += emote_overlay

	if(remove_delay)
		addtimer(CALLBACK(src, .proc/remove_emote_overlay, emote_overlay, TRUE), remove_delay)


/mob/proc/remove_emote_overlay(image/emote_overlay, delete)
	overlays -= emote_overlay
	if(delete)
		qdel(emote_overlay)


/mob/proc/spin(spintime, speed)
	set waitfor = FALSE
	var/D = dir
	if(spintime < 1 || speed < 1 || !spintime || !speed)
		return
	while(spintime >= speed)
		sleep(speed)
		switch(D)
			if(NORTH)
				D = EAST
			if(SOUTH)
				D = WEST
			if(EAST)
				D = SOUTH
			if(WEST)
				D = NORTH
		setDir(D)
		spintime -= speed


/mob/proc/is_muzzled()
	return FALSE


// reset_perspective(thing) set the eye to the thing (if it's equal to current default reset to mob perspective)
// reset_perspective() set eye to common default : mob on turf, loc otherwise
/mob/proc/reset_perspective(atom/A)
	if(!client)
		return

	if(A)
		if(ismovableatom(A))
			//Set the the thing unless it's us
			if(A != src)
				client.perspective = EYE_PERSPECTIVE
				client.eye = A
			else
				client.eye = client.mob
				client.perspective = MOB_PERSPECTIVE
		else if(isturf(A))
			//Set to the turf unless it's our current turf
			if(A != loc)
				client.perspective = EYE_PERSPECTIVE
				client.eye = A
			else
				client.eye = client.mob
				client.perspective = MOB_PERSPECTIVE
	else
		//Reset to common defaults: mob if on turf, otherwise current loc
		if(isturf(loc))
			client.eye = client.mob
			client.perspective = MOB_PERSPECTIVE
		else
			client.perspective = EYE_PERSPECTIVE
			client.eye = loc

	return TRUE


/mob/Moved(atom/oldloc, direction)
	if(client && (client.view != WORLD_VIEW || client.pixel_x || client.pixel_y))
		for(var/obj/item/item in contents)
			if(item.zoom)
				item.zoom(src)
				click_intercept = null
				break
	return ..()


/mob/proc/update_joined_player_list(newname, oldname)
	if(newname == oldname)
		return
	if(oldname)
		GLOB.joined_player_list -= oldname
	if(newname)
		GLOB.joined_player_list[newname] = TRUE


//This will update a mob's name, real_name, mind.name, GLOB.datacore records and id
/mob/proc/fully_replace_character_name(oldname, newname)
	if(!newname)
		return FALSE

	log_played_names(ckey, newname)

	if(GLOB.joined_player_list[oldname])
		update_joined_player_list(newname, oldname)

	real_name = newname
	name = newname
	if(mind)
		mind.name = newname
		if(mind.key)
			log_played_names(mind.key, newname) //Just in case the mind is unsynced at the moment.

	return TRUE


/mob/proc/update_sight()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_SIGHT)
	sync_lighting_plane_alpha()


/mob/proc/sync_lighting_plane_alpha()
	if(!hud_used)
		return

	var/obj/screen/plane_master/lighting/L = hud_used.plane_masters["[LIGHTING_PLANE]"]
	if(L)
		L.alpha = lighting_alpha


/mob/proc/get_photo_description(obj/item/camera/camera)
	return "a ... thing?"


/mob/proc/can_interact_with(datum/D)
	return (D == src)

///Update the mouse pointer of the attached client in this mob
/mob/proc/update_mouse_pointer()
	if (!client)
		return
	client.mouse_pointer_icon = initial(client.mouse_pointer_icon)


/mob/proc/update_names_joined_list(new_name, old_name)
	if(old_name)
		GLOB.real_names_joined -= old_name
	if(new_name)
		GLOB.real_names_joined[new_name] = TRUE

/// Updates the grab state of the mob and updates movespeed
/mob/setGrabState(newstate)
	. = ..()
	if(isnull(.))
		return
	if(grab_state == GRAB_PASSIVE)
		remove_movespeed_modifier(MOVESPEED_ID_MOB_GRAB_STATE)
	else if(. == GRAB_PASSIVE)
		add_movespeed_modifier(MOVESPEED_ID_MOB_GRAB_STATE, TRUE, 100, NONE, TRUE, grab_state * 3)

/mob/proc/set_stat(new_stat)
	if(new_stat == stat)
		return
	. = stat //old stat
	stat = new_stat
