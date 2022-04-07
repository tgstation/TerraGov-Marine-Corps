/atom/proc/get_codex_value()
	return src

/atom/proc/get_specific_codex_entry()

	var/lore = get_lore_info()
	var/mechanics = get_mechanics_info()
	var/antag = get_antag_info()
	if(!lore && !mechanics && !antag)
		return FALSE

	var/datum/codex_entry/entry = new(name, list(type), _lore_text = lore, _mechanics_text = mechanics, _antag_text = antag)
	return entry

/atom/proc/get_mechanics_info()

/atom/proc/get_antag_info()

/atom/proc/get_lore_info()

