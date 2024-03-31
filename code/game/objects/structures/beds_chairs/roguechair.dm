/obj/structure/chair/bench
	name = "bench"
	icon_state = "bench"
	icon = 'icons/roguetown/misc/structure.dmi'
	buildstackamount = 1
	item_chair = null
	destroy_sound = 'sound/combat/hits/onwood/destroyfurniture.ogg'
	attacked_sound = "woodimpact"
	sleepy = 0.5
//	pixel_y = 10
	layer = OBJ_LAYER

/obj/structure/chair/bench/church
	icon_state = "church_benchleft"

/obj/structure/chair/bench/church/mid
	icon_state = "church_benchmid"

/obj/structure/chair/bench/church/r
	icon_state = "church_benchright"

/obj/structure/chair/bench/Initialize()
	. = ..()
	handle_layer()

/obj/structure/chair/bench/handle_layer()
	if(dir == NORTH)
		layer = ABOVE_MOB_LAYER
		plane = GAME_PLANE_UPPER
	else
		layer = OBJ_LAYER
		plane = GAME_PLANE

/obj/structure/chair/bench/post_buckle_mob(mob/living/M)
	..()
	density = TRUE
//	M.pixel_y = 10

/obj/structure/chair/bench/post_unbuckle_mob(mob/living/M)
	..()
	density = FALSE
//	M.pixel_x = M.get_standard_pixel_x_offset(M.lying)
//	M.pixel_y = M.get_standard_pixel_y_offset(M.lying)


/obj/structure/chair/bench/CanPass(atom/movable/mover, turf/target)
	if(get_dir(mover,loc) == dir)
		return 0
	return !density

/obj/structure/chair/bench/CheckExit(atom/movable/O, turf/target)
	if(get_dir(target, O.loc) == dir)
		return 0
	return !density

/obj/structure/chair/bench/couch
	icon_state = "redcouch"

/obj/structure/chair/bench/church/smallbench
	icon_state = "benchsmall"

/obj/structure/chair/bench/couch/r
	icon_state = "redcouch2"

/obj/structure/chair/bench/ultimacouch
	icon_state = "ultimacouchleft"

/obj/structure/chair/bench/ultimacouch/r
	icon_state = "ultimacouchright"

/obj/structure/chair/bench/coucha
	icon_state = "couchaleft"

/obj/structure/chair/bench/coucha/r
	icon_state = "coucharight"

/obj/structure/chair/bench/couchablack
	icon_state = "couchablackaleft"

/obj/structure/chair/bench/couchablack/r
	icon_state = "couchablackaright"


/obj/structure/chair/bench/couch/Initialize()
	..()
	if(GLOB.lordprimary)
		lordcolor(GLOB.lordprimary,GLOB.lordsecondary)
	else
		GLOB.lordcolor += src

/obj/structure/chair/bench/couch/Destroy()
	GLOB.lordcolor -= src
	return ..()

/obj/structure/chair/bench/couch/lordcolor(primary,secondary)
	if(!primary || !secondary)
		return
	var/mutable_appearance/M = mutable_appearance(icon, "[icon_state]_primary", -(layer+0.1))
	M.color = secondary //looks better
	add_overlay(M)
	GLOB.lordcolor -= src

/obj/structure/chair/wood/rogue
	icon_state = "chair2"
	icon = 'icons/roguetown/misc/structure.dmi'
	item_chair = /obj/item/chair/rogue
	blade_dulling = DULLING_BASHCHOP
	destroy_sound = 'sound/combat/hits/onwood/destroyfurniture.ogg'
	attacked_sound = "woodimpact"

/obj/structure/chair/wood/rogue/chair3
	icon_state = "chair3"
	icon = 'icons/roguetown/misc/structure.dmi'
	item_chair = /obj/item/chair/rogue
	blade_dulling = DULLING_BASHCHOP
	destroy_sound = 'sound/combat/hits/onwood/destroyfurniture.ogg'
	attacked_sound = "woodimpact"

/obj/structure/chair/wood/rogue/throne
	icon_state = "thronechair"
	icon = 'icons/roguetown/misc/structure.dmi'
	blade_dulling = DULLING_BASHCHOP
	destroy_sound = 'sound/combat/hits/onwood/destroyfurniture.ogg'
	attacked_sound = "woodimpact"

/obj/item/chair/rogue/
	name = "chair"
	icon = 'icons/roguetown/items/chairs.dmi'
	icon_state = "chair2"
	origin_type = /obj/structure/chair/wood/rogue
	blade_dulling = DULLING_BASHCHOP
	can_parry = TRUE
	gripped_intents = list(/datum/intent/hit)
	obj_flags = CAN_BE_HIT
	max_integrity = 100
	destroy_sound = 'sound/combat/hits/onwood/destroyfurniture.ogg'
	attacked_sound = "woodimpact"
	sleepy = 0.1

/obj/item/chair/rogue/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("wieldedl")
				return list("shrink" = 0.7,"sx" = 2,"sy" = 1,"nx" = -17,"ny" = 0,"wx" = -11,"wy" = 0,"ex" = 2,"ey" = 0,"westabove" = 1,"eastbehind" = 0,"nturn" = 9,"sturn" = -42,"wturn" = 21,"eturn" = -27,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0)
			if("wielded")
				return list("shrink" = 0.7,"sx" = 2,"sy" = 1,"nx" = -17,"ny" = 0,"wx" = -11,"wy" = 0,"ex" = 2,"ey" = 0,"westabove" = 1,"eastbehind" = 0,"nturn" = 9,"sturn" = -42,"wturn" = 21,"eturn" = -27,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,)
	..()

/obj/structure/chair/wood/rogue/CanPass(atom/movable/mover, turf/target)
	if(isliving(mover))
		var/mob/living/M = mover
		if((M.mobility_flags & MOBILITY_STAND))
			if(isturf(loc))
				var/movefrom = get_dir(M.loc, loc)
				if(movefrom == dir && item_chair != null)
					playsound(loc, 'sound/foley/chairfall.ogg', 100, FALSE)
					var/obj/item/I = new item_chair(loc)
					item_chair = null
					I.dir = dir
					qdel(src)
					return FALSE
	return ..()


/obj/structure/chair/wood/rogue/onkick(mob/user)
	if(!user)
		return
	if(isturf(loc))
		playsound(loc, 'sound/foley/chairfall.ogg', 100, FALSE)
		var/obj/item/I = new item_chair(loc)
		item_chair = null
		I.dir = dir
		qdel(src)
		return FALSE

/obj/structure/chair/wood/rogue/CheckExit(atom/movable/O, turf/target)
	if(isliving(O))
		var/mob/living/M = O
		if((M.mobility_flags & MOBILITY_STAND))
			if(isturf(loc))
				var/movefrom = get_dir(M.loc, target)
				if(movefrom == turn(dir, 180) && item_chair != null)
					playsound(loc, 'sound/foley/chairfall.ogg', 100, FALSE)
					var/obj/item/I = new item_chair(loc)
					item_chair = null
					I.dir = dir
					qdel(src)
					return FALSE
	return ..()

/obj/structure/chair/wood/rogue/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	if(damage_amount > 5 && item_chair != null)
		playsound(loc, 'sound/foley/chairfall.ogg', 100, FALSE)
		var/obj/item/I = new item_chair(loc)
		item_chair = null
		I.dir = dir
		qdel(src)
		return FALSE
	else
		..()


/obj/structure/chair/wood/rogue/fancy
	icon_state = "chair1"
	item_chair = /obj/item/chair/rogue/fancy

/obj/item/chair/rogue/fancy
	icon_state = "chair1"
	origin_type = /obj/structure/chair/wood/rogue/fancy

/obj/structure/chair/wood/rogue/attack_right(mob/user)
	var/datum/component/simple_rotation/rotcomp = GetComponent(/datum/component/simple_rotation)
	if(rotcomp)
		rotcomp.HandRot(rotcomp,user,ROTATION_CLOCKWISE)

/obj/structure/chair/wood/rogue
//	pixel_y = 5

/obj/structure/chair/wood/rogue/post_buckle_mob(mob/living/M)
	..()
	density = TRUE
//	M.set_mob_offsets("bed_buckle", _x = 0, _y = 5)

/obj/structure/chair/wood/rogue/post_unbuckle_mob(mob/living/M)
	..()
	density = FALSE
//	M.reset_offsets("bed_buckle")


/obj/structure/chair/stool/rogue
	name = "stool"
	desc = ""
	icon_state = "barstool"
	icon = 'icons/roguetown/misc/structure.dmi'
	item_chair = /obj/item/chair/stool/bar/rogue
	max_integrity = 100
	blade_dulling = DULLING_BASHCHOP
	destroy_sound = 'sound/combat/hits/onwood/destroyfurniture.ogg'
	attacked_sound = "woodimpact"

/obj/item/chair/stool/bar/rogue
	name = "stool"
	icon_state = "baritem"
	icon = 'icons/roguetown/misc/structure.dmi'
	origin_type = /obj/structure/chair/stool/rogue
	blade_dulling = DULLING_BASHCHOP
	can_parry = TRUE
	gripped_intents = list(/datum/intent/hit)
	obj_flags = CAN_BE_HIT
	max_integrity = 100
	destroy_sound = 'sound/combat/hits/onwood/destroyfurniture.ogg'
	attacked_sound = "woodimpact"

/obj/item/chair/stool/bar/rogue/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("wieldedl")
				return list("shrink" = 0.8,"sx" = 3,"sy" = -8,"nx" = -19,"ny" = -6,"wx" = -13,"wy" = -7,"ex" = 1,"ey" = -5,"westabove" = 1,"eastbehind" = 0,"nturn" = 30,"sturn" = -18,"wturn" = 30,"eturn" = -24,"nflip" = 8,"sflip" = 0,"wflip" = 8,"eflip" = 0)
			if("wielded")
				return list("shrink" = 0.8,"sx" = -20,"sy" = -6,"nx" = 0,"ny" = -7,"wx" = -18,"wy" = -5,"ex" = -4,"ey" = -8,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = -42,"sturn" = 33,"wturn" = 33,"eturn" = -21,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)

/obj/structure/bed/rogue
	icon_state = "bed"
	icon = 'icons/roguetown/misc/structure.dmi'
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = 90
	pixel_y = 5
	sleepy = 3
	debris = list(/obj/item/grown/log/tree/small = 1)

/obj/structure/bed/rogue/shit
	icon_state = "shitbed"
	sleepy = 1

/obj/structure/bed/rogue/post_buckle_mob(mob/living/M)
	..()
	M.set_mob_offsets("bed_buckle", _x = 0, _y = 5)

/obj/structure/bed/rogue/post_unbuckle_mob(mob/living/M)
	..()
	M.reset_offsets("bed_buckle")

/obj/structure/bed/rogue/inn
	icon_state = "inn_bed"
	icon = 'icons/roguetown/misc/structure.dmi'
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = 90
	pixel_y = 5
	sleepy = 3
	debris = list(/obj/item/grown/log/tree/small = 1)

/obj/structure/bed/rogue/inn/wooldouble
	icon_state = "double_wool"
	icon = 'icons/roguetown/misc/structure.dmi'
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = 90
	pixel_y = 0
	sleepy = 3
	debris = list(/obj/item/grown/log/tree/small = 2)

/obj/structure/bed/rogue/inn/double
	icon_state = "double"
	icon = 'icons/roguetown/misc/structure.dmi'
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = 90
	pixel_y = 0
	sleepy = 3
	debris = list(/obj/item/grown/log/tree/small = 2)
/*            ///////WIP  This will essentially allow for multiple mobs to buckle, just needs to change mousedrop function
/obj/structure/bed/rogue/inn/double
	var/list/buckled_mobs = list()

/obj/structure/bed/rogue/inn/double/post_buckle_mob(mob/living/M)
	. = ..()
	if(!buckled_mobs)
		buckled_mobs = list()
	buckled_mobs += M
	M.set_mob_offsets("bed_buckle", _x = buckled_mobs.len * 10, _y = 5)

/obj/structure/bed/rogue/inn/double/post_unbuckle_mob(mob/living/M)
	. = ..()
	if(M in buckled_mobs)
		buckled_mobs -= M
	M.reset_offsets("bed_buckle")

	var/x_offset = 0
	for(var/mob/living/buckled_mob in buckled_mobs)
		buckled_mob.set_mob_offsets("bed_buckle", _x = x_offset, _y = 5)
		x_offset += 10
*/
/obj/structure/bed/rogue/inn/hay
	icon_state = "haybed"
	icon = 'icons/roguetown/misc/structure.dmi'
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = 90
	pixel_y = 5
	sleepy = 3
	debris = list(/obj/item/grown/log/tree/small = 1)

/obj/structure/bed/rogue/inn/wool
	icon_state = "woolbed"
	icon = 'icons/roguetown/misc/structure.dmi'
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = 90
	pixel_y = 5
	sleepy = 3
	debris = list(/obj/item/grown/log/tree/small = 1)

/obj/structure/bed/rogue/inn/pileofshit
	icon_state = "shitbed2"
	icon = 'icons/roguetown/misc/structure.dmi'
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = 90
	pixel_y = 5
	sleepy = 3