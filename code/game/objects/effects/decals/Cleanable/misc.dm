/obj/effect/decal/cleanable/generic
	name = "clutter"
	desc = "Someone should clean that up."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = TURF_LAYER
	icon = 'icons/obj/objects.dmi'
	icon_state = "shards"

/obj/effect/decal/cleanable/ash
	name = "ashes"
	desc = "Ashes to ashes, dust to dust, and into space."
	gender = PLURAL
	icon = 'icons/obj/objects.dmi'
	icon_state = "ash"
	anchored = 1

/obj/effect/decal/cleanable/ash/attack_hand(mob/user as mob)
	to_chat(user, "<span class='notice'>[src] sifts through your fingers.</span>")
	cdel(src)

/obj/effect/decal/cleanable/greenglow

	New()
		..()
		spawn(1200)// 2 minutes
			cdel(src)

/obj/effect/decal/cleanable/dirt
	name = "dirt"
	desc = "Someone should clean that up."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = TURF_LAYER
	icon = 'icons/effects/effects.dmi'
	icon_state = "dirt"
	mouse_opacity = 0

/obj/effect/decal/cleanable/flour
	name = "flour"
	desc = "It's still good. Four second rule!"
	gender = PLURAL
	density = 0
	anchored = 1
	layer = TURF_LAYER
	icon = 'icons/effects/effects.dmi'
	icon_state = "flour"

/obj/effect/decal/cleanable/greenglow
	name = "glowing goo"
	desc = "Jeez. I hope that's not for lunch."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = TURF_LAYER
	luminosity = 1
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenglow"

/obj/effect/decal/cleanable/greenglow/Dispose()
	SetLuminosity(0)
	. = ..()

/obj/effect/decal/cleanable/cobweb
	name = "cobweb"
	desc = "Somebody should remove that."
	density = 0
	anchored = 1
	layer = FLY_LAYER
	icon = 'icons/effects/effects.dmi'
	icon_state = "cobweb1"

/obj/effect/decal/cleanable/molten_item
	name = "gooey grey mass"
	desc = "It looks like a melted... something."
	density = 0
	anchored = 1
	layer = OBJ_LAYER
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "molten"

/obj/effect/decal/cleanable/cobweb2
	name = "cobweb"
	desc = "Somebody should remove that."
	density = 0
	anchored = 1
	layer = OBJ_LAYER
	icon = 'icons/effects/effects.dmi'
	icon_state = "cobweb2"

//Vomit (sorry)
/obj/effect/decal/cleanable/vomit
	name = "vomit"
	desc = "Gosh, how unpleasant."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = TURF_LAYER
	icon = 'icons/effects/blood.dmi'
	icon_state = "vomit_1"
	random_icon_states = list("vomit_1", "vomit_2", "vomit_3", "vomit_4")
	var/list/viruses = list()

	Dispose()
		for(var/datum/disease/D in viruses)
			D.cure(0)
		. = ..()

/obj/effect/decal/cleanable/tomato_smudge
	name = "tomato smudge"
	desc = "It's red."
	density = 0
	anchored = 1
	layer = TURF_LAYER
	icon = 'icons/effects/effects.dmi'
	random_icon_states = list("tomato_floor1", "tomato_floor2", "tomato_floor3")

/obj/effect/decal/cleanable/egg_smudge
	name = "smashed egg"
	desc = "Seems like this one won't hatch."
	density = 0
	anchored = 1
	layer = TURF_LAYER
	icon = 'icons/effects/effects.dmi'
	random_icon_states = list("smashed_egg1", "smashed_egg2", "smashed_egg3")

/obj/effect/decal/cleanable/pie_smudge //honk
	name = "smashed pie"
	desc = "It's pie cream from a cream pie."
	density = 0
	anchored = 1
	layer = TURF_LAYER
	icon = 'icons/effects/effects.dmi'
	random_icon_states = list("smashed_pie")

/obj/effect/decal/cleanable/blackgoo
	name = "black goo"
	desc = "It's thick and gooey."
	gender = PLURAL
	icon = 'icons/effects/effects.dmi'
	icon_state = "blackgoo"

/obj/effect/decal/cleanable/blackgoo/Crossed(mob/living/carbon/human/H)
	if(!istype(H)) return
	if(H.species.name == "Human")
		if(!H.shoes || prob(25))
			H.contract_disease(new /datum/disease/black_goo)