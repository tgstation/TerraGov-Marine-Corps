/client/proc/play_imported_sound(S as sound)
	set category = "Fun"
	set name = "Play Imported Sound"
	set desc = "Play a sound imported from anywhere on your computer."
	if(!check_rights(R_SOUNDS))	return

	var/sound/uploaded_sound = sound(S, repeat = 0, wait = 1, channel = 777)
	uploaded_sound.priority = 250
	var/heard = 0

	switch( alert("Play sound globally or locally?", "Sound", "Global", "Local", "Cancel") )
		if("Global")
			for(var/mob/M in player_list)
				if(M.client.prefs.toggles_sound & SOUND_MIDI)
					sound_to(M,uploaded_sound)
					heard ++
		if("Local")
			playsound(get_turf(src.mob), uploaded_sound, 50, 0)
			for(var/mob/M in view())
				heard ++
		if("Cancel")
			return

	log_admin("[key_name(src)] played sound `[S]` for [heard] player(s) - the rest have disabled admin midis.")
	message_admins("[key_name_admin(src)] played sound `[S]` for [heard] player(s) - the rest have disabled admin midis.", 1)
	feedback_add_details("admin_verb","PCS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	// A 30 sec timer used to show Admins how many players are silencing the sound after it starts - see preferences_toggles.dm
	var/midi_playing_timer = 300 // Should match with the midi_silenced spawn() in preferences_toggles.dm
	midi_playing = 1
	spawn(midi_playing_timer)
		midi_playing = 0


/client/proc/play_sound_from_list()
	set category = "Fun"
	set name = "Play Sound From List"
	set desc = "Play a sound already in the project from a pre-made list."
	if(!check_rights(R_SOUNDS))	return

	var/list/sounds = file2list("sound/soundlist.txt");
	sounds += "--CANCEL--"

	var/melody = input("Select a sound to play", "Sound list", "--CANCEL--") in sounds

	if(melody == "--CANCEL--")	return

	play_imported_sound(melody)
	feedback_add_details("admin_verb","PDS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
