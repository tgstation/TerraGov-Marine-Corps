
/obj/structure/fluff/testportal
	name = "portal"
	icon_state = "shitportal"
	icon = 'icons/roguetown/misc/structure.dmi'
	density = FALSE
	anchored = TRUE
	layer = BELOW_MOB_LAYER
	max_integrity = 0
	var/aportalloc = "a"

/obj/structure/fluff/testportal/Initialize()
	name = aportalloc
	..()

/obj/structure/fluff/testportal/attack_hand(mob/user)
	var/fou
	for(var/obj/structure/fluff/testportal/T in shuffle(GLOB.testportals))
		if(T.aportalloc == aportalloc)
			if(T == src)
				continue
			to_chat(user, "<b>I teleport to [T].</b>")
			playsound(src, 'sound/misc/portal_enter.ogg', 100, TRUE)
			user.forceMove(T.loc)
			fou = TRUE
			break
	if(!fou)
		to_chat(user, "<b>There is no portal connected to this. Report it as a bugs.</b>")
	. = ..()


/obj/structure/fluff/traveltile
	name = "travel"
	icon_state = "travel"
	icon = 'icons/turf/roguefloor.dmi'
	density = FALSE
	anchored = TRUE
	layer = ABOVE_OPEN_TURF_LAYER
	max_integrity = 0
	var/aportalid = "REPLACETHIS"
	var/aportalgoesto = "REPLACETHIS"
	var/aallmig

/obj/structure/fluff/traveltile/Initialize()
	GLOB.traveltiles += src
	. = ..()

/obj/structure/fluff/traveltile/Destroy()
	GLOB.traveltiles -= src
	. = ..()

/obj/structure/fluff/traveltile/attack_ghost(mob/dead/observer/user)
	if(user.Adjacent(src))
		if(!aportalgoesto)
			return
		var/fou
		for(var/obj/structure/fluff/traveltile/T in shuffle(GLOB.traveltiles))
			if(T.aportalid == aportalgoesto)
				if(T == src)
					continue
				user.forceMove(T.loc)
				fou = TRUE
				break
		if(!fou)
			to_chat(user, "<b>It is a dead end.</b>")


/obj/structure/fluff/traveltile/attack_hand(mob/user)
	var/fou
	if(!aportalgoesto)
		return
	for(var/obj/structure/fluff/traveltile/T in shuffle(GLOB.traveltiles))
		if(T.aportalid == aportalgoesto)
			if(T == src)
				continue
			if(!can_go(user))
				return
			if(user.pulledby)
				return
			to_chat(user, "<b>I begin to travel...</b>")
			if(do_after(user, 50, target = src))
				var/mob/living/L = user
				var/atom/movable/pullingg = L.pulling
				L.recent_travel = world.time
				if(pullingg)
					pullingg.forceMove(T.loc)
					pullingg.recent_travel = world.time
				L.forceMove(T.loc)
				if(pullingg)
					L.start_pulling(pullingg, supress_message = TRUE)
			fou = TRUE
			break
	if(!fou)
		to_chat(user, "<b>It is a dead end.</b>")
	. = ..()

/obj/structure/fluff/traveltile/proc/can_go(atom/movable/AM)
	if(AM.recent_travel)
		if(world.time < AM.recent_travel + 15 SECONDS)
			return FALSE
	return TRUE

/atom/movable
	var/recent_travel = 0

/obj/structure/fluff/traveltile/Crossed(atom/movable/AM)
	. = ..()
	var/fou
	if(!aportalgoesto)
		return
	if(!isliving(AM))
		return
	for(var/obj/structure/fluff/traveltile/T in shuffle(GLOB.traveltiles))
		if(T.aportalid == aportalgoesto)
			if(T == src)
				continue
			if(!can_go(AM))
				return
			if(AM.pulledby)
				return
			to_chat(AM, "<b>I begin to travel...</b>")
			if(do_after(AM, 50, target = src))
				if(!can_go(AM))
					return
				var/mob/living/L = AM
				var/atom/movable/pullingg = L.pulling
				L.recent_travel = world.time
				if(pullingg)
					pullingg.forceMove(T.loc)
					pullingg.recent_travel = world.time
				L.forceMove(T.loc)
				if(pullingg)
					L.start_pulling(pullingg, supress_message = TRUE)
			fou = TRUE
			break
	if(!fou)
		to_chat(AM, "<b>It is a dead end.</b>")

/obj/structure/fluff/traveltile/bandit/can_go(mob/user)
	. = ..()
	if(.)
		var/mob/living/L = user
		if(HAS_TRAIT(L, TRAIT_BANDITCAMP))
			for(var/mob/living/carbon/human/H in hearers(6,src))
				if(!HAS_TRAIT(H, TRAIT_BANDITCAMP))
					to_chat(user, "<b>I discover the entrance to the strange mansion</b>")
					ADD_TRAIT(H, TRAIT_BANDITCAMP, TRAIT_GENERIC)
			return TRUE
		else
			to_chat(user, "<b>It is a dead end.</b>")
			return FALSE

/obj/structure/fluff/traveltile/vampire/can_go(mob/user)
	. = ..()
	if(.)
		var/mob/living/L = user
		if(HAS_TRAIT(L, TRAIT_VAMPMANSION))
			for(var/mob/living/carbon/human/H in hearers(6,src))
				if(!HAS_TRAIT(H, TRAIT_VAMPMANSION))
					to_chat(user, "<b>I discover the entrance to the vampire mansion.</b>")
					ADD_TRAIT(H, TRAIT_VAMPMANSION, TRAIT_GENERIC)
			return TRUE
		else
			to_chat(user, "<b>It is a dead end.</b>")
			return FALSE
