/obj/item/organ/tongue
	name = "tongue"
	desc = ""
	icon_state = "tonguenormal"
	zone = BODY_ZONE_PRECISE_MOUTH
	slot = ORGAN_SLOT_TONGUE
	attack_verb = list("licked", "slobbered", "slapped", "frenched", "tongued")
	var/list/languages_possible
	var/say_mod = null
	var/taste_sensitivity = 15 // lower is more sensitive.
	var/modifies_speech = FALSE
	var/static/list/languages_possible_base = typecacheof(list(
		/datum/language/common,
		/datum/language/dwarvish,
		/datum/language/elvish,
		/datum/language/celestial,
		/datum/language/hellspeak,
		/datum/language/beast
	))

/obj/item/organ/tongue/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_base

/obj/item/organ/tongue/proc/handle_speech(datum/source, list/speech_args)

/obj/item/organ/tongue/Insert(mob/living/carbon/M, special = 0)
	..()
	if(say_mod && M.dna && M.dna.species)
		M.dna.species.say_mod = say_mod
	if (modifies_speech)
		RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	M.UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/organ/tongue/Remove(mob/living/carbon/M, special = 0)
	..()
	if(say_mod && M.dna && M.dna.species)
		M.dna.species.say_mod = initial(M.dna.species.say_mod)
	UnregisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	M.RegisterSignal(M, COMSIG_MOB_SAY, TYPE_PROC_REF(/mob/living/carbon, handle_tongueless_speech))

/obj/item/organ/tongue/could_speak_in_language(datum/language/dt)
	return is_type_in_typecache(dt, languages_possible)

/obj/item/organ/tongue/lizard
	name = "forked tongue"
	desc = ""
	icon_state = "tonguelizard"
	say_mod = "hisses"
	taste_sensitivity = 10 // combined nose + tongue, extra sensitive
	modifies_speech = TRUE

/obj/item/organ/tongue/lizard/handle_speech(datum/source, list/speech_args)
	var/static/regex/lizard_hiss = new("s+", "g")
	var/static/regex/lizard_hiSS = new("S+", "g")
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = lizard_hiss.Replace(message, "sss")
		message = lizard_hiSS.Replace(message, "SSS")
	speech_args[SPEECH_MESSAGE] = message

/obj/item/organ/tongue/fly
	name = "proboscis"
	desc = ""
	icon_state = "tonguefly"
	say_mod = "buzzes"
	taste_sensitivity = 25 // you eat vomit, this is a mercy
	modifies_speech = TRUE

/obj/item/organ/tongue/fly/handle_speech(datum/source, list/speech_args)
	var/static/regex/fly_buzz = new("z+", "g")
	var/static/regex/fly_buZZ = new("Z+", "g")
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = fly_buzz.Replace(message, "zzz")
		message = fly_buZZ.Replace(message, "ZZZ")
	speech_args[SPEECH_MESSAGE] = message

/obj/item/organ/tongue/abductor
	name = "superlingual matrix"
	desc = ""
	icon_state = "tongueayylmao"
	say_mod = "gibbers"
	taste_sensitivity = 101 // ayys cannot taste anything.
	modifies_speech = TRUE
	var/mothership

/obj/item/organ/tongue/abductor/attack_self(mob/living/carbon/human/H)
	if(!istype(H))
		return

	var/obj/item/organ/tongue/abductor/T = H.getorganslot(ORGAN_SLOT_TONGUE)
	if(!istype(T))
		return

	if(T.mothership == mothership)
		to_chat(H, "<span class='notice'>[src] is already attuned to the same channel as my own.</span>")

	H.visible_message("<span class='notice'>[H] holds [src] in their hands, and concentrates for a moment.</span>", "<span class='notice'>I attempt to modify the attunation of [src].</span>")
	if(do_after(H, delay=15, target=src))
		to_chat(H, "<span class='notice'>I attune [src] to my own channel.</span>")
		mothership = T.mothership

/obj/item/organ/tongue/abductor/examine(mob/M)
	. = ..()
	if(HAS_TRAIT(M, TRAIT_ABDUCTOR_TRAINING) || HAS_TRAIT(M.mind, TRAIT_ABDUCTOR_TRAINING) || isobserver(M))
		if(!mothership)
			. += "<span class='notice'>It is not attuned to a specific mothership.</span>"
		else
			. += "<span class='notice'>It is attuned to [mothership].</span>"

/obj/item/organ/tongue/abductor/handle_speech(datum/source, list/speech_args)
	//Hacks
	var/message = speech_args[SPEECH_MESSAGE]
	var/mob/living/carbon/human/user = usr
	var/rendered = "<span class='abductor'><b>[user.real_name]:</b> [message]</span>"
	user.log_talk(message, LOG_SAY, tag="abductor")
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		var/obj/item/organ/tongue/abductor/T = H.getorganslot(ORGAN_SLOT_TONGUE)
		if(!istype(T))
			continue
		if(mothership == T.mothership)
			to_chat(H, rendered)

	for(var/mob/M in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(M, user)
		to_chat(M, "[link] [rendered]")

	speech_args[SPEECH_MESSAGE] = ""

/obj/item/organ/tongue/zombie
	name = "rotting tongue"
	desc = ""
	icon_state = "tonguezombie"
	say_mod = "moans"
	modifies_speech = TRUE
	taste_sensitivity = 32

/obj/item/organ/tongue/zombie/handle_speech(datum/source, list/speech_args)
	var/list/message_list = splittext(speech_args[SPEECH_MESSAGE], " ")
	var/maxchanges = max(round(message_list.len / 1.5), 2)

	for(var/i = rand(maxchanges / 2, maxchanges), i > 0, i--)
		var/insertpos = rand(1, message_list.len - 1)
		var/inserttext = message_list[insertpos]

		if(!(copytext(inserttext, length(inserttext) - 2) == "..."))
			message_list[insertpos] = inserttext + "..."

		if(prob(20) && message_list.len > 3)
			message_list.Insert(insertpos, "[pick("BRAINS", "Brains", "Braaaiinnnsss", "BRAAAIIINNSSS")]...")

	speech_args[SPEECH_MESSAGE] = jointext(message_list, " ")

/obj/item/organ/tongue/alien
	name = "alien tongue"
	desc = ""
	icon_state = "tonguexeno"
	say_mod = "hisses"
	taste_sensitivity = 10 // LIZARDS ARE ALIENS CONFIRMED
	modifies_speech = TRUE // not really, they just hiss
	var/static/list/languages_possible_alien = typecacheof(list(
		/datum/language/xenocommon,
		/datum/language/common,
		/datum/language/draconic,
		/datum/language/monkey))

/obj/item/organ/tongue/alien/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_alien

/obj/item/organ/tongue/alien/handle_speech(datum/source, list/speech_args)
	playsound(owner, "hiss", 25, TRUE, TRUE)

/obj/item/organ/tongue/bone
	name = "bone \"tongue\""
	desc = ""
	icon_state = "tonguebone"
	say_mod = "rattles"
	attack_verb = list("bitten", "chattered", "chomped", "enamelled", "boned")
	taste_sensitivity = 101 // skeletons cannot taste anything
	modifies_speech = TRUE
	var/chattering = FALSE
	var/phomeme_type = "sans"
	var/list/phomeme_types = list("sans", "papyrus")

/obj/item/organ/tongue/bone/Initialize()
	. = ..()
	phomeme_type = pick(phomeme_types)

/obj/item/organ/tongue/bone/handle_speech(datum/source, list/speech_args)
	if (chattering)
		chatter(speech_args[SPEECH_MESSAGE], phomeme_type, source)
	switch(phomeme_type)
		if("sans")
			speech_args[SPEECH_SPANS] |= SPAN_SANS
		if("papyrus")
			speech_args[SPEECH_SPANS] |= SPAN_PAPYRUS

/obj/item/organ/tongue/bone/plasmaman
	name = "plasma bone \"tongue\""
	desc = ""
	icon_state = "tongueplasma"
	modifies_speech = FALSE

/obj/item/organ/tongue/robot
	name = "robotic voicebox"
	desc = ""
	status = ORGAN_ROBOTIC
	icon_state = "tonguerobot"
	say_mod = "states"
	attack_verb = list("beeped", "booped")
	modifies_speech = TRUE
	taste_sensitivity = 25 // not as good as an organic tongue

/obj/item/organ/tongue/robot/can_speak_in_language(datum/language/dt)
	return TRUE // THE MAGIC OF ELECTRONICS

/obj/item/organ/tongue/robot/handle_speech(datum/source, list/speech_args)
	speech_args[SPEECH_SPANS] |= SPAN_ROBOT

/obj/item/organ/tongue/snail
	name = "snailtongue"
	modifies_speech = TRUE

/obj/item/organ/tongue/snail/handle_speech(datum/source, list/speech_args)
	var/new_message
	var/message = speech_args[SPEECH_MESSAGE]
	for(var/i in 1 to length(message))
		if(findtext("ABCDEFGHIJKLMNOPWRSTUVWXYZabcdefghijklmnopqrstuvwxyz", message[i])) //Im open to suggestions
			new_message += message[i] + message[i] + message[i] //aaalllsssooo ooopppeeennn tttooo sssuuuggggggeeessstttiiiooonsss
		else
			new_message += message[i]
	speech_args[SPEECH_MESSAGE] = new_message
