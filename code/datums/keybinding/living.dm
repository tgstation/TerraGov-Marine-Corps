/datum/keybinding/living
	category = CATEGORY_LIVING
	weight = WEIGHT_MOB


/datum/keybinding/living/resist
	hotkey_keys = list("B")
	name = "resist"
	full_name = "Resist"
	description = "Break free of your current state. Handcuffs, on fire, being trapped in an alien nest? Resist!"
	keybind_signal = COMSIG_KB_LIVING_RESIST_DOWN

/datum/keybinding/living/resist/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/L = user.mob
	L.resist()
	return TRUE

/datum/keybinding/living/attempt_jump
	hotkey_keys = list("C")
	name = "Jump"
	full_name = "Jump"
	description = "Jumps, if your mob is capable of doing so."
	keybind_signal = COMSIG_KB_LIVING_JUMP_DOWN

/datum/keybinding/living/attempt_jump/up(client/user)
	SEND_SIGNAL(user.mob, COMSIG_KB_LIVING_JUMP_UP)
	return TRUE
