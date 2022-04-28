//////Kitchen Spike

/obj/structure/kitchenspike
	name = "a meat spike"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spike"
	desc = "A spike for collecting meat from animals"
	density = TRUE
	anchored = TRUE
	coverage = 5
	var/meat = 0
	var/occupied = 0
	var/meattype = 0 // 0 - Nothing, 1 - Monkey, 2 - Xeno

/obj/structure/kitchenspike

	attackby(obj/item/grab/G, mob/user)
		if(!istype(G, /obj/item/grab))
			return
		if(ismonkey(G.grabbed_thing))
			var/mob/living/carbon/human/species/monkey/M = G.grabbed_thing
			if(!occupied)
				icon_state = "spikebloody"
				occupied = 1
				meat = 5
				meattype = 1
				visible_message(span_warning(" [user] has forced [M] onto the spike, killing [M.p_them()] instantly!"))
				M.death(TRUE)
				G.grabbed_thing = null
				qdel(G)

			else
				to_chat(user, span_warning("The spike already has something on it, finish collecting its meat first!"))
		else
			to_chat(user, span_warning("They are too big for the spike, try something smaller!"))
			return

//	MouseDrop_T(var/atom/movable/C, mob/user)
//		if(istype(C, /obj/mob/carbon/monkey)
//		else if(istype(C, /obj/mob/carbon/alien))
//		else if(istype(C, /obj/livestock/spesscarp

	attack_hand(mob/user as mob)
		if(..())
			return
		if(src.occupied)
			if(src.meattype == 1)
				if(src.meat > 1)
					src.meat--
					new /obj/item/reagent_containers/food/snacks/meat/monkey( src.loc )
					to_chat(usr, "You remove some meat from the monkey.")
				else if(src.meat == 1)
					src.meat--
					new /obj/item/reagent_containers/food/snacks/meat/monkey(src.loc)
					to_chat(usr, "You remove the last piece of meat from the monkey!")
					src.icon_state = "spike"
					src.occupied = 0
			else if(src.meattype == 2)
				if(src.meat > 1)
					src.meat--
					new /obj/item/reagent_containers/food/snacks/xenomeat( src.loc )
					to_chat(usr, "You remove some meat from the alien.")
				else if(src.meat == 1)
					src.meat--
					new /obj/item/reagent_containers/food/snacks/xenomeat(src.loc)
					to_chat(usr, "You remove the last piece of meat from the alien!")
					src.icon_state = "spike"
					src.occupied = 0
