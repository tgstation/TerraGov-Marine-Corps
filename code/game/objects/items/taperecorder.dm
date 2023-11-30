/obj/item/taperecorder
	desc = "A device that can record up to an hour of dialogue and play it back. It automatically translates the content in playback."
	name = "universal recorder"
	icon = 'icons/obj/device.dmi'
	icon_state = "taperecorderidle"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL

	var/recording = 0
	var/playing = 0
	var/timerecorded = 0
	var/playsleepseconds = 0
	var/list/storedinfo = list()
	var/list/timestamp = list()
	var/canprint = 1
	flags_atom = CONDUCT
	throwforce = 2
	throw_speed = 4
	throw_range = 20

/obj/item/taperecorder/Initialize(mapload)
	. = ..()
	become_hearing_sensitive()

/obj/item/taperecorder/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, spans, message_mode)
	. = ..()

	if(recording)
		timestamp += timerecorded
		storedinfo += "\[[time2text(timerecorded * 10, "mm:ss")]\] [speaker.name]: \"[message]\""

/obj/item/taperecorder/verb/record()
	set name = "Start Recording"
	set category = "Object"

	if(usr.stat)
		return
	icon_state = "taperecorderrecording"
	if(timerecorded < 3600 && playing == 0)
		to_chat(usr, span_notice("Recording started."))
		recording = 1
		timestamp+= timerecorded
		storedinfo += "\[[time2text(timerecorded*10,"mm:ss")]\] Recording started."
		for(timerecorded, timerecorded<3600)
			if(recording == 0)
				break
			timerecorded++
			sleep(1 SECONDS)
		recording = 0
		icon_state = "taperecorderidle"
		return
	else
		to_chat(usr, span_notice("Either [src]'s memory is full, or it is currently playing back its memory."))


/obj/item/taperecorder/verb/stop()
	set name = "Stop"
	set category = "Object"

	if(usr.stat)
		return
	if(recording == 1)
		recording = 0
		timestamp+= timerecorded
		storedinfo += "\[[time2text(timerecorded*10,"mm:ss")]\] Recording stopped."
		to_chat(usr, span_notice("Recording stopped."))
		icon_state = "taperecorderidle"
		return
	else if(playing == 1)
		playing = 0
		var/turf/T = get_turf(src)
		T.visible_message("<font color=Maroon><B>[src]</B>: Playback stopped.</font>")
		icon_state = "taperecorderidle"
		return


/obj/item/taperecorder/verb/clear_memory()
	set name = "Clear Memory"
	set category = "Object"

	if(usr.stat)
		return
	if(recording == 1 || playing == 1)
		to_chat(usr, span_notice("You can't clear the memory while playing or recording!"))
		return
	else
		if(storedinfo)	storedinfo.Cut()
		if(timestamp)	timestamp.Cut()
		timerecorded = 0
		to_chat(usr, span_notice("Memory cleared."))
		return


/obj/item/taperecorder/verb/playback_memory()
	set name = "Playback Memory"
	set category = "Object"

	if(usr.stat)
		return
	if(recording == 1)
		to_chat(usr, span_notice("You can't playback when recording!"))
		return
	if(playing == 1)
		to_chat(usr, span_notice("You're already playing!"))
		return
	playing = 1
	icon_state = "taperecorderplaying"
	to_chat(usr, span_notice("Playing started."))
	for(var/i=1,timerecorded<3600,sleep(10 * (playsleepseconds) ))
		if(playing == 0)
			break
		if(length(storedinfo) < i)
			break
		var/turf/T = get_turf(src)
		T.visible_message("<font color=Maroon><B>[src]</B>: [storedinfo[i]]</font>")
		if(length(storedinfo) < i+1)
			playsleepseconds = 1
			sleep(1 SECONDS)
			T = get_turf(src)
			T.visible_message("<font color=Maroon><B>[src]</B>: End of recording.</font>")
		else
			playsleepseconds = timestamp[i+1] - timestamp[i]
		if(playsleepseconds > 14)
			sleep(1 SECONDS)
			T = get_turf(src)
			T.visible_message("<font color=Maroon><B>[src]</B>: Skipping [playsleepseconds] seconds of silence</font>")
			playsleepseconds = 1
		i++
	icon_state = "taperecorderidle"
	playing = 0


/obj/item/taperecorder/verb/print_transcript()
	set name = "Print Transcript"
	set category = "Object"

	if(usr.stat)
		return
	if(!canprint)
		to_chat(usr, span_notice("The recorder can't print that fast!"))
		return
	if(recording == 1 || playing == 1)
		to_chat(usr, span_notice("You can't print the transcript while playing or recording!"))
		return
	to_chat(usr, span_notice("Transcript printed."))
	var/obj/item/paper/P = new /obj/item/paper(get_turf(src))
	var/t1 = "<B>Transcript:</B><BR><BR>"
	for(var/i=1,length(storedinfo) >= i,i++)
		t1 += "[storedinfo[i]]<BR>"
	P.info = t1
	P.name = "Transcript"
	canprint = 0
	sleep(30 SECONDS)
	canprint = 1


/obj/item/taperecorder/attack_self(mob/user)
	if(recording == 0 && playing == 0)
		if(usr.stat)
			return
		icon_state = "taperecorderrecording"
		if(timerecorded < 3600 && playing == 0)
			to_chat(usr, span_notice("Recording started."))
			recording = 1
			timestamp+= timerecorded
			storedinfo += "\[[time2text(timerecorded*10,"mm:ss")]\] Recording started."
			for(timerecorded, timerecorded<3600)
				if(recording == 0)
					break
				timerecorded++
				sleep(1 SECONDS)
			recording = 0
			icon_state = "taperecorderidle"
			return
		else
			to_chat(usr, span_warning("Either [src]'s memory is full, or it is currently playing back its memory."))
	else
		if(usr.stat)
			to_chat(usr, "Not when you're incapacitated.")
			return
		if(recording == 1)
			recording = 0
			timestamp+= timerecorded
			storedinfo += "\[[time2text(timerecorded*10,"mm:ss")]\] Recording stopped."
			to_chat(usr, span_notice("Recording stopped."))
			icon_state = "taperecorderidle"
			return
		else if(playing == 1)
			playing = 0
			audible_message("<font color=Maroon><B>[src]</B>: Playback stopped.</font>")
			icon_state = "taperecorderidle"
			return
		else
			to_chat(usr, span_warning("Stop what?"))
			return
