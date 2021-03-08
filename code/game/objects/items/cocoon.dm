/obj/cocoon
	name = "cocoon"
	desc = "A slimy looking cocoon, it is covered by weird resin and it is vibrating"
	icon = 'icons/obj/cocoon.dmi'
	icon_state = "xeno_cocoon"
	density = FALSE
	layer = BELOW_OBJ_LAYER
	hit_sound = 'sound/effects/alien_resin_break2.ogg'
	max_integrity = 400
	anchored = TRUE
	obj_flags = CAN_BE_HIT
	///Which hive it belongs too
	var/hivenumber
	///What is inside the cocoon
	var/mob/living/victim
	///How much time the cocoon takes to deplete the life force of the marine
	var/cocoon_life_time = 15 MINUTES
	///How many psych points it is generating in 5 seconds
	var/psych_points_output = 1
	///If the cocoon should produce psych points
	var/nested = TRUE


/obj/cocoon/Initialize(mapload, _hivenumber, mob/living/_victim)
	. = ..()
	hivenumber =  _hivenumber
	victim = _victim
	victim.forceMove(src)
	if(!nested)
		return
	START_PROCESSING(SSslowprocess, src)
	addtimer(CALLBACK(src, .proc/release_victim), cocoon_life_time)
	new /obj/effect/alien/weeds/node(loc)

/obj/cocoon/process()
	SSpoints.xeno_points_by_hive[hivenumber] += psych_points_output

/obj/cocoon/Destroy()
	if(victim)
		STOP_PROCESSING(SSslowprocess, src)
		new /obj/structure/bed/nest(loc)
		new /obj/cocoon/unnested(loc, hivenumber, victim)
		victim = null
	return ..()

/obj/cocoon/proc/release_victim()
	REMOVE_TRAIT(victim, TRAIT_STASIS, TRAIT_STASIS)
	if(nested)
		STOP_PROCESSING(SSslowprocess, src)
		return
	playsound(loc, "alien_resin_move", 25)
	victim.forceMove(loc)
	victim.setDir(NORTH)
	victim = null

/obj/cocoon/unnested
	name = "unnested cocoon"
	desc = "A slimy looking cocoon"
	icon_state = "xeno_cocoon_unnested"
	layer = OBJ_LAYER
	max_integrity = 400
	anchored = FALSE
	nested = FALSE

/obj/cocoon/unnested/attacked_by(obj/item/I, mob/living/user, def_zone)
	if(victim && I.sharp && do_after(user, 10 SECONDS, TRUE, src))
		playsound(user, "sound/effects/cutting_cocoon.ogg")
		release_victim()
		update_icon_state()
		obj_flag = CAN_BE_HIT

/obj/cocoon/unnested/update_icon_state()
	if(victim)
		icon_state = "xeno_cocoon_unnested"
		return
	icon_state = "xeno_cocoon_open"
	
		

	
