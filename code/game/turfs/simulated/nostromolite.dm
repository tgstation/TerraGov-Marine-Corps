var/list/obj/effect/death_drop/DEATH_TELEPORT = list()

/turf/unsimulated/floor/nostromowater
	name = "ocean"
	desc = "Its a long way down to the ocean from here."
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "seadeep"

/obj/effect/death_drop
	name = "deathdrop"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	var/id = null			//id of this bump_teleporter.
	var/id_target = null	//id of bump_teleporter which this moves you to.
	invisibility = 101 		//nope, can't see this
	anchored = 1
	density = 1
	opacity = 0

/obj/effect/death_drop/New()
	..()
	DEATH_TELEPORT += src

/obj/effect/death_drop/Del()
	DEATH_TELEPORT -= src
	..()

/obj/effect/death_drop/Bumped(atom/user)
	if(!ismob(user))
		return

	if(!id_target)
		return

	for(var/obj/effect/death_drop/DT in DEATH_TELEPORT)
		if(DT.id == src.id_target)
			user.visible_message("<span class='notice'>[user] falls to their doom!</span>", "<span class='notice'>You fall to your doom!</span>")
			usr.loc = DT.loc
			var/mob/living/M = user
			M << "Your life flashes before you're mind as your body is crushed!"
			M.apply_damage(5000, BRUTE, sharp=1, edge=1)
			return

/area/nostromorig
	name = "\improper Ocean"
	icon_state = "yellow"
	requires_power = 1
	always_unpowered = 1
	lighting_use_dynamic = 0
	luminosity = 0.1
	power_light = 0
	power_equip = 0
	power_environ = 0
	ambience = list('sound/ambience/ambispace.ogg')

/obj/item/bananapeel/surface_slip
	name = "slippery surface"
	desc = "A slippery surface, likely from water."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "banana_peel"
	item_state = "banana_peel"
	invisibility = 101 		//nope, can't see this
	anchored = 1
	w_class = 2.0
	throwforce = 0
	throw_speed = 4
	throw_range = 20
