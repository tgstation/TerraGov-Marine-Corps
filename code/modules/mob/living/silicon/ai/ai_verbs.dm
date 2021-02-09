/mob/living/silicon/ai/verb/ai_network_change()
	set category = "Silicon"
	set name = "Jump To Network"

	if(incapacitated())
		return

	unset_interaction()
	cameraFollow = null

	var/new_network = tgui_input_list(src, "Which network would you like to view?", "Jump To Network", available_networks)
	if(!new_network)
		return

	if(!eyeobj)
		view_core()
		return

	for(var/i in GLOB.cameranet.cameras)
		var/obj/machinery/camera/C = i

		if(!C.can_use())
			continue

		if(new_network in C.network)
			eyeobj.setLoc(get_turf(C))
			break

	to_chat(src, "<span class='notice'>Switched to the \"[uppertext(new_network)]\" camera network.</span>")



/mob/living/silicon/ai/verb/display_status()
	set category = "Silicon"
	set name = "Display Status"

	if(incapacitated())
		return

	var/list/ai_emotions = list("Very Happy", "Happy", "Neutral", "Unsure", "Confused", "Sad", "BSOD", "Blank", "Problems?", "Awesome", "Facepalm", "Thinking", "Friend Computer", "Dorfy", "Blue Glow", "Red Glow")
	var/emote = tgui_input_list("Please, select a status!", "AI Status", ai_emotions)
	if(!emote)
		return

	for(var/i in GLOB.ai_status_displays)
		var/obj/machinery/status_display/ai/SD = i
		SD.emotion = emote
		SD.update()

	if(emote == "Friend Computer")
		var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)

		if(!frequency)
			return

		var/datum/signal/status_signal = new(list("command" = "friendcomputer"))
		frequency.post_signal(src, status_signal)

	to_chat(src, "<span class='notice'>Changed display status to: [emote]</span>")


/mob/living/silicon/ai/verb/change_hologram()
	set category = "Silicon"
	set name = "Change Hologram"

	if(incapacitated())
		return

	var/hologram = tgui_alert(src, "Would you like to select a hologram based on a crew member, an animal, or switch to a unique avatar?", "Hologram", list("Crew Member", "Unique", "Animal"))
	switch(hologram)
		if("Crew Member")
			var/list/personnel_list = list()

			for(var/datum/data/record/t in GLOB.datacore.general)
				personnel_list["[t.fields["name"]]: [t.fields["rank"]]"] = t.fields["photo_front"]

			if(!length(personnel_list))
				to_chat(src, "<span class='warning'>No suitable records found. Aborting.</span>")
				return

			hologram = tgui_input_list(src, "Select a crew member:", null,personnel_list)
			var/icon/character_icon = personnel_list[hologram]
			if(!character_icon)
				return

			holo_icon = getHologramIcon(icon(character_icon))

		if("Animal")
			var/list/icon_list = list(
			"bear" = 'icons/mob/animal.dmi',
			"carp" = 'icons/mob/animal.dmi',
			"chicken_brown" = 'icons/mob/animal.dmi',
			"corgi" = 'icons/mob/pets.dmi',
			"cow" = 'icons/mob/animal.dmi',
			"crab" = 'icons/mob/animal.dmi',
			"fox" = 'icons/mob/pets.dmi',
			"goat" = 'icons/mob/animal.dmi',
			"cat" = 'icons/mob/pets.dmi',
			"cat2" = 'icons/mob/pets.dmi',
			"parrot_fly" = 'icons/mob/animal.dmi',
			"pug" = 'icons/mob/pets.dmi',
			"guard" = 'icons/mob/animal.dmi'
			)

			hologram = tgui_input_list(src, "Please select a hologram:", null, icon_list)
			if(!hologram)
				return

			holo_icon = getHologramIcon(icon(icon_list[hologram], hologram))

		if("Unique")
			var/list/icon_list = list(
				"default" = 'icons/mob/ai.dmi',
				"floating face" = 'icons/mob/ai.dmi',
				"alienq" = 'icons/mob/alien.dmi',
				"horror" = 'icons/mob/ai.dmi'
				)

			hologram = tgui_input_list(src, "Please select a hologram:", null, icon_list)
			if(!hologram)
				return

			holo_icon = getHologramIcon(icon(icon_list[hologram], hologram))

		else
			return

	to_chat(src, "<span class='notice'>Changed hologram to: [hologram]</span>")


/mob/living/silicon/ai/verb/toggle_sensors()
	set category = "Silicon"
	set name = "Toggle Sensors"

	if(incapacitated())
		return

	toggle_sensor_mode()


/mob/living/silicon/ai/verb/make_announcement()
	set category = "Silicon"
	set name = "Make Announcement"

	if(incapacitated())
		return

	if(last_announcement + 60 SECONDS > world.time)
		to_chat(src, "<span class='warning'>You must wait before announcing again.</span>")
		return

	var/input = stripped_input(usr, "Please write a message to announce to the station crew.", "Announcement")
	if(!input || incapacitated())
		return

	last_announcement = world.time
	priority_announce(input, "[src] Announcement", sound = 'sound/AI/aireport.ogg')


/mob/living/silicon/ai/verb/ai_core_display()
	set category = "Silicon"
	set name = "AI Core Display"

	if(incapacitated())
		return

	var/list/iconstates = GLOB.ai_core_display_screens
	for(var/option in iconstates)
		if(option == "Random")
			iconstates[option] = image(icon = icon, icon_state = "ai-random")
			continue
		iconstates[option] = image(icon = icon, icon_state = resolve_ai_icon(option))

	view_core()

	var/ai_core_icon = tgui_input_list(src, "Choose your AI core display icon.", "AI Core Display", iconstates)
	if(!ai_core_icon || incapacitated())
		return

	icon_state = resolve_ai_icon(ai_core_icon)


/mob/living/silicon/ai/cancel_camera()
	set category = "Silicon"
	set name = "Cancel Camera View"

	view_core()


/mob/living/silicon/ai/verb/toggle_acceleration()
	set category = "Silicon"
	set name = "Toggle Camera Acceleration"

	if(incapacitated())
		return

	acceleration = !acceleration

	to_chat(src, "<span class='notice'>Camera acceleration has been [acceleration ? "enabled" : "disabled"].</span>")


/mob/living/silicon/ai/verb/radio_settings()
	set category = "Silicon"
	set name = "Radio Settings"

	if(incapacitated())
		return

	if(!radio)
		to_chat(src, "<span class='warning'>No internal radio detected.</span>")
		return

	to_chat(src, "<span class='notice'>Accessing internal radio settings.</span>")
	radio.interact(src)


/mob/living/silicon/ai/verb/view_manifest()
	set category = "Silicon"
	set name = "View Crew Manifest"

	if(incapacitated())
		return

	var/dat = GLOB.datacore.get_manifest()

	var/datum/browser/popup = new(src, "manifest", "<div align='center'>Crew Manifest</div>", 370, 420)
	popup.set_content(dat)
	popup.open(FALSE)


/mob/living/silicon/ai/verb/show_laws()
	set category = "Silicon"
	set name = "Show Laws"

	if(incapacitated())
		return

	to_chat(src, "<span class='notice'><b>Obey these laws:</b></span>")
	for(var/i in laws)
		to_chat(src, "<span class='notice'>[i]</span>")


/mob/living/silicon/ai/verb/state_laws()
	set category = "Silicon"
	set name = "State Laws"

	if(incapacitated())
		return

	if(tgui_alert(src, "Are you sure you want to announce your laws[radiomod ? " over the [radiomod] channel" : ""]?", "State Laws", list("Yes", "No")) != "Yes")
		return

	say("[radiomod] Current Active Lawset:")

	var/delay = 1 SECONDS
	for(var/i in laws)
		addtimer(CALLBACK(src, /atom/movable/.proc/say, "[radiomod] [i]"), delay)
		delay += 1 SECONDS


/mob/living/silicon/ai/verb/set_autosay()
	set category = "Silicon"
	set name = "Set Announce Mode"

	if(incapacitated())
		return

	if(!radio)
		to_chat(src, "Radio not detected.")
		return

	var/chan = input("Select a channel:") as null|anything in list("Default", "None") + radio.channels
	if(!chan)
		return

	if(chan == "Default")
		radiomod = ";"
		chan += " ([radio.frequency])"
	else if(chan == "None")
		radiomod = ""
	else
		for(var/key in GLOB.department_radio_keys)
			if(GLOB.department_radio_keys[key] == chan)
				radiomod = ":" + key
				break

	to_chat(src, "<span class='notice'>Automatic announcements [chan == "None" ? "will not use the radio." : "set to [chan]."]</span>")


/mob/living/silicon/ai/verb/shutdown_systems()
	set category = "Silicon"
	set name = "Shutdown Systems"


	if(tgui_alert(src, "Do you want to shutdown your systems? WARNING: This will permanently put you out of your mob.", "Shutdown Systems", list("Yes", "No")) != "Yes")
		return

	to_chat(src, "<span class='notice'>Systems shutting down...</span>")

	ghostize(FALSE)
	offer_mob()
