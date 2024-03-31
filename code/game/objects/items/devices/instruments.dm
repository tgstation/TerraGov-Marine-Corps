//copy pasta of the space piano, don't hurt me -Pete
/obj/item/instrument
	name = "generic instrument"
	resistance_flags = FLAMMABLE
	force = 10
	max_integrity = 100
	icon = 'icons/obj/musician.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/instruments_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/instruments_righthand.dmi'
	var/datum/song/handheld/song
	var/instrumentId = "generic"
	var/instrumentExt = "mid"

/obj/item/instrument/Initialize()
	. = ..()
	song = new(instrumentId, src, instrumentExt)

/obj/item/instrument/Destroy()
	QDEL_NULL(song)
	. = ..()

/obj/item/instrument/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] begins to play 'Gloomy Sunday'! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/instrument/Initialize(mapload)
	. = ..()
	if(mapload)
		song.tempo = song.sanitize_tempo(song.tempo) // tick_lag isn't set when the map is loaded

/obj/item/instrument/attack_self(mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>I don't have the dexterity to do this!</span>")
		return 1
	interact(user)

/obj/item/instrument/interact(mob/user)
	ui_interact(user)

/obj/item/instrument/ui_interact(mob/living/user)
	if(!isliving(user) || user.stat || user.restrained() || !(user.mobility_flags & MOBILITY_STAND))
		return

	user.set_machine(src)
	song.interact(user)

/obj/item/instrument/violin
	name = "space violin"
	desc = ""
	icon_state = "violin"
	item_state = "violin"
	hitsound = "swing_hit"
	instrumentId = "violin"

/obj/item/instrument/violin/golden
	name = "golden violin"
	desc = ""
	icon_state = "golden_violin"
	item_state = "golden_violin"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/instrument/piano_synth
	name = "synthesizer"
	desc = ""
	icon_state = "synth"
	item_state = "synth"
	instrumentId = "piano"
	instrumentExt = "ogg"
	var/static/list/insTypes = list("accordion" = "mid", "bikehorn" = "ogg", "glockenspiel" = "mid", "banjo" = "ogg", "guitar" = "ogg", "harmonica" = "mid", "piano" = "ogg", "recorder" = "mid", "saxophone" = "mid", "trombone" = "mid", "violin" = "mid", "xylophone" = "mid")	//No eguitar you ear-rapey fuckers.
	actions_types = list(/datum/action/item_action/synthswitch)

/obj/item/instrument/piano_synth/proc/changeInstrument(name = "piano")
	song.instrumentDir = name
	song.instrumentExt = insTypes[name]

/obj/item/instrument/piano_synth/proc/selectInstrument() // Moved here so it can be used by the action and PAI software panel without copypasta
	var/chosen = input("Choose the type of instrument you want to use", "Instrument Selection", song.instrumentDir) as null|anything in sortList(insTypes)
	if(!insTypes[chosen])
		return
	return changeInstrument(chosen)

/obj/item/instrument/banjo
	name = "banjo"
	desc = ""
	icon_state = "banjo"
	item_state = "banjo"
	instrumentExt = "ogg"
	attack_verb = list("scruggs-styled", "hum-diggitied", "shin-digged", "clawhammered")
	hitsound = 'sound/blank.ogg'
	instrumentId = "banjo"

/obj/item/instrument/guitar
	name = "guitar"
	desc = ""
	icon_state = "guitar"
	item_state = "guitar"
	instrumentExt = "ogg"
	attack_verb = list("played metal on", "serenaded", "crashed", "smashed")
	hitsound = 'sound/blank.ogg'
	instrumentId = "guitar"

/obj/item/instrument/eguitar
	name = "electric guitar"
	desc = ""
	icon_state = "eguitar"
	item_state = "eguitar"
	force = 12
	attack_verb = list("played metal on", "shredded", "crashed", "smashed")
	hitsound = 'sound/blank.ogg'
	instrumentId = "eguitar"
	instrumentExt = "ogg"

/obj/item/instrument/glockenspiel
	name = "glockenspiel"
	desc = ""
	icon_state = "glockenspiel"
	item_state = "glockenspiel"
	instrumentId = "glockenspiel"

/obj/item/instrument/accordion
	name = "accordion"
	desc = ""
	icon_state = "accordion"
	item_state = "accordion"
	instrumentId = "accordion"

/obj/item/instrument/trumpet
	name = "trumpet"
	desc = ""
	icon_state = "trumpet"
	item_state = "trombone"
	instrumentId = "trombone"

/obj/item/instrument/trumpet/spectral
	name = "spectral trumpet"
	desc = ""
	icon_state = "trumpet"
	item_state = "trombone"
	force = 0
	instrumentId = "trombone"
	attack_verb = list("played","jazzed","trumpeted","mourned","dooted","spooked")

/obj/item/instrument/trumpet/spectral/Initialize()
	. = ..()
	AddComponent(/datum/component/spooky)

/obj/item/instrument/trumpet/spectral/attack(mob/living/carbon/C, mob/user)
	..()

/obj/item/instrument/saxophone
	name = "saxophone"
	desc = ""
	icon_state = "saxophone"
	item_state = "saxophone"
	instrumentId = "saxophone"

/obj/item/instrument/saxophone/spectral
	name = "spectral saxophone"
	desc = ""
	icon_state = "saxophone"
	item_state = "saxophone"
	instrumentId = "saxophone"
	force = 0
	attack_verb = list("played","jazzed","saxxed","mourned","dooted","spooked")

/obj/item/instrument/saxophone/spectral/Initialize()
	. = ..()
	AddComponent(/datum/component/spooky)

/obj/item/instrument/saxophone/spectral/attack(mob/living/carbon/C, mob/user)
	..()

/obj/item/instrument/trombone
	name = "trombone"
	desc = ""
	icon_state = "trombone"
	item_state = "trombone"
	instrumentId = "trombone"

/obj/item/instrument/trombone/spectral
	name = "spectral trombone"
	desc = ""
	instrumentId = "trombone"
	icon_state = "trombone"
	item_state = "trombone"
	force = 0
	attack_verb = list("played","jazzed","tromboned","mourned","dooted","spooked")

/obj/item/instrument/trombone/spectral/Initialize()
	. = ..()
	AddComponent(/datum/component/spooky)

/obj/item/instrument/trombone/spectral/attack(mob/living/carbon/C, mob/user)
	..()

/obj/item/instrument/recorder
	name = "recorder"
	desc = ""
	force = 5
	icon_state = "recorder"
	item_state = "recorder"
	instrumentId = "recorder"

/obj/item/instrument/harmonica
	name = "harmonica"
	desc = ""
	icon_state = "harmonica"
	item_state = "harmonica"
	instrumentId = "harmonica"
	slot_flags = ITEM_SLOT_MASK
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	actions_types = list(/datum/action/item_action/instrument)

/obj/item/instrument/harmonica/proc/handle_speech(datum/source, list/speech_args)
	if(song.playing && ismob(loc))
		to_chat(loc, "<span class='warning'>I stop playing the harmonica to talk...</span>")
		song.playing = FALSE

/obj/item/instrument/harmonica/equipped(mob/M, slot)
	. = ..()
	RegisterSignal(M, COMSIG_MOB_SAY, .proc/handle_speech, override = TRUE)

/obj/item/instrument/harmonica/dropped(mob/M)
	. = ..()
	UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/instrument/bikehorn
	name = "gilded bike horn"
	desc = ""
	icon_state = "bike_horn"
	item_state = "bike_horn"
	lefthand_file = 'icons/mob/inhands/equipment/horns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/horns_righthand.dmi'
	attack_verb = list("beautifully honks")
	instrumentId = "bikehorn"
	instrumentExt = "ogg"
	w_class = WEIGHT_CLASS_TINY
	force = 0
	throw_speed = 1
	throw_range = 15
	hitsound = 'sound/blank.ogg'

///

/obj/item/choice_beacon/music
	name = "instrument delivery beacon"
	desc = ""
	icon_state = "gangtool-red"

/obj/item/choice_beacon/music/generate_display_names()
	var/static/list/instruments
	if(!instruments)
		instruments = list()
		var/list/templist = list(/obj/item/instrument/violin,
							/obj/item/instrument/piano_synth,
							/obj/item/instrument/banjo,
							/obj/item/instrument/guitar,
							/obj/item/instrument/eguitar,
							/obj/item/instrument/glockenspiel,
							/obj/item/instrument/accordion,
							/obj/item/instrument/trumpet,
							/obj/item/instrument/saxophone,
							/obj/item/instrument/trombone,
							/obj/item/instrument/recorder,
							/obj/item/instrument/harmonica
							)
		for(var/V in templist)
			var/atom/A = V
			instruments[initial(A.name)] = A
	return instruments
