//PASS FLAGS
#define PASSTABLE (1<<0)
#define PASSGLASS (1<<1)
#define PASSGRILLE (1<<2)
#define PASSBLOB (1<<3)
#define PASSMOB (1<<4)
#define PASSSMALLSTRUCT (1<<5)
#define PASSFIRE (1<<6)
#define PASSXENO (1<<7)
#define HOVERING (PASSTABLE|PASSMOB|PASSSMALLSTRUCT|PASSFIRE)

//==========================================================================================



//flags_atom

#define NOINTERACT (1<<3)		// You can't interact with it, at all. Useful when doing certain animations.
#define CONDUCT (1<<4)		// conducts electricity (metal etc.)
#define ON_BORDER (1<<5)		// 'border object'. item has priority to check when entering or leaving
#define NOBLOODY (1<<6)		// Don't want a blood overlay on this one.
#define DIRLOCK (1<<7)		// movable atom won't change direction when Moving()ing. Useful for items that have several dir states.
#define INITIALIZED (1<<8)  	//Whether /atom/Initialize() has already run for the object
#define NODECONSTRUCT (1<<9)
#define OVERLAY_QUEUED (1<<10)
#define PREVENT_CLICK_UNDER (1<<11)		//Prevent clicking things below it on the same turf
#define CRITICAL_ATOM (1<<12)		//Use when this shouldn't be obscured by large icons.
///Does not cascade explosions to its contents.
#define PREVENT_CONTENTS_EXPLOSION (1<<13)
/// was this spawned by an admin? used for stat tracking stuff.
#define ADMIN_SPAWNED (1<<14)
/// Can this atom be bumped attack
#define BUMP_ATTACKABLE (1<<15)
///This atom will not be qdeled when a shuttle lands on it; it will just move onto the shuttle tile. It will stay on the ground when the shuttle takes off
#define SHUTTLE_IMMUNE (1<<16)
/// Should we use the initial icon for display? Mostly used by overlay only objects
#define HTML_USE_INITAL_ICON_1 (1<<21)

//turf-only flags
#define AI_BLOCKED (1<<0) //Prevent ai from going onto this turf
#define UNUSED_RESERVATION_TURF_1 (1<<1)
/// If a turf can be made dirty at roundstart. This is also used in areas.
#define CAN_BE_DIRTY_1 (1<<2)

//==========================================================================================

//flags_barrier
#define HANDLE_BARRIER_CHANCE 1
#define HANDLE_BARRIER_BLOCK 2


//bitflags that were previously under flags_atom, these only apply to items.
//clothing specific stuff uses flags_inventory.
//flags_item
#define NODROP (1<<0)	// Cannot be dropped/unequipped at all, only deleted.
#define NOBLUDGEON (1<<1)	// when an item has this it produces no "X has been hit by Y with Z" message with the default handler
#define DELONDROP (1<<2)	// Deletes on drop instead of falling on the floor.
#define TWOHANDED (1<<3)	// The item is twohanded.
#define WIELDED (1<<4)	// The item is wielded with both hands.
#define ITEM_ABSTRACT (1<<5)	//The item is abstract (grab, powerloader_clamp, etc)
#define BEING_REMOVED (1<<6)	//Cuffs
#define DOES_NOT_NEED_HANDS (1<<7)	//Dont need hands to use it
#define SYNTH_RESTRICTED (1<<8)	//Prevents synths from wearing items with this flag
#define IMPEDE_JETPACK (1<<9)  //Reduce the range of jetpack
#define DRAINS_XENO (1<<10)  //Enables the item to collect resource for chem_booster component
#define CAN_BUMP_ATTACK (1<<11)	 //Item triggers bump attack
#define NO_VACUUM (1<<12) //Roomba won't eat this
#define IS_DEPLOYABLE (1<<13) //Item can be deployed into a machine
#define DEPLOY_ON_INITIALIZE (1<<14)
#define IS_DEPLOYED (1<<15) //If this is on an item, said item is currently deployed
#define DEPLOYED_NO_PICKUP  (1<<16) //Disables deployed item pickup
#define DEPLOYED_NO_ROTATE  (1<<17) //Disables deployed item rotation abilities to rotate.
#define DEPLOYED_WRENCH_DISASSEMBLE (1<<18) //If this is on an item, the item can only be disassembled using a wrench once deployed.

//==========================================================================================

//flags_inv_hide
//Bit flags for the flags_inv_hide variable, which determine when a piece of clothing hides another. IE a helmet hiding glasses.

#define HIDEGLOVES (1<<0)
#define HIDESUITSTORAGE (1<<1)
#define HIDEJUMPSUIT (1<<2)
#define HIDESHOES (1<<3)
#define HIDEMASK (1<<4)
#define HIDEEARS (1<<5)		//(ears means headsets and such)
#define HIDEEYES (1<<6)		//(eyes means glasses)
#define HIDELOWHAIR (1<<7)		// temporarily removes the user's facial hair overlay.
#define HIDETOPHAIR (1<<8)		// temporarily removes the user's hair overlay. Leaves facial hair.
#define HIDEALLHAIR (1<<9)		// temporarily removes the user's hair, facial and otherwise.
#define HIDEFACE (1<<10)	//Dictates whether we appear as unknown.


//==========================================================================================

//flags_inventory

//SHOES ONLY===========================================================================================
#define NOSLIPPING (1<<0) 	//prevents from slipping on wet floors, in space etc
//SHOES ONLY===========================================================================================

//HELMET AND MASK======================================================================================
#define COVEREYES (1<<1) // Covers the eyes/protects them.
#define COVERMOUTH (1<<2) // Covers the mouth.
#define ALLOWINTERNALS (1<<3)	//mask allows internals
#define BLOCKGASEFFECT (1<<4) // blocks the effect that chemical clouds would have on a mob --glasses, mask and helmets
//HELMET AND MASK======================================================================================

//SUITS AND HELMETS====================================================================================
//To successfully stop taking all pressure damage you must have both a suit and head item with this flag.
#define BLOCKSHARPOBJ (1<<6)  //From /tg: prevents syringes, parapens and hypos if the external suit or helmet (if targeting head) has this flag. Example: space suits, biosuit, bombsuits, thick suits that cover your body.
#define NOPRESSUREDMAGE (1<<7) //This flag is used on the flags variable for SUIT and HEAD items which stop pressure damage.

#define NOQUICKEQUIP (1<<8) // Prevents the item from being handled via quick-equip hotkeys. Can still manipulate the inventory and be inserted into the slot from the hand, however.

//SUITS AND HELMETS====================================================================================
//vision obscuring facegear and etc.
#define TINT_NONE 0
#define TINT_1 1
#define TINT_2 2
#define TINT_3 3
#define TINT_4 4
#define TINT_5 5
#define TINT_BLIND 6

//Inventory depth: limits how many nested storage items you can access directly.
//1: stuff in mob, 2: stuff in backpack, 3: stuff in box in backpack, etc
#define INVENTORY_DEPTH 4
#define STORAGE_VIEW_DEPTH 3


//===========================================================================================
//Marine armor only, use for flags_armor_features.
#define ARMOR_SQUAD_OVERLAY (1<<0)
#define ARMOR_LAMP_OVERLAY (1<<1)
#define ARMOR_LAMP_ON (1<<2)
#define ARMOR_IS_REINFORCED (1<<3)
#define ARMOR_NO_DECAP (1<<4)
//===========================================================================================

//===========================================================================================
//Marine helmet only, use for flags_marine_helmet.
#define HELMET_SQUAD_OVERLAY (1<<0)
#define HELMET_GARB_OVERLAY (1<<1)
#define HELMET_DAMAGE_OVERLAY (1<<2)
#define HELMET_STORE_GARB (1<<3)
#define HELMET_IS_DAMAGED (1<<4)
//===========================================================================================

//ITEM INVENTORY SLOT BITMASKS
//flags_equip_slot
#define ITEM_SLOT_OCLOTHING (1<<0)
#define ITEM_SLOT_ICLOTHING (1<<1)
#define ITEM_SLOT_GLOVES (1<<2)
#define ITEM_SLOT_EYES (1<<3)
#define ITEM_SLOT_EARS (1<<4)
#define ITEM_SLOT_MASK (1<<5)
#define ITEM_SLOT_HEAD (1<<6)
#define ITEM_SLOT_FEET (1<<7)
#define ITEM_SLOT_ID (1<<8)
#define ITEM_SLOT_BELT (1<<9)
#define ITEM_SLOT_BACK (1<<10)
#define ITEM_SLOT_POCKET (1<<11)	//this is to allow items with a w_class of 3 or 4 to fit in pockets.
#define ITEM_SLOT_DENYPOCKET (1<<12)	//this is to deny items with a w_class of 2 or 1 to fit in pockets.
#define ITEM_SLOT_LEGS (1<<13)
//=================================================

//slots
//Text strings so that the slots can be associated when doing inventory lists.
#define SLOT_WEAR_ID 1
#define SLOT_EARS 2
#define SLOT_W_UNIFORM 3
#define SLOT_LEGS 4
#define SLOT_SHOES 5
#define SLOT_GLOVES 6
#define SLOT_BELT 7
#define SLOT_WEAR_SUIT 8
#define SLOT_GLASSES 9
#define SLOT_WEAR_MASK 10
#define SLOT_HEAD 11
#define SLOT_BACK 12
#define SLOT_L_STORE 13
#define SLOT_R_STORE 14
#define SLOT_ACCESSORY 15
#define SLOT_S_STORE 16
#define SLOT_L_HAND 17
#define SLOT_R_HAND 18
#define SLOT_HANDCUFFED 19
#define SLOT_IN_BOOT 21
#define SLOT_IN_BACKPACK 22
#define SLOT_IN_SUIT 23
#define SLOT_IN_ACCESSORY 24
#define SLOT_IN_HOLSTER 25
#define SLOT_IN_B_HOLSTER 26
#define SLOT_IN_S_HOLSTER 27
#define SLOT_IN_STORAGE 28
#define SLOT_IN_L_POUCH 29
#define SLOT_IN_R_POUCH 30
#define SLOT_IN_HEAD 31
#define SLOT_IN_BELT 32
//=================================================


//Inventory slot strings.
#define slot_back_str "slot_back"
#define slot_l_hand_str "slot_l_hand"
#define slot_r_hand_str "slot_r_hand"
#define slot_w_uniform_str "slot_w_uniform"
#define slot_head_str "slot_head"
#define slot_wear_suit_str "slot_suit"
#define slot_ear_str "slot_ear"
#define slot_belt_str "slot_belt"
#define slot_shoes_str "slot_shoes"
#define slot_wear_mask_str "slot_wear_mask"
#define slot_handcuffed_str "slot_handcuffed"
#define slot_wear_id_str "slot_wear_id"
#define slot_gloves_str "slot_gloves"
#define slot_glasses_str "slot_glasses"
#define slot_s_store_str "slot_s_store"
#define slot_l_store_str "slot_l_store"
#define slot_r_store_str "slot_r_store"
#define slot_tie_str "slot_tie"

///Correspondance between slot strings and slot numbers
GLOBAL_LIST_INIT(slot_str_to_slot, list(
	"slot_back" = SLOT_BACK,
	"slot_l_hand" = SLOT_L_HAND,
	"slot_r_hand" = SLOT_R_HAND,
	"slot_w_uniform" = SLOT_W_UNIFORM,
	"slot_head" = SLOT_HEAD,
	"slot_suit" = SLOT_WEAR_SUIT,
	"slot_ear" = SLOT_EARS,
	"slot_belt" = SLOT_BELT,
	"slot_shoes" = SLOT_SHOES,
	"slot_wear_mask" = SLOT_WEAR_MASK,
	"slot_handcuffed" = SLOT_HANDCUFFED,
	"slot_wear_id" = SLOT_WEAR_ID,
	"slot_gloves" = SLOT_GLOVES,
	"slot_glasses" = SLOT_GLASSES,
	"slot_s_store" = SLOT_S_STORE,
	"slot_l_store" = SLOT_L_STORE,
	"slot_r_store" = SLOT_R_STORE,
	"slot_tie" = SLOT_ACCESSORY,
))

//I hate that this has to exist
/proc/slotdefine2slotbit(slotdefine) //Keep this up to date with the value of SLOT BITMASKS and SLOTS (the two define sections above)
	. = 0
	switch(slotdefine)
		if(SLOT_BACK)
			. = ITEM_SLOT_BACK
		if(SLOT_WEAR_MASK)
			. = ITEM_SLOT_MASK
		if(SLOT_BELT)
			. = ITEM_SLOT_BELT
		if(SLOT_WEAR_ID)
			. = ITEM_SLOT_ID
		if(SLOT_EARS)
			. = ITEM_SLOT_EARS
		if(SLOT_GLASSES)
			. = ITEM_SLOT_EYES
		if(SLOT_GLOVES)
			. = ITEM_SLOT_GLOVES
		if(SLOT_HEAD)
			. = ITEM_SLOT_HEAD
		if(SLOT_SHOES)
			. = ITEM_SLOT_FEET
		if(SLOT_WEAR_SUIT)
			. = ITEM_SLOT_OCLOTHING
		if(SLOT_W_UNIFORM)
			. = ITEM_SLOT_ICLOTHING
		if(SLOT_L_STORE, SLOT_R_STORE)
			. = ITEM_SLOT_POCKET
		if(SLOT_LEGS)
			. = ITEM_SLOT_LEGS

//=================================================
// bitflags for clothing parts
//thermal_protection_flags
#define HEAD (1<<0)
#define FACE (1<<1)
#define EYES (1<<2)
#define CHEST (1<<3)
#define GROIN (1<<4)
#define LEG_LEFT (1<<5)
#define LEG_RIGHT (1<<6)
#define LEGS (LEG_RIGHT|LEG_LEFT)
#define FOOT_LEFT (1<<7)
#define FOOT_RIGHT (1<<8)
#define FEET (FOOT_RIGHT|FOOT_LEFT)
#define ARM_LEFT (1<<9)
#define ARM_RIGHT (1<<10)
#define ARMS (ARM_RIGHT|ARM_LEFT)
#define HAND_LEFT (1<<11)
#define HAND_RIGHT (1<<12)
#define HANDS (HAND_RIGHT|HAND_LEFT)
#define FULL_BODY (~0)
//=================================================

// bitflags for the percentual amount of protection a piece of clothing which covers the body part offers.
// Used with human/proc/get_flags_heat_protection() and human/proc/get_flags_cold_protection()
// The values here should add up to 1.
// Hands and feet have 2.5%, arms and legs 7.5%, each of the torso parts has 15% and the head has 30%
#define THERMAL_PROTECTION_HEAD 0.3
#define THERMAL_PROTECTION_UPPER_TORSO 0.15
#define THERMAL_PROTECTION_LOWER_TORSO 0.15
#define THERMAL_PROTECTION_LEG_LEFT 0.075
#define THERMAL_PROTECTION_LEG_RIGHT 0.075
#define THERMAL_PROTECTION_FOOT_LEFT 0.025
#define THERMAL_PROTECTION_FOOT_RIGHT 0.025
#define THERMAL_PROTECTION_ARM_LEFT 0.075
#define THERMAL_PROTECTION_ARM_RIGHT 0.075
#define THERMAL_PROTECTION_HAND_LEFT 0.025
#define THERMAL_PROTECTION_HAND_RIGHT 0.025
//=================================================

//=================================================
#define SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE 2.0 //what min_cold_protection_temperature is set to for space-helmet quality headwear. MUST NOT BE 0.
#define SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE 2.0 //what min_cold_protection_temperature is set to for space-suit quality jumpsuits or suits. MUST NOT BE 0.
#define SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE 5000	//These need better heat protect, but not as good heat protect as firesuits.
#define FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE 30000 //what max_heat_protection_temperature is set to for firesuit quality headwear. MUST NOT BE 0.
#define FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE 30000 //for fire helmet quality items (red and white hardhats)
#define HELMET_MIN_COLD_PROTECTION_TEMPERATURE 200	//For normal helmets
#define HELMET_MAX_HEAT_PROTECTION_TEMPERATURE 600	//For normal helmets
#define ARMOR_MIN_COLD_PROTECTION_TEMPERATURE 200	//For armor
#define ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE 600	//For armor
#define HEAVYHELMET_MAX_HEAT_PROTECTION_TEMPERATURE 15000	//For heavy helmets
#define HEAVYARMOR_MAX_HEAT_PROTECTION_TEMPERATURE 15000	//For heavy armor

#define GLOVES_MIN_COLD_PROTECTION_TEMPERATURE 200	//For some gloves (black and)
#define GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE 650	//For some gloves
#define SHOE_MIN_COLD_PROTECTION_TEMPERATURE 200	//For gloves
#define SHOE_MAX_HEAT_PROTECTION_TEMPERATURE 650	//For gloves

#define ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE 200 //For the ice planet map protection from the elements.
//=================================================

//ITEM INVENTORY WEIGHT, FOR w_class
#define WEIGHT_CLASS_TINY 1 //Usually items smaller then a human hand, ex: Playing Cards, Lighter, Scalpel, Coins/Money
#define WEIGHT_CLASS_SMALL 2 //Pockets can hold small and tiny items, ex: Flashlight, Multitool, Grenades, GPS Device
#define WEIGHT_CLASS_NORMAL 3 //Standard backpacks can carry tiny, small & normal items, ex: Fire extinguisher, Stunbaton, Gas Mask, Metal Sheets
#define WEIGHT_CLASS_BULKY 4 //Items that can be weilded or equipped but not stored in an inventory, ex: Defibrillator, Backpack, Space Suits
#define WEIGHT_CLASS_HUGE 5 //Usually represents objects that require two hands to operate, ex: Shotgun, Two Handed Melee Weapons
#define WEIGHT_CLASS_GIGANTIC 6 //Essentially means it cannot be picked up or placed in an inventory, ex: Mech Parts, Safe

#define SLOT_EQUIP_ORDER list(\
	SLOT_IN_BOOT,\
	SLOT_IN_L_POUCH,\
	SLOT_IN_R_POUCH,\
	SLOT_IN_HEAD,\
	SLOT_IN_ACCESSORY,\
	SLOT_IN_HOLSTER,\
	SLOT_IN_S_HOLSTER,\
	SLOT_IN_B_HOLSTER,\
	SLOT_BACK,\
	SLOT_WEAR_ID,\
	SLOT_GLASSES,\
	SLOT_W_UNIFORM,\
	SLOT_ACCESSORY,\
	SLOT_WEAR_SUIT,\
	SLOT_WEAR_MASK,\
	SLOT_HEAD,\
	SLOT_SHOES,\
	SLOT_GLOVES,\
	SLOT_EARS,\
	SLOT_BELT,\
	SLOT_S_STORE,\
	SLOT_L_STORE,\
	SLOT_R_STORE,\
	SLOT_IN_STORAGE,\
	SLOT_IN_SUIT,\
	SLOT_IN_BACKPACK,\
	SLOT_IN_BELT\
	)

#define SLOT_DRAW_ORDER list(\
	SLOT_IN_HOLSTER,\
	SLOT_IN_S_HOLSTER,\
	SLOT_IN_B_HOLSTER,\
	SLOT_IN_ACCESSORY,\
	SLOT_S_STORE,\
	SLOT_IN_L_POUCH,\
	SLOT_IN_R_POUCH,\
	SLOT_BELT,\
	SLOT_WEAR_SUIT,\
	SLOT_IN_STORAGE,\
	SLOT_L_STORE,\
	SLOT_R_STORE,\
	SLOT_BACK,\
	SLOT_IN_BOOT,\
	SLOT_IN_HEAD\
	)

#define SLOT_ALL list(\
	SLOT_WEAR_ID,\
	SLOT_EARS,\
	SLOT_W_UNIFORM,\
	SLOT_LEGS,\
	SLOT_SHOES,\
	SLOT_GLOVES,\
	SLOT_BELT,\
	SLOT_WEAR_SUIT,\
	SLOT_GLASSES,\
	SLOT_WEAR_MASK,\
	SLOT_HEAD,\
	SLOT_BACK,\
	SLOT_L_STORE,\
	SLOT_R_STORE,\
	SLOT_ACCESSORY,\
	SLOT_S_STORE,\
	SLOT_L_HAND,\
	SLOT_R_HAND,\
	SLOT_HANDCUFFED,\
	SLOT_IN_BOOT,\
	SLOT_IN_BACKPACK,\
	SLOT_IN_SUIT,\
	SLOT_IN_ACCESSORY,\
	SLOT_IN_HOLSTER,\
	SLOT_IN_B_HOLSTER,\
	SLOT_IN_S_HOLSTER,\
	SLOT_IN_STORAGE,\
	SLOT_IN_L_POUCH,\
	SLOT_IN_R_POUCH,\
	SLOT_IN_HEAD,\
	SLOT_IN_BELT,\
)

#define ITEM_NOT_EQUIPPED 0
#define ITEM_EQUIPPED_CARRIED 1 //To hands, a storage or the likes.
#define ITEM_EQUIPPED_WORN 2 //Actually worn on the body.

#define SLOT_FLUFF_DRAW list(\
	"Suit Storage",\
	"Suit Inside",\
	"Belt",\
	"Back",\
	"Boot",\
	"Helmet",\
	"Left Pocket",\
	"Right Pocket",\
	"Webbing",\
	"Belt",\
	"Belt Holster",\
	"Suit Storage Holster",\
	"Back Holster",\
)

/proc/slot_fluff_to_flag(slot)
	switch(slot)
		if("Suit Storage")
			return SLOT_S_STORE
		if("Suit Inside")
			return SLOT_WEAR_SUIT
		if("Belt")
			return SLOT_BELT
		if("Back")
			return SLOT_BACK
		if("Boot")
			return SLOT_IN_BOOT
		if("Helmet")
			return SLOT_IN_HEAD
		if("Left Pocket")
			return SLOT_L_STORE
		if("Right Pocket")
			return SLOT_R_STORE
		if("Webbing")
			return SLOT_IN_ACCESSORY
		if("Belt")
			return SLOT_IN_BELT
		if("Belt Holster")
			return SLOT_IN_HOLSTER
		if("Suit Storage Holster")
			return SLOT_IN_S_HOLSTER
		if("Back Holster")
			return SLOT_IN_B_HOLSTER

/proc/slot_flag_to_fluff(slot)
	switch(slot)
		if(SLOT_S_STORE)
			return "Suit Storage"
		if(SLOT_WEAR_SUIT)
			return "Suit Inside"
		if(SLOT_BELT)
			return "Belt"
		if(SLOT_BACK)
			return "Back"
		if(SLOT_IN_BOOT)
			return "Boot"
		if(SLOT_IN_HEAD)
			return "Helmet"
		if(SLOT_L_STORE)
			return "Left Pocket"
		if(SLOT_R_STORE)
			return "Right Pocket"
		if(SLOT_IN_ACCESSORY)
			return "Webbing"
		if(SLOT_IN_BELT)
			return "Belt"
		if(SLOT_IN_HOLSTER)
			return "Belt Holster"
		if(SLOT_IN_S_HOLSTER)
			return "Suit Storage Holster"
		if(SLOT_IN_B_HOLSTER)
			return "Back Holster"
