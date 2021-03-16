/obj/structure/cocoon
	name = "resin cocoon"
	desc = "A slimy-looking cocoon made out of resin. It is vibrating from the outside, yuck."
	icon = 'icons/obj/cocoon.dmi'
	icon_state = "xeno_cocoon"
	density = FALSE
	layer = BELOW_OBJ_LAYER
	hit_sound = 'sound/effects/alien_resin_break2.ogg'
	max_integrity = 800
	anchored = TRUE
	obj_flags = CAN_BE_HIT
	///Which hive it belongs too
	var/hivenumber
	///What is inside the cocoon
	var/mob/living/victim
	///How much time the cocoon takes to deplete the life force of the marine
	var/cocoon_life_time = 15 MINUTES
	///How many psych points it is generating every 5 seconds
	var/psych_points_output = 1
	///If the cocoon should produce psych points
	var/producing_points = TRUE
	///Standard busy check
	var/busy = FALSE


/obj/structure/cocoon/Initialize(mapload, _hivenumber, mob/living/_victim)
	. = ..()
	hivenumber =  _hivenumber
	victim = _victim
	victim.forceMove(src)
	if(!producing_points)
		return
	START_PROCESSING(SSslowprocess, src)
	addtimer(CALLBACK(src, .proc/life_draining_over, TRUE), cocoon_life_time)
	new /obj/effect/alien/weeds/node(loc)

/obj/structure/cocoon/examine(mob/user, distance, infix, suffix)
	. = ..()
	if(producing_points && victim && ishuman(user))
		to_chat(user, "<span class='notice'>There is something inside it. You think you can open it with a sharp object</span>")

/obj/structure/cocoon/process()
	SSpoints.xeno_points_by_hive[hivenumber] += psych_points_output

/obj/structure/cocoon/take_damage(damage_amount, damage_type, damage_flag, effects, attack_dir, armour_penetration)
	. = ..()
	if(producing_points && obj_integrity < max_integrity / 2)
		life_draining_over()

/obj/structure/cocoon/proc/life_draining_over(must_release_victim = FALSE)
	STOP_PROCESSING(SSslowprocess, src)
	playsound(loc, "alien_resin_move", 35)
	new /obj/structure/bed/nest(loc)
	producing_points = FALSE
	update_icon()
	anchored = FALSE
	if(must_release_victim)
		release_victim()

/obj/structure/cocoon/Destroy()
	if(victim)
		release_victim()
	return ..()

///Open the cocoon and move the victim out 
/obj/structure/cocoon/proc/release_victim()
	REMOVE_TRAIT(victim, TRAIT_STASIS, TRAIT_STASIS)
	playsound(loc, "alien_resin_move", 35)
	victim.forceMove(loc)
	victim.setDir(NORTH)
	victim.med_hud_set_status()
	victim = null

/obj/structure/cocoon/attacked_by(obj/item/I, mob/living/user, def_zone)
	if(!producing_points && victim)
		if(busy)
			return
		if(!I.sharp)
			return
		busy = TRUE
		var/channel = SSsounds.random_available_channel()
		playsound(user, "sound/effects/cutting_cocoon.ogg", 30, channel = channel)
		if(!do_after(user, 10 SECONDS, TRUE, src))
			busy = FALSE
			user.stop_sound_channel(channel)
			return
		release_victim()
		update_icon()
		busy = FALSE
		return
	return ..()

/obj/structure/cocoon/update_icon_state()
	if(producing_points)
		icon_state = "xeno_cocoon"
		return
	if(victim)
		icon_state = "xeno_cocoon_unnested"
		return
	icon_state = "xeno_cocoon_open"
	
