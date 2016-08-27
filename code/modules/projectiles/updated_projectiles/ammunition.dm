//Magazine items, and casings.
/*
Boxes of ammo. Certain weapons have internal boxes of ammo that cannot be removed and function as part of the weapon.
They're all essentially identical when it comes to getting the job done.
*/
/obj/item/ammo_magazine
	name = "generic ammo"
	desc = "A box of ammo."
	icon = 'icons/obj/ammo.dmi'
	icon_state = null
	item_state = "ammo_mag" //PLACEHOLDER. This ensures the mag doesn't use the icon state instead.
	var/bonus_overlay = null //Sprite pointer in ammo.dmi to an overlay to add to the gun, for extended mags, box mags, and so on
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_BELT
	matter = list("metal" = 50000)
	origin_tech = "combat=2'materials=2" //Low.
	throwforce = 2
	w_class = 1.0
	throw_speed = 2
	throw_range = 6
	var/default_ammo = /datum/ammo/bullet
	var/caliber = null // This is used for matching handfuls to each other or whatever the mag is. Examples are" "12g" ".44" ".357" etc.
	var/current_rounds = -1 //Set this to something else for it not to start with different initial counts.
	var/max_rounds = 7 //How many rounds can it hold?
	var/gun_type = null //Path of the gun that it fits. Mags will fit any of the parent guns as well, so make sure you want this.
	var/reload_delay = 1 //Set a timer for reloading mags. Higher is slower.
	var/used_casings = 0 //Just an easier way to track how many shells to eject later.

	New(loc, spawn_empty)
		..()
		if(spawn_empty) current_rounds = 0
		switch(current_rounds)
			if(-1) current_rounds = max_rounds //Fill it up. Anything other than -1 and 0 will just remain so.
			if(0) icon_state += "_e" //In case it spawns empty instead.

	update_icon(var/round_diff = 0)
		if(current_rounds <= 0) 					icon_state += "_e" //Is it zero? Then it's empty.
		else if(current_rounds - round_diff <= 0) 	icon_state  = copytext(icon_state,1,-2) //Did we add ammo to an empty?

	examine()
		..()
		// It should never have negative ammo after spawn. If it does, we need to know about it.
		if(current_rounds < 0)
			usr<< "Something went horribly wrong. Ahelp the following: ERROR CODE R1: negative current_rounds on examine."
			log_debug("ERROR CODE R1: negative current_rounds on examine. User: <b>[usr]</b>")
		else
			usr << "[src] has <b>[current_rounds]</b> rounds out of <b>[max_rounds]</b>."


	attack_hand(mob/user as mob)
		if(istype(src,/obj/item/ammo_magazine/shotgun) || istype(src,/obj/item/ammo_magazine/revolver)) //If it's a box of shotgun shells or a speedloader.
			var/obj/item/ammo_magazine/in_hand = user.get_inactive_hand()
			if( in_hand == src ) //Have to be holding it in the hand.
				if (current_rounds > 0)
					create_handful(user)
					return
				else user << "[src] is empty. Nothing to grab."
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
				else user << "Try holding [src] before you attempt to restock it."

//Generic proc to transfer ammo between ammo mags. Can work for anything, mags, handfuls, etc.
/obj/item/ammo_magazine/proc/transfer_ammo(var/obj/item/ammo_magazine/source,var/obj/item/ammo_magazine/target,mob/user,transfer_amount = 1)
	if( target.current_rounds == target.max_rounds ) //Does the target mag actually need reloading?
		user << "[target] is already full."
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
	target.update_icon(S)
	return S // We return the number transferred if it was successful.

//This will attempt to place the ammo in the user's hand if possible.
/obj/item/ammo_magazine/proc/create_handful(mob/user, transfer_amount)
	var/R
	if (current_rounds > 0)
		var/obj/item/ammo_magazine/handful/new_handful = rnew(/obj/item/ammo_magazine/handful)
		var/MR = caliber == "12g" ? 5 : 8
		R = transfer_amount ? min(current_rounds, transfer_amount) : min(current_rounds, MR)
		new_handful.generate_handful(default_ammo, caliber, MR, R, gun_type)
		current_rounds -= R

		if(user)
			user.put_in_hands(new_handful)
			user << "<span class='notice'>You grab <b>[R]</b> round\s from [src].</span>"

		else new_handful.loc = get_turf(src)
		update_icon(-R) //Update the other one.
	return R //Give the number created.

/obj/item/ammo_magazine/proc/match_ammo(var/obj/item/ammo_magazine/source,var/obj/item/ammo_magazine/target)
	target.caliber = source.caliber
	target.default_ammo = source.default_ammo
	target.gun_type = source.gun_type

//Magazines that actually cannot be removed from the firearm. Functionally the same as the regular thing, but they do have three extra vars.
/obj/item/ammo_magazine/internal
	name = "internal chamber"
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
	desc = "A handful of rounds to reload on the go."
	matter = list("metal" = 5000) //This changes based on the ammo ammount. 5k is the base of one shell/bullet.
	flags_equip_slot = null // It only fits into pockets and such.
	origin_tech = "combat=1'materials=1"
	current_rounds = 1 // So it doesn't get autofilled for no reason.
	max_rounds = 5 // For shotguns, though this will be determined by the handful type when generated.
	flags_atom = FPRINT|CONDUCT|DIRLOCK

	Dispose()
		..()
		return TA_REVIVE_ME

	Recycle()
		var/blacklist[] = list("name","desc","icon_state","caliber","max_rounds","current_rounds","default_ammo","icon_type","gun_type")
		. = ..() + blacklist

	update_icon() //Handles the icon itself as well as some bonus things.
		if(max_rounds >= current_rounds)
			var/I = current_rounds*5000 // For the metal.
			matter = list("metal" = I)
			dir = current_rounds + round(current_rounds/3)

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

/obj/item/ammo_magazine/handful/proc/generate_handful(new_ammo, new_caliber, maximum_rounds, new_rounds, new_gun_type)
	var/datum/ammo/A = ammo_list[new_ammo]
	var/ammo_name = A.name //Let's pull up the name.

	name = "handful of [ammo_name + (ammo_name == "shotgun buckshot"? " ":"s ") + "([new_caliber])"]"
	icon_state = new_caliber == "12g" ? ammo_name : "bullet"
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
	icon = 'icons/obj/casings.dmi'
	icon_state = "casing_"
	throwforce = 1
	w_class = 1.0
	layer = OBJ_LAYER - 0.1 //Below other objects but above weeds.
	dir = 1 //Always north when it spawns.
	flags_atom = FPRINT|CONDUCT|DIRLOCK
	var/current_casings = 1 //This is manipulated in the procs that use these.
	var/max_casings = 16
	var/current_icon = 0
	var/number_of_states = 10 //How many variations of this item there are.

	New()
		..()
		pixel_x = rand(-2.0, 2) //Want to move them just a tad.
		pixel_y = rand(-2.0, 2)
		icon_state += "[rand(1,number_of_states)]" //Set the icon to it.

	//This does most of the heavy lifting. It updates the icon and name if needed, then changes .dir to simulate new casings.
	update_icon()
		if(max_casings >= current_casings)
			if(current_casings == 2) name += "s" //In case there is more than one.
			if(round((current_casings-1)/8) > current_icon)
				current_icon++
				icon_state += "_[current_icon]"

			var/base_direction = current_casings - (current_icon * 8)
			dir = base_direction + round(base_direction)/3
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