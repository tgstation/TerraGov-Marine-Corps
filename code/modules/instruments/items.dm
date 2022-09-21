//copy pasta of the space piano, don't hurt me -Pete
/obj/item/instrument
	name = "generic instrument"
	force = 10
	max_integrity = 100
	icon = 'icons/obj/musician.dmi'
	interaction_flags = INTERACT_OBJ_UI
	item_state_worn = TRUE
	item_icons = list(
		slot_l_hand_str = 'icons/mob/instruments_lefthand.dmi',
		slot_r_hand_str = 'icons/mob/instruments_righthand.dmi',
		)
	/// Our song datum.
	var/datum/song/handheld/song
	/// Our allowed list of instrument ids. This is nulled on initialize.
	var/list/allowed_instrument_ids
	/// How far away our song datum can be heard.
	var/instrument_range = 15

/obj/item/instrument/Initialize(mapload)
	. = ..()
	song = new(src, allowed_instrument_ids, instrument_range)
	allowed_instrument_ids = null			//We don't need this clogging memory after it's used.

/obj/item/instrument/Destroy()
	QDEL_NULL(song)
	return ..()

/obj/item/instrument/proc/should_stop_playing(mob/user)
	return user.incapacitated() || !((loc == user) || (isturf(loc) && Adjacent(user)))		// sorry, no more TK playing.

/obj/item/instrument/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] begins to play 'Gloomy Sunday'! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (BRUTELOSS)

/datum/action/item_action/instrument
	name = "Use Instrument"
	desc = "Use the instrument specified"

/obj/item/instrument/attack_self(mob/user)
	interact(user)

/obj/item/instrument/ui_interact(mob/living/user)
	if(!isliving(user) || user.stat != CONSCIOUS)
		return

	user.set_machine(src)
	song.ui_interact(user)

/obj/item/instrument/violin
	name = "space violin"
	desc = "A wooden musical instrument with four strings and a bow. \"The devil went down to space, he was looking for an assistant to grief.\""
	icon_state = "violin"
	item_state = "violin"
	hitsound = "swing_hit"
	allowed_instrument_ids = "violin"

/obj/item/instrument/violin/golden
	name = "golden violin"
	desc = "A golden musical instrument with four strings and a bow. \"The devil went down to space, he was looking for an assistant to grief.\""
	icon_state = "golden_violin"
	item_state = "golden_violin"

/obj/item/instrument/piano_synth
	name = "synthesizer"
	desc = "An advanced electronic synthesizer that can be used as various instruments."
	icon_state = "synth"
	item_state = "synth"
	allowed_instrument_ids = "piano"

/obj/item/instrument/piano_synth/Initialize(mapload)
	. = ..()
	song.allowed_instrument_ids = SSinstruments.synthesizer_instrument_ids

/obj/item/instrument/banjo
	name = "banjo"
	desc = "A drum with a neck and strings."
	icon_state = "banjo"
	item_state = "banjo"
	attack_verb = list("scruggs-styles", "hum-diggitys", "shin-digs", "clawhammers")
	hitsound = 'sound/weapons/banjoslap.ogg'
	allowed_instrument_ids = "banjo"

/obj/item/instrument/guitar
	name = "guitar"
	desc = "It's made of wood and has bronze strings."
	icon_state = "guitar"
	item_state = "guitar"
	attack_verb = list("serenades", "crashes", "smashes")
	hitsound = 'sound/weapons/stringsmash.ogg'
	allowed_instrument_ids = list("guitar","csteelgt","cnylongt", "ccleangt", "cmutedgt")

/obj/item/instrument/eguitar
	name = "electric guitar"
	desc = "Makes all your shredding needs possible."
	icon_state = "eguitar"
	item_state = "eguitar"
	force = 12
	attack_verb = list("shreds", "crashes", "smashes")
	hitsound = 'sound/weapons/stringsmash.ogg'
	allowed_instrument_ids = "eguitar"

/obj/item/instrument/glockenspiel
	name = "glockenspiel"
	desc = "Smooth metal bars perfect for any marching band."
	icon_state = "glockenspiel"
	item_state = "glockenspiel"
	allowed_instrument_ids = list("glockenspiel","crvibr", "sgmmbox", "r3celeste")

/obj/item/instrument/accordion
	name = "accordion"
	desc = "Monkey not included."
	icon_state = "accordion"
	item_state = "accordion"
	allowed_instrument_ids = list("crack", "crtango", "accordion")

/obj/item/instrument/trumpet
	name = "trumpet"
	desc = "To announce the arrival of the king!"
	icon_state = "trumpet"
	item_state = "trumpet"
	allowed_instrument_ids = "crtrumpet"

/obj/item/instrument/saxophone
	name = "saxophone"
	desc = "This soothing sound will be sure to leave your audience in tears."
	icon_state = "saxophone"
	item_state = "saxophone"
	allowed_instrument_ids = "saxophone"


/obj/item/instrument/trombone
	name = "trombone"
	desc = "How can any pool table ever hope to compete?"
	icon_state = "trombone"
	item_state = "trombone"
	allowed_instrument_ids = list("crtrombone", "crbrass", "trombone")

/obj/item/instrument/recorder
	name = "recorder"
	desc = "Just like in school, playing ability and all."
	force = 5
	icon_state = "recorder"
	item_state = "recorder"
	allowed_instrument_ids = "recorder"

/obj/item/instrument/harmonica
	name = "harmonica"
	desc = "For when you get a bad case of the space blues."
	icon_state = "harmonica"
	item_state = "harmonica"
	allowed_instrument_ids = list("crharmony", "harmonica")
	flags_equip_slot = ITEM_SLOT_MASK
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	actions_types = list(/datum/action/item_action/instrument)

/obj/item/instrument/harmonica/proc/handle_speech(datum/source, list/speech_args)
	if(song.playing && ismob(loc))
		to_chat(loc, span_warning("You stop playing the harmonica to talk..."))
		song.playing = FALSE

/obj/item/instrument/harmonica/equipped(mob/M, slot)
	. = ..()
	RegisterSignal(M, COMSIG_MOB_SAY, .proc/handle_speech)

/obj/item/instrument/harmonica/dropped(mob/M)
	UnregisterSignal(M, COMSIG_MOB_SAY)
	return ..()

/obj/item/instrument/bikehorn
	name = "gilded bike horn"
	desc = "An exquisitely decorated bike horn, capable of honking in a variety of notes."
	icon_state = "bike_horn"
	allowed_instrument_ids = list("bikehorn", "honk")
	attack_verb = list("beautifully honks")
	w_class = WEIGHT_CLASS_TINY
	force = 0
	throw_speed = 3
	throw_range = 15
	hitsound = 'sound/items/bikehorn.ogg'

/obj/item/instrument/musicalmoth
	name = "musical moth"
	desc = "Despite its popularity, this controversial musical toy was eventually banned due to its unethically sampled sounds of moths screaming in agony."
	icon_state = "mothsician"
	allowed_instrument_ids = "mothscream"
	attack_verb = list("flutters", "flaps")
	w_class = WEIGHT_CLASS_TINY
	force = 0
	hitsound = 'sound/voice/moth_scream.ogg'
