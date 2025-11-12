/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	do_resist()

///Handles trying to toggle resting state
/mob/living/proc/toggle_resting()
	if(incapacitated(TRUE))
		return

	if(!resting)
		if(is_ventcrawling)
			return FALSE
		set_resting(TRUE, FALSE)
		return
	if(do_actions)
		balloon_alert(src, "Busy!")
		return
	get_up()

///Handles getting up, doing a basic check before relaying it to the actual proc that does it
/mob/living/proc/get_up()
	if(!incapacitated(TRUE))
		set_resting(FALSE, FALSE)
	else
		to_chat(src, span_notice("You fail to get up."))

///Actually handles toggling the resting state
/mob/living/proc/set_resting(rest, silent = TRUE)
	if(status_flags & INCORPOREAL)
		return
	if(rest == resting)
		return
	. = resting
	resting = rest
	if(resting)
		ADD_TRAIT(src, TRAIT_FLOORED, RESTING_TRAIT)
		if(!silent)
			to_chat(src, span_notice("You are now resting."))
		SEND_SIGNAL(src, COMSIG_XENOMORPH_REST)
	else
		REMOVE_TRAIT(src, TRAIT_FLOORED, RESTING_TRAIT)
		if(!silent)
			to_chat(src, span_notice("You get up."))
		SEND_SIGNAL(src, COMSIG_XENOMORPH_UNREST)
	hud_used?.rest_icon?.update_icon()


/mob/living/verb/ghost()
	set category = "OOC"
	set name = "Ghost"

	if(stat == DEAD)
		ghostize(TRUE)
		return

	if(tgui_alert(src, "Are you sure you want to ghost?\n(You are alive. If you ghost, you won't be able to return to your body. You can't change your mind so choose wisely!)", "Ghost", list("Yes", "No")) != "Yes")
		return

	set_resting(TRUE)
	log_game("[key_name(usr)] has ghosted at [AREACOORD(usr)].")
	message_admins("[ADMIN_TPMONTY(usr)] has ghosted.")
	ghostize(FALSE)

/mob/living/point_to(atom/pointed_atom as mob|obj|turf in view(client.view, src))
	if(!..())
		return FALSE
	if(HAS_TRAIT(src, TRAIT_FAKEDEATH))
		return FALSE
	visible_message(span_infoplain("[span_name("[src]")] points at [pointed_atom]."), span_notice("You point at [pointed_atom]."))
