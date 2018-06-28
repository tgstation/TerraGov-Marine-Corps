/obj/item/reagent_container/food/drinks/cans
	var/canopened = 0

	attack_self(mob/user as mob)
		if (canopened == 0)
			playsound(src.loc,'sound/effects/canopen.ogg', 15, 1)
			user << "<span class='notice'>You open the drink with an audible pop!</span>"
			canopened = 1
		else
			return

	attack(mob/M as mob, mob/user as mob, def_zone)
		if (canopened == 0)
			user << "<span class='notice'>You need to open the drink!</span>"
			return
		var/datum/reagents/R = src.reagents
		var/fillevel = gulp_size

		if(!R.total_volume || !R)
			user << "\red The [src.name] is empty!"
			return 0

		if(M == user)
			M << "\blue You swallow a gulp of [src]."
			if(reagents.total_volume)
				reagents.trans_to_ingest(M, gulp_size)
				reagents.reaction(M, INGEST)
				spawn(5)
					reagents.trans_to(M, gulp_size)

			playsound(M.loc,'sound/items/drink.ogg', 15, 1)
			return 1
		else if( istype(M, /mob/living/carbon/human) )
			if (canopened == 0)
				user << "<span class='notice'>You need to open the drink!</span>"
				return

		else if (canopened == 1)
			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] attempts to feed [M] [src].", 1)
			if(!do_mob(user, M, 30, BUSY_ICON_FRIENDLY)) return
			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] feeds [M] [src].", 1)

			var/rgt_list_text = get_reagent_list_text()

			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: [rgt_list_text]</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [M.name] by [M.name] ([M.ckey]) Reagents: [rgt_list_text]</font>")
			msg_admin_attack("[key_name(user)] fed [key_name(M)] with [src.name] Reagents: [rgt_list_text] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

			if(reagents.total_volume)
				reagents.trans_to_ingest(M, gulp_size)

			if(isrobot(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
				var/mob/living/silicon/robot/bro = user
				bro.cell.use(30)
				var/refill = R.get_master_reagent_id()
				spawn(600)
					R.add_reagent(refill, fillevel)

			playsound(M.loc,'sound/items/drink.ogg', 15, 1)
			return 1

		return 0


	afterattack(obj/target, mob/user, proximity)
		if(!proximity) return

		if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.
			if (canopened == 0)
				user << "<span class='notice'>You need to open the drink!</span>"
				return


		else if(target.is_open_container()) //Something like a glass. Player probably wants to transfer TO it.
			if (canopened == 0)
				user << "<span class='notice'>You need to open the drink!</span>"
				return

			if (istype(target, /obj/item/reagent_container/food/drinks/cans))
				var/obj/item/reagent_container/food/drinks/cans/cantarget = target
				if(cantarget.canopened == 0)
					user << "<span class='notice'>You need to open the drink you want to pour into!</span>"
					return

		return ..()



//DRINKS

/obj/item/reagent_container/food/drinks/cans/cola
	name = "\improper Fruit-Beer"
	desc = "In theory, Mango flavored root beer sounds like a pretty good idea. Weyland Yutani has disproved yet another theory with its latest line of cola. Canned by the Weyland-Yutani Corporation."
	icon_state = "fruit_beer"
	center_of_mass = list("x"=16, "y"=10)
	New()
		..()
		reagents.add_reagent("cola", 30)

/obj/item/reagent_container/food/drinks/cans/waterbottle
	name = "\improper Weyland-Yutani Bottled Spring Water"
	desc = "Overpriced 'Spring' water. Bottled by the Weyland-Yutani Corporation."
	icon_state = "wy_water"
	center_of_mass = list("x"=15, "y"=8)
	New()
		..()
		reagents.add_reagent("water", 30)

/obj/item/reagent_container/food/drinks/cans/beer
	name = "beer bottle"
	desc = "Beer. You've dialed in your target. Time to fire for effect."
	icon_state = "beer"
	center_of_mass = list("x"=16, "y"=12)
	New()
		..()
		reagents.add_reagent("beer", 30)

/obj/item/reagent_container/food/drinks/cans/ale
	name = "ale bottle"
	desc = "Beer's misunderstood cousin."
	icon_state = "alebottle"
	item_state = "beer"
	center_of_mass = list("x"=16, "y"=10)
	New()
		..()
		reagents.add_reagent("ale", 30)


/obj/item/reagent_container/food/drinks/cans/space_mountain_wind
	name = "\improper Mountain Wind"
	desc = "Blows right through you like a space wind."
	icon_state = "space_mountain_wind"
	center_of_mass = list("x"=16, "y"=10)
	New()
		..()
		reagents.add_reagent("spacemountainwind", 30)

/obj/item/reagent_container/food/drinks/cans/thirteenloko
	name = "\improper Thirteen Loko"
	desc = "The CMO has advised crew members that consumption of Thirteen Loko may result in seizures, blindness, drunkeness, or even death. Please Drink Responsibly."
	icon_state = "thirteen_loko"
	center_of_mass = list("x"=16, "y"=8)
	New()
		..()
		reagents.add_reagent("thirteenloko", 30)

/obj/item/reagent_container/food/drinks/cans/dr_gibb
	name = "\improper Dr. Gibb"
	desc = "A delicious mixture of 42 different flavors of chemicals that you can't pronoounce."
	icon_state = "dr_gibb"
	center_of_mass = list("x"=16, "y"=10)
	New()
		..()
		reagents.add_reagent("dr_gibb", 30)

/obj/item/reagent_container/food/drinks/cans/starkist
	name = "\improper Star-kist"
	desc = "The taste of a star in liquid form. And, a bit of tuna...?"
	icon_state = "starkist"
	center_of_mass = list("x"=16, "y"=10)
	New()
		..()
		reagents.add_reagent("cola", 15)
		reagents.add_reagent("orangejuice", 15)

/obj/item/reagent_container/food/drinks/cans/space_up
	name = "\improper Space-Up"
	desc = "Tastes like a hull breach in your mouth."
	icon_state = "space-up"
	center_of_mass = list("x"=16, "y"=10)
	New()
		..()
		reagents.add_reagent("space_up", 30)

/obj/item/reagent_container/food/drinks/cans/lemon_lime
	name = "lemon-lime"
	desc = "You wanted ORANGE. It gave you Lemon Lime."
	icon_state = "lemon-lime"
	center_of_mass = list("x"=16, "y"=10)
	New()
		..()
		reagents.add_reagent("lemon_lime", 30)

/obj/item/reagent_container/food/drinks/cans/iced_tea
	name = "iced tea can"
	desc = "Just like the squad redneck's grandmother used to buy."
	icon_state = "ice_tea_can"
	center_of_mass = list("x"=16, "y"=10)
	New()
		..()
		reagents.add_reagent("icetea", 30)

/obj/item/reagent_container/food/drinks/cans/grape_juice
	name = "grape juice"
	desc = "A can of probably not grape juice."
	icon_state = "purple_can"
	center_of_mass = list("x"=16, "y"=10)
	New()
		..()
		reagents.add_reagent("grapejuice", 30)

/obj/item/reagent_container/food/drinks/cans/tonic
	name = "tonic water"
	desc = "Step One: Tonic. Check. Step Two: Gin."
	icon_state = "tonic"
	center_of_mass = list("x"=16, "y"=10)
	New()
		..()
		reagents.add_reagent("tonic", 50)

/obj/item/reagent_container/food/drinks/cans/sodawater
	name = "soda water"
	desc = "A can of soda water. Tap water's more refreshing cousin...according to those Europe-folk."
	icon_state = "sodawater"
	center_of_mass = list("x"=16, "y"=10)
	New()
		..()
		reagents.add_reagent("sodawater", 50)

/obj/item/reagent_container/food/drinks/cans/souto
	name = "\improper Souto Classic"
	desc = "The can boldly proclaims it to be tangerine flavored. You can't help but think that's a lie. Canned in Havana."
	icon_state = "souto_classic"
	center_of_mass = list("x"=16, "y"=10)
	New()
		..()
		reagents.add_reagent("souto_classic", 50)

/obj/item/reagent_container/food/drinks/cans/souto/diet
	name = "\improper Diet Souto"
	desc = "Now with 0% fruit juice! Canned in Havana"
	icon_state = "souto_diet_classic"
	center_of_mass = list("x"=16, "y"=10)
	New()
		..()
		reagents.add_reagent("souto_classic", 25)
		reagents.add_reagent("water", 25)

/obj/item/reagent_container/food/drinks/cans/souto/cherry
	name = "\improper Cherry Souto"
	desc = "Now with more artificial flavors! Canned in Havana"
	icon_state = "souto_cherry"
	center_of_mass = list("x"=16, "y"=10)
	New()
		..()
		reagents.add_reagent("souto_cherry", 50)

/obj/item/reagent_container/food/drinks/cans/souto/cherry/diet
	name = "\improper Diet Cherry Souto"
	desc = "It's neither diet nor cherry flavored. Canned in Havanna."
	icon_state = "souto_diet_cherry"
	center_of_mass = list("x"=16, "y"=10)
	New()
		..()
		reagents.add_reagent("souto_cherry", 25)
		reagents.add_reagent("water", 25)

/obj/item/reagent_container/food/drinks/cans/aspen
	name = "\improper Weyland Yutani Aspen Beer"
	desc = "Pretty good when you get past the fact that it tastes like piss. Canned by the Weyland-Yutani Corporation."
	icon_state = "6_pack_1"
	center_of_mass = list("x"=16, "y"=10)
	New()
		..()
		reagents.add_reagent("beer", 50)

/obj/item/reagent_container/food/drinks/cans/souto/lime
	name = "\improper Lime Souto"
	desc = "It's not bad. It's not good either, but it's not bad. Canned in Havana."
	icon_state = "souto_lime"
	center_of_mass = list("x"=16, "y"=10)
	New()
		..()
		reagents.add_reagent("lemon_lime", 50)

/obj/item/reagent_container/food/drinks/cans/souto/lime/diet
	name = "\improper Diet Lime Souto"
	desc = "Ten kinds of acid, two cups of fake sugar, almost a full tank of carbon dioxide, and about 210 kPs all crammed into an aluminum can. What's not to love? Canned in Havana."
	icon_state = "souto_diet_lime"
	center_of_mass = list("x"=16, "y"=10)
	New()
		..()
		reagents.add_reagent("lemon_lime", 25)
		reagents.add_reagent("water", 25)

/obj/item/reagent_container/food/drinks/cans/souto/grape
	name = "\improper Grape Souto"
	desc = "An old standby for soda flavors. This, however, tastes like grape flavored cough syrup. Canned in Havana."
	icon_state = "souto_grape"
	center_of_mass = list("x"=16, "y"=10)
	New()
		..()
		reagents.add_reagent("grapejuice", 50)

/obj/item/reagent_container/food/drinks/cans/souto/grape/diet
	name = "\improper Diet Grape Souto"
	desc = "You're fairly certain that this is just grape cough syrup and carbonated water. Canned in Havana."
	icon_state = "souto_diet_grape"
	center_of_mass = list("x"=16, "y"=10)
	New()
		..()
		reagents.add_reagent("grapejuice", 25)
		reagents.add_reagent("water", 25)