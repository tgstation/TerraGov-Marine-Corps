/*
ERROR CODES AND WHAT THEY MEAN:


ERROR CODE A1: null ammo while reloading. <------------ Only appears when reloading a weapon and switching the .ammo. Somehow the argument passed a null.ammo.
ERROR CODE I1: projectile malfunctioned while firing. <------------ Right before the bullet is fired, the actual bullet isn't present or isn't a bullet.
ERROR CODE I2: null ammo while load_into_chamber() <------------- Somehow the ammo datum is missing or something. We need to figure out how that happened.
ERROR CODE R1: negative current_rounds on examine. <------------ Applies to ammunition only. Ammunition should never have negative rounds after spawn.

DEFINES in setup.dm, referenced here.
#define GUN_CAN_POINTBLANK		(1 << 0)
#define GUN_TRIGGER_SAFETY		(1 << 1)
#define GUN_UNUSUAL_DESIGN		(1 << 2)
#define GUN_SILENCED			(1 << 3)
#define GUN_AUTOMATIC			(1 << 4)
#define GUN_INTERNAL_MAG		(1 << 5)
#define GUN_AUTO_EJECTOR		(1 << 6)
#define GUN_AMMO_COUNTER		(1 << 7)
#define GUN_BURST_ON			(1 << 8)
#define GUN_BURST_FIRING		(1 << 9)
#define GUN_FLASHLIGHT_ON		(1 << 10)
#define GUN_WIELDED_FIRING_ONLY	(1 << 11)
#define GUN_HAS_FULL_AUTO		(1 << 12)
#define GUN_FULL_AUTO_ON		(1 << 13)
#define GUN_POLICE				(1 << 14)
#define GUN_ENERGY				(1 << 15)
#define GUN_LOAD_INTO_CHAMBER	(1 << 16)

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

	Energy guns, or guns that don't really use magazines, can gut this system a bit. You can see examples in the taser.

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
	Move the mind checks for damage and stun to actual files, or rework it somehow.
*/

//----------------------------------------------------------
			//							  \\
			// EQUIPMENT AND INTERACTION  \\
			//							  \\
			//						   	  \\
//----------------------------------------------------------

/obj/item/weapon/gun/AltClick(mob/user)
	toggle_gun_safety()


/obj/item/weapon/gun/mob_can_equip(mob/user)
	//Cannot equip wielded items or items burst firing.
	if(flags_gun_features & GUN_BURST_FIRING)
		return
	unwield(user)
	return ..()


/obj/item/weapon/gun/attack_hand(mob/user)
	var/obj/item/weapon/gun/in_hand = user.get_inactive_held_item()
	if(in_hand == src && (flags_item & TWOHANDED))
		unload(user)//It has to be held if it's a two hander.
	else
		return ..()


/obj/item/weapon/gun/throw_at(atom/target, range, speed, thrower)
	if( harness_check(thrower) )
		to_chat(usr, "<span class='warning'>\The [src] clanks on the ground.</span>")
	else
		return ..()

/*
Note: pickup and dropped on weapons must have both the ..() to update zoom AND twohanded,
As sniper rifles have both and weapon mods can change them as well. ..() deals with zoom only.
*/
/obj/item/weapon/gun/dropped(mob/user)
	. = ..()

	stop_aim()
	if(user?.client)
		user.update_gun_icons()

	turn_off_light(user)

	unwield(user)
	harness_check(user)


/obj/item/weapon/gun/proc/turn_off_light(mob/bearer)
	if(!bearer && ismob(loc))
		bearer = loc
	if(flags_gun_features & GUN_FLASHLIGHT_ON && bearer)
		bearer.SetLuminosity( rail.light_mod * -1 )
		SetLuminosity(rail.light_mod)
		return TRUE
	return FALSE


/obj/item/weapon/gun/pickup(mob/user)
	..()

	if(flags_gun_features & GUN_FLASHLIGHT_ON)
		user.SetLuminosity(rail.light_mod)
		SetLuminosity(0)

	unwield(user)


/obj/item/weapon/gun/proc/police_allowed_check(mob/living/carbon/human/user)
	if(CONFIG_GET(flag/remove_gun_restrictions))
		return TRUE //Not if the config removed it.

	if(user.mind)
		if(user.mind.cm_skills && user.mind.cm_skills.police >= SKILL_POLICE_MP)
			return TRUE
		if(allowed(user))
			return TRUE
	to_chat(user, "<span class='warning'>[src] flashes a warning sign indicating unauthorized use!</span>")


/obj/item/weapon/gun/proc/wielded_stable() //soft wield-delay
	if(world.time > wield_time)
		return TRUE
	else
		return FALSE


/obj/item/weapon/gun/proc/do_wield(mob/user, wdelay) //*shrugs*
	if(wield_time > 0 && !do_mob(user, user, wdelay, BUSY_ICON_HOSTILE, null, PROGRESS_CLOCK, TRUE, CALLBACK(src, .proc/is_wielded)))
		return FALSE
	return TRUE

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
			if(istype(I,/obj/item/clothing/suit/storage/marine) || istype(I, /obj/item/clothing/suit/armor))
				harness_return(user)
				return 1


/obj/item/weapon/gun/proc/harness_return(mob/living/carbon/human/user)
	set waitfor = 0
	sleep(3)
	if(loc && user)
		if(isnull(user.s_store) && isturf(loc))
			var/obj/item/I = user.wear_suit
			user.equip_to_slot_if_possible(src,SLOT_S_STORE)
			if(user.s_store == src)
				to_chat(user, "<span class='warning'>[src] snaps into place on [I].</span>")
			user.update_inv_s_store()


/obj/item/weapon/gun/attack_self(mob/user)
	. = ..()
	if(target)
		return

	//There are only two ways to interact here.
	if(flags_item & TWOHANDED)
		if(flags_item & WIELDED)
			unwield(user)//Trying to unwield it
		else
			wield(user)//Trying to wield it
	else
		unload(user)//We just unload it.


//Clicking stuff onto the gun.
//Attachables & Reloading
/obj/item/weapon/gun/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(flags_gun_features & GUN_BURST_FIRING)
		return

	. = ..()

	if(istype(I,/obj/item/attachable) && check_inactive_hand(user))
		attach_to_gun(user, I)
		return

 	//the active attachment is reloadable
	if(active_attachable?.flags_attach_features & ATTACH_RELOADABLE && check_inactive_hand(user))
		active_attachable.reload_attachment(I, user)
		return

	if((istype(I, /obj/item/ammo_magazine) || istype(I, /obj/item/cell/lasgun)) && check_inactive_hand(user))
		reload(user, I)


//tactical reloads
/obj/item/weapon/gun/MouseDrop_T(atom/dropping, mob/living/carbon/human/user)
	if(istype(dropping, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/AM = dropping
		if(!istype(user) || user.incapacitated(TRUE))
			return
		if(src != user.r_hand && src != user.l_hand)
			to_chat(user, "<span class='warning'>[src] must be in your hand to do that.</span>")
			return
		if(flags_gun_features & GUN_INTERNAL_MAG)
			to_chat(user, "<span class='warning'>Can't do tactical reloads with [src].</span>")
			return
		//no tactical reload for the untrained.
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.firearms == 0)
			to_chat(user, "<span class='warning'>You don't know how to do tactical reloads.</span>")
			return
		if(istype(src, AM.gun_type))
			if(current_mag)
				unload(user,0,1)
				to_chat(user, "<span class='notice'>You start a tactical reload.</span>")
			var/tac_reload_time = 15
			if(user.mind && user.mind.cm_skills)
				tac_reload_time = max(15 - 5*user.mind.cm_skills.firearms, 5)
			if(do_after(user,tac_reload_time, TRUE, AM) && loc == user)
				if(istype(AM.loc, /obj/item/storage))
					var/obj/item/storage/S = AM.loc
					S.remove_from_storage(AM)
				reload(user, AM)
	else
		..()



//----------------------------------------------------------
				//						 \\
				// GENERIC HELPER PROCS  \\
				//						 \\
				//						 \\
//----------------------------------------------------------

/obj/item/weapon/gun/proc/unique_action(mob/M) //Anything unique the gun can do, like pump or spin or whatever.
	return FALSE


/mob/living/carbon/human/proc/do_unique_action()
	. = COMSIG_KB_ACTIVATED //The return value must be a flag compatible with the signals triggering this.
	if(incapacitated() || lying)
		return

	var/obj/item/weapon/gun/G = get_active_held_item()
	if(!istype(G))
		return

	G.unique_action(src)


/obj/item/weapon/gun/proc/check_inactive_hand(mob/user)
	if(user)
		var/obj/item/weapon/gun/in_hand = user.get_inactive_held_item()
		if( in_hand != src ) //It has to be held.
			to_chat(user, "<span class='warning'>You have to hold [src] to do that!</span>")
			return
	return TRUE


/obj/item/weapon/gun/proc/check_both_hands(mob/user)
	if(user)
		var/obj/item/weapon/gun/in_handL = user.l_hand
		var/obj/item/weapon/gun/in_handR = user.r_hand
		if( in_handL != src && in_handR != src ) //It has to be held.
			to_chat(user, "<span class='warning'>You have to hold [src] to do that!</span>")
			return
	return 1

/obj/item/weapon/gun/proc/is_wielded() //temporary proc until we get traits going
	return CHECK_BITFIELD(flags_item, WIELDED)

/obj/item/weapon/gun/proc/has_attachment(A)
	if(!A)
		return
	if(istype(muzzle,A))
		return TRUE
	if(istype(under,A))
		return TRUE
	if(istype(rail,A))
		return TRUE
	if(istype(stock,A))
		return TRUE


/obj/item/weapon/gun/proc/attach_to_gun(mob/user, obj/item/attachable/attachment)
	if(attachable_allowed && !(attachment.type in attachable_allowed) )
		to_chat(user, "<span class='warning'>[attachment] doesn't fit on [src]!</span>")
		return

	//Checks if they can attach the thing in the first place, like with fixed attachments.
	var/can_attach = 1
	switch(attachment.slot)
		if("rail")
			if(rail && !(rail.flags_attach_features & ATTACH_REMOVABLE))
				can_attach = FALSE
		if("muzzle")
			if(muzzle && !(muzzle.flags_attach_features & ATTACH_REMOVABLE))
				can_attach = FALSE
		if("under")
			if(under && !(under.flags_attach_features & ATTACH_REMOVABLE))
				can_attach = FALSE
		if("stock")
			if(stock && !(stock.flags_attach_features & ATTACH_REMOVABLE))
				can_attach = FALSE

	if(!can_attach)
		to_chat(user, "<span class='warning'>The attachment on [src]'s [attachment.slot] cannot be removed!</span>")
		return

	var/final_delay = attachment.attach_delay
	var/idisplay = BUSY_ICON_GENERIC
	if(user.mind?.cm_skills?.firearms)
		user.visible_message("<span class='notice'>[user] begins attaching [attachment] to [src].</span>",
		"<span class='notice'>You begin attaching [attachment] to [src].</span>", null, 4)
		if(user.mind.cm_skills.firearms >= SKILL_FIREARMS_DEFAULT) //See if the attacher is super skilled/panzerelite born to defeat never retreat etc
			final_delay *= 0.5
	else //If the user has no training, attaching takes twice as long and they fumble about, looking like a retard.
		final_delay *= 2
		user.visible_message("<span class='notice'>[user] begins fumbling about, trying to attach [attachment] to [src].</span>",
		"<span class='notice'>You begin fumbling about, trying to attach [attachment] to [src].</span>", null, 4)
		idisplay = BUSY_ICON_UNSKILLED
	//user.visible_message("","<span class='notice'>Attach Delay = [final_delay]. Attachment = [attachment]. Firearm Skill = [user.mind.cm_skills.firearms].</span>", null, 4) //DEBUG
	if(do_after(user, final_delay, TRUE, src, idisplay))
		user.visible_message("<span class='notice'>[user] attaches [attachment] to [src].</span>",
		"<span class='notice'>You attach [attachment] to [src].</span>", null, 4)
		user.temporarilyRemoveItemFromInventory(attachment)
		attachment.Attach(src)
		update_attachable(attachment.slot)
		playsound(user, 'sound/machines/click.ogg', 15, 1, 4)


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


/obj/item/weapon/gun/proc/update_overlays(obj/item/attachable/A, slot)
	var/image/I = attachable_overlays[slot]
	overlays -= I
	qdel(I)
	if(A) //Only updates if the attachment exists for that slot.
		var/item_icon = A.icon_state
		if(A.attach_icon)
			item_icon = A.attach_icon
		I = image(A.icon,src, item_icon)
		I.pixel_x = attachable_offset["[slot]_x"] - A.pixel_shift_x
		I.pixel_y = attachable_offset["[slot]_y"] - A.pixel_shift_y
		attachable_overlays[slot] = I
		overlays += I
	else
		attachable_overlays[slot] = null


/obj/item/weapon/gun/proc/update_mag_overlay()
	var/image/I = attachable_overlays["mag"]
	overlays -= I
	qdel(I)
	if(current_mag && current_mag.bonus_overlay)
		I = image(current_mag.icon,src,current_mag.bonus_overlay)
		attachable_overlays["mag"] = I
		overlays += I
	else
		attachable_overlays["mag"] = null


/obj/item/weapon/gun/proc/update_special_overlay(new_icon_state)
	overlays -= attachable_overlays["special"]
	qdel(attachable_overlays["special"])
	var/image/I = image(icon,src,new_icon_state)
	attachable_overlays["special"] = I
	overlays += I


/obj/item/weapon/gun/proc/update_force_list()
	switch(force)
		if(-50 to 15)
			attack_verb = list("struck", "hit", "bashed") //Unlikely to ever be -50, but just to be safe.
		if(16 to 35)
			attack_verb = list("smashed", "struck", "whacked", "beaten", "cracked")
		else
			attack_verb = list("slashed", "stabbed", "speared", "torn", "punctured", "pierced", "gored") //Greater than 35


/proc/get_active_firearm(mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this.</span>")
		return

	if( user.incapacitated() || !isturf(user.loc))
		to_chat(user, "<span class='warning'>You can't do this right now.</span>")
		return

	var/obj/item/weapon/gun/G = user.get_active_held_item()
	if(!istype(G))
		G = user.get_inactive_held_item()

	if(!istype(G))
		to_chat(user, "<span class='warning'>You need a gun in your hands to do that!</span>")
		return

	if(G.flags_gun_features & GUN_BURST_FIRING)
		return

	return G

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
	set src = usr.contents //We want to make sure one is picked at random, hence it's not in a list.

	var/obj/item/weapon/gun/G = get_active_firearm(usr)

	if(!G)
		return

	src = G

	if(usr.action_busy)
		return

	if(zoom)
		to_chat(usr, "<span class='warning'>You cannot conceviably do that while looking down \the [src]'s scope!</span>")
		return

	if(!rail && !muzzle && !under && !stock)
		to_chat(usr, "<span class='warning'>This weapon has no attachables. You can only field strip enhanced weapons!</span>")
		return

	var/list/possible_attachments = list()

	if(rail && (rail.flags_attach_features & ATTACH_REMOVABLE))
		possible_attachments += rail
	if(muzzle && (muzzle.flags_attach_features & ATTACH_REMOVABLE))
		possible_attachments += muzzle
	if(under && (under.flags_attach_features & ATTACH_REMOVABLE))
		possible_attachments += under
	if(stock && (stock.flags_attach_features & ATTACH_REMOVABLE))
		possible_attachments += stock

	if(!possible_attachments.len)
		to_chat(usr, "<span class='warning'>[src] has no removable attachments.</span>")
		return

	var/obj/item/attachable/A
	if(possible_attachments.len == 1)
		A = possible_attachments[1]
	else
		A = input("Which attachment to remove?") as null|anything in possible_attachments

	if(!A)
		return

	if(get_active_firearm(usr) != src)//dropped the gun
		return

	if(usr.action_busy)
		return

	if(zoom)
		return

	if(A != rail && A != muzzle && A != under && A != stock)
		return
	if(!(A.flags_attach_features & ATTACH_REMOVABLE))
		return

	var/final_delay = A.detach_delay
	var/idisplay = BUSY_ICON_GENERIC
	if(usr.mind?.cm_skills?.firearms)
		usr.visible_message("<span class='notice'>[usr] begins stripping [A] from [src].</span>",
		"<span class='notice'>You begin stripping [A] from [src].</span>", null, 4)
		if(usr.mind.cm_skills.firearms > SKILL_FIREARMS_DEFAULT) //See if the attacher is super skilled/panzerelite born to defeat never retreat etc
			final_delay *= 0.5 //Half normal time
	else //If the user has no training, attaching takes twice as long and they fumble about, looking like a retard.
		final_delay *= 2
		usr.visible_message("<span class='notice'>[usr] begins fumbling about, trying to strip [A] from [src].</span>",
		"<span class='notice'>You begin fumbling about, trying to strip [A] from [src].</span>", null, 4)
		idisplay = BUSY_ICON_UNSKILLED
	//usr.visible_message("","<span class='notice'>Detach Delay = [detach_delay]. Attachment = [A]. Firearm Skill = [usr.mind.cm_skills.firearms].</span>", null, 4) //DEBUG
	if(!do_after(usr,final_delay, TRUE, src, idisplay))
		return

	if(A != rail && A != muzzle && A != under && A != stock)
		return
	if(!(A.flags_attach_features & ATTACH_REMOVABLE))
		return

	if(zoom)
		return

	usr.visible_message("<span class='notice'>[usr] strips [A] from [src].</span>",
	"<span class='notice'>You strip [A] from [src].</span>", null, 4)
	A.Detach(src)

	playsound(src, 'sound/machines/click.ogg', 15, 1, 4)
	update_attachables()

/obj/item/weapon/gun/verb/toggle_burst()
	set category = "Weapons"
	set name = "Toggle Burst Fire Mode"
	set desc = "Toggle on or off your weapon burst mode, if it has one. Greatly reduces accuracy."
	set src = usr.contents

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return
	src = G

	//Burst of 1 doesn't mean anything. The weapon will only fire once regardless.
	//Just a good safety to have all weapons that can equip a scope with 1 burst_amount.
	if(burst_amount < 2)
		to_chat(usr, "<span class='warning'>This weapon does not have a burst fire mode!</span>")
		return

	if(flags_gun_features & GUN_BURST_FIRING)//can't toggle mid burst
		return

	playsound(usr, 'sound/machines/click.ogg', 15, 1)
	if(flags_gun_features & GUN_HAS_FULL_AUTO)
		if(flags_gun_features & GUN_BURST_ON)
			if(flags_gun_features & GUN_FULL_AUTO_ON)
				flags_gun_features &= ~GUN_FULL_AUTO_ON
				flags_gun_features &= ~GUN_BURST_ON
				to_chat(usr, "<span class='notice'>[icon2html(src, usr)] You set [src] to single fire mode.</span>")
			else
				flags_gun_features|= GUN_FULL_AUTO_ON
				to_chat(usr, "<span class='notice'>[icon2html(src, usr)] You set [src] to full auto mode.</span>")
		else
			flags_gun_features |= GUN_BURST_ON
			to_chat(usr, "<span class='notice'>[icon2html(src, usr)] You set [src] to burst fire mode.</span>")
	else
		flags_gun_features ^= GUN_BURST_ON

		to_chat(usr, "<span class='notice'>[icon2html(src, usr)] You [flags_gun_features & GUN_BURST_ON ? "<B>enable</b>" : "<B>disable</b>"] [src]'s burst fire mode.</span>")


/obj/item/weapon/gun/verb/empty_mag()
	set category = "Weapons"
	set name = "Unload Weapon"
	set desc = "Removes the magazine from your current gun and drops it on the ground, or clears the chamber if your gun is already empty."
	set src = usr.contents

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return
	src = G

	unload(usr,,1) //We want to drop the mag on the ground.

/obj/item/weapon/gun/verb/use_unique_action()
	set category = "Weapons"
	set name = "Unique Action"
	set desc = "Use anything unique your firearm is capable of. Includes pumping a shotgun or spinning a revolver."
	set src = usr.contents

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return
	src = G

	unique_action(usr)


/obj/item/weapon/gun/verb/toggle_gun_safety()
	set category = "Weapons"
	set name = "Toggle Gun Safety"
	set desc = "Toggle the safety of the held gun."
	set src = usr.contents //We want to make sure one is picked at random, hence it's not in a list.

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return
	src = G

	to_chat(usr, "<span class='notice'>You toggle the safety [flags_gun_features & GUN_TRIGGER_SAFETY ? "<b>off</b>" : "<b>on</b>"].</span>")
	playsound(usr, 'sound/machines/click.ogg', 15, 1)
	flags_gun_features ^= GUN_TRIGGER_SAFETY


/obj/item/weapon/gun/verb/activate_attachment_verb()
	set category = "Weapons"
	set name = "Load From Attachment"
	set desc = "Load from a gun attachment, such as a mounted grenade launcher, shotgun, or flamethrower."
	set src = usr.contents

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return
	src = G

	var/obj/item/attachable/A

	var/usable_attachments[] = list() //Basic list of attachments to compare later.
// rail attachment use the button to toggle flashlight instead.
//	if(rail && (rail.flags_attach_features & ATTACH_ACTIVATION) )
//		usable_attachments += rail
	if(under && (under.flags_attach_features & ATTACH_ACTIVATION) )
		usable_attachments += under
	if(stock  && (stock.flags_attach_features & ATTACH_ACTIVATION) )
		usable_attachments += stock
	if(muzzle && (muzzle.flags_attach_features & ATTACH_ACTIVATION) )
		usable_attachments += muzzle

	if(!usable_attachments.len) //No usable attachments.
		to_chat(usr, "<span class='warning'>[src] does not have any usable attachment!</span>")
		return

	if(usable_attachments.len == 1) //Activates the only attachment if there is only one.
		A = usable_attachments[1]
	else
		A = input("Which attachment to activate?") as null|anything in usable_attachments
		if(!A || A.loc != src)
			return
	if(A)
		A.ui_action_click(usr, src)


/obj/item/weapon/gun/verb/toggle_rail_attachment()
	set category = "Weapons"
	set name = "Toggle Rail Attachment"
	set desc = "Uses the rail attachement currently attached to the gun."
	set src = usr.contents

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return

	if(!G.rail)
		to_chat(usr, "<span class='warning'>[src] does not have any usable rail attachment!</span>")
		return

	G.rail.activate_attachment(G, usr)


/obj/item/weapon/gun/verb/toggle_ammo_hud()
	set category = "Weapons"
	set name = "Toggle Ammo HUD"
	set desc = "Toggles the Ammo HUD for this weapon."
	set src = usr.contents

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return
	src = G

	hud_enabled = !hud_enabled
	var/obj/screen/ammo/A = usr.hud_used.ammo
	hud_enabled ? A.add_hud(usr) : A.remove_hud(usr)
	A.update_hud(usr)
	to_chat(usr, "<span class='notice'>[hud_enabled ? "You enable the Ammo HUD for this weapon." : "You disable the Ammo HUD for this weapon."]</span>")


/obj/item/weapon/gun/item_action_slot_check(mob/user, slot)
	if(slot != SLOT_L_HAND && slot != SLOT_R_HAND)
		return FALSE
	return TRUE

/obj/item/weapon/gun/proc/get_ammo_type()
	return FALSE

/obj/item/weapon/gun/proc/get_ammo_count()
	return FALSE



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
	var/icon/I = new( 'icons/obj/items/ammo.dmi', current_mag.icon_spent, pick(1,2,4,5,6,8,9,10) ) //Feeding dir is faster than doing Turn().
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
		G = new( 'icons/obj/items/ammo.dmi', current_mag.icon_spent, pick(1,2,4,5,6,8,9,10) ) //We make a new icon.
		G.Shift(pick(1,2,4,5,6,8,9,10),rand(0,11)) //Shift it randomy.
		var/obj/item/ammo_casing/new_casing = new(current_turf) //Then we create a new casing.
		new_casing.icon = G //We give this new casing the icon we just generated.
		casing = new_casing //Our casing from earlier is now this csaing.
		current_mag.casings_to_eject.Cut(1,2) //Cut the list so that it's one less.
		playsound(current_turf, sound_to_play, 20, 1) //Play the sound.

	G = casing.icon //Get the icon from the casing icon if it spawned or was there previously.
	var/i
	for(i = 1 to current_mag.casings_to_eject.len) //We want to run this for each item in the list.
		var/icon/I = new( 'icons/obj/items/ammo.dmi', current_mag.icon_spent, pick(1,2,4,5,6,8,9,10) )
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
