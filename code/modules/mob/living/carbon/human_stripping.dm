#define POCKET_EQUIP_DELAY (1 SECONDS)

GLOBAL_LIST_INIT(strippable_human_items, create_strippable_list(list(
	/datum/strippable_item/mob_item_slot/head,
	/datum/strippable_item/mob_item_slot/back,
	/datum/strippable_item/mob_item_slot/mask,
	/datum/strippable_item/mob_item_slot/eyes,
	/datum/strippable_item/mob_item_slot/ears,
	/datum/strippable_item/mob_item_slot/uniform,
	/datum/strippable_item/mob_item_slot/suit,
	/datum/strippable_item/mob_item_slot/gloves,
	/datum/strippable_item/mob_item_slot/feet,
	/datum/strippable_item/mob_item_slot/suit_storage,
	/datum/strippable_item/mob_item_slot/id,
	/datum/strippable_item/mob_item_slot/belt,
	/datum/strippable_item/mob_item_slot/pocket/left,
	/datum/strippable_item/mob_item_slot/pocket/right,
	/datum/strippable_item/hand/left,
	/datum/strippable_item/hand/right,
	/datum/strippable_item/mob_item_slot/handcuffs,
)))

GLOBAL_LIST_INIT(strippable_human_layout, list(
	list(
		new /datum/strippable_item_layout("left_hand"),
		new /datum/strippable_item_layout("right_hand")
	),
	list(
		new /datum/strippable_item_layout("back")
	),
	list(
		new /datum/strippable_item_layout("head"),
		new /datum/strippable_item_layout("mask"),
		new /datum/strippable_item_layout("corgi_collar"),
		new /datum/strippable_item_layout("parrot_headset"),
		new /datum/strippable_item_layout("eyes"),
		new /datum/strippable_item_layout("ears")
	),
	list(
		new /datum/strippable_item_layout("suit"),
		new /datum/strippable_item_layout("suit_storage", TRUE),
		new /datum/strippable_item_layout("shoes"),
		new /datum/strippable_item_layout("gloves"),
		new /datum/strippable_item_layout("uniform"),
		new /datum/strippable_item_layout("belt", TRUE),
		new /datum/strippable_item_layout("left_pocket", TRUE),
		new /datum/strippable_item_layout("right_pocket", TRUE),
		new /datum/strippable_item_layout("id"),
		new /datum/strippable_item_layout("handcuffs"),
	),
))

/datum/strippable_item/mob_item_slot/eyes
	key = STRIPPABLE_ITEM_EYES
	item_slot = ITEM_SLOT_EYES

/datum/strippable_item/mob_item_slot/ears
	key = STRIPPABLE_ITEM_EARS
	item_slot = ITEM_SLOT_EARS

/datum/strippable_item/mob_item_slot/uniform
	key = STRIPPABLE_ITEM_UNIFORM
	item_slot = ITEM_SLOT_ICLOTHING

/datum/strippable_item/mob_item_slot/uniform/get_alternate_action(atom/source, mob/user)
	var/obj/item/clothing/under/uniform = get_item(source)
	if(!istype(uniform))
		return null
	return uniform?.has_sensor? "adjust_sensors" : null

/datum/strippable_item/mob_item_slot/uniform/alternate_action(atom/source, mob/user)
	var/obj/item/clothing/under/uniform = get_item(source)
	if(!istype(uniform))
		return null
	uniform.set_sensors(user)

/datum/strippable_item/mob_item_slot/suit
	key = STRIPPABLE_ITEM_SUIT
	item_slot = ITEM_SLOT_OCLOTHING

/datum/strippable_item/mob_item_slot/gloves
	key = STRIPPABLE_ITEM_GLOVES
	item_slot = ITEM_SLOT_GLOVES

/datum/strippable_item/mob_item_slot/feet
	key = STRIPPABLE_ITEM_FEET
	item_slot = ITEM_SLOT_FEET

/datum/strippable_item/mob_item_slot/suit_storage
	key = STRIPPABLE_ITEM_SUIT_STORAGE
	item_slot = ITEM_SLOT_SUITSTORE

/datum/strippable_item/mob_item_slot/suit_storage/is_unavailable(atom/source)
	. = ..()
	if(.)
		return

	if(!ishuman(source))
		return

	var/mob/living/carbon/human/human = source

	if(!human.wear_suit)
		return TRUE

/datum/strippable_item/mob_item_slot/id
	key = STRIPPABLE_ITEM_ID
	item_slot = ITEM_SLOT_ID

/datum/strippable_item/mob_item_slot/belt
	key = STRIPPABLE_ITEM_BELT
	item_slot = ITEM_SLOT_BELT

/datum/strippable_item/mob_item_slot/pocket
	/// Which pocket we're referencing. Used for visible text.
	var/pocket_side = "yell at coders!!!!!"

/datum/strippable_item/mob_item_slot/pocket/get_obscuring(atom/source)
	return isnull(get_item(source)) \
		? STRIPPABLE_OBSCURING_NONE \
		: STRIPPABLE_OBSCURING_HIDDEN

/datum/strippable_item/mob_item_slot/pocket/get_equip_delay(obj/item/equipping)
	return POCKET_EQUIP_DELAY

/datum/strippable_item/mob_item_slot/pocket/start_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if(!.)
		warn_owner(source)

/datum/strippable_item/mob_item_slot/pocket/start_unequip(atom/source, mob/user)
	var/obj/item/item = get_item(source)
	if(isnull(item))
		return FALSE

	to_chat(user, "<span class='notice'>You try to empty [source]'s [pocket_side] pocket.</span>")

	var/log_message = "[key_name(source)] is being pickpocketed of [item] by [key_name(user)] ([pocket_side])"
	source.log_message(log_message, LOG_ATTACK, color="red")
	user.log_message(log_message, LOG_ATTACK, color="red", log_globally=FALSE)
	item.add_fingerprint(user, "tried to pickpocket [key_name(source)]")

	var/result = start_unequip_mob(item, source, user, POCKET_STRIP_DELAY)

	if(!result)
		warn_owner(source)

	return result

/// Warns the pocket owner that their pocket is being fumbled with
/datum/strippable_item/mob_item_slot/pocket/proc/warn_owner(atom/owner)
	to_chat(owner, "<span class='warning'>You feel your [pocket_side] pocket being fumbled with!</span>")

/datum/strippable_item/mob_item_slot/pocket/left
	key = STRIPPABLE_ITEM_LPOCKET
	item_slot = ITEM_SLOT_L_POCKET
	pocket_side = "left"

/datum/strippable_item/mob_item_slot/pocket/right
	key = STRIPPABLE_ITEM_RPOCKET
	item_slot = ITEM_SLOT_R_POCKET
	pocket_side = "right"


#undef POCKET_EQUIP_DELAY
