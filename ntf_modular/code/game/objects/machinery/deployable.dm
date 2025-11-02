/obj/machinery/deployable/obj_destruction(damage_amount, damage_type, damage_flag, mob/living/blame_mob)
	log_combat(blame_mob, src, "destroyed")
	. = ..()

/obj/machinery/deployable/bullet_act(atom/movable/projectile/proj)
	if(!proj.firer)
		src.log_message("was shot by SOMETHING?? with [logdetails(proj)]", LOG_ATTACK)
	log_combat(proj.firer, src, "shot", proj)
	. = ..()
