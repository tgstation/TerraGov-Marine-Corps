/datum/language/sectoid
	name = "Psi-Speak"
	desc = "A language consisting of psionic emissions created from thought, it sounds like garbled nonsense to those who are not trained to mentally decrypt it."
	speech_verb = "emits"
	ask_verb = "questions"
	exclaim_verb = "shrieks"
	whisper_verb = "faintly emits"
	flags = LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD | TONGUELESS_SPEECH
	key = "p"
	sentence_chance = 0
	default_priority = 80
	syllables = list("<font face='Wingdings'>wreh<font face='Verdana'>",
		"<font face='Wingdings'>breh<font face='Verdana'>",
		"<font face='Wingdings'>ayy<font face='Verdana'>",
		"<font face='Wingdings'>gji<font face='Verdana'>",
		"<font face='Wingdings'>pks<font face='Verdana'>",
		"<font face='Wingdings'>jok<font face='Verdana'>",
	)
	icon_state = "aphasia"
