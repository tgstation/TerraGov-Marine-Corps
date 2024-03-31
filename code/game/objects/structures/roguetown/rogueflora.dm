
//newtree

/obj/structure/flora/roguetree
	name = "old tree"
	desc = "An old, wicked tree that not even elves could love."
	icon = 'icons/roguetown/misc/foliagetall.dmi'
	icon_state = "t1"
	opacity = 1
	density = 1
	max_integrity = 200
	blade_dulling = DULLING_CUT
	pixel_x = -16
	layer = 4.81
	plane = GAME_PLANE_UPPER
	attacked_sound = 'sound/misc/woodhit.ogg'
	destroy_sound = 'sound/misc/woodhit.ogg'
	debris = list(/obj/item/grown/log/tree/stick = 2)
	static_debris = list(/obj/item/grown/log/tree = 1)
	alpha = 200
	var/stump_type = /obj/structure/flora/roguetree/stump

/obj/structure/flora/roguetree/attack_right(mob/user)
	if(user.mind && isliving(user))
		if(user.mind.special_items && user.mind.special_items.len)
			var/item = input(user, "What will I take?", "STASH") as null|anything in user.mind.special_items
			if(item)
				if(user.Adjacent(src))
					if(user.mind.special_items[item])
						var/path2item = user.mind.special_items[item]
						user.mind.special_items -= item
						var/obj/item/I = new path2item(user.loc)
						user.put_in_hands(I)
			return

/obj/structure/flora/roguetree/fire_act(added, maxstacks)
	if(added > 5)
		return ..()

/obj/structure/flora/roguetree/Initialize()
	. = ..()

/*
	if(makevines)
		var/turf/target = get_step_multiz(src, UP)
		if(istype(target, /turf/open/transparent/openspace))
			target.ChangeTurf(/turf/open/floor/rogue/shroud)
			var/makecanopy = FALSE
			for(var/D in GLOB.cardinals)
				if(!makecanopy)
					var/turf/NT = get_step(src, D)
					for(var/obj/structure/flora/roguetree/R in NT)
						if(R.makevines)
							makecanopy = TRUE
							break
			if(makecanopy)
				for(var/D in GLOB.cardinals)
					var/turf/NT = get_step(target, D)
					if(NT)
						if(istype(NT, /turf/open/transparent/openspace) || istype(NT, /turf/open/floor/rogue/shroud))
							NT.ChangeTurf(/turf/closed/wall/shroud)
							for(var/X in GLOB.cardinals)
								var/turf/NA = get_step(NT, X)
								if(NA)
									if(istype(NA, /turf/open/transparent/openspace))
										NA.ChangeTurf(/turf/open/floor/rogue/shroud)
*/

	if(istype(loc, /turf/open/floor/rogue/grass))
		var/turf/T = loc
		T.ChangeTurf(/turf/open/floor/rogue/dirt)

/obj/structure/flora/roguetree/obj_destruction(damage_flag)
	if(stump_type)
		new stump_type(loc)
	playsound(src, 'sound/misc/treefall.ogg', 100, FALSE)
	. = ..()


/obj/structure/flora/roguetree/Initialize()
	. = ..()
	icon_state = "t[rand(1,16)]"

/obj/structure/flora/roguetree/evil/Initialize()
	. = ..()
	icon_state = "wv[rand(1,2)]"
	soundloop = new(list(src), FALSE)
	soundloop.start()

/obj/structure/flora/roguetree/evil/Destroy()
	soundloop.stop()
	if(controller)
		controller.endvines()
	controller.tree = null
	controller = null
	. = ..()

/obj/structure/flora/roguetree/evil
	var/datum/looping_sound/boneloop/soundloop
	var/datum/spacevine_controller/controller

/obj/structure/flora/roguetree/wise
	name = "wise tree"
	icon_state = "mystical"

/obj/structure/flora/roguetree/wise/Initialize()
	. = ..()
	icon_state = "mystical"
/*
/obj/structure/flora/roguetree/wise/examine(mob/user)
	. = ..()
	user.play_priomusic('sound/music/tree.ogg', MUSIC_PRIO_DEFAULT)
*/

/obj/structure/flora/roguetree/burnt
	name = "burnt tree"
	desc = ""
	icon = 'icons/roguetown/misc/96x96.dmi'
	icon_state = "t1"
	stump_type = /obj/structure/flora/roguetree/stump/burnt
	pixel_x = -32

/obj/structure/flora/roguetree/burnt/Initialize()
	. = ..()
	icon_state = "t[rand(1,4)]"

/obj/structure/flora/roguetree/stump/burnt
	name = "tree stump"
	icon_state = "st1"
	icon = 'icons/roguetown/misc/96x96.dmi'
	stump_type = null
	pixel_x = -32

/obj/structure/flora/roguetree/stump/burnt/Initialize()
	. = ..()
	icon_state = "st[rand(1,2)]"

/obj/structure/flora/roguetree/underworld
	name = "screaming tree"
	desc = "human faces everywhere."
	icon = 'icons/roguetown/misc/foliagetall.dmi'
	icon_state = "screaming1"
	opacity = 1
	density = 1

/obj/structure/flora/roguetree/underworld/Initialize()
	. = ..()
	icon_state = "screaming[rand(1,3)]"

/obj/structure/flora/roguetree/stump
	name = "tree stump"
	icon_state = "t1stump"
	opacity = 0
	max_integrity = 100
	climbable = TRUE
	climb_time = 0
	layer = TABLE_LAYER
	plane = GAME_PLANE
	blade_dulling = DULLING_PICK
	static_debris = null
	debris = null
	alpha = 255
	pixel_x = -16
	climb_offset = 14
	stump_type = FALSE

/obj/structure/flora/roguetree/stump/Initialize()
	. = ..()
	icon_state = "t[rand(1,4)]stump"

/obj/structure/flora/roguetree/stump/log
	name = "ancient log"
	icon_state = "log1"
	opacity = 0
	max_integrity = 200
	blade_dulling = DULLING_CUT
	static_debris = list(/obj/item/grown/log/tree = 1)
	climb_offset = 14
	stump_type = FALSE

/obj/structure/flora/roguetree/stump/log/Initialize()
	. = ..()
	icon_state = "log[rand(1,2)]"


//newbushes

/obj/structure/flora/roguegrass
	name = "grass"
	desc = ""
	icon = 'icons/roguetown/misc/foliage.dmi'
	icon_state = "grass1"
	attacked_sound = "plantcross"
	destroy_sound = "plantcross"
	max_integrity = 5
	blade_dulling = DULLING_CUT
	debris = list(/obj/item/natural/fibers = 1)


/obj/structure/flora/roguegrass/spark_act()
	fire_act()

/obj/structure/flora/roguegrass/Initialize()
	update_icon()
	AddComponent(/datum/component/roguegrass)
	. = ..()

/obj/structure/flora/roguegrass/update_icon()
	icon_state = "grass[rand(1, 6)]"

/obj/structure/flora/roguegrass/water
	name = "grass"
	icon_state = "swampgrass"
	max_integrity = 5

/obj/structure/flora/roguegrass/water/reeds
	name = "reeds"
	icon_state = "reeds"
	opacity = 1
	max_integrity = 10
	layer = 4.1
	blade_dulling = DULLING_CUT

/obj/structure/flora/roguegrass/water/update_icon()
	dir = pick(GLOB.cardinals)

/datum/component/roguegrass/Initialize()
	RegisterSignal(parent, list(COMSIG_MOVABLE_CROSSED), .proc/Crossed)

/datum/component/roguegrass/proc/Crossed(datum/source, atom/movable/AM)
	var/atom/A = parent

	if(isliving(AM))
		var/mob/living/L = AM
		if(L.m_intent == MOVE_INTENT_SNEAK)
			return
		else
			playsound(A.loc, "plantcross", 100, FALSE, -1)
			var/oldx = A.pixel_x
			animate(A, pixel_x = oldx+1, time = 0.5)
			animate(pixel_x = oldx-1, time = 0.5)
			animate(pixel_x = oldx, time = 0.5)
			L.consider_ambush()
	return


/obj/structure/flora/roguegrass/bush
	name = "bush"
	desc = "A bush, I think I can see some spiders crawling in it."
	icon_state = "bush1"
	layer = ABOVE_ALL_MOB_LAYER
	var/res_replenish
	blade_dulling = DULLING_CUT
	max_integrity = 35
	climbable = FALSE
	dir = SOUTH
	debris = list(/obj/item/natural/fibers = 1, /obj/item/grown/log/tree/stick = 1)
	var/list/looty = list()
	var/bushtype

/obj/structure/flora/roguegrass/bush/Initialize()
	if(prob(88))
		bushtype = pickweight(list(/obj/item/reagent_containers/food/snacks/grown/berries/rogue=5,
					/obj/item/reagent_containers/food/snacks/grown/berries/rogue/poison=3,
					/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweed=1))
	loot_replenish()
	pixel_x += rand(-3,3)
	return ..()

/obj/structure/flora/roguegrass/bush/proc/loot_replenish()
	if(bushtype)
		looty += bushtype
	if(prob(66))
		looty += /obj/item/natural/thorn
	looty += /obj/item/natural/fibers


/obj/structure/flora/roguegrass/bush/Crossed(atom/movable/AM)
	..()
	if(isliving(AM))
		var/mob/living/L = AM
		if(L.m_intent == MOVE_INTENT_RUN && !L.lying)
			if(!ishuman(L))
				to_chat(L, "<span class='warning'>I'm cut on a thorn!</span>")
				L.apply_damage(5, BRUTE)

			else
				var/mob/living/carbon/human/H = L
				if(prob(20))
					if(!HAS_TRAIT(src, TRAIT_PIERCEIMMUNE))
//						H.throw_alert("embeddedobject", /obj/screen/alert/embeddedobject)
						var/obj/item/bodypart/BP = pick(H.bodyparts)
						var/obj/item/natural/thorn/TH = new(src.loc)
						BP.embedded_objects |= TH
						TH.add_mob_blood(H)//it embedded itself in you, of course it's bloody!
						TH.forceMove(H)
						BP.receive_damage(10)
						to_chat(H, "<span class='danger'>\A [TH] impales my [BP.name]!</span>")
						SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "embedded", /datum/mood_event/embedded)
				else
					var/obj/item/bodypart/BP = pick(H.bodyparts)
					to_chat(H, "<span class='warning'>A thorn [pick("slices","cuts","nicks")] my [BP.name].</span>")
					BP.receive_damage(10)

/obj/structure/flora/roguegrass/bush/attack_hand(mob/user)
	if(isliving(user))
		var/mob/living/L = user
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(src.loc, "plantcross", 50, FALSE, -1)
		if(do_after(L, rand(1,5), target = src))
#ifndef MATURESERVER
			if(!looty.len && (world.time > res_replenish))
				loot_replenish()
#endif
			if(prob(50) && looty.len)
				if(looty.len == 1)
					res_replenish = world.time + 8 MINUTES
				var/obj/item/B = pick_n_take(looty)
				if(B)
					B = new B(user.loc)
					user.put_in_hands(B)
					user.visible_message("<span class='notice'>[user] finds [B] in [src].</span>")
					return
			user.visible_message("<span class='warning'>[user] searches through [src].</span>")
#ifdef MATURESERVER
			if(!looty.len)
				to_chat(user, "<span class='warning'>Picked clean.</span>")
#else
			if(!looty.len)
				to_chat(user, "<span class='warning'>Picked clean... I should try later.</span>")
#endif
/obj/structure/flora/roguegrass/bush/update_icon()
	icon_state = "bush[rand(1, 4)]"

/obj/structure/flora/roguegrass/bush/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSGRILLE))
		return 1
	if(get_dir(loc, target) == dir)
		return 0
	return 1

/obj/structure/flora/roguegrass/bush/CheckExit(atom/movable/mover as mob|obj, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSGRILLE))
		return 1
	if(get_dir(mover.loc, target) == dir)
		return 0
	return 1

/obj/structure/flora/roguegrass/bush/wall
	name = "great bush"
	desc = "A bush, this one's roots are thick and block the way."
	opacity = TRUE
	density = 1
	climbable = FALSE
	icon_state = "bushwall1"
	max_integrity = 150
	debris = list(/obj/item/natural/fibers = 1, /obj/item/grown/log/tree/stick = 1, /obj/item/natural/thorn = 1)
	attacked_sound = 'sound/misc/woodhit.ogg'

/obj/structure/flora/roguegrass/bush/wall/Initialize()
	..()
	icon_state = "bushwall[pick(1,2)]"

/obj/structure/flora/roguegrass/bush/wall/update_icon()
	return

/obj/structure/flora/roguegrass/bush/wall/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSGRILLE))
		return 1
	return 0

/obj/structure/flora/roguegrass/bush/wall/CheckExit(atom/movable/O, turf/target)
	if(istype(O) && (O.pass_flags & PASSGRILLE))
		return 1
	return 0

/obj/structure/flora/roguegrass/bush/wall/tall
	icon = 'icons/roguetown/misc/foliagetall.dmi'
	icon_state = "tallbush1"
	opacity = 1
	pixel_x = -16
	debris = null
	static_debris = null

/obj/structure/flora/roguegrass/bush/wall/tall/Initialize()
	..()
	icon_state = "tallbush[pick(1,2)]"


/obj/structure/flora/rogueshroom
	name = "shroom"
	desc = ""
	icon = 'icons/roguetown/misc/foliagetall.dmi'
	icon_state = "mush1"
	opacity = 0
	density = 0
	max_integrity = 120
	blade_dulling = DULLING_CUT
	pixel_x = -16
	layer = 4.81
	attacked_sound = 'sound/misc/woodhit.ogg'
	destroy_sound = 'sound/misc/woodhit.ogg'
	static_debris = list( /obj/item/grown/log/tree/small = 1)
	dir = SOUTH

/obj/structure/flora/rogueshroom/attack_right(mob/user)
	if(user.mind && isliving(user))
		if(user.mind.special_items && user.mind.special_items.len)
			var/item = input(user, "What will I take?", "STASH") as null|anything in user.mind.special_items
			if(item)
				if(user.Adjacent(src))
					if(user.mind.special_items[item])
						var/path2item = user.mind.special_items[item]
						user.mind.special_items -= item
						var/obj/item/I = new path2item(user.loc)
						user.put_in_hands(I)
			return


/obj/structure/flora/rogueshroom/Initialize()
	..()
	icon_state = "mush[rand(1,5)]"
	if(icon_state == "mush5")
		static_debris = list(/obj/item/natural/thorn=1, /obj/item/grown/log/tree/small = 1)
	pixel_x += rand(8,-8)

/obj/structure/flora/rogueshroom/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSGRILLE))
		return 1
	if(get_dir(loc, target) == dir)
		return 0
	return 1

/obj/structure/flora/rogueshroom/CheckExit(atom/movable/mover as mob|obj, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSGRILLE))
		return 1
	if(get_dir(mover.loc, target) == dir)
		return 0
	return 1

/obj/structure/flora/rogueshroom/fire_act(added, maxstacks)
	if(added > 5)
		return ..()

/obj/structure/flora/rogueshroom/obj_destruction(damage_flag)
	var/obj/structure/S = new /obj/structure/flora/shroomstump(loc)
	S.icon_state = "[icon_state]stump"
	. = ..()


/obj/structure/flora/shroomstump
	name = "shroom stump"
	icon_state = "mush1stump"
	opacity = 0
	max_integrity = 100
	climbable = TRUE
	climb_time = 0
	density = TRUE
	icon = 'icons/roguetown/misc/foliagetall.dmi'
	layer = TABLE_LAYER
	blade_dulling = DULLING_PICK
	static_debris = null
	debris = null
	alpha = 255
	pixel_x = -16
	climb_offset = 14

/obj/structure/flora/shroomstump/Initialize()
	. = ..()
	icon_state = "t[rand(1,4)]stump"

/obj/structure/roguerock
	name = "rock"
	icon_state = "rock1"
	icon = 'icons/roguetown/misc/foliage.dmi'
	opacity = 0
	max_integrity = 50
	climbable = TRUE
	climb_time = 30
	density = TRUE
	layer = TABLE_LAYER
	blade_dulling = DULLING_BASH
	static_debris = null
	debris = null
	alpha = 255
	climb_offset = 14
	destroy_sound = 'sound/foley/smash_rock.ogg'
	attacked_sound = 'sound/foley/hit_rock.ogg'
	static_debris = list(/obj/item/natural/stone = 1)

/obj/structure/roguerock/Initialize()
	. = ..()
	icon_state = "rock[rand(1,4)]"

//Thorn bush

/obj/structure/flora/roguegrass/thorn_bush
    name = "thorn bush"
    desc = "A thorny bush, watch your step!"
    icon_state = "thornbush"
    layer = ABOVE_ALL_MOB_LAYER
    blade_dulling = DULLING_CUT
    max_integrity = 35
    climbable = FALSE
    dir = SOUTH
    debris = list(/obj/item/natural/thorn = 3, /obj/item/grown/log/tree/stick = 1)
//WIP