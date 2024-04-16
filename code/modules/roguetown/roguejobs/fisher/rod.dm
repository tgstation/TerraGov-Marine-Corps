/obj/item/fishingrod
	force = 12
	possible_item_intents = list(SPEAR_BASH,ROD_CAST)
	name = "fishing rod"
	desc = ""
	icon_state = "rod"
	icon = 'icons/roguetown/weapons/tools.dmi'
	sharpness = IS_BLUNT
	wlength = 33
	var/obj/item/baited = null
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_HIP
	w_class = WEIGHT_CLASS_BULKY

/datum/intent/cast
	name = "cast"
	chargetime = 0
	noaa = TRUE
	misscost = 0
	icon_state = "inuse"
	no_attack = TRUE

/obj/item/fishingrod/attack_self(mob/user)
	if(user.doing)
		user.doing = 0
	else
		..()


/obj/item/fishingrod/attackby(obj/item/I, mob/user, params)
	if(I.baitchance && !baited)
		user.visible_message("<span class='notice'>[user] hooks something to the line.</span>", \
							"<span class='notice'>I hook [I] to my line.</span>")
		playsound(src.loc, 'sound/foley/pierce.ogg', 50, FALSE)
		if(istype(I,/obj/item/natural/worms))
			var/obj/item/natural/worms/W = I
			if(W.amt > 1)
				W.amt--
				var/obj/item/natural/worms/N = new W.type(src)
				baited = N
			else
				W.forceMove(src)
				baited = W
		else
			I.forceMove(src)
			baited = I
		update_icon()
		return
	. = ..()

/obj/item/fishingrod/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.6,"sx" = -17,"sy" = -1,"nx" = 11,"ny" = -1,"wx" = -14,"wy" = 0,"ex" = 3,"ey" = -2,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/fishingrod/afterattack(obj/target, mob/user, proximity)
	if(user.used_intent.type == SPEAR_BASH)
		return ..()

	if(!check_allowed_items(target,target_self=1))
		return ..()

	if(istype(target, /turf/open/water))
		if(user.used_intent.type == ROD_CAST && !user.doing)
			if(target in range(user,5))
				user.visible_message("<span class='warning'>[user] casts a line!</span>", \
									"<span class='notice'>I cast a line.</span>")
				playsound(src.loc, 'sound/items/fishing_plouf.ogg', 100, TRUE)
				if(do_after(user,rand(80,150), target = target)) //rogtodo based on fishing skill
					if(baited)
						var/bc = baited.baitchance
						var/ft = 30
						if(user.mind)
							var/sl = user.mind.get_skill_level(/datum/skill/labor/fishing)
							if(!sl)
								bc = 0
							else
								ft += (sl * 10)
								bc += (sl * 10)
						if(prob(bc))
							var/A = pickweight(baited.fishloot)
							to_chat(user, "<span class='notice'>Something tugs the line!</span>")
							playsound(src.loc, 'sound/items/fishing_plouf.ogg', 100, TRUE)
							if(!do_after(user,ft, target = target)) //rogtodo based on fishing skill
								if(ismob(A))
									var/mob/M = A
									if(M.type in subtypesof(/mob/living/simple_animal/hostile))
										new M(target)
									else
										new M(user.loc)
								else
									new A(user.loc)
								playsound(src.loc, 'sound/items/Fish_out.ogg', 100, TRUE)
							else
								to_chat(user, "<span class='warning'>Damn, got away...</span>")
						else
							to_chat(user, "<span class='warning'>Damn, got away...</span>")
						qdel(baited)
						baited = null
					else
						to_chat(user, "<span class='warning'>This seems pointless.</span>")
			update_icon()

/obj/item/fishingrod/update_icon()
	cut_overlays()
	if(baited)
		var/obj/item/I = baited
		I.pixel_x = 6
		I.pixel_y = -6
		add_overlay(new /mutable_appearance(I))
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()
