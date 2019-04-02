/*
	Datum based languages. Easily editable and modular.
*/

/datum/language
	var/name = "an unknown language" // Fluff name of language if any.
	var/desc = "A language."         // Short description for 'Check Languages'.
	var/speech_verb = "says"         // 'says', 'hisses', 'farts'.
	var/ask_verb = "asks"            // Used when sentence ends in a ?
	var/exclaim_verb = "exclaims"    // Used when sentence ends in a !
	var/signlang_verb = list()       // list of emotes that might be displayed if this language has NONVERBAL or SIGNLANG flags
	var/colour = "body"         // CSS style to use for strings in this language.
	var/key = "x"                    // Character used to speak in language eg. :o for Unathi.
	var/language_flags = NOFLAGS                    // Various language flags.
	var/native                       // If set, non-native speakers will have trouble speaking.

/datum/language/proc/broadcast(var/mob/living/speaker,var/message,var/speaker_mask)

	speaker.log_talk(message, LOG_SAY)

	for(var/mob/player in GLOB.player_list)

		var/understood = 0

		if(istype(player,/mob/dead))
			understood = 1
		else if((src in player.languages) && check_special_condition(player))
			understood = 1

		if(understood)
			if(!speaker_mask) speaker_mask = speaker.name
			var/msg = "<i><span class='game say'>[name], <span class='name'>[speaker_mask]</span> <span class='message'>[speech_verb], \"<span class='[colour]'>[message]</span><span class='message'>\"</span></span></i>"
			to_chat(player, "[msg]")

/datum/language/proc/check_special_condition(var/mob/other)
	return 1

/datum/language/proc/get_speech_verb(mob/living/carbon/human/H)
	return speech_verb

/datum/language/proc/get_spoken_verb(msg_end, mob/living/carbon/human/H)
	switch(msg_end)
		if("!")
			return exclaim_verb
		if("?")
			return ask_verb
	return speech_verb

/datum/language/unathi
	name = "Sinta'unathi"
	desc = "The common language of Moghes, composed of sibilant hisses and rattles. Spoken natively by Unathi."
	speech_verb = "hisses"
	ask_verb = "hisses"
	exclaim_verb = "roars"
	colour = "soghun"
	key = "o"
	language_flags = WHITELISTED

/datum/language/tajaran
	name = "Siik'tajr"
	desc = "The traditionally employed tongue of Ahdomai, composed of expressive yowls and chirps. Native to the Tajaran."
	speech_verb = "mrowls"
	ask_verb = "mrowls"
	exclaim_verb = "yowls"
	colour = "tajaran"
	key = "j"
	language_flags = WHITELISTED

/datum/language/skrell
	name = "Skrellian"
	desc = "A melodic and complex language spoken by the Skrell of Qerrbalak. Some of the notes are inaudible to humans."
	speech_verb = "warbles"
	ask_verb = "warbles"
	exclaim_verb = "warbles"
	colour = "skrell"
	key = "k"
	language_flags = WHITELISTED

/datum/language/vox
	name = "Vox-pidgin"
	desc = "The common tongue of the various Vox ships making up the Shoal. It sounds like chaotic shrieking to everyone else."
	speech_verb = "shrieks"
	ask_verb = "creels"
	exclaim_verb = "SHRIEKS"
	colour = "vox"
	key = "9"
	language_flags = RESTRICTED

/datum/language/common
	name = "English"
	desc = "Common earth English."
	speech_verb = "says"
	key = "0"
	language_flags = RESTRICTED

/datum/language/common/get_speech_verb(mob/living/carbon/human/H)
	return H.species?.speech_verb_override || speech_verb

/datum/language/common/get_spoken_verb(msg_end, mob/living/carbon/human/H)
	switch(msg_end)
		if("!")
			return pick("exclaims","shouts","yells") //TODO: make the basic proc handle lists of verbs.
		if("?")
			return ask_verb
	return get_speech_verb(H)

/*
/datum/language/human
	name = "Sol Common"
	desc = "A bastardized hybrid of informal English and elements of Mandarin Chinese; the common language of the Sol system."
	colour = "rough"
	key = "1"
	flags = RESTRICTED
*/

// Galactic common languages (systemwide accepted standards).
/datum/language/trader
	name = "Tradeband"
	desc = "Maintained by the various trading cartels in major systems, this elegant, structured language is used for bartering and bargaining."
	speech_verb = "enunciates"
	colour = "say_quote"
	key = "2"

/datum/language/russian
	name = "Russian"
	desc = "An East Slavic language from Earth."
	speech_verb = "says"
	colour = "soghun"
	key = "3"

/datum/language/imperial
	name = "Imperial"
	desc = "English 2: Electric Boogaloo"
	speech_verb = "says"
	colour = "impradio" // same color is radio
	key = "5"

/datum/language/xenocommon
	name = "Xenomorph"
	colour = "alien"
	desc = "The common tongue of the xenomorphs."
	speech_verb = "hisses"
	ask_verb = "hisses"
	exclaim_verb = "hisses"
	key = "x"
	language_flags = RESTRICTED

/datum/language/xenos
	name = "Hivemind"
	desc = "Xenomorphs have the strange ability to commune over a psychic hivemind."
	speech_verb = "hiveminds"
	ask_verb = "hiveminds"
	exclaim_verb = "hiveminds"
	colour = "soghun"
	key = "a"
	language_flags = RESTRICTED|HIVEMIND

/datum/language/xenos/check_special_condition(var/mob/other)

	var/mob/living/carbon/M = other
	if(!istype(M)) //Ghosts etc
		return 1

	if(locate(/datum/internal_organ/xenos/hivenode) in M.internal_organs || istype(M,/mob/living/carbon/Xenomorph))
		return 1

	return 0

//Make queens BOLD text
/datum/language/xenos/broadcast(var/mob/living/speaker,var/message,var/speaker_mask)
	if(istype(speaker,/mob/living/carbon/Xenomorph/Queen))
		message = "<B> [message]</b>"

	..(speaker,message)

/datum/language/binary
	name = "Robot Talk"
	desc = "Most human stations support free-use communications protocols and routing hubs for synthetic use."
	colour = "say_quote"
	speech_verb = "states"
	ask_verb = "queries"
	exclaim_verb = "declares"
	key = "6"
	language_flags = RESTRICTED|HIVEMIND
	var/drone_only

/datum/language/binary/broadcast(var/mob/living/speaker,var/message,var/speaker_mask)

	if(!speaker.binarycheck())
		return

	if (!message)
		return

	var/message_start = "<i><span class='game say'>[name], <span class='name'>[speaker.name]</span>"
	var/message_body = "<span class='message'>[speaker.say_quote(message)], \"[message]\"</span></span></i>"

	for (var/mob/M in GLOB.dead_mob_list)
		if(!istype(M,/mob/new_player) && !istype(M,/mob/living/brain)) //No meta-evesdropping
			M.show_message("[message_start] [message_body]", 2)

	for (var/mob/living/S in GLOB.alive_mob_list)

		if(drone_only && !istype(S,/mob/living/silicon/robot/drone))
			continue
		else if(isAI(S))
			message_start = "<i><span class='game say'>[name], <a href='byond://?src=\ref[S];track2=\ref[S];track=\ref[speaker];trackname=[html_encode(speaker.name)]'><span class='name'>[speaker.name]</span></a>"
		else if (!S.binarycheck())
			continue

		S.show_message("[message_start] [message_body]", 2)

	var/list/listening = hearers(1, src)
	listening -= src

	for (var/mob/living/M in listening)
		if(issilicon(M) || M.binarycheck())
			continue
		M.show_message("<i><span class='game say'><span class='name'>synthesised voice</span> <span class='message'>beeps, \"beep beep beep\"</span></span></i>",2)

	//robot binary xmitter component power usage
	if (iscyborg(speaker))
		var/mob/living/silicon/robot/R = speaker
		var/datum/robot_component/C = R.components["comms"]
		R.cell_use_power(C.active_usage)

/datum/language/binary/drone
	name = "Drone Talk"
	desc = "A heavily encoded damage control coordination stream."
	speech_verb = "transmits"
	ask_verb = "transmits"
	exclaim_verb = "transmits"
	colour = "say_quote"
	key = "d"
	language_flags = RESTRICTED|HIVEMIND
	drone_only = 1

/datum/language/zombie
	name = "Zombie"
	desc = "If you select this from the language screen, expect braaaains..."
	colour = "green"
	key = "4"
	language_flags = RESTRICTED

// Language handling.
/mob/proc/add_language(var/language)
	var/datum/language/new_language = GLOB.all_languages[language]

	if(!istype(new_language) || new_language in languages)
		return 0

	languages.Add(new_language)
	return 1

/mob/proc/remove_language(var/rem_language)

	languages.Remove(GLOB.all_languages[rem_language])

	return 0

// Can we speak this language, as opposed to just understanding it?
/mob/proc/can_speak(datum/language/speaking)

	return (universal_speak || speaking in src.languages)

//TBD
/mob/verb/check_languages()
	set name = "Check Known Languages"
	set category = "IC"
	set src = usr

	var/dat

	for(var/datum/language/L in languages)
		dat += "<b>[L.name] (:[L.key])</b><br/>[L.desc]<br/><br/>"

	var/datum/browser/popup = new(src, "checklanguage", "<div align='center'>Known Languages</div>")
	popup.set_content(dat)
	popup.open(FALSE)