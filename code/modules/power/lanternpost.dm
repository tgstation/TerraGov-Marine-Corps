/obj/machinery/light/rogue/lanternpost
	name = "lantern post"
	icon = 'icons/roguetown/misc/tallstructure.dmi'
	icon_state = "streetlantern1"
	base_state = "streetlantern"
	brightness = 5
	density = FALSE
	var/obj/item/flashlight/flare/torch/torchy
	fueluse = 0 //we use the torch's fuel
	soundloop = null
	crossfire = FALSE
	plane = GAME_PLANE_UPPER
	cookonme = FALSE

/obj/machinery/light/rogue/lanternpost/fire_act(added, maxstacks)
	if(torchy)
		if(!on)
			if(torchy.fuel > 0)
				torchy.spark_act()
				playsound(src.loc, 'sound/items/firelight.ogg', 100)
				on = TRUE
				update()
				update_icon()
				if(soundloop)
					soundloop.start()
				addtimer(CALLBACK(src, .proc/trigger_weather), rand(5,20))

/obj/machinery/light/rogue/lanternpost/Initialize()
	torchy = new /obj/item/flashlight/flare/torch/lantern(src)
	torchy.spark_act()
	. = ..()

/obj/machinery/light/rogue/lanternpost/process()
	if(on)
		if(torchy)
			if(torchy.fuel <= 0)
				burn_out()
			if(!torchy.on)
				burn_out()
		else
			return PROCESS_KILL

/obj/machinery/light/rogue/lanternpost/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(torchy)
		if(!istype(user) || !Adjacent(user) || !user.put_in_active_hand(torchy))
			torchy.forceMove(loc)
		torchy = null
		on = FALSE
		set_light(0)
		update_icon()
		playsound(src.loc, 'sound/foley/torchfixturetake.ogg', 100)

/obj/machinery/light/rogue/lanternpost/update_icon()
	if(torchy)
		if(on)
			icon_state = "[base_state]1"
		else
			icon_state = "[base_state]0"
	else
		icon_state = "streetlantern"

/obj/machinery/light/rogue/lanternpost/burn_out()
	if(torchy.on)
		torchy.turn_off()
	..()

/obj/machinery/light/rogue/lanternpost/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/flashlight/flare/torch))
		var/obj/item/flashlight/flare/torch/LR = W
		if(torchy)
			if(LR.on && !on)
				if(torchy.fuel <= 0)
					to_chat(user, "<span class='warning'>The mounted lantern is burned out.</span>")
					return
				else
					torchy.spark_act()
					user.visible_message("<span class='info'>[user] lights [src].</span>")
					playsound(src.loc, 'sound/items/firelight.ogg', 100)
					on = TRUE
					update()
					update_icon()
					addtimer(CALLBACK(src, .proc/trigger_weather), rand(5,20))
					return
			if(!LR.on && on)
				if(LR.fuel > 0)
					LR.spark_act()
					user.visible_message("<span class='info'>[user] lights [LR] in [src].</span>")
					user.update_inv_hands()
		else
			if(LR.on)
				LR.forceMove(src)
				torchy = LR
				on = TRUE
				update()
				update_icon()
				addtimer(CALLBACK(src, .proc/trigger_weather), rand(5,20))
			else
				LR.forceMove(src)
				torchy = LR
				update_icon()
			playsound(src.loc, 'sound/foley/torchfixtureput.ogg', 100)
		return
	. = ..()