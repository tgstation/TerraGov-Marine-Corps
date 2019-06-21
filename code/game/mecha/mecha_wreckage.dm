///////////////////////////////////
////////  Mecha wreckage   ////////
///////////////////////////////////


/obj/effect/decal/mecha_wreckage
	name = "Exosuit wreckage"
	desc = "Remains of some unfortunate mecha. There is nothing left to Salvage."
	icon = 'icons/mecha/mecha.dmi'
	density = TRUE
	anchored = 0
	opacity = 0


/obj/effect/decal/mecha_wreckage/ex_act(severity)
	if(severity < 2)
		spawn
			qdel(src)
	return

/obj/effect/decal/mecha_wreckage/bullet_act(obj/item/projectile/Proj)
	return 1


/obj/effect/decal/mecha_wreckage/attack_alien(mob/living/carbon/xenomorph/M)
	if(M.a_intent != INTENT_HARM)
		return
		
	playsound(src, 'sound/effects/metal_crash.ogg', 50, 1)
	M.visible_message("<span class='danger'>[M] slices [src] apart!</span>","<span class='danger'>You slice [src] apart!</span>")
	robogibs(src)
	qdel(src)


/obj/effect/decal/mecha_wreckage/gygax
	name = "Gygax wreckage"
	icon_state = "gygax-broken"

/obj/effect/decal/mecha_wreckage/gygax/dark
	name = "Dark Gygax wreckage"
	icon_state = "darkgygax-broken"

/obj/effect/decal/mecha_wreckage/marauder
	name = "Marauder wreckage"
	icon_state = "marauder-broken"

/obj/effect/decal/mecha_wreckage/mauler
	name = "Mauler Wreckage"
	icon_state = "mauler-broken"
	desc = "The syndicate won't be very happy about this..."

/obj/effect/decal/mecha_wreckage/seraph
	name = "Seraph wreckage"
	icon_state = "seraph-broken"

/obj/effect/decal/mecha_wreckage/ripley
	name = "Ripley wreckage"
	icon_state = "ripley-broken"

/obj/effect/decal/mecha_wreckage/ripley/lv624
	name = "MkIV Powerloader Wreckage"
	anchored = TRUE

/obj/effect/decal/mecha_wreckage/ripley/firefighter
	name = "Firefighter wreckage"
	icon_state = "firefighter-broken"

/obj/effect/decal/mecha_wreckage/ripley/deathripley
	name = "Death-Ripley wreckage"
	icon_state = "deathripley-broken"

/obj/effect/decal/mecha_wreckage/durand
	name = "Durand wreckage"
	icon_state = "durand-broken"

/obj/effect/decal/mecha_wreckage/phazon
	name = "Phazon wreckage"
	icon_state = "phazon-broken"


/obj/effect/decal/mecha_wreckage/odysseus
	name = "Odysseus wreckage"
	icon_state = "odysseus-broken"

/obj/effect/decal/mecha_wreckage/hoverpod
	name = "Hover pod wreckage"
	icon_state = "engineering_pod-broken"
