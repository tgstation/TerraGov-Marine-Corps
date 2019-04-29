/obj/structure/showcase
	name = "Showcase"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "showcase_1"
	desc = "A stand with the empty body of a cyborg bolted to it."
	density = TRUE
	anchored = TRUE

/obj/structure/showcase/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(50))
				qdel(src)

/obj/structure/showcase/yaut
	name = "alien sarcophagus"
	desc = "An ancient, dusty tomb with strange alien writing. It's best not to touch it."
	icon_state = "yaut"

/obj/structure/monorail
	name = "monorail track"
	icon = 'icons/obj/structures/structures.dmi'
	icon_state = "monorail"
	density = FALSE
	anchored = TRUE
	layer = ATMOS_PIPE_LAYER + 0.01

/obj/structure/mopbucket
	name = "mop bucket"
	desc = "Fill it with water, but don't forget a mop!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = TRUE
	anchored = FALSE
	var/amount_per_transfer_from_this = 5 //Shit I dunno, adding this so syringes stop runtime erroring. --NeoFite

/obj/structure/mopbucket/New()
	..()
	create_reagents(100, OPENCONTAINER)

/obj/structure/mopbucket/examine(mob/user)
	..()
	to_chat(user, "It contains [reagents.total_volume] unit\s of water!")

/obj/structure/mopbucket/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/tool/mop))
		if(reagents.total_volume < 1)
			to_chat(user, "<span class='warning'>[src] is out of water!</span>")
		else
			reagents.trans_to(I, 5)
			to_chat(user, "<span class='notice'>You wet [I] in [src].</span>")
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)

/obj/structure/shipmast
	name = "\the Ships Mast"
	icon = 'icons/obj/structures/structures.dmi'
	icon_state = "shipmast" //Thank you to Spyroshark and Arachnidnexus
	desc = "A piece of old earth that was. The plaque reads<br><br><span class='name'>HMS Victory Sailed 1765 to 1922.</span><br><span class='name'>Relaunched 2393.</span><br><span class='name'>On loan from the First Sea Lord.</span><br><br>"
	layer = ABOVE_MOB_LAYER
	density = TRUE
	anchored = TRUE

/obj/structure/shipmast/attack_hand(var/mob/user)
	. = ..()
	switch(user.a_intent)
		if(INTENT_HELP)
			visible_message("[usr] rubs the [src] for good luck.")
		if(INTENT_DISARM)
			visible_message("[usr] pushes the [src]. It's surprisingly solid.")
		if(INTENT_GRAB)
			visible_message("[usr] hugs the [src].")
		if(INTENT_HARM)
			visible_message("[usr] punches the [src] while letting out a muttered curse.")

//ICE COLONY RESEARCH DECORATION-----------------------//
//Most of icons made by ~Morrinn
obj/structure/xenoautopsy
	name = "Research thingies"
	icon = 'icons/obj/alien_autopsy.dmi'
	icon_state = "jarshelf_9"

obj/structure/xenoautopsy/jar_shelf
	name = "jar shelf"
	icon_state = "jarshelf_0"
	var/randomise = 1 //Random icon

	New()
		if(randomise)
			icon_state = "jarshelf_[rand(0,9)]"

obj/structure/xenoautopsy/tank
	name = "cryo tank"
	icon_state = "tank_empty"
	desc = "It is empty."

obj/structure/xenoautopsy/tank/broken
	name = "cryo tank"
	icon_state = "tank_broken"
	desc = "Something broke it..."

obj/structure/xenoautopsy/tank/alien
	name = "cryo tank"
	icon_state = "tank_alien"
	desc = "There is something big inside..."

obj/structure/xenoautopsy/tank/hugger
	name = "cryo tank"
	icon_state = "tank_hugger"
	desc = "There is something spider-like inside..."

obj/structure/xenoautopsy/tank/larva
	name = "cryo tank"
	icon_state = "tank_larva"
	desc = "There is something worm-like inside..."

obj/item/alienjar
	name = "sample jar"
	icon = 'icons/obj/alien_autopsy.dmi'
	icon_state = "jar_sample"
	desc = "Used to store organic samples inside for preservation."

	New()
		var/image/I
		I = image('icons/obj/alien_autopsy.dmi', "sample_[rand(0,11)]")
		I.layer = src.layer - 0.1
		overlays += I
		pixel_x += rand(-3,3)
		pixel_y += rand(-3,3)




//stairs

/obj/structure/stairs
	name = "Stairs"
	icon = 'icons/obj/structures/structures.dmi'
	desc = "Stairs.  You walk up and down them."
	icon_state = "rampbottom"
	density = 0
	opacity = 0