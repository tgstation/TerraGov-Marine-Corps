/obj/item
	name = "item"
	icon = 'icons/obj/items/items.dmi'
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	materials = list(/datum/material/metal = 50)
	light_system = MOVABLE_LIGHT
	flags_pass = PASSTABLE
	flags_atom = PREVENT_CONTENTS_EXPLOSION

	var/image/blood_overlay = null //this saves our blood splatter overlay, which will be processed not to go over the edges of the sprite
	///The iconstate that the items use for blood on blood.dmi when drawn on the mob.
	var/blood_sprite_state


	var/item_state = null //if you don't want to use icon_state for onmob inhand/belt/back/ear/suitstorage/glove sprite.
						//e.g. most headsets have different icon_state but they all use the same sprite when shown on the mob's ears.
						//also useful for items with many icon_state values when you don't want to make an inhand sprite for each value.
	///The icon state used to represent this image in "icons/obj/items/items_mini.dmi" Used in /obj/item/storage/box/visual to display tiny items in the box
	var/icon_state_mini = "item"
	var/force = 0
	var/damtype = BRUTE
	///Byond tick delay between left click attacks
	var/attack_speed = 11
	///Byond tick delay between right click alternate attacks
	var/attack_speed_alternate = 11
	var/list/attack_verb //Used in attackby() to say how something was attacked "[x] has been [z.attack_verb] by [y] with [z]"

	var/sharp = FALSE		// whether this item cuts
	var/edge = FALSE		// whether this item is more likely to dismember
	var/pry_capable = FALSE //whether this item can be used to pry things open.
	var/heat = 0 //whether this item is a source of heat, and how hot it is (in Kelvin).

	var/hitsound = null
	var/w_class = WEIGHT_CLASS_NORMAL
	var/flags_item = NONE	//flags for item stuff that isn't clothing/equipping specific.
	var/flags_equip_slot = NONE		//This is used to determine on which slots an item can fit.

	//Since any item can now be a piece of clothing, this has to be put here so all items share it.
	var/flags_inventory = NONE //This flag is used for various clothing/equipment item stuff
	var/flags_inv_hide = NONE //This flag is used to determine when items in someone's inventory cover others. IE helmets making it so you can't see glasses, etc.

	var/obj/item/master = null

	var/flags_armor_protection = NONE //see setup.dm for appropriate bit flags
	var/flags_heat_protection = NONE //flags which determine which body parts are protected from heat. Use the HEAD, CHEST, GROIN, etc. flags. See setup.dm
	var/flags_cold_protection = NONE //flags which determine which body parts are protected from cold. Use the HEAD, CHEST, GROIN, etc. flags. See setup.dm

	var/max_heat_protection_temperature //Set this variable to determine up to which temperature (IN KELVIN) the item protects against heat damage. Keep at null to disable protection. Only protects areas set by flags_heat_protection flags
	var/min_cold_protection_temperature //Set this variable to determine down to which temperature (IN KELVIN) the item protects against cold damage. 0 is NOT an acceptable number due to if(varname) tests!! Keep at null to disable protection. Only protects areas set by flags_cold_protection flags

	var/list/actions = list() //list of /datum/action's that this item has.
	var/list/actions_types = list() //list of paths of action datums to give to the item on Initialize().

	var/gas_transfer_coefficient = 1 // for leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/permeability_coefficient = 1 // for chemicals/diseases
	var/siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit)
	var/slowdown = 0 // How much clothing is slowing you down. Negative values speeds you up
	var/breakouttime = 0

	///list() of species types, if a species cannot put items in a certain slot, but species type is in list, it will be able to wear that item
	var/list/species_exception = null

	var/list/allowed = null //suit storage stuff.
	///name used for message when binoculars/scope is used
	var/zoomdevicename = null
	///TRUE if item is actively being used to zoom. For scoped guns and binoculars.
	var/zoom = FALSE
	///how much tiles the zoom offsets to the direction it zooms to.
	var/zoom_tile_offset = 6
	///how much tiles the zoom zooms out, 7 is the default view.
	var/zoom_viewsize = 7
	///if you can move with the zoom on, only works if zoom_view_size is 7 otherwise CRASH() is called due to maptick performance reasons.
	var/zoom_allow_movement = FALSE

	var/datum/embedding_behavior/embedding
	var/mob/living/embedded_into

	var/time_to_equip = 0 // set to ticks it takes to equip a worn suit.
	var/time_to_unequip = 0 // set to ticks it takes to unequip a worn suit.


	var/reach = 1


	/// Species-specific sprites, concept stolen from Paradise//vg/. Ex: sprite_sheets = list("Combat Robot" = 'icons/mob/species/robot/backpack.dmi') If index term exists and icon_override is not set, this sprite sheet will be used.
	var/list/sprite_sheets = null

	//** These specify item/icon overrides for _slots_

	///>Lazylist< that overrides the default item_state for particular slots.
	var/list/item_state_slots
	///>LazyList< Used to specify the icon file to be used when the item is worn in a certain slot. icon_override or sprite_sheets are set they will take precendence over this, assuming they apply to the slot in question.
	var/list/item_icons
	///specific layer for on-mob icon.
	var/worn_layer
	///tells if the item shall use item_state for non-inhands, needed due to some items using item_state only for inhands and not worn.
	var/item_state_worn = FALSE
	///overrides the icon file which the item will be used to render on mob, if its in hands it will add _l or _r to the state depending if its on left or right hand.
	var/icon_override = null
	///Dimensions of the icon file used when this item is worn, eg: hats.dmi (32x32 sprite, 64x64 sprite, etc.). Allows inhands/worn sprites to be of any size, but still centered on a mob properly
	var/worn_x_dimension = 32
	///Dimensions of the icon file used when this item is worn, eg: hats.dmi (32x32 sprite, 64x64 sprite, etc.). Allows inhands/worn sprites to be of any size, but still centered on a mob properly
	var/worn_y_dimension = 32
	///Same as for [worn_x_dimension][/obj/item/var/worn_x_dimension] but for inhands.
	var/inhand_x_dimension = 32
	///Same as for [worn_y_dimension][/obj/item/var/worn_y_dimension] but for inhands.
	var/inhand_y_dimension = 32
	/// Worn overlay will be shifted by this along x axis
	var/worn_x_offset = 0
	/// Worn overlay will be shifted by this along y axis
	var/worn_y_offset = 0
	///Worn nhand overlay will be shifted by this along x axis
	var/inhand_x_offset = 0
	///Worn inhand overlay will be shifted by this along y axis
	var/inhand_y_offset = 0

	var/flags_item_map_variant = NONE

	//TOOL RELATED VARS
	var/tool_behaviour = FALSE
	var/toolspeed = 1
	var/usesound = null

	var/active = FALSE


/obj/item/Initialize()

	if(species_exception)
		species_exception = string_list(species_exception)

	. = ..()

	for(var/path in actions_types)
		new path(src)
	if(w_class <= 3) //pulling small items doesn't slow you down much
		drag_delay = 1

	if(!embedding)
		embedding = getEmbeddingBehavior()
	else if(islist(embedding))
		embedding = getEmbeddingBehavior(arglist(embedding))

	if(flags_item_map_variant)
		update_item_sprites()


/obj/item/Destroy()
	flags_item &= ~DELONDROP //to avoid infinite loop of unequip, delete, unequip, delete.
	flags_item &= ~NODROP //so the item is properly unequipped if on a mob.
	if(ismob(loc))
		var/mob/m = loc
		m.temporarilyRemoveItemFromInventory(src, TRUE)
	for(var/X in actions)
		qdel(X)
	master = null
	embedding = null
	embedded_into = null //Should have been removed by temporarilyRemoveItemFromInventory, but let's play it safe.
	GLOB.cryoed_item_list -= src
	return ..()


/obj/item/proc/update_item_state(mob/user)
	item_state = "[initial(icon_state)][flags_item & WIELDED ? "_w" : ""]"


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

	if(!isturf(loc) || usr.stat || usr.restrained())
		return

	var/turf/T = loc
	loc = null
	loc = T

/obj/item/get_examine_name(mob/user)
	. = "\a [src]"
	var/list/override = list(gender == PLURAL ? "some" : "a", " ", "[name]")
	if(article)
		. = "[article] [src]"
		override[EXAMINE_POSITION_ARTICLE] = article
	if(blood_color)
		override[EXAMINE_POSITION_BEFORE] = blood_color != "#030303" ? " bloody " : " oil-stained "
		. = "\a [blood_color != "#030303" ? "bloody" : "oil-stained"] [src]"
	if(SEND_SIGNAL(src, COMSIG_ATOM_GET_EXAMINE_NAME, user, override) & COMPONENT_EXNAME_CHANGED)
		. = override.Join("")

/obj/item/examine(mob/user)
	. = ..()
	. += "[gender == PLURAL ? "They are" : "It is"] a [weight_class_to_text(w_class)] item."

/obj/item/attack_ghost(mob/dead/observer/user)
	if(!can_interact(user))
		return

	return interact(user)


/obj/item/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!user)
		return
	if(!istype(user))
		return
	if(anchored)
		to_chat(user, "[src] is anchored to the ground.")
		return

	set_throwing(FALSE)

	if(istype(loc, /obj/item/storage))
		var/obj/item/storage/S = loc
		if(!S.remove_from_storage(src, user.loc, user))
			return

	if(loc == user && !user.temporarilyRemoveItemFromInventory(src))
		return

	if(QDELETED(src))
		return

	pickup(user)
	if(!user.put_in_active_hand(src))
		user.dropItemToGround(src)
		dropped(user)


// Due to storage type consolidation this should get used more now.
// I have cleaned it up a little, but it could probably use more.  -Sayu
/obj/item/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!istype(I, /obj/item/storage))
		return

	var/obj/item/storage/S = I

	if(!S.use_to_pickup || !isturf(loc))
		return

	if(S.collection_mode) //Mode is set to collect all items on a tile and we clicked on a valid one.
		var/list/rejections = list()
		var/success = FALSE
		var/failure = FALSE

		for(var/obj/item/IM in loc)
			if(IM.type in rejections) // To limit bag spamming: any given type only complains once
				continue
			if(!S.can_be_inserted(IM))	// Note can_be_inserted still makes noise when the answer is no
				rejections += IM.type	// therefore full bags are still a little spammy
				failure = TRUE
				continue
			success = TRUE
			S.handle_item_insertion(IM, TRUE, user)	//The 1 stops the "You put the [src] into [S]" insertion message from being displayed.
		if(success && !failure)
			to_chat(user, span_notice("You put everything in [S]."))
		else if(success)
			to_chat(user, span_notice("You put some things in [S]."))
		else
			to_chat(user, span_notice("You fail to pick anything up with [S]."))

	else if(S.can_be_inserted(src))
		S.handle_item_insertion(src, FALSE, user)

/obj/item/proc/talk_into(mob/M, input, channel, spans, datum/language/language)
	return ITALICS | REDUCE_RANGE


// apparently called whenever an item is removed from a slot, container, or anything else.
//the call happens after the item's potential loc change.
/obj/item/proc/dropped(mob/user)
	SEND_SIGNAL(src, COMSIG_ITEM_DROPPED, user)

	if(flags_item & DELONDROP)
		qdel(src)

///Called whenever an item is unequipped to a new loc (IE, not when the item ends up in the hands)
/obj/item/proc/removed_from_inventory(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ITEM_REMOVED_INVENTORY, user)

// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	if(current_acid) //handle acid removal
		if(!ishuman(user)) //gotta have limbs Morty
			return
		user.visible_message(span_danger("Corrosive substances seethe all over [user] as it retrieves the acid-soaked [src]!"),
		span_danger("Corrosive substances burn and seethe all over you upon retrieving the acid-soaked [src]!"))
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
			armor_block = H.get_soft_armor("acid", X)
			if(istype(X) && X.take_damage_limb(0, rand(raw_damage * 0.75, raw_damage * 1.25), blocked = armor_block))
				H.UpdateDamageIcon()
			limb_count++
		UPDATEHEALTH(H)
		qdel(current_acid)
		current_acid = null
	return

///Called to return an item to equip using the quick equip hotkey. Will try return a stored item, otherwise returns itself to equip.
/obj/item/proc/do_quick_equip()
	var/obj/item/found = locate(/obj/item/storage) in contents
	if(!found)
		found = locate(/obj/item/armor_module/storage) in contents
	if(found)
		return found.do_quick_equip()
	return src

///called when this item is removed from a storage item, which is passed on as S. The loc variable is already set to the new destination before this is called.
/obj/item/proc/on_exit_storage(obj/item/storage/S as obj)
	return


///called when this item is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/obj/item/proc/on_enter_storage(obj/item/storage/S as obj)
	return


///called when "found" in pockets and storage items. Returns 1 if the search should end.
/obj/item/proc/on_found(mob/finder as mob)
	return

// called after an item is placed in an equipment slot
// user is mob that equipped it
// slot uses the slot_X defines found in setup.dm
// for items that can be placed in multiple slots
// note this isn't called during the initial dressing of a player
/obj/item/proc/equipped(mob/user, slot)
	SHOULD_CALL_PARENT(TRUE) // no exceptions
	SEND_SIGNAL(src, COMSIG_ITEM_EQUIPPED, user, slot)

	var/equipped_to_slot = flags_equip_slot & slotdefine2slotbit(slot)
	if(equipped_to_slot) // flags_equip_slot is a bitfield
		SEND_SIGNAL(src, COMSIG_ITEM_EQUIPPED_TO_SLOT, user, slot)
	else
		SEND_SIGNAL(src, COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, user, slot)

	for(var/X in actions)
		var/datum/action/A = X
		if(item_action_slot_check(user, slot)) //some items only give their actions buttons when in a specific slot.
			A.give_action(user)

	if(!equipped_to_slot)
		return

	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(flags_armor_protection)
			human_user.add_limb_armor(src)
		if(slowdown)
			human_user.add_movespeed_modifier(type, TRUE, 0, (flags_item & IMPEDE_JETPACK) ? SLOWDOWN_IMPEDE_JETPACK : NONE, TRUE, slowdown)


///Called when an item is removed from an equipment slot. The loc should still be in the unequipper.
/obj/item/proc/unequipped(mob/unequipper, slot)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ITEM_UNEQUIPPED, unequipper, slot)

	var/equipped_from_slot = flags_equip_slot & slotdefine2slotbit(slot)

	for(var/X in actions)
		var/datum/action/A = X
		A.remove_action(unequipper)

	if(!equipped_from_slot)
		return

	if(ishuman(unequipper))
		var/mob/living/carbon/human/human_unequipper = unequipper
		if(flags_armor_protection)
			human_unequipper.remove_limb_armor(src)
		if(slowdown)
			human_unequipper.remove_movespeed_modifier(type)


//sometimes we only want to grant the item's action if it's equipped in a specific slot.
/obj/item/proc/item_action_slot_check(mob/user, slot)
	return TRUE

///Signal sender for unique_action
/obj/item/proc/do_unique_action(mob/user, special_treatment = FALSE)
	SEND_SIGNAL(src, COMSIG_ITEM_UNIQUE_ACTION, user)
	return unique_action(user, special_treatment)

///Anything unique the item can do, like pumping a shotgun, spin or whatever.
/obj/item/proc/unique_action(mob/user, special_treatment = FALSE)
	return

///Used to enable/disable an item's bump attack. Grouped in a proc to make sure the signal or flags aren't missed
/obj/item/proc/toggle_item_bump_attack(mob/user, enable_bump_attack)
	SEND_SIGNAL(user, COMSIG_ITEM_TOGGLE_BUMP_ATTACK, enable_bump_attack)
	if(flags_item & CAN_BUMP_ATTACK && enable_bump_attack)
		return
	if(enable_bump_attack)
		flags_item |= CAN_BUMP_ATTACK
		return
	flags_item &= ~CAN_BUMP_ATTACK

// The mob M is attempting to equip this item into the slot passed through as 'slot'. Return 1 if it can do this and 0 if it can't.
// If you are making custom procs but would like to retain partial or complete functionality of this one, include a 'return ..()' to where you want this to happen.
// Set disable_warning to 1 if you wish it to not give you outputs.
// warning_text is used in the case that you want to provide a specific warning for why the item cannot be equipped.

/obj/item/proc/mob_can_equip(mob/M, slot, warning = TRUE, override_nodrop = FALSE)
	if(!slot)
		return FALSE

	if(!M)
		return FALSE

	if(CHECK_BITFIELD(flags_item, NODROP) && slot != SLOT_L_HAND && slot != SLOT_R_HAND && !override_nodrop) //No drops can only be equipped to a hand slot
		if(slot == SLOT_L_HAND || slot == SLOT_R_HAND)
			to_chat(M, span_notice("[src] is stuck to our hand!"))
		return FALSE

	if(!ishuman(M))
		return FALSE
	//START HUMAN
	var/mob/living/carbon/human/H = M
	var/list/mob_equip = list()
	if(H.species.hud?.equip_slots)
		mob_equip = H.species.hud.equip_slots

	if(H.species && !(slot in mob_equip))
		return FALSE

	if(slot in H.species?.no_equip)
		if(!is_type_in_list(H.species, species_exception))
			return FALSE

	if(issynth(H) && CHECK_BITFIELD(flags_item, SYNTH_RESTRICTED) && !CONFIG_GET(flag/allow_synthetic_gun_use))
		to_chat(H, span_warning("Your programming prevents you from wearing this."))
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
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [name]."))
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
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [name]."))
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
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [name]."))
				return FALSE
			if(flags_equip_slot & ITEM_SLOT_DENYPOCKET)
				return FALSE
			if(w_class <= 2 || (flags_equip_slot & ITEM_SLOT_POCKET))
				return TRUE
			return FALSE
		if(SLOT_IN_ACCESSORY)
			if((H.w_uniform && istype(H.w_uniform.attachments_by_slot[ATTACHMENT_SLOT_UNIFORM], /obj/item/armor_module/storage/uniform/holster)))
				var/obj/item/armor_module/storage/U = H.w_uniform.attachments_by_slot[ATTACHMENT_SLOT_UNIFORM]
				var/obj/item/storage/S = U.storage
				if(S.can_be_inserted(src, warning))
					return TRUE
			return FALSE
		if(SLOT_S_STORE)
			if(H.s_store)
				return FALSE
			if(!H.wear_suit && (SLOT_WEAR_SUIT in mob_equip))
				if(warning)
					to_chat(H, span_warning("You need a suit before you can attach this [name]."))
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
			if(!istype(src, /obj/item/restraints/handcuffs))
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
			if(!H.back || !istype(H.back, /obj/item/storage/holster))
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
			if((H.belt && istype(H.belt,/obj/item/storage/holster)) || (H.belt && istype(H.belt,/obj/item/storage/belt/gun)))
				var/obj/item/storage/S = H.belt
				if(S.can_be_inserted(src, warning))
					return TRUE
			return FALSE
		if(SLOT_IN_S_HOLSTER)
			if((H.s_store && istype(H.s_store, /obj/item/storage/holster)) ||(H.s_store && istype(H.s_store,/obj/item/storage/belt/gun)))
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
		if(SLOT_IN_BOOT)
			var/obj/item/clothing/shoes/marine/S = H.shoes
			if(!istype(S) || !S.pockets)
				return FALSE
			var/obj/item/storage/internal/T = S.pockets
			if(T.can_be_inserted(src, warning))
				return TRUE
	return FALSE //Unsupported slot


/obj/item/proc/update_item_sprites()
	switch(SSmapping.configs[GROUND_MAP].armor_style)
		if(MAP_ARMOR_STYLE_JUNGLE)
			if(flags_item_map_variant & ITEM_JUNGLE_VARIANT)
				icon_state = "m_[icon_state]"
				item_state = "m_[item_state]"
		if(MAP_ARMOR_STYLE_ICE)
			if(flags_item_map_variant & ITEM_ICE_VARIANT)
				icon_state = "s_[icon_state]"
				item_state = "s_[item_state]"
		if(MAP_ARMOR_STYLE_PRISON)
			if(flags_item_map_variant & ITEM_PRISON_VARIANT)
				icon_state = "k_[icon_state]"
				item_state = "k_[item_state]"

	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD] && (flags_item_map_variant & ITEM_ICE_PROTECTION))
		min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE


///Play small animation and jiggle when picking up an object
/obj/item/proc/do_pickup_animation(atom/target)
	if(!isturf(loc))
		return
	var/image/pickup_animation = image(icon = src, loc = loc, layer = layer + 0.1)
	pickup_animation.plane = GAME_PLANE
	pickup_animation.transform.Scale(0.75)
	pickup_animation.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	var/turf/current_turf = get_turf(src)
	var/direction = get_dir(current_turf, target)
	var/to_x = target.pixel_x
	var/to_y = target.pixel_y

	if(direction & NORTH)
		to_y += 32
	else if(direction & SOUTH)
		to_y -= 32
	if(direction & EAST)
		to_x += 32
	else if(direction & WEST)
		to_x -= 32
	if(!direction)
		to_y += 10
		pickup_animation.pixel_x += 6 * (prob(50) ? 1 : -1) //6 to the right or left, helps break up the straight upward move

	flick_overlay(pickup_animation, GLOB.clients, 4)
	var/matrix/animation_matrix = new(pickup_animation.transform)
	animation_matrix.Turn(pick(-30, 30))
	animation_matrix.Scale(0.65)

	animate(pickup_animation, alpha = 175, pixel_x = to_x, pixel_y = to_y, time = 3, transform = animation_matrix, easing = CUBIC_EASING)
	animate(alpha = 0, transform = matrix().Scale(0.7), time = 1)

///Play small animation and jiggle when dropping an object
/obj/item/proc/do_drop_animation(atom/moving_from)
	if(!isturf(loc))
		return

	var/turf/current_turf = get_turf(src)
	var/direction = get_dir(moving_from, current_turf)
	var/from_x = moving_from.pixel_x
	var/from_y = moving_from.pixel_y

	if(direction & NORTH)
		from_y -= 32
	else if(direction & SOUTH)
		from_y += 32
	if(direction & EAST)
		from_x -= 32
	else if(direction & WEST)
		from_x += 32
	if(!direction)
		from_y += 10
		from_x += 6 * (prob(50) ? 1 : -1) //6 to the right or left, helps break up the straight upward move

	//We're moving from these chords to our current ones
	var/old_x = pixel_x
	var/old_y = pixel_y
	var/old_alpha = alpha
	var/matrix/old_transform = transform
	var/matrix/animation_matrix = new(old_transform)
	animation_matrix.Turn(pick(-30, 30))
	animation_matrix.Scale(0.7) // Shrink to start, end up normal sized

	pixel_x = from_x
	pixel_y = from_y
	alpha = 0
	transform = animation_matrix

	// This is instant on byond's end, but to our clients this looks like a quick drop
	animate(src, alpha = old_alpha, pixel_x = old_x, pixel_y = old_y, transform = old_transform, time = 3, easing = CUBIC_EASING)

/obj/item/verb/verb_pickup()
	set src in oview(1)
	set category = "Object"
	set name = "Pick up"

	if(usr.incapacitated() || !Adjacent(usr))
		return

	if(usr.get_active_held_item())
		return

	usr.UnarmedAttack(src, TRUE)


//This proc is executed when someone clicks the on-screen UI button. To make the UI button show, set the 'icon_action_button' to the icon_state of the image of the button in actions.dmi
//The default action is attack_self().
//Checks before we get to here are: mob is alive, mob is not restrained, paralyzed, asleep, resting, laying, item is on the mob.
/obj/item/proc/ui_action_click(mob/user, datum/action/item_action/action)
	attack_self(user)

/obj/item/proc/toggle_item_state(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ITEM_TOGGLE_ACTION, user)


/mob/living/carbon/verb/showoff()
	set name = "Show Held Item"
	set category = "Object"

	var/obj/item/I = get_active_held_item()
	if(I && !(I.flags_item & ITEM_ABSTRACT))
		visible_message("[src] holds up [I]. <a HREF=?src=[REF(usr)];lookitem=[REF(I)]>Take a closer look.</a>")

/*
For zooming with scope or binoculars. This is called from
modules/mob/mob_movement.dm if you move you will be zoomed out
modules/mob/living/carbon/human/life.dm if you die, you will be zoomed out.
*/

/obj/item/proc/zoom(mob/living/user, tileoffset, viewsize) //tileoffset is client view offset in the direction the user is facing. viewsize is how far out this thing zooms. 7 is normal view
	if(!user)
		return
	var/zoom_device = zoomdevicename ? "\improper [zoomdevicename] of [src]" : "\improper [src]"


	if(is_blind(user))
		to_chat(user, span_warning("You are too blind to see anything."))
		return

	if(!user.dextrous)
		to_chat(user, span_warning("You do not have the dexterity to use \the [zoom_device]."))
		return

	if(!zoom && user.tinttotal >= TINT_5)
		to_chat(user, span_warning("Your vision is too obscured for you to look through \the [zoom_device]."))
		return

	if(!tileoffset)
		tileoffset = zoom_tile_offset
	if(!viewsize)
		viewsize = zoom_viewsize

	if(zoom) //If we are zoomed out, reset that parameter.
		if(!TIMER_COOLDOWN_CHECK(user, COOLDOWN_ZOOM)) //If we are spamming the zoom, cut it out
			user.visible_message(span_notice("[user] looks up from [zoom_device]."),
			span_notice("You look up from [zoom_device]."))

		zoom = FALSE
		UnregisterSignal(user, COMSIG_ITEM_ZOOM)
		onunzoom(user)
		TIMER_COOLDOWN_START(user, COOLDOWN_ZOOM, 2 SECONDS)
		SEND_SIGNAL(user, COMSIG_ITEM_UNZOOM)

		if(user.interactee == src)
			user.unset_interaction()

		if(user.client)
			user.client.click_intercept = null
			user.client.view_size.reset_to_default()
			animate(user.client, 3*(tileoffset/7), pixel_x = 0, pixel_y = 0)
		return

	TIMER_COOLDOWN_START(user, COOLDOWN_ZOOM, 2 SECONDS)
	if(SEND_SIGNAL(user, COMSIG_ITEM_ZOOM) &  COMSIG_ITEM_ALREADY_ZOOMED)
		to_chat(user, span_warning("You are already looking through another zoom device.."))
		return

	if(user.client)
		user.client.view_size.add(viewsize)
		change_zoom_offset(user, zoom_offset = tileoffset)

	if(!TIMER_COOLDOWN_CHECK(user, COOLDOWN_ZOOM))
		user.visible_message(span_notice("[user] peers through \the [zoom_device]."),
		span_notice("You peer through \the [zoom_device]."))
	zoom = TRUE
	RegisterSignal(user, COMSIG_ITEM_ZOOM, .proc/zoom_check_return)
	onzoom(user)

///applies the offset of the zooming, using animate for smoothing.
/obj/item/proc/change_zoom_offset(mob/user, newdir, zoom_offset)
	SIGNAL_HANDLER
	if(!istype(user))
		return

	var/viewoffset = zoom_tile_offset * 32
	if(zoom_offset)
		viewoffset = zoom_offset * 32

	var/zoom_offset_time = 3*((viewoffset/32)/7)
	var/dirtooffset = newdir ? newdir : user.dir

	switch(dirtooffset)
		if(NORTH)
			animate(user.client, pixel_x = 0, pixel_y = viewoffset, time = zoom_offset_time)
		if(SOUTH)
			animate(user.client, pixel_x = 0, pixel_y = -viewoffset, time = zoom_offset_time)
		if(EAST)
			animate(user.client, pixel_x = viewoffset, pixel_y = 0, time = zoom_offset_time)
		if(WEST)
			animate(user.client, pixel_x = -viewoffset, pixel_y = 0, time = zoom_offset_time)


///returns a bitflag when another item tries to zoom same user.
/obj/item/proc/zoom_check_return(datum/source)
	SIGNAL_HANDLER
	return COMSIG_ITEM_ALREADY_ZOOMED

///Wrapper for signal turning scope off.
/obj/item/proc/zoom_item_turnoff(datum/source, mob/living/carbon/user)
	SIGNAL_HANDLER
	if(isliving(source))
		zoom(source)
	else
		zoom(user)

///called when zoom is activated.
/obj/item/proc/onzoom(mob/living/user)
	if(zoom_allow_movement)
		RegisterSignal(user, COMSIG_CARBON_SWAPPED_HANDS, .proc/zoom_item_turnoff)
	else
		RegisterSignal(user, list(COMSIG_MOVABLE_MOVED, COMSIG_CARBON_SWAPPED_HANDS), .proc/zoom_item_turnoff)
	RegisterSignal(user, COMSIG_MOB_FACE_DIR, .proc/change_zoom_offset)
	RegisterSignal(src, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), .proc/zoom_item_turnoff)


///called when zoom is deactivated.
/obj/item/proc/onunzoom(mob/living/user)
	if(zoom_allow_movement)
		UnregisterSignal(user, list(COMSIG_CARBON_SWAPPED_HANDS, COMSIG_MOB_FACE_DIR))
	else
		UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED, COMSIG_CARBON_SWAPPED_HANDS, COMSIG_MOB_FACE_DIR))

	UnregisterSignal(src, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))


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
			to_chat(H, span_danger("You can't see anything!"))
			H.blind_eyes(1)
		else if (E.damage >= E.min_bruised_damage)
			to_chat(H, span_warning("Your eyes are really starting to hurt. This can't be good for you!"))
			H.blind_eyes(5)
		else
			switch(safety)
				if(1)
					to_chat(user, span_warning("Your eyes sting a little."))
				if(0)
					to_chat(user, span_warning("Your eyes burn."))
				if(-1)
					to_chat(user, span_danger("Your eyes itch and burn severely."))





//This proc is here to prevent Xenomorphs from picking up objects (default attack_hand behaviour)
//Note that this is overriden by every proc concerning a child of obj unless inherited
/obj/item/attack_alien(mob/living/carbon/xenomorph/X, isrightclick = FALSE)
	return FALSE


/obj/item/proc/update_action_button_icons()
	for(var/X in actions)
		var/datum/action/A = X
		A.update_button_icon()


/obj/item/proc/extinguish(atom/target, mob/user)
	if (reagents.total_volume < 1)
		to_chat(user, span_warning("\The [src]'s water reserves are empty."))
		return

	user.visible_message(span_danger("[user] sprays water from [src]!"), \
	span_warning("You spray water from [src]."),)

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

	if(isspaceturf(user.loc))
		user.inertia_dir = get_dir(target, user)
		step(user, user.inertia_dir)


// Called when a mob tries to use the item as a tool.
// Handles most checks.
/obj/item/proc/use_tool(atom/target, mob/living/user, delay, amount = 0, volume = 0, datum/callback/extra_checks)
	// No delay means there is no start message, and no reason to call tool_start_check before use_tool.
	// Run the start check here so we wouldn't have to call it manually.
	if(!delay && !tool_start_check(user, amount))
		return

	delay *= toolspeed

	// Play tool sound at the beginning of tool usage.
	play_tool_sound(target, volume)

	if(delay)
		// Create a callback with checks that would be called every tick by do_after.
		var/datum/callback/tool_check = CALLBACK(src, .proc/tool_check_callback, user, amount, extra_checks)

		if(ismob(target))
			if(do_mob(user, target, delay, extra_checks=tool_check))
				return

		else if(!do_after(user, delay, target=target, extra_checks=tool_check))
			return

	else if(extra_checks && !extra_checks.Invoke()) // Invoke the extra checks once, just in case.
		return

	// Use tool's fuel, stack sheets or charges if amount is set.
	if(amount && !use(amount))
		return

	// Play tool sound at the end of tool usage,
	// but only if the delay between the beginning and the end is not too small
	if(delay >= MIN_TOOL_SOUND_DELAY)
		play_tool_sound(target, volume)

	return TRUE


// Called before use_tool if there is a delay, or by use_tool if there isn't.
// Only ever used by welding tools and stacks, so it's not added on any other use_tool checks.
/obj/item/proc/tool_start_check(mob/living/user, amount = 0)
	return tool_use_check(user, amount)


// A check called by tool_start_check once, and by use_tool on every tick of delay.
/obj/item/proc/tool_use_check(mob/living/user, amount)
	return !amount


// Generic use proc. Depending on the item, it uses up fuel, charges, sheets, etc.
// Returns TRUE on success, FALSE on failure.
/obj/item/proc/use(used)
	return !used

// Plays item's usesound, if any.
/obj/item/proc/play_tool_sound(atom/target, volume)
	if(!target || !usesound || !volume)
		return
	var/played_sound = usesound
	if(islist(usesound))
		played_sound = pick(usesound)
	playsound(target, played_sound, volume, 1)


// Used in a callback that is passed by use_tool into do_after call. Do not override, do not call manually.
/obj/item/proc/tool_check_callback(mob/living/user, amount, datum/callback/extra_checks)
	return tool_use_check(user, amount) && (!extra_checks || extra_checks.Invoke())


/obj/item/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!user.CanReach(src))
		return FALSE

	return TRUE


/obj/item/attack_self(mob/user)
	if(!can_interact(user))
		return

	interact(user)

/obj/item/proc/toggle_active(new_state)
	if(!isnull(new_state))
		if(new_state == active)
			return
		new_state = active
	else
		active = !active
	SEND_SIGNAL(src, COMSIG_ITEM_TOGGLE_ACTIVE, active)

///Generates worn icon for sprites on-mob.
/obj/item/proc/make_worn_icon(species_type, slot_name, inhands, default_icon, default_layer)
	//Get the required information about the base icon
	var/icon2use = get_worn_icon_file(species_type = species_type, slot_name = slot_name, default_icon = default_icon, inhands = inhands)
	var/state2use = get_worn_icon_state(slot_name = slot_name, inhands = inhands)
	var/layer2use = !inhands && worn_layer ? -worn_layer : -default_layer

	//Snowflakey inhand icons in a specific slot
	if(inhands && icon2use == icon_override)
		switch(slot_name)
			if(slot_r_hand_str)
				state2use += "_r"
			if(slot_l_hand_str)
				state2use += "_l"

	//testing("[src] (\ref[src]) - Slot: [slot_name], Inhands: [inhands], Worn Icon:[icon2use], Worn State:[state2use], Worn Layer:[layer2use]")

	var/mutable_appearance/standing = mutable_appearance(icon2use, state2use, layer2use)

	//Apply any special features
	if(!inhands)
		apply_custom(standing)		//image overrideable proc to customize the onmob icon.
		apply_blood(standing)			//Some items show blood when bloodied.
		apply_accessories(standing)		//Some items sport accessories like webbings or ties.

	standing = center_image(standing, inhands ? inhand_x_dimension : worn_x_dimension, inhands ? inhand_y_dimension : worn_y_dimension)

	standing.pixel_x += inhands ? inhand_x_offset : worn_x_offset
	standing.pixel_y += inhands ? inhand_y_offset : worn_y_offset
	standing.alpha = alpha
	standing.color = color

	//Return our icon
	return standing

///gets what icon dmi file shall be used for the on-mob sprite
/obj/item/proc/get_worn_icon_file(species_type,slot_name,default_icon,inhands)

	//1: icon_override var
	if(icon_override)
		return icon_override

	//2: species-specific sprite sheets.
	. = LAZYACCESS(sprite_sheets, species_type)
	if(. && !inhands)
		return

	//3: slot-specific sprite sheets
	. = LAZYACCESS(item_icons, slot_name)
	if(.)
		return

	//5: provided default_icon
	if(default_icon)
		return default_icon

	//6: give error
	CRASH("[src] dind't manage to find a icon file for worn onmob icon.")

///Returns the state that should be used for the on-mob icon
/obj/item/proc/get_worn_icon_state(slot_name, inhands)

	//1: slot-specific sprite sheets
	. = LAZYACCESS(item_state_slots, slot_name)
	if(.)
		return

	//2: item_state variable, some items use it for worn sprite, others for inhands.
	if(inhands || item_state_worn)
		if(item_state)
			return item_state

	//3: icon_state variable
	if(icon_state)
		return icon_state

///applies any custom thing to the sprite, caled by make_worn_icon().
/obj/item/proc/apply_custom(mutable_appearance/standing)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ITEM_APPLY_CUSTOM_OVERLAY, standing)
	return standing

///applies blood on the item, called by make_worn_icon().
/obj/item/proc/apply_blood(mutable_appearance/standing)
	return standing

///applies any accessory the item may have, called by make_worn_icon().
/obj/item/proc/apply_accessories(mutable_appearance/standing)
	return standing
