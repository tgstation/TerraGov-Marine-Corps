/datum/status_effect/moodbad
	id = "moodbad"
	effectedstats = list("fortune" = -1)
	alert_type = /obj/screen/alert/status_effect/moodbad

/obj/screen/alert/status_effect/moodbad
	name = "Stressed"
	desc = ""
	icon_state = "stressb"

/datum/status_effect/moodvbad
	id = "moodvbad"
	effectedstats = list("fortune" = -2)
	alert_type = /obj/screen/alert/status_effect/moodvbad

/obj/screen/alert/status_effect/moodvbad
	name = "Max Stress"
	desc = ""
	icon_state = "stressvb"

/datum/status_effect/moodgood
	id = "moodgood"
	effectedstats = list("fortune" = 1)
	alert_type = /obj/screen/alert/status_effect/moodgood

/obj/screen/alert/status_effect/moodgood
	name = "Inner Peace"
	desc = ""
	icon_state = "stressg"

/datum/status_effect/moodvgood
	id = "moodvgood"
	effectedstats = list("fortune" = 2)
	alert_type = /obj/screen/alert/status_effect/moodvgood

/obj/screen/alert/status_effect/moodvgood
	name = "Max Peace"
	desc = ""
	icon_state = "stressvg"