//Magazine items, and casings.
/*
Boxes of ammo. Certain weapons have internal boxes of ammo that cannot be removed and function as part of the weapon.
They're all essentially identical when it comes to getting the job done.
*/
/obj/item/ammo_magazine
	name = "generic ammo"
	desc = "A box of ammo."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = null
	item_state = "ammo_mag" //PLACEHOLDER. This ensures the mag doesn't use the icon state instead.
	var/bonus_overlay = null //Sprite pointer in ammo.dmi to an overlay to add to the gun, for extended mags, box mags, and so on
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	matter = list("metal" = 1000)
	origin_tech = "combat=2'materials=2" //Low.
	throwforce = 2
	w_class = 1.0
	throw_speed = 2
	throw_range = 6
	var/default_ammo = /datum/ammo/bullet
	var/overcharge_ammo = /datum/ammo/bullet //Generally used for energy weapons
	var/caliber = null // This is used for matching handfuls to each other or whatever the mag is. Examples are" "12g" ".44" ".357" etc.
	var/current_rounds = -1 //Set this to something else for it not to start with different initial counts.
	var/max_rounds = 7 //How many rounds can it hold?
	var/gun_type = null //Path of the gun that it fits. Mags will fit any of the parent guns as well, so make sure you want this.
	var/reload_delay = 1 //Set a timer for reloading mags. Higher is slower.
	var/used_casings = 0 //Just an easier way to track how many shells to eject later.
	var/flags_magazine = AMMUNITION_REFILLABLE //flags specifically for magazines.
	var/base_mag_icon //the default mag icon state.

/obj/item/ammo_magazine/New(loc, spawn_empty)
	..()
	base_mag_icon = icon_state
	if(spawn_empty) current_rounds = 0
	switch(current_rounds)
		if(-1) current_rounds = max_rounds //Fill it up. Anything other than -1 and 0 will just remain so.
		if(0) icon_state += "_e" //In case it spawns empty instead.

/obj/item/ammo_magazine/update_icon(var/round_diff = 0)
	if(current_rounds <= 0) 					icon_state = base_mag_icon + "_e"
	else if(current_rounds - round_diff <= 0) 	icon_state = base_mag_icon

/obj/item/ammo_magazine/examine(mob/user)
	..()
	// It should never have negative ammo after spawn. If it does, we need to know about it.
	if(current_rounds < 0)
		to_chat(user, "Something went horribly wrong. Ahelp the following: ERROR CODE R1: negative current_rounds on examine.")
		log_runtime("ERROR CODE R1: negative current_rounds on examine. User: <b>[usr]</b>")
	else
		to_chat(user, "[src] has <b>[current_rounds]</b> rounds out of <b>[max_rounds]</b>.")


/obj/item/ammo_magazine/attack_hand(mob/user)
	if(flags_magazine & AMMUNITION_REFILLABLE) //actual refillable magazine, not just a handful of bullets or a fuel tank.
		if(src == user.get_inactive_held_item()) //Have to be holding it in the hand.
			if (current_rounds > 0)
				if(create_handful(user))
					return
			else
				to_chat(user, "[src] is empty. Nothing to grab.")
			return
	return ..() //Do normal stuff.

//We should only attack it with handfuls. Empty hand to take out, handful to put back in. Same as normal handful.
/obj/item/ammo_magazine/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/MG = I
		if(MG.flags_magazine & AMMUNITION_HANDFUL) //got a handful of bullets
			if(flags_magazine & AMMUNITION_REFILLABLE) //and a refillable magazine
				var/obj/item/ammo_magazine/handful/transfer_from = I
				if(src == user.get_inactive_held_item() ) //It has to be held.
					if(default_ammo == transfer_from.default_ammo)
						transfer_ammo(transfer_from,user,transfer_from.current_rounds) // This takes care of the rest.
					else
						to_chat(user, "Those aren't the same rounds. Better not mix them up.")
				else
					to_chat(user, "Try holding [src] before you attempt to restock it.")

//Generic proc to transfer ammo between ammo mags. Can work for anything, mags, handfuls, etc.
/obj/item/ammo_magazine/proc/transfer_ammo(obj/item/ammo_magazine/source, mob/user, transfer_amount = 1)
	if(current_rounds == max_rounds) //Does the mag actually need reloading?
		to_chat(user, "[src] is already full.")
		return

	if(source.caliber != caliber) //Are they the same caliber?
		to_chat(user, "The rounds don't match up. Better not mix them up.")
		return

	var/S = min(transfer_amount, max_rounds - current_rounds)
	source.current_rounds -= S
	current_rounds += S
	if(source.current_rounds <= 0 && istype(source, /obj/item/ammo_magazine/handful)) //We want to delete it if it's a handful.
		if(user)
			user.temporarilyRemoveItemFromInventory(source)
		qdel(source) //Dangerous. Can mean future procs break if they reference the source. Have to account for this.
	else source.update_icon()
	update_icon(S)
	return S // We return the number transferred if it was successful.

//This will attempt to place the ammo in the user's hand if possible.
/obj/item/ammo_magazine/proc/create_handful(mob/user, transfer_amount)
	var/R
	if(current_rounds <= 0)
		return

	var/obj/item/ammo_magazine/handful/new_handful = new /obj/item/ammo_magazine/handful()
	var/MR = (caliber in list("12g", "7.62x54mmR")) ? 5 : 8
	R = transfer_amount ? min(current_rounds, transfer_amount) : min(current_rounds, MR)
	new_handful.generate_handful(default_ammo, caliber, MR, R, gun_type)
	current_rounds -= R

	if(user)
		user.put_in_hands(new_handful)
		to_chat(user, "<span class='notice'>You grab <b>[R]</b> round\s from [src].</span>")
		update_icon(-R) //Update the other one.
		return R //Give the number created.
	else
		update_icon(-R)
		return new_handful


//our magazine inherits ammo info from a source magazine
/obj/item/ammo_magazine/proc/match_ammo(obj/item/ammo_magazine/source)
	caliber = source.caliber
	default_ammo = source.default_ammo
	gun_type = source.gun_type

//~Art interjecting here for explosion when using flamer procs.
/obj/item/ammo_magazine/flamer_fire_act()
	switch(current_rounds)
		if(0) return
		if(1 to 100) explosion(loc,  -1, -1, 0, 2) //blow it up.
		else explosion(loc,  -1, -1, 1, 2) //blow it up HARDER
	qdel(src)

//Magazines that actually cannot be removed from the firearm. Functionally the same as the regular thing, but they do have three extra vars.
/obj/item/ammo_magazine/internal
	name = "internal chamber"
	desc = "You should not be able to examine it."
	//For revolvers and shotguns.
	var/list/chamber_contents //What is actually in the chamber. Initiated on New().
	var/chamber_position = 1 //Where the firing pin is located. We usually move this instead of the contents.
	var/chamber_closed = 1 //Starts out closed. Depends on firearm.

//Helper proc, to allow us to see a percentage of how full the magazine is.
/obj/item/ammo_magazine/proc/get_ammo_percent()		// return % charge of cell
	return 100.0*current_rounds/max_rounds

//----------------------------------------------------------------//
//Now for handfuls, which follow their own rules and have some special differences from regular boxes.

/*
Handfuls are generated dynamically and they are never actually loaded into the item.
What they do instead is refill the magazine with ammo and sometime save what sort of
ammo they are in order to use later. The internal magazine for the gun really does the
brunt of the work. This is also far, far better than generating individual items for
bullets/shells. ~N
*/

/obj/item/ammo_magazine/handful
	name = "generic handful of bullets or shells"
	desc = "A handful of rounds to reload on the go."
	matter = list("metal" = 50) //This changes based on the ammo ammount. 5k is the base of one shell/bullet.
	flags_equip_slot = null // It only fits into pockets and such.
	origin_tech = "combat=1'materials=1"
	w_class = 2
	current_rounds = 1 // So it doesn't get autofilled for no reason.
	max_rounds = 5 // For shotguns, though this will be determined by the handful type when generated.
	flags_atom = CONDUCT|DIRLOCK
	flags_magazine = AMMUNITION_HANDFUL
	attack_speed = 3 // should make reloading less painful

/obj/item/ammo_magazine/handful/Destroy()
	..()
	return TA_REVIVE_ME

/obj/item/ammo_magazine/handful/update_icon() //Handles the icon itself as well as some bonus things.
	if(max_rounds >= current_rounds)
		var/I = current_rounds*50 // For the metal.
		matter = list("metal" = I)
		setDir(current_rounds + round(current_rounds/3))


/*
There aren't many ways to interact here.
If the default ammo isn't the same, then you can't do much with it.
If it is the same and the other stack isn't full, transfer an amount (default 1) to the other stack.
*/
/obj/item/ammo_magazine/handful/attackby(obj/item/ammo_magazine/handful/transfer_from, mob/user)
	if(istype(transfer_from)) // We have a handful. They don't need to hold it.
		if(default_ammo == transfer_from.default_ammo) //Has to match.
			transfer_ammo(transfer_from,user, transfer_from.current_rounds) // Transfer it from currently held to src
		else
			to_chat(user, "Those aren't the same rounds. Better not mix them up.")

/obj/item/ammo_magazine/handful/proc/generate_handful(new_ammo, new_caliber, maximum_rounds, new_rounds, new_gun_type)
	var/datum/ammo/A = GLOB.ammo_list[new_ammo]
	var/ammo_name = A.name //Let's pull up the name.

	name = "handful of [ammo_name + (ammo_name == "shotgun buckshot"? " ":"s ") + "([new_caliber])"]"
	icon_state = new_caliber == "12g" ? ammo_name : new_caliber == "7.62x54mmR" ? "mosin bullet" : "bullet" //What am I even doing with my life?
	default_ammo = new_ammo
	caliber = new_caliber
	max_rounds = maximum_rounds
	current_rounds = new_rounds
	gun_type = new_gun_type
	update_icon()

//----------------------------------------------------------------//


/*
Doesn't do anything or hold anything anymore.
Generated per the various mags, and then changed based on the number of
casings. .dir is the main thing that controls the icon. It modifies
the icon_state to look like more casings are hitting the ground.
There are 8 directions, 8 bullets are possible so after that it tries to grab the next
icon_state while reseting the direction. After 16 casings, it just ignores new
ones. At that point there are too many anyway. Shells and bullets leave different
items, so they do not intersect. This is far more efficient than using Blend() or
Turn() or Shift() as there is virtually no overhead. ~N
*/
/obj/item/ammo_casing
	name = "spent casing"
	desc = "Empty and useless now."
	icon = 'icons/obj/items/casings.dmi'
	icon_state = "casing_"
	throwforce = 1
	w_class = 1.0
	layer = LOWER_ITEM_LAYER //Below other objects
	dir = 1 //Always north when it spawns.
	flags_atom = CONDUCT|DIRLOCK
	matter = list("metal" = 8) //tiny amount of metal
	var/current_casings = 1 //This is manipulated in the procs that use these.
	var/max_casings = 16
	var/current_icon = 0
	var/number_of_states = 10 //How many variations of this item there are.

/obj/item/ammo_casing/New()
	..()
	pixel_x = rand(-2.0, 2) //Want to move them just a tad.
	pixel_y = rand(-2.0, 2)
	icon_state += "[rand(1,number_of_states)]" //Set the icon to it.

//This does most of the heavy lifting. It updates the icon and name if needed, then changes .dir to simulate new casings.
/obj/item/ammo_casing/update_icon()
	if(max_casings >= current_casings)
		if(current_casings == 2) name += "s" //In case there is more than one.
		if(round((current_casings-1)/8) > current_icon)
			current_icon++
			icon_state += "_[current_icon]"

		var/I = current_casings*8 // For the metal.
		matter = list("metal" = I)
		var/base_direction = current_casings - (current_icon * 8)
		setDir(base_direction + round(base_direction)/3)
		switch(current_casings)
			if(3 to 5) w_class = 2 //Slightly heavier.
			if(9 to 10) w_class = 3 //Can't put it in your pockets and stuff.


//Making child objects so that locate() and istype() doesn't screw up.
/obj/item/ammo_casing/bullet

/obj/item/ammo_casing/cartridge
	name = "spent cartridge"
	icon_state = "cartridge_"

/obj/item/ammo_casing/shell
	name = "spent shell"
	icon_state = "shell_"




//Big ammo boxes

/obj/item/big_ammo_box
	name = "big ammo box (10x24mm)"
	desc = "A large ammo box. It comes with a leather strap."
	w_class = 5
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "big_ammo_box"
	item_state = "big_ammo_box"
	flags_equip_slot = ITEM_SLOT_BACK
	var/base_icon_state = "big_ammo_box"
	var/default_ammo = /datum/ammo/bullet/rifle
	var/bullet_amount = 600
	var/max_bullet_amount = 600
	var/caliber = "10x24mm"

/obj/item/big_ammo_box/update_icon()
	if(bullet_amount) icon_state = base_icon_state
	else icon_state = "[base_icon_state]_e"

/obj/item/big_ammo_box/examine(mob/user)
	..()
	if(bullet_amount)
		to_chat(user, "It contains [bullet_amount] round\s.")
	else
		to_chat(user, "It's empty.")

/obj/item/big_ammo_box/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/AM = I
		if(!isturf(loc))
			to_chat(user, "<span class='warning'>[src] must be on the ground to be used.</span>")
			return
		if(AM.flags_magazine & AMMUNITION_REFILLABLE)
			if(default_ammo != AM.default_ammo)
				to_chat(user, "<span class='warning'>Those aren't the same rounds. Better not mix them up.</span>")
				return
			if(caliber != AM.caliber)
				to_chat(user, "<span class='warning'>The rounds don't match up. Better not mix them up.</span>")
				return
			if(AM.current_rounds == AM.max_rounds)
				to_chat(user, "<span class='warning'>[AM] is already full.</span>")
				return
			if(!do_after(user,15, TRUE, 5, BUSY_ICON_FRIENDLY))
				return
			playsound(loc, 'sound/weapons/gun_revolver_load3.ogg', 25, 1)
			var/S = min(bullet_amount, AM.max_rounds - AM.current_rounds)
			AM.current_rounds += S
			bullet_amount -= S
			AM.update_icon(S)
			update_icon()
			if(AM.current_rounds == AM.max_rounds)
				to_chat(user, "<span class='notice'>You refill [AM].</span>")
			else
				to_chat(user, "<span class='notice'>You put [S] rounds in [AM].</span>")
		else if(AM.flags_magazine & AMMUNITION_HANDFUL)
			if(caliber != AM.caliber)
				to_chat(user, "<span class='warning'>The rounds don't match up. Better not mix them up.</span>")
				return
			if(bullet_amount == max_bullet_amount)
				to_chat(user, "<span class='warning'>[src] is full!</span>")
				return
			playsound(loc, 'sound/weapons/gun_revolver_load3.ogg', 25, 1)
			var/S = min(AM.current_rounds, max_bullet_amount - bullet_amount)
			AM.current_rounds -= S
			bullet_amount += S
			AM.update_icon()
			to_chat(user, "<span class='notice'>You put [S] rounds in [src].</span>")
			if(AM.current_rounds <= 0)
				user.temporarilyRemoveItemFromInventory(AM)
				qdel(AM)

//explosion when using flamer procs.
/obj/item/big_ammo_box/flamer_fire_act()
	switch(bullet_amount)
		if(0) return
		if(1 to 100) explosion(loc,  0, 0, 1, 2) //blow it up.
		else explosion(loc,  0, 0, 2, 3) //blow it up HARDER
	qdel(src)



//Deployable ammo box
/obj/item/ammobox
	name = "M41A Ammo Box"
	desc = "A large, deployable ammo box."
	w_class = 5
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "ammobox"
	var/magazine_amount = 10
	var/max_magazine_amount = 10
	var/max_magazine_rounds = 40
	var/ammo_type = /datum/ammo/bullet/rifle
	var/magazine_type = /obj/item/ammo_magazine/rifle
	var/deployed = FALSE

/obj/item/ammobox/update_icon()
	if(magazine_amount > 0)
		icon_state = "[initial(icon_state)]_deployed"
	else
		icon_state = "[initial(icon_state)]_empty"

/obj/item/ammobox/examine(mob/user)
	. = ..()
	to_chat(user, "It contains [magazine_amount] out of [max_magazine_amount] magazines.")

/obj/item/ammobox/attackby(obj/item/I, mob/user)
	if(deployed == FALSE)
		to_chat(user, "<span class='warning'>[src] must be deployed on the ground to be refilled.</span>")
		return
	if(!istype(I, /obj/item/ammo_magazine))
		return
	var/obj/item/ammo_magazine/MG = I
	if(!(MG.flags_magazine & AMMUNITION_REFILLABLE))
		return
	if(MG.default_ammo != ammo_type)
		to_chat(user, "<span class='warning'>That's not the right kind of ammo.</span>")
		return
	if(MG.current_rounds != MG.max_rounds)
		to_chat(user, "<span class='warning'>The magazine is not full!</span>")
		return
	if(magazine_amount == max_magazine_amount)
		to_chat(user, "<span class='warning'>The [src] is already full.")
		return
	qdel(user.get_held_item())
	magazine_amount++
	update_icon()

/obj/item/ammobox/attack_hand(mob/user)
	if(deployed == FALSE)
		user.put_in_hands(src)
		return
	if(magazine_amount == 0)
		to_chat(user, "<span class='warning'>The [src] is empty.")
		return
	var/obj/item/ammo_magazine/MG = new magazine_type
	user.put_in_hands(MG)
	magazine_amount--
	update_icon()

/obj/item/ammobox/attack_self(mob/user)
	deployed = TRUE
	update_icon()
	user.drop_held_item(src)

/obj/item/ammobox/MouseDrop(atom/over_object)
	if(deployed == FALSE)
		return
	if(!ishuman(over_object))
		return
	var/mob/living/carbon/human/H = over_object
	if(H == usr && !H.incapacitated() && Adjacent(H) && H.put_in_hands(src))
		icon_state = initial(icon_state)


//Deployable shotgun ammo box
/obj/item/ammo_magazine/shotgunbox
	name = "Slug Ammo Box"
	desc = "A large, deployable ammo box."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "ammoboxslug"
	default_ammo = /datum/ammo/bullet/shotgun/slug
	caliber = "12g"
	gun_type = /obj/item/weapon/gun/shotgun
	max_rounds = 100
	current_rounds = 100
	w_class = 5
	var/base = /obj/item/ammo_magazine/shotgunbox
	var/deployed = FALSE

/obj/item/ammo_magazine/shotgunbox/update_icon()
	if(current_rounds > 0)
		icon_state = "[initial(icon_state)]_deployed"
	else
		icon_state = "[initial(icon_state)]_empty"

/obj/item/ammo_magazine/shotgunbox/attack_self(mob/user)
	deployed = TRUE
	update_icon()
	user.drop_held_item(src)

/obj/item/ammo_magazine/shotgunbox/MouseDrop(atom/over_object)
	if(deployed == FALSE)
		return
	if(!ishuman(over_object))
		return
	var/mob/living/carbon/human/H = over_object
	if(H == usr && !H.incapacitated() && Adjacent(H) && H.put_in_hands(src))
		icon_state = initial(icon_state)

/obj/item/ammo_magazine/shotgunbox/examine(mob/user)
	. = ..()
	to_chat(user, "It contains [current_rounds] out of [max_rounds] shotgun shells.")

/obj/item/ammo_magazine/shotgunbox/attack_hand(mob/user)
	if(deployed == FALSE)
		user.put_in_hands(src)
		return
	if(!(flags_magazine & AMMUNITION_REFILLABLE) || current_rounds < 1)
		to_chat(user, "<span class='warning'>The [src] is empty.")
		return ..()
	if(create_handful(user))
		update_icon()
		return ..()

/obj/item/ammo_magazine/shotgunbox/attackby(obj/item/I, mob/user)
	if(deployed == FALSE)
		to_chat(user, "<span class='warning'>[src] must be on the ground to be refilled.</span>")
		return
	if(!istype(I, /obj/item/ammo_magazine))
		return
	var/obj/item/ammo_magazine/MG = I
	if(!(MG.flags_magazine & AMMUNITION_HANDFUL) || !(flags_magazine & AMMUNITION_REFILLABLE))
		to_chat(user, "<span class='warning'>That's not the right kind of ammo.</span>")
		return
	var/obj/item/ammo_magazine/handful/transfer_from = MG
	if(default_ammo == transfer_from.default_ammo)
		transfer_ammo(transfer_from,user,transfer_from.current_rounds)







/obj/item/big_ammo_box/ap
	name = "big ammo box (10x24mm AP)"
	icon_state = "big_ammo_box_ap"
	base_icon_state = "big_ammo_box_ap"
	default_ammo = /datum/ammo/bullet/rifle/ap
	bullet_amount = 400 //AP is OP
	max_bullet_amount = 400

/obj/item/big_ammo_box/smg
	name = "big ammo box (10x20mm)"
	caliber = "10x20mm"
	icon_state = "big_ammo_box_m39"
	base_icon_state = "big_ammo_box_m39"
	default_ammo = /datum/ammo/bullet/smg


/obj/item/ammobox/ap
	name = "M41A AP Ammo Box"
	icon_state = "ammoboxap"
	ammo_type = /datum/ammo/bullet/rifle/ap
	magazine_type = /obj/item/ammo_magazine/rifle/ap

/obj/item/ammobox/ext
	name = "M41A Extended Ammo Box"
	icon_state = "ammoboxext"
	ammo_type = /datum/ammo/bullet/rifle
	magazine_type = /obj/item/ammo_magazine/rifle/extended

/obj/item/ammobox/m39
	name = "M39 Ammo Box"
	icon_state = "ammoboxm39"
	ammo_type = /datum/ammo/bullet/smg
	magazine_type = /obj/item/ammo_magazine/smg/m39

/obj/item/ammobox/m39ap
	name = "M39 AP Ammo Box"
	icon_state = "ammoboxm39ap"
	ammo_type = /datum/ammo/bullet/smg/ap
	magazine_type = /obj/item/ammo_magazine/smg/m39/ap

/obj/item/ammobox/m39ext
	name = "M39 Extended Ammo Box"
	icon_state = "ammoboxm39ext"
	ammo_type = /datum/ammo/bullet/smg
	magazine_type = /obj/item/ammo_magazine/smg/m39/extended


/obj/item/ammo_magazine/shotgunbox/buckshot
	name = "Buckshot Ammo Box"
	icon_state = "ammoboxbuckshot"
	default_ammo = /datum/ammo/bullet/shotgun/buckshot
	max_rounds = 100
	current_rounds = 100

/obj/item/ammo_magazine/shotgunbox/flechette
	name = "Flechette Ammo Box"
	icon_state = "ammoboxflechette"
	default_ammo = /datum/ammo/bullet/shotgun/flechette
	max_rounds = 100
	current_rounds = 100


/obj/item/ammobox/m4a3
	name = "M4A3 Ammo Box"
	icon_state = "ammoboxm4a3"
	ammo_type = /datum/ammo/bullet/pistol
	magazine_type = /obj/item/ammo_magazine/pistol

/obj/item/ammobox/m4a3ext
	name = "M4A3 Extended Ammo Box"
	icon_state = "ammoboxm4a3ext"
	ammo_type = /datum/ammo/bullet/pistol
	magazine_type = /obj/item/ammo_magazine/pistol/extended

/obj/item/ammobox/m4a3ap
	name = "M4A3 AP Ammo Box"
	icon_state = "ammoboxm4a3ap"
	ammo_type = /datum/ammo/bullet/pistol/ap
	magazine_type = /obj/item/ammo_magazine/pistol/ap