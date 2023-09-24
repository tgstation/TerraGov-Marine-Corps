/client/verb/search_codex(searching as null|text)

	set name = "Search Codex"
	set category = "IC"
	set src = usr

	if(!mob || !SScodex)
		return

	if(codex_on_cooldown || !mob.can_use_codex())
		to_chat(src, span_warning("You cannot perform codex actions currently."))
		return

	if(!searching)
		searching = tgui_input_text(usr, "Enter a search string.", "Codex Search", encode = FALSE)
		if(!searching)
			return

	if(codex_on_cooldown || !mob.can_use_codex())
		to_chat(src, span_warning("You cannot perform codex actions currently."))
		return

	codex_on_cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, codex_on_cooldown, FALSE), 3 SECONDS)

	var/list/all_entries = SScodex.retrieve_entries_for_string(searching)

	if(LAZYLEN(all_entries) == 1)
		SScodex.present_codex_entry(mob, all_entries[1])
	else
		if(LAZYLEN(all_entries) > 1)
			var/list/codex_data = list("<h3><b>[length(all_entries)] matches</b> for '[searching]':</h3>")
			if(LAZYLEN(all_entries) > max_codex_entries_shown)
				codex_data += "Showing first <b>[max_codex_entries_shown]</b> entries. <b>[length(all_entries) - 5] result\s</b> omitted.</br>"
			codex_data += "<table width = 100%>"
			for(var/i = 1 to min(length(all_entries), max_codex_entries_shown))
				var/datum/codex_entry/entry = all_entries[i]
				codex_data += "<tr><td>[entry.display_name]</td><td><a href='?_src_=codex;show_examined_info=[text_ref(entry)];show_to=[text_ref(mob)]'>View</a></td></tr>"
			codex_data += "</table>"
			var/datum/browser/popup = new(mob, "codex-search", "Codex Search")
			popup.set_content(jointext(codex_data, null))
			popup.open()
		else
			to_chat(src, span_notice("The codex reports <b>no matches</b> for '[searching]'."))

/client/verb/list_codex_entries()

	set name = "List Codex Entries"
	set category = "IC"
	set src = usr

	if(!mob || !SScodex.initialized)
		return

	if(codex_on_cooldown || !mob.can_use_codex())
		to_chat(src, span_warning("You cannot perform codex actions currently."))
		return
	codex_on_cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, codex_on_cooldown, FALSE), 10 SECONDS)

	to_chat(mob, span_notice("The codex forwards you an index file."))

	var/datum/browser/popup = new(mob, "codex-index", "Codex Index")
	var/list/codex_data = list("<h2>Codex Entries</h2>")
	codex_data += "<table width = 100%>"

	var/last_first_letter
	for(var/thing in SScodex.index_file)
		var/datum/codex_entry/entry = SScodex.index_file[thing]
		if(!entry.mechanics_text && !entry.lore_text)
			continue

		var/first_letter = uppertext(copytext(thing, 1, 2))
		if(first_letter != last_first_letter)
			last_first_letter = first_letter
			codex_data += "<tr><td colspan = 2><hr></td></tr>"
			codex_data += "<tr><td colspan = 2>[last_first_letter]</td></tr>"
			codex_data += "<tr><td colspan = 2><hr></td></tr>"
		codex_data += "<tr><td>[thing]</td><td><a href='?_src_=codex;show_examined_info=\ref[SScodex.index_file[thing]];show_to=[text_ref(mob)]'>View</a></td></tr>"
	codex_data += "</table>"
	popup.set_content(jointext(codex_data, null))
	popup.open()
