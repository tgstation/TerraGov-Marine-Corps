/datum/language/beast
	name = "Beastish"
	desc = ""
	speech_verb = "growls"
	ask_verb = "grrs"
	exclaim_verb = "howls"
	key = "b"
	flags = LANGUAGE_HIDE_ICON_IF_UNDERSTOOD | LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD
	space_chance = 7
	default_priority = 100
	icon_state = "asse"
	spans = list(SPAN_BEAST)
	syllables = list("GRRrrrr",
"GGGrrr",
"RRRRrr",
"GRrr",
"Rr",
"Rrrr",
"Rrrrr")