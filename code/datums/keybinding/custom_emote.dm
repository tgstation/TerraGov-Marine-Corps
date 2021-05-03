/datum/keybinding/custom_emote
	category = CATEGORY_CUSTOM_EMOTE
	weight = WEIGHT_EMOTE
	keybind_signal = COMSIG_KB_EMOTE
	/// They ID of the custom emote
	var/custom_emote_id

/// Link the keybind and the custom emote
/datum/keybinding/custom_emote/proc/set_id(id)
	custom_emote_id = id
	description = "Run the [id]th custom emote"
	name = "Custom emote :[id]"
	full_name = name

/datum/keybinding/custom_emote/down(client/user)
	. = ..()
	var/datum/custom_emote/emote = user.prefs.custom_emotes[custom_emote_id]
	emote.run_custom_emote(user.mob)
