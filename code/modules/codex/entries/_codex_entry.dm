/datum/codex_entry
	var/display_name
	var/list/associated_strings
	var/list/associated_paths
	var/lore_text
	var/mechanics_text
	var/antag_text

/datum/codex_entry/dd_SortValue()
	return display_name

/datum/codex_entry/New(_display_name, list/_associated_paths, list/_associated_strings, _lore_text, _mechanics_text, _antag_text)

	if(_display_name)       
		display_name = _display_name
	if(_associated_paths)   
		associated_paths = _associated_paths
	if(_associated_strings) 
		associated_strings = _associated_strings
	if(_lore_text)          
		lore_text = _lore_text
	if(_mechanics_text)     
		mechanics_text = _mechanics_text
	if(_antag_text)         
		antag_text = _antag_text

	if(associated_paths && associated_paths.len)
		for(var/tpath in associated_paths)
			var/atom/thing = tpath
			LAZYADD(associated_strings, sanitize(lowertext(initial(thing.name))))
	if(display_name)
		LAZYADD(associated_strings, display_name)
	else if(associated_strings && associated_strings.len)
		display_name = associated_strings[1]
	return ..()

/*How to write a codex entry.

example:

/datum/codex_entry/barsign
	display_name = "Barsign"
	associated_paths = list(/obj/structure/sign/double/barsign)
	mechanics_text = "If your ID has bar access, you may swipe it on this sign to alter its display."
	lore_text = "They say the first barsign ever invented was actually a severed head. Which is why the Kingshead is such a popular pub name."
	antag_text = "I don't see how this could be used for antagonistic purposes."

/datum/codex_entry/barsign 
	- The unique identifier path for this entry. this part must be unique.
	display_name = "Barsign" 
		- what you want to show up in the big list of entries when people look at the codex as a whole.
	associated_paths = list(/obj/structure/sign/double/barsign)
		- This associated path will overwrite any automated process for generating a codex entry.
		- if you want it to work with the automated system, which is limited to guns, clothing, and storage items at the moment.
			do not include this line, but instead make the display_name match your item exactly.
		- when making it exactly match the var/name, do not include \improper or any other such formatting.
			display_name = "M276 pattern toolbelt rig" is good.
			display_name = "\improper M276 pattern toolbelt rig" is bad.
	mechanics_text = "If your ID has bar access, you may swipe it on this sign to alter its display."
		- This is what you include if you want to talk to the player directly.
	lore_text = "They say the first barsign ever invented was actually a severed head. Which is why the Kingshead is such a popular pub name."
		- This is what you include if you want to give some fun in character lore. Real world lore is also acceptable.
	antag_text = "I don't see how this could be used for antagonistic purposes."
		- This is for antagonists eyes only. Currently TGMC does not have any of those. As such you can ignore what is here.
*/
