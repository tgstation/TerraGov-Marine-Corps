
/obj/item
	var/smeltresult

/obj/machinery/light/rogue/smelter
	icon = 'icons/roguetown/misc/forge.dmi'
	name = "furnace"
	icon_state = "cavesmelter0"
	base_state = "cavesmelter"
	anchored = TRUE
	density = TRUE
	climbable = TRUE
	climb_time = 0
	climb_offset = 10
	on = TRUE
	var/list/ore = list()
	var/maxore = 1
	var/cooking = 0
	fueluse = 5 MINUTES
	crossfire = FALSE

/obj/machinery/light/rogue/smelter/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/rogueweapon/tongs))
		var/obj/item/rogueweapon/tongs/T = W
		if(ore.len && !T.hingot)
			var/obj/item/I = ore[ore.len]
			ore -= I
			I.forceMove(T)
			T.hingot = I
			user.visible_message("<span class='info'>[user] retrieves [I] from [src].</span>")
			if(on)
				var/tyme = world.time
				T.hott = tyme
				addtimer(CALLBACK(T, /obj/item/rogueweapon/tongs.proc/make_unhot, tyme), 50)
			T.update_icon()
			return
		if(on)
			return
	if(istype(W, /obj/item/rogueore/coal) && fueluse <= 0)
		return ..()
	if((ore.len < maxore) && W.smeltresult)
		W.forceMove(src)
		ore += W
		user.visible_message("<span class='warning'>[user] puts something in the smelter.</span>")
		cooking = 0
		return
	return ..()


/obj/machinery/light/rogue/smelter/attack_hand(mob/user, params)
	if(on)
		to_chat(user, "<span class='warning'>It's too hot.</span>")
		return
	if(ore.len)
		var/obj/item/I = ore[ore.len]
		ore -= I
		I.loc = user.loc
		user.put_in_active_hand(I)
		user.visible_message("<span class='info'>[user] retrieves [I] from [src].</span>")
	else
		return ..()


/obj/machinery/light/rogue/smelter/process()
	..()
	if(maxore > 1)
		return
	if(on)
		if(ore.len)
			if(cooking < 20)
				cooking++
				playsound(src.loc,'sound/misc/smelter_sound.ogg', 50, FALSE)
			else
				if(cooking == 20)
					for(var/obj/item/I in ore)
						if(I.smeltresult)
							ore -= I
							var/obj/item/R = new I.smeltresult(src)
							ore += R
							qdel(I)
					playsound(src,'sound/misc/smelter_fin.ogg', 100, FALSE)
					cooking = 21

/obj/machinery/light/rogue/smelter/burn_out()
	cooking = 0
	..()

/obj/machinery/light/rogue/smelter/great
	icon = 'icons/roguetown/misc/forge.dmi'
	name = "great furnace"
	icon_state = "smelter0"
	base_state = "smelter"
	anchored = TRUE
	density = TRUE
	maxore = 4
	fueluse = 10 MINUTES
	climbable = FALSE

/obj/machinery/light/rogue/smelter/great/process()
	..()
	if(on)
		if(ore.len)
			if(cooking < 30)
				cooking++
				playsound(src.loc,'sound/misc/smelter_sound.ogg', 50, FALSE)
			else
				if(cooking == 30)
					var/alloy
					for(var/obj/item/I in ore)
						if(I.smeltresult == /obj/item/rogueore/coal)
							alloy = alloy + 1
						if(I.smeltresult == /obj/item/ingot/iron)
							alloy = alloy + 2
					if(alloy == 7)
						testing("ALLOYED")
						alloy = /obj/item/ingot/steel
					else
						alloy = null
					if(alloy)
						for(var/obj/item/I in ore)
							ore -= I
							qdel(I)
						for(var/i in 1 to maxore)
							var/obj/item/R = new alloy(src)
							ore += R
					else
						for(var/obj/item/I in ore)
							if(I.smeltresult)
								ore -= I
								var/obj/item/R = new I.smeltresult(src)
								ore += R
								qdel(I)
					playsound(src,'sound/misc/smelter_fin.ogg', 100, FALSE)
					cooking = 31