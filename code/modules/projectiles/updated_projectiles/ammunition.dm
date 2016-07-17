//Magazine items, and casings.
/*
Boxes of ammo. Certain weapons have internal boxes of ammo that cannot be removed and function as part of the weapon.
They're all essentially identical when it comes to getting the job done.
*/
/obj/item/ammo_magazine
	name = "generic ammo"
	desc = "A box of ammo"
	icon = 'icons/obj/ammo.dmi'
	icon_state = null
	var/icon_empty = null
	var/icon_type = "bullet" //Used for updating the icon when it creates casings.
	var/bonus_overlay = null //Sprite pointer in ammo.dmi to an overlay to add to the gun, for extended mags, box mags, and so on
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	item_state = ""
	matter = list("metal" = 50000)
	origin_tech = "combat=2'materials=2" //Low.
	throwforce = 2
	w_class = 1.0
	throw_speed = 2
	throw_range = 6
	var/default_ammo = "default bullet"
	var/caliber = null // This is used for matching handfuls to each other or whatever the mag is. Examples are" "12g" ".44" ".357" etc.
	var/current_rounds = -1 //Set this to something else for it not to start with different initial counts.
	var/max_rounds = 7 //How many rounds can it hold?
	var/gun_type = null //Path of the gun that it fits. Ammo will fit any of the parent guns as well.
	var/reload_delay = 1 //Set a timer for reloading mags. Higher is slower.
	var/used_casings = 0 //Just an easier way to track how many shells to eject later.

	//For the handful method of reloading. Not used for regular mags.
	var/handful_type = "Bullets" // "Bullets" or "Shells" or "Slugs" or "Incendiary Slugs"
	var/handful_max_rounds = 8 // Tell a handful of how many rounds to make when it defaults.

	/*
	Current rounds are set to -1 by default.
	When the magazine spawns in with New(), the -1 tell it to fill to full.
	This doesn't honestly make a lot of sense, since you would in most circumstances
	want a fresh mag to start with max_rounds, but this doesn't impact
	anything. You may, potentially, want to have the mag spawn with
	less than full rounds, for scavenging or Hunter Games.
	So I'm leaving it like it is. The check didn't work before for whatever reason,
	but I think it triggers properly now. ~N.
	*/

	New()
		..()
		if(current_rounds == -1) //This actually works now. Amazing.
			current_rounds = max_rounds
		update_icon()

	update_icon()
		if(current_rounds <= 0 && icon_empty) 	icon_state = icon_empty
		else							 		icon_state = initial(icon_state)


	examine()
		..()
		// It should never have negative ammo after spawn. If it does, we need to know about it.
		if(current_rounds < 0) 	usr << "Something went horribly wrong. Ahelp the following: ERROR CODE R1: negative current_rounds on examine."
		else 					usr << "\The [src] has <b>[current_rounds]</b> rounds out of <b>[max_rounds]</b>."


	attack_hand(mob/user as mob)
		if(istype(src,/obj/item/ammo_magazine/shotgun) || istype(src,/obj/item/ammo_magazine/revolver)) //If it's a box of shotgun shells or a speedloader.
			var/obj/item/ammo_magazine/in_hand = user.get_inactive_hand()
			if( in_hand == src ) //Have to be holding it in the hand.
				if (current_rounds > 0)
					create_handful(src,user)
					return
				else user << "\The [src] is empty. Nothing to grab."
		return ..() //Do normal stuff.

	//We should only attack it with handfuls. Empty hand to take out, handful to put back in. Same as normal handful.
	attackby(var/obj/item/ammo_magazine/handful/transfer_from, mob/user)
		if(istype(src,/obj/item/ammo_magazine/shotgun) || istype(src,/obj/item/ammo_magazine/revolver)) //Same deal.
			if(istype(transfer_from)) // We have a handful.
				var/obj/item/ammo_magazine/in_hand = user.get_inactive_hand()
				if( in_hand == src ) //It has to be held.
					if(default_ammo == transfer_from.default_ammo)
						transfer_ammo(transfer_from,src,user,transfer_from.current_rounds) // This takes care of the rest.
					else user << "Those aren't the same rounds. Better not mix them up."
				else user << "Try holding \the [src] before you attempt to restock it."

//Generic proc to transfer ammo between ammo mags. Can work for anything, mags, handfuls, etc.
/obj/item/ammo_magazine/proc/transfer_ammo(var/obj/item/ammo_magazine/source,var/obj/item/ammo_magazine/target,mob/user,transfer_amount = 1)
	if( target.current_rounds == target.max_rounds ) //Does the target mag actually need reloading?
		user << "\The [target] is already full."
		return

	if(source.caliber != target.caliber) //Are they the same caliber?
		user << "The rounds don't match up. Better not mix them up."
		return

	var/S = min(transfer_amount, target.max_rounds - target.current_rounds)
	source.current_rounds -= S
	target.current_rounds += S
	if(source.current_rounds <= 0 && istype(source, /obj/item/ammo_magazine/handful)) //We want to delete it if it's a handful.
		if(user)
			user.remove_from_mob(source)
			user.update_inv_l_hand(0) //In case we will get in hand icons.
			user.update_inv_r_hand()
		cdel(source) //Dangerous. Can mean future procs break if they reference the source. Have to account for this.
	else source.update_icon()
	target.update_icon()
	return S // We return the number transferred if it was successful.

//This will attempt to place the ammo in the user's hand if possible.
/obj/item/ammo_magazine/proc/create_handful(var/obj/item/ammo_magazine/source, mob/user, transfer_amount)
	var/S
	if (source.current_rounds > 0)
		var/obj/item/ammo_magazine/handful/new_handful = rnew(/obj/item/ammo_magazine/handful)
		new_handful.name = "Handful of [source.handful_type]"
		new_handful.desc = "A handful of rounds to reload on the go."
		new_handful.icon_state = source.icon_type
		new_handful.caliber = source.caliber
		new_handful.max_rounds = source.handful_max_rounds
		S = transfer_amount ? min(source.current_rounds, transfer_amount) : min(source.current_rounds, new_handful.max_rounds)
		new_handful.current_rounds = S
		new_handful.default_ammo = source.default_ammo
		new_handful.icon_type = source.icon_type
		new_handful.gun_type = source.gun_type
		new_handful.handful_type = source.handful_type
		new_handful.update_icon() // Let's get it updated.

		current_rounds -= S

		if(user)
			user.put_in_hands(new_handful)
			user << "<span class='notice'>You grab <b>[S]</b> round\s from \the [source].</span>"

		else new_handful.loc = get_turf(src)
		source.update_icon() //Update the other one.
	return S //Give the number created.

/obj/item/ammo_magazine/proc/match_ammo(var/obj/item/ammo_magazine/source,var/obj/item/ammo_magazine/target)
	target.caliber = source.caliber
	target.default_ammo = source.default_ammo
	target.gun_type = source.gun_type
	target.handful_type = source.handful_type

//Magazines that actually cannot be removed from the firearm. Functionally the same as the regular thing, but they do have three extra vars.
/obj/item/ammo_magazine/internal
	name = "Internal Chamber"
	desc = "You should not be able to examine it."
	//For revolvers and shotguns.
	var/chamber_contents[] //What is actually in the chamber. Initiated on New().
	var/chamber_position = 1 //Where the firing pin is located. We usually move this instead of the contents.
	var/chamber_closed = 1 //Starts out closed. Depends on firearm.

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
	name = "generic handful"
	desc = "A handful of ammunition."
	matter = list("metal" = 5000) //This changes based on the ammo ammount. 5k is the base of one shell/bullet.
	slot_flags = null // It only fits into pockets and such.
	origin_tech = "combat=1'materials=1"
	current_rounds = 1 // So it doesn't get autofilled for no reason.
	max_rounds = 5 // For shotguns, though this will be determined by the handful type when generated.

	Dispose()
		..()
		return TA_REVIVE_ME

	Recycle()
		var/blacklist[] = list("name","desc","icon_state","caliber","caliber_type","max_rounds","current_rounds","default_ammo","icon_type","gun_type","handful_type")
		. = ..() + blacklist

	update_icon() //Handles the icon itself as well as some bonus things.
		var/I = current_rounds*5000 // For the metal.
		matter = list("metal" = I)
		switch(current_rounds)
			if(1,2) dir = current_rounds
			if(3,4,5) dir = current_rounds+1
			if(6,7,8) dir = current_rounds+2
			if(9,10) dir = current_rounds-8
			if(11,12,13) dir = current_rounds-7
			if(14,15,16) dir = current_rounds-6
		return

	/*
	There aren't many ways to interact here.
	If the default ammo isn't the same, then you can't do much with it.
	If it is the same and the other stack isn't full, transfer an amount (default 1) to the other stack.
	*/
	attackby(var/obj/item/ammo_magazine/handful/transfer_from, mob/user as mob)
		if(istype(transfer_from)) // We have a handful. They don't need to hold it.
			if(default_ammo == transfer_from.default_ammo) //Has to match.
				transfer_ammo(transfer_from,src,user) // Transfer it from currently held to src, this item, message user.
			else user << "Those aren't the same rounds. Better not mix them up."

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
	icon = 'icons/obj/ammo.dmi'
	icon_state = "casing_"
	flags = FPRINT | TABLEPASS | CONDUCT
	throwforce = 1
	w_class = 1.0
	layer = OBJ_LAYER - 0.1 //Below other objects but above weeds.
	dir = 1 //Always north when it spawns.
	var/casings = 1 //This is manipulated in the procs that use these.
	var/casing_pile = 0
	var/current_icon = 0
	var/current_state = 1
	var/number_of_states = 5 //How many variations of this item there are.

	New()
		..()
		pixel_x = rand(-2.0, 2) //Want to move them just a tad.
		pixel_y = rand(-2.0, 2)
		var/current_state = rand(1,number_of_states) //We pick one of these.
		icon_state += "[current_state]" //Set the icon to it.

	//This does most of the heavy lifting. It updates the icon and name if needed, then changes .dir to simulate new casings.
	update_icon()
		if(casings>1 && !casing_pile)
			name += "s" //In case there is more than one.
			casing_pile = !casing_pile
		if(casings>8 && current_icon < 1) //More than 8 casings, but the icon hasn't been switched.
			icon_state += "_a" //Can make a switch if more are added. But over 16 is a lot.
			current_icon = 1 //So I don't have to check for names and stuff. Icon switched.

		switch(casings) //This is how we get the actual icon to show. It's a switch, so it's hilariously fast.
			if(1,2) dir = casings
			if(3,4,5)
				dir = casings+1
				w_class = 2 //Slightly heavier.
			if(6,7,8) dir = casings+2
			if(9,10)
				dir = casings-8
				w_class = 3 //Can't put it in your pockets and stuff.
			if(11,12,13) dir = casings-7
			if(14,15,16) dir = casings-6

//Making child objects so that locate() and istype() doesn't screw up.
/obj/item/ammo_casing/bullet

/obj/item/ammo_casing/shell
	name = "spent shell"
	icon_state = "shell_"
	number_of_states = 5