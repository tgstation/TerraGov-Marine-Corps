/obj/structure/flora/newtree
	name = "tree"
	desc = "The thick core of a tree."
	icon = 'icons/roguetown/misc/tree.dmi'
	icon_state = "tree1"
	var/tree_type = 1
	var/base_state
	blade_dulling = DULLING_CUT
	opacity = 1
	density = 1
	attacked_sound = 'sound/misc/woodhit.ogg'
	destroy_sound = 'sound/misc/woodhit.ogg'
	climbable = FALSE
	static_debris = list(/obj/item/grown/log/tree = 1)
	obj_flags = CAN_BE_HIT | BLOCK_Z_IN_UP | BLOCK_Z_OUT_DOWN

/obj/structure/flora/newtree/attack_right(mob/user)
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

/obj/structure/flora/newtree/obj_destruction(damage_flag)
	var/turf/NT = get_turf(src)
	if(!istype(NT, /turf/open/transparent/openspace))
		new /obj/structure/flora/roguetree/stump(NT)
	playsound(src, 'sound/misc/treefall.ogg', 100, FALSE)
	. = ..()

/obj/structure/flora/newtree/attack_hand(mob/user)
	if(isliving(user))
		var/mob/living/L = user
		if(L.stat != CONSCIOUS)
			return
		var/turf/target = get_step_multiz(user, UP)
		if(!istype(target, /turf/open/transparent/openspace))
			to_chat(user, "<span class='warning'>I can't climb here.</span>")
			return
		if(!L.can_zTravel(target, UP))
			to_chat(user, "<span class='warning'>I can't climb there.</span>")
			return
		var/used_time = 0
		if(L.mind)
			var/myskill = L.mind.get_skill_level(/datum/skill/misc/climbing)
			var/obj/structure/table/TA = locate() in L.loc
			if(TA)
				myskill += 1
			else
				var/obj/structure/chair/CH = locate() in L.loc
				if(CH)
					myskill += 1
			used_time = max(70 - (myskill * 10) - (L.STASPD * 3), 30)
		playsound(user, 'sound/foley/climb.ogg', 100, TRUE)
		user.visible_message("<span class='warning'>[user] starts to climb [src].</span>", "<span class='warning'>I start to climb [src]...</span>")
		if(do_after(L, used_time, target = src))
			var/pulling = user.pulling
			if(ismob(pulling))
				user.pulling.forceMove(target)
			user.forceMove(target)
			user.start_pulling(pulling,supress_message = TRUE)
			playsound(user, 'sound/foley/climb.ogg', 100, TRUE)

/obj/structure/flora/newtree/update_icon()
	icon_state = ""
	cut_overlays()
	var/mutable_appearance/M
	if(base_state)
		M = mutable_appearance(icon, "[base_state]")
		add_overlay(M)
	M = mutable_appearance(icon, "tree[tree_type]")
	M.dir = dir
	add_overlay(M)

/obj/structure/flora/newtree/Initialize()
	. = ..()
	tree_type = rand(1,2)
	dir = pick(GLOB.cardinals)
	SStreesetup.initialize_me |= src
	build_trees()
	update_icon()
	if(istype(loc, /turf/open/floor/rogue/grass))
		var/turf/T = loc
		T.ChangeTurf(/turf/open/floor/rogue/dirt)

/obj/structure/flora/newtree/proc/build_trees()
	var/turf/target = get_step_multiz(src, UP)
	if(istype(target, /turf/open/transparent/openspace))
		var/obj/structure/flora/newtree/T = new(target)
		T.base_state = "center-leaf[rand(1,2)]"
		T.update_icon()

/obj/structure/flora/newtree/proc/build_branches()
	for(var/D in GLOB.cardinals)
		var/turf/NT = get_step(src, D)
		if(istype(NT, /turf/open/transparent/openspace))
			var/turf/NB = get_step(NT, D)
			if(istype(NB, /turf/open/transparent/openspace) && prob(50))//make an ending branch
				if(prob(50))
					if(!locate(/obj/structure) in NB)
						var/obj/structure/flora/newbranch/T = new(NB)
						T.dir = D
					if(!locate(/obj/structure) in NT)
						var/obj/structure/flora/newbranch/connector/TC = new(NT)
						TC.dir = D
				else
					if(!locate(/obj/structure) in NB)
						new /obj/structure/flora/newleaf(NB)
					if(!locate(/obj/structure) in NT)
						var/obj/structure/flora/newbranch/TC = new(NT)
						TC.dir = D
			else
				if(!locate(/obj/structure) in NT)
					var/obj/structure/flora/newbranch/TC = new(NT)
					TC.dir = D
		else
			if(prob(70))
				if(isopenturf(NT))
					if(!istype(loc, /turf/open/transparent/openspace)) //must be lowest
						if(!locate(/obj/structure) in NT)
							var/obj/structure/flora/newbranch/leafless/T = new(NT)
							T.dir = D


/obj/structure/flora/newtree/proc/build_leafs()
	for(var/D in GLOB.diagonals)
		var/turf/NT = get_step(src, D)
		if(istype(NT, /turf/open/transparent/openspace))
			if(!locate(/obj/structure) in NT)
				var/obj/structure/flora/newleaf/corner/T = new(NT)
				T.dir = D


///BRANCHES

/obj/structure/flora/newbranch
	name = "branch"
	desc = "A stable branch, should be safe to walk on."
	icon = 'icons/roguetown/misc/tree.dmi'
	icon_state = "branch-end1"
//	var/tree_type = 1
	var/base_state = TRUE
	obj_flags = CAN_BE_HIT | BLOCK_Z_OUT_DOWN
	static_debris = list(/obj/item/grown/log/tree/stick = 1)
	density = FALSE
	max_integrity = 30

/obj/structure/flora/newbranch/update_icon()
	icon_state = ""
	cut_overlays()
	var/mutable_appearance/M
	if(base_state)
		M = mutable_appearance(icon, "[base_state]")
		M.dir = pick(GLOB.cardinals)
		add_overlay(M)
	M = mutable_appearance(icon, "branch-end[rand(1,2)]")
	M.dir = dir
	add_overlay(M)

/obj/structure/flora/newbranch/Initialize()
	. = ..()
	if(base_state)
		AddComponent(/datum/component/squeak, list('sound/foley/plantcross1.ogg','sound/foley/plantcross2.ogg','sound/foley/plantcross3.ogg','sound/foley/plantcross4.ogg'), 100)
		base_state = "center-leaf[rand(1,2)]"
	update_icon()

/obj/structure/flora/newbranch/connector
	icon_state = "branch-extend"

/obj/structure/flora/newbranch/connector/update_icon()
	icon_state = ""
	cut_overlays()
	var/mutable_appearance/M
	if(base_state)
		M = mutable_appearance(icon, "[base_state]")
		M.dir = pick(GLOB.cardinals)
		add_overlay(M)
	M = mutable_appearance(icon, "branch-extend")
	M.dir = dir
	add_overlay(M)

/obj/structure/flora/newbranch/leafless
	base_state = FALSE

/obj/structure/flora/newbranch/leafless/update_icon()
	icon_state = ""
	cut_overlays()
	var/mutable_appearance/M = mutable_appearance(icon, "branch-end[rand(1,2)]")
	M.dir = dir
	add_overlay(M)

/// LEAF


/obj/structure/flora/newleaf/corner
	icon = 'icons/roguetown/misc/tree.dmi'
	icon_state = "corner-leaf1"


/obj/structure/flora/newleaf/corner/Initialize()
	. = ..()
	icon_state = "corner-leaf[rand(1,2)]"
	update_icon()

/obj/structure/flora/newleaf
	name = "leaves"
	icon = 'icons/roguetown/misc/tree.dmi'
	icon_state = "center-leaf1"
	density = FALSE
	max_integrity = 10

/obj/structure/flora/newleaf/Initialize()
	. = ..()
	icon_state = "center-leaf[rand(1,2)]"
	update_icon()