
/obj/machinery/anvil
	icon = 'icons/roguetown/misc/forge.dmi'
	name = "anvil"
	icon_state = "anvil"
	var/hott = null
	var/obj/item/ingot/hingot
	max_integrity = 2000
	density = TRUE
	damage_deflection = 25
	climbable = TRUE

/obj/machinery/anvil/crafted
	icon_state = "caveanvil"

/obj/machinery/anvil/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/rogueweapon/tongs))
		var/obj/item/rogueweapon/tongs/T = W
		if(hingot)
			if(T.hingot)
				..()
				return
			else
				hingot.forceMove(T)
				T.hingot = hingot
				hingot = null
				T.hott = null
				hott = null
				T.update_icon()
				update_icon()
				return
		else
			if(T.hingot && istype(T.hingot, /obj/item/ingot))
				T.hingot.forceMove(src)
				hingot = T.hingot
				T.hingot = null
				hott = T.hott
				if(hott)
					START_PROCESSING(SSmachines, src)
				T.update_icon()
				update_icon()
				return
	if(istype(W, /obj/item/ingot))
		if(!hingot)
			W.forceMove(src)
			hingot = W
			hott = null
			update_icon()
			return
	if(istype(W, /obj/item/rogueweapon/hammer))
		user.changeNext_move(CLICK_CD_MELEE)
		if(hingot)
			if(hott)
				if(hingot.currecipe)
					var/used_str = user.STASTR
					if(iscarbon(user))
						var/mob/living/carbon/C = user
						if(C.domhand)
							used_str = C.get_str_arms(C.used_hand)
						C.rogfat_add(max(30 - (used_str * 3), 0))
					if(hingot.currecipe.advance(user))
						playsound(src,pick('sound/items/bsmith1.ogg','sound/items/bsmith2.ogg','sound/items/bsmith3.ogg','sound/items/bsmith4.ogg'), 100, FALSE)
					else
						shake_camera(user, 1, 1)
						playsound(src,'sound/items/bsmithfail.ogg', 100, FALSE)
					if(prob(23))
						user.flash_fullscreen("whiteflash")
						var/datum/effect_system/spark_spread/S = new()
						var/turf/front = get_turf(src)
						S.set_up(1, 1, front)
						S.start()
				else
					if(choose_recipe(user))
						user.flash_fullscreen("whiteflash")
						shake_camera(user, 1, 1)
						playsound(src,pick('sound/items/bsmith1.ogg','sound/items/bsmith2.ogg','sound/items/bsmith3.ogg','sound/items/bsmith4.ogg'), 100, FALSE)
					else
						return
				for(var/mob/M in GLOB.player_list)
					if(!is_in_zweb(M.z,src.z))
						continue
					var/turf/M_turf = get_turf(M)
					var/far_smith_sound = sound(pick('sound/items/smithdist1.ogg','sound/items/smithdist2.ogg','sound/items/smithdist3.ogg'))
					if(M_turf)
						var/dist = get_dist(M_turf, loc)
						if(dist < 7)
							continue
						M.playsound_local(M_turf, null, 100, 1, get_rand_frequency(), falloff = 5, S = far_smith_sound)
			else
				to_chat(user, "<span class='warning'>It's too cold.</span>")
				return
			return
	if(hingot && hingot.currecipe && hingot.currecipe.needed_item && istype(W, hingot.currecipe.needed_item))
		hingot.currecipe.item_added(user)
		qdel(W)
		return
	if(W.anvilrepair)
		user.visible_message("<span class='info'>[user] places [W] on the anvil.</span>")
		W.forceMove(src.loc)
		return
	..()

/obj/machinery/anvil/proc/choose_recipe(user)
	if(!hingot || !hott)
		return
	var/list/appro_recipe = GLOB.anvil_recipes.Copy()
	for(var/I in appro_recipe)
		var/datum/anvil_recipe/R = I
		if(!R.req_bar)
			appro_recipe -= R
		if(!istype(hingot, R.req_bar))
			appro_recipe -= R
	if(appro_recipe.len)
		var/datum/chosen_recipe = input(user, "Choose A Creation", "Anvil") as null|anything in sortNames(appro_recipe.Copy())
		if(!hingot.currecipe && chosen_recipe)
			hingot.currecipe = new chosen_recipe.type(hingot)
			return TRUE
	return FALSE

/obj/machinery/anvil/attack_hand(mob/user, params)
	if(hingot)
		if(hott)
			to_chat(user, "<span class='warning'>It's too hot.</span>")
			return
		else
			var/obj/item/I = hingot
			hingot = null
			I.loc = user.loc
			user.put_in_active_hand(I)
			update_icon()

/obj/machinery/anvil/process()
	if(hott)
		if(world.time > hott + 10 SECONDS)
			hott = null
			STOP_PROCESSING(SSmachines, src)
	else
		STOP_PROCESSING(SSmachines, src)
	update_icon()

/obj/machinery/anvil/update_icon()
	cut_overlays()
	if(hingot)
		var/obj/item/I = hingot
		I.pixel_x = 0
		I.pixel_y = 0
		var/mutable_appearance/M = new /mutable_appearance(I)
		if(hott)
			M.filters += filter(type="color", color = list(3,0,0,1, 0,2.7,0,0.4, 0,0,1,0, 0,0,0,1))
		M.transform *= 0.5
		M.pixel_y = 5
		M.pixel_x = 3
		add_overlay(M)
