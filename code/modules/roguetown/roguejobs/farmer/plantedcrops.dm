
/obj/machinery/crop
	name = "tilled dirt"
	desc = ""
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "blank"
	density = FALSE
	climbable = FALSE
	max_integrity = 0
	var/growth = 0
	var/weeds = 0				//they appear at a value of 50 but don't start damaging the crop until 100
	var/water = 30
	var/food = 30
	var/php = 30
	var/mphp = 100				//normally plants can't heal if they're dying, but certain things can heal crops to this max
	var/obj/item/seeds/myseed
	var/lastcycle = 0
	var/seesky = TRUE

/obj/machinery/crop/Crossed(atom/movable/AM)
	if(isliving(AM))
		if(myseed)
			php = max(php-11, 0)
		else
			qdel(src)
	..()

/obj/machinery/crop/examine(mob/user)
	. = ..()
	if(growth >= 100)
		. += "<span class='notice'>[src] is ready for harvest!</span>"
	if(water < 25)
		. += "<span class='info'>The ground is thirsty.</span>"
	if(food < 25)
		. += "<span class='info'>The ground is hungry.</span>"
	if(weeds > 25)
		. += "<span class='warning'>Weeds!</span>"
	if(php < 25)
		. += "<span class='warning'>Brown and dying...</span>"

/obj/machinery/crop/process()
	if(QDELETED(src))
		return
	var/needs_update = 0

	if(!myseed)
		STOP_PROCESSING(SSmachines, src)
		qdel(src)
		return

	if(world.time > (lastcycle + 10 SECONDS))
		lastcycle = world.time

//		var/turf/T = loc
//		if(T)
//			for(var/D in GLOB.cardinals)
//				var/turf/TU = get_step(T, D)
//				if(istype(TU, /turf/open/water))
//					water = 100
//					break

		if(seesky)
			php = max(php-1, 0) //offset by healing from food if there are not weeds
		else
			php = max(php-2, 0)
			weeds = 0
			growth = 0

		if(water > 0)
			if(myseed)
				water = water - myseed.watersucc
			if(weeds >= 50)
				water = water - 1
			water = max(water, 0)
		if(food > 0)
			if(myseed)
				food = food - myseed.foodsucc
			if(weeds >= 50)
				food = food - 1
			else
				if(php < 100)
					php = min(php+1, mphp)
					food = food - 1
			food = max(food, 0)
		if(weeds < 100)
			if(myseed)
				if(growth < 100)
					var/oldgrowth = growth
					growth = growth + (5*myseed.growthrate)
					if(oldgrowth < 50 && growth >= 50)
						needs_update = 1
					if(oldgrowth < 100 && growth >= 100)
						needs_update = 1
				if(prob(myseed.weed_chance))
					var/oldweeds = weeds
					weeds = weeds + myseed.weed_rate
					if(weeds >= 50 && oldweeds < 50)
						needs_update = 1
		else if(php > 0)
			php = max(php-5, 0)

		if(myseed)
			if(myseed.yield <= 0) //end of lifespan for long-lived crops
				php -= 33

		if(php <= 0)
			STOP_PROCESSING(SSmachines, src)
			var/oldname = name
			name = "dead [oldname]"
			needs_update = 1

	if (needs_update)
		update_seed_icon()

/obj/machinery/crop/Destroy(force=FALSE)
	if(myseed)
		QDEL_NULL(myseed)
	if(istype(loc, /turf/open/floor/rogue/dirt))
		var/turf/open/floor/rogue/dirt/T = loc
		if(T.planted_crop == src)
			T.planted_crop = null
	. = ..()

/obj/machinery/crop/proc/update_seed_icon()
	cut_overlays()
	var/list/layz = list()

	if(myseed) //put the crop on top
		var/gn = 0
		if(php <= 0) //dead
			if(myseed.obscura)
				opacity = FALSE
				density = FALSE
			gn = 3
		else if(growth >= 50)
			if(myseed.obscura)
				opacity = TRUE
				density = TRUE
			gn = 1
			if(growth >= 100)
				gn = 2
		var/image/crop_overlay = image('icons/roguetown/misc/crops.dmi', "[myseed.species][gn]", "layer"=2.91)
		layz += crop_overlay

	if(weeds >= 50) //put the weeds under
		var/image/weed_overlay = image('icons/roguetown/misc/foliage.dmi', "weeds", "layer"=2.92)
		layz += weed_overlay

	add_overlay(layz)

/obj/machinery/crop/proc/crossed_turf()
	php -= 1

/obj/machinery/crop/proc/rainedon()
	water = 100

/obj/machinery/crop/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/seeds))
		to_chat(user, "<span class='warning'>Something is already growing here.</span>")
		return

	if(istype(I, /obj/item/rogueweapon/sickle))
		if(myseed)
			if(php <= 0)
				to_chat(user, "<span class='warning'>This crop has perished.</span>")
				return
			if(growth >= 100)
				for(var/i in 1 to myseed.yield)
					if(php <= 0)
						return
					var/ttime = 1
					if(!I.remove_bintegrity(1))
						ttime = 20
					if(do_after(user,ttime, target = src)) //ROGTODO make this based on farming skill
						new myseed.product(src.loc)
						myseed.yield -= 1
						playsound(src,"plantcross", 100, FALSE)
						user.visible_message("<span class='notice'>[user] harvests [src] with [I].</span>")
					else
						break
				if(myseed?.yield <= 0)
					if(myseed.delonharvest)
						qdel(src)
						return
					else
						myseed.timesharvested++
						growth = 0
						myseed.yield = max(initial(myseed.yield) - myseed.timesharvested,0)
					if(!myseed.yield)
						php = 0
					update_seed_icon()
		return

	if(istype(I, /obj/item/rogueweapon/hoe))
		if(user.used_intent.type == /datum/intent/till)
			if(php <= 0)
				playsound(src,'sound/items/seed.ogg', 100, FALSE)
				new /obj/item/natural/fibers(src.loc)
				user.visible_message("<span class='notice'>[user] rips out [src] with [I].</span>")
				qdel(src)
				return
			else if(weeds > 0)
				playsound(src,'sound/items/seed.ogg', 100, FALSE)
				user.visible_message("<span class='notice'>[user] rips out some weeds with [I].</span>")
				weeds = max(weeds - rand(1,50), 0)
				update_seed_icon()
		return


	if(istype(I, /obj/item/natural/poo))
		playsound(src,'sound/items/seed.ogg', 100, FALSE)
		visible_message("<span class='notice'>[user] confidently fertilizes the soil with [I].</span>")
		qdel(I)
		user.update_inv_hands()
		food = 100
		return
	if(istype(I, /obj/item/ash) || istype(I, /obj/item/trash/applecore))
		playsound(src,'sound/items/seed.ogg', 100, FALSE)
		visible_message("<span class='notice'>[user] confidently fertilizes the soil with [I].</span>")
		food = min(food + 50, 100)
		qdel(I)
		user.update_inv_hands()
		return
	if(istype(I, /obj/item/reagent_containers/food/snacks))
		var/obj/item/reagent_containers/food/snacks/S = I
		if(S.fertamount)
			playsound(src,'sound/items/seed.ogg', 100, FALSE)
			visible_message("<span class='notice'>[user] confidently fertilizes the soil with [I].</span>")
			food = min(food + S.fertamount, 100)
			qdel(I)
			user.update_inv_hands()
			return
	..()

/obj/machinery/crop/attack_hand(mob/M)
	if(!myseed)
		qdel(src)
	var/harvtime = 60
	if(M.mind)
		harvtime = 60 - (M.mind.get_skill_level(/datum/skill/labor/farming) * 10)
	if(php <= 0)
		if(do_after(M,harvtime, target = src))
			playsound(src,"plantcross", 100, FALSE)
			M.visible_message("<span class='notice'>[M] pulls out [src].</span>")
			new /obj/item/natural/fibers(src.loc)
			qdel(src)
			name = initial(name)
			update_seed_icon()
			return
	if(growth >= 100)
		for(var/i in 1 to myseed.yield)
			if(php <= 0)
				return
			if(do_after(M,harvtime, target = src))
				myseed.yield -= 1
				playsound(src,"plantcross", 100, FALSE)
				var/probbi = 10
				if(M.mind.get_skill_level(/datum/skill/labor/farming))
					probbi = 100
				if(prob(probbi))
					new myseed.product(src.loc)
					M.visible_message("<span class='info'>[M] harvests something from [src].</span>")
				else
					M.visible_message("<span class='warning'>[M] spoils something from [src]!</span>")
			else
				break
		if(myseed)
			if(myseed.yield <= 0)
				if(myseed.delonharvest)
					qdel(src)
					return
				else
					myseed.timesharvested++
					growth = 0
					myseed.yield = max(initial(myseed.yield) - myseed.timesharvested,0)
				if(!myseed.yield)
					php = 0
				update_seed_icon()

/obj/machinery/crop/attack_right(mob/user)
	if(weeds > 0)
		if(do_after(user,50, target = src)) //ROGTODO make this based on farming skill
			playsound(src,"plantcross", 100, FALSE)
			user.visible_message("<span class='notice'>[user] rips out some weeds.</span>")
			weeds = max(weeds - rand(1,30), 0)
			update_seed_icon()
		return