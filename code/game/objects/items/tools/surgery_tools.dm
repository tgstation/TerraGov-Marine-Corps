

// Surgery Tools
/obj/item/tool/surgery
	icon = 'icons/obj/items/surgery_tools.dmi'
	attack_speed = 4 // reduced

/*
 * Retractor
 */
/obj/item/tool/surgery/retractor
	name = "retractor"
	desc = "Retracts stuff."
	icon_state = "retractor"
	matter = list("metal" = 10000, "glass" = 5000)
	flags_atom = FPRINT|CONDUCT
	w_class = 2.0
	origin_tech = "materials=1;biotech=1"

/*
 * Hemostat
 */
/obj/item/tool/surgery/hemostat
	name = "hemostat"
	desc = "You think you have seen this before."
	icon_state = "hemostat"
	matter = list("metal" = 5000, "glass" = 2500)
	flags_atom = FPRINT|CONDUCT
	w_class = 2.0
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "pinched")

/*
 * Cautery
 */
/obj/item/tool/surgery/cautery
	name = "cautery"
	desc = "This stops bleeding."
	icon_state = "cautery"
	matter = list("metal" = 5000, "glass" = 2500)
	flags_atom = FPRINT|CONDUCT
	w_class = 1
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("burnt")

/*
 * Surgical Drill
 */
/obj/item/tool/surgery/surgicaldrill
	name = "surgical drill"
	desc = "You can drill using this item. You dig?"
	icon_state = "drill"
	hitsound = 'sound/weapons/circsawhit.ogg'
	matter = list("metal" = 15000, "glass" = 10000)
	flags_atom = FPRINT|CONDUCT
	force = 15.0
	w_class = 2.0
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("drilled")

	suicide_act(mob/user)
		viewers(user) << pick("\red <b>[user] is pressing the [src.name] to \his temple and activating it! It looks like \he's trying to commit suicide.</b>", \
							"\red <b>[user] is pressing [src.name] to \his chest and activating it! It looks like \he's trying to commit suicide.</b>")
		return (BRUTELOSS)

/*
 * Scalpel
 */
/obj/item/tool/surgery/scalpel
	name = "scalpel"
	desc = "Cut, cut, and once more cut."
	icon_state = "scalpel"
	flags_atom = FPRINT|CONDUCT
	force = 10.0
	sharp = IS_SHARP_ITEM_ACCURATE
	edge = 1
	w_class = 1
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	matter = list("metal" = 10000, "glass" = 5000)
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

	suicide_act(mob/user)
		viewers(user) << pick("\red <b>[user] is slitting \his wrists with the [src.name]! It looks like \he's trying to commit suicide.</b>", \
							"\red <b>[user] is slitting \his throat with the [src.name]! It looks like \he's trying to commit suicide.</b>", \
							"\red <b>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</b>")
		return (BRUTELOSS)

/*
 * Researchable Scalpels
 */
/obj/item/tool/surgery/scalpel/laser1
	name = "laser scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field.  This one looks basic and could be improved."
	icon_state = "scalpel_laser1_on"
	damtype = "fire"

/obj/item/tool/surgery/scalpel/laser2
	name = "laser scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field.  This one looks somewhat advanced."
	icon_state = "scalpel_laser2_on"
	damtype = "fire"
	force = 12.0

/obj/item/tool/surgery/scalpel/laser3
	name = "laser scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field.  This one looks to be the pinnacle of precision energy cutlery!"
	icon_state = "scalpel_laser3_on"
	damtype = "fire"
	force = 15.0

/obj/item/tool/surgery/scalpel/manager
	name = "incision management system"
	desc = "A true extension of the surgeon's body, this marvel instantly and completely prepares an incision allowing for the immediate commencement of therapeutic steps."
	icon_state = "scalpel_manager_on"
	force = 7.5

/*
 * Circular Saw
 */
/obj/item/tool/surgery/circular_saw
	name = "circular saw"
	desc = "For heavy duty cutting."
	icon_state = "saw3"
	hitsound = 'sound/weapons/circsawhit.ogg'
	flags_atom = FPRINT|CONDUCT
	force = 15.0
	w_class = 2.0
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	matter = list("metal" = 20000,"glass" = 10000)
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "slashed", "sawed", "cut")
	sharp = IS_SHARP_ITEM_BIG
	edge = 1

//misc, formerly from code/defines/weapons.dm
/obj/item/tool/surgery/bonegel
	name = "bone gel"
	icon_state = "bone-gel"
	force = 0
	w_class = 2.0
	throwforce = 1.0

/obj/item/tool/surgery/FixOVein
	name = "FixOVein"
	icon_state = "fixovein"
	force = 0
	throwforce = 1.0
	origin_tech = "materials=1;biotech=3"
	w_class = 2.0
	var/usage_amount = 10

/obj/item/tool/surgery/bonesetter
	name = "bone setter"
	icon_state = "bone setter"
	force = 8.0
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	w_class = 2.0
	attack_verb = list("attacked", "hit", "bludgeoned")

/*
 * Predator Retractor
 */
/obj/item/tool/surgery/retractor/predatorretractor
	name = "opener"
	desc = "Retracts stuff."
	icon_state = "predator_retractor"

/*
 * Predator Hemostat
 */
/obj/item/tool/surgery/hemostat/predatorhemostat
	name = "pincher"
	desc = "You think you have seen this before."
	icon_state = "predator_hemostat"

/*
 * Predator Cautery
 */
/obj/item/tool/surgery/cautery/predatorcautery
	name = "cauterizer"
	desc = "This stops bleeding."
	icon_state = "predator_cautery"

/*
 * Predator Surgical Drill
 */
/obj/item/tool/surgery/surgicaldrill/predatorsurgicaldrill
	name = "bone drill"
	desc = "You can drill using this item. You dig?"
	icon_state = "predator_drill"

/*
 * Predator Scalpel
 */
/obj/item/tool/surgery/scalpel/predatorscalpel
	name = "cutter"
	desc = "Cut, cut, and once more cut."
	icon_state = "predator_scalpel"

/*
 * Predator Saw
 */
/obj/item/tool/surgery/circular_saw/predatorbonesaw
	name = "bone saw"
	desc = "For heavy duty cutting."
	icon_state = "predator_bonesaw"

/*
 * Predator Bonegel
 */
/obj/item/tool/surgery/bonegel/predatorbonegel
	name = "gel gun"
	icon_state = "predator_bone-gel"

/*
 * Predator FixOVein
 */
/obj/item/tool/surgery/FixOVein/predatorFixOVein
	name = "vein fixer"
	icon_state = "predator_fixovein"

/*
 * Predator Bonesetter
 */
/obj/item/tool/surgery/bonesetter/predatorbonesetter
	name = "bone placer"
	icon_state = "predator_bonesetter"

//XENO AUTOPSY TOOL

/obj/item/tool/surgery/WYautopsy
	name = "Weyland Brand Automatic Autopsy System(TM)"
	desc = "Putting the FUN back in Autopsy.  This little gadget performs an entire autopsy of whatever strange life form you've found in about 30 seconds."
	icon_state = "scalpel_laser2_on"
	damtype = "fire"
	force = 12.0
	var/active = 0
	var/resetting = 0//For the reset, to prevent macro-spam abuse

/obj/item/tool/surgery/WYautopsy/verb/reset()
	set category = "IC"
	set name = "Reset WY Autopsy tool"
	set desc = "Reset the WY Tool in case it breaks."
	set src in usr

	if(!active)
		usr << "System appears to be working fine..."
		return
	if(active)
		resetting = 1
		usr << "Resetting tool, This will take a few seconds...  Do not attempt to use the tool during the reset or it may malfunction."
		while(active) //While keep running until it's reset (in case of lag-spam)
			active = 0 //Sets it to not active
			usr << "Processing..."
			spawn(60) // runs a timer before the final check.  timer is longer than autopsy timers.
				if(!active)
					usr << "System Reset completed"
					resetting = 0

/obj/item/tool/surgery/WYautopsy/attack(mob/living/carbon/Xenomorph/T as mob, mob/living/user as mob)
/*	set category = "Autopsy"
	set name = "Perform Alien Autopsy"
	set src in usr*/
	if(resetting)
		usr << "Tool is currently returning to factory default.  If you have been waiting, try running the reset again."
	if(!isXeno(T))
		usr << "What are you, some sort of fucking MONSTER?"
		return
	if(T.health > 0)
		usr << "Nope."
		return
	if(active)
		usr << "Your already performing an autopsy"
		return
	if(istype(T, /mob/living/carbon/Xenomorph/Larva))
		usr << "It's too young... (This will be in a future update)"
		return
	active = 1
	var CHECK = user.loc
	playsound(loc, 'sound/weapons/pierce.ogg', 25)
	usr << "You begin to cut into the alien... This might take some time..."
	if(T.health >-100)
		usr << "HOLY SHIT IT'S STILL ALIVE.  It knocks you down as it jumps up."
		usr.KnockDown(20)
		T << "You feel TREMENDOUS pain and jump back up to use the last of your strength to kill [usr] with your final moments of life. (~10 seconds)"
		T.health = T.maxHealth*2 //It's hulk levels of angry.
		active = 0
		spawn (1000) //Around 10 seconds
			T.adjustBruteLoss(5000) //to make sure it's DEAD after it's hyper-boost
		return

	switch(T.butchery_progress)
		if(0)
			spawn(50)
				if(CHECK != user.loc)
					usr << "This is difficult, you probably shouldn't move"
					return.
				usr << "You've cut through the outer layers of Chitin"
				new /obj/item/XenoBio/Chitin(T.loc) //This will be 1-3 Chitin eventually (depending on tier)
				new /obj/item/XenoBio/Chitin(T.loc) //This will be 1-3 Chitin eventually (depending on tier)
				T.butchery_progress++
				active = 0
		if(1)
			spawn(50)
				if(CHECK != user.loc)
					usr << "This is difficult, you probably shouldn't move."
					return
				usr << "You've cut into the chest cavity and retreived a sample of blood."
				new /obj/item/XenoBio/Blood(T.loc)//This will be a sample of blood eventually
				T.butchery_progress++
				active = 0
		if(2)
			spawn(50)
				if(CHECK != user.loc)
					usr << "This is difficult, you probably shouldn't move."
					return
				//usr << "You've cut out an intact organ."
				usr << "You've cut out some Biomass..."
				new /obj/item/XenoBio/Resin(T.loc)//This will be an organ eventually, based on the caste.
				T.butchery_progress++
				active = 0
		if(3)
			spawn(50)
				if(CHECK != user.loc)
					usr << "This is difficult, you probably shouldn't move."
					return
				usr << "You scrape out the remaining biomass."
				active = 0
				new /obj/item/XenoBio/Resin(T.loc)
				new /obj/effect/decal/remains/xeno(T.loc)
				cdel(T)






