/datum/crafting_recipe/roguetown/gravemarker
	name = "grave marker"
	result = /obj/structure/gravemarker
	reqs = list(/obj/item/grown/log/tree/stick = 1)
	time = 10 SECONDS
	verbage = "tie"
	craftsound = 'sound/foley/Building-01.ogg'
	structurecraft = /obj/structure/closet/dirthole
	craftdiff = 0

/datum/crafting_recipe/roguetown/gravemarker/TurfCheck(mob/user, turf/T)
	if(!(locate(/obj/structure/closet/dirthole) in T))
		to_chat(user, "<span class='warning'>There is no grave here.</span>")
		return FALSE
	for(var/obj/structure/closet/dirthole/D in T)
		if(D.stage != 4)
			to_chat(user, "<span class='warning'>I can't.</span>")
			return FALSE
	if(locate(/obj/structure/gravemarker) in T)
		to_chat(user, "<span class='warning'>This grave is already hallowed.</span>")
		return FALSE
	return TRUE

/obj/structure/gravemarker
	name = "grave marker"
	icon = 'icons/turf/roguefloor.dmi'
	icon_state = "gravemarker1"
	density = FALSE
	max_integrity = 0
	static_debris = list(/obj/item/grown/log/tree/stick = 1)
	anchored = TRUE
	layer = 2.91

/obj/structure/gravemarker/Destroy()
	var/turf/T = get_turf(src)
	if(T)
		new /obj/item/grown/log/tree/stick(T)
	..()

/mob/dead/new_player/proc/reducespawntime(amt)
	if(ckey)
		if(amt)
			if(GLOB.respawntimes[ckey])
				GLOB.respawntimes[ckey] = GLOB.respawntimes[ckey] + amt
				to_chat(src, "<span class='rose'>My soul finds peace buried in creation.</span>")


/obj/structure/gravemarker/OnCrafted(dir)
	icon_state = "gravemarker[rand(1,3)]"
	for(var/obj/structure/closet/dirthole/D in loc)
		bodysearch(D)
		for(var/obj/structure/closet/burial_shroud/B in D)
			bodysearch(B)
	..()

/obj/structure/gravemarker/proc/bodysearch(atom/movable/AM)
	if(!AM)
		return
	for(var/mob/living/L in AM)
		if(L.stat == DEAD)
			if(L.mind && L.mind.has_antag_datum(/datum/antagonist/zombie))
				L.mind.remove_antag_datum(/datum/antagonist/zombie)
			var/mob/dead/observer/O = L.ghostize(force_respawn = TRUE)
			if(O)
				testing("bur1")
				to_chat(O, "<span class='rose'>My soul finds peace buried in creation.</span>")
				O.returntolobby(RESPAWNTIME*-1)
			else
				O = L.get_ghost()
				if(istype(O))
					testing("bur2")
					to_chat(O, "<span class='rose'>My soul finds peace buried in creation.</span>")
					O.returntolobby(RESPAWNTIME*-1)
				else
					testing("bur8")
					testing("[L.mind.key]")
					for(var/mob/dead/new_player/G in GLOB.player_list)
						if(G.mind && L.mind)
							if(G.mind.key == L.mind.key)
								testing("bur3")
								G.reducespawntime(RESPAWNTIME*-1)
	for(var/obj/item/bodypart/head/H in AM)
		if(H.brainmob)
			var/mob/living/brain/B = H.brainmob
			if(B.stat == DEAD)
				var/mob/dead/observer/O = B.ghostize()
				if(O)
					testing("bur4")
					to_chat(O, "<span class='rose'>My soul finds peace buried in creation.</span>")
					O.returntolobby(RESPAWNTIME*-1)
				else
					O = B.get_ghost()
					if(istype(O))
						testing("bur5")
						to_chat(O, "<span class='rose'>My soul finds peace buried in creation.</span>")
						O.returntolobby(RESPAWNTIME*-1)
					else
						testing("bur7")
						testing("[B.mind.key]")
						for(var/mob/dead/new_player/G in GLOB.player_list)
							if(G.mind.key == B.mind.key)
								testing("bur6")
								G.reducespawntime(RESPAWNTIME*-1)