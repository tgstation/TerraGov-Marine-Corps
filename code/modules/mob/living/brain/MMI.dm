//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	icon = 'icons/obj/items/assemblies.dmi'
	icon_state = "mmi_empty"
	w_class = 3
	origin_tech = "biotech=3"

	var/list/construction_cost = list("metal"=1000,"glass"=500)
	var/construction_time = 75
	//these vars are so the mecha fabricator doesn't shit itself anymore. --NEO

	req_access = list(ACCESS_MARINE_RESEARCH)

	//Revised. Brainmob is now contained directly within object of transfer. MMI in this case.

	var/locked = 0
	var/mob/living/brain/brainmob = null//The current occupant.
	var/mob/living/silicon/robot = null//Appears unused.
	var/obj/mecha = null//This does not appear to be used outside of reference in mecha.dm.

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if(istype(O,/obj/item/organ/brain) && !brainmob) //Time to stick a brain in it --NEO

			var/obj/item/organ/brain/B = O
			if(B.obj_integrity <= 0)
				to_chat(user, "<span class='warning'>That brain is well and truly dead.</span>")
				return
			else if(!B.brainmob)
				to_chat(user, "<span class='warning'>You aren't sure where this brain came from, but you're pretty sure it's a useless brain.</span>")
				return

			for(var/mob/V in viewers(src, null))
				V.show_message(text("<span class='notice'> [user] sticks \a [O] into \the [src].</span>"))

			brainmob = O:brainmob
			O:brainmob = null
			brainmob.loc = src
			brainmob.container = src
			brainmob.stat = 0
			GLOB.dead_mob_list -= brainmob//Update dem lists
			GLOB.alive_mob_list += brainmob

			user.drop_held_item()
			qdel(O)

			name = "Man-Machine Interface: [brainmob.real_name]"
			icon_state = "mmi_full"

			locked = 1

			return

		if(istype(O,/obj/item/card/id) && brainmob)
			if(allowed(user))
				locked = !locked
				to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] the brain holder.</span>")
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")
			return
		if(brainmob)
			O.attack(brainmob, user)//Oh noooeeeee
			return
		..()

	//TODO: ORGAN REMOVAL UPDATE. Make the brain remain in the MMI so it doesn't lose organ data.
	attack_self(mob/user as mob)
		if(!brainmob)
			to_chat(user, "<span class='warning'>You upend the MMI, but there's nothing in it.</span>")
		else if(locked)
			to_chat(user, "<span class='warning'>You upend the MMI, but the brain is clamped into place.</span>")
		else
			to_chat(user, "<span class='notice'>You upend the MMI, spilling the brain onto the floor.</span>")
			var/obj/item/organ/brain/brain = new(user.loc)
			brainmob.container = null//Reset brainmob mmi var.
			brainmob.loc = brain//Throw mob into brain.
			GLOB.alive_mob_list -= brainmob//Get outta here
			brain.brainmob = brainmob//Set the brain to use the brainmob
			brainmob = null//Set mmi brainmob var to null

			icon_state = "mmi_empty"
			name = "Man-Machine Interface"

	proc
		transfer_identity(var/mob/living/carbon/human/H)//Same deal as the regular brain proc. Used for human-->robot people.
			brainmob = new(src)
			brainmob.name = H.real_name
			brainmob.real_name = H.real_name
			brainmob.container = src

			name = "Man-Machine Interface: [brainmob.real_name]"
			icon_state = "mmi_full"
			locked = 1
			return

/obj/item/mmi/radio_enabled
	name = "Radio-enabled Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity. This one comes with a built-in radio."
	origin_tech = "biotech=4"

	var/obj/item/radio/radio = null//Let's give it a radio.

	New()
		..()
		radio = new(src)//Spawns a radio inside the MMI.
		radio.broadcasting = 1//So it's broadcasting from the start.

	verb//Allows the brain to toggle the radio functions.
		Toggle_Broadcasting()
			set name = "Toggle Broadcasting"
			set desc = "Toggle broadcasting channel on or off."
			set category = "MMI"
			set src = usr.loc//In user location, or in MMI in this case.
			set popup_menu = 0//Will not appear when right clicking.

			if(brainmob.stat)//Only the brainmob will trigger these so no further check is necessary.
				to_chat(brainmob, "Can't do that while incapacitated or dead.")

			radio.broadcasting = radio.broadcasting==1 ? 0 : 1
			to_chat(brainmob, "<span class='notice'>Radio is [radio.broadcasting==1 ? "now" : "no longer"] broadcasting.</span>")

		Toggle_Listening()
			set name = "Toggle Listening"
			set desc = "Toggle listening channel on or off."
			set category = "MMI"
			set src = usr.loc
			set popup_menu = 0

			if(brainmob.stat)
				to_chat(brainmob, "Can't do that while incapacitated or dead.")

			radio.listening = radio.listening==1 ? 0 : 1
			to_chat(brainmob, "<span class='notice'>Radio is [radio.listening==1 ? "now" : "no longer"] receiving broadcast.</span>")

/obj/item/mmi/emp_act(severity)
	if(!brainmob)
		return
	else
		switch(severity)
			if(1)
				brainmob.emp_damage += rand(20,30)
			if(2)
				brainmob.emp_damage += rand(10,20)
			if(3)
				brainmob.emp_damage += rand(0,10)
	..()
