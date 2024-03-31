/////////////////////////////////////////Scrying///////////////////

/obj/item/scrying
	name = "scrying orb"
	desc = ""
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state ="scrying"
	throw_speed = 3
	throw_range = 7
	throwforce = 15
	damtype = BURN
	force = 15
	hitsound = 'sound/blank.ogg'
	sellprice = 30
	dropshrink = 0.6

	var/mob/current_owner
	var/last_scry


/obj/item/scrying/attack_self(mob/user)
	. = ..()
	if(world.time < last_scry + 30 SECONDS)
		to_chat(user, "<span class='warning'>I look into the ball but only see inky smoke. Maybe I should wait.</span>")
		return
	var/input = stripped_input(user, "Who are you looking for?", "Scrying Orb")
	if(!input)
		return
	if(!user.key)
		return
	if(world.time < last_scry + 30 SECONDS)
		to_chat(user, "<span class='warning'>I look into the ball but only see inky smoke. Maybe I should wait.</span>")
		return
	if(!user.mind || !user.mind.do_i_know(name=input))
		to_chat(user, "<span class='warning'>I don't know anyone by that name.</span>")
		return
	for(var/mob/living/carbon/human/HL in GLOB.human_list)
		if(HL.real_name == input)
			var/turf/T = get_turf(HL)
			if(!T)
				continue
			var/mob/dead/observer/screye/S = user.scry_ghost()
			if(!S)
				return
			S.ManualFollow(HL)
			last_scry = world.time
			user.visible_message("<span class='danger'>[user] stares into [src], \their eyes rolling back into \their head.</span>")
			addtimer(CALLBACK(S, /mob/dead/observer/.proc/reenter_corpse), 8 SECONDS)
			if(!HL.stat)
				if(HL.STAPER >= 15)
					if(HL.mind)
						if(HL.mind.do_i_know(name=user.real_name))
							to_chat(HL, "<span class='warning'>I can clearly see the face of [user.real_name] staring at me!.</span>")
							return
					to_chat(HL, "<span class='warning'>I can clearly see the face of an unknown [user.gender == FEMALE ? "woman" : "man"] staring at me!</span>")
					return
				if(HL.STAPER >= 11)
					to_chat(HL, "<span class='warning'>I feel a pair of unknown eyes on me.</span>")
			return
	to_chat(user, "<span class='warning'>I peer into the ball, but can't find [input].</span>")
	return

/////////////////////////////////////////Crystal ball ghsot vision///////////////////

/obj/item/crystalball/attack_self(mob/user)
	user.visible_message("<span class='danger'>[user] stares into [src], \their eyes rolling back into \their head.</span>")
	user.ghostize(1)