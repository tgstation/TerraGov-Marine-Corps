/obj/item
	name = "item"
	icon = 'icons/obj/items/items.dmi'
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	var/image/blood_overlay = null //this saves our blood splatter overlay, which will be processed not to go over the edges of the sprite

	var/item_state = null //if you don't want to use icon_state for onmob inhand/belt/back/ear/suitstorage/glove sprite.
						//e.g. most headsets have different icon_state but they all use the same sprite when shown on the mob's ears.
						//also useful for items with many icon_state values when you don't want to make an inhand sprite for each value.
	var/r_speed = 1.0
	var/force = 0
	var/damtype = "brute"
	var/attack_speed = 11  //+3, Adds up to 10.  Added an extra 4 removed from /mob/proc/do_click()
	var/list/attack_verb = list() //Used in attackby() to say how something was attacked "[x] has been [z.attack_verb] by [y] with [z]"

	var/health = null

	var/sharp = FALSE		// whether this item cuts
	var/edge = FALSE		// whether this item is more likely to dismember
	var/pry_capable = FALSE //whether this item can be used to pry things open.
	var/heat_source = FALSE //whether this item is a source of heat, and how hot it is (in Kelvin).

	var/hitsound = null
	var/w_class = 3.0
	var/storage_cost = null
	var/flags_item = NOFLAGS	//flags for item stuff that isn't clothing/equipping specific.
	var/flags_equip_slot = NOFLAGS		//This is used to determine on which slots an item can fit.

	//Since any item can now be a piece of clothing, this has to be put here so all items share it.
	var/flags_inventory = NOFLAGS //This flag is used for various clothing/equipment item stuff
	var/flags_inv_hide = NOFLAGS //This flag is used to determine when items in someone's inventory cover others. IE helmets making it so you can't see glasses, etc.
	flags_pass = PASSTABLE

	var/obj/item/master = null

	var/flags_armor_protection = NOFLAGS //see setup.dm for appropriate bit flags
	var/flags_heat_protection = NOFLAGS //flags which determine which body parts are protected from heat. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/flags_cold_protection = NOFLAGS //flags which determine which body parts are protected from cold. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	var/max_heat_protection_temperature //Set this variable to determine up to which temperature (IN KELVIN) the item protects against heat damage. Keep at null to disable protection. Only protects areas set by flags_heat_protection flags
	var/min_cold_protection_temperature //Set this variable to determine down to which temperature (IN KELVIN) the item protects against cold damage. 0 is NOT an acceptable number due to if(varname) tests!! Keep at null to disable protection. Only protects areas set by flags_cold_protection flags

	var/list/actions = list() //list of /datum/action's that this item has.
	var/list/actions_types = list() //list of paths of action datums to give to the item on New().

	//var/heat_transfer_coefficient = 1 //0 prevents all transfers, 1 is invisible
	var/body_parts_covered = 0
	var/gas_transfer_coefficient = 1 // for leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/permeability_coefficient = 1 // for chemicals/diseases
	var/siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit)
	var/slowdown = 0 // How much clothing is slowing you down. Negative values speeds you up

	var/list/allowed = null //suit storage stuff.
	var/obj/item/device/uplink/hidden/hidden_uplink = null // All items can have an uplink hidden inside, just remember to add the triggers.
	var/zoomdevicename = null //name used for message when binoculars/scope is used
	var/zoom = FALSE //TRUE if item is actively being used to zoom. For scoped guns and binoculars.

	var/list/uniform_restricted //Need to wear this uniform to equip this

	var/time_to_equip = 0 // set to ticks it takes to equip a worn suit.
	var/time_to_unequip = 0 // set to ticks it takes to unequip a worn suit.

	/* Species-specific sprites, concept stolen from Paradise//vg/.
	ex:
	sprite_sheets = list(
		"Tajara" = 'icons/cat/are/bad'
		)
	If index term exists and icon_override is not set, this sprite sheet will be used.
	*/
	var/list/sprite_sheets = null
	var/icon_override = null  //Used to override hardcoded ON-MOB clothing dmis in human clothing proc (i.e. not the icon_state sprites).
	var/sprite_sheet_id = 0 //Select which sprite sheet ID to use due to the sprite limit per .dmi. 0 is default, 1 is the new one.

	/* Species-specific sprite sheets for inventory sprites
	Works similarly to worn sprite_sheets, except the alternate sprites are used when the clothing/refit_for_species() proc is called.
	*/
	var/list/sprite_sheets_obj = null

/obj/item/New(loc)
	..()
	item_list += src
	for(var/path in actions_types)
		new path(src)
	if(w_class <= 3) //pulling small items doesn't slow you down much
		drag_delay = 1


/obj/item/Dispose()
	flags_item &= ~DELONDROP //to avoid infinite loop of unequip, delete, unequip, delete.
	flags_item &= ~NODROP //so the item is properly unequipped if on a mob.
	for(var/X in actions)
		actions -= X
		cdel(X)
	master = null
	item_list -= src
	. = ..()



/obj/item/ex_act(severity)
	switch(severity)
		if(1)
			cdel(src)
		if(2)
			if(prob(50))
				cdel(src)
		if(3)
			if(prob(5))
				cdel(src)


//user: The mob that is suiciding
//damagetype: The type of damage the item will inflict on the user
//BRUTELOSS = 1
//FIRELOSS = 2
//TOXLOSS = 4
//OXYLOSS = 8
//Output a creative message and then return the damagetype done
/obj/item/proc/suicide_act(mob/user)
	return

/obj/item/verb/move_to_top()
	set name = "Move To Top"
	set category = "Object"
	set src in oview(1)

	if(!istype(src.loc, /turf) || usr.stat || usr.is_mob_restrained() )
		return

	var/turf/T = src.loc

	src.loc = null

	src.loc = T

/*Global item proc for all of your unique item skin needs. Works with any
item, and will change the skin to whatever you specify here. You can also
manually override the icon with a unique skin if wanted, for the outlier
cases. Override_icon_state should be a list.*/
/obj/item/proc/select_gamemode_skin(expected_type, list/override_icon_state, override_name, list/override_protection)
	if(type == expected_type)
		var/new_icon_state
		var/new_name
		var/new_protection
		if(override_icon_state && override_icon_state.len) new_icon_state = override_icon_state[map_tag]
		if(override_name) new_name = override_name[map_tag]
		if(override_protection && override_protection.len) new_protection = override_protection[map_tag]
		switch(map_tag)
			if(MAP_ICE_COLONY) //Can easily add other states if needed.
				icon_state = new_icon_state ? new_icon_state : "s_" + icon_state
				if(new_name) name = new_name
				if(new_protection) min_cold_protection_temperature = new_protection
			if(MAP_WHISKEY_OUTPOST) //Can easily add other states if needed.
				icon_state = new_icon_state ? new_icon_state : "d_" + icon_state
				if(new_name) name = new_name
				if(new_protection) min_cold_protection_temperature = new_protection

		item_state = icon_state

/obj/item/attack_hand(mob/user as mob)
	if (!user)
		return

	if(anchored)
		to_chat(user, "[src] is anchored to the ground.")
		return

	if (istype(src.loc, /obj/item/storage))
		var/obj/item/storage/S = src.loc
		S.remove_from_storage(src, user.loc)

	throwing = FALSE

	if(loc == user)
		if(!user.drop_inv_item_on_ground(src))
			return
	else
		user.next_move = max(user.next_move+2,world.time + 2)
	if(!disposed) //item may have been cdel'd by the drop above.
		pickup(user)
		add_fingerprint(user)
		if(!user.put_in_active_hand(src))
			dropped(user)


/obj/item/attack_paw(mob/user as mob)
	return attack_hand(user)

// Due to storage type consolidation this should get used more now.
// I have cleaned it up a little, but it could probably use more.  -Sayu
/obj/item/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/storage))
		var/obj/item/storage/S = W
		if(S.use_to_pickup && isturf(loc))
			if(S.collection_mode) //Mode is set to collect all items on a tile and we clicked on a valid one.
				var/list/rejections = list()
				var/success = FALSE
				var/failure = FALSE

				for(var/obj/item/I in src.loc)
					if(I.type in rejections) // To limit bag spamming: any given type only complains once
						continue
					if(!S.can_be_inserted(I))	// Note can_be_inserted still makes noise when the answer is no
						rejections += I.type	// therefore full bags are still a little spammy
						failure = TRUE
						continue
					success = TRUE
					S.handle_item_insertion(I, TRUE, user)	//The 1 stops the "You put the [src] into [S]" insertion message from being displayed.
				if(success && !failure)
					to_chat(user, "<span class='notice'>You put everything in [S].</span>")
				else if(success)
					to_chat(user, "<span class='notice'>You put some things in [S].</span>")
				else
					to_chat(user, "<span class='notice'>You fail to pick anything up with [S].</span>")

			else if(S.can_be_inserted(src))
				S.handle_item_insertion(src, FALSE, user)

	return

/obj/item/proc/talk_into(mob/M as mob, text)
	return

/obj/item/proc/moved(mob/user as mob, old_loc as turf)
	return

// apparently called whenever an item is removed from a slot, container, or anything else.
//the call happens after the item's potential loc change.
/obj/item/proc/dropped(mob/user as mob)
	if(user && user.client) //Dropped when disconnected, whoops
		if(zoom) //binoculars, scope, etc
			zoom(user, 11, 12)

	for(var/X in actions)
		var/datum/action/A = X
		A.remove_action(user)

	if(flags_item & DELONDROP)
		cdel(src)

// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	return

// called when this item is removed from a storage item, which is passed on as S. The loc variable is already set to the new destination before this is called.
/obj/item/proc/on_exit_storage(obj/item/storage/S as obj)
	return

// called when this item is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/obj/item/proc/on_enter_storage(obj/item/storage/S as obj)
	return

// called when "found" in pockets and storage items. Returns 1 if the search should end.
/obj/item/proc/on_found(mob/finder as mob)
	return

// called after an item is placed in an equipment slot
// user is mob that equipped it
// slot uses the slot_X defines found in setup.dm
// for items that can be placed in multiple slots
// note this isn't called during the initial dressing of a player
/obj/item/proc/equipped(mob/user, slot)
	for(var/X in actions)
		var/datum/action/A = X
		if(item_action_slot_check(user, slot)) //some items only give their actions buttons when in a specific slot.
			A.give_action(user)

//sometimes we only want to grant the item's action if it's equipped in a specific slot.
/obj/item/proc/item_action_slot_check(mob/user, slot)
	return TRUE

// The mob M is attempting to equip this item into the slot passed through as 'slot'. Return 1 if it can do this and 0 if it can't.
// If you are making custom procs but would like to retain partial or complete functionality of this one, include a 'return ..()' to where you want this to happen.
// Set disable_warning to 1 if you wish it to not give you outputs.
// warning_text is used in the case that you want to provide a specific warning for why the item cannot be equipped.
/obj/item/proc/mob_can_equip(M as mob, slot, disable_warning = 0)
	if(!slot)
		return FALSE
	if(!M)
		return FALSE

	if(ishuman(M))
		//START HUMAN
		var/mob/living/carbon/human/H = M
		var/list/mob_equip = list()
		if(H.species.hud && H.species.hud.equip_slots)
			mob_equip = H.species.hud.equip_slots

		if(H.species && !(slot in mob_equip))
			return FALSE

		switch(slot)
			if(WEAR_L_HAND)
				if(H.l_hand)
					return FALSE
				return TRUE
			if(WEAR_R_HAND)
				if(H.r_hand)
					return FALSE
				return TRUE
			if(WEAR_FACE)
				if(H.wear_mask)
					return FALSE
				if(!(flags_equip_slot & SLOT_FACE))
					return FALSE
				return TRUE
			if(WEAR_BACK)
				if(H.back)
					return FALSE
				if(!(flags_equip_slot & SLOT_BACK))
					return FALSE
				return TRUE
			if(WEAR_JACKET)
				if(H.wear_suit)
					return FALSE
				if(!(flags_equip_slot & SLOT_OCLOTHING))
					return FALSE
				return TRUE
			if(WEAR_HANDS)
				if(H.gloves)
					return FALSE
				if(!(flags_equip_slot & SLOT_HANDS))
					return FALSE
				return TRUE
			if(WEAR_FEET)
				if(H.shoes)
					return FALSE
				if(!(flags_equip_slot & SLOT_FEET))
					return FALSE
				return TRUE
			if(WEAR_WAIST)
				if(H.belt)
					return FALSE
				if(!H.w_uniform && (WEAR_BODY in mob_equip))
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return FALSE
				if(!(flags_equip_slot & SLOT_WAIST))
					return FALSE
				return TRUE
			if(WEAR_EYES)
				if(H.glasses)
					return FALSE
				if(!(flags_equip_slot & SLOT_EYES))
					return FALSE
				return TRUE
			if(WEAR_HEAD)
				if(H.head)
					return FALSE
				if(!(flags_equip_slot & SLOT_HEAD))
					return FALSE
				return TRUE
			if(WEAR_EAR)
				if(H.wear_ear)
					return FALSE
				if(!(flags_equip_slot & SLOT_EAR))
					return FALSE
				return TRUE
			if(WEAR_BODY)
				if(H.w_uniform)
					return FALSE
				if(!(flags_equip_slot & SLOT_ICLOTHING))
					return FALSE
				return TRUE
			if(WEAR_ID)
				if(H.wear_id)
					return FALSE
				if(!(flags_equip_slot & SLOT_ID))
					return FALSE
				return TRUE
			if(WEAR_L_STORE)
				if(H.l_store)
					return FALSE
				if(!H.w_uniform && (WEAR_BODY in mob_equip))
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return FALSE
				if(flags_equip_slot & SLOT_NO_STORE)
					return FALSE
				if(w_class <= 2 || (flags_equip_slot & SLOT_STORE))
					return TRUE
			if(WEAR_R_STORE)
				if(H.r_store)
					return FALSE
				if(!H.w_uniform && (WEAR_BODY in mob_equip))
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return FALSE
				if(flags_equip_slot & SLOT_NO_STORE)
					return FALSE
				if(w_class <= 2 || (flags_equip_slot & SLOT_STORE))
					return TRUE
				return FALSE
			if(WEAR_J_STORE)
				if(H.s_store)
					return FALSE
				if(!H.wear_suit && (WEAR_JACKET in mob_equip))
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a suit before you can attach this [name].</span>")
					return FALSE
				if(!H.wear_suit.allowed)
					if(!disable_warning)
						to_chat(usr, "You somehow have a suit with no defined allowed items for suit storage, stop that.")
					return FALSE
				if( istype(src, /obj/item/device/pda) || istype(src, /obj/item/tool/pen) || is_type_in_list(src, H.wear_suit.allowed) )
					return TRUE
				return FALSE
			if(WEAR_HANDCUFFS)
				if(H.handcuffed)
					return FALSE
				if(!istype(src, /obj/item/handcuffs))
					return FALSE
				return TRUE
			if(WEAR_LEGCUFFS)
				if(H.legcuffed)
					return FALSE
				if(!istype(src, /obj/item/legcuffs))
					return FALSE
				return TRUE
			if(WEAR_ACCESSORY)
				if(!istype(src, /obj/item/clothing/tie))
					return FALSE
				var/obj/item/clothing/under/U = H.w_uniform
				if(!U || U.hastie)
					return FALSE
				return TRUE
			if(EQUIP_IN_BOOT)
				if(!istype(src, /obj/item/weapon/combat_knife) && !istype(src, /obj/item/weapon/throwing_knife))
					return FALSE
				var/obj/item/clothing/shoes/marine/B = H.shoes
				if(!B || !istype(B) || B.knife)
					return FALSE
				return TRUE
			if(WEAR_IN_BACK)
				if (!H.back || !istype(H.back, /obj/item/storage/backpack))
					return FALSE
				var/obj/item/storage/backpack/B = H.back
				if(src.w_class <= B.max_w_class && B.can_be_inserted(src))
					return TRUE
			if(WEAR_IN_B_HOLSTER)
				if (H.back && istype(H.back, /obj/item/storage/large_holster))
					var/obj/item/storage/S = H.back
					if(S.can_be_inserted(src))
						return TRUE
				return FALSE
			if(WEAR_IN_HOLSTER)
				if((H.belt && istype(H.belt,/obj/item/storage/large_holster)) || (H.belt && istype(H.belt,/obj/item/storage/belt/gun)))
					var/obj/item/storage/S = H.belt
					if(S.can_be_inserted(src))
						return TRUE
				return FALSE
			if(WEAR_IN_J_HOLSTER)
				if((H.s_store && istype(H.s_store, /obj/item/storage/large_holster)) ||(H.s_store && istype(H.s_store,/obj/item/storage/belt/gun)))
					var/obj/item/storage/S = H.s_store
					if(S.can_be_inserted(src))
						return TRUE
				return FALSE
			if(EQUIP_IN_STORAGE)
				if(!H.s_active)
					return FALSE
				var/obj/item/storage/S = H.s_active
				if(S.can_be_inserted(src))
					return TRUE
			if(EQUIP_IN_L_POUCH)
				if(!H.l_store || !istype(H.l_store, /obj/item/storage/pouch))
					return FALSE
				var/obj/item/storage/S = H.l_store
				if(S.can_be_inserted(src))
					return TRUE
			if(EQUIP_IN_R_POUCH)
				if(!H.r_store || !istype(H.r_store, /obj/item/storage/pouch))
					return FALSE
				var/obj/item/storage/S = H.r_store
				if(S.can_be_inserted(src))
					return TRUE
		return FALSE //Unsupported slot
		//END HUMAN

	else if(ismonkey(M))
		//START MONKEY
		var/mob/living/carbon/monkey/MO = M
		switch(slot)
			if(WEAR_L_HAND)
				if(MO.l_hand)
					return FALSE
				return TRUE
			if(WEAR_R_HAND)
				if(MO.r_hand)
					return FALSE
				return TRUE
			if(WEAR_FACE)
				if(MO.wear_mask)
					return FALSE
				if( !(flags_equip_slot & SLOT_FACE) )
					return FALSE
				return TRUE
			if(WEAR_BACK)
				if(MO.back)
					return FALSE
				if( !(flags_equip_slot & SLOT_BACK) )
					return FALSE
				return TRUE
		return FALSE //Unsupported slot

		//END MONKEY


/obj/item/verb/verb_pickup()
	set src in oview(1)
	set category = "Object"
	set name = "Pick up"

	if(!(usr)) //BS12 EDIT
		return
	if(!usr.canmove || usr.stat || usr.is_mob_restrained() || !Adjacent(usr))
		return
	if((!istype(usr, /mob/living/carbon)) || (istype(usr, /mob/living/brain)))//Is humanoid, and is not a brain
		to_chat(usr, "\red You can't pick things up!")
		return
	if( usr.stat || usr.is_mob_restrained() )//Is not asleep/dead and is not restrained
		to_chat(usr, "\red You can't pick things up!")
		return
	if(src.anchored) //Object isn't anchored
		to_chat(usr, "\red You can't pick that up!")
		return
	if(!usr.hand && usr.r_hand) //Right hand is not full
		to_chat(usr, "\red Your right hand is full.")
		return
	if(usr.hand && usr.l_hand) //Left hand is not full
		to_chat(usr, "\red Your left hand is full.")
		return
	if(!istype(src.loc, /turf)) //Object is on a turf
		to_chat(usr, "\red You can't pick that up!")
		return
	//All checks are done, time to pick it up!
	usr.UnarmedAttack(src)
	return


//This proc is executed when someone clicks the on-screen UI button. To make the UI button show, set the 'icon_action_button' to the icon_state of the image of the button in actions.dmi
//The default action is attack_self().
//Checks before we get to here are: mob is alive, mob is not restrained, paralyzed, asleep, resting, laying, item is on the mob.
/obj/item/proc/ui_action_click()
	if( src in usr )
		attack_self(usr)


/obj/item/proc/IsShield()
	return FALSE

/obj/item/proc/get_loc_turf()
	var/atom/L = loc
	while(L && !istype(L, /turf/))
		L = L.loc
	return loc


/obj/item/proc/showoff(mob/user)
	for (var/mob/M in view(user))
		M.show_message("[user] holds up [src]. <a HREF=?src=\ref[M];lookitem=\ref[src]>Take a closer look.</a>",1)

/mob/living/carbon/verb/showoff()
	set name = "Show Held Item"
	set category = "Object"

	var/obj/item/I = get_active_hand()
	if(I && !(I.flags_item & ITEM_ABSTRACT))
		I.showoff(src)

/*
For zooming with scope or binoculars. This is called from
modules/mob/mob_movement.dm if you move you will be zoomed out
modules/mob/living/carbon/human/life.dm if you die, you will be zoomed out.
*/

/obj/item/proc/zoom(mob/living/user, tileoffset = 11, viewsize = 12) //tileoffset is client view offset in the direction the user is facing. viewsize is how far out this thing zooms. 7 is normal view
	if(!user)
		return
	var/zoom_device = zoomdevicename ? "\improper [zoomdevicename] of [src]" : "\improper [src]"
	var/mob/living/carbon/human/H = user

	for(var/obj/item/I in user.contents)
		if(I.zoom && I != src)
			to_chat(user, "<span class='warning'>You are already looking through \the [zoom_device].</span>")
			return //Return in the interest of not unzooming the other item. Check first in the interest of not fucking with the other clauses

	if(is_blind(user))
		to_chat(user, "<span class='warning'>You are too blind to see anything.</span>")
	else if(user.stat || !ishuman(user))
		to_chat(user, "<span class='warning'>You are unable to focus through \the [zoom_device].</span>")
	else if(!zoom && user.client && H.tinttotal >= 3)
		to_chat(user, "<span class='warning'>Your welding equipment gets in the way of you looking through \the [zoom_device].</span>")
	else if(!zoom && user.get_active_hand() != src)
		to_chat(user, "<span class='warning'>You need to hold \the [zoom_device] to look through it.</span>")
	else if(zoom) //If we are zoomed out, reset that parameter.
		user.visible_message("<span class='notice'>[user] looks up from [zoom_device].</span>",
		"<span class='notice'>You look up from [zoom_device].</span>")
		zoom = !zoom
		user.zoom_cooldown = world.time + 20
	else //Otherwise we want to zoom in.
		if(world.time <= user.zoom_cooldown) //If we are spamming the zoom, cut it out
			return
		user.zoom_cooldown = world.time + 20

		if(user.client)
			user.client.change_view(viewsize)

			var/tilesize = 32
			var/viewoffset = tilesize * tileoffset

			switch(user.dir)
				if(NORTH)
					user.client.pixel_x = 0
					user.client.pixel_y = viewoffset
				if(SOUTH)
					user.client.pixel_x = 0
					user.client.pixel_y = -viewoffset
				if(EAST)
					user.client.pixel_x = viewoffset
					user.client.pixel_y = 0
				if(WEST)
					user.client.pixel_x = -viewoffset
					user.client.pixel_y = 0

		user.visible_message("<span class='notice'>[user] peers through \the [zoom_device].</span>",
		"<span class='notice'>You peer through \the [zoom_device].</span>")
		zoom = !zoom
		if(user.interactee)
			user.unset_interaction()
		else
			user.set_interaction(src)
		return

	//General reset in case anything goes wrong, the view will always reset to default unless zooming in.
	if(user.client)
		user.client.change_view(world.view)
		user.client.pixel_x = 0
		user.client.pixel_y = 0

/obj/item/proc/eyecheck(mob/user)
	if(!ishuman(user))
		return 1
	var/safety = user.get_eye_protection()
	var/mob/living/carbon/human/H = user
	var/datum/internal_organ/eyes/E = H.internal_organs_by_name["eyes"]
	if(!E)
		return
	if(E.robotic == ORGAN_ROBOT)
		return
	switch(safety)
		if(1)
			to_chat(user, "<span class='danger'>Your eyes sting a little.</span>")
			E.damage += rand(1, 2)
			if(E.damage > 12)
				H.eye_blurry += rand(3,6)
		if(0)
			to_chat(user, "<span class='warning'>Your eyes burn.</span>")
			E.damage += rand(2, 4)
			if(E.damage > 10)
				E.damage += rand(4,10)
		if(-1)
			to_chat(user, "<span class='warning'>Your thermals intensify [src]'s glow. Your eyes itch and burn severely.</span>")
			H.eye_blurry += rand(12,20)
			E.damage += rand(12, 16)
	if(safety<2)
		if(E.damage > 10)
			to_chat(H, "<span class='warning'>Your eyes are really starting to hurt. This can't be good for you!</span>")
		if(E.damage >= E.min_broken_damage)
			to_chat(H, "<span class='warning'>You go blind!</span>")
			H.sdisabilities |= BLIND
		else if (E.damage >= E.min_bruised_damage)
			to_chat(H, "<span class='warning'>You go blind!</span>")
			H.eye_blind = 5
			H.eye_blurry = 5
			H.disabilities |= NEARSIGHTED
			spawn(100)
				H.disabilities &= ~NEARSIGHTED

//This proc is here to prevent Xenomorphs from picking up objects (default attack_hand behaviour)
//Note that this is overriden by every proc concerning a child of obj unless inherited
/obj/item/attack_alien(mob/living/carbon/Xenomorph/M)
	return FALSE

/obj/item/proc/update_action_button_icons()
	for(var/X in actions)
		var/datum/action/A = X
		A.update_button_icon()

/obj/item/proc/extinguish(atom/target, mob/user)

	if (reagents.total_volume < 1)
		to_chat(user, "\red \The [src]'s water reserves are empty.")
		return

	user.visible_message("<span class='danger'>[user] sprays water from [src]!</span>", \
	"<span class='warning'>You spray water from [src].</span>",)

	playsound(user.loc, 'sound/effects/extinguish.ogg', 52, 1, 7)

	var/direction = get_dir(user,target)

	if(user.buckled && isobj(user.buckled) && !user.buckled.anchored )
		spawn(0)
			var/obj/structure/bed/chair/C = null
			if(istype(user.buckled, /obj/structure/bed/chair))
				C = user.buckled
			var/obj/B = user.buckled
			var/movementdirection = turn(direction,180)
			if(C)
				C.propelled = 4
			B.Move(get_step(user,movementdirection), movementdirection)
			sleep(1)
			B.Move(get_step(user,movementdirection), movementdirection)
			if(C)
				C.propelled = 3
			sleep(1)
			B.Move(get_step(user,movementdirection), movementdirection)
			sleep(1)
			B.Move(get_step(user,movementdirection), movementdirection)
			if(C)
				C.propelled = 2
			sleep(2)
			B.Move(get_step(user,movementdirection), movementdirection)
			if(C)
				C.propelled = 1
			sleep(2)
			B.Move(get_step(user,movementdirection), movementdirection)
			if(C)
				C.propelled = 0
			sleep(3)
			B.Move(get_step(user,movementdirection), movementdirection)
			sleep(3)
			B.Move(get_step(user,movementdirection), movementdirection)
			sleep(3)
			B.Move(get_step(user,movementdirection), movementdirection)

	var/turf/T = get_turf(target)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))

	var/list/the_targets = list(T,T1,T2)

	for(var/a=0, a<7, a++)
		spawn(0)
			var/obj/effect/particle_effect/water/W = new /obj/effect/particle_effect/water( get_turf(user) )
			var/turf/my_target = pick(the_targets)
			var/datum/reagents/R = new/datum/reagents(5)
			if(!W)
				return
			W.reagents = R
			R.my_atom = W
			if(!W || !src)
				return
			reagents.trans_to(W,1)
			for(var/b=0, b<7, b++)
				step_towards(W,my_target)
				if(!(W?.reagents))
					return
				W.reagents.reaction(get_turf(W))
				for(var/atom/atm in get_turf(W))
					if(!W)
						return
					if(!W.reagents)
						break
					W.reagents.reaction(atm)
					if(istype(atm, /obj/flamer_fire))
						var/obj/flamer_fire/FF = atm
						if(FF.firelevel > 20)
							FF.firelevel -= 20
							FF.updateicon()
						else
							cdel(atm)
						continue
					if(isliving(atm)) //For extinguishing mobs on fire
						var/mob/living/M = atm
						M.ExtinguishMob()
						for(var/obj/item/clothing/mask/cigarette/C in M.contents)
							if(C.item_state == C.icon_on)
								C.die()
				if(W.loc == my_target)
					break
				sleep(2)
			cdel(W)

	if((istype(user.loc, /turf/open/space)) || (user.lastarea.has_gravity == 0))
		user.inertia_dir = get_dir(target, user)
		step(user, user.inertia_dir)
	return
