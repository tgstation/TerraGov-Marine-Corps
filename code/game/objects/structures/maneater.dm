
/obj/structure/flora/roguegrass/maneater
	name = "grass"
	icon = 'icons/roguetown/mob/monster/maneater.dmi'
	icon_state = "maneater-hidden"
	max_integrity = 5

/obj/structure/flora/roguegrass/maneater/update_icon()
	return

/obj/structure/flora/roguegrass/maneater/real
	var/aggroed = 0
	max_integrity = 100
	integrity_failure = 0.15
	attacked_sound = list('sound/vo/mobs/plant/pain (1).ogg','sound/vo/mobs/plant/pain (2).ogg','sound/vo/mobs/plant/pain (3).ogg','sound/vo/mobs/plant/pain (4).ogg')
	var/list/eatablez = list(/obj/item/bodypart, /obj/item/organ, /obj/item/reagent_containers/food/snacks/rogue/meat)
	var/last_eat
	buckle_lying = 0
	buckle_prevents_pull = 1

/obj/structure/flora/roguegrass/maneater/real/Initialize()
	. = ..()
	proximity_monitor = new(src, 1)

/obj/structure/flora/roguegrass/maneater/real/Destroy()
	QDEL_NULL(proximity_monitor)
	unbuckle_all_mobs()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/flora/roguegrass/maneater/real/obj_break(damage_flag)
	..()
	QDEL_NULL(proximity_monitor)
	unbuckle_all_mobs()
	STOP_PROCESSING(SSobj, src)
	update_icon()

/obj/structure/flora/roguegrass/maneater/real/process()
	if(!has_buckled_mobs())
		if(world.time > last_eat + 50)
			var/list/around = view(1, src)
			for(var/mob/living/M in around)
				HasProximity(M)
				return
			for(var/obj/item/F in around)
				if(is_type_in_list(F, eatablez))
					aggroed = world.time
					last_eat = world.time
					playsound(src,'sound/misc/eat.ogg', rand(30,60), TRUE)
					qdel(F)
					return
		if(world.time > aggroed + 30 SECONDS)
			aggroed = 0
			update_icon()
			STOP_PROCESSING(SSobj, src)
			return TRUE
	for(var/mob/living/L in buckled_mobs)
		if(world.time > last_eat + 50)
			last_eat = world.time
			L.flash_fullscreen("redflash3")
			playsound(src.loc, list('sound/vo/mobs/plant/attack (1).ogg','sound/vo/mobs/plant/attack (2).ogg','sound/vo/mobs/plant/attack (3).ogg','sound/vo/mobs/plant/attack (4).ogg'), 100, FALSE, -1)
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				src.visible_message("<span class='danger'>[src] starts to rip apart [C]!</span>")
				spawn(50)
					if(C && (C.buckled == src))
						var/obj/item/bodypart/limb
						var/list/limb_list = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
						for(var/zone in limb_list)
							limb = C.get_bodypart(zone)
							if(limb)
								playsound(src,'sound/misc/eat.ogg', rand(30,60), TRUE)
								limb.dismember()
								qdel(limb)
								return
						limb = C.get_bodypart(BODY_ZONE_HEAD)
						if(limb)
							playsound(src,'sound/misc/eat.ogg', rand(30,60), TRUE)
							limb.dismember()
							qdel(limb)
							return
						limb = C.get_bodypart(BODY_ZONE_CHEST)
						if(limb)
							if(!limb.dismember())
								C.gib()
							return
			else
				src.visible_message("<span class='danger'>[src] starts to rip apart [L]!</span>")
				spawn(50)
					if(L && (L.buckled == src))
						L.gib()
						return

/obj/structure/flora/roguegrass/maneater/real/update_icon()
	if(obj_broken)
		name = "MANEATER"
		icon_state = "maneater-dead"
		return
	if(aggroed)
		name = "MANEATER"
		icon_state = "maneater"
	else
		name = "grass"
		icon_state = "maneater-hidden"

/obj/structure/flora/roguegrass/maneater/real/user_unbuckle_mob(mob/living/M, mob/user)
	if(obj_broken)
		..()
		return
	if(isliving(user))
		var/mob/living/L = user
		var/time2mount = CLAMP((L.STASTR * 2), 1, 99)
		user.changeNext_move(CLICK_CD_RAPID)
		if(user != M)
			if(prob(time2mount))
				..()
			else
				user.visible_message("<span class='warning'>[user] tries to pull [M] free of [src]!</span>")
			return
		if(prob(time2mount))
			..()
		else
			user.visible_message("<span class='warning'>[user] tries to break free of [src]!</span>")

/obj/structure/flora/roguegrass/maneater/real/user_buckle_mob(mob/living/M, mob/living/user) //Don't want them getting put on the rack other than by spiking
	return

/obj/structure/flora/roguegrass/maneater/real/HasProximity(atom/movable/AM)
	if(has_buckled_mobs())
		return
	if(world.time > last_eat + 50)
		var/list/around = view(src, 1) // scan for enemies
		if(!(AM in around))
			return
		if(istype(AM, /mob/living))
			var/mob/living/L = AM
			if(!aggroed)
				if(L.m_intent != MOVE_INTENT_RUN)
					return
			aggroed = world.time
			last_eat = world.time
			update_icon()
			buckle_mob(L, TRUE, check_loc = FALSE)
			START_PROCESSING(SSobj, src)
			if(!HAS_TRAIT(L, TRAIT_NOPAIN))
				L.emote("painscream", forced = TRUE)
			src.visible_message("<span class='danger'>[src] snatches [L]!</span>")
			playsound(src.loc, list('sound/vo/mobs/plant/attack (1).ogg','sound/vo/mobs/plant/attack (2).ogg','sound/vo/mobs/plant/attack (3).ogg','sound/vo/mobs/plant/attack (4).ogg'), 100, FALSE, -1)
		if(istype(AM, /obj/item))
			if(is_type_in_list(AM, eatablez))
				aggroed = world.time
				last_eat = world.time
				START_PROCESSING(SSobj, src)
				update_icon()
				playsound(src,'sound/misc/eat.ogg', rand(30,60), TRUE)
				qdel(AM)
				return
/obj/structure/flora/roguegrass/maneater/real/attackby(obj/item/W, mob/user, params)
	. = ..()
	aggroed = world.time
	update_icon()
