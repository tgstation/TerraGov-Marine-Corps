//////Kitchen Spike

/obj/structure/kitchenspike
	name = "a meat spike"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spike"
	desc = "A spike for collecting meat from animals"
	density = 1
	anchored = 1
	var/meat = 0
	var/occupied = 0
	var/meattype = 0 // 0 - Nothing, 1 - Monkey, 2 - Xeno

/obj/structure/kitchenspike
	attack_paw(mob/user as mob)
		return src.attack_hand(usr)

	attackby(obj/item/grab/G, mob/user)
		if(!istype(G, /obj/item/grab))
			return
		if(istype(G.grabbed_thing, /mob/living/carbon/monkey))
			var/mob/living/carbon/monkey/M = G.grabbed_thing
			if(!occupied)
				icon_state = "spikebloody"
				occupied = 1
				meat = 5
				meattype = 1
				visible_message("\red [user] has forced [M] onto the spike, killing them instantly!")
				M.death()
				cdel(M)
				G.grabbed_thing = null
				cdel(G)

			else
				user << "\red The spike already has something on it, finish collecting its meat first!"
		else
			user << "\red They are too big for the spike, try something smaller!"
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
					new /obj/item/reagent_container/food/snacks/meat/monkey( src.loc )
					usr << "You remove some meat from the monkey."
				else if(src.meat == 1)
					src.meat--
					new /obj/item/reagent_container/food/snacks/meat/monkey(src.loc)
					usr << "You remove the last piece of meat from the monkey!"
					src.icon_state = "spike"
					src.occupied = 0
			else if(src.meattype == 2)
				if(src.meat > 1)
					src.meat--
					new /obj/item/reagent_container/food/snacks/xenomeat( src.loc )
					usr << "You remove some meat from the alien."
				else if(src.meat == 1)
					src.meat--
					new /obj/item/reagent_container/food/snacks/xenomeat(src.loc)
					usr << "You remove the last piece of meat from the alien!"
					src.icon_state = "spike"
					src.occupied = 0