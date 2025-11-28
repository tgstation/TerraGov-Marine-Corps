
/mob/Destroy()//This makes sure that mobs with clients/keys are not just deleted from the game.
	GLOB.mob_list -= src
	GLOB.dead_mob_list -= src
	GLOB.offered_mob_list -= src
	for(var/alert in alerts)
		clear_alert(alert, TRUE)
	if(length(observers))
		for(var/mob/dead/observes AS in observers)
			observes.reset_perspective(null)
	ghostize()
	clear_fullscreens()
	if(mind)
		mind = null
	if(hud_used)
		QDEL_NULL(hud_used)
	if(s_active)
		s_active.hide_from(src)
	unset_machine()
	for(var/a in actions)
		var/datum/action/action_to_remove = a
		action_to_remove.remove_action(src)
	set_focus(null)
	return ..()

/mob/New()
	// This needs to happen IMMEDIATELY. I'm sorry :(
	GenerateTag()
	return ..()

/mob/Initialize(mapload)
	GLOB.mob_list += src
	if(stat == DEAD)
		GLOB.dead_mob_list += src
	set_focus(src)
	prepare_huds()
	for(var/v in GLOB.active_alternate_appearances)
		if(!v)
			continue
		var/datum/atom_hud/alternate_appearance/AA = v
		AA.onNewMob(src)
	. = ..()
	if(islist(skills))
		set_skills(getSkills(arglist(skills)))
	else if(!skills)
		set_skills(getSkills())
	else if(!istype(skills, /datum/skills))
		stack_trace("Invalid type [skills.type] found in .skills during /mob Initialize()")
	update_config_movespeed()
	update_movespeed(TRUE)
	log_mob_tag("\[[tag]\] CREATED: [key_name(src)]")
	become_hearing_sensitive()

/**
 * Generate the tag for this mob
 *
 * This is simply "mob_"+ a global incrementing counter that goes up for every mob
 */
/mob/GenerateTag()
	. = ..()
	tag = "mob_[next_mob_id++]"

/mob/proc/show_message(msg, type, alt_msg, alt_type, avoid_highlight)
	if(!client)
		return FALSE

	msg = copytext_char(msg, 1, MAX_MESSAGE_LEN)

	to_chat(src, msg)
	return TRUE


/mob/living/show_message(msg, type, alt_msg, alt_type, avoid_highlight)
	if(!client)
		return FALSE

	msg = copytext_char(msg, 1, MAX_MESSAGE_LEN)

	if(type)
		if(type == EMOTE_TYPE_VISIBLE && eye_blind) //Vision related
			if(!alt_msg)
				return FALSE
			else
				msg = alt_msg
				type = alt_type

		if(type == EMOTE_TYPE_AUDIBLE && isdeaf(src)) //Hearing related
			if(!alt_msg)
				return FALSE
			else
				msg = alt_msg
				type = alt_type
				if(type == EMOTE_TYPE_VISIBLE && eye_blind)
					return FALSE

	if(stat == UNCONSCIOUS && type == EMOTE_TYPE_AUDIBLE)
		to_chat(src, "<i>... You can almost hear something ...</i>")
		return FALSE
	to_chat(src, msg, avoid_highlighting = avoid_highlight)
	return TRUE

/**
 * Show a message to all player mobs who sees this atom
 * Show a message to the src mob (if the src is a mob)
 * Use for atoms performing visible actions
 * message is output to anyone who can see, e.g. "The [src] does something!"
 * self_message (optional) is what the src mob sees e.g. "You do something!"
 * blind_message (optional) is what blind people will hear e.g. "You hear something!"
 * vision_distance (optional) define how many tiles away the message can be seen.
 * ignored_mob (optional) doesn't show any message to a given mob if TRUE.
 */
/atom/proc/visible_message(message, self_message, blind_message, vision_distance, ignored_mob, visible_message_flags = NONE, emote_prefix)
	var/turf/T = get_turf(src)
	if(!T)
		return

	var/range = 7
	if(vision_distance)
		range = vision_distance

	var/raw_msg = message
	if(visible_message_flags & EMOTE_MESSAGE)
		message = "[emote_prefix]<b>[src]</b> [message]"

	for(var/mob/M in get_hearers_in_view(range, src))
		if(!M.client)
			continue

		if(M == ignored_mob)
			continue

		var/msg = message

		if(M == src && self_message) //the src always see the main message or self message
			msg = self_message

			if((visible_message_flags & COMBAT_MESSAGE) && M.client.prefs.mute_self_combat_messages)
				continue

		else
			if(M.see_invisible < invisibility || (T != loc && T != src)) //if src is invisible to us or is inside something (and isn't a turf),
				if(!blind_message) // then people see blind message if there is one, otherwise nothing.
					continue

				msg = blind_message

			if((visible_message_flags & COMBAT_MESSAGE) && M.client.prefs.mute_others_combat_messages)
				continue

		if(visible_message_flags & EMOTE_MESSAGE && rc_vc_msg_prefs_check(M, visible_message_flags) && !is_blind(M))
			M.create_chat_message(src, raw_message = raw_msg, runechat_flags = visible_message_flags)

		M.show_message(msg, EMOTE_TYPE_VISIBLE, blind_message, EMOTE_TYPE_AUDIBLE)


///Returns the client runechat visible messages preference according to the message type.
/atom/proc/rc_vc_msg_prefs_check(mob/target, visible_message_flags = NONE)
	if(!target.client?.prefs.chat_on_map || !target.client.prefs.see_chat_non_mob)
		return FALSE
	if(visible_message_flags & EMOTE_MESSAGE && !target.client.prefs.see_rc_emotes)
		return FALSE
	return TRUE

/mob/rc_vc_msg_prefs_check(mob/target, visible_message_flags = NONE)
	if(!target.client?.prefs.chat_on_map)
		return FALSE
	if(visible_message_flags & EMOTE_MESSAGE && !target.client.prefs.see_rc_emotes)
		return FALSE
	return TRUE



// Show a message to all mobs in earshot of this one
// This would be for audible actions by the src mob
// message is the message output to anyone who can hear.
// self_message (optional) is what the src mob hears.
// deaf_message (optional) is what deaf people will see.
// hearing_distance (optional) is the range, how many tiles away the message can be heard.

/mob/audible_message(message, deaf_message, hearing_distance, self_message, audible_message_flags = NONE, emote_prefix)
	var/range = 7
	var/raw_msg = message
	if(hearing_distance)
		range = hearing_distance
	if(audible_message_flags & EMOTE_MESSAGE)
		message = "[emote_prefix]<b>[src]</b> [message]"
	for(var/mob/M in get_hearers_in_view(range, src))
		var/msg = message
		if(self_message && M == src)
			msg = self_message
		if(audible_message_flags & EMOTE_MESSAGE && rc_vc_msg_prefs_check(M, audible_message_flags) && !isdeaf(M))
			M.create_chat_message(src, raw_message = raw_msg, runechat_flags = audible_message_flags)
		M.show_message(msg, EMOTE_TYPE_AUDIBLE, deaf_message, EMOTE_TYPE_VISIBLE)


/**
 * Show a message to all mobs in earshot of this atom
 * Use for objects performing audible actions
 * message is the message output to anyone who can hear.
 * deaf_message (optional) is what deaf people will see.
 * hearing_distance (optional) is the range, how many tiles away the message can be heard.
 */
/atom/proc/audible_message(message, deaf_message, hearing_distance, self_message, audible_message_flags = NONE, emote_prefix)
	var/range = 7
	var/raw_msg = message
	if(hearing_distance)
		range = hearing_distance
	if(audible_message_flags & EMOTE_MESSAGE)
		message = "[emote_prefix]<b>[src]</b> [message]"
	for(var/mob/M in get_hearers_in_view(range, src))
		if(audible_message_flags & EMOTE_MESSAGE && rc_vc_msg_prefs_check(M, audible_message_flags))
			M.create_chat_message(src, raw_message = raw_msg, runechat_flags = audible_message_flags)
		M.show_message(message, EMOTE_TYPE_AUDIBLE, deaf_message, EMOTE_TYPE_VISIBLE)


///This proc is called whenever someone clicks an inventory ui slot.
/mob/proc/attack_ui(slot)
	var/obj/item/W = get_active_held_item()
	if(istype(W))
		equip_to_slot_if_possible(W, slot, FALSE) // equiphere


///Attempts to put an item in either hand, prioritizing the active hand
/mob/proc/put_in_any_hand_if_possible(obj/item/W as obj, del_on_fail = FALSE, warning = FALSE, redraw_mob = TRUE)
	if(equip_to_slot_if_possible(W, (hand ? SLOT_L_HAND : SLOT_R_HAND), TRUE, del_on_fail, warning, redraw_mob))
		return TRUE
	else if(equip_to_slot_if_possible(W, (hand ? SLOT_R_HAND : SLOT_L_HAND), TRUE, del_on_fail, warning, redraw_mob))
		return TRUE
	return FALSE

/**
 * This is a SAFE proc. Use this instead of equip_to_slot()!
 * set del_on_fail to have it delete item_to_equip if it fails to equip
 * unset redraw_mob to prevent the mob from being redrawn at the end.
 */
/mob/proc/equip_to_slot_if_possible(obj/item/item_to_equip, slot, ignore_delay = TRUE, del_on_fail = FALSE, warning = TRUE, redraw_mob = TRUE, override_nodrop = FALSE)
	if(!istype(item_to_equip) || QDELETED(item_to_equip)) //This qdeleted is to prevent stupid behavior with things that qdel during init, like say stacks
		return FALSE
	if(!item_to_equip.mob_can_equip(src, slot, warning, override_nodrop))
		if(del_on_fail)
			qdel(item_to_equip)
			return FALSE
		if(warning)
			to_chat(src, span_warning("You are unable to equip that."))
		return FALSE
	if(item_to_equip.equip_delay_self && !ignore_delay)
		if(!do_after(src, item_to_equip.equip_delay_self, NONE, item_to_equip, BUSY_ICON_FRIENDLY))
			to_chat(src, "You stop putting on \the [item_to_equip].")
			return FALSE
		//calling the proc again with ignore_delay saves a boatload of copypaste
		return equip_to_slot_if_possible(item_to_equip, slot, TRUE, del_on_fail, warning, redraw_mob, override_nodrop)
	//This will unwield items -without- triggering lights.
	if(CHECK_BITFIELD(item_to_equip.item_flags, TWOHANDED))
		item_to_equip.unwield(src)
	equip_to_slot(item_to_equip, slot) //This proc should not ever fail.
	return TRUE

/**
*This is an UNSAFE proc. It merely handles the actual job of equipping. All the checks on whether you can or can't eqip need to be done before! Use mob_can_equip() for that task.
*In most cases you will want to use equip_to_slot_if_possible()
*/
/mob/proc/equip_to_slot(obj/item/item_to_equip, slot, bitslot = FALSE)
	if(!slot)
		return
	if(!istype(item_to_equip))
		return
	if(bitslot)
		var/oldslot = slot
		slot = slotbit2slotdefine(oldslot)

	if(item_to_equip == l_hand)
		l_hand = null
		item_to_equip.unequipped(src, SLOT_L_HAND)
		update_inv_l_hand()

	else if(item_to_equip == r_hand)
		r_hand = null
		item_to_equip.unequipped(src, SLOT_R_HAND)
		update_inv_r_hand()

	for(var/datum/action/A AS in item_to_equip.actions)
		A.remove_action(src)

	item_to_equip.screen_loc = null
	SET_PLANE_EXPLICIT(item_to_equip, ABOVE_HUD_PLANE, src)
	item_to_equip.forceMove(src)

///This is just a commonly used configuration for the equip_to_slot_if_possible() proc, used to equip people when the rounds starts and when events happen and such.
/mob/proc/equip_to_slot_or_del(obj/item/W, slot, override_nodrop = FALSE)
	return equip_to_slot_if_possible(W, slot, TRUE, TRUE, FALSE, FALSE, override_nodrop)

/// Tries to equip an item to the slot provided, otherwise tries to put it in hands, if hands are full the item is deleted
/mob/proc/equip_to_slot_or_hand(obj/item/W, slot, override_nodrop = FALSE)
	if(!equip_to_slot_if_possible(W, slot, TRUE, FALSE, FALSE, FALSE, override_nodrop))
		put_in_any_hand_if_possible(W, TRUE, FALSE)

///Attempts to store an item in a valid location based on SLOT_EQUIP_ORDER
/mob/proc/equip_to_appropriate_slot(obj/item/W, ignore_delay = TRUE)
	if(!istype(W))
		return FALSE

	for(var/slot in SLOT_EQUIP_ORDER)
		if(equip_to_slot_if_possible(W, slot, ignore_delay, FALSE, FALSE, FALSE))
			return TRUE

	return FALSE

///Checks an inventory slot for an item that can be drawn that is directly stored, or inside another storage item, and draws it if possible
/mob/proc/draw_from_slot_if_possible(slot)
	if(!slot)
		return FALSE

	var/obj/item/I = get_item_by_slot(slot)

	if(!I)
		return FALSE

	//This is quite horrible, there's probably a better way to do it.
	//Each actual inventory slot has more than one slot define associated with it.
	//The defines below are for specific items in specific slots, which allows for a much more specific draw order, i.e. drawing a weapon from a slot which would otherwise be lower in the order
	if(slot == SLOT_IN_HOLSTER && (!(istype(I, /obj/item/storage/holster) || istype(I, /obj/item/weapon))))
		return FALSE
	if(slot == SLOT_IN_S_HOLSTER && (!(istype(I, /obj/item/storage/holster) || istype(I, /obj/item/weapon) || istype(I, /obj/item/storage/belt/knifepouch))))
		return FALSE
	if(slot == SLOT_IN_B_HOLSTER && (!(istype(I, /obj/item/storage/holster) || istype(I, /obj/item/weapon))))
		return FALSE
	if(slot == SLOT_IN_ACCESSORY && (!istype(I, /obj/item/clothing/under)))
		return FALSE
	if(slot == SLOT_IN_L_POUCH && (!(istype(I, /obj/item/storage/holster) || istype(I, /obj/item/weapon) || istype(I, /obj/item/storage/pouch/pistol))))
		return FALSE
	if(slot == SLOT_IN_R_POUCH && (!(istype(I, /obj/item/storage/holster) || istype(I, /obj/item/weapon) || istype(I, /obj/item/storage/pouch/pistol))))
		return FALSE

	//Sends quick equip signal, if our signal is not handled/blocked we continue to the normal behaviour
	var/return_value = SEND_SIGNAL(I, COMSIG_ITEM_QUICK_EQUIP, src)
	switch(return_value)
		if(COMSIG_QUICK_EQUIP_HANDLED)
			return TRUE
		if(COMSIG_QUICK_EQUIP_BLOCKED)
			return FALSE

	//calls on the item to return a suitable item to be equipped
	//Realistically only would get called on an item that has no storage/storage didnt fail signal
	var/obj/item/found = I.do_quick_equip(src)
	if(!found)
		return FALSE
	if(CHECK_BITFIELD(found.inventory_flags, NOQUICKEQUIP))
		return FALSE
	temporarilyRemoveItemFromInventory(found)
	put_in_hands(found)
	return TRUE

/mob/vv_get_dropdown()
	. = ..()
	. += "---"
	VV_DROPDOWN_OPTION(VV_HK_PLAYER_PANEL, "Show player panel")
	VV_DROPDOWN_OPTION(VV_HK_VIEW_PLANES, "View/Edit Planes")

/mob/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list[VV_HK_PLAYER_PANEL])
		return SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/show_player_panel, src)

	if(href_list[VV_HK_VIEW_PLANES])
		if(!check_rights(R_DEBUG))
			return
		usr.client.edit_plane_masters(src)

/mob/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, control_object))
			var/obj/O = var_value
			if(!istype(O) || (O.obj_flags & DANGEROUS_POSSESSION))
				return FALSE
		if(NAMEOF(src, machine))
			set_machine(var_value)
			. = TRUE
		if(NAMEOF(src, focus))
			set_focus(var_value)
			. = TRUE
		if(NAMEOF(src, stat))
			set_stat(var_value)
			. = TRUE
		if(NAMEOF(src, lighting_cutoff))
			sync_lighting_plane_cutoff()

	if(!isnull(.))
		datum_flags |= DF_VAR_EDITED
		return

	var/slowdown_edit = (var_name == NAMEOF(src, cached_multiplicative_slowdown))
	var/diff
	if(slowdown_edit && isnum(cached_multiplicative_slowdown) && isnum(var_value))
		remove_movespeed_modifier(MOVESPEED_ID_ADMIN_VAREDIT)
		diff = var_value - cached_multiplicative_slowdown

	. = ..()

	if(. && slowdown_edit && isnum(diff))
		update_movespeed()


/client/verb/changes()
	set name = "Changelog"
	set category = "OOC"
	if(!GLOB.changelog_tgui)
		GLOB.changelog_tgui = new /datum/changelog()

	GLOB.changelog_tgui.ui_interact(mob)
	if(prefs.lastchangelog != GLOB.changelog_hash)
		prefs.lastchangelog = GLOB.changelog_hash
		prefs.save_preferences()
		winset(src, "infobuttons.changelog", "font-style=;")

/client/verb/hotkeys_help()
	set name = "Hotkeys"
	set category = "Preferences"

	prefs.tab_index = KEYBIND_SETTINGS
	prefs.ShowChoices(mob)

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

/mob/living/start_pulling(atom/movable/AM, force = move_force, suppress_message = FALSE)
	if(QDELETED(AM) || QDELETED(usr) || src == AM || !isturf(loc) || !Adjacent(AM) || status_flags & INCORPOREAL)	//if there's no person pulling OR the person is pulling themself OR the object being pulled is inside something: abort!
		return FALSE

	if(!AM.can_be_pulled(src, force))
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
			to_chat(src, span_warning("Cannot grab, lacking free hands to do so!"))
		return FALSE

	AM.add_fingerprint(src, "pull")

	changeNext_move(CLICK_CD_GRABBING)

	if(AM.pulledby)
		if(!suppress_message)
			AM.visible_message(span_danger("[src] has pulled [AM] from [AM.pulledby]'s grip."),
				span_danger("[src] has pulled you from [AM.pulledby]'s grip."), null, null, src)
			to_chat(src, span_notice("You pull [AM] from [AM.pulledby]'s grip!"))
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


	hud_used?.pull_icon?.icon_state = "pull"

	if(ismob(AM))
		var/mob/pulled_mob = AM
		log_combat(src, pulled_mob, "grabbed")
		do_attack_animation(pulled_mob, ATTACK_EFFECT_GRAB)

		if(!suppress_message)
			visible_message(span_warning("[src] has grabbed [pulled_mob] passively!"), null, null, 5)

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
 * You can buckle on mobs if you're next to them since most are dense
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
	. = ..()
	tag = "mob_[next_mob_id++]"

/mob/serialize_list(list/options, list/semvers)
	. = ..()

	.["tag"] = tag
	.["name"] = name
	.["ckey"] = ckey
	.["key"] = key

	SET_SERIALIZATION_SEMVER(semvers, "1.0.0")
	return .

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
	SEND_SIGNAL(src, COMSIG_MOB_FACE_DIR, ndir)
	setDir(ndir)
	if(buckled && !buckled.anchored)
		buckled.setDir(ndir)
	return TRUE


/proc/is_species(A, species_datum)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(istype(H.species, species_datum))
			return TRUE
	return FALSE

/mob/proc/get_species()
	return ""

/mob/proc/flash_weak_pain()
	overlay_fullscreen("pain", /atom/movable/screen/fullscreen/pain, 1)
	clear_fullscreen("pain")

///Called to update the stat var, returns a boolean to indicate if it has been handled.
/mob/proc/update_stat()
	return FALSE

/mob/proc/can_inject()
	return reagents

/mob/proc/get_idcard(hand_first)
	return

/mob/proc/slip(slip_source_name, stun_level, paralyze_level, run_only, override_noslip, slide_steps)
	return FALSE

/mob/forceMove(atom/destination)
	. = ..()
	if(!.)
		return
	if(currently_z_moving)
		return
	stop_pulling()
	if(buckled && !HAS_TRAIT(src, TRAIT_CANNOT_BE_UNBUCKLED))
		buckled.unbuckle_mob(src, TRUE)


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
		if((A in conga_line) || A.anchored) //No loops, nor moving anchored things.
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
	for(var/atom/movable/AM in conga_line)
		AM.forceMove(destination)
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
	SET_PLANE(emote_overlay, ABOVE_LIGHTING_PLANE, src)
	overlays += emote_overlay

	if(remove_delay)
		addtimer(CALLBACK(src, PROC_REF(remove_emote_overlay), emote_overlay, TRUE), remove_delay)


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

/// Adds this list to the output to the stat browser
/mob/proc/get_status_tab_items()
	. = list("") //we want to offset unique stuff from standard stuff
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MOB_GET_STATUS_TAB_ITEMS, src, .)
	SEND_SIGNAL(src, COMSIG_MOB_GET_STATUS_TAB_ITEMS, .)

// reset_perspective(thing) set the eye to the thing (if it's equal to current default reset to mob perspective)
// reset_perspective(null) set eye to common default : mob on turf, loc otherwise
/mob/proc/reset_perspective(atom/new_eye)
	if(!client)
		return

	if(new_eye)
		if(ismovable(new_eye))
			//Set the new eye unless it's us
			if(new_eye != src)
				client.perspective = EYE_PERSPECTIVE
				client.set_eye(new_eye)
			else
				client.set_eye(client.mob)
				client.perspective = MOB_PERSPECTIVE
		else if(isturf(new_eye))
			//Set to the turf unless it's our current turf
			if(new_eye != loc)
				client.perspective = EYE_PERSPECTIVE
				client.set_eye(new_eye)
			else
				client.set_eye(client.mob)
				client.perspective = MOB_PERSPECTIVE
		else
			return TRUE //no setting eye to stupid things like areas or whatever
	else
		//Reset to common defaults: mob if on turf, otherwise current loc
		if(isturf(loc))
			client.set_eye(client.mob)
			client.perspective = MOB_PERSPECTIVE
		else
			client.perspective = EYE_PERSPECTIVE
			client.set_eye(loc)
	/// Signal sent after the eye has been successfully updated, with the client existing.
	SEND_SIGNAL(src, COMSIG_MOB_RESET_PERSPECTIVE)
	return TRUE

/mob/proc/update_joined_player_list(newname, oldname)
	if(newname == oldname)
		return
	if(!istext(newname) && !isnull(newname))
		stack_trace("[src] attempted to change its name from [oldname] to the non string value [newname]")
		return FALSE
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

	log_mob_tag("\[[tag]\] RENAMED: [key_name(src)]")

	return TRUE


///Update the lighting plane and sight of this mob (sends COMSIG_MOB_UPDATE_SIGHT)
/mob/proc/update_sight()
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_SIGHT)
	sync_lighting_plane_cutoff()

///Set the lighting plane hud filters to the mobs lighting_cutoff var
/mob/proc/sync_lighting_plane_cutoff()
	if(!hud_used)
		return
	for(var/atom/movable/screen/plane_master/rendering_plate/lighting/light as anything in hud_used.get_true_plane_masters(RENDER_PLANE_LIGHTING))
		light.set_light_cutoff(lighting_cutoff, lighting_color_cutoffs)


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
		add_movespeed_modifier(MOVESPEED_ID_MOB_GRAB_STATE, TRUE, 100, NONE, TRUE, BASE_GRAB_SLOWDOWN) //We cap this at 3 so we don't get utterly insane slowdowns for neck and other grabs.

/mob/set_throwing(new_throwing)
	. = ..()
	if(!.)
		return
	if(throwing)
		ADD_TRAIT(src, TRAIT_IMMOBILE, THROW_TRAIT) // Prevents moving during the throw.
	else
		REMOVE_TRAIT(src, TRAIT_IMMOBILE, THROW_TRAIT)

/mob/proc/set_stat(new_stat)
	SHOULD_CALL_PARENT(TRUE)
	if(new_stat == stat)
		return
	remove_all_indicators()
	. = stat //old stat
	stat = new_stat
	if(. == DEAD && client)
		//This would go on on_revive() but that is a mob/living proc
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[ckey]
		personal_statistics.times_revived++
		personal_statistics.mission_times_revived++
	SEND_SIGNAL(src, COMSIG_MOB_STAT_CHANGED, ., new_stat)

/// Cleanup proc that's called when a mob loses a client, either through client destroy or logout
/// Logout happens post client del, so we can't just copypaste this there. This keeps things clean and consistent
/mob/proc/become_uncliented()
	if(!canon_client)
		return

	for(var/foo in canon_client.player_details.post_logout_callbacks)
		var/datum/callback/CB = foo
		CB.Invoke()

	if(canon_client?.movingmob)
		LAZYREMOVE(canon_client.movingmob.client_mobs_in_contents, src)
		canon_client.movingmob = null

	clear_important_client_contents()
	canon_client = null

/mob/proc/point_to_atom(atom/pointed_atom)
	var/turf/tile = get_turf(pointed_atom)
	if(!tile)
		return FALSE
	if (pointed_atom in src)
		create_point_bubble(pointed_atom)
		return FALSE
	var/turf/our_tile = get_turf(src)
	var/obj/visual = new /obj/effect/overlay/temp/point/big(our_tile, 0)
	visual.invisibility = invisibility
	animate(visual, pixel_x = (tile.x - our_tile.x) * world.icon_size + pointed_atom.pixel_x, pixel_y = (tile.y - our_tile.y) * world.icon_size + pointed_atom.pixel_y, time = 1.7, easing = EASE_OUT)
	SEND_SIGNAL(src, COMSIG_POINT_TO_ATOM, pointed_atom)
	return TRUE

/atom/movable/proc/create_point_bubble(atom/pointed_atom, include_arrow = TRUE)
	var/mutable_appearance/thought_bubble = mutable_appearance(
		'icons/effects/effects.dmi',
		"thought_bubble",
		offset_spokesman = src,
		plane = POINT_PLANE,
		appearance_flags = KEEP_APART,
	)

	var/mutable_appearance/pointed_atom_appearance = new(pointed_atom.appearance)
	pointed_atom_appearance.blend_mode = BLEND_INSET_OVERLAY
	pointed_atom_appearance.plane = FLOAT_PLANE
	pointed_atom_appearance.layer = FLOAT_LAYER
	pointed_atom_appearance.pixel_x = 0
	pointed_atom_appearance.pixel_y = 0
	thought_bubble.overlays += pointed_atom_appearance
/* // tg has hover outlines reenable this if we ever port them
	var/hover_outline_index = pointed_atom.get_filter_index(HOVER_OUTLINE_FILTER)
	if (!isnull(hover_outline_index))
		pointed_atom_appearance.filters.Cut(hover_outline_index, hover_outline_index + 1)
*/
	thought_bubble.pixel_w = 16
	thought_bubble.pixel_z = 32
	thought_bubble.alpha = 200

	if(include_arrow)
		var/mutable_appearance/point_visual = mutable_appearance(
			'icons/mob/screen/generic.dmi',
			"arrow"
		)

		thought_bubble.overlays += point_visual

	add_overlay(thought_bubble)
	LAZYADD(update_overlays_on_z, thought_bubble)
	addtimer(CALLBACK(src, PROC_REF(clear_point_bubble), thought_bubble), POINT_TIME)

/atom/movable/proc/clear_point_bubble(mutable_appearance/thought_bubble)
	LAZYREMOVE(update_overlays_on_z, thought_bubble)
	cut_overlay(thought_bubble)

/// Side effects of being sent to the end of round deathmatch zone
/mob/proc/on_eord(turf/destination)
	return

/mob/key_down(key, client/client, full_key)
	..()
	SEND_SIGNAL(src, COMSIG_MOB_KEYDOWN, key, client, full_key)
