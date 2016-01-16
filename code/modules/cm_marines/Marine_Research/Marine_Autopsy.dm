//This is a necessary for the fancy autopsy system


/obj/item/weapon/WYautopsy
	name = "Weyland Brand Automatic Autopsy System(TM)"
	desc = "Putting the FUN back in Autopsy.  This little gadget performs an entire autopsy of whatever strange life form you've found in about 30 seconds."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel_laser2_on"
	damtype = "fire"
	force = 12.0
	var active = 0;



/obj/item/weapon/WYautopsy/attack(mob/living/carbon/T as mob, mob/living/user as mob)
/*	set category = "Autopsy"
	set name = "Perform Alien Autopsy"
	set src in usr*/
	if(active)
		usr << "Your already performign an autoposy"
		return
	active = 1
	var CHECK = user.loc
	playsound(loc, 'sound/weapons/pierce.ogg', 50)
	usr << "You begin to cut into the alien... This might take some time..."

	if(T.butchery_progress == 0)
		spawn(50)
			if(CHECK != user.loc)
				usr << "This is difficult, you probably shouldn't move"
				return.
			usr << "You've cut through the outer layers of Chitin"
			new /obj/item/XenoBio(T.loc) //This will be 1-3 Chitin eventually (depending on tier)
			T.butchery_progress++
			active = 0
	if(T.butchery_progress == 1)
		spawn(50)
			if(CHECK != user.loc)
				usr << "This is difficult, you probably shouldn't move."
				return
			usr << "You've cut into the chest cavity and retreived a sample of blood."
			new /obj/item/XenoBio(T.loc)//This will be a sample of blood eventually
			T.butchery_progress++
			active = 0
	if(T.butchery_progress == 2)
		spawn(50)
			if(CHECK != user.loc)
				usr << "This is difficult, you probably shouldn't move."
				return
			usr << "You've cut out an intact organ."
			new /obj/item/XenoBio(T.loc)//This will be an organ eventually, based on the caste.
			T.butchery_progress++
			active = 0
	if(T.butchery_progress == 3)
		spawn(50)
			if(CHECK != user.loc)
				usr << "This is difficult, you probably shouldn't move."
				return
			usr << "You scrape out the remaining biomass."
			active = 0
			new /obj/item/XenoBio(T.loc)
			new /obj/effect/decal/remains/xeno(T.loc)
			del(T)


	return













