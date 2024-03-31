/obj/effect/proc_holder/spell/self/telljoke
	name = "Comedia"
	desc = "Say something funny to someone in high spirits, it will brighten their mood."
	overlay_state = "comedy"
	antimagic_allowed = TRUE
	invocation_type = "shout"
	charge_max = 600

/obj/effect/proc_holder/spell/self/telljoke/cast(list/targets,mob/user = usr)
	..()
	var/joker = input(user, "Say something funny!", "Comedia")
	if(!joker)
		return FALSE
	user.say(joker, forced = "spell")
	sleep(20)
	playsound(get_turf(user), 'sound/magic/comedy.ogg', 100)
	for(var/mob/living/carbon/CA in view(7, get_turf(user)))
		if(CA == user)
			continue
		if(CA.cmode)
			continue
		if(CA.stress <= 0)
			CA.add_stress(/datum/stressevent/joke)
			CA.emote(pick("laugh","chuckle","giggle"), forced = TRUE)
		sleep(rand(1,5))

/obj/effect/proc_holder/spell/self/telltragedy
	name = "Tragedia"
	desc = "Remind someone in low spirits that it could be much worse."
	overlay_state = "tragedy"
	antimagic_allowed = TRUE
	invocation_type = "shout"
	charge_max = 600

/obj/effect/proc_holder/spell/self/telltragedy/cast(list/targets,mob/user = usr)
	..()
	var/joker = input(user, "Say something sad!", "Tragedia")
	if(!joker)
		return FALSE
	user.say(joker, forced = "spell")
	sleep(20)
	playsound(get_turf(user), 'sound/magic/tragedy.ogg', 100)
	for(var/mob/living/carbon/CA in view(7, get_turf(user)))
		if(CA == user)
			continue
		if(CA.cmode)
			continue
		if(CA.stress > 0)
			CA.add_stress(/datum/stressevent/tragedy)
			CA.emote(pick("sigh","hmm"), forced = TRUE)
		sleep(rand(1,5))