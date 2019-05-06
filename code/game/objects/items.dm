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

	var/sharp = FALSE		// whether this item cuts
	var/edge = FALSE		// whether this item is more likely to dismember
	var/pry_capable = FALSE //whether this item can be used to pry things open.
	var/heat_source = FALSE //whether this item is a source of heat, and how hot it is (in Kelvin).

	var/hitsound = null
	var/w_class = WEIGHT_CLASS_NORMAL
	var/storage_cost = null
	var/flags_item = NOFLAGS	//flags for item stuff that isn't clothing/equipping specific.
	var/flags_equip_slot = NOFLAGS		//This is used to determine on which slots an item can fit.

	//Since any item can now be a piece of clothing, this has to be put here so all items share it.
	var/flags_inventory = NOFLAGS //This flag is used for various clothing/equipment item stuff
	var/flags_inv_hide = NOFLAGS //This flag is used to determine when items in someone's inventory cover others. IE helmets making it so you can't see glasses, etc.
	flags_pass = PASSTABLE

	var/obj/item/master = null

	var/flags_armor_protection = NONE //see setup.dm for appropriate bit flags
	var/flags_heat_protection = NOFLAGS //flags which determine which body parts are protected from heat. Use the HEAD, CHEST, GROIN, etc. flags. See setup.dm
	var/flags_cold_protection = NOFLAGS //flags which determine which body parts are protected from cold. Use the HEAD, CHEST, GROIN, etc. flags. See setup.dm

	var/max_heat_protection_temperature //Set this variable to determine up to which temperature (IN KELVIN) the item protects against heat damage. Keep at null to disable protection. Only protects areas set by flags_heat_protection flags
	var/min_cold_protection_temperature //Set this variable to determine down to which temperature (IN KELVIN) the item protects against cold damage. 0 is NOT an acceptable number due to if(varname) tests!! Keep at null to disable protection. Only protects areas set by flags_cold_protection flags

	var/list/actions = list() //list of /datum/action's that this item has.
	var/list/actions_types = list() //list of paths of action datums to give to the item on New().

	//var/heat_transfer_coefficient = 1 //0 prevents all transfers, 1 is invisible
	var/gas_transfer_coefficient = 1 // for leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/permeability_coefficient = 1 // for chemicals/diseases
	var/siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit)
	var/slowdown = 0 // How much clothing is slowing you down. Negative values speeds you up

	var/list/allowed = null //suit storage stuff.
	var/obj/item/uplink/hidden/hidden_uplink = null // All items can have an uplink hidden inside, just remember to add the triggers.
	var/zoomdevicename = null //name used for message when binoculars/scope is used
	var/zoom = FALSE //TRUE if item is actively being used to zoom. For scoped guns and binoculars.

	var/list/uniform_restricted //Need to wear this uniform to equip this

	var/time_to_equip = 0 // set to ticks it takes to equip a worn suit.
	var/time_to_unequip = 0 // set to ticks it takes to unequip a worn suit.


	var/reach = 1

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
	GLOB.item_list += src
	for(var/path in actions_types)
		new path(src)
	if(w_class <= 3) //pulling small items doesn't slow you down much
		drag_delay = 1


/obj/item/Destroy()
	flags_item &= ~DELONDROP //to avoid infinite loop of unequip, delete, unequip, delete.
	flags_item &= ~NODROP //so the item is properly unequipped if on a mob.
	for(var/X in actions)
		actions -= X
		qdel(X)
	master = null
	GLOB.item_list -= src
	. = ..()



/obj/item/ex_act(severity)
	if(CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE))
		return
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(50))
				qdel(src)
		if(3)
			if(prob(5))
				qdel(src)


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

	if(!istype(src.loc, /turf) || usr.stat || usr.restrained() )
		return

	var/turf/T = src.loc

	src.loc = null

	src.loc = T

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
		if(!user.dropItemToGround(src))
			return
	else
		user.next_move = max(user.next_move+2,world.time + 2)
	if(!gc_destroyed) //item may have been cdel'd by the drop above.
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

	SEND_SIGNAL(src, COMSIG_ITEM_DROPPED, user)

	if(flags_item & DELONDROP)
		qdel(src)

// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	if(current_acid) //handle acid removal
		if(!ishuman(user)) //gotta have limbs Morty
			return
		user.visible_message("<span class='danger'>Corrosive substances seethe all over [user] as it retrieves the acid-soaked [src]!</span>",
		"<span class='danger'>Corrosive substances burn and seethe all over you upon retrieving the acid-soaked [src]!</span>")
		playsound(user, "acid_hit", 25)
		var/mob/living/carbon/human/H = user
		var/armor_block
		H.emote("pain")
		var/raw_damage = current_acid.acid_damage * 0.25 //It's spread over 4 areas.
		var/list/affected_limbs = list("l_hand", "r_hand", "l_arm", "r_arm")
		var/limb_count = null
		for(var/datum/limb/X in H.limbs)
			if(limb_count > 4) //All target limbs affected
				break
			if(!affected_limbs.Find(X.name) )
				continue
			armor_block = H.run_armor_check(X, "acid")
			if(istype(X) && X.take_damage_limb(0, rand(raw_damage * 0.75, raw_damage * 1.25), FALSE, FALSE, armor_block))
				H.UpdateDamageIcon()
			limb_count++
		H.updatehealth()
		qdel(current_acid)
		current_acid = null
	user.changeNext_move(CLICK_CD_RAPID)
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
	SEND_SIGNAL(src, COMSIG_ITEM_EQUIPPED, user, slot)
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
/obj/item/proc/mob_can_equip(M as mob, slot, warning = TRUE)
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
			if(SLOT_L_HAND)
				if(H.l_hand)
					return FALSE
				return TRUE
			if(SLOT_R_HAND)
				if(H.r_hand)
					return FALSE
				return TRUE
			if(SLOT_WEAR_MASK)
				if(H.wear_mask)
					return FALSE
				if(!(flags_equip_slot & ITEM_SLOT_MASK))
					return FALSE
				return TRUE
			if(SLOT_BACK)
				if(H.back)
					return FALSE
				if(!(flags_equip_slot & ITEM_SLOT_BACK))
					return FALSE
				return TRUE
			if(SLOT_WEAR_SUIT)
				if(H.wear_suit)
					return FALSE
				if(!(flags_equip_slot & ITEM_SLOT_OCLOTHING))
					return FALSE
				return TRUE
			if(SLOT_GLOVES)
				if(H.gloves)
					return FALSE
				if(!(flags_equip_slot & ITEM_SLOT_GLOVES))
					return FALSE
				return TRUE
			if(SLOT_SHOES)
				if(H.shoes)
					return FALSE
				if(!(flags_equip_slot & ITEM_SLOT_FEET))
					return FALSE
				return TRUE
			if(SLOT_BELT)
				if(H.belt)
					return FALSE
				if(!H.w_uniform && (SLOT_W_UNIFORM in mob_equip))
					if(warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return FALSE
				if(!(flags_equip_slot & ITEM_SLOT_BELT))
					return FALSE
				return TRUE
			if(SLOT_GLASSES)
				if(H.glasses)
					return FALSE
				if(!(flags_equip_slot & ITEM_SLOT_EYES))
					return FALSE
				return TRUE
			if(SLOT_HEAD)
				if(H.head)
					return FALSE
				if(!(flags_equip_slot & ITEM_SLOT_HEAD))
					return FALSE
				return TRUE
			if(SLOT_EARS)
				if(H.wear_ear)
					return FALSE
				if(!(flags_equip_slot & ITEM_SLOT_EARS))
					return FALSE
				return TRUE
			if(SLOT_W_UNIFORM)
				if(H.w_uniform)
					return FALSE
				if(!(flags_equip_slot & ITEM_SLOT_ICLOTHING))
					return FALSE
				return TRUE
			if(SLOT_WEAR_ID)
				if(H.wear_id)
					return FALSE
				if(!(flags_equip_slot & ITEM_SLOT_ID))
					return FALSE
				return TRUE
			if(SLOT_L_STORE)
				if(H.l_store)
					return FALSE
				if(!H.w_uniform && (SLOT_W_UNIFORM in mob_equip))
					if(warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return FALSE
				if(flags_equip_slot & ITEM_SLOT_DENYPOCKET)
					return FALSE
				if(w_class <= 2 || (flags_equip_slot & ITEM_SLOT_POCKET))
					return TRUE
			if(SLOT_R_STORE)
				if(H.r_store)
					return FALSE
				if(!H.w_uniform && (SLOT_W_UNIFORM in mob_equip))
					if(warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return FALSE
				if(flags_equip_slot & ITEM_SLOT_DENYPOCKET)
					return FALSE
				if(w_class <= 2 || (flags_equip_slot & ITEM_SLOT_POCKET))
					return TRUE
				return FALSE
			if(SLOT_S_STORE)
				if(H.s_store)
					return FALSE
				if(!H.wear_suit && (SLOT_WEAR_SUIT in mob_equip))
					if(warning)
						to_chat(H, "<span class='warning'>You need a suit before you can attach this [name].</span>")
					return FALSE
				if(!H.wear_suit.allowed)
					if(warning)
						to_chat(usr, "You somehow have a suit with no defined allowed items for suit storage, stop that.")
					return FALSE
				if(istype(src, /obj/item/tool/pen) || is_type_in_list(src, H.wear_suit.allowed) )
					return TRUE
				return FALSE
			if(SLOT_HANDCUFFED)
				if(H.handcuffed)
					return FALSE
				if(!istype(src, /obj/item/handcuffs))
					return FALSE
				return TRUE
			if(SLOT_LEGCUFFED)
				if(H.legcuffed)
					return FALSE
				if(!istype(src, /obj/item/legcuffs))
					return FALSE
				return TRUE
			if(SLOT_ACCESSORY)
				if(!istype(src, /obj/item/clothing/tie))
					return FALSE
				var/obj/item/clothing/under/U = H.w_uniform
				if(!U || U.hastie)
					return FALSE
				return TRUE
			if(SLOT_IN_BOOT)
				if(!istype(src, /obj/item/weapon/combat_knife) && !istype(src, /obj/item/weapon/throwing_knife))
					return FALSE
				var/obj/item/clothing/shoes/marine/B = H.shoes
				if(!B || !istype(B) || B.knife)
					return FALSE
				return TRUE
			if(SLOT_IN_BACKPACK)
				if (!H.back || !istype(H.back, /obj/item/storage/backpack))
					return FALSE
				var/obj/item/storage/backpack/B = H.back
				if(w_class > B.max_w_class || !B.can_be_inserted(src, warning))
					return FALSE
				return TRUE
			if(SLOT_IN_B_HOLSTER)
				if(!H.back || !istype(H.back, /obj/item/storage/large_holster))
					return FALSE
				var/obj/item/storage/S = H.back
				if(!S.can_be_inserted(src, warning))
					return FALSE
				return TRUE
			if(SLOT_IN_BELT)
				if(!H.belt || !istype(H.belt, /obj/item/storage/belt))
					return FALSE
				var/obj/item/storage/belt/S = H.belt
				if(!S.can_be_inserted(src, warning))
					return FALSE
				return TRUE
			if(SLOT_IN_HOLSTER)
				if((H.belt && istype(H.belt,/obj/item/storage/large_holster)) || (H.belt && istype(H.belt,/obj/item/storage/belt/gun)))
					var/obj/item/storage/S = H.belt
					if(S.can_be_inserted(src, warning))
						return TRUE
				return FALSE
			if(SLOT_IN_S_HOLSTER)
				if((H.s_store && istype(H.s_store, /obj/item/storage/large_holster)) ||(H.s_store && istype(H.s_store,/obj/item/storage/belt/gun)))
					var/obj/item/storage/S = H.s_store
					if(S.can_be_inserted(src, warning))
						return TRUE
				return FALSE
			if(SLOT_IN_STORAGE)
				if(!H.s_active)
					return FALSE
				var/obj/item/storage/S = H.s_active
				if(S.can_be_inserted(src, warning))
					return TRUE
			if(SLOT_IN_L_POUCH)
				if(!H.l_store || !istype(H.l_store, /obj/item/storage/pouch))
					return FALSE
				var/obj/item/storage/S = H.l_store
				if(S.can_be_inserted(src, warning))
					return TRUE
			if(SLOT_IN_R_POUCH)
				if(!H.r_store || !istype(H.r_store, /obj/item/storage/pouch))
					return FALSE
				var/obj/item/storage/S = H.r_store
				if(S.can_be_inserted(src, warning))
					return TRUE
			if(SLOT_IN_SUIT)
				var/obj/item/clothing/suit/storage/S = H.wear_suit
				if(!istype(S) || !S.pockets)
					return FALSE
				var/obj/item/storage/internal/T = S.pockets
				if(T.can_be_inserted(src, warning))
					return TRUE
			if(SLOT_IN_HEAD)
				var/obj/item/clothing/head/helmet/marine/S = H.head
				if(!istype(S) || !S.pockets)
					return FALSE
				var/obj/item/storage/internal/T = S.pockets
				if(T.can_be_inserted(src, warning))
					return TRUE
			if(SLOT_IN_ACCESSORY)
				var/obj/item/clothing/under/U = H.w_uniform
				if(!U?.hastie)
					return FALSE
				var/obj/item/clothing/tie/storage/T = U.hastie
				if(!istype(T))
					return FALSE
				var/obj/item/storage/internal/S = T.hold
				if(S.can_be_inserted(src, warning))
					return TRUE
		return FALSE //Unsupported slot
		//END HUMAN

	else if(ismonkey(M))
		//START MONKEY
		var/mob/living/carbon/monkey/MO = M
		switch(slot)
			if(SLOT_L_HAND)
				if(MO.l_hand)
					return FALSE
				return TRUE
			if(SLOT_R_HAND)
				if(MO.r_hand)
					return FALSE
				return TRUE
			if(SLOT_WEAR_MASK)
				if(MO.wear_mask)
					return FALSE
				if( !(flags_equip_slot & ITEM_SLOT_MASK) )
					return FALSE
				return TRUE
			if(SLOT_BACK)
				if(MO.back)
					return FALSE
				if( !(flags_equip_slot & ITEM_SLOT_BACK) )
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
	if(!usr.canmove || usr.stat || usr.restrained() || !Adjacent(usr))
		return
	if((!iscarbon(usr)) || (isbrain(usr)))//Is humanoid, and is not a brain
		to_chat(usr, "<span class='warning'>You can't pick things up!</span>")
		return
	if( usr.stat || usr.restrained() )//Is not asleep/dead and is not restrained
		to_chat(usr, "<span class='warning'>You can't pick things up!</span>")
		return
	if(src.anchored) //Object isn't anchored
		to_chat(usr, "<span class='warning'>You can't pick that up!</span>")
		return
	if(!usr.hand && usr.r_hand) //Right hand is not full
		to_chat(usr, "<span class='warning'>Your right hand is full.</span>")
		return
	if(usr.hand && usr.l_hand) //Left hand is not full
		to_chat(usr, "<span class='warning'>Your left hand is full.</span>")
		return
	if(!istype(src.loc, /turf)) //Object is on a turf
		to_chat(usr, "<span class='warning'>You can't pick that up!</span>")
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

	var/obj/item/I = get_active_held_item()
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

	for(var/obj/item/I in user.contents)
		if(I.zoom && I != src)
			to_chat(user, "<span class='warning'>You are already looking through \the [zoom_device].</span>")
			return //Return in the interest of not unzooming the other item. Check first in the interest of not fucking with the other clauses

	if(is_blind(user))
		to_chat(user, "<span class='warning'>You are too blind to see anything.</span>")
	else if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You do not have the dexterity to use \the [zoom_device].</span>")
	else if(!zoom && user.get_total_tint() >= TINT_HEAVY)
		to_chat(user, "<span class='warning'>Your vision is too obscured for you to look through \the [zoom_device].</span>")
	else if(!zoom && user.get_active_held_item() != src)
		to_chat(user, "<span class='warning'>You need to hold \the [zoom_device] to look through it.</span>")
	else if(zoom) //If we are zoomed out, reset that parameter.
		user.visible_message("<span class='notice'>[user] looks up from [zoom_device].</span>",
		"<span class='notice'>You look up from [zoom_device].</span>")
		zoom = !zoom
		user.zoom_cooldown = world.time + 20
		if(user.client.click_intercept)
			user.client.click_intercept = null
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
		else if(!istype(src, /obj/item/attachable/scope))
			user.set_interaction(src)
		return

	//General reset in case anything goes wrong, the view will always reset to default unless zooming in.
	if(user.client)
		user.client.change_view(world.view)
		user.client.pixel_x = 0
		user.client.pixel_y = 0

/obj/item/proc/eyecheck(mob/user)
	if(!ishuman(user))
		return TRUE
	var/safety = user.get_eye_protection()
	var/mob/living/carbon/human/H = user
	var/datum/internal_organ/eyes/E = H.internal_organs_by_name["eyes"]
	switch(safety)
		if(1)
			E.take_damage(rand(1, 2), TRUE)
		if(0)
			E.take_damage(rand(2, 4), TRUE)
		if(-1)
			H.blur_eyes(rand(12,20))
			E.take_damage(rand(12, 16), TRUE)
	if(safety<2)
		if(E.damage >= E.min_broken_damage)
			to_chat(H, "<span class='danger'>You can't see anything!</span>")
			H.blind_eyes(1)
		else if (E.damage >= E.min_bruised_damage)
			to_chat(H, "<span class='warning'>Your eyes are really starting to hurt. This can't be good for you!</span>")
			H.blind_eyes(5)
		else
			switch(safety)
				if(1)
					to_chat(user, "<span class='warning'>Your eyes sting a little.</span>")
				if(0)
					to_chat(user, "<span class='warning'>Your eyes burn.</span>")
				if(-1)
					to_chat(user, "<span class='danger'>Your eyes itch and burn severely.</span>")





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
		to_chat(user, "<span class='warning'>\The [src]'s water reserves are empty.</span>")
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
							qdel(atm)
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
			qdel(W)

	if(isspaceturf(user.loc) || user.lastarea.has_gravity == 0)
		user.inertia_dir = get_dir(target, user)
		step(user, user.inertia_dir)
	return
