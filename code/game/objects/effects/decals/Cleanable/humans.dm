#define DRYING_TIME 5 * 60*10                        //for 1 unit of depth in puddle (amount var)

/obj/effect/decal/cleanable/blood
	name = "blood"
	desc = "It's thick and gooey. Perhaps it's the chef's cooking?"
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/effects/blood.dmi'
	icon_state = "mfloor1"
	random_icon_states = list("mfloor1", "mfloor2", "mfloor3", "mfloor4", "mfloor5", "mfloor6", "mfloor7")
	var/base_icon = 'icons/effects/blood.dmi'
	var/basecolor="#ff3b00" // Color when wet.
	var/amount = 5
	var/drying_timer


/obj/effect/decal/cleanable/blood/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
	)
	AddElement(/datum/element/connect_loc, connections)
	update_icon()
	if(istype(src, /obj/effect/decal/cleanable/blood/gibs))
		return
	if(istype(src, /obj/effect/decal/cleanable/blood/tracks))
		return // We handle our own drying.
	if(isturf(loc))
		for(var/obj/effect/decal/cleanable/blood/B in loc)
			if(B == src)
				continue
			return INITIALIZE_HINT_QDEL
	return INITIALIZE_HINT_LATELOAD

/obj/effect/decal/cleanable/blood/LateInitialize()
	. = ..()
	if(QDELETED(src))
		CRASH("[type] already deleted on LateInitialize. Loc: ([x], [y], [z])")
	drying_timer = addtimer(CALLBACK(src, PROC_REF(dry)), DRYING_TIME * (amount + 1), TIMER_STOPPABLE)


/obj/effect/decal/cleanable/blood/Destroy()
	if(drying_timer)
		deltimer(drying_timer)
	return ..()


/obj/effect/decal/cleanable/blood/update_icon()
	if(basecolor == "rainbow") basecolor = "#[pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))]"
	color = basecolor

/obj/effect/decal/cleanable/blood/proc/on_cross(datum/source, mob/living/carbon/human/perp, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(!istype(perp))
		return
	if(amount < 1)
		return
	if(CHECK_MULTIPLE_BITFIELDS(perp.pass_flags, HOVERING))
		return

	var/datum/limb/foot/l_foot = perp.get_limb("l_foot")
	var/datum/limb/foot/r_foot = perp.get_limb("r_foot")
	var/hasfeet = 1
	if((!l_foot || l_foot.limb_status & LIMB_DESTROYED) && (!r_foot || r_foot.limb_status & LIMB_DESTROYED))
		hasfeet = 0
	if(perp.shoes && !perp.buckled)//Adding blood to shoes
		var/obj/item/clothing/shoes/S = perp.shoes
		if(istype(S))
			S.add_blood(basecolor)
			S.track_blood = max(amount,S.track_blood)

	else if (hasfeet)//Or feet
		perp.feet_blood_color = basecolor
		perp.track_blood = max(amount,perp.track_blood)
	else if (perp.buckled && istype(perp.buckled, /obj/structure/bed/chair/wheelchair))
		var/obj/structure/bed/chair/wheelchair/W = perp.buckled
		W.bloodiness = 4

	perp.update_inv_shoes(1)
	amount--

/obj/effect/decal/cleanable/blood/proc/dry()
		name = "dried [src.name]"
		desc = "It's dry and crusty. Someone is not doing their job."
		color = adjust_brightness(color, -50)
		amount = 0

/obj/effect/decal/cleanable/blood/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!amount || !ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	if(H.gloves)
		return

	var/taken = rand(1,amount)
	amount -= taken
	to_chat(H, span_notice("You get some of \the [src] on your hands."))

	H.add_blood(basecolor)
	H.bloody_hands += taken
	H.update_inv_gloves()



/obj/effect/decal/cleanable/blood/splatter
	random_icon_states = list("mgibbl1", "mgibbl2", "mgibbl3", "mgibbl4", "mgibbl5")
	amount = 2

/obj/effect/decal/cleanable/blood/drip
	name = "drips of blood"
	desc = "Some small drips of blood."
	gender = PLURAL
	icon = 'icons/effects/drip.dmi'
	icon_state = "1"
	random_icon_states = list("1","2","3","4","5")
	amount = 0
	var/drips

/obj/effect/decal/cleanable/blood/six
	icon_state = "gib6"

/obj/effect/decal/cleanable/blood/drip/tracking_fluid
	name = "tracking fluid"
	desc = "Tracking fluid from a tracking round."
	basecolor = "#00FFFF"
	layer = TRACKING_FLUID_LAYER

/obj/effect/decal/cleanable/blood/drip/tracking_fluid/dry()
	name = "dried [name]"
	desc = "Tracking fluid from a tracking round. It appears to have lost its color."
	color = adjust_brightness(color, -75)
	amount = 0

/obj/effect/decal/cleanable/blood/writing
	icon_state = "tracks"
	desc = "It looks like a writing in blood."
	gender = NEUTER
	random_icon_states = list("writing1","writing2","writing3","writing4","writing5")
	amount = 0
	var/message

/obj/effect/decal/cleanable/blood/writing/Initialize(mapload)
	. = ..()
	if(length(random_icon_states))
		for(var/obj/effect/decal/cleanable/blood/writing/W in loc)
			random_icon_states.Remove(W.icon_state)
		icon_state = pick(random_icon_states)
	else
		icon_state = "writing1"

/obj/effect/decal/cleanable/blood/writing/examine(mob/user)
	. = ..()
	. += "It reads: <font color='[basecolor]'>\"[message]\"<font>"

/obj/effect/decal/cleanable/blood/gibs
	name = "gibs"
	desc = "They look bloody and gruesome."
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/effects/blood.dmi'
	icon_state = "gibbl5"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")
	var/fleshcolor = "#FFC896"

/obj/effect/decal/cleanable/blood/gibs/update_icon()

	var/image/giblets = new(base_icon, "[icon_state]_flesh", dir)
	if(!fleshcolor || fleshcolor == "rainbow")
		fleshcolor = "#[pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))]"
	giblets.color = fleshcolor

	var/icon/blood = new(base_icon,"[icon_state]",dir)
	if(basecolor == "rainbow") basecolor = "#[pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))]"
	blood.Blend(basecolor,ICON_MULTIPLY)

	icon = blood
	overlays.Cut()
	overlays += giblets

/obj/effect/decal/cleanable/blood/gibs/up
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibup1","gibup1","gibup1")

/obj/effect/decal/cleanable/blood/gibs/down
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibdown1","gibdown1","gibdown1")

/obj/effect/decal/cleanable/blood/gibs/body
	random_icon_states = list("gibhead", "gibtorso")

/obj/effect/decal/cleanable/blood/gibs/limb
	random_icon_states = list("gibleg", "gibarm")

/obj/effect/decal/cleanable/blood/gibs/core
	random_icon_states = list("gibmid1", "gibmid2", "gibmid3")


/obj/effect/decal/cleanable/blood/gibs/proc/streak(list/directions)
	spawn (0)
		var/direction = pick(directions)
		for (var/i = 0, i < pick(1, 200; 2, 150; 3, 50; 4), i++)
			sleep(0.3 SECONDS)
			if (i > 0)
				var/obj/effect/decal/cleanable/blood/b = new /obj/effect/decal/cleanable/blood/splatter(src.loc)
				b.basecolor = src.basecolor
				b.update_icon()

			if (step_to(src, get_step(src, direction), 0))
				break


/obj/effect/decal/cleanable/mucus
	name = "mucus"
	desc = "Disgusting mucus."
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/effects/blood.dmi'
	icon_state = "mucus"
	random_icon_states = list("mucus")
	var/dry=0 // Keeps the lag down
	///The dry timer id
	var/dry_timer

/obj/effect/decal/cleanable/mucus/Initialize(mapload)
	. = ..()
	dry_timer = addtimer(VARSET_CALLBACK(src, dry, TRUE), DRYING_TIME * 2, TIMER_STOPPABLE)

/obj/effect/decal/cleanable/mucus/Destroy()
	if(dry_timer)
		deltimer(dry_timer)
	return ..()

/obj/effect/decal/cleanable/blood/humanimprint/one
	icon_state = "u_madman"

/obj/effect/decal/cleanable/blood/humanimprint/two
	icon_state = "u_psycopath"

/obj/effect/decal/cleanable/blood/humanimprint/three
	icon_state = "u_dangerous_l"

/obj/effect/decal/cleanable/blood/humanimprint/four
	icon_state = "u_madman_l"

/obj/effect/decal/cleanable/blood/humanimprint/five
	icon_state = "u_psycopath_l"
