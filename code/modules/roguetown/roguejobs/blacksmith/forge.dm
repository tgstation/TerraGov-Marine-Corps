
/obj/machinery/light/rogue/forge
	icon = 'icons/roguetown/misc/forge.dmi'
	name = "forge"
	icon_state = "forge0"
	base_state = "forge"
	density = TRUE
	anchored = TRUE
	on = FALSE
	climbable = TRUE
	climb_time = 0

/obj/machinery/light/rogue/forge/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/rogueweapon/tongs) && on)
		var/obj/item/rogueweapon/tongs/T = W
		if(T.hingot)
			var/tyme = world.time
			T.hott = tyme
			addtimer(CALLBACK(T, /obj/item/rogueweapon/tongs.proc/make_unhot, tyme), 100)
			T.update_icon()
			user.visible_message("<span class='info'>[user] heats the bar.</span>")
			return
	..()