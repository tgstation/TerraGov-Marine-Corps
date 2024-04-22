/client/proc/view_rogue_manifest()
	var/dat
	dat += "<h1>Round ID: [GLOB.rogue_round_id]</h1>"
	dat += "<h4>- Inhabitants of Rogue Lands -</h4>"
	for(var/X in GLOB.character_list)
		dat += "[GLOB.character_list[X]]"

	src << browse(dat, "window=manifest;size=387x420;can_close=1")