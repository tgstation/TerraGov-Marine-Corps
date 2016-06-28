//Ammo datums, magazine items, and casings.
/datum/ammo
	var/name = "generic bullet"

	var/obj/item/current_gun = null //Where's our home base?

	var/stun = 0
	var/weaken = 0
	var/paralyze = 0
	var/irradiate = 0
	var/stutter = 0
	var/eyeblur = 0
	var/drowsy = 0
	var/agony = 0
	var/skips_marines = 0
	var/skips_xenos = 0
	var/accuracy = 0

	var/damage = 0
	var/damage_type = BRUTE

	var/armor_pen = 0
	var/incendiary = 0
	var/silenced = 0
	var/shrapnel_chance = 0
	var/icon = 'icons/obj/projectiles.dmi'
	var/icon_state = "bullet"
	var/effect_type = "bullet" //For shotguns shooting different ammo types. Can be used elsewhere too.
	var/ping = "ping_b" //The icon that is displayed when the bullet bounces off something.
	var/ignores_armor = 0 //Use this on tasers, not on bullets. Use armor pen for that.

	var/max_range = 30 //This will de-increment a counter on the bullet.
	var/accurate_range = 7 //After this distance, accuracy suffers badly unless zoomed.
	var/damage_bleed = 1 //How much damage the bullet loses per turf traveled, very high for shotguns. //Not anymore ~N.
	var/shell_speed = 1 //This is the default projectile speed: x turfs per 1 second.
	var/bonus_projectiles = 0 //Seems to be only set for buckshot, and not actually used. I might need to take a look into this. ~N
	var/never_scatters = 0 //Never wanders

	proc/do_at_half_range(var/obj/item/projectile/P)
		return

	proc/do_at_max_range(var/obj/item/projectile/P)
		return

	proc/on_shield_block(var/mob/M, var/obj/item/projectile/P) //Does it do something special when shield blocked? Ie. a flare or grenade that still blows up.
		return

	proc/on_hit_turf(var/turf/T, var/obj/item/projectile/P) //Special effects when hitting dense turfs.
		return

	proc/on_hit_mob(var/mob/M, var/obj/item/projectile/P) //Special effects when hitting mobs.
		return

	proc/on_hit_obj(var/obj/O, var/obj/item/projectile/P) //Special effects when hitting objects.
		return

	proc/knockback(var/mob/M,var/obj/item/projectile/P)
		if(!M || M == P.firer) return

		if(P.distance_travelled > 2) shake_camera(M, 2, 1) //Two tiles away or more, basically.

		else //One tile away or less.
			shake_camera(M, 3, 4)
			if(istype(M,/mob/living))
				if(istype(M,/mob/living/carbon/Xenomorph))
					var/mob/living/carbon/Xenomorph/target = M
					if(target.big_xeno) return //Big xenos are not affected.
					target.apply_effects(0,1) //Smaller ones just get shaken.
					target << "\red You are shaken by the sudden impact!"
				else
					var/mob/living/target = M
					target.apply_effects(2,2) //Humans get stunned a bit.
					target << "\red The blast knocks you off your feet!"
			step_away(M,P)

	proc/burst(var/atom/target,var/obj/item/projectile/P,var/message = "buckshot")
		if(!target) return

		for(var/mob/living/carbon/M in range(1,target))
			if(P.firer == M)
				continue
			M.visible_message("\red [M] is hit by [message]!","\red You are hit by </b>[message]</b>!")
			M.apply_damage(rand(5,25),BRUTE)

/*
Boxes of ammo. Certain weapons have internal boxes of ammo that cannot be removed and function as part of the weapon.
They're all essentially identical when it comes to getting the job done.
*/
/obj/item/ammo_magazine
	name = "generic ammo"
	desc = "A box of ammo"
	icon = 'icons/obj/ammo.dmi'
	icon_state = ""
	var/icon_empty = ""
	var/icon_spent = "casing" //The sort of casing it leaves behind.
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	item_state = ""
	matter = list("metal" = 50000)
	origin_tech = "combat=2'materials=2" //Low.
	throwforce = 2
	w_class = 1.0
	throw_speed = 2
	throw_range = 6
	var/default_ammo = "/datum/ammo"
	var/caliber = ".44" // This is used for matching handfuls to each other or whatever the mag is. Examples are" "12g" ".44" ".357" etc.
	var/caliber_type = "bullet" //What the actual thing is. Used by shotguns to determine what to fire.
	var/max_rounds = 7 //How many rounds can it hold?
	var/current_rounds = -1 //Set this to something else for it not to start with different initial counts.
	var/gun_type = "/obj/item/weapon/gun" //What type of gun does it fit in? Must be currently a gun. (see : gun reload proc)
	var/icon_type = "bullet" //Used for updating the icon when it creates casings.
	var/null_ammo = 0 //Set this to 0 to have a non-ammo-datum-using magazine without generating errors.
	var/reload_delay = 1 //Set a timer for reloading mags. Higher is slower.
	var/bonus_overlay = null //Sprite pointer in ammo.dmi to an overlay to add to the gun, for extended mags, box mags, and so on
	var/used_casings = 0 //Just an easier way to track how many shells to eject later.

	//For the handful method of reloading. Not used for regular mags.
	var/handful_type = "Bullets" // "Bullets" or "Shells" or "Slugs" or "Incendiary Slugs"
	var/handful_max_rounds = 8 // Tell a handful of how many rounds to make when it defaults.

	//For revolvers.
	var/cylinder_contents[] //What is actually in the cylinder. Initiated on New().
	var/cylinder_position = 1 //Where the firing pin is located. We don't rotate the cylinder, just move the pin.
	var/cylinder_closed = 1 //Starts out closed.

	//For shotguns. No real need for two sets of variables that serve similar function, but it helps to tell them apart.
	var/tube_contents[] //Initiated on New().
	var/tube_position = 1
	var/tube_closed = 0 //For the double barrel, more or less, everything else doesn't use it.

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
		if(isnull(default_ammo) || null_ammo) //None!
			icon_state = icon_empty
			current_rounds = 0
			desc = desc && "\nThis one is empty."
			return

		if(current_rounds == -1) //This actually works now. Amazing.
			current_rounds = max_rounds
		return

	update_icon()
		if(current_rounds <= 0 && icon_empty)
			icon_state = icon_empty
		else
			icon_state = initial(icon_state)

	examine()
		..()
		// It should never have negative ammo after spawn. If it does, we need to know about it.
		if(current_rounds < 0)
			usr << "Something went horribly wrong. Ahelp the following: ERROR CODE R1: negative current_rounds on examine."
		else
			usr << "\The [src] has <b>[current_rounds]</b> rounds out of <b>[max_rounds]</b>."

	attack_hand(mob/user as mob)
		if(istype(src,/obj/item/ammo_magazine/shotgun) || istype(src,/obj/item/ammo_magazine/revolver)) //If it's a box of shotgun shells or a speedloader.
			var/obj/item/ammo_magazine/in_hand = user.get_inactive_hand()
			if( in_hand == src ) //Have to be holding it in the hand.
				if (current_rounds > 0)
					create_handful(src,user)
					return
				else
					user << "\The [src] is empty. Nothing to grab."
		return ..() //Do normal stuff.

	//We should only attack it with handfuls. Empty hand to take out, handful to put back in. Same as normal handful.
	attackby(var/obj/item/ammo_magazine/handful/transfer_from, mob/user as mob)
		if(istype(src,/obj/item/ammo_magazine/shotgun) || istype(src,/obj/item/ammo_magazine/revolver)) //Same deal.
			if(istype(transfer_from)) // We have a handful.
				var/obj/item/ammo_magazine/in_hand = user.get_inactive_hand()
				if( in_hand == src ) //It has to be held.
					if(default_ammo == transfer_from.default_ammo)
						transfer_ammo(transfer_from,src,user,transfer_from.current_rounds) // This takes care of the rest.
					else
						user << "Those aren't the same rounds. Better not mix them up."
				else
					user << "Try holding \the [src] before you attempt to restock it."
		return

	//Generic proc to transfer ammo between ammo mags. Can work for anything, mags, handfuls, etc.
	proc/transfer_ammo(var/obj/item/ammo_magazine/source,var/obj/item/ammo_magazine/target,var/mob/user as mob,var/transfer_amount = 1)
		if( target.current_rounds == target.max_rounds ) //Does the target mag actually need reloading?
			if(user) user << "\The [target] is already full."
			return

		if(source.caliber != target.caliber) //Are they the same caliber?
			if(user) user << "The rounds don't match up. Better not mix them up."
			return

		var/S = min(transfer_amount, target.max_rounds - target.current_rounds)
		source.current_rounds -= S
		target.current_rounds += S
		//if(user) user << "\blue You transfer [S] round\s from \the [source] to \the [target]."
		if(source.current_rounds <= 0 && istype(source, /obj/item/ammo_magazine/handful)) //We want to delete it if it's a handful.
			del(source) //Dangerous. Can mean future procs break if they reference the source. Have to account for this.
			if(user)
				user.update_inv_l_hand(0) //In case we will get in hand icons.
				user.update_inv_r_hand()
		else
			source.update_icon()
		target.update_icon()
		return S // We return the number transferred if it was successful.

	//This will attempt to place the ammo in the user's hand if possible.
	proc/create_handful(var/obj/item/ammo_magazine/source, var/mob/user as mob, var/transfer_amount)
		var/S
		if (source.current_rounds > 0)
			var/obj/item/ammo_magazine/handful/new_handful = new()

			new_handful.name = "Handful of [source.handful_type]"
			new_handful.desc = "A handful of rounds to reload on the go."
			new_handful.icon_state = source.icon_type
			new_handful.caliber = source.caliber
			new_handful.caliber_type = source.caliber_type
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
				//fingerprints are added here.
				if(!user.put_in_active_hand(new_handful) && !user.put_in_inactive_hand(new_handful))
					new_handful.loc = get_turf(user)
					user << "\blue You remove <b>[S]</b> round\s from \the [source]."
				else
					user << "\blue You grab <b>[S]</b> round\s from \the [source]."
			else
				new_handful.loc = get_turf(src)

			source.update_icon() //Update the other one.
		return S //Give the number created.

	proc/match_ammo(var/obj/item/ammo_magazine/source,var/obj/item/ammo_magazine/target)
		target.caliber = source.caliber
		target.default_ammo = source.default_ammo
		target.gun_type = source.gun_type
		target.handful_type = source.handful_type

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
			else
				user << "Those aren't the same rounds. Better not mix them up."
		return


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
		return

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
		return

//Making child objects so that locate() and istype() doesn't screw up.
/obj/item/ammo_casing/bullet

/obj/item/ammo_casing/shell
	name = "spent shell"
	icon_state = "shell_"
	number_of_states = 5