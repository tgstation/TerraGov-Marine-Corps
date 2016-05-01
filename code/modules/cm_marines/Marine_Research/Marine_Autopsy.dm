//This is a necessary for the fancy autopsy system


/obj/item/weapon/WYautopsy
	name = "Weyland Brand Automatic Autopsy System(TM)"
	desc = "Putting the FUN back in Autopsy.  This little gadget performs an entire autopsy of whatever strange life form you've found in about 30 seconds."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel_laser2_on"
	damtype = "fire"
	force = 12.0
	var active = 0;



/obj/item/weapon/WYautopsy/attack(mob/living/carbon/Xenomorph/T as mob, mob/living/user as mob)
/*	set category = "Autopsy"
	set name = "Perform Alien Autopsy"
	set src in usr*/
	if(!isXeno(T))
		usr << "What are you, some sort of fucking MONSTER?"
		return
	if(T.health > 0)
		usr << "Nope."
		return
	if(active)
		usr << "Your already performing an autopsy"
		return
	active = 1
	var CHECK = user.loc
	playsound(loc, 'sound/weapons/pierce.ogg', 50)
	usr << "You begin to cut into the alien... This might take some time..."
	if(T.health >-100)
		usr << "HOLY SHIT IT'S STILL ALIVE.  It knocks you down as it jumps up."
		usr.weakened = 20
		T << "You feel TREMENDOUS pain and jump back up to use the last of your strength to kill [usr] with your final moments of life. (~10 seconds)"
		T.health = T.maxHealth*2 //It's hulk levels of angry.
		active = 0
		spawn (1000) //Around 10 seconds
			T.adjustBruteLoss(5000) //to make sure it's DEAD after it's hyper-boost
		return

	if(T.butchery_progress == 0)
		spawn(50)
			if(CHECK != user.loc)
				usr << "This is difficult, you probably shouldn't move"
				return.
			usr << "You've cut through the outer layers of Chitin"
			new /obj/item/XenoBio/Chitin(T.loc) //This will be 1-3 Chitin eventually (depending on tier)
			new /obj/item/XenoBio/Chitin(T.loc) //This will be 1-3 Chitin eventually (depending on tier)
			T.butchery_progress++
			active = 0
	if(T.butchery_progress == 1)
		spawn(50)
			if(CHECK != user.loc)
				usr << "This is difficult, you probably shouldn't move."
				return
			usr << "You've cut into the chest cavity and retreived a sample of blood."
			new /obj/item/XenoBio/Blood(T.loc)//This will be a sample of blood eventually
			T.butchery_progress++
			active = 0
	if(T.butchery_progress == 2)
		spawn(50)
			if(CHECK != user.loc)
				usr << "This is difficult, you probably shouldn't move."
				return
			//usr << "You've cut out an intact organ."
			usr << "You've cut out some Biomass..."
			new /obj/item/XenoBio/Biomass(T.loc)//This will be an organ eventually, based on the caste.
			T.butchery_progress++
			active = 0
	if(T.butchery_progress == 3)
		spawn(50)
			if(CHECK != user.loc)
				usr << "This is difficult, you probably shouldn't move."
				return
			usr << "You scrape out the remaining biomass."
			active = 0
			new /obj/item/XenoBio/Biomass(T.loc)
			new /obj/effect/decal/remains/xeno(T.loc)
			del(T)


	return













