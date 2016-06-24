/*
ERROR CODES AND WHAT THEY MEAN:


ERROR CODE A1: null.ammopath while reloading. <------------ Only appears when reloading a weapon and switching the .ammo. Somehow the argument passed a null.ammo.
ERROR CODE I1: projectile malfunctioned while firing. <------------ Right before the bullet is fired, the actual bullet isn't present or isn't a bullet.
ERROR CODE I2: null ammo while load_into_chamber() <------------- Somehow the ammo datum is missing or something. We need to figure out how that happened.
ERROR CODE R1: negative current_rounds on examine. <------------ Applies to ammunition only. Ammunition should never have negative rounds on spawn.

NOTES


if(burst_toggled && burst_firing) return
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
That should be on for most procs that deal with the gun doing some action. We do not want
the gun to suddenly begin to fire when you're doing something else to it that could mess it up.
As a general safety, make sure you remember this.


Guns, on the front end, function off a three tier process. To successfully create some unique gun
that has a special method of firing, you need to override these procs.

New() //You can typically leave this one alone, unless you need for the gun to do something on spawn.
Guns that use the regular system of chamber fire should load_into_chamber() on New().

reload() //If the gun doesn't use the normal methods of reloading, like revolvers or shotguns which use
handfuls, you will need to specify just how it reloads. User can be passed as null.

unload() //Same deal. If it's some unique unload method, you need to put that here. User can be passed as null.

make_casing() //What the gun does to make a casing. If it just shoots them out (or doesn't make casings), the
regular proc is fine. This proc uses .dir and icon_state to change the number of bullets spawned, and is the
fastest I could make it. One thing to note about it is that if more casings are desired, they have to be
pregenerated, usually by hand.

able_to_fire() //Unless the gun has some special check to see whether or not it may fire, you don't need this.
You can see examples of how this is modified in smartgun/sadar code, along with others. Return ..() on a success.

load_into_chamber() //This can get complicated, but if the gun doesn't take attachments that fire bullets from
the Fire() process, just set them to null and leave the if(current_mag && current_mag.current_rounds > 0) check.
The idea here is that if the gun can find a valid bullet to fire, subtract the ammo.

reload_into_chamber() //The is the back action of the fire cycle that tells the gun to do all the stuff it needs
to in order to prepare for the next fire cycle. This will be called if the gun fired successfully, per bullet.
This is also where the gun will make a casing. So if your gun doesn't handle casings the regular way, modify it.
Also where the gun will do final attachment calculations if the gun fired an attachment bullet.

delete_bullet() //Important for point blanking and and jams, but can be called on for other reasons (that are
not currently used). If the gun makes a bullet but doesn't fire it, this will be called on through clear_jam().
This is also used to delete the bullet when you directly fire a bullet without going through the Fire() process,
like with the mentioned point blanking/suicide.


Other procs are pretty self explanatory, and what is listed above is what you should usually cahnge for unusual
cases. So long as the gun can return true on able_to_fire() then move on to load_into_chamber() and finally
reload_into_chamber(), you're in good shape. Those three procs basically make up the fire cycle, and if they
function correctly, everything else will follow.

This system is incredibly robust and can be used for anything from single bullet carbines to high-end energy
weapons. So long as the steps are followed, it will work without issue. Some guns ignore active attachables,
since they currently do not use them, but if that changes, the related procs must also change.

~N

*/

//----------------------------------------------------------
			//							  \\
			// EQUIPMENT AND INTERACTION  \\
			//							  \\
			//						   	  \\
//----------------------------------------------------------
/obj/item/weapon/gun/mob_can_equip(var/mob/user as mob, slot)
	//Cannot equip wielded items or items burst firing.
	if(is_bursting || burst_firing) return
	unwield(user)
	return ..()

/obj/item/weapon/gun/attack_hand(mob/user as mob)
	var/obj/item/weapon/gun/in_hand = user.get_inactive_hand()
	if( in_hand == src && twohanded ) //It has to be held if it's a two hander.
		unload(user)
	else ..()

/obj/item/weapon/gun/throw_at(atom/target, range, speed, thrower)
	if( harness_check(thrower) )
		usr << "\red The [src] clanks on the ground."
		return
	else ..()

/*
Note: pickup and dropped on weapons must have both the ..() to update zoom AND twohanded,
As sniper rifles have both and weapon mods can change them as well. ..() deals with zoom only.
*/
/obj/item/weapon/gun/dropped(mob/user as mob)
	..()

	stop_aim()
	if (user && user.client)
		user.client.remove_gun_icons()

	if(flashlight_on && src.loc != user)
		user.SetLuminosity(-flash_lum)
		SetLuminosity(flash_lum)

	if(harness_check(user))
		var/mob/living/carbon/human/owner = user
		spawn(3)
			if(owner)
				if(isnull(owner.s_store) && isturf(src.loc))
					var/obj/item/I = owner.wear_suit
					owner.equip_to_slot_if_possible(src,slot_s_store)
					if(owner.s_store == src) user << "\red The [src] snaps into place on [I]."
					owner.update_inv_s_store()

	unwield(user)

/obj/item/weapon/gun/pickup(mob/user)
	..()

	if(flashlight_on && src.loc != user)
		user.SetLuminosity(flash_lum)
		SetLuminosity(0)

	unwield(user)
	return

/*
Here we have throwing and dropping related procs.
This should fix some issues with throwing mag harnessed guns when
they're not supposed to be thrown. Either way, this fix
should be alright.
*/
/obj/item/weapon/gun/proc/harness_check(mob/user as mob)
	if(user && ishuman(user))
		var/mob/living/carbon/human/owner = user
		if(has_attachment(/obj/item/attachable/magnetic_harness) || istype(src,/obj/item/weapon/gun/smartgun))
			var/obj/item/I = owner.wear_suit
			if(istype(I,/obj/item/clothing/suit/storage/marine) || istype(I,/obj/item/clothing/suit/storage/marine_smartgun_armor))
				return 1
	return

/obj/item/weapon/gun/attack_self(mob/user as mob)
	if (target)
		lower_aim()
		return

	//There are only two ways to interact here.
	if(twohanded)
		if(wielded) //Trying to unwield it
			unwield(user)

		else //Trying to wield it
			wield(user)

	else //We just unload it.
		unload(user)
	return

//Unless the user is not present, you always want to pass user as mob for wield/unwield. But you don't have to, I guess.
/obj/item/weapon/gun/proc/wield(mob/user as mob)
	if(!twohanded || wielded) return

	if(user && user.get_inactive_hand())
		user << "<span class='warning'>You need your other hand to be empty.</span>"
		return

	wielded = !wielded

	name = "[initial(name)] (Wielded)"
	if(!isnull(icon_wielded))
		item_state = icon_wielded
	else
		item_state = "[initial(item_state)]-w"
	if(user && ishuman(user))
		var/mob/living/carbon/human/wielder = user
		wielder << "<span class='notice'>You grab the [initial(name)] with both hands.</span>"
		var/obj/item/weapon/twohanded/offhand/O = new(wielder) ////Let's reserve his other hand~
		O.wielded = 1
		O.name = "[initial(name)] - offhand"
		O.desc = "Your second grip on the [initial(name)]"
		wielder.put_in_inactive_hand(O)
		wielder.update_inv_l_hand(0)
		wielder.update_inv_r_hand()

/obj/item/weapon/gun/proc/unwield(mob/user as mob)
	if(!twohanded || !wielded) return //If we're not actually carrying it with both hands or it's a one handed weapon.

	wielded = !wielded

	name = "[initial(name)]"
	item_state = "[initial(item_state)]"
	if(user && ishuman(user))
		user << "<span class='notice'>You are now carrying the [name] with one hand.</span>"
		var/mob/living/carbon/human/wielder = user
		wielder.update_inv_l_hand(0) //Updating invs is more efficient than updating the entire icon set.
		wielder.update_inv_r_hand()
		var/obj/item/weapon/twohanded/O = wielder.get_inactive_hand()
		if(istype(O))
			O.unwield()

//Clicking stuff onto the gun.
//Attachables & Reloading
/obj/item/weapon/gun/attackby(obj/item/I as obj, mob/user as mob)
	if(burst_toggled && burst_firing) return

	if(istype(I,/obj/item/ammo_magazine))
		reload(user,I)
		return

	if(!istype(I,/obj/item/attachable)) return

	var/obj/item/attachable/A = I
	if(!(src.type in A.guns_allowed))
		user << "\The [A] doesn't fit on [src]."
		return

	var/obj/item/weapon/gun/in_hand = user.get_inactive_hand()
	if(twohanded && in_hand != src) //It has to be held if it's a two hander.
		user << "\blue Try holding \the [src] before you attempt to modify it."
		return

	//Checks if they can attach the thing in the first place, like with fixed attachments.
	var/can_attach = 1
	switch(A.slot)
		if("rail")
			if(rail && rail.can_be_removed == 0) can_attach = 0
		if("muzzle")
			if(muzzle && muzzle.can_be_removed == 0) can_attach = 0
		if("under")
			if(under && under.can_be_removed == 0) can_attach = 0
		if("stock")
			if(stock && stock.can_be_removed == 0) can_attach = 0

	if(!can_attach)
		user << "The attachment on [src]'s [A.slot] cannot be removed."
		return

	user.visible_message("\blue [user] begins field-modifying their [src]..","\blue You begin field modifying \the [src].")
	if(do_after(user,60))
		user.visible_message("\blue [user] attaches \the [A] to \the [src].","\blue You attach \the [A] to \the [src].")
		user.drop_item(A)
		A.Attach(src)
		update_attachables()
		if(reload_sound)
			playsound(user, reload_sound, 100, 1)
	return

//----------------------------------------------------------
				//						 \\
				// GENERIC HELPER PROCS  \\
				//						 \\
				//						 \\
//----------------------------------------------------------

/obj/item/weapon/gun/proc/unique_action(var/mob/M) //Anything unique the gun can do, like pump or spin or whatever.
	return

/obj/item/weapon/gun/proc/has_attachment(var/A)
	if(!A)
		return
	if(istype(muzzle,A)) return 1
	if(istype(under,A)) return 1
	if(istype(rail,A)) return 1
	if(istype(stock,A)) return 1
	return

/obj/item/weapon/gun/proc/update_attachables()
	overlays.Cut()
	if(rail)
		var/flash = 0
		var/image/I
		if(rail.light_mod) //Currently only rail-mounted flashlights.
			if(flashlight_on)
				I = new(rail.icon, "[rail.icon_state]-on")
				I.icon_state = "[rail.icon_state]-on"
				flash = 1
		if(!flash)
			I = new(rail.icon, rail.icon_state)
			I.icon_state = rail.icon_state
		I.pixel_x = src.rail_pixel_x - rail.pixel_shift_x
		I.pixel_y = src.rail_pixel_y - rail.pixel_shift_y
		overlays += I
	if(muzzle)
		var/image/I = new(muzzle.icon, muzzle.icon_state)
		I.icon_state = muzzle.icon_state
		I.pixel_x = src.muzzle_pixel_x - muzzle.pixel_shift_x
		I.pixel_y = src.muzzle_pixel_y - muzzle.pixel_shift_y
		overlays += I
	if(under)
		var/image/I = new(under.icon, under.icon_state)
		I.icon_state = under.icon_state
		I.pixel_x = src.under_pixel_x - under.pixel_shift_x
		I.pixel_y = src.under_pixel_y - under.pixel_shift_y
		overlays += I
	if(stock)
		var/image/I = new(stock.icon, stock.icon_state)
		I.icon_state = stock.icon_state
		I.pixel_x = src.under_pixel_x - stock.pixel_shift_x
		I.pixel_y = src.under_pixel_y - stock.pixel_shift_y
		overlays += I

//----------------------------------------------------------
					//				   \\
					// GUN VERBS PROCS \\
					//				   \\
					//				   \\
//----------------------------------------------------------

/obj/item/weapon/gun/verb/field_strip()
	set category = "Weapons"
	set name = "Field Strip Weapon"
	set desc = "Remove all attachables from a weapon."
	set src in usr

	if(burst_toggled && burst_firing) return

	if(!usr.canmove || usr.stat || usr.restrained() || !usr.loc)
		usr << "Not right now."
		return

	if(!rail && !muzzle && !under && !stock)
		usr << "This weapon has no attachables. You can only field strip enhanced weapons."
		return

	usr.visible_message("\blue [usr] begins field stripping their [src].","\blue You begin field-stripping your [src].")
	if(!do_after(usr,40))
		return

	if(rail && rail.can_be_removed)
		usr << "You remove the weapon's [rail]."
		rail.Detach(src)
	if(muzzle && muzzle.can_be_removed)
		usr << "You remove the weapon's [muzzle]."
		muzzle.Detach(src)
	if(under && under.can_be_removed)
		usr << "You remove the weapon's [under]."
		under.Detach(src)
	if(stock && stock.can_be_removed)
		usr << "You remove the weapon's [stock]."
		stock.Detach(src)

	playsound(src,'sound/machines/click.ogg', 50, 1)
	update_attachables()

/obj/item/weapon/gun/verb/toggle_burst()
	set category = "Weapons"
	set name = "Toggle Burst Fire Mode"
	set desc = "Toggle on or off your weapon burst mode, if it has one. Greatly reduces accuracy."
	set src in usr

	if(burst_firing) return //We don't want to mess with this WHILE the gun is firing.

	if(!ishuman(usr)) return

	if(!usr.canmove || usr.stat || usr.restrained() || !usr.loc)
		usr << "Not right now."
		return

	if(!burst_amount)
		usr << "This weapon does not have a burst fire mode."
		return

	playsound(src.loc,'sound/machines/click.ogg', 50, 1)
	burst_toggled = !burst_toggled
	if(burst_toggled)
		usr << "\icon[src] You <B>enable</b> the [src]'s burst fire mode."
	else
		usr << "\icon[src] You <B>disable</b> the [src]'s burst fire mode."

	return

/obj/item/weapon/gun/verb/empty_mag()
	set category = "Weapons"
	set name = "Unload Magazine"
	set desc = "Remove the magazine from your current gun and drop it on the ground."
	set src in usr

	if(burst_toggled && burst_firing) return

	if(!ishuman(usr)) return

	if(!usr.canmove || usr.stat || usr.restrained() || !usr.loc || !isturf(usr.loc))
		usr << "Not right now."
		return

	unload(usr)

	return

/obj/item/weapon/gun/verb/use_unique_action()
	set category = "Weapons"
	set name = "Unique Action"
	set desc = "Use anything unique your firearm is capable of. Includes pumping a shotgun or spinning a revolver."
	set src in usr

	if(burst_toggled && burst_firing) return

	if(!ishuman(usr)) return

	if(!usr.canmove || usr.stat || usr.restrained() || !usr.loc || !isturf(usr.loc))
		usr << "Not right now."
		return

	unique_action(usr)

	return

/obj/item/weapon/gun/verb/activate_attachment()
	set category = "Weapons"
	set name = "Load From Attachment"
	set desc = "Load from a gun attachment, such as a mounted grenade launcher, shotgun, or flamethrower."
	set src in usr

	if(burst_toggled && burst_firing) return

	if(!ishuman(usr)) return

	if(!usr.canmove || usr.stat || usr.restrained() || !usr.loc || !isturf(usr.loc))
		usr << "Not right now."
		return

	var/list/usable_attachments = list() //Basic list of attachments to compare later.
	if(rail && rail.can_activate) usable_attachments[rail.name] = rail
	if(under && under.can_activate) usable_attachments[under.name] = under
	if(stock  && stock.can_activate) usable_attachments[stock.name] = stock
	if(muzzle && muzzle.can_activate) usable_attachments[muzzle.name] = muzzle

	if(usable_attachments.len <= 0) //No usable attachments.
		usr << "This weapon does not have any attachments."
		return

	if(usable_attachments.len == 1) //Activates the only attachment if there is only one.
		if(active_attachable && !active_attachable.passive) //In case the attach is passive like the flashlight/scope.
			usr << "You disable the [active_attachable.name]."
			playsound(src.loc,active_attachable.activation_sound, 50, 1)
			active_attachable = null
			return
		else
			var/activate_this = usable_attachments[1]
			active_attachable = usable_attachments[activate_this]

	else
		var/list/attachment_names = list() //Name list, since otherwise we would reference the object path itself in the choice menu.
		for(var/attachment_found in usable_attachments)
			attachment_names += attachment_found
		if(active_attachable)
			attachment_names += "Cancel Active"
		else
			attachment_names += "Cancel"

		//If you click on anything but the attachment name, it'll cancel anything active.
		var/choice = input("Which attachment to activate?") as null|anything in attachment_names

		if(src.loc != usr) //Dropped or something.
			return

		if(!choice || choice == "Cancel" || choice == "Cancel Active")
			if(active_attachable  && !active_attachable.passive)
				usr << "You disable the [active_attachable.name]."
				playsound(src.loc,active_attachable.activation_sound, 50, 1)
				active_attachable = null
				return

		var/obj/item/attachable/activate_this = usable_attachments[choice]
		if(activate_this && activate_this.loc == src) //If it still exists at all and held on the gun.
			active_attachable = activate_this

		if(!active_attachable)
			usr << "Nothing happened!"
			return

	usr << "You toggle the [active_attachable.name]."
	active_attachable.activate_attachment(src,usr)
	playsound(src.loc,active_attachable.activation_sound, 50, 1)
	return


//----------------------------------------------------------
				//				   	   \\
				// UNUSED EXAMPLE CODE \\
				//				  	   \\
				//				   	   \\
//----------------------------------------------------------

	/*
	//This works, but it's also pretty slow in comparison to the updated method.
	var/turf/current_turf = get_turf(src)
	var/obj/item/ammo_casing/casing = locate() in current_turf
	var/icon/I = new( 'icons/obj/ammo.dmi', current_mag.icon_spent, pick(1,2,4,5,6,8,9,10) ) //Feeding dir is faster than doing Turn().
	I.Shift(pick(1,2,4,5,6,8,9,10),rand(0,11))
	if(casing) //If there is already something on the ground, takes the firs thing it finds. Can take a long time if there are a lot of things.
		//Still better than making a billion casings.
		if(casing.name != "spent casings")
			casing.name += "s"
		I.Blend(casing.icon,ICON_UNDERLAY) //We want to overlay it on top.
		casing.icon = I
	else //If not, make one.
		var/obj/item/ammo_casing/new_casing = new(current_turf)
		new_casing.icon = I
	playsound(current_turf, sound_to_play, 20, 1)
	*/

/*
//Leaving this here because I think it's excellent code in terms of something you can do. But it is not the
//most efficient. Also, this particular example crashes the client upon Blend(). Not sure what is causing it,
//but the code was entirely replaced so it's irrelevant now. ~N
//If the gun has spent shells and we either have no ammo remaining or we're reloading it on the go.
if(current_mag.casings_to_eject.len && casing_override) //We have some spent casings to eject.
	var/turf/current_turf = get_turf(src)
	var/obj/item/ammo_casing/casing = locate() in current_turf
	var/icon/G

	if(!casing)
		//Feeding dir is faster than doing Turn().
		G = new( 'icons/obj/ammo.dmi', current_mag.icon_spent, pick(1,2,4,5,6,8,9,10) ) //We make a new icon.
		G.Shift(pick(1,2,4,5,6,8,9,10),rand(0,11)) //Shift it randomy.
		var/obj/item/ammo_casing/new_casing = new(current_turf) //Then we create a new casing.
		new_casing.icon = G //We give this new casing the icon we just generated.
		casing = new_casing //Our casing from earlier is now this csaing.
		current_mag.casings_to_eject.Cut(1,2) //Cut the list so that it's one less.
		playsound(current_turf, sound_to_play, 20, 1) //Play the sound.

	G = casing.icon //Get the icon from the casing icon if it spawned or was there previously.
	var/i
	for(i = 1 to current_mag.casings_to_eject.len) //We want to run this for each item in the list.
		var/icon/I = new( 'icons/obj/ammo.dmi', current_mag.icon_spent, pick(1,2,4,5,6,8,9,10) )
		I.Shift(pick(1,2,4,5,6,8,9,10),rand(0,11))
		G.Blend(I,ICON_OVERLAY) //<---- Crashes the client. //Blend them two in, with I overlaying what's already there.
		playsound(current_turf, sound_to_play, 20, 1)

	G.Blend(casing.icon,ICON_UNDERLAY)
	casing.icon = G
	if(casing.name != "spent casings")
		casing.name += "s"
	current_mag.casings_to_eject = list() //Empty list.

else if(!casing_override)//So we're not reloading/emptying, we're firing the gun.
	//I would add a check here for attachables, but you can't fit the masterkey on a revolver/shotgun.
	current_mag.casings_to_eject += ammo.casing_type //Other attachables are processed beforehand and don't matter here.
*/