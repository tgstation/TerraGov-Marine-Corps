/obj/item/rogueweapon/thresher
	force = 10
	force_wielded = 15
	possible_item_intents = list(MACE_STRIKE)
	gripped_intents = list(MACE_STRIKE,/datum/intent/flailthresh)
	name = "thresher"
	desc = ""
	icon_state = "flail"
	icon = 'icons/roguetown/weapons/tools.dmi'
	item_state = "mace_greyscale"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	sharpness = IS_BLUNT
	//dropshrink = 0.8
	slot_flags = ITEM_SLOT_BACK
	wlength = 33
	gripsprite = TRUE
	drop_sound = 'sound/foley/dropsound/wooden_drop.ogg'
	smeltresult = /obj/item/ingot/iron
/datum/intent/flailthresh
	name = "thresh"
	icon_state = "inthresh"
	chargetime = 0
	noaa = TRUE
	candodge = FALSE
	misscost = 0
	no_attack = TRUE

/obj/item/rogueweapon/thresher/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.7,
"sx" = -16,
"sy" = -3,
"nx" = 5,
"ny" = -3,
"wx" = -13,
"wy" = -4,
"ex" = -1,
"ey" = -4,
"northabove" = 0,
"southabove" = 1,
"eastabove" = 1,
"westabove" = 0,
"nturn" = -15,
"sturn" = 12,
"wturn" = 0,
"eturn" = 354,
"nflip" = 0,
"sflip" = 8,
"wflip" = 8,
"eflip" = 0)
			if("wielded")
				return list("shrink" = 0.8,
"sx" = -3,
"sy" = -14,
"nx" = -12,
"ny" = -15,
"wx" = -9,
"wy" = -14,
"ex" = -4,
"ey" = -13,
"northabove" = 0,
"southabove" = 1,
"eastabove" = 1,
"westabove" = 0,
"nturn" = 0,
"sturn" = -6,
"wturn" = -3,
"eturn" = -21,
"nflip" = 8,
"sflip" = 0,
"wflip" = 0,
"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/rogueweapon/thresher/afterattack(obj/target, mob/user, proximity)
	if(user.used_intent.type == /datum/intent/flailthresh)
		if(isturf(target.loc))
			var/turf/T = target.loc
			var/found = FALSE
			for(var/obj/item/natural/chaff/C in T)
				found = TRUE
				C.thresh()
			if(found)
				playsound(loc,"plantcross", 100, FALSE)
				playsound(loc,"smashlimb", 50, FALSE)
				user.visible_message("<span class='notice'>[user] threshes the stalks!</span>", \
									"<span class='notice'>I thresh the stalks.</span>")
			return
	..()

/obj/item/rogueweapon/sickle
	force = 10
	possible_item_intents = list(DAGGER_CUT)
	name = "sickle"
	desc = ""
	icon_state = "sickle"
	icon = 'icons/roguetown/weapons/tools.dmi'
	item_state = "crysknife"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	sharpness = IS_SHARP
	//dropshrink = 0.8
	wlength = 10
	slot_flags = ITEM_SLOT_HIP
	max_blade_int = 50
	smeltresult = /obj/item/ingot/iron

/obj/item/rogueweapon/sickle/attack_turf(turf/T, mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	if(istype(T, /turf/open/floor/rogue/dirt))
		var/turf/open/floor/rogue/dirt/D = T
		if(D.planted_crop)
			D.planted_crop.attackby(src, user)
			return
	. = ..()

/obj/item/rogueweapon/sickle/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.6,
"sx" = -13,
"sy" = -4,
"nx" = 7,
"ny" = -4,
"wx" = -10,
"wy" = -4,
"ex" = 0,
"ey" = -4,
"northabove" = 0,
"southabove" = 1,
"eastabove" = 1,
"westabove" = 0,
"nturn" = 0,
"sturn" = 0,
"wturn" = 0,
"eturn" = 0,
"nflip" = 0,
"sflip" = 8,
"wflip" = 8,
"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)


/obj/item/rogueweapon/hoe
	force = 10
	force_wielded = 15
	possible_item_intents = list(/datum/intent/pick)
	gripped_intents = list(/datum/intent/pick,SPEAR_BASH,TILL_INTENT)
	name = "hoe"
	desc = ""
	icon_state = "hoe"
	slot_flags = ITEM_SLOT_BACK
	icon = 'icons/roguetown/weapons/tools.dmi'
	item_state = "pitchfork"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	sharpness = IS_BLUNT
	//dropshrink = 0.8
	wlength = 33
	drop_sound = 'sound/foley/dropsound/wooden_drop.ogg'
	smeltresult = /obj/item/ingot/iron

/obj/item/rogueweapon/hoe/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.7,
"sx" = -16,
"sy" = -3,
"nx" = 5,
"ny" = -3,
"wx" = -13,
"wy" = -4,
"ex" = -1,
"ey" = -4,
"northabove" = 0,
"southabove" = 1,
"eastabove" = 1,
"westabove" = 0,
"nturn" = -15,
"sturn" = 12,
"wturn" = 0,
"eturn" = 354,
"nflip" = 0,
"sflip" = 8,
"wflip" = 8,
"eflip" = 0)
			if("wielded")
				return list("shrink" = 0.8,
"sx" = -3,
"sy" = -14,
"nx" = -12,
"ny" = -15,
"wx" = -9,
"wy" = -14,
"ex" = -4,
"ey" = -13,
"northabove" = 0,
"southabove" = 1,
"eastabove" = 1,
"westabove" = 0,
"nturn" = 0,
"sturn" = -6,
"wturn" = -3,
"eturn" = -21,
"nflip" = 8,
"sflip" = 0,
"wflip" = 0,
"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/rogueweapon/hoe/attack_turf(turf/T, mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	if(istype(T, /turf/open/floor/rogue/dirt))
		var/turf/open/floor/rogue/dirt/D = T
		if(D.planted_crop)
			D.planted_crop.attackby(src, user)
			return
	if(istype(T, /turf/open/floor/rogue/grass))
		if(user.used_intent.type == /datum/intent/till)
			playsound(T,'sound/items/dig_shovel.ogg', 100, TRUE)
			if (do_after(user,30, target = src))
				T.ChangeTurf(/turf/open/floor/rogue/dirt, flags = CHANGETURF_INHERIT_AIR)
				playsound(T,'sound/items/dig_shovel.ogg', 100, TRUE)
			return
	. = ..()

/datum/intent/till
	name = "hoe"
	icon_state = "inhoe"
	chargetime = 0
	noaa = TRUE
	candodge = FALSE
	misscost = 0

/*
//make this attack_turf instead
/obj/item/rogueweapon/hoe/afterattack(obj/target, mob/user, proximity)
	if((!proximity) || (!wielded))
		return ..()

	if(istype(target, /turf/open/floor/rogue/dirt))
		var/obj/machinery/crop/R = locate() in target
		if(R)
			to_chat(user,"<span class='warning'>There's already a mound here.</span>")
			return
		if(prob(10)) //ROGTODO make this farming skill based maybe a stat too
			user.visible_message("<span class='notice'>[user] tills the soil!</span>", \
								"<span class='notice'>I till the soil.</span>")
			new /obj/machinery/crop(target)
		else
			to_chat(user,"<span class='warning'>I till the soil.</span>")
		return
	..()
*/
/obj/item/rogueweapon/pitchfork

	force = 10
	force_wielded = 15
	possible_item_intents = list(SPEAR_BASH)
	gripped_intents = list(SPEAR_BASH,SPEAR_THRUST,DUMP_INTENT)
	name = "pitchfork"
	desc = ""
	icon_state = "pitchfork"
	icon = 'icons/roguetown/weapons/tools.dmi'
	item_state = "pitchfork"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	sharpness = IS_BLUNT
	//dropshrink = 0.8
	wlength = 33
	var/list/forked = list()
	slot_flags = ITEM_SLOT_BACK
	drop_sound = 'sound/foley/dropsound/wooden_drop.ogg'
	smeltresult = /obj/item/ingot/iron
/obj/item/rogueweapon/pitchfork/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.7,
"sx" = -16,
"sy" = -3,
"nx" = 5,
"ny" = -3,
"wx" = -13,
"wy" = -4,
"ex" = -1,
"ey" = -4,
"northabove" = 0,
"southabove" = 1,
"eastabove" = 1,
"westabove" = 0,
"nturn" = -15,
"sturn" = 12,
"wturn" = 0,
"eturn" = 354,
"nflip" = 0,
"sflip" = 8,
"wflip" = 8,
"eflip" = 0)
			if("wielded")
				return list("shrink" = 0.8,
"sx" = -3,
"sy" = -14,
"nx" = -12,
"ny" = -15,
"wx" = -9,
"wy" = -14,
"ex" = -4,
"ey" = -13,
"northabove" = 0,
"southabove" = 1,
"eastabove" = 1,
"westabove" = 0,
"nturn" = 0,
"sturn" = -6,
"wturn" = -3,
"eturn" = -21,
"nflip" = 8,
"sflip" = 0,
"wflip" = 0,
"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/datum/intent/pforkdump
	name = "scoop"
	icon_state = "inscoop"
	chargetime = 0
	noaa = TRUE
	candodge = FALSE
	misscost = 0
	no_attack = TRUE

/obj/item/rogueweapon/pitchfork/afterattack(obj/target, mob/user, proximity)
	if((!proximity) || (!wielded))
		return ..()
	testing("fuck")
	if(isopenturf(target))
		if(forked.len)
			for(var/obj/item/I in forked)
				I.forceMove(target)
				forked -= I
			to_chat(user, "<span class='warning'>I dump the stalks.</span>")
		update_icon()
		return
	..()

/obj/item/rogueweapon/pitchfork/ungrip(mob/living/carbon/user, show_message = TRUE)
	if(forked.len)
		var/turf/T = get_turf(user)
		for(var/obj/item/I in forked)
			I.forceMove(T)
			forked -= I
		update_icon()
	..()

/obj/item/rogueweapon/pitchfork/update_icon()
	if(forked.len)
		icon_state = "pitchforkstuff"
	else
		icon_state = initial(icon_state)
	..()