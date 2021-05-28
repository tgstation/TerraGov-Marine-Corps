//List of all visible and accessible slot on the loadout maker
GLOBAL_LIST_INIT(visible_item_slot_list, list(
	slot_head_str,
	slot_back_str,
	slot_wear_mask_str,
	slot_glasses_str,
	slot_w_uniform_str,
	slot_wear_suit_str,
	slot_gloves_str,
	slot_shoes_str,
	slot_s_store_str,
	slot_belt_str,
	slot_l_store_str,
	slot_r_store_str,
))

///All the vendor types which the automated loadout vendor can take items from
GLOBAL_LIST_INIT(loadout_linked_vendor, list(
	/obj/machinery/vending/marine/shared,
	/obj/machinery/vending/uniform_supply,
	/obj/machinery/vending/armor_supply,
	/obj/machinery/vending/marineFood,
))

///All the items that once they are in loadouts, should not have stock checked when sold by the loadout vendor
GLOBAL_LIST_INIT(bypass_vendor_item, typecacheof(list(
	/obj/item/ammo_magazine/handful,
	)))

#define MARINE_LOADOUT "marine"
#define ENGINEER_LOADOUT "engie"
#define MEDIC_LOADOUT "medic"
#define SMARTGUNNER_LOADOUT "smartgunner"
#define LEADER_LOADOUT "leader"

//Defines use for the visualisation of loadouts
#define NO_OFFSET "0%"
#define NO_SCALING 1
#define MODULAR_ARMOR_OFFSET_Y "-10%"
#define MODULAR_ARMOR_SCALING 1.2

///The maximum number of loadouts one player can have
#define MAXIMUM_LOADOUT 50
