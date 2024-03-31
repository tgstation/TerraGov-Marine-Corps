GLOBAL_VAR(moneymaster)

/obj/structure/roguemachine/money
	name = "machine"
	desc = ""
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "money1"
	density = FALSE
	blade_dulling = DULLING_BASH
	pixel_y = 32
	var/budget = 0
	var/izmaster = FALSE
	anchored = TRUE

/obj/structure/roguemachine/money/attackby(obj/item/P, mob/user, params)
	if(!user.cmode)
		if(istype(P, /obj/item/roguecoin))
			budget += P.get_real_price()
			qdel(P)
			update_icon()
			playsound(loc, 'sound/misc/machinevomit.ogg', 100, TRUE, -1)
			return
		else if(P.get_real_price())
			if(izmaster)
				return ..()
			if(!GLOB.moneymaster)
				say("The masters have perished?")
				playsound(src, 'sound/misc/machinequestion.ogg', 100, FALSE, -1)
				return
			if(P.get_real_price() > 100)
				say("This must be traded to a Guildmaster.")
				playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
				return
			var/obj/structure/roguemachine/money/twins/T = GLOB.moneymaster
			var/amtofsale = round(P.get_real_price()/2)
			if(amtofsale >= 1)
				if(T.budget >= amtofsale)
					T.budget -= amtofsale
					budget += amtofsale
					update_icon()
				else
					say("The masters cannot afford...")
					playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
					return
			P.forceMove(T.loc)
			playsound(T.loc, 'sound/misc/hiss.ogg', 100, TRUE, -1)
			say("Item accepted for [amtofsale] mammon.")
			playsound(src, 'sound/misc/machineyes.ogg', 100, FALSE, -1)
			playsound(T, 'sound/misc/machinevomit.ogg', 100, TRUE, -1)

		return
	..()


/obj/structure/roguemachine/money/Initialize()
	. = ..()
	icon_state = "money[rand(1,2)]"
	update_icon()

/obj/structure/roguemachine/money/r
	pixel_y = 0
	pixel_x = 32

/obj/structure/roguemachine/money/r/Initialize()
	. = ..()
	icon_state = "money1"
	update_icon()

/obj/structure/roguemachine/money/l
	pixel_y = 0
	pixel_x = -32

/obj/structure/roguemachine/money/l/Initialize()
	. = ..()
	icon_state = "money2"
	update_icon()

/obj/structure/roguemachine/money/attack_hand(mob/living/user)
	. = ..()
	user.changeNext_move(CLICK_CD_MELEE)
	to_chat(user, "<span class='info'>I rub the machine clockwise.</span>")
	if(budget > 0)
		say("[budget] MAMMON ARE MINE...")
		playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
		playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
	update_icon()

/obj/structure/roguemachine/money/attack_right(mob/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	var/inputt = alert(user,"Gold, Silver, or Bronze?",,"BRONZE","SILVER","GOLD")
	if(inputt && Adjacent(user))
		to_chat(user, "<span class='info'>I pull on the [inputt] tongue.</span>")
		if(inputt == "BRONZE" && budget >= 50)
			budget2change(budget, user, inputt)
			budget = 0
			if(isliving(user))
				var/mob/living/L = user
				L.emote("scream")
				L.Paralyze(50)
				L.Stun(50)
				L.visible_message("<span class='danger'>[user] is buried under a mountain of coins!</span>")
		else
			budget2change(budget, user, inputt)
			switch(inputt)
				if("GOLD")
					var/zenars = budget/10
					if(zenars >= 1)
						for(var/i in 1 to zenars)
							budget -= 10
				if("SILVER")
					var/zenars = budget/5
					if(zenars >= 1)
						for(var/i in 1 to zenars)
							budget -= 5
				if("BRONZE")
					if(budget >= 1)
						for(var/i in 1 to budget)
							budget -= 1
		update_icon()

/obj/structure/roguemachine/proc/budget2change(budget, mob/user, specify)
	var/turf/T
	if(!user || (!ismob(user)))
		T = get_turf(src)
	else
		T = get_turf(user)
	if(!budget)
		return
	budget = round(budget)
	var/found
	if(specify)
		found = TRUE
		switch(specify)
			if("GOLD")
				var/zenars = budget/10
				if(zenars >= 1)
					var/obj/item/roguecoin/gold/G = new (T)
					if(zenars > 1)
						for(var/i in 2 to zenars)
							var/obj/item/roguecoin/gold/GV = new /obj/item/roguecoin/gold(G)
							G.held += GV
					G.update_icon()
					user.put_in_hands(G)
			if("SILVER")
				var/zenars = budget/5
				if(zenars >= 1)
					var/obj/item/roguecoin/silver/G = new (T)
					if(zenars > 1)
						for(var/i in 2 to zenars)
							var/obj/item/roguecoin/silver/GV = new /obj/item/roguecoin/silver(G)
							G.held += GV
					G.update_icon()
					user.put_in_hands(G)
			if("BRONZE")
				var/zenars = budget
				if(zenars >= 1)
					var/obj/item/roguecoin/copper/G = new (T)
					if(zenars > 1)
						for(var/i in 2 to zenars)
							var/obj/item/roguecoin/copper/GV = new /obj/item/roguecoin/copper(G)
							G.held += GV
					G.update_icon()
					user.put_in_hands(G)
	else
		var/zenars = budget/10
		if(zenars >= 1)
			for(var/i in 1 to zenars)
				budget -= 10
				found = TRUE
				new /obj/item/roguecoin/gold(T)
		zenars = budget/5
		if(zenars >= 1)
			for(var/i in 1 to zenars)
				budget -= 5
				found = TRUE
				new /obj/item/roguecoin/silver(T)
		if(budget >= 1)
			for(var/i in 1 to budget)
				found = TRUE
				new /obj/item/roguecoin/copper(T)
	if(found)
		playsound(T, 'sound/misc/coindispense.ogg', 100, FALSE, -1)
/*
/obj/structure/roguemachine/money/attack_right(mob/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
	speaking = !speaking
	to_chat(user, "<span class='info'>I press the right eye.</span>")
	update_icon()
*/
/obj/structure/roguemachine/money/obj_break(damage_flag)
	..()
	budget2change(budget)
	budget = 0
	update_icon()

/obj/structure/roguemachine/money/update_icon()
	cut_overlays()
	if(obj_broken)
		set_light(0)
		return
	set_light(1, 1, "#1b7bf1")

/obj/structure/roguemachine/money/Destroy()
	set_light(0)
	budget2change(budget)
	budget = 0
	return ..()

/obj/structure/roguemachine/money/twins
	name = "janus twins"
	desc = "They may hold money for you."
	icon_state = "twins"
	icon = 'icons/roguetown/misc/64x64.dmi'
	budget = 0
	pixel_x = -16
	izmaster = TRUE

/obj/structure/roguemachine/money/twins/Initialize()
	. = ..()
	budget = rand(50,200)
	icon_state = "twins"
	update_icon()
	GLOB.moneymaster = src

/obj/structure/roguemachine/money/twins/obj_break(damage_flag)
	. = ..()
	GLOB.moneymaster = null

/obj/structure/roguemachine/money/twins/update_icon()
	cut_overlays()
	if(obj_broken)
		set_light(0)
		return
	if(budget > 10)
		add_overlay(mutable_appearance(icon, "[icon_state]-e"))
	else
		add_overlay(mutable_appearance(icon, "[icon_state]-b"))
	set_light(1, 1, "#1b7bf1")