
/obj/vehicle/ridden/atv
	name = "all-terrain vehicle"
	desc = "An all-terrain vehicle built for traversing rough terrain with ease. One of the few old-Earth technologies that are still relevant on most planet-bound outposts."
	icon_state = "atv"
	max_integrity = 150
	soft_armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 0, BOMB = 30, FIRE = 60, ACID = 60)
	key_type = /obj/item/key/atv
	integrity_failure = 0.5
	var/static/mutable_appearance/atvcover

/obj/vehicle/ridden/atv/Initialize()
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/atv)
	if(!atvcover)
		atvcover = mutable_appearance(icon, "atvcover", MOB_LAYER + 0.1)

/obj/vehicle/ridden/atv/post_buckle_mob(mob/living/M)
	add_overlay(atvcover)
	return ..()

/obj/vehicle/ridden/atv/post_unbuckle_mob(mob/living/M)
	if(!LAZYLEN(buckled_mobs))
		cut_overlay(atvcover)
	return ..()

/obj/vehicle/ridden/atv/welder_act(mob/living/user, obj/item/I)
	if(obj_integrity >= max_integrity)
		return TRUE
	if(!I.use_tool(src, user, 0, volume=50, amount=1))
		return TRUE
	user.visible_message(span_notice("[user] repairs some damage to [name]."), span_notice("You repair some damage to \the [src]."))
	obj_integrity += min(10, max_integrity-obj_integrity)
	if(obj_integrity == max_integrity)
		to_chat(user, span_notice("It looks to be fully repaired now."))
	return TRUE

/obj/vehicle/ridden/atv/obj_break()
	START_PROCESSING(SSobj, src)
	return ..()

/obj/vehicle/ridden/atv/process(delta_time)
	if(obj_integrity >= integrity_failure * max_integrity)
		return PROCESS_KILL
	if(prob(20))
		return
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(0, src)
	smoke.start()

/obj/vehicle/ridden/atv/bullet_act(obj/projectile/P)
	if(prob(50) || !buckled_mobs)
		return ..()
	for(var/mob/buckled_mob AS in buckled_mobs)
		buckled_mob.bullet_act(P)
	return TRUE

/obj/vehicle/ridden/atv/obj_destruction()
	explosion(src, devastation_range = -1, light_impact_range = 2, flame_range = 3, flash_range = 4)
	return ..()

/obj/vehicle/ridden/atv/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()
