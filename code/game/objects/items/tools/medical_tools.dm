
//CELLS here
/obj/item/tool/geltool/gell  //Gell a CELL but GELL
	name = "Gell classic"
	desc = "A vial used to transport and store medical gel, NOT EDIBLE."
	icon_state = "gell"
	item_state = "gell"
	icon = 'icons/obj/items/geltools.dmi'
	var/gelcapacity = 840   //how much gel can you fit in this tool, THIS NUMBER WAS CHOSEN FOR ITS DIVISIBILITY
	var/gelquantity = 840   //how much gel does it starts with
	w_class = WEIGHT_CLASS_SMALL

/obj/item/tool/geltool/gell/small
	name = "Gell tiny"
	desc = "A vial used to transport and store medical gel, NOT EDIBLE."
	icon_state = "gelltiny"
	item_state = "gelltiny"
	gelcapacity = 280
	gelquantity = 280
	w_class = WEIGHT_CLASS_TINY


/obj/item/tool/geltool/gell/attack(mob/living/M, mob/living/user)
	if(M != user)
		return ..()
	if(gelquantity => 35)
	user.visible_message("[user] sucks on \the [src].",
	"You suck on \the [src].")
	gelquantity -= 35 // 8 sucks should suffice them without killing them

	playsound(loc, 'sound/voice/alien_drool2.ogg', 30, 1)
	playsound(loc, 'sound/voice/skeleton_warcry.ogg', 10,1,1)
	M.adjustFireLoss(10) // add a little bit of Burn damage
	M.adjustToxLoss(5) // and tox for good measure
	M.disabilities |= MUTE
	addtimer(VARSET_CALLBACK(M, disabilities, M.disabilities & ~MUTE), 30 SECONDS)
	to_chat(user, "you feel a acid taste in your mouth, as your lips tighten up</span>")
	update_icon()

/obj/item/tool/geltool/gell/examine(mob/user)
	..()
	to_chat(user, "the gel gauge measures. <b>Gel quantity: [gelquantity]/[gelcapacity]</b>")
	update_icon()

/obj/item/tool/geltool/gell/update_icon()
	..()
	if(gelquantity <= 0)
		icon_state = "[initial(icon_state)]0"
	else
		var/charges = round(gelquantity/(gelcapacity/6))
		icon_state = "[initial(icon_state)][charges]"

/obj/item/tool/geltool/gell/afterattack(obj/item/I, mob/user)
	. = ..()
	if(!istype(I, /obj/machinery/vending/nanomed || /obj/machinery/vending/MarineMed))
		return

	gelquantity = gelcapacity
	playsound(loc, 'sound/machines/hydraulics_1.ogg', 5, 1)
	playsound(loc, 'sound/machines/switch.ogg', 50, 1)
	to_chat(user, "<span class='warning'>You refill the [src]!</span>")
	update_icon()

//define for its TOOLs
/obj/item/tool/geltool/gadget
	name = "Medical gel based tool"
	desc = "You shouldn't be holding this! give to high command and let them know how you got it."
	icon_state = "synthkitoff"
	item_state = "synthkitoff"
	flags_atom = CONDUCT
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/items/geltools.dmi'
	attack_speed = 11 //same as surgery tools for convenience, yet we SHOULDN't need to worry about people beating others with it
	materials = list(/datum/material/metal = 5000, /datum/material/glass = 2500)//i mean scrap if you want. but thats gonna be a waste for sure
	var/gelefficiency = 28  //how much gel it uses per application, 28 here will provide 30 uses by default
	var/obj/item/tool/geltool/gell/cell //Starts with a gell cell

/obj/item/tool/geltool/gadget/Initialize()
	. = ..()
	cell = new /obj/item/tool/geltool/gell()

/obj/item/tool/geltool/gadget/update_icon(mob/user,silent=FALSE)
	..()
	if(!cell || cell.gelquantity <= 0)
		item_state = "synthkitoff"
		playsound(loc, 'sound/weapons/guns/misc/empty_alarm.ogg', 25, 1)
		to_chat(user, "<span class='warning'>The tool beeps as it runs out of gel!</span>")
		return

/obj/item/tool/geltool/gadget/proc/gel_use(M = 1)  //change the M if you want to further modify the efficient of a specific procedure
	cell.gelquantity -= gelefficiency * M
	usr.visible_message(,"<span class='notice'>the [src] used up [gelefficiency * M] gel in this procedure [cell.gelquantity] left.</span>")

/obj/item/tool/geltool/gadget/attack_hand(mob/living/user)
	if(user.get_inactive_held_item() != src)
		return ..()
	if(!cell)
		return ..()
	cell.update_icon()
	user.put_in_active_hand(cell)
	cell = null
	playsound(user, 'sound/machines/click.ogg', 25, 1, 5)
	playsound(user, 'sound/weapons/guns/interact/flamethrower_unload.ogg', 12, 2, 5)
	to_chat(user, "<span class='notice'>You remove the Gell from [src].</span>")
	update_icon(user)
	return TRUE

/obj/item/tool/geltool/gadget/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/geltool/gell))
		if(!user.drop_held_item())
			return
		I.forceMove(src)
		var/replace_install = "You replace the gell in [src]"
		if(!cell)
			replace_install = "You install a gell in [src]"
		else
			cell.update_icon()
			user.put_in_hands(cell)
		cell = I
		to_chat(user, "<span class='notice'>[replace_install] <b>Gel quantity: [cell.gelquantity]/[cell.gelcapacity]</b></span>")
		playsound(user, 'sound/weapons/guns/interact/rifle_reload.ogg', 25, 1, 5)
		playsound(user, 'sound/weapons/guns/interact/flamethrower_unload.ogg', 12, 2, 5)
		update_icon()

// TOOLS down here
/obj/item/tool/geltool/gadget/kitprinter
	name = "Synthetic trauma kit"
	desc = "A tool that utilizes gel. to act as brute or a burn advanced kit. it have a level to toggle its mode"
	icon_state = "synthkitbrute"
	item_state = "synthkitbrute"
	var/brute = TRUE
	var/heal_rate = 1.5 //yes better than advanced kits
	gelefficiency = 56 //same as 5 kits with small cell. same 15 with regular cell

/obj/item/tool/geltool/gadget/kitprinter/update_icon()
	..()
	if(!cell || cell.gelquantity <= 0)
		icon_state = "synthkitoff"
		return
	if(brute)
		icon_state = "synthkitbrute"
		return
	icon_state = "synthkitburn"


/obj/item/tool/geltool/gadget/kitprinter/proc/update_kitprinter(mob/user, silent=FALSE)
	if(!cell || cell.gelquantity <= 0)
		icon_state = "synthkitoff"
		playsound(loc, 'sound/weapons/saberoff.ogg', 0.25, 1, 2)
		playsound(loc, 'sound/weapons/guns/misc/empty_alarm.ogg', 25, 1)
		to_chat(user, "<span class='warning'>The tool beeps as it runs out of gel!</span>")
		return

	update_icon()

/obj/item/tool/geltool/gadget/kitprinter/examine(mob/user)
	..()
	if(cell)
		to_chat(user, "the gel gauge measures. <b>Gel quantity: [cell.gelquantity]/[cell.gelcapacity]</b>")
	else
		to_chat(user, "<span class='warning'>It does not have a gel vial in it!</span>")

/obj/item/tool/geltool/gadget/kitprinter/attack_self(mob/user)
	toggle(user)

/obj/item/tool/geltool/gadget/kitprinter/proc/toggle(mob/user, silent)
	if(brute)
		brute = FALSE
		playsound(loc, 'sound/machines/computer_typing1.ogg', 5)
		playsound(loc, 'sound/machines/terminal_on.ogg', 15)  //maybe placehold. maybe it will be left as this. but sure its better than a bland click
		if(!silent && user)
			user.visible_message("<span class='notice'>[user] turns [src] burn mode.</span>",
		"<span class='notice'>You switch [src] lever to Burn.<b>Gel gauge reads: [cell.gelquantity]/[cell.gelcapacity]</b></span>")
		update_kitprinter()
		return

	if(!brute)
		brute = TRUE
		playsound(loc, 'sound/machines/computer_typing1.ogg', 15)
		playsound(loc, 'sound/machines/terminal_on.ogg', 5 , 1) //maybe placehold. maybe it will be left as this. but sure its better than a bland click
		if(!silent && user)
			user.visible_message("<span class='notice'>[user] turns [src] burn mode.</span>",
		"<span class='notice'>You switch [src] lever to Brute.<b>Gel gauge reads: [cell.gelquantity]/[cell.gelcapacity]</b></span>")
		update_kitprinter()
		return

/obj/item/tool/geltool/gadget/kitprinter/attack(mob/living/carbon/M as mob, mob/user as mob)

	if(!cell || cell.gelquantity < gelefficiency)
		to_chat(user, "<span class='warning'>The [src] is out of gel.</span>")
		return

	if (!ishuman(M))
		return

	var/mob/living/carbon/human/H = M
	var/datum/limb/affecting = user.client.prefs.toggles_gameplay & RADIAL_MEDICAL ? radial_medical(H, user) : H.get_limb(user.zone_selected)

	if(!affecting)
		return TRUE

	if(affecting.surgery_open_stage != 0)
		to_chat(user, "<span class='warning'>Close the incision before using a [src].</span>")
		return

	var/bandaged = affecting.bandage()
	var/disinfected = affecting.disinfect()
	var/heal_amt = heal_rate
	var/datum/wound/W = affecting.wounds

	if(brute)
		if(user.skills.getRating("medical") < SKILL_MEDICAL_PRACTICED) //untrained marines have a hard time using it
			to_chat(user, "<span class='warning'>You start fumbling with [src].</span>")
			if(!do_mob(user, M, 6 SECONDS, BUSY_ICON_UNSKILLED, BUSY_ICON_MEDICAL)) //yes 2x the advanced pack
				return

		if(!(bandaged || disinfected))
			to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.display_name] have already been treated.</span>")
			return

		user.visible_message("<span class='notice'>[user] applies the printkit on [W.desc] on [M]'s [affecting.display_name].</span>",
		"<span class='notice'>You pressure the printer against [W.desc] on [M]'s [affecting.display_name].</span>")
		if(bandaged)
			affecting.heal_limb_damage(heal_amt, updating_health = TRUE)
		gel_use()
		return

	if(!brute)
		if(user.skills.getRating("medical") < SKILL_MEDICAL_PRACTICED) //untrained marines have a hard time using it
			to_chat(user, "<span class='warning'>You start fumbling with [src].</span>")
			if(!do_mob(user, M, 6 SECONDS, BUSY_ICON_UNSKILLED, BUSY_ICON_MEDICAL)) //yes 2x the advanced pack
				return

		if(!(bandaged || disinfected))
			to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.display_name] have already been treated.</span>")
			return

		user.visible_message("<span class='notice'>[user] applies the printkit on [W.desc] on [M]'s [affecting.display_name].</span>",
		"<span class='notice'>You pressure the printer against [W.desc] on [M]'s [affecting.display_name].</span>")
		if(bandaged)
			affecting.heal_limb_damage(heal_amt, updating_health = TRUE)
		gel_use()
		return
