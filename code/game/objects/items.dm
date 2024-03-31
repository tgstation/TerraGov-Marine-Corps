GLOBAL_DATUM_INIT(fire_overlay, /mutable_appearance, mutable_appearance('icons/effects/fire.dmi', "fire"))


GLOBAL_VAR_INIT(rpg_loot_items, FALSE)
// if true, everyone item when created will have its name changed to be
// more... RPG-like.

/obj/item
	name = "item"
	icon = 'icons/obj/items_and_weapons.dmi'
	///icon state name for inhanf overlays
	var/item_state = null
	///Icon file for left hand inhand overlays
	var/lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	///Icon file for right inhand overlays
	var/righthand_file = 'icons/mob/inhands/items_righthand.dmi'

	///Icon file for mob worn overlays.
	///no var for state because it should *always* be the same as icon_state
	var/icon/mob_overlay_icon
	//Forced mob worn layer instead of the standard preferred ssize.
	var/alternate_worn_layer

	//Dimensions of the icon file used when this item is worn, eg: hats.dmi
	//eg: 32x32 sprite, 64x64 sprite, etc.
	//allows inhands/worn sprites to be of any size, but still centered on a mob properly
	var/worn_x_dimension = 32
	var/worn_y_dimension = 32
	//Same as above but for inhands, uses the lefthand_ and righthand_ file vars
	var/inhand_x_dimension = 64
	var/inhand_y_dimension = 64

	var/no_effect = FALSE

	max_integrity = 200

	obj_flags = NONE
	var/item_flags = NONE

	var/list/hitsound
	var/usesound
	///Used when yate into a mob
	var/mob_throw_hit_sound
	///Sound used when equipping the item into a valid slot
	var/equip_sound
	///Sound uses when picking the item up (into my hands)
	var/pickup_sound = "rustle"
	///Sound uses when dropping the item, or when its thrown.
	var/drop_sound = 'sound/foley/dropsound/gen_drop.ogg'
	//when being placed on a table play this instead
	var/place_sound = 'sound/foley/dropsound/gen_drop.ogg'
	var/list/swingsound = PUNCHWOOSH
	var/list/parrysound = "parrywood"
	var/w_class = WEIGHT_CLASS_NORMAL
	var/slot_flags = 0		//This is used to determine on which slots an item can fit.
	pass_flags = PASSTABLE
	pressure_resistance = 4
	var/obj/item/master = null

	var/heat_protection = 0 //flags which determine which body parts are protected from heat. Use the HEAD, CHEST, GROIN, etc. flags. See setup.dm
	var/cold_protection = 0 //flags which determine which body parts are protected from cold. Use the HEAD, CHEST, GROIN, etc. flags. See setup.dm
	var/max_heat_protection_temperature //Set this variable to determine up to which temperature (IN KELVIN) the item protects against heat damage. Keep at null to disable protection. Only protects areas set by heat_protection flags
	var/min_cold_protection_temperature //Set this variable to determine down to which temperature (IN KELVIN) the item protects against cold damage. 0 is NOT an acceptable number due to if(varname) tests!! Keep at null to disable protection. Only protects areas set by cold_protection flags

	var/list/actions //list of /datum/action's that this item has.
	var/list/actions_types //list of paths of action datums to give to the item on New().

	//Since any item can now be a piece of clothing, this has to be put here so all items share it.
	var/flags_inv //This flag is used to determine when items in someone's inventory cover others. IE helmets making it so you can't see glasses, etc.
	var/transparent_protection = NONE //you can see someone's mask through their transparent visor, but you can't reach it

	var/interaction_flags_item = INTERACT_ITEM_ATTACK_HAND_PICKUP

	var/body_parts_covered = 0 //see setup.dm for appropriate bit flags
	var/gas_transfer_coefficient = 1 // for leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/permeability_coefficient = 1 // for chemicals/diseases
	var/siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit)
	var/slowdown = 0 // How much clothing is slowing you down. Negative values speeds you up
	var/armor_penetration = 0 //percentage of armour effectiveness to remove
	var/list/allowed = null //suit storage stuff.
	var/equip_delay_self = 1 //In deciseconds, how long an item takes to equip; counts only for normal clothing slots, not pockets etc.
	var/edelay_type = 1 //if 1, can be moving while equipping (for helmets etc)
	var/equip_delay_other = 20 //In deciseconds, how long an item takes to put on another person
	var/strip_delay = 40 //In deciseconds, how long an item takes to remove from another person
	var/breakouttime = 0 // greater than 15 str get this isnstead
	var/slipouttime = 0

	var/list/attack_verb //Used in attackby() to say how something was attacked "[x] has been [z.attack_verb] by [y] with [z]"
	var/list/species_exception = null	// list() of species types, if a species cannot put items in a certain slot, but species type is in list, it will be able to wear that item

	var/mob/thrownby = null

	mouse_drag_pointer = MOUSE_ACTIVE_POINTER //the icon to indicate this object is being dragged

	var/datum/embedding_behavior/embedding

	var/flags_cover = 0 //for flags such as GLASSESCOVERSEYES
	var/heat = 0
	///All items with sharpness of IS_SHARP or higher will automatically get the butchering component.
	var/sharpness = IS_BLUNT

	var/tool_behaviour = NONE
	var/toolspeed = 1

	var/block_chance = 0
	var/hit_reaction_chance = 0 //If you want to have something unrelated to blocking/armour piercing etc. Maybe not needed, but trying to think ahead/allow more freedom
	var/reach = 1 //In tiles, how far this weapon can reach; 1 for adjacent, which is default

	//The list of slots by priority. equip_to_appropriate_slot() uses this list. Doesn't matter if a mob type doesn't have a slot.
	var/list/slot_equipment_priority = null // for default list, see /mob/proc/equip_to_appropriate_slot()

	// Needs to be in /obj/item because corgis can wear a lot of
	// non-clothing items
	var/datum/dog_fashion/dog_fashion = null

	//Tooltip vars
	var/force_string //string form of an item's force. Edit this var only to set a custom force string
	var/last_force_string_check = 0
	var/tip_timer

	var/trigger_guard = TRIGGER_GUARD_NONE

	///Used as the dye color source in the washing machine only (at the moment). Can be a hex color or a key corresponding to a registry entry, see washing_machine.dm
	var/dye_color
	///Whether the item is unaffected by standard dying.
	var/undyeable = FALSE
	///What dye registry should be looked at when dying this item; see washing_machine.dm
	var/dying_key

	//Grinder vars
	var/list/grind_results //A reagent list containing the reagents this item produces when ground up in a grinder - this can be an empty list to allow for reagent transferring only
	var/list/juice_results //A reagent list containing blah blah... but when JUICED in a grinder!

	var/canMouseDown = FALSE
	var/can_parry = FALSE
	var/associated_skill

	var/list/possible_item_intents = list(/datum/intent/use)

	var/bigboy = FALSE //used to center screen_loc when in hand
	var/wielded = FALSE
	var/altgripped = FALSE
	var/list/alt_intents //these replace main intents
	var/list/gripped_intents //intents while gripped, replacing main intents
	var/force_wielded = 0
	var/gripsprite = FALSE //use alternate grip sprite for inhand

	var/dropshrink = 0

	var/wlength = WLENGTH_NORMAL		//each weapon length class has its own inherent dodge properties
	var/wbalance = 0
	var/wdefense = 0 //better at defending
	var/minstr = 0  //for weapons

	var/sleeved = null
	var/sleevetype = null
	var/nodismemsleeves = FALSE
	var/inhand_mod = FALSE
	var/r_sleeve_status = SLEEVE_NOMOD //SLEEVE_TORN or SLEEVE_ROLLED
	var/l_sleeve_status = SLEEVE_NOMOD
	var/r_sleeve_zone = BODY_ZONE_R_ARM
	var/l_sleeve_zone = BODY_ZONE_L_ARM

	var/twohands_required = FALSE

	var/bloody_icon = 'icons/effects/blood.dmi'
	var/bloody_icon_state = "itemblood"
	var/boobed = FALSE

	var/firefuel = 0 //add this idiot

	var/thrown_bclass = BCLASS_BLUNT

	var/icon/experimental_inhand = TRUE
	var/icon/experimental_onhip = FALSE
	var/icon/experimental_onback = FALSE

	var/muteinmouth = TRUE //trying to emote or talk with this in our mouth makes us muffled
	var/spitoutmouth = TRUE //using spit emote spits the item out of our mouth and falls out after some time

	var/has_inspect_verb = FALSE

	var/anvilrepair //this should be a skill path
	var/sewrepair //this should be true or false

	var/breakpath

	var/walking_stick = FALSE

	var/mailer = null
	var/mailedto = null

	var/list/examine_effects = list()

	var/list/blocksound //played when an item that is equipped blocks a hit

/obj/item/New()
	..()
	if(!pixel_x && !pixel_y && !bigboy)
		pixel_x = rand(-5,5)
		pixel_y = rand(-5,5)
	if(twohands_required)
		has_inspect_verb = TRUE
	update_transform()


/obj/item/proc/update_transform()
	transform = null
	if(dropshrink)
		if(isturf(loc))
			var/matrix/M = matrix()
			M.Scale(dropshrink,dropshrink)
			transform = M
	if(ismob(loc))
		if(altgripped)
			if(gripsprite)
				icon_state = "[initial(icon_state)]1"
				var/datum/component/decal/blood/B = GetComponent(/datum/component/decal/blood)
				if(B)
					B.remove()
					B.generate_appearance()
					B.apply()
			return
		if(wielded)
			if(gripsprite)
				icon_state = "[initial(icon_state)]1"
				var/datum/component/decal/blood/B = GetComponent(/datum/component/decal/blood)
				if(B)
					B.remove()
					B.generate_appearance()
					B.apply()
			return
		if(gripsprite)
			icon_state = initial(icon_state)
			var/datum/component/decal/blood/B = GetComponent(/datum/component/decal/blood)
			if(B)
				B.remove()
				B.generate_appearance()
				B.apply()

/obj/item/Initialize()
	if (attack_verb)
		attack_verb = typelist("attack_verb", attack_verb)

	if(experimental_inhand)
		var/props2gen = list("gen")
		var/list/prop
		if(gripped_intents)
			props2gen += "wielded"
		for(var/i in props2gen)
			prop = getonmobprop(i)
			if(prop)
				getmoboverlay(i,prop,behind=FALSE,mirrored=FALSE)
				getmoboverlay(i,prop,behind=TRUE,mirrored=FALSE)
				getmoboverlay(i,prop,behind=FALSE,mirrored=TRUE)
				getmoboverlay(i,prop,behind=TRUE,mirrored=TRUE)

	if(experimental_onhip)
		if(slot_flags & ITEM_SLOT_BELT)
			var/i = "onbelt"
			var/list/prop = getonmobprop(i)
			if(prop)
				getmoboverlay(i,prop,behind=FALSE,mirrored=FALSE)
				getmoboverlay(i,prop,behind=TRUE,mirrored=FALSE)
				getmoboverlay(i,prop,behind=FALSE,mirrored=TRUE)
				getmoboverlay(i,prop,behind=TRUE,mirrored=TRUE)

	if(experimental_onback)
		if(slot_flags & ITEM_SLOT_BACK)
			var/i = "onback"
			var/list/prop = getonmobprop(i)
			if(prop)
				getmoboverlay(i,prop,behind=FALSE,mirrored=FALSE)
				getmoboverlay(i,prop,behind=TRUE,mirrored=FALSE)
				getmoboverlay(i,prop,behind=FALSE,mirrored=TRUE)
				getmoboverlay(i,prop,behind=TRUE,mirrored=TRUE)

	. = ..()
	for(var/path in actions_types)
		new path(src)
	actions_types = null

	if(GLOB.rpg_loot_items)
		AddComponent(/datum/component/fantasy)

	if(force_string)
		item_flags |= FORCE_STRING_OVERRIDE

	if(!hitsound)
		if(damtype == "fire")
			hitsound = list('sound/blank.ogg')
		if(damtype == "brute")
			hitsound = list("swing_hit")

	if (!embedding)
		embedding = getEmbeddingBehavior()
	else if (islist(embedding))
		embedding = getEmbeddingBehavior(arglist(embedding))
	else if (!istype(embedding, /datum/embedding_behavior))
		stack_trace("Invalid type [embedding.type] found in .embedding during /obj/item Initialize()")

	if(sharpness) //give sharp objects butchering functionality, for consistency
		AddComponent(/datum/component/butchering, 80 * toolspeed)

	if(max_blade_int && !blade_int) //set blade integrity to randomized 60% to 100% if not already set
		blade_int = max_blade_int + rand(-(max_blade_int * 0.4), 0)

/obj/item/Destroy()
	item_flags &= ~DROPDEL	//prevent reqdels
	if(ismob(loc))
		var/mob/m = loc
		m.temporarilyRemoveItemFromInventory(src, TRUE)
	for(var/X in actions)
		qdel(X)
	return ..()

/obj/item/proc/check_allowed_items(atom/target, not_inside, target_self)
	if(((src in target) && !target_self) || (!isturf(target.loc) && !isturf(target) && not_inside))
		return 0
	else
		return 1

/obj/item/blob_act(obj/structure/blob/B)
	if(B && B.loc == loc)
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
	set hidden = 1
	set src in oview(1)

	if(!isturf(loc) || usr.stat || usr.restrained())
		return

	if(isliving(usr))
		var/mob/living/L = usr
		if(!(L.mobility_flags & MOBILITY_PICKUP))
			return

	var/turf/T = loc
	loc = null
	loc = T

/obj/item/Topic(href, href_list)
	. = ..()

	if(href_list["inspect"])
		if(!usr.canUseTopic(src, be_close=TRUE))
			return
		var/list/inspec = list("<span class='notice'>Properties of [src.name]</span>")
		if(minstr)
			inspec += "\n<b>MIN.STR:</b> [minstr]"

		if(wbalance)
			inspec += "\n<b>BALANCE:</b>"
			if(wbalance < 0)
				inspec += "Heavy"
			if(wbalance > 0)
				inspec += "Swift"

		if(wlength != WLENGTH_NORMAL)
			inspec += "\n<b>LENGTH:</b> "
			switch(wlength)
				if(WLENGTH_SHORT)
					inspec += "Short"
				if(WLENGTH_LONG)
					inspec += "Long"
				if(WLENGTH_GREAT)
					inspec += "Great"

//		if(eweight)
//			inspec += "\n<b>ENCUMBRANCE:</b> [eweight]"

		if(alt_intents)
			inspec += "\n<b>ALT-GRIP</b>"

		if(gripped_intents)
			inspec += "\n<b>TWO-HANDED</b>"

		if(twohands_required)
			inspec += "\n<b>BULKY</b>"

		if(can_parry)
			inspec += "\n<b>DEFENSE:</b> [wdefense]"

		if(max_blade_int)
			inspec += "\n<b>SHARPNESS:</b> "
			var/meme = round(((blade_int / max_blade_int) * 100), 1)
			inspec += "[meme]%"

//**** CLOTHING STUFF

		if(istype(src,/obj/item/clothing))
			var/obj/item/clothing/C = src
			if(C.prevent_crits)
				if(C.prevent_crits.len)
					inspec += "\n<b>DEFENSE</b>"
					for(var/X in C.prevent_crits)
						inspec += "\n<b>[X] damage</b>"

//**** General durability

		if(max_integrity)
			inspec += "\n<b>DURABILITY:</b> "
			var/meme = round(((obj_integrity / max_integrity) * 100), 1)
			inspec += "[meme]%"

		to_chat(usr, "[inspec.Join()]")

/obj/item
	var/simpleton_price = FALSE

/obj/item/get_inspect_button()
	if(has_inspect_verb || (obj_integrity < max_integrity))
		return " <span class='info'><a href='?src=[REF(src)];inspect=1'>{?}</a></span>"
	return ..()


/obj/item/interact(mob/user)
	add_fingerprint(user)
	ui_interact(user)

/obj/item/ui_act(action, params)
	add_fingerprint(usr)
	return ..()

/obj/item/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!user)
		return
	if(anchored)
		return

	if(twohands_required)
		if(user.get_num_arms() < 2)
			to_chat(user, "<span class='warning'>[src] is too bulky to carry in one hand!</span>")
			return
		var/obj/item/twohanded/required/H
		H = user.get_inactive_held_item()
		if(get_dist(src,user) > 1)
			return
		if(H != null)
			to_chat(user, "<span class='warning'>[src] is too bulky to carry in one hand!</span>")
			return

	if(w_class == WEIGHT_CLASS_GIGANTIC)
		return

	if(resistance_flags & ON_FIRE)
		var/mob/living/carbon/C = user
		var/can_handle_hot = FALSE
		if(!istype(C))
			can_handle_hot = TRUE
		else if(C.gloves && (C.gloves.max_heat_protection_temperature > 360))
			can_handle_hot = TRUE
		else if(HAS_TRAIT(C, TRAIT_RESISTHEAT) || HAS_TRAIT(C, TRAIT_RESISTHEATHANDS))
			can_handle_hot = TRUE

		if(can_handle_hot)
			extinguish()
			user.visible_message("<span class='warning'>[user] puts out the fire on [src].</span>")
		else
			user.visible_message("<span class='warning'>[user] burns [user.p_their()] hand putting out the fire on [src]!</span>")
			extinguish()
			var/obj/item/bodypart/affecting = C.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
			if(affecting && affecting.receive_damage( 0, 5 ))		// 5 burn damage
				C.update_damage_overlays()
			return

	if(acid_level > 20 && !ismob(loc))// so we can still remove the clothes on us that have acid.
		var/mob/living/carbon/C = user
		if(istype(C))
			if(!C.gloves || (!(C.gloves.resistance_flags & (UNACIDABLE|ACID_PROOF))))
				to_chat(user, "<span class='warning'>The acid on [src] burns my hand!</span>")
				var/obj/item/bodypart/affecting = C.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
				if(affecting && affecting.receive_damage( 0, 5 ))		// 5 burn damage
					C.update_damage_overlays()

	if(!(interaction_flags_item & INTERACT_ITEM_ATTACK_HAND_PICKUP))		//See if we're supposed to auto pickup.
		return

	//Heavy gravity makes picking up things very slow.
	var/grav = user.has_gravity()
	if(grav > STANDARD_GRAVITY)
		var/grav_power = min(3,grav - STANDARD_GRAVITY)
		to_chat(user,"<span class='notice'>I start picking up [src]...</span>")
		if(!do_mob(user,src,30*grav_power))
			return

	if(!ontable() && isturf(loc))
		if(!move_after(user,3,target = src))
			return

	//If the item is in a storage item, take it out
	SEND_SIGNAL(loc, COMSIG_TRY_STORAGE_TAKE, src, user.loc, TRUE)
	if(QDELETED(src)) //moving it out of the storage to the floor destroyed it.
		return

	if(throwing)
		throwing.finalize(FALSE)
	if(loc == user)
		if(!allow_attack_hand_drop(user) || !user.temporarilyRemoveItemFromInventory(src))
			return

	pickup(user)
	add_fingerprint(user)
	if(!user.put_in_active_hand(src, FALSE, FALSE))
		user.dropItemToGround(src)
	else
		if(twohands_required)
			wield(user)

/atom/proc/ontable()
	if(!isturf(src.loc))
		return FALSE
	for(var/obj/structure/table/T in src.loc)
		return TRUE
	return FALSE

/obj/item/proc/allow_attack_hand_drop(mob/user)
	return TRUE

/obj/item/attack_paw(mob/user)
	if(!user)
		return
	if(anchored)
		return

	SEND_SIGNAL(loc, COMSIG_TRY_STORAGE_TAKE, src, user.loc, TRUE)

	if(throwing)
		throwing.finalize(FALSE)
	if(loc == user)
		if(!user.temporarilyRemoveItemFromInventory(src))
			return

	pickup(user)
	add_fingerprint(user)
	if(!user.put_in_active_hand(src, FALSE, FALSE))
		user.dropItemToGround(src)

/obj/item/attack_alien(mob/user)
	var/mob/living/carbon/alien/A = user

	if(!A.has_fine_manipulation)
		if(src in A.contents) // To stop Aliens having items stuck in their pockets
			A.dropItemToGround(src)
		to_chat(user, "<span class='warning'>My claws aren't capable of such fine manipulation!</span>")
		return
	attack_paw(A)

/obj/item/attack_ai(mob/user)
	if(istype(src.loc, /obj/item/robot_module))
		//If the item is part of a cyborg module, equip it
		if(!iscyborg(user))
			return
		var/mob/living/silicon/robot/R = user
		if(!R.low_power_mode) //can't equip modules with an empty cell.
			R.activate_module(src)
			R.hud_used.update_robot_modules_display()

/obj/item/proc/GetDeconstructableContents()
	return GetAllContents() - src

// afterattack() and attack() prototypes moved to _onclick/item_attack.dm for consistency

/obj/item/proc/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	SEND_SIGNAL(src, COMSIG_ITEM_HIT_REACT, args)
	if(prob(final_block_chance))
		owner.visible_message("<span class='danger'>[owner] blocks [attack_text] with [src]!</span>")
		return 1
	return 0

/obj/item/proc/talk_into(mob/M, input, channel, spans, datum/language/language)
	return ITALICS | REDUCE_RANGE

/obj/item/proc/dropped(mob/user, silent = FALSE)
	SHOULD_CALL_PARENT(1)
	for(var/X in actions)
		var/datum/action/A = X
		A.Remove(user)
	if(item_flags & DROPDEL)
		qdel(src)
		return
	pixel_x = initial(pixel_x)
	pixel_y = initial(pixel_y)
	if(isturf(loc))
		if(!ontable())
			var/oldy = pixel_y
			pixel_y = pixel_y+5
			animate(src, pixel_y = oldy, time = 0.5)
	if(altgripped || wielded)
		ungrip(user, FALSE)
	item_flags &= ~IN_INVENTORY
	SEND_SIGNAL(src, COMSIG_ITEM_DROPPED,user)
	if(!silent)
		playsound(src, drop_sound, DROP_SOUND_VOLUME, TRUE, ignore_walls = FALSE)
	user.update_equipment_speed_mods()
	update_transform()

// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	SHOULD_CALL_PARENT(1)
	SEND_SIGNAL(src, COMSIG_ITEM_PICKUP, user)
	item_flags |= IN_INVENTORY

// called when "found" in pockets and storage items. Returns 1 if the search should end.
/obj/item/proc/on_found(mob/finder)
	return

// called after an item is placed in an equipment slot
// user is mob that equipped it
// slot uses the slot_X defines found in setup.dm
// for items that can be placed in multiple slots
// Initial is used to indicate whether or not this is the initial equipment (job datums etc) or just a player doing it
/obj/item/proc/equipped(mob/user, slot, initial = FALSE)
	SHOULD_CALL_PARENT(1)
	SEND_SIGNAL(src, COMSIG_ITEM_EQUIPPED, user, slot)
	for(var/X in actions)
		var/datum/action/A = X
		if(item_action_slot_check(slot, user)) //some items only give their actions buttons when in a specific slot.
			A.Grant(user)
	item_flags |= IN_INVENTORY
	if(!initial)
		if(equip_sound &&(slot_flags & slotdefine2slotbit(slot)))
			playsound(src, equip_sound, EQUIP_SOUND_VOLUME, TRUE, ignore_walls = FALSE)
		else if(slot == SLOT_HANDS)
			playsound(src, pickup_sound, PICKUP_SOUND_VOLUME, ignore_walls = FALSE)
	user.update_equipment_speed_mods()

	if(!user.is_holding(src))
		if(altgripped || wielded)
			ungrip(user, FALSE)
	if(twohands_required)
		var/slotbit = slotdefine2slotbit(slot)
		if(slot_flags & slotbit)
			var/datum/O = user.is_holding_item_of_type(/obj/item/twohanded/offhand)
			if(!O || QDELETED(O))
				return
			qdel(O)
			return
		if(slot == SLOT_HANDS)
			wield(user)
		else
			ungrip(user)

	update_transform()

//sometimes we only want to grant the item's action if it's equipped in a specific slot.
/obj/item/proc/item_action_slot_check(slot, mob/user)
	if(slot == SLOT_IN_BACKPACK || slot == SLOT_LEGCUFFED) //these aren't true slots, so avoid granting actions there
		return FALSE
	return TRUE

//the mob M is attempting to equip this item into the slot passed through as 'slot'. Return 1 if it can do this and 0 if it can't.
//if this is being done by a mob other than M, it will include the mob equipper, who is trying to equip the item to mob M. equipper will be null otherwise.
//If you are making custom procs but would like to retain partial or complete functionality of this one, include a 'return ..()' to where you want this to happen.
//Set disable_warning to TRUE if you wish it to not give you outputs.
/obj/item/proc/mob_can_equip(mob/living/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	if(twohands_required)
		if(!disable_warning)
			to_chat(M, "<span class='warning'>[src] is too bulky to carry with anything but my hands!</span>")
		return 0

	if(!M)
		return FALSE

	return M.can_equip(src, slot, disable_warning, bypass_equip_delay_self)

/obj/item/verb/verb_pickup()
	set src in oview(1)
	set hidden = 1
	set name = "Pick up"

	if(usr.incapacitated() || !Adjacent(usr))
		return

	if(isliving(usr))
		var/mob/living/L = usr
		if(!(L.mobility_flags & MOBILITY_PICKUP))
			return

	if(usr.get_active_held_item() == null) // Let me know if this has any problems -Yota
		usr.UnarmedAttack(src)

//This proc is executed when someone clicks the on-screen UI button.
//The default action is attack_self().
//Checks before we get to here are: mob is alive, mob is not restrained, stunned, asleep, resting, laying, item is on the mob.
/obj/item/proc/ui_action_click(mob/user, actiontype)
	attack_self(user)

/obj/item/proc/IsReflect(var/def_zone) //This proc determines if and at what% an object will reflect energy projectiles if it's in l_hand,r_hand or wear_armor
	return 0

/obj/item/proc/eyestab(mob/living/carbon/M, mob/living/carbon/user)

	var/is_human_victim
	var/obj/item/bodypart/affecting = M.get_bodypart(BODY_ZONE_HEAD)
	if(ishuman(M))
		if(!affecting) //no head!
			return
		is_human_victim = TRUE

	if(M.is_eyes_covered())
		// you can't stab someone in the eyes wearing a mask!
		to_chat(user, "<span class='warning'>You're going to need to remove [M.p_their()] eye protection first!</span>")
		return

	if(isalien(M))//Aliens don't have eyes./N     slimes also don't have eyes!
		to_chat(user, "<span class='warning'>I cannot locate any eyes on this creature!</span>")
		return

	if(isbrain(M))
		to_chat(user, "<span class='warning'>I cannot locate any organic eyes on this brain!</span>")
		return

	src.add_fingerprint(user)

	playsound(loc, src.hitsound, 30, TRUE, -1)

	user.do_attack_animation(M)

	if(M != user)
		M.visible_message("<span class='danger'>[user] has stabbed [M] in the eye with [src]!</span>", \
							"<span class='danger'>[user] stabs you in the eye with [src]!</span>")
	else
		user.visible_message( \
			"<span class='danger'>[user] has stabbed [user.p_them()]self in the eyes with [src]!</span>", \
			"<span class='danger'>I stab myself in the eyes with [src]!</span>" \
		)
	if(is_human_victim)
		var/mob/living/carbon/human/U = M
		U.apply_damage(7, BRUTE, affecting)

	else
		M.take_bodypart_damage(7)

	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "eye_stab", /datum/mood_event/eye_stab)

	log_combat(user, M, "attacked", "[src.name]", "(INTENT: [uppertext(user.used_intent)])")

	var/obj/item/organ/eyes/eyes = M.getorganslot(ORGAN_SLOT_EYES)
	if (!eyes)
		return
	M.adjust_blurriness(3)
	eyes.applyOrganDamage(rand(2,4))
	if(eyes.damage >= 10)
		M.adjust_blurriness(15)
		if(M.stat != DEAD)
			to_chat(M, "<span class='danger'>My eyes start to bleed profusely!</span>")
		if(!(HAS_TRAIT(M, TRAIT_BLIND) || HAS_TRAIT(M, TRAIT_NEARSIGHT)))
			to_chat(M, "<span class='danger'>I become nearsighted!</span>")
		M.become_nearsighted(EYE_DAMAGE)
		if(prob(50))
			if(M.stat != DEAD)
				if(M.drop_all_held_items())
					to_chat(M, "<span class='danger'>I drop what you're holding and clutch at my eyes!</span>")
			M.adjust_blurriness(10)
			M.Unconscious(20)
			M.Paralyze(40)
		if (prob(eyes.damage - 10 + 1))
			M.become_blind(EYE_DAMAGE)
			to_chat(M, "<span class='danger'>I go blind!</span>")

/obj/item/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FOUR)
		throw_at(S,14,3, spin=0)
	else
		return

/obj/item/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(hit_atom && !QDELETED(hit_atom))
		SEND_SIGNAL(src, COMSIG_MOVABLE_IMPACT, hit_atom, throwingdatum)
		if(get_temperature() && isliving(hit_atom))
			var/mob/living/L = hit_atom
			L.IgniteMob()
		var/itempush = 0
		if(w_class < 4)
			itempush = 0 //too light to push anything
		if(istype(hit_atom, /mob/living)) //Living mobs handle hit sounds differently.
			var/volume = get_volume_by_throwforce_and_or_w_class()
			if (throwforce > 0)
				if (mob_throw_hit_sound)
					playsound(hit_atom, mob_throw_hit_sound, volume, TRUE, -1)
				else if(hitsound)
					playsound(hit_atom, pick(hitsound), volume, TRUE, -1)
				else
					playsound(hit_atom, 'sound/blank.ogg',volume, TRUE, -1)
			else
				playsound(hit_atom, 'sound/blank.ogg', 1, volume, -1)

		else
			playsound(src, drop_sound, YEET_SOUND_VOLUME, TRUE, ignore_walls = FALSE)
		return hit_atom.hitby(src, 0, itempush, throwingdatum=throwingdatum)

/obj/item/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force)
	thrownby = thrower
	callback = CALLBACK(src, .proc/after_throw, callback) //replace their callback with our own
	. = ..(target, range, speed, thrower, spin, diagonals_first, callback, force)


/obj/item/proc/after_throw(datum/callback/callback)
	if (callback) //call the original callback
		. = callback.Invoke()
	item_flags &= ~IN_INVENTORY
	if(!pixel_y && !pixel_x)
		pixel_x = rand(-8,8)
		pixel_y = rand(-8,8)


/obj/item/proc/remove_item_from_storage(atom/newLoc) //please use this if you're going to snowflake an item out of a obj/item/storage
	if(!newLoc)
		return FALSE
	if(SEND_SIGNAL(loc, COMSIG_CONTAINS_STORAGE))
		return SEND_SIGNAL(loc, COMSIG_TRY_STORAGE_TAKE, src, newLoc, TRUE)
	return FALSE

/obj/item/proc/get_belt_overlay() //Returns the icon used for overlaying the object on a belt
	return mutable_appearance('icons/obj/clothing/belt_overlays.dmi', icon_state)

/obj/item/proc/update_slot_icon()
	if(!ismob(loc))
		return
	var/mob/owner = loc
	var/mob/living/carbon/human/H
	if(ishuman(owner))
		H = owner
	var/flags = slot_flags
//	if(flags & ITEM_SLOT_OCLOTHING)
//		owner.update_inv_wear_suit()
//	if(flags & ITEM_SLOT_ICLOTHING)
//		owner.update_inv_w_uniform()
	if(flags & ITEM_SLOT_GLOVES)
		owner.update_inv_gloves()
//	if(flags & ITEM_SLOT_HEAD)
//		owner.update_inv_glasses()
//	if(flags & ITEM_SLOT_HEAD)
//		owner.update_inv_ears()
	if(flags & ITEM_SLOT_MASK)
		owner.update_inv_wear_mask()
	if(flags & ITEM_SLOT_SHOES)
		owner.update_inv_shoes()
	if(flags & ITEM_SLOT_RING)
		owner.update_inv_wear_id()
	if(flags & ITEM_SLOT_WRISTS)
		owner.update_inv_wrists()
	if(flags & ITEM_SLOT_BACK)
		owner.update_inv_back()
	if(flags & ITEM_SLOT_NECK)
		owner.update_inv_neck()
	if(flags & ITEM_SLOT_PANTS)
		owner.update_inv_pants()
	if(flags & ITEM_SLOT_CLOAK)
		owner.update_inv_cloak()
	if(H)
		if(flags & ITEM_SLOT_HEAD && H.head == src)
			owner.update_inv_head()
		if(flags & ITEM_SLOT_ARMOR && H.wear_armor == src)
			owner.update_inv_armor()
		if(flags & ITEM_SLOT_SHIRT && H.wear_shirt == src)
			owner.update_inv_shirt()
		if(flags & ITEM_SLOT_MOUTH && H.mouth == src)
			owner.update_inv_mouth()
		if(flags & ITEM_SLOT_BELT && H.belt == src)
			owner.update_inv_belt()
		if(flags & ITEM_SLOT_HIP && (H.beltr == src || H.beltl == src) )
			owner.update_inv_belt()
	else
		if(flags & ITEM_SLOT_HEAD)
			owner.update_inv_head()
		if(flags & ITEM_SLOT_ARMOR)
			owner.update_inv_armor()
		if(flags & ITEM_SLOT_SHIRT)
			owner.update_inv_shirt()
		if(flags & ITEM_SLOT_MOUTH)
			owner.update_inv_mouth()
		if(flags & ITEM_SLOT_BELT)
			owner.update_inv_belt()
		if(flags & ITEM_SLOT_HIP)
			owner.update_inv_belt()


///Returns the temperature of src. If you want to know if an item is hot use this proc.
/obj/item/proc/get_temperature()
	return heat

///Returns the sharpness of src. If you want to get the sharpness of an item use this.
/obj/item/proc/get_sharpness()
	for(var/X in possible_item_intents)
		var/datum/intent/D = new X()
		if(D.blade_class == BCLASS_CUT)
			return TRUE
		if(D.blade_class == BCLASS_CHOP)
			return TRUE
	return sharpness

/obj/item/proc/get_dismemberment_chance(obj/item/bodypart/affecting, input)
	if(!input)
		input = force
	if(affecting.can_dismember(src))
		if((sharpness || damtype == BURN) && w_class >= WEIGHT_CLASS_NORMAL && input >= 10)
			. = force * (affecting.get_damage() / affecting.max_damage)

/obj/item/proc/get_dismember_sound()
	if(damtype == BURN)
		. = 'sound/blank.ogg'
	else
		. = "desceration"

/obj/item/proc/open_flame(flame_heat=700)
	var/turf/location = loc
	if(ismob(location))
		var/mob/M = location
		var/success = FALSE
		if(src == M.get_item_by_slot(SLOT_WEAR_MASK))
			success = TRUE
		if(success)
			location = get_turf(M)
	if(isturf(location))
		location.hotspot_expose(flame_heat, 5)


/obj/item/proc/ignition_effect(atom/A, mob/user)
	if(get_temperature())
		. = "<span class='notice'>[user] lights [A] with [src].</span>"
	else
		. = ""

/obj/item/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	return

/obj/item/attack_hulk(mob/living/carbon/human/user)
	return FALSE

/obj/item/attack_animal(mob/living/simple_animal/M)
	if (obj_flags & CAN_BE_HIT)
		return ..()
	return 0

/obj/item/mech_melee_attack(obj/mecha/M)
	return 0

/obj/item/burn()
	if(!QDELETED(src))
		var/turf/T = get_turf(src)
		var/ash_type = /obj/item/ash
		if(w_class == WEIGHT_CLASS_HUGE || w_class == WEIGHT_CLASS_GIGANTIC)
			ash_type = /obj/item/ash
		var/obj/item/ash/A = new ash_type(T)
		A.desc += "\nLooks like this used to be \an [name] some time ago."
		..()

/obj/item/acid_melt()
	if(!QDELETED(src))
		var/turf/T = get_turf(src)
		var/obj/effect/decal/cleanable/molten_object/MO = new(T)
		MO.pixel_x = rand(-16,16)
		MO.pixel_y = rand(-16,16)
		MO.desc = ""
		..()

/obj/item/proc/microwave_act(obj/machinery/microwave/M)
	if(istype(M) && M.dirty < 100)
		M.dirty++

/obj/item/proc/on_mob_death(mob/living/L, gibbed)

/obj/item/proc/grind_requirements(obj/machinery/reagentgrinder/R) //Used to check for extra requirements for grinding an object
	return TRUE

 //Called BEFORE the object is ground up - use this to change grind results based on conditions
 //Use "return -1" to prevent the grinding from occurring
/obj/item/proc/on_grind()

/obj/item/proc/on_juice()

/obj/item/proc/set_force_string()
	switch(force)
		if(0 to 4)
			force_string = "very low"
		if(4 to 7)
			force_string = "low"
		if(7 to 10)
			force_string = "medium"
		if(10 to 11)
			force_string = "high"
		if(11 to 20) //12 is the force of a toolbox
			force_string = "robust"
		if(20 to 25)
			force_string = "very robust"
		else
			force_string = "exceptionally robust"
	last_force_string_check = force

/obj/item/proc/openTip(location, control, params, user)
	if(last_force_string_check != force && !(item_flags & FORCE_STRING_OVERRIDE))
		set_force_string()
	if(!(item_flags & FORCE_STRING_OVERRIDE))
		openToolTip(user,src,params,title = name,content = "[desc]<br>[force ? "<b>Force:</b> [force_string]" : ""]",theme = "")
	else
		openToolTip(user,src,params,title = name,content = "[desc]<br><b>Force:</b> [force_string]",theme = "")

/obj/item/MouseEntered(location, control, params)
	. = ..()
	if((item_flags & IN_INVENTORY || item_flags & IN_STORAGE) && usr.client.prefs.enable_tips && !QDELETED(src))
		var/timedelay = usr.client.prefs.tip_delay/100
		var/user = usr
		tip_timer = addtimer(CALLBACK(src, .proc/openTip, location, control, params, user), timedelay, TIMER_STOPPABLE)//timer takes delay in deciseconds, but the pref is in milliseconds. dividing by 100 converts it.

/obj/item/MouseExited()
	. = ..()
	deltimer(tip_timer)//delete any in-progress timer if the mouse is moved off the item before it finishes
	closeToolTip(usr)


// Called when a mob tries to use the item as a tool.
// Handles most checks.
/obj/item/proc/use_tool(atom/target, mob/living/user, delay, amount=0, volume=0, datum/callback/extra_checks)
	// No delay means there is no start message, and no reason to call tool_start_check before use_tool.
	// Run the start check here so we wouldn't have to call it manually.
	if(!delay && !tool_start_check(user, amount))
		return

	var/skill_modifier = 1

	if(tool_behaviour == TOOL_MINING && ishuman(user))
		var/mob/living/carbon/human/H = user
		skill_modifier = H.mind.get_skill_speed_modifier(/datum/skill/mining)

	delay *= toolspeed * skill_modifier

	// Play tool sound at the beginning of tool usage.
	play_tool_sound(target, volume)

	if(delay)
		// Create a callback with checks that would be called every tick by do_after.
		var/datum/callback/tool_check = CALLBACK(src, .proc/tool_check_callback, user, amount, extra_checks)

		if(ismob(target))
			if(!do_mob(user, target, delay, extra_checks=tool_check))
				return

		else
			if(!do_after(user, delay, target=target, extra_checks=tool_check))
				return
	else
		// Invoke the extra checks once, just in case.
		if(extra_checks && !extra_checks.Invoke())
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
/obj/item/proc/tool_start_check(mob/living/user, amount=0)
	return tool_use_check(user, amount)

// A check called by tool_start_check once, and by use_tool on every tick of delay.
/obj/item/proc/tool_use_check(mob/living/user, amount)
	return !amount

// Generic use proc. Depending on the item, it uses up fuel, charges, sheets, etc.
// Returns TRUE on success, FALSE on failure.
/obj/item/proc/use(used)
	return !used

// Plays item's usesound, if any.
/obj/item/proc/play_tool_sound(atom/target, volume=50)
	if(target && usesound && volume)
		var/played_sound = usesound

		if(islist(usesound))
			played_sound = pick(usesound)

		playsound(target, played_sound, volume, TRUE)

// Used in a callback that is passed by use_tool into do_after call. Do not override, do not call manually.
/obj/item/proc/tool_check_callback(mob/living/user, amount, datum/callback/extra_checks)
	return tool_use_check(user, amount) && (!extra_checks || extra_checks.Invoke())

// Returns a numeric value for sorting items used as parts in machines, so they can be replaced by the rped
/obj/item/proc/get_part_rating()
	return 0

/obj/item/doMove(atom/destination)
	if (ismob(loc))
		var/mob/M = loc
		var/hand_index = M.get_held_index_of_item(src)
		if(hand_index)
			M.held_items[hand_index] = null
			M.update_inv_hands()
			if(M.client)
				M.client.screen -= src
			layer = initial(layer)
			plane = initial(plane)
			appearance_flags &= ~NO_CLIENT_COLOR
			dropped(M, TRUE)
	return ..()

/obj/item/throw_at(atom/target, range, speed, mob/thrower, spin=TRUE, diagonals_first = FALSE, datum/callback/callback)
	if(HAS_TRAIT(src, TRAIT_NODROP))
		return
	return ..()

/obj/item/proc/canStrip(mob/stripper, mob/owner)
	return !HAS_TRAIT(src, TRAIT_NODROP)

/obj/item/proc/doStrip(mob/stripper, mob/owner)
	return owner.dropItemToGround(src)

/obj/item/update_icon()
	update_transform()

/obj/item/proc/ungrip(mob/living/carbon/user, show_message = TRUE)
	if(!user)
		return
	if(twohands_required)
		if(!wielded)
			return
		if(show_message)
			to_chat(user, "<span class='notice'>I drop [src].</span>")
		show_message = FALSE
	if(wielded)
		wielded = FALSE
		if(force_wielded)
			force = initial(force)
		wdefense = initial(wdefense)
		var/obj/item/twohanded/offhand/O = user.get_inactive_held_item()
		if(O && istype(O))
			O.unwield()
	if(altgripped)
		altgripped = FALSE
	update_transform()
	if(user.get_item_by_slot(SLOT_BACK) == src)
		user.update_inv_back()
	else
		user.update_inv_hands()
	if(show_message)
		to_chat(user, "<span class='notice'>I wield [src] normally.</span>")
	if(user.get_active_held_item() == src)
		user.update_a_intents()
	return

/obj/item/proc/altgrip(mob/living/carbon/user)
	if(altgripped)
		return
	altgripped = TRUE
	update_transform()
	to_chat(user, "<span class='notice'>I wield [src] with an alternate grip</span>")
	if(user.get_active_held_item() == src)
		if(alt_intents)
			user.update_a_intents()

/obj/item/proc/wield(mob/living/carbon/user)
	if(wielded)
		return
	if(user.get_inactive_held_item())
		to_chat(user, "<span class='warning'>I need a free hand first.</span>")
		return
	if(user.get_num_arms() < 2)
		to_chat(user, "<span class='warning'>I don't have enough hands.</span>")
		return
	wielded = TRUE
	if(force_wielded)
		force = force_wielded
	wdefense = wdefense + 3
	update_transform()
	to_chat(user, "<span class='notice'>I wield [src] with both hands.</span>")
	playsound(loc, pick('sound/combat/weaponr1.ogg','sound/combat/weaponr2.ogg'), 100, TRUE)
	var/obj/item/twohanded/offhand/O = new(user) ////Let's reserve his other hand~
	O.name = "[name] - offhand"
	O.wielded = TRUE
	user.put_in_inactive_hand(O)
	if(twohands_required)
		if(!wielded)
			user.dropItemToGround(src)
			return
	user.update_a_intents()
	user.update_inv_hands()

/obj/item/attack_self(mob/user)
	. = ..()
	if(twohands_required)
		return
	if(altgripped || wielded) //Trying to unwield it
		ungrip(user)
		return
	if(alt_intents)
		altgrip(user)
	if(gripped_intents)
		wield(user)

/obj/item/equip_to_best_slot(mob/M)
	if(..())
		if(altgripped || wielded)
			ungrip(M, FALSE)


