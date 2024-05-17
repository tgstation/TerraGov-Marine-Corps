///////////////////////////////////
////////  Mecha wreckage   ////////
///////////////////////////////////


/obj/structure/mecha_wreckage
	name = "exosuit wreckage"
	desc = "Remains of some unfortunate mecha. Completely irreparable, but perhaps something can be salvaged."
	icon = 'icons/mecha/mecha.dmi'
	hit_sound = 'sound/effects/metal_crash.ogg'
	density = TRUE
	anchored = FALSE
	opacity = FALSE
	resistance_flags = XENO_DAMAGEABLE
	///list of welder-salvaged items that it can output
	var/list/welder_salvage = list(/obj/item/stack/sheet/plasteel)
	/// times we can salvage this mech
	var/salvage_num = 5
	///list of crowbar-salvaged items that it can output
	var/list/crowbar_salvage = list()
	/// if the wires got pulled yet
	var/wires_removed = FALSE
	///AIs to be salvaged
	var/mob/living/silicon/ai/AI
	/// parts of the mechs that can be taken out
	var/list/parts

/obj/structure/mecha_wreckage/Initialize(mapload, mob/living/silicon/ai/AI_pilot)
	. = ..()
	if(parts)
		for(var/i in 1 to 2)
			if(!length(parts))
				break
			if(prob(60))
				continue
			var/part = pick(parts)
			welder_salvage += part
		parts = null

/obj/structure/mecha_wreckage/Destroy()
	if(AI)
		QDEL_NULL(AI)
	QDEL_LIST(crowbar_salvage)
	return ..()

/obj/structure/mecha_wreckage/examine(mob/user)
	. = ..()
	if(!AI)
		return
	. += span_notice("The AI recovery beacon is active.")

/obj/structure/mecha_wreckage/welder_act(mob/living/user, obj/item/I)
	..()
	. = TRUE
	if(salvage_num <= 0 || !length(welder_salvage))
		to_chat(user, span_notice("You don't see anything that can be cut with [I]!"))
		return
	if(!I.use_tool(src, user, 0, volume=50))
		return
	if(prob(30))
		to_chat(user, span_notice("You fail to salvage anything valuable from [src]!"))
		return
	var/type = pick(welder_salvage)
	var/N = new type(get_turf(user))
	user.visible_message(span_notice("[user] cuts [N] from [src]."), span_notice("You cut [N] from [src]."))
	if(!istype(N, /obj/item/stack))
		welder_salvage -= type
	salvage_num--

/obj/structure/mecha_wreckage/wirecutter_act(mob/living/user, obj/item/I)
	..()
	. = TRUE
	if(wires_removed)
		to_chat(user, span_notice("You don't see anything that can be cut with [I]!"))
		return
	var/N = new /obj/item/stack/cable_coil(get_turf(user), rand(1,3))
	user.visible_message(span_notice("[user] cuts [N] from [src]."), span_notice("You cut [N] from [src]."))
	wires_removed = TRUE

/obj/structure/mecha_wreckage/crowbar_act(mob/living/user, obj/item/I)
	..()
	. = TRUE
	if(length(crowbar_salvage))
		var/obj/S = pick(crowbar_salvage)
		S.forceMove(user.drop_location())
		user.visible_message(span_notice("[user] pries [S] from [src]."), span_notice("You pry [S] from [src]."))
		crowbar_salvage -= S
		return
	to_chat(user, span_notice("You don't see anything that can be cut with [I]!"))

/obj/structure/mecha_wreckage/gygax
	name = "\improper Gygax wreckage"
	icon_state = "gygax-broken"

/obj/structure/mecha_wreckage/gygax/dark
	name = "\improper Dark Gygax wreckage"
	icon_state = "darkgygax-broken"

/obj/structure/mecha_wreckage/marauder
	name = "\improper Marauder wreckage"
	icon_state = "marauder-broken"

/obj/structure/mecha_wreckage/mauler
	name = "\improper Mauler wreckage"
	icon_state = "mauler-broken"
	desc = "The syndicate won't be very happy about this..."

/obj/structure/mecha_wreckage/seraph
	name = "\improper Seraph wreckage"
	icon_state = "seraph-broken"

/obj/structure/mecha_wreckage/reticence
	name = "\improper Reticence wreckage"
	icon_state = "reticence-broken"
	color = "#87878715"
	desc = "..."

/obj/structure/mecha_wreckage/ripley
	name = "\improper Ripley wreckage"
	icon_state = "ripley-broken"

/obj/structure/mecha_wreckage/ripley/mk2
	name = "\improper Ripley MK-II wreckage"
	icon_state = "ripleymkii-broken"

/obj/structure/mecha_wreckage/ripley/lv624
	name = "MkIV Powerloader Wreckage"
	anchored = TRUE
/obj/structure/mecha_wreckage/clarke
	name = "\improper Clarke wreckage"
	icon_state = "clarke-broken"

/obj/structure/mecha_wreckage/ripley/deathripley
	name = "\improper Death-Ripley wreckage"
	icon_state = "deathripley-broken"

/obj/structure/mecha_wreckage/honker
	name = "\improper H.O.N.K wreckage"
	icon_state = "honker-broken"
	desc = "All is right in the universe."

/obj/structure/mecha_wreckage/durand
	name = "\improper Durand wreckage"
	icon_state = "durand-broken"

/obj/structure/mecha_wreckage/phazon
	name = "\improper Phazon wreckage"
	icon_state = "phazon-broken"

/obj/structure/mecha_wreckage/savannah_ivanov
	name = "\improper Savannah-Ivanov wreckage"
	icon_state = "savannah_ivanov-broken"

/obj/structure/mecha_wreckage/odysseus
	name = "\improper Odysseus wreckage"
	icon_state = "odysseus-broken"

/obj/structure/mecha_wreckage/hoverpod
	name = "Hover pod wreckage"
	icon_state = "engineering_pod-broken"
