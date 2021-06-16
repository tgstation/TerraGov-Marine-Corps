/*
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

	gun_on_cooldown() //For custom cooldown checks. By default it takes into account the user's skills.

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

	delete_bullet() //Important for point blanking, but can be called on for other reasons (that are
	not currently used).
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

/obj/item/weapon/gun/attack_hand_alternate(mob/user)
	return toggle_gun_safety()


/obj/item/weapon/gun/mob_can_equip(mob/user)
	//Cannot equip wielded items or items burst firing.
	if(flags_gun_features & GUN_BURST_FIRING)
		return
	unwield(user)
	return ..()


/obj/item/weapon/gun/attack_hand(mob/living/user)
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

	unwield(user)
	harness_check(user)


/obj/item/weapon/gun/pickup(mob/user)
	..()

	unwield(user)


/obj/item/weapon/gun/proc/police_allowed_check(mob/living/carbon/human/user)
	if(CONFIG_GET(flag/remove_gun_restrictions))
		return TRUE //Not if the config removed it.

	if(user.skills.getRating("police") >= SKILL_POLICE_MP)
		return TRUE
	if(user.mind && allowed(user))
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
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/owner = user
	if(!has_attachment(/obj/item/attachable/magnetic_harness) && !istype(src,/obj/item/weapon/gun/smartgun))
		var/obj/item/B = owner.belt	//if they don't have a magharness, are they wearing a harness belt?
		if(!istype(B, /obj/item/belt_harness))
			return FALSE
	var/obj/item/I = owner.wear_suit
	if(!is_type_in_list(I, list(/obj/item/clothing/suit/storage, /obj/item/clothing/suit/armor, /obj/item/clothing/suit/modular)))
		return FALSE
	addtimer(CALLBACK(src, .proc/harness_return, user), 0.3 SECONDS, TIMER_UNIQUE)
	return TRUE


/obj/item/weapon/gun/proc/harness_return(mob/living/carbon/human/user)
	if(!isturf(loc) || QDELETED(user) || !isnull(user.s_store) && !isnull(user.back))
		return

	user.equip_to_slot_if_possible(src, SLOT_S_STORE, warning = FALSE)
	if(user.s_store == src)
		var/obj/item/I = user.wear_suit
		to_chat(user, "<span class='warning'>[src] snaps into place on [I].</span>")
		user.update_inv_s_store()
		return

	user.equip_to_slot_if_possible(src, SLOT_BACK, warning = FALSE)
	if(user.back == src)
		to_chat(user, "<span class='warning'>[src] snaps into place on your back.</span>")
	user.update_inv_back()


/obj/item/weapon/gun/attack_self(mob/user)
	. = ..()

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
	if(.)
		return

	if(flags_gun_features & GUN_BURST_FIRING)
		return

	if(istype(I,/obj/item/attachable) && check_inactive_hand(user))
		attach_to_gun(user, I)
		return

	//the active attachment is reloadable
	if(active_attachable?.flags_attach_features & ATTACH_RELOADABLE && check_inactive_hand(user) && active_attachable.reload_attachment(I, user, TRUE))
		return

	if((istype(I, /obj/item/ammo_magazine) || istype(I, /obj/item/cell/lasgun)) && check_inactive_hand(user))
		reload(user, I)
		return


//tactical reloads
/obj/item/weapon/gun/MouseDrop_T(atom/dropping, mob/living/carbon/human/user)
	if(istype(dropping, /obj/item/ammo_magazine))
		tactical_reload(dropping,user)
	return ..()

///This performs a tactical reload with src using new_magazine to load the gun.
/obj/item/weapon/gun/proc/tactical_reload(obj/item/ammo_magazine/new_magazine, mob/living/carbon/human/user)
	if(!istype(user) || user.incapacitated(TRUE))
		return
	if(src != user.r_hand && src != user.l_hand)
		to_chat(user, "<span class='warning'>[src] must be in your hand to do that.</span>")
		return
	if(flags_gun_features & GUN_INTERNAL_MAG)
		to_chat(user, "<span class='warning'>Can't do tactical reloads with [src].</span>")
		return
	//no tactical reload for the untrained.
	if(!user.skills.getRating("firearms"))
		to_chat(user, "<span class='warning'>You don't know how to do tactical reloads.</span>")
		return
	if(!istype(src, new_magazine.gun_type))
		return
	if(current_mag)
		unload(user,0,1)
		to_chat(user, "<span class='notice'>You start a tactical reload.</span>")
	var/tac_reload_time = max(0.5 SECONDS, 1.5 SECONDS - user.skills.getRating("firearms") * 5)
	if(!do_after(user,tac_reload_time, TRUE, new_magazine, ignore_turf_checks = TRUE) && loc == user)
		return
	if(istype(new_magazine.loc, /obj/item/storage))
		var/obj/item/storage/S = new_magazine.loc
		S.remove_from_storage(new_magazine, get_turf(user))
	user.put_in_any_hand_if_possible(new_magazine)
	reload(user, new_magazine)

//----------------------------------------------------------
				//						 \\
				// GENERIC HELPER PROCS  \\
				//						 \\
				//						 \\
//----------------------------------------------------------
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
	if(!attachments)
		return FALSE
	for(var/slot in attachments)
		if(istype(attachments[slot], A))
			return TRUE



/obj/item/weapon/gun/proc/attach_to_gun(mob/user, obj/item/attachable/attachment)
	if(attachable_allowed && !(attachment.type in attachable_allowed) )
		to_chat(user, "<span class='warning'>[attachment] doesn't fit on [src]!</span>")
		return

	if(overcharge == TRUE)
		to_chat(user, "<span class='warning'>You need to disable overcharge on [src]!</span>")
		return

	//Checks if there is any unremovable attachment on our slot, if true, return.
	var/obj/item/attachable/currently_in_slot = LAZYACCESS(attachments, attachment.slot)
	if(currently_in_slot && !(currently_in_slot.flags_attach_features & ATTACH_REMOVABLE))
		to_chat(user, "<span class='warning'>The attachment on [src]'s [attachment.slot] cannot be removed!</span>")
		return

	var/final_delay = attachment.attach_delay
	var/idisplay = BUSY_ICON_GENERIC
	if(user.skills.getRating("firearms"))
		user.visible_message("<span class='notice'>[user] begins attaching [attachment] to [src].</span>",
		"<span class='notice'>You begin attaching [attachment] to [src].</span>", null, 4)
		if(user.skills.getRating("firearms") >= SKILL_FIREARMS_DEFAULT) //See if the attacher is super skilled/panzerelite born to defeat never retreat etc
			final_delay *= 0.5
	else //If the user has no training, attaching takes twice as long and they fumble about.
		final_delay *= 2
		user.visible_message("<span class='notice'>[user] begins fumbling about, trying to attach [attachment] to [src].</span>",
		"<span class='notice'>You begin fumbling about, trying to attach [attachment] to [src].</span>", null, 4)
		idisplay = BUSY_ICON_UNSKILLED
	if(!do_after(user, final_delay, TRUE, src, idisplay))
		return
	user.visible_message("<span class='notice'>[user] attaches [attachment] to [src].</span>",
	"<span class='notice'>You attach [attachment] to [src].</span>", null, 4)
	user.temporarilyRemoveItemFromInventory(attachment)
	attachment.attach_to_gun(src, user)
	playsound(user, 'sound/machines/click.ogg', 15, 1, 4)

///Updates everything. You generally don't need to use this.
/obj/item/weapon/gun/proc/update_attachables()
	if(!attachable_offset) //Even if the attachment doesn't exist, we're going to try and remove it.
		return

	if(!attachments)
		return
	for(var/slot in attachments)
		var/obj/item/attachable/attachie = LAZYACCESS(attachments, slot)
		update_overlays(attachie, attachie.slot)


/obj/item/weapon/gun/proc/update_attachable(slot) //Updates individually.
	if(!attachable_offset)
		return

	update_overlays(LAZYACCESS(attachments, slot), slot)

/obj/item/weapon/gun/update_overlays(obj/item/attachable/attachie, slot)
	. = ..()
	var/image/overlay = attachable_overlays[slot]
	overlays -= overlay
	if(!attachie) //Only updates if the attachment exists for that slot.
		attachable_overlays[slot] = null
		return
	var/item_icon = attachie.icon_state
	if(attachie.attach_icon)
		item_icon = attachie.attach_icon
	overlay = image(attachie.icon, src, item_icon)
	overlay.pixel_x = attachable_offset["[slot]_x"] - attachie.pixel_shift_x
	overlay.pixel_y = attachable_offset["[slot]_y"] - attachie.pixel_shift_y
	attachable_overlays[slot] = overlay
	overlays += overlay

///updates the magazine overlay if it needs to be updated
/obj/item/weapon/gun/proc/update_mag_overlay(mob/user)
	var/image/overlay = attachable_overlays[ATTACHMENT_SLOT_MAGAZINE]
	overlays -= overlay
	if(current_mag && current_mag.bonus_overlay)
		overlay = image(current_mag.icon, src, current_mag.bonus_overlay)
		attachable_overlays[ATTACHMENT_SLOT_MAGAZINE] = overlay
		overlays += overlay
	else
		attachable_overlays[ATTACHMENT_SLOT_MAGAZINE] = null


/obj/item/weapon/gun/proc/update_force_list()
	switch(force)
		if(-50 to 15)
			attack_verb = list("struck", "hit", "bashed") //Unlikely to ever be -50, but just to be safe.
		if(16 to 35)
			attack_verb = list("smashed", "struck", "whacked", "beaten", "cracked")
		else
			attack_verb = list("slashed", "stabbed", "speared", "torn", "punctured", "pierced", "gored") //Greater than 35


/proc/get_active_firearm(mob/user)
	if(!user.dextrous)
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this.</span>")
		return

	if(user.incapacitated() || !isturf(user.loc))
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

/mob/living/carbon/human/verb/field_strip()
	set category = "Weapons"
	set name = "Field Strip Weapon"
	set desc = "Remove all attachables from a weapon."

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return
	G.field_strip()


/obj/item/weapon/gun/verb/field_strip()
	set category = null
	set name = "Field Strip (Weapon)"
	set desc = "Remove all attachables from a weapon."

	if(usr.do_actions)
		return

	if(zoom)
		to_chat(usr, "<span class='warning'>You cannot conceviably do that while looking down \the [src]'s scope!</span>")
		return

	if(overcharge)
		to_chat(usr, "[icon2html(src, usr)] You need to disable overcharge mode to remove attachments.")
		return

	if(!attachments)
		to_chat(usr, "<span class='warning'>This weapon has no attachables. You can only field strip enhanced weapons!</span>")
		return

	var/list/possible_attachments = list()

	for(var/slotties in attachments)
		var/obj/item/attachable/possible_attachment = attachments[slotties]
		if(!(possible_attachment.flags_attach_features & ATTACH_REMOVABLE))
			continue
		possible_attachments += possible_attachment

	if(!length(possible_attachments))
		to_chat(usr, "<span class='warning'>[src] has no removable attachments.</span>")
		return

	var/obj/item/attachable/A
	if(length(possible_attachments) == 1)
		A = possible_attachments[1]
	else
		A = tgui_input_list(usr, "Which attachment to remove?", null, possible_attachments)

	if(!A)
		return

	if(get_active_firearm(usr) != src)//dropped the gun
		return

	if(usr.do_actions)
		return

	if(zoom)
		return

	if(A != LAZYACCESS(attachments, A.slot))
		return
	if(!(A.flags_attach_features & ATTACH_REMOVABLE))
		return

	var/final_delay = A.detach_delay
	var/idisplay = BUSY_ICON_GENERIC
	if(usr.skills.getRating("firearms"))
		usr.visible_message("<span class='notice'>[usr] begins stripping [A] from [src].</span>",
		"<span class='notice'>You begin stripping [A] from [src].</span>", null, 4)
		if(usr.skills.getRating("firearms") > SKILL_FIREARMS_DEFAULT) //See if the attacher is super skilled/panzerelite born to defeat never retreat etc
			final_delay *= 0.5 //Half normal time
	else //If the user has no training, attaching takes twice as long and they fumble about.
		final_delay *= 2
		usr.visible_message("<span class='notice'>[usr] begins fumbling about, trying to strip [A] from [src].</span>",
		"<span class='notice'>You begin fumbling about, trying to strip [A] from [src].</span>", null, 4)
		idisplay = BUSY_ICON_UNSKILLED
	if(!do_after(usr,final_delay, TRUE, src, idisplay))
		return

	if(A != LAZYACCESS(attachments, A.slot))
		return

	if(!(A.flags_attach_features & ATTACH_REMOVABLE))
		return

	if(zoom)
		return

	usr.visible_message("<span class='notice'>[usr] strips [A] from [src].</span>",
	"<span class='notice'>You strip [A] from [src].</span>", null, 4)
	A.detach_from_master_gun(usr)

	playsound(src, 'sound/machines/click.ogg', 15, 1, 4)


/obj/item/weapon/gun/ui_action_click(mob/user, datum/action/item_action/action)
	if(flags_gun_features & GUN_BURST_FIRING)
		return
	var/datum/action/item_action/firemode/firemode_action = action
	if(!istype(firemode_action))
		return ..()
	do_toggle_firemode()
	user.update_action_buttons()


/mob/living/carbon/human/verb/toggle_autofire()
	set category = "Weapons"
	set name = "Toggle Auto Fire"
	set desc = "Toggle automatic firemode, if the gun has it."

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return
	G.toggle_autofire()


/obj/item/weapon/gun/verb/toggle_autofire()
	set category = null
	set name = "Toggle Auto Fire (Weapon)"
	set desc = "Toggle automatic firemode, if the gun has it."

	var/new_firemode
	switch(gun_firemode)
		if(GUN_FIREMODE_SEMIAUTO)
			new_firemode = GUN_FIREMODE_AUTOMATIC
		if(GUN_FIREMODE_BURSTFIRE)
			new_firemode = GUN_FIREMODE_AUTOBURST
		if(GUN_FIREMODE_AUTOMATIC)
			new_firemode = GUN_FIREMODE_SEMIAUTO
		if(GUN_FIREMODE_AUTOBURST)
			new_firemode = GUN_FIREMODE_BURSTFIRE
	if(!(new_firemode in gun_firemode_list))
		to_chat(usr, "<span class='warning'>[src] lacks a [new_firemode]!</span>")
		return
	do_toggle_firemode(new_firemode = new_firemode)


/mob/living/carbon/human/verb/toggle_burstfire()
	set category = "Weapons"
	set name = "Toggle Burst Fire"
	set desc = "Toggle burst firemode, if the gun has it."

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return
	G.toggle_burstfire()


/obj/item/weapon/gun/verb/toggle_burstfire()
	set category = null
	set name = "Toggle Burst Fire (Weapon)"
	set desc = "Toggle burst firemode, if the gun has it."

	var/new_firemode
	switch(gun_firemode)
		if(GUN_FIREMODE_SEMIAUTO)
			new_firemode = GUN_FIREMODE_BURSTFIRE
		if(GUN_FIREMODE_BURSTFIRE)
			new_firemode = GUN_FIREMODE_SEMIAUTO
		if(GUN_FIREMODE_AUTOMATIC)
			new_firemode = GUN_FIREMODE_AUTOBURST
		if(GUN_FIREMODE_AUTOBURST)
			new_firemode = GUN_FIREMODE_AUTOMATIC
	if(!(new_firemode in gun_firemode_list))
		to_chat(usr, "<span class='warning'>[src] lacks a [new_firemode]!</span>")
		return
	do_toggle_firemode(new_firemode = new_firemode)


/mob/living/carbon/human/verb/toggle_firemode()
	set category = "Weapons"
	set name = "Toggle Fire Mode"
	set desc = "Toggle between fire modes, if the gun has more than has one."

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return
	G.toggle_firemode()


/obj/item/weapon/gun/verb/toggle_firemode()
	set category = null
	set name = "Toggle Fire Mode (Weapon)"
	set desc = "Toggle between fire modes, if the gun has more than has one."

	do_toggle_firemode()


/obj/item/weapon/gun/proc/do_toggle_firemode(datum/source, new_firemode)
	SIGNAL_HANDLER
	if(flags_gun_features & GUN_BURST_FIRING)//can't toggle mid burst
		return

	if(!length(gun_firemode_list))
		CRASH("[src] called do_toggle_firemode() with an empty gun_firemode_list")

	if(length(gun_firemode) == 1)
		return

	if(new_firemode)
		if(!(new_firemode in gun_firemode_list))
			CRASH("[src] called do_toggle_firemode() with [new_firemode] new_firemode, not on gun_firemode_list")
		gun_firemode = new_firemode
	else
		var/mode_index = gun_firemode_list.Find(gun_firemode)
		if(++mode_index <= length(gun_firemode_list))
			gun_firemode = gun_firemode_list[mode_index]
		else
			gun_firemode = gun_firemode_list[1]

	if(gun_user)
		playsound(src, 'sound/weapons/guns/interact/selector.ogg', 15, 1)
		to_chat(gun_user, "<span class='notice'>[icon2html(src, gun_user)] You switch to <b>[gun_firemode]</b>.</span>")
		gun_user.update_action_buttons()

	SEND_SIGNAL(src, COMSIG_GUN_FIRE_MODE_TOGGLE, gun_firemode)


/obj/item/weapon/gun/proc/add_firemode(added_firemode, mob/user)
	gun_firemode_list += added_firemode

	switch(length(gun_firemode_list))
		if(0)
			CRASH("add_firemode called with a resulting gun_firemode_list length of [length(gun_firemode_list)].")
		if(1) //No need to toggle anything if there's a single firemode.
			return
		if(2)
			LAZYADD(actions_types, /datum/action/item_action/firemode)
			var/datum/action/new_action = new /datum/action/item_action/firemode(src)
			if(user)
				var/mob/living/living_user = user
				if(src == living_user.l_hand || src == living_user.r_hand)
					new_action.give_action(living_user)
		else //The action should already be there by now.
			return


/obj/item/weapon/gun/proc/remove_firemode(removed_firemode, mob/user)
	switch(length(gun_firemode_list))
		if(0, 1)
			CRASH("remove_firemode called with gun_firemode_list length [length(gun_firemode_list)].")
		if(2)
			LAZYREMOVE(actions_types, /datum/action/item_action/firemode)
			var/datum/action/old_action = locate(/datum/action/item_action/firemode) in actions
			if(user)
				var/mob/living/living_user = user
				if(src == living_user.l_hand || src == living_user.r_hand)
					old_action.remove_action(living_user)
			qdel(old_action)

	gun_firemode_list -= removed_firemode

	if(gun_firemode == removed_firemode)
		gun_firemode = gun_firemode_list[1]
		do_toggle_firemode(user, gun_firemode)


/obj/item/weapon/gun/proc/setup_firemodes()
	if(burst_amount > 1 && !(GUN_FIREMODE_BURSTFIRE in  gun_firemode_list))
		gun_firemode_list += GUN_FIREMODE_BURSTFIRE

	switch(length(gun_firemode_list))
		if(0)
			CRASH("[src] called setup_firemodes() with an empty gun_firemode_list")
		if(1)
			gun_firemode = gun_firemode_list[1]
		else
			gun_firemode = gun_firemode_list[1]
			var/datum/action/new_action = new /datum/action/item_action/firemode(src)
			if(isliving(loc))
				var/mob/living/living_user = loc
				if(src == living_user.l_hand || src == living_user.r_hand)
					new_action.give_action(living_user)

// The section for where you can do a fancy change to ammo types for most weapons.
/obj/item/weapon/gun/proc/add_ammo_mod(ammo_mod)
	return

/obj/item/weapon/gun/proc/remove_ammo_mod()
	return

/obj/item/weapon/gun/energy/add_ammo_mod(ammo_mod)
	ammo_diff = ammo_mod

/obj/item/weapon/gun/energy/remove_ammo_mod()
	ammo_diff = initial(ammo_diff)


/mob/living/carbon/human/verb/empty_mag()
	set category = "Weapons"
	set name = "Unload Weapon"
	set desc = "Removes the magazine from your current gun and drops it on the ground, or clears the chamber if your gun is already empty."

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return
	G.empty_mag()


/obj/item/weapon/gun/verb/empty_mag()
	set category = null
	set name = "Unload Weapon (Weapon)"
	set desc = "Removes the magazine from your current gun and drops it on the ground, or clears the chamber if your gun is already empty."

	unload(usr,,1) //We want to drop the mag on the ground.


/mob/living/carbon/human/verb/use_unique_action()
	set category = "Weapons"
	set name = "Unique Action"
	set desc = "Use anything unique your firearm is capable of. Includes pumping a shotgun or spinning a revolver."

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return
	G.use_unique_action()


/obj/item/weapon/gun/verb/use_unique_action()
	set category = null
	set name = "Unique Action (Weapon)"
	set desc = "Use anything unique your firearm is capable of. Includes pumping a shotgun or spinning a revolver."

	unique_action(usr)


/mob/living/carbon/human/verb/toggle_gun_safety()
	set category = "Weapons"
	set name = "Toggle Gun Safety"
	set desc = "Toggle the safety of the held gun."

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return
	G.toggle_gun_safety()


/obj/item/weapon/gun/verb/toggle_gun_safety()
	set category = null
	set name = "Toggle Gun Safety (Weapon)"
	set desc = "Toggle the safety of the held gun."

	to_chat(usr, "<span class='notice'>You toggle the safety [flags_gun_features & GUN_TRIGGER_SAFETY ? "<b>off</b>" : "<b>on</b>"].</span>")
	playsound(usr, 'sound/weapons/guns/interact/selector.ogg', 15, 1)
	flags_gun_features ^= GUN_TRIGGER_SAFETY


/mob/living/carbon/human/verb/activate_attachment_verb()
	set category = "Weapons"
	set name = "Load From Attachment"
	set desc = "Load from a gun attachment, such as a mounted grenade launcher, shotgun, or flamethrower."

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return
	G.activate_attachment_verb()


/obj/item/weapon/gun/verb/activate_attachment_verb()
	set category = null
	set name = "Load From Attachment (Weapon)"
	set desc = "Load from a gun attachment, such as a mounted grenade launcher, shotgun, or flamethrower."

	var/list/usable_attachments = list()
	// rail attachment use the button to toggle flashlight instead.
	//	if(rail && (rail.flags_attach_features & ATTACH_ACTIVATION) )
	//		usable_attachments += rail
	if(!attachments)
		to_chat(usr, "<span class='warning'>[src] does not have any usable attachment!</span>")
		return

	for(var/slot in attachments)
		var/obj/item/attachable/attachment = attachments[slot]
		if(attachment?.flags_attach_features & ATTACH_ACTIVATION)
			usable_attachments += attachment

	if(!length(usable_attachments)) //No usable attachments.
		to_chat(usr, "<span class='warning'>[src] does not have any usable attachment!</span>")
		return
	var/obj/item/attachable/usable_attachment
	if(length(usable_attachments) == 1)
		usable_attachment = usable_attachments[1]
	else
		usable_attachment = tgui_input_list(usr, "Which attachment to activate?", null, usable_attachments)

	if(!usable_attachment)
		return
	usable_attachment.ui_action_click(usr, null, src)


/mob/living/carbon/human/verb/toggle_rail_attachment()
	set category = "Weapons"
	set name = "Toggle Rail Attachment"
	set desc = "Uses the rail attachement currently attached to the gun."

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return
	G.toggle_rail_attachment()

/obj/item/weapon/gun/verb/toggle_rail_attachment()
	set category = null
	set name = "Toggle Rail Attachment (Weapon)"
	set desc = "Uses the rail attachement currently attached to the gun."

	var/obj/item/attachable/rail_attachment = LAZYACCESS(attachments, ATTACHMENT_SLOT_RAIL)
	if(!rail_attachment)
		to_chat(usr, "<span class='warning'>[src] does not have any usable rail attachment!</span>")
		return
	rail_attachment.activate_attachment(usr)

/obj/item/weapon/gun/verb/toggle_underrail_attachment()
	set category = null
	set name = "Toggle Underrail Attachment (Weapon)"
	set desc = "Uses the underrail attachement currently attached to the gun."

	var/obj/item/attachable/underrail_attachment = LAZYACCESS(attachments, ATTACHMENT_SLOT_UNDER)
	if(!underrail_attachment)
		to_chat(usr, "<span class='warning'>[src] does not have any usable rail attachment!</span>")
		return
	underrail_attachment.activate_attachment(usr)

/mob/living/carbon/human/verb/toggle_ammo_hud()
	set category = "Weapons"
	set name = "Toggle Ammo HUD"
	set desc = "Toggles the Ammo HUD for this weapon."

	var/obj/item/weapon/gun/G = get_active_firearm(usr)
	if(!G)
		return
	G.toggle_ammo_hud()


/obj/item/weapon/gun/verb/toggle_ammo_hud()
	set category = null
	set name = "Toggle Ammo HUD (Weapon)"
	set desc = "Toggles the Ammo HUD for this weapon."

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


/obj/item/weapon/gun/proc/modify_fire_delay(value, mob/user)
	fire_delay += value
	SEND_SIGNAL(src, COMSIG_GUN_AUTOFIREDELAY_MODIFIED, fire_delay)

/obj/item/weapon/gun/proc/modify_burst_delay(value, mob/user)
	burst_delay += value
	SEND_SIGNAL(src, COMSIG_GUN_BURST_SHOT_DELAY_MODIFIED, burst_delay)

/obj/item/weapon/gun/proc/modify_burst_amount(value, mob/user)
	burst_amount += value
	SEND_SIGNAL(src, COMSIG_GUN_BURST_SHOTS_TO_FIRE_MODIFIED, burst_amount)

	if(burst_amount < 2)
		if(GUN_FIREMODE_BURSTFIRE in gun_firemode_list)
			remove_firemode(GUN_FIREMODE_BURSTFIRE, user)
		if(GUN_FIREMODE_AUTOBURST in gun_firemode_list)
			remove_firemode(GUN_FIREMODE_AUTOBURST, user)
	else
		if(!(GUN_FIREMODE_BURSTFIRE in gun_firemode_list))
			add_firemode(GUN_FIREMODE_BURSTFIRE, user)
		if((GUN_FIREMODE_AUTOMATIC in gun_firemode_list) && !(GUN_FIREMODE_AUTOBURST in gun_firemode_list))
			add_firemode(GUN_FIREMODE_AUTOBURST, user)

/obj/item/weapon/gun/proc/toggle_auto_aim_mode(mob/living/carbon/human/user) //determines whether toggle_aim_mode activates at the end of gun/wield proc

	if(CHECK_BITFIELD(flags_item, WIELDED)) //if gun is wielded it toggles aim mode directly instead
		toggle_aim_mode(user)
		return

	if(!CHECK_BITFIELD(flags_gun_features, AUTO_AIM_MODE))
		to_chat(user, "<span class='notice'>You will immediately aim upon wielding your weapon.</b></span>")
		ENABLE_BITFIELD(flags_gun_features, AUTO_AIM_MODE)
	else
		to_chat(user, "<span class='notice'>You will wield your weapon without aiming with precision.</b></span>")
		DISABLE_BITFIELD(flags_gun_features, AUTO_AIM_MODE)

/obj/item/weapon/gun/proc/toggle_aim_mode(mob/living/carbon/human/user)
	var/static/image/aim_mode_visual = image('icons/mob/hud.dmi', null, "aim_mode")
	if(CHECK_BITFIELD(flags_gun_features, GUN_IS_AIMING))
		user.overlays -= aim_mode_visual
		DISABLE_BITFIELD(flags_gun_features, GUN_IS_AIMING)
		user.remove_movespeed_modifier(MOVESPEED_ID_AIM_MODE_SLOWDOWN)
		gun_iff_signal = null
		modify_fire_delay(-aim_fire_delay)
		to_chat(user, "<span class='notice'>You cease aiming.</b></span>")
		return
	if(!CHECK_BITFIELD(flags_item, WIELDED))
		to_chat(user, "<span class='notice'>You need to wield your gun before aiming.</b></span>")
		return
	if(!user.wear_id)
		to_chat(user, "<span class='notice'>You don't have distinguished allies you want to avoid shooting.</b></span>")
		return
	to_chat(user, "<span class='notice'>You steady your breathing...</b></span>")

	if(user.do_actions)
		return
	if(!user.marksman_aura)
		if(!do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_BAR, ignore_turf_checks = TRUE))
			to_chat(user, "<span class='warning'>Your concentration is interrupted!</b></span>")
			return
	if(!CHECK_BITFIELD(flags_item, WIELDED))
		to_chat(user, "<span class='notice'>You need to wield your gun before aiming.</b></span>")
		return
	user.overlays += aim_mode_visual
	ENABLE_BITFIELD(flags_gun_features, GUN_IS_AIMING)
	user.add_movespeed_modifier(MOVESPEED_ID_AIM_MODE_SLOWDOWN, TRUE, 0, NONE, TRUE, aim_speed_modifier)
	var/obj/item/card/id/C = user.wear_id
	gun_iff_signal = C.access
	modify_fire_delay(aim_fire_delay)
	to_chat(user, "<span class='notice'>You line up your aim, allowing you to shoot past allies.</b></span>")

/// Signal handler to activate the rail attachement of that gun if it's in our active hand
/obj/item/weapon/gun/proc/activate_rail_attachment()
	SIGNAL_HANDLER
	if(gun_user?.get_active_held_item() != src)
		return
	var/obj/item/attachable/underrail_attachment = LAZYACCESS(attachments, ATTACHMENT_SLOT_RAIL)
	underrail_attachment?.activate_attachment(gun_user)
	return COMSIG_KB_ACTIVATED

/// Signal handler to activate the underrail attachement of that gun if it's in our active hand
/obj/item/weapon/gun/proc/activate_underrail_attachment()
	SIGNAL_HANDLER
	if(gun_user?.get_active_held_item() != src)
		return
	var/obj/item/attachable/rail_attachment = LAZYACCESS(attachments, ATTACHMENT_SLOT_UNDER)
	rail_attachment?.activate_attachment(gun_user)
	return COMSIG_KB_ACTIVATED

/// Signal handler to unload that gun if it's in our active hand
/obj/item/weapon/gun/proc/unload_gun()
	SIGNAL_HANDLER
	if(gun_user?.get_active_held_item() != src)
		return
	unload(gun_user)
	return COMSIG_KB_ACTIVATED

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
