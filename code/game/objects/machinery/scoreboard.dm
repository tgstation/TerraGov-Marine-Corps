/obj/machinery/scoreboard
	icon = 'icons/obj/machines/scoreboard.dmi'
	icon_state = "scoreboard"
	name = "basketball scoreboard"
	anchored = TRUE
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	var/id = ""

	var/scoreleft = 0
	var/scoreright = 0

/obj/machinery/scoreboard/Initialize()
	. = ..()
	update_display()

/obj/machinery/scoreboard/proc/update_display()
	if(overlays.len)
		overlays.Cut()

	var/score_state = "s[( round(scoreleft/10) > scoreleft/10 ? round(scoreleft/10)-1 : round(scoreleft/10) )]a"
	overlays += image('icons/obj/machines/scoreboard.dmi', icon_state=score_state)
	score_state = "s[scoreleft%10]b"
	overlays += image('icons/obj/machines/scoreboard.dmi', icon_state=score_state)
	score_state = "s[( round(scoreright/10) > scoreright/10 ? round(scoreright/10)-1 : round(scoreright/10) )]c"
	overlays += image('icons/obj/machines/scoreboard.dmi', icon_state=score_state)
	score_state = "s[scoreright%10]d"
	overlays += image('icons/obj/machines/scoreboard.dmi', icon_state=score_state)

/obj/machinery/scoreboard/proc/score(side, points=2)
	switch(side)
		if("left")
			scoreleft += points
			if(scoreleft > 99)
				scoreleft %= 100
		if("right")
			scoreright += points
			if(scoreright > 99)
				scoreright %= 100
	update_display()

/obj/machinery/scoreboard/proc/reset_scores()
	scoreleft = 0
	scoreright = 0
	update_display()

/obj/machinery/scoreboard_button
	name = "scoreboard button"
	desc = "A remote control button to reset a scoreboard."
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	var/id = null
	var/active = 0
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/scoreboard_button/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(active)
		return

	use_power(active_power_usage)

	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/scoreboard/X in GLOB.machines)
		if(X.id == id)
			X.reset_scores()

	sleep(50)

	icon_state = "launcherbtt"
	active = 0

	return
