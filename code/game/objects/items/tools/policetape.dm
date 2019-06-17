//Define all tape types in policetape.dm
/obj/item/tool/taperoll
	name = "tape roll"
	icon = 'icons/obj/policetape.dmi'
	icon_state = "rollstart"
	flags_item = NOBLUDGEON
	w_class = 2.0
	var/turf/start
	var/turf/end
	var/tape_type = /obj/item/tape
	var/icon_base

/obj/item/tape
	name = "tape"
	icon = 'icons/obj/policetape.dmi'
	anchored = TRUE
	var/lifted = 0
	var/crumpled = 0
	var/icon_base

/obj/item/tool/taperoll/police
	name = "police tape"
	desc = "A roll of police tape used to block off crime scenes from the public."
	icon_state = "police_start"
	tape_type = /obj/item/tape/police
	icon_base = "police"

/obj/item/tape/police
	name = "police tape"
	desc = "A length of police tape.  Do not cross."
	req_access = list(ACCESS_MARINE_BRIG)
	icon_base = "police"

/obj/item/tool/taperoll/engineering
	name = "engineering tape"
	desc = "A roll of engineering tape used to block off working areas from the public."
	icon_state = "engineering_start"
	tape_type = /obj/item/tape/engineering
	icon_base = "engineering"

/obj/item/tape/engineering
	name = "engineering tape"
	desc = "A length of engineering tape. Better not cross it."
	req_one_access = list(ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_ENGPREP)
	icon_base = "engineering"

/obj/item/tool/taperoll/attack_self(mob/user as mob)
	if(icon_state == "[icon_base]_start")
		start = get_turf(src)
		to_chat(usr, "<span class='notice'>You place the first end of the [src].</span>")
		icon_state = "[icon_base]_stop"
	else
		icon_state = "[icon_base]_start"
		end = get_turf(src)
		if(start.y != end.y && start.x != end.x || start.z != end.z)
			to_chat(usr, "<span class='notice'>[src] can only be laid horizontally or vertically.</span>")
			return

		var/turf/cur = start
		var/dir
		if (start.x == end.x)
			var/d = end.y-start.y
			if(d) d = d/abs(d)
			end = get_turf(locate(end.x,end.y+d,end.z))
			dir = "v"
		else
			var/d = end.x-start.x
			if(d) d = d/abs(d)
			end = get_turf(locate(end.x+d,end.y,end.z))
			dir = "h"

		var/can_place = 1
		while (cur!=end && can_place)
			if(cur.density == 1)
				can_place = 0
			else if (isspaceturf(cur))
				can_place = 0
			else
				for(var/obj/O in cur)
					if(!istype(O, /obj/item/tape) && O.density)
						can_place = 0
						break
			cur = get_step_towards(cur,end)
		if (!can_place)
			to_chat(usr, "<span class='notice'>You can't run \the [src] through that!</span>")
			return

		cur = start
		var/tapetest = 0
		while (cur!=end)
			for(var/obj/item/tape/Ptest in cur)
				if(Ptest.icon_state == "[Ptest.icon_base]_[dir]")
					tapetest = 1
			if(tapetest != 1)
				var/obj/item/tape/P = new tape_type(cur)
				P.icon_state = "[P.icon_base]_[dir]"
			cur = get_step_towards(cur,end)
	//is_blocked_turf(var/turf/T)
		to_chat(usr, "<span class='notice'> You finish placing the [src].</span>"	)

/obj/item/tool/taperoll/afterattack(var/atom/A, mob/user as mob, proximity)
	if (proximity && istype(A, /obj/machinery/door/airlock))
		var/turf/T = get_turf(A)
		var/obj/item/tape/P = new tape_type(T.x,T.y,T.z)
		P.loc = locate(T.x,T.y,T.z)
		P.icon_state = "[src.icon_base]_door"
		P.layer = WINDOW_LAYER
		to_chat(user, "<span class='notice'>You finish placing the [src].</span>")

/obj/item/tape/proc/crumple()
	if(!crumpled)
		crumpled = 1
		icon_state = "[icon_state]_c"
		name = "crumpled [name]"

/obj/item/tape/Crossed(atom/movable/AM)
	if(!lifted && ismob(AM))
		var/mob/M = AM
		if(!allowed(M))	//only select few learn art of not crumpling the tape
			if(ishuman(M))
				to_chat(M, "<span class='warning'>You are not supposed to go past [src]...</span>")
			crumple()

/obj/item/tape/attackby(obj/item/I, mob/user, params)
	. = ..()
	breaktape(I, user)

/obj/item/tape/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return
	if (user.a_intent == INTENT_HELP && allowed(user))
		user.visible_message("<span class='notice'>[user] lifts [src], allowing passage.</span>")
		crumple()
		lifted = 1
		spawn(200)
			lifted = 0
	else
		breaktape(null, user)

/obj/item/tape/attack_paw(mob/user as mob)
	breaktape(/obj/item/tool/wirecutters,user)

/obj/item/tape/proc/breaktape(obj/item/W as obj, mob/user as mob)
	if(user.a_intent == INTENT_HELP && ((!can_puncture(W) && src.allowed(user))))
		to_chat(user, "You can't break the [src] with that!")
		return
	user.visible_message("<span class='notice'> [user] breaks the [src]!</span>")

	var/dir[2]
	var/icon_dir = src.icon_state
	if(icon_dir == "[src.icon_base]_h")
		dir[1] = EAST
		dir[2] = WEST
	if(icon_dir == "[src.icon_base]_v")
		dir[1] = NORTH
		dir[2] = SOUTH

	for(var/i=1;i<3;i++)
		var/N = 0
		var/turf/cur = get_step(src,dir[i])
		while(N != 1)
			N = 1
			for (var/obj/item/tape/P in cur)
				if(P.icon_state == icon_dir)
					N = 0
					qdel(P)
			cur = get_step(cur,dir[i])

	qdel(src)
	return


