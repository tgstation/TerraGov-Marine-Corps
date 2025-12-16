/obj/item/radio/loadout_tool
	name = "Personal Holophone"
	desc = "A holophone used for radio communication and other personal things, duh. Also used to download miniskillsofts into your neural implant RAM, temporary and less effective than actual skillsofts that are chip based. ALT+CLICK to view loadout and skillsoft menu."
	icon = 'ntf_modular/icons/obj/items/pda.dmi'
	icon_state = "pda_white"
	var/screen_overlay = "pda_on"

/obj/item/pda/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/pda/update_overlays()
	. = ..()
	. += mutable_appearance(icon, screen_overlay)
	. += emissive_appearance(icon, screen_overlay, src)

/obj/item/radio/loadout_tool/AltClick(mob/user)
	. = ..()
	var/datum/faction_stats/your_faction = GLOB.faction_stats_datums[user.faction]
	if(!your_faction)
		to_chat(user, "You don't have the credentials to this network.")
		return
	var/datum/individual_stats/stats = your_faction.get_player_stats(user)
	if(!stats)
		return
	stats.current_mob = user //taking over ssd's creates a mismatch
	//we have to update selected tab/job so we load the correct data for the UI
	var/mob/living/living_user = user

	if(!isliving(user) || !(living_user?.job?.title in stats.valid_jobs))
		stats.selected_job = stats.valid_jobs[1]
	else
		stats.selected_job = living_user.job.title
	stats.selected_tab = "Loadout"
	stats.interact(user)

/obj/item/radio/loadout_tool/red
	icon_state = "pda_red"

/obj/item/radio/loadout_tool/green
	icon_state = "pda_green"

/obj/item/radio/loadout_tool/blue
	icon_state = "pda_blue"

/obj/item/radio/loadout_tool/purple
	icon_state = "pda_purple"

/obj/item/radio/loadout_tool/large
	name = "Personal Holopad"
	desc = "A holopad used for radio communication and other personal things such as watching porn in a larger screen, duh. Also used to download miniskillsofts into your neural implant RAM, temporary and less effective than actual skillsofts that are chip based."
	icon_state = "pda_large_white"
	screen_overlay = "pda_large_on"

/obj/item/radio/loadout_tool/large/red
	icon_state = "pda_large_red"

/obj/item/radio/loadout_tool/large/green
	icon_state = "pda_large_green"

/obj/item/radio/loadout_tool/large/blue
	icon_state = "pda_large_blue"

/obj/item/radio/loadout_tool/large/purple
	icon_state = "pda_large_purple"
