/datum/language/telepathy
	name = "Telepathy"
	desc = "Direct transmission of concepts into the minds of others."
	speech_verb = "psychically transmits"
	ask_verb = "psychically asks"
	exclaim_verb = "psychically exclaims"
	whisper_verb = "psychically whispers" 
	sing_verb = "psychically sings"
	key = "t"
	spans = list("psychicin")
	syllables = list("mmm", "mMm", "MMM") // Should not actually get seen, this is meant to be understandable by everyone
	default_priority = 10
	flags = TONGUELESS_SPEECH
	
	icon = 'icons/Xeno/actions/queen.dmi'
	icon_state = "screech"
