

/obj/item/natural/stone
	name = "stone"
	icon_state = "stone1"
	desc = ""
	gripped_intents = null
	dropshrink = 0.75
	possible_item_intents = list(INTENT_GENERIC)
	force = 10
	throwforce = 15
	slot_flags = ITEM_SLOT_MOUTH
	obj_flags = null
	w_class = WEIGHT_CLASS_TINY

/obj/item/natural/stone/Initialize()
	icon_state = "stone[rand(1,4)]"
	..()


/obj/item/natural/stone/attackby(obj/item/W, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(istype(W, /obj/item/natural/stone))
		playsound(src.loc, pick('sound/items/stonestone.ogg'), 100)
		user.visible_message("<span class='info'>[user] strikes the stones together.</span>")
		if(prob(10))
			var/datum/effect_system/spark_spread/S = new()
			var/turf/front = get_step(user,user.dir)
			S.set_up(1, 1, front)
			S.start()
	else
		..()

/obj/item/natural/rock
	name = "rock"
	desc = ""
	icon_state = "stonebig1"
	dropshrink = 0
	throwforce = 25
	throw_range = 2
	force = 15
	obj_flags = CAN_BE_HIT
	force_wielded = 15
	gripped_intents = list(INTENT_GENERIC)
	w_class = WEIGHT_CLASS_HUGE
	twohands_required = TRUE
	var/obj/item/stack/ore/mineralType = null
	var/mineralAmt = 1
	blade_dulling = DULLING_BASH
	max_integrity = 90
	destroy_sound = 'sound/foley/smash_rock.ogg'
	attacked_sound = 'sound/foley/hit_rock.ogg'


/obj/item/natural/rock/Initialize()
	icon_state = "stonebig[rand(1,2)]"
	..()


/obj/item/natural/rock/Crossed(mob/living/L)
	if(istype(L) && !L.throwing)
		if(L.m_intent == MOVE_INTENT_RUN)
			L.visible_message("<span class='warning'>[L] trips over the rock!</span>","<span class='warning'>I trip over the rock!</span>")
			L.Knockdown(10)
			L.consider_ambush()
	..()

/obj/item/natural/rock/deconstruct(disassembled = FALSE)
	if(!disassembled)
		if(mineralType && mineralAmt)
			new mineralType(src.loc, mineralAmt)
		for(var/i in 1 to rand(1,3))
			var/obj/item/S = new /obj/item/natural/stone(src.loc)
			S.pixel_x = rand(25,-25)
			S.pixel_y = rand(25,-25)
	qdel(src)

/obj/item/natural/rock/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(.) //damage received
		if(damage_amount > 10)
			if(prob(10))
				var/datum/effect_system/spark_spread/S = new()
				var/turf/front = get_turf(src)
				S.set_up(1, 1, front)
				S.start()

/obj/item/natural/rock/attackby(obj/item/W, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(istype(W, /obj/item/natural/stone))
		user.visible_message("<span class='info'>[user] strikes the stone against the rock.</span>")
		playsound(src.loc, 'sound/items/stonestone.ogg', 100)
		if(prob(35))
			var/datum/effect_system/spark_spread/S = new()
			var/turf/front = get_turf(src)
			S.set_up(1, 1, front)
			S.start()
		return
	if(istype(W, /obj/item/natural/rock))
		playsound(src.loc, pick('sound/items/stonestone.ogg'), 100)
		user.visible_message("<span class='info'>[user] strikes the rocks together.</span>")
		if(prob(10))
			var/datum/effect_system/spark_spread/S = new()
			var/turf/front = get_turf(src)
			S.set_up(1, 1, front)
			S.start()
		return
	..()

//begin ore loot rocks
/obj/item/natural/rock/gold
	mineralType = /obj/item/rogueore/gold

/obj/item/natural/rock/iron
	mineralType = /obj/item/rogueore/iron

/obj/item/natural/rock/coal
	mineralType = /obj/item/rogueore/coal

/obj/item/natural/rock/salt
	mineralType = /obj/item/reagent_containers/powder/flour/salt