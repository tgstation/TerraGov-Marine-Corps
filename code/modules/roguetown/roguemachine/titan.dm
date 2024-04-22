GLOBAL_LIST_EMPTY(outlawed_players)
GLOBAL_LIST_EMPTY(lord_decrees)

/obj/structure/roguemachine/titan
	name = "throat"
	desc = "He who wears the crown holds the key to this strange thing. If all else fails, yell \"Help!\""
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = ""
	density = FALSE
	blade_dulling = DULLING_BASH
	integrity_failure = 0.5
	max_integrity = 0
	flags_1 = HEAR_1
	anchored = TRUE
	var/mode = 0


/obj/structure/roguemachine/titan/obj_break(damage_flag)
	..()
	cut_overlays()
//	icon_state = "[icon_state]-br"
	set_light(0)
	return

/obj/structure/roguemachine/titan/Destroy()
	set_light(0)
	..()

/obj/structure/roguemachine/titan/Initialize()
	. = ..()
	icon_state = null
//	var/mutable_appearance/eye_lights = mutable_appearance(icon, "titan-eyes")
//	eye_lights.plane = ABOVE_LIGHTING_PLANE //glowy eyes
//	eye_lights.layer = ABOVE_LIGHTING_LAYER
//	add_overlay(eye_lights)
	set_light(5)

/obj/structure/roguemachine/titan/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
//	. = ..()
	if(speaker == src)
		return
	if(speaker.loc != loc)
		return
	if(obj_broken)
		return
	if(!ishuman(speaker))
		return
	var/mob/living/carbon/human/H = speaker
	if(!H.head)
		return
	var/nocrown
	if(!istype(H.head, /obj/item/clothing/head/roguetown/crown/serpcrown))
		nocrown = TRUE
	var/notlord
	if(SSticker.rulermob != H)
		notlord = TRUE
	var/message2recognize = sanitize_hear_message(raw_message)

	if(mode)
		if(findtext(message2recognize, "nevermind"))
			mode = 0
			return

	switch(mode)
		if(0)
			if(findtext(message2recognize, "help"))
				say("My commands are: Make Decree, Make Announcement, Set Taxes, Declare Outlaw, Summon Crown, Nevermind")
				playsound(src, 'sound/misc/machinelong.ogg', 100, FALSE, -1)
			if(findtext(message2recognize, "make announcement"))
				if(nocrown)
					say("You need the crown.")
					playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
					return
				if(!SScommunications.can_announce(H))
					say("I must gather my strength!")
					return
				say("Speak and they will listen.")
				playsound(src, 'sound/misc/machineyes.ogg', 100, FALSE, -1)
				mode = 1
				return
			if(findtext(message2recognize, "make decree"))
				if(!SScommunications.can_announce(H))
					say("I must gather my strength!")
					playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
					return
				if(notlord || nocrown)
					say("You are not my master!")
					playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
					return
				say("Speak and they will obey.")
				playsound(src, 'sound/misc/machineyes.ogg', 100, FALSE, -1)
				mode = 2
				return
			if(findtext(message2recognize, "declare outlaw"))
				if(notlord || nocrown)
					say("You are not my master!")
					playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
					return
				say("Who should be outlawed?")
				playsound(src, 'sound/misc/machinequestion.ogg', 100, FALSE, -1)
				mode = 3
				return
			if(findtext(message2recognize, "set taxes"))
				if(notlord || nocrown)
					say("You are not my master!")
					playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
					return
				say("The new tax percent shall be...")
				playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
				give_tax_popup(H)
				return
			if(findtext(message2recognize, "summon crown"))
				if(SSroguemachine.crown)
					var/obj/item/I = SSroguemachine.crown
					if(!I)
						I = new /obj/item/clothing/head/roguetown/crown/serpcrown(src.loc)
					if(ishuman(I.loc))
						var/mob/living/carbon/human/HC = I.loc
						if(HC.stat != DEAD)
							if(I in HC.held_items)
								say("[HC.real_name] holds the crown!")
								playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
								return
							if(H.head == I)
								say("[HC.real_name] wears the crown!")
								playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
								return
					I.forceMove(src.loc)
					say("The crown is summoned!")
					playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
					playsound(src, 'sound/misc/hiss.ogg', 100, FALSE, -1)
		if(1)
			make_announcement(H, raw_message)
			mode = 0
		if(2)
			make_decree(H, raw_message)
			mode = 0
		if(3)
			make_outlaw(H, raw_message)
			mode = 0

/obj/structure/roguemachine/titan/proc/give_tax_popup(mob/living/carbon/human/user)
	if(!Adjacent(user))
		return
	var/newtax = input(user, "Set a new tax percentage (1-99)", src, SStreasury.tax_value*100) as null|num
	if(newtax)
		if(!Adjacent(user))
			return
		if(findtext(num2text(newtax), "."))
			return
		newtax = CLAMP(newtax, 1, 99)
		SStreasury.tax_value = newtax / 100
		priority_announce("The new tax in Rockhill shall be [newtax] percent.", "The Generous Lord Decrees", 'sound/misc/alert.ogg', "Captain")


/obj/structure/roguemachine/titan/proc/make_announcement(mob/living/user, raw_message)
	if(!SScommunications.can_announce(user))
		return
	var/datum/antagonist/prebel/P = user.mind?.has_antag_datum(/datum/antagonist/prebel)
	if(P)
		var/datum/game_mode/chaosmode/C = SSticker.mode
		if(istype(C))
			if(P.rev_team)
				if(P.rev_team.members.len < 3)
					to_chat(user, "<span class='warning'>I need more folk on my side to declare victory.</span>")
				else
					for(var/datum/objective/prebel/obj in user.mind.get_all_objectives())
						obj.completed = TRUE
					if(!C.headrebdecree)
						user.mind.adjust_triumphs(1)
					C.headrebdecree = TRUE

	SScommunications.make_announcement(user, FALSE, raw_message)

/obj/structure/roguemachine/titan/proc/make_decree(mob/living/user, raw_message)
	if(!SScommunications.can_announce(user))
		return
	var/datum/antagonist/prebel/P = user.mind?.has_antag_datum(/datum/antagonist/prebel)
	if(P)
		var/datum/game_mode/chaosmode/C = SSticker.mode
		if(istype(C))
			if(P.rev_team)
				if(P.rev_team.members.len < 3)
					to_chat(user, "<span class='warning'>I need more folk on my side to declare victory.</span>")
				else
					for(var/datum/objective/prebel/obj in user.mind.get_all_objectives())
						obj.completed = TRUE
					if(!C.headrebdecree)
						user.mind.adjust_triumphs(1)
					C.headrebdecree = TRUE
	GLOB.lord_decrees += raw_message
	SScommunications.make_announcement(user, TRUE, raw_message)

/obj/structure/roguemachine/titan/proc/make_outlaw(mob/living/user, raw_message)
	if(!SScommunications.can_announce(user))
		return
	if(user.job)
		var/datum/job/J = SSjob.GetJob(user.job)
		var/used_title = J.title
		if(user.gender == FEMALE && J.f_title)
			used_title = J.f_title
		if(used_title != "King")
			return
	else
		return
	if(raw_message in GLOB.outlawed_players)
		GLOB.outlawed_players -= raw_message
		priority_announce("[raw_message] is no longer an outlaw in Rockhill lands.", "The King Decrees", 'sound/misc/alert.ogg', "Captain")
		return FALSE
	var/found = FALSE
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.real_name == raw_message)
			found = TRUE
	if(!found)
		return FALSE
	GLOB.outlawed_players += raw_message
	priority_announce("[raw_message] has been declared an outlaw and must be captured or slain.", "The King Decrees", 'sound/misc/alert.ogg', "Captain")
