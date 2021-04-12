


GLOBAL_LIST_INIT(item_slot_list, create_item_slot_list(list(
	/datum/item_slot/head,
	/datum/item_slot/back,
	/datum/item_slot/mask,
	/datum/item_slot/eyes,
	/datum/item_slot/jumpsuit,
	/datum/item_slot/armor,
	/datum/item_slot/gloves,
	/datum/item_slot/feet,
	/datum/item_slot/armor_storage,
	/datum/item_slot/belt,
	/datum/item_slot/pocket/left,
	/datum/item_slot/pocket/right,
)))

#define ITEM_SLOT_KEY_HEAD "head"
#define ITEM_SLOT_KEY_BACK "back"
#define ITEM_SLOT_KEY_MASK "mask"
#define ITEM_SLOT_KEY_EYES "eyes"
#define ITEM_SLOT_KEY_JUMPSUIT "jumpsuit"
#define ITEM_SLOT_KEY_ARMOR "armor"
#define ITEM_SLOT_KEY_GLOVES "gloves"
#define ITEM_SLOT_KEY_FEET "shoes"
#define ITEM_SLOT_KEY_ARMOR_STORAGE "armor_storage"
#define ITEM_SLOT_KEY_BELT "belt"
#define ITEM_SLOT_KEY_LPOCKET "left_pocket"
#define ITEM_SLOT_KEY_RPOCKET "right_pocket"


/// Creates an assoc list of keys to /datum/item_slot
/proc/create_item_slot_list(types)
	var/list/item_slot_list = list()

	for (var/item_slot_type in types)
		var/datum/item_slot/item_slot = new item_slot_type
		item_slot_list[item_slot.key] = item_slot

	return item_slot_list

/datum/item_slot 
	/// The item slot key used by the interface
	var/key
	/// The corresponding item slot on the mob
	var/item_slot

/datum/item_slot/head
	key = ITEM_SLOT_KEY_HEAD
	item_slot = SLOT_HEAD

/datum/item_slot/back
	key = ITEM_SLOT_KEY_BACK
	item_slot = SLOT_BACK

/datum/item_slot/mask
	key = ITEM_SLOT_KEY_MASK
	item_slot = SLOT_WEAR_MASK

/datum/item_slot/eyes
	key = ITEM_SLOT_KEY_EYES
	item_slot = SLOT_GLASSES

/datum/item_slot/jumpsuit
	key = ITEM_SLOT_KEY_JUMPSUIT
	item_slot = SLOT_W_UNIFORM

/datum/item_slot/armor
	key = ITEM_SLOT_KEY_ARMOR
	item_slot = SLOT_WEAR_SUIT

/datum/item_slot/gloves
	key = ITEM_SLOT_KEY_GLOVES
	item_slot = SLOT_GLOVES

/datum/item_slot/feet
	key = ITEM_SLOT_KEY_FEET
	item_slot = SLOT_SHOES

/datum/item_slot/armor_storage
	key = ITEM_SLOT_KEY_ARMOR_STORAGE
	item_slot = SLOT_S_STORE

/datum/item_slot/belt
	key = ITEM_SLOT_KEY_BELT
	item_slot = SLOT_BELT

/datum/item_slot/pocket/left
	key = ITEM_SLOT_KEY_LPOCKET
	item_slot = SLOT_L_STORE

/datum/item_slot/pocket/right
	key = ITEM_SLOT_KEY_RPOCKET
	item_slot = SLOT_R_STORE
