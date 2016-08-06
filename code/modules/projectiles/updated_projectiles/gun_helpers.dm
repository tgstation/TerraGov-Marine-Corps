/*
ERROR CODES AND WHAT THEY MEAN:


ERROR CODE A1: null ammo while reloading. <------------ Only appears when reloading a weapon and switching the .ammo. Somehow the argument passed a null.ammo.
ERROR CODE I1: projectile malfunctioned while firing. <------------ Right before the bullet is fired, the actual bullet isn't present or isn't a bullet.
ERROR CODE I2: null ammo while load_into_chamber() <------------- Somehow the ammo datum is missing or something. We need to figure out how that happened.
ERROR CODE R1: negative current_rounds on examine. <------------ Applies to ammunition only. Ammunition should never have negative rounds after spawn.

DEFINES in setup.dm, referenced here.
#define GUN_CAN_POINTBLANK		1
#define GUN_TRIGGER_SAFETY		2
#define GUN_UNUSUAL_DESIGN		4
#define GUN_SILENCED			8
#define GUN_AUTOMATIC			16
#define GUN_INTERNAL_MAG		32
#define GUN_AUTO_EJECTOR		64
#define GUN_AMMO_COUNTER		128
#define GUN_BURST_ON			256
#define GUN_BURST_FIRING		512
#define GUN_FLASHLIGHT_ON		1024
#define GUN_ON_MERCS			2048
#define GUN_ON_RUSSIANS			4096
#define GUN_WY_RESTRICTED		8192

	NOTES


	if(burst_toggled && burst_firing) return
	^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	That should be on for most procs that deal with the gun doing some action. We do not want
	the gun to suddenly begin to fire when you're doing something else to it that could mess it up.
	As a general safety, make sure you remember this.


	Guns, on the front end, function off a three tier process. To successfully create some unique gun
	that has a special method of firing, you need to override these procs.

	New() //You can typically leave this one alone unless you need for the gun to do something on spawn.
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
	This must return positive to continue the fire cycle.

	ready_in_chamber() //If the load_into_chamber is identical to the base outside of the actual bullet getting loaded,
	then you can use this in order to save on overrides. This primarily goes for anything that uses attachments like
	any standard firing cycle (attachables that fire through the firing cycle).

	reload_into_chamber() //The is the back action of the fire cycle that tells the gun to do all the stuff it needs
	to in order to prepare for the next fire cycle. This will be called if the gun fired successfully, per bullet.
	This is also where the gun will make a casing. So if your gun doesn't handle casings the regular way, modify it.
	Also where the gun will do final attachment calculations if the gun fired an attachment bullet.
	This must return positive to continue burst firing or so that you don't hear *click*.

	delete_bullet() //Important for point blanking and and jams, but can be called on for other reasons (that are
	not currently used). If the gun makes a bullet but doesn't fire it, this will be called on through clear_jam().
	This is also used to delete the bullet when you directly fire a bullet without going through the Fire() process,
	like with the mentioned point blanking/suicide.


	Other procs are pretty self explanatory, and what is listed above is what you should usually change for unusual
	cases. So long as the gun can return true on able_to_fire() then move on to load_into_chamber() and finally
	reload_into_chamber(), you're in good shape. Those three procs basically make up the fire cycle, and if they
	function correctly, everything else will follow.

	This system is incredibly robust and can be used for anything from single bullet carbines to high-end energy
	weapons. So long as the steps are followed, it will work without issue. Some guns ignore active attachables,
	since they currently do not use them, but if that changes, the related procs must also change.

	Energy guns, or guns that don't really use magazines, can gut this system a bit. You can see examples in
	predator weapons or the taser.

	Ammo is loaded dynamically based on parent type through a global list. It is located in global_lists.dm under
	__HELPERS. So never create new() datums, as the datum should just be referenced through the global list instead.
	This cuts down on unnecessary overhead, and makes bullets always have an ammo type, even if the parent weapon is
	somehow deleted or some such. Null ammo in the projectile flight stage shoulder NEVER exist. If it does, something
	has gone wrong elsewhere and should be looked at. Do not simply add if(ammo) checks. If the system is working correctly,
	you will never need them.

	The guns also have bitflags for various functions, so refer to those in case you want to create something unique.
	They're all pretty straight forward; silenced comes from attachments only, so don't try to set it as the default.
	If you want a silenced gun, attach a silencer to it on New() that cannot be removed.

	~N

	TODO:

	Add more muzzle flashes and gun sounds. Energy weapons, spear launcher, and taser for example.
	Add more guns, or unique guns. The framework should be there.
	Add ping for energy guns like the taser and plasma caster.
	Move pred check for damage effects into the actual predator files instead of the usual.
	Move the mind checks for damage and stun to actual files, or rework it somehow.
	Make the following flags do something: GUN_ON_RUSSIANS GUN_ON_MERCS.
	These two are for the distress weapon randomizier that was never implemented as far as I know,
*/

//----------------------------------------------------------
			//							  \\
			// EQUIPMENT AND INTERACTION  \\
			//							  \\
			//						   	  \\
//----------------------------------------------------------

/obj/item/weapon/gun/AltClick(var/mob/user)
	if((gun_features | GUN_BURST_ON | GUN_BURST_FIRING) == gun_features || gun_features & GUN_UNUSUAL_DESIGN) return

	if(!ishuman(user)) return

	if(!user.canmove || user.stat || user.restrained() || !user.loc || !isturf(user.loc))
		user << "Not right now."
		return

	user << "<span class='notice'>You toggle the safety [gun_features & GUN_TRIGGER_SAFETY ? "<b>off</b>" : "<b>on</b>"].</span>"
	playsound(usr,'sound/machines/click.ogg', 15, 1)
	gun_features ^= GUN_TRIGGER_SAFETY
	return

/obj/item/weapon/gun/mob_can_equip(mob/user)
	//Cannot equip wielded items or items burst firing.
	if(gun_features & GUN_BURST_FIRING) return
	unwield(user)
	return ..()

/obj/item/weapon/gun/attack_hand(mob/user)
	var/obj/item/weapon/gun/in_hand = user.get_inactive_hand()
	if( in_hand == src && (flags & TWOHANDED) ) unload(user)//It has to be held if it's a two hander.
	else ..()

/obj/item/weapon/gun/throw_at(atom/target, range, speed, thrower)
	if( harness_check(thrower) ) usr << "<span class='warning'>The [src] clanks on the ground.</span>"
	else ..()

/*
Note: pickup and dropped on weapons must have both the ..() to update zoom AND twohanded,
As sniper rifles have both and weapon mods can change them as well. ..() deals with zoom only.
*/
/obj/item/weapon/gun/dropped(mob/user)
	..()

	stop_aim()
	if (user && user.client)
		user.client.remove_gun_icons()

	if(gun_features & GUN_FLASHLIGHT_ON)
		user.SetLuminosity(-rail.light_mod)
		SetLuminosity(rail.light_mod)

	unwield(user)
	harness_check(user)

/obj/item/weapon/gun/pickup(mob/user)
	..()

	if(gun_features & GUN_FLASHLIGHT_ON)
		user.SetLuminosity(rail.light_mod)
		SetLuminosity(0)

	unwield(user)

/obj/item/weapon/gun/proc/wy_allowed_check(var/mob/living/carbon/human/user)
	if(config && config.remove_gun_restrictions) return 1 //Not if the config removed it.

	if(istype(user) && user.mind)
		switch(user.mind.assigned_role)
			if("PMC Leader","PMC", "WY Agent", "Corporate Laison", "Event") return 1
		if(user.mind.special_role == "DEATH SQUAD") return 1
	user << "<span class='warning'>[src] flashes a warning sign indicating unauthorized use!</span>"

/*
Here we have throwing and dropping related procs.
This should fix some issues with throwing mag harnessed guns when
they're not supposed to be thrown. Either way, this fix
should be alright.
*/
/obj/item/weapon/gun/proc/harness_check(mob/user)
	if(user && ishuman(user))
		var/mob/living/carbon/human/owner = user
		if(has_attachment(/obj/item/attachable/magnetic_harness) || istype(src,/obj/item/weapon/gun/smartgun))
			var/obj/item/I = owner.wear_suit
			if(istype(I,/obj/item/clothing/suit/storage/marine) || istype(I,/obj/item/clothing/suit/storage/smartgunner))
				harness_return(user)
				return 1

/obj/item/weapon/gun/proc/harness_return(var/mob/living/carbon/human/user)
	set waitfor = 0
	sleep(3)
	if(loc && user)
		if(isnull(user.s_store) && isturf(src.loc))
			var/obj/item/I = user.wear_suit
			user.equip_to_slot_if_possible(src,slot_s_store)
			if(user.s_store == src) user << "<span class='warning'>[src] snaps into place on [I].</span>"
			user.update_inv_s_store()

/obj/item/weapon/gun/attack_self(mob/user)
	..()
	if (target)
		lower_aim()
		return

	//There are only two ways to interact here.
	if(flags & TWOHANDED)
		if(flags & WIELDED) unwield(user)//Trying to unwield it
		else wield(user)//Trying to wield it
	else unload(user)//We just unload it.

//Clicking stuff onto the gun.
//Attachables & Reloading
/obj/item/weapon/gun/attackby(obj/item/I as obj, mob/user as mob)
	if((gun_features | GUN_BURST_ON | GUN_BURST_FIRING) == gun_features) return

	if(istype(I,/obj/item/ammo_magazine))
		if(check_inactive_hand(user)) reload(user,I)

	else if(istype(I,/obj/item/attachable))
		if(check_inactive_hand(user)) attach_to_gun(user,I)

//----------------------------------------------------------
				//						 \\
				// GENERIC HELPER PROCS  \\
				//						 \\
				//						 \\
//----------------------------------------------------------

/obj/item/weapon/gun/proc/unique_action(mob/M) //Anything unique the gun can do, like pump or spin or whatever.
	return

/obj/item/weapon/gun/proc/check_inactive_hand(var/mob/user)
	if(user)
		var/obj/item/weapon/gun/in_hand = user.get_inactive_hand()
		if( in_hand != src ) //It has to be held.
			user << "<span class='warning'>You have to hold [src] to do that!</span>"
			return
	return 1

/obj/item/weapon/gun/proc/check_both_hands(var/mob/user)
	if(user)
		var/obj/item/weapon/gun/in_handL = user.l_hand
		var/obj/item/weapon/gun/in_handR = user.r_hand
		if( in_handL != src && in_handR != src ) //It has to be held.
			user << "<span class='warning'>You have to hold [src] to do that!</span>"
			return
	return 1

/obj/item/weapon/gun/proc/has_attachment(var/A)
	if(!A) return
	if(istype(muzzle,A)) return 1
	if(istype(under,A)) return 1
	if(istype(rail,A)) return 1
	if(istype(stock,A)) return 1

/obj/item/weapon/gun/proc/attach_to_gun(var/mob/user, var/obj/item/attachable/attachment)
	if( !(attachment.type in attachable_allowed) )
		user << "<span class='warning'>[attachment] doesn't fit on [src]!</span>"
		return

	//Checks if they can attach the thing in the first place, like with fixed attachments.
	var/can_attach = 1
	switch(attachment.slot)
		if("rail")
			if(rail && !(rail.attach_features & ATTACH_REMOVABLE) ) can_attach = 0
		if("muzzle")
			if(muzzle && !(muzzle.attach_features & ATTACH_REMOVABLE) ) can_attach = 0
		if("under")
			if(under && !(under.attach_features & ATTACH_REMOVABLE) ) can_attach = 0
		if("stock")
			if(stock && !(stock.attach_features & ATTACH_REMOVABLE) ) can_attach = 0

	if(!can_attach)
		user << "<span class='warning'>The attachment on [src]'s [attachment.slot] cannot be removed!</span>"
		return

	user << "<span class='notice'>You begin field modifying [src]...</span>"
	if(do_after(user,60))
		user << "<span class='notice'>You attach [attachment] to [src].</span>"
		user.drop_item(attachment)
		attachment.Attach(src)
		update_attachable(attachment.slot)
		playsound(user,'sound/machines/click.ogg', 50, 1)

/obj/item/weapon/gun/proc/update_attachables() //Updates everything. You generally don't need to use this.
	//overlays.Cut()
	if(attachable_offset) //Even if the attachment doesn't exist, we're going to try and remove it.
		update_overlays(muzzle, "muzzle")
		update_overlays(stock, "stock")
		update_overlays(under, "under")
		update_overlays(rail, "rail")

/obj/item/weapon/gun/proc/update_attachable(attachable) //Updates individually.
	if(attachable_offset)
		switch(attachable)
			if("muzzle") update_overlays(muzzle, attachable)
			if("stock") update_overlays(stock, attachable)
			if("under") update_overlays(under, attachable)
			if("rail") update_overlays(rail, attachable)

/obj/item/weapon/gun/proc/update_overlays(var/obj/item/attachable/A, slot)
	overlays -= attachable_overlays[slot]
	cdel(attachable_overlays[slot])
	if(A) //Only updates if the attachment exists for that slot.
		//var/directives[] = list(A.icon,src, ( (slot == "rail" && gun_features & GUN_FLASHLIGHT_ON) ? "[A.icon_state]-on" : A.icon_state ))
		var/image/reusable/I = rnew(/image/reusable)
		I.generate_image(A.icon,src, ( (slot == "rail" && gun_features & GUN_FLASHLIGHT_ON) ? "[A.icon_state]-on" : A.icon_state ))
		I.pixel_x = attachable_offset["[slot]_x"] - A.pixel_shift_x
		I.pixel_y = attachable_offset["[slot]_y"] - A.pixel_shift_y
		attachable_overlays[slot] = I
		overlays += I

/obj/item/weapon/gun/proc/update_mag_overlay()
	overlays -= attachable_overlays["mag"]
	cdel(attachable_overlays["mag"])
	if(current_mag && current_mag.bonus_overlay)
		//var/directives[] = list(current_mag.icon,src,current_mag.bonus_overlay)
		var/image/reusable/I = rnew(/image/reusable)
		I.generate_image(current_mag.icon,src,current_mag.bonus_overlay)
		attachable_overlays["mag"] = I
		overlays += I

/obj/item/weapon/gun/proc/update_special_overlay(new_icon_state)
	overlays -= attachable_overlays["special"]
	cdel(attachable_overlays["special"])
	//var/directives[] = list(icon,src,new_icon_state)
	var/image/reusable/I = rnew(/image/reusable)
	I.generate_image(icon,src,new_icon_state)
	attachable_overlays["special"] = I
	overlays += I

/obj/item/weapon/gun/proc/update_force_list()
	switch(force)
		if(-50 to 15) attack_verb = list("struck", "hit", "bashed") //Unlikely to ever be -50, but just to be safe.
		if(16 to 35) attack_verb = list("smashed", "struck", "whacked", "beaten", "cracked")
		else attack_verb = list("slashed", "stabbed", "speared", "torn", "punctured", "pierced", "gored") //Greater than 35

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

	if((gun_features | GUN_BURST_ON | GUN_BURST_FIRING) == gun_features) return

	if(!usr.canmove || usr.stat || usr.restrained() || !usr.loc)
		usr << "Not right now."
		return

	if(!check_both_hands(usr)) return

	if(!rail && !muzzle && !under && !stock)
		usr << "<span class='warning'>This weapon has no attachables. You can only field strip enhanced weapons!</span>"
		return

	usr << "<span class='notice'>You begin field-stripping your [src]...</span>"
	if(!do_after(usr,40))
		return

	if(rail && (rail.attach_features & ATTACH_REMOVABLE) )
		usr << "<span class='notice'>You remove [src]'s [rail].</span>"
		rail.Detach(src)
	if(muzzle && (muzzle.attach_features & ATTACH_REMOVABLE) )
		usr << "<span class='notice'>You remove [src]'s [muzzle].</span>"
		muzzle.Detach(src)
	if(under && (under.attach_features & ATTACH_REMOVABLE) )
		usr << "<span class='notice'>You remove [src]'s [under].</span>"
		under.Detach(src)
	if(stock && (stock.attach_features & ATTACH_REMOVABLE))
		usr << "<span class='notice'>You remove [src]'s [stock].</span>"
		stock.Detach(src)

	playsound(src,'sound/machines/click.ogg', 50, 1)
	update_attachables()

/obj/item/weapon/gun/verb/toggle_burst()
	set category = "Weapons"
	set name = "Toggle Burst Fire Mode"
	set desc = "Toggle on or off your weapon burst mode, if it has one. Greatly reduces accuracy."
	set src in usr

	if(gun_features & GUN_BURST_FIRING) return //We don't want to mess with this WHILE the gun is firing.

	if(!ishuman(usr)) return

	if(!usr.canmove || usr.stat || usr.restrained() || !usr.loc)
		usr << "Not right now."
		return

	//Burst of 1 doesn't mean anything. The weapon will only fire once regardless.
	//Just a good safety to have all weapons that can equip a scope with 1 burst_amount.
	if(burst_amount < 2)
		usr << "<span class='warning'>This weapon does not have a burst fire mode!</span>"
		return

	if(!check_both_hands(usr)) return

	usr << "<span class='notice'>\icon[src] You [gun_features & GUN_BURST_ON ? "<B>disable</b>" : "<B>enable</b>"] the [src]'s burst fire mode.</span>"
	playsound(usr,'sound/machines/click.ogg', 50, 1)
	gun_features ^= GUN_BURST_ON

/obj/item/weapon/gun/verb/empty_mag()
	set category = "Weapons"
	set name = "Unload Magazine"
	set desc = "Remove the magazine from your current gun and drop it on the ground."
	set src in usr

	if((gun_features | GUN_BURST_ON | GUN_BURST_FIRING) == gun_features) return

	if(!ishuman(usr)) return

	if(!usr.canmove || usr.stat || usr.restrained() || !usr.loc || !isturf(usr.loc))
		usr << "<span class='warning'>Not right now!</span>"
		return

	if(!check_both_hands(usr)) return

	unload(usr)

/obj/item/weapon/gun/verb/use_unique_action()
	set category = "Weapons"
	set name = "Unique Action"
	set desc = "Use anything unique your firearm is capable of. Includes pumping a shotgun or spinning a revolver."
	set src in usr

	if((gun_features | GUN_BURST_ON | GUN_BURST_FIRING) == gun_features) return

	if(!ishuman(usr)) return

	if(!usr.canmove || usr.stat || usr.restrained() || !usr.loc || !isturf(usr.loc))
		usr << "<span class='warning'>Not right now!</span>"
		return

	if(!check_both_hands(usr)) return
	unique_action(usr)

/obj/item/weapon/gun/verb/activate_attachment()
	set category = "Weapons"
	set name = "Load From Attachment"
	set desc = "Load from a gun attachment, such as a mounted grenade launcher, shotgun, or flamethrower."
	set src in usr

	if((gun_features | GUN_BURST_ON | GUN_BURST_FIRING) == gun_features) return

	if(!ishuman(usr)) return

	if(!usr.canmove || usr.stat || usr.restrained() || !usr.loc || !isturf(usr.loc))
		usr << "<span class='warning'>Not right now!</span>"
		return

	if(!check_both_hands(usr)) return

	var/usable_attachments[] = list() //Basic list of attachments to compare later.
	if(rail && (rail.attach_features & ATTACH_ACTIVATION) ) usable_attachments += rail
	if(under && (under.attach_features & ATTACH_ACTIVATION) )
		if(istype(under, /obj/item/attachable/bipod)) //Specific case for bipods. Can be revised later if necessary.
			if(under.activate_attachment(src,usr)) return
		else usable_attachments += under
	if(stock  && (stock.attach_features & ATTACH_ACTIVATION) ) usable_attachments += stock
	if(muzzle && (muzzle.attach_features & ATTACH_ACTIVATION) ) usable_attachments += muzzle

	if(!usable_attachments.len) //No usable attachments.
		usr << "<span class='warning'>[src] does not have any usable attachments!</span>"
		return

	if(usable_attachments.len == 1) //Activates the only attachment if there is only one.
		if(active_attachable && !(active_attachable.attach_features & ATTACH_PASSIVE) ) //In case the attach is passive like the flashlight/scope.
			cancel_active_attachment(usr)
			return
		else active_attachable = usable_attachments[1]
	else
		//If you click on anything but the attachment name, it'll cancel anything active.
		usable_attachments += active_attachable ? "Cancel Active" : "Cancel"
		var/obj/item/attachable/activate_this = input("Which attachment to activate?") as null|anything in usable_attachments
		if(!usr.client || src.loc != usr) return//Dropped or something.
		if(!activate_this || activate_this == "Cancel" || activate_this == "Cancel Active")
			if(active_attachable  && !(active_attachable.attach_features & ATTACH_PASSIVE) ) cancel_active_attachment(usr)
			return

		if(activate_this.loc == src) active_attachable = activate_this //If it's still held in the gun.
	toggle_active_attachment(usr)

/obj/item/weapon/gun/proc/cancel_active_attachment(mob/user)
	user << "<span class='notice'>You disable [active_attachable].</span>"
	playsound(user,active_attachable.activation_sound, 50, 1)
	active_attachable = null

/obj/item/weapon/gun/proc/toggle_active_attachment(mob/user)
	user << "<span class='notice'>You toggle the [active_attachable.name].</span>"
	playsound(user,active_attachable.activation_sound, 50, 1)
	active_attachable.activate_attachment(src,user)

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