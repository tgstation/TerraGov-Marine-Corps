//NO BUGS
/obj/structure/nobugs
	name = "metal pad"
	icon = 'icons/obj/items/devices.dmi'
	icon_state = "implant_melted"
	desc = "A strange small metal object with a button in the middle and rectangular hole on the side..."
	var/state = 0 //0 = hidden, 1 = shown
	var/coins = 0
	unacidable = 1

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W,/obj/item/coin))
			if(coins < 4 && !state)
				user.visible_message("[user] inserts \the [W] into \the [src].","<span class='notice'> You insert \the [W] inside \the [src].</span>")
				coins++
				qdel(W)
			else
				to_chat(user, "<span class='warning'>\the [W] does not fit anymore.</span>")
		else
			to_chat(user, "<span class='warning'>\the [W] does not fit inside that rectangular hole.</span>")

	examine(mob/user)
		desc = state?"<font size='4' color='red'>NO BUGS</font>":"A strange small metal object with a button in the middle and rectangular hole on the side..."
		..()

	attack_hand(mob/user)
		if(!user && !user.canmove && user.stat)
			return
		if(!state)
			if(coins)
				user.visible_message("You hear a click from somewhere near...","<span class='notice'> You press the button and hear a click coming from inside...</span>")
				state = 1
				spawn(rand(100,200))
					switch(coins)
						if(1)
							for(var/mob/living/carbon/human/H in range(8))
								if(!H || isnull(H) || H.stat) continue
								to_chat(H, "<font size=5 color=red>NO BUGS</font>")

						if(2)
							for(var/mob/living/carbon/human/H in range(9))
								if(!H || isnull(H) || H.stat) continue
								to_chat(H, "<font size=6 color=red>NO - BUGS</font>")
								new /obj/item/reagent_container/food/snacks/sliceable/braincake(get_turf(H.loc))

						if(3)
							for(var/mob/living/carbon/human/H in range(10))
								if(!H || isnull(H) || H.stat) continue
								to_chat(H, "<font size=7 color=red><b>NO<br>BUGS</b></font>")
								new /obj/item/reagent_container/pill/happy(get_turf(H.loc))
								new /obj/item/reagent_container/pill/happy(get_turf(H.loc))
								new /obj/item/reagent_container/pill/happy(get_turf(H.loc))
								new /obj/item/reagent_container/pill/happy(get_turf(H.loc))

						if(4)
							for(var/mob/living/carbon/human/H in range(12))
								if(!H || isnull(H) || H.stat) continue
								to_chat(H, "<font size=8 color=red><b>NO<br><br>BUGS</b></font>")
							new /obj/item/weapon/gun/launcher/rocket/toy(get_turf(src.loc))
							new /obj/item/ammo_magazine/rocket/toy(get_turf(src.loc))
							new /obj/item/ammo_magazine/rocket/toy(get_turf(src.loc))
							new /obj/item/ammo_magazine/rocket/toy(get_turf(src.loc))
							new /obj/item/ammo_magazine/rocket/toy(get_turf(src.loc))
							new /obj/item/ammo_magazine/rocket/toy(get_turf(src.loc))

					icon = 'icons/obj/decals.dmi'
					icon_state = "nobugs"
					layer = ABOVE_HUD_LAYER
					spawn(100)
						icon = 'icons/obj/items/devices.dmi'
						icon_state = "implant_melted"
						state = 0
						layer = 2
						coins = 0
			else
				to_chat(usr, "<span class='warning'>Nothing happened...</span>")
		else
			to_chat(usr, "<span class='warning'>Nothing happened...</span>")
