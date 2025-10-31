/obj/item/clothing/glasses/hypno
	name = "hypnotic goggles"
	desc = "It could be a discarded secred NovaMed device. Or maybe it's just a pair of kinky goggles with a savy tech inside."
	icon = 'ntf_modular/icons/obj/clothing/goggles/hypno.dmi'
	icon_state = "hypnogoggles"
	item_state_worn = TRUE
	worn_icon_list = list(
		slot_glasses_str = 'ntf_modular/icons/mob/clothing/goggles/hypno.dmi',
		slot_r_hand_str = 'ntf_modular/icons/mob/inhands/lewd_left.dmi',
		slot_l_hand_str = 'ntf_modular/icons/mob/inhands/lewd_left.dmi',
	)
	var/current_hypnogoggles_color = "pink"
	var/static/list/hypnogoggles_designs

	var/mob/living/carbon/human/victim
	var/codephrase = "Obey"

/obj/item/clothing/glasses/hypno/equipped(mob/user, slot)//Adding hypnosis on equip
	. = ..()
	if(!ishuman(user) || slot != ITEM_SLOT_EYES)
		return

	victim = user
	victim.apply_status_effect(/datum/status_effect/induced_hypnosis, codephrase == "" ? "Obey" : codephrase)

/obj/item/clothing/glasses/hypno/unequipped(mob/user, slot)
	. = ..()
	if(slot == SLOT_GLASSES)
		victim.remove_status_effect(/datum/status_effect/induced_hypnosis)
	victim = null

/obj/item/clothing/glasses/hypno/Destroy()
	if(victim?.glasses == src)
		victim.remove_status_effect(/datum/status_effect/induced_hypnosis)
	victim = null
	return ..()

/obj/item/clothing/glasses/hypno/attack_self(mob/user) //Setting up hypnotizing phrase
	. = ..()
	codephrase = stripped_input(user, "Change the hypnotic phrase")
	to_chat(user, span_warning("This item is not an alternative to brain washing, use at your own discretion."))

//create radial menu
/obj/item/clothing/glasses/hypno/proc/populate_hypnogoggles_designs()
	hypnogoggles_designs = list(
		"pink" = image (icon = src.icon, icon_state = "hypnogoggles_pink"),
		"teal" = image(icon = src.icon, icon_state = "hypnogoggles_teal"))

//to change model
/obj/item/clothing/glasses/hypno/AltClick(mob/user, obj/item/I)
	. = ..()
	var/choice = show_radial_menu(user,src, hypnogoggles_designs, custom_check = CALLBACK(src, PROC_REF(check_menu), user, I), radius = 36, require_near = TRUE)
	if(!choice)
		return FALSE
	current_hypnogoggles_color = choice
	update_icon()

//to check if we can change kinkphones's model
/obj/item/clothing/glasses/hypno/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return TRUE

/obj/item/clothing/glasses/hypno/Initialize()
	. = ..()
	update_icon_state()
	update_icon()
	if(!length(hypnogoggles_designs))
		populate_hypnogoggles_designs()

/obj/item/clothing/glasses/hypno/update_icon_state()
	. = ..()
	icon_state = icon_state = "[initial(icon_state)]_[current_hypnogoggles_color]"
	icon_state = "[initial(icon_state)]_[current_hypnogoggles_color]"

/datum/status_effect/induced_hypnosis
	examine_text = ""
	var/hypnotic_phrase = ""
	var/regex/target_phrase
	alert_type = /atom/movable/screen/alert/status_effect/induced_hypnosis

/atom/movable/screen/alert/status_effect/induced_hypnosis
	name = "Induced hypnosis"
	desc = "Something's hypnotizing you, but you're not really sure about what."
	icon_state = "hypnosis"
	icon = 'ntf_modular/icons/mob/screen_alert.dmi'

/datum/status_effect/induced_hypnosis/on_creation(mob/living/new_owner, phrase, ...)
	if(!phrase)
		qdel(src)
	hypnotic_phrase = phrase
	try
		target_phrase = new("(//b[REGEX_QUOTE(hypnotic_phrase)]//b)","ig")
	catch(var/exception/e)
		stack_trace("[e] on [e.file]:[e.line]")
		qdel(src)
	tick_interval = SSmobs.wait
	return ..()

/datum/status_effect/induced_hypnosis/on_apply()
	log_game("[key_name(owner)] was hypnogoggled'.")
	to_chat(owner, "<span class='reallybig hypnophrase'>[hypnotic_phrase]</span>")
	to_chat(owner, span_notice(pick("You feel your thoughts focusing on this phrase... you can't seem to get it out of your head.",
									"Your head hurts, but this is all you can think of. It must be vitally important.",
									"You feel a part of your mind repeating this over and over. You need to follow these words.",
									"Something about this sounds... right, for some reason. You feel like you should follow these words.",
									"These words keep echoing in your mind. You find yourself completely fascinated by them.")))
	to_chat(owner, span_boldwarning("You've been hypnotized by this sentence. You must follow these words. If it isn't a clear order, you can freely interpret how to do so, as long as you act like the words are your highest priority."))
	examine_text = "[hypnotic_phrase]... your mind seems to be fixated on this concept."
	return TRUE

/datum/status_effect/induced_hypnosis/on_remove()
	log_game("[key_name(owner)] is no longer hypnogoggled.")
	to_chat(owner, span_userdanger("You suddenly snap out of your hypnosis. The phrase '[hypnotic_phrase]' no longer feels important to you."))
	owner.clear_alert("hypnosis")
	return ..()

/datum/status_effect/induced_hypnosis/tick(delta_time)
	if(!(SPT_PROB(1, SSmobs.wait)))
		return

	switch(rand(1, 2))
		if(1)
			to_chat(owner, span_hypnophrase("<i>...[lowertext(hypnotic_phrase)]...</i>"))
		if(2)
			new /datum/hallucination/chat(owner, TRUE, FALSE, span_hypnophrase("[hypnotic_phrase]"))
