/atom/proc/get_codex_value()
	return src

/atom/proc/get_specific_codex_entry()

	var/lore = get_lore_info()
	var/mechanics = get_mechanics_info()
	var/antag = get_antag_info()
	var/list/attributes = get_attributes()
	var/list/get_mechanics_ui = get_mechanics()
	var/list/background = get_background_info()
	var/is_gun = isgun(src)
	var/is_clothing = isclothing(src)
	if(!lore && !mechanics && !antag)
		return FALSE

	var/datum/codex_entry/entry = new(name, list(type), _lore_text = lore, _mechanics_text = mechanics, _antag_text = antag, \
									_attributes = attributes, \
									_mechanics = get_mechanics_ui, \
									_background = background, \
									_description = desc, \
									_is_gun = is_gun, \
									_is_clothing = is_clothing)
	return entry

/atom/proc/get_mechanics_info()
	var/list/mechanics_text = list()
	if(SEND_SIGNAL(src, COMSIG_ATOM_GET_MECHANICS_INFO, mechanics_text) & COMPONENT_MECHANICS_CHANGE)
		. = mechanics_text.Join("")

/atom/proc/get_antag_info()

/atom/proc/get_lore_info()

