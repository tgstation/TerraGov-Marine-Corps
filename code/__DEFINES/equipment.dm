//PASS FLAGS

///Pass low objects like tables or windowframes
#define PASS_LOW_STRUCTURE (1<<0)
///lasers and the like can pass unobstructed
#define PASS_GLASS (1<<1)
///Pass grilles
#define PASS_GRILLE (1<<2)
///Pass mobs
#define PASS_MOB (1<<3)
///Pass defensive structures like barricades
#define PASS_DEFENSIVE_STRUCTURE (1<<4)
///Allows Mobs to pass fire without ignition
#define PASS_FIRE (1<<5)
///Pass xenos
#define PASS_XENO (1<<6)
///you can throw past
#define PASS_THROW (1<<7)
///projectiles can pass
#define PASS_PROJECTILE (1<<8)
///non-airtight, gas/fire can pass
#define PASS_AIR (1<<9)
///Mobs can walk freely between turfs with walkover flagged objects
#define PASS_WALKOVER (1<<10)

#define PASSABLE (PASS_THROW|PASS_PROJECTILE|PASS_AIR)
#define HOVERING (PASS_LOW_STRUCTURE|PASS_MOB|PASS_DEFENSIVE_STRUCTURE|PASS_FIRE)

//==========================================================================================



//flags_atom

#define UNUSED_RESERVATION_TURF_1 (1<<0)
#define AI_BLOCKED (1<<1) //Prevent ai from going onto this turf
#define NOINTERACT (1<<2)		// You can't interact with it, at all. Useful when doing certain animations.
#define CONDUCT (1<<3)		// conducts electricity (metal etc.)
#define ON_BORDER (1<<4)		// 'border object'. item has priority to check when entering or leaving
#define NOBLOODY (1<<5)		// Don't want a blood overlay on this one.
#define DIRLOCK (1<<6)		// movable atom won't change direction when Moving()ing. Useful for items that have several dir states.
#define INITIALIZED (1<<7)  	//Whether /atom/Initialize() has already run for the object
#define NODECONSTRUCT (1<<8)
#define PREVENT_CLICK_UNDER (1<<9)		//Prevent clicking things below it on the same turf
#define CRITICAL_ATOM (1<<10)		//Use when this shouldn't be obscured by large icons.
///Does not cascade explosions to its contents.
#define PREVENT_CONTENTS_EXPLOSION (1<<11)
/// was this spawned by an admin? used for stat tracking stuff.
#define ADMIN_SPAWNED (1<<12)
/// Can this atom be bumped attack
#define BUMP_ATTACKABLE (1<<13)
///This atom will not be qdeled when a shuttle lands on it; it will just move onto the shuttle tile. It will stay on the ground when the shuttle takes off
#define SHUTTLE_IMMUNE (1<<14)
/// Should we use the initial icon for display? Mostly used by overlay only objects
#define HTML_USE_INITAL_ICON_1 (1<<15)

//==========================================================================================

//flags_barrier
#define HANDLE_BARRIER_CHANCE (1<<0)
#define HANDLE_BARRIER_BLOCK (1<<1)


//bitflags that were previously under flags_atom, these only apply to items.
//clothing specific stuff uses flags_inventory.
//flags_item
#define NOBLUDGEON (1<<0)	// when an item has this it produces no "X has been hit by Y with Z" message with the default handler
#define DELONDROP (1<<1)	// Deletes on drop instead of falling on the floor.
#define TWOHANDED (1<<2)	// The item is twohanded.
#define WIELDED (1<<3)	// The item is wielded with both hands.
#define ITEM_ABSTRACT (1<<4)	//The item is abstract (grab, powerloader_clamp, etc)
#define DOES_NOT_NEED_HANDS (1<<5)	//Dont need hands to use it
#define SYNTH_RESTRICTED (1<<6)	//Prevents synths from wearing items with this flag
#define IMPEDE_JETPACK (1<<7)  //Reduce the range of jetpack
#define CAN_BUMP_ATTACK (1<<8)	 //Item triggers bump attack
#define IS_DEPLOYABLE (1<<9) //Item can be deployed into a machine
#define DEPLOY_ON_INITIALIZE (1<<10)
#define IS_DEPLOYED (1<<11) //If this is on an item, said item is currently deployed
#define DEPLOYED_NO_PICKUP  (1<<12) //Disables deployed item pickup
#define DEPLOYED_NO_ROTATE  (1<<13) //Disables deployed item rotation abilities to rotate.
#define DEPLOYED_NO_ROTATE_ANCHORED (1<<14) //Disables deployed item rotation if anchored.
#define DEPLOYED_WRENCH_DISASSEMBLE (1<<15) //If this is on an item, the item can only be disassembled using a wrench once deployed.
#define DEPLOYED_ANCHORED_FIRING_ONLY (1<<16) //Disables firing deployable if it is not anchored.
#define FULLY_WIELDED (1<<17) //If the item is properly wielded. Used for guns
///If a holster has underlay sprites
#define HAS_UNDERLAY (1<<18)
///is this item equipped into an inventory slot or hand of a mob?
#define IN_INVENTORY (1<<19)

//flags_storage
///If a storage container can be restocked into a vendor
#define BYPASS_VENDOR_CHECK (1<<0)

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
#define HIDE_EXCESS_HAIR (1<<11)	//masks hair so it doesn't poke out of the top or front of helmets.


//==========================================================================================

//flags_inventory

//SHOES ONLY===========================================================================================
#define NOSLIPPING (1<<0) 	//prevents from slipping on wet floors, in space etc
//SHOES ONLY===========================================================================================

//HELMET AND MASK======================================================================================
#define COVEREYES (1<<1) // Covers the eyes/protects them.
#define COVERMOUTH (1<<2) // Covers the mouth.
#define BLOCKGASEFFECT (1<<3) // blocks the effect that chemical clouds would have on a mob --glasses, mask and helmets
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
#define ARMOR_FIRE_RESISTANT (1<<5)
//===========================================================================================

//===========================================================================================
//Marine helmet only, use for flags_marine_helmet.
#define HELMET_SQUAD_OVERLAY (1<<0)
#define HELMET_GARB_OVERLAY (1<<1)
#define HELMET_STORE_GARB (1<<2)
#define HELMET_IS_DAMAGED (1<<3)
//===========================================================================================

//ITEM INVENTORY SLOT BITMASKS - These determine to which slot an item can be equipped to
//flags_equip_slot
#define ITEM_SLOT_OCLOTHING (1<<0) //outer clothing, so armor, vests, etc
#define ITEM_SLOT_ICLOTHING (1<<1) //inner clothing, so jumpsuits/uniforms, etc
#define ITEM_SLOT_GLOVES (1<<2) //gloves, any type of gloves
#define ITEM_SLOT_EYES (1<<3) //eyes, any type of eyewear
#define ITEM_SLOT_EARS (1<<4) //ears, any type of earwear (mostly headsets)
#define ITEM_SLOT_MASK (1<<5) //masks, gas masks, rebreathers, coifs etc
#define ITEM_SLOT_HEAD (1<<6) //head slot, so helmets, hats etc
#define ITEM_SLOT_FEET (1<<7) //feet slot, shoes
#define ITEM_SLOT_ID (1<<8) //id, id
#define ITEM_SLOT_BELT (1<<9) //any type of belt
#define ITEM_SLOT_BACK (1<<10) //back slot, so guns, bags etc
#define ITEM_SLOT_R_POCKET (1<<11)	//the right pocket
#define ITEM_SLOT_L_POCKET (1<<12)	//the left pocket
	#define ITEM_SLOT_POCKET (ITEM_SLOT_R_POCKET|ITEM_SLOT_L_POCKET) //a combo of the above
#define ITEM_SLOT_SUITSTORE (1<<13) //the suit storage slot
#define ITEM_SLOT_HANDCUFF (1<<14) //the slot for handcuffs

//=================================================

//Inventory slots - These are mostly used to get items from certain slots
//Text strings so that the slots can be associated when doing inventory lists.
#define SLOT_WEAR_ID 1
#define SLOT_EARS 2
#define SLOT_W_UNIFORM 3
#define SLOT_SHOES 4
#define SLOT_GLOVES 5
#define SLOT_BELT 6
#define SLOT_WEAR_SUIT 7
#define SLOT_GLASSES 8
#define SLOT_WEAR_MASK 9
#define SLOT_HEAD 10
#define SLOT_BACK 11
#define SLOT_L_STORE 12
#define SLOT_R_STORE 13
#define SLOT_ACCESSORY 14
#define SLOT_S_STORE 15
#define SLOT_L_HAND 16
#define SLOT_R_HAND 17
#define SLOT_HANDCUFFED 18
#define SLOT_IN_BOOT 19
#define SLOT_IN_BACKPACK 20
#define SLOT_IN_SUIT 21
#define SLOT_IN_ACCESSORY 23
#define SLOT_IN_HOLSTER 24
#define SLOT_IN_B_HOLSTER 25
#define SLOT_IN_S_HOLSTER 26
#define SLOT_IN_STORAGE 27
#define SLOT_IN_L_POUCH 28
#define SLOT_IN_R_POUCH 29
#define SLOT_IN_HEAD 30
#define SLOT_IN_BELT 31
//=================================================


//Inventory slot strings. These are used for icons. (and checking if an item can be equipped in loadouts for some reason??)
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
		if(SLOT_S_STORE)
			. = ITEM_SLOT_SUITSTORE
		if(SLOT_W_UNIFORM)
			. = ITEM_SLOT_ICLOTHING
		if(SLOT_R_STORE)
			. = ITEM_SLOT_R_POCKET
		if(SLOT_L_STORE)
			. = ITEM_SLOT_L_POCKET

/proc/slotbit2slotdefine(slotbit)
	. = 0
	switch(slotbit)
		if(ITEM_SLOT_OCLOTHING)
			. = SLOT_WEAR_SUIT
		if(ITEM_SLOT_ICLOTHING)
			. = SLOT_W_UNIFORM
		if(ITEM_SLOT_GLOVES)
			. = SLOT_GLOVES
		if(ITEM_SLOT_EYES)
			. = SLOT_GLASSES
		if(ITEM_SLOT_EARS)
			. = SLOT_EARS
		if(ITEM_SLOT_MASK)
			. = SLOT_WEAR_MASK
		if(ITEM_SLOT_HEAD)
			. = SLOT_HEAD
		if(ITEM_SLOT_FEET)
			. = SLOT_SHOES
		if(ITEM_SLOT_ID)
			. = SLOT_WEAR_ID
		if(ITEM_SLOT_BELT)
			. = SLOT_BELT
		if(ITEM_SLOT_BACK)
			. = SLOT_BACK
		if(ITEM_SLOT_R_POCKET)
			. = SLOT_R_STORE
		if(ITEM_SLOT_L_POCKET)
			. = SLOT_L_STORE
		if(ITEM_SLOT_SUITSTORE)
			. = SLOT_S_STORE
		if(ITEM_SLOT_HANDCUFF)
			. = SLOT_HANDCUFFED

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
	SLOT_IN_BOOT,\
	SLOT_IN_L_POUCH,\
	SLOT_IN_R_POUCH,\
	SLOT_IN_HEAD,\
	SLOT_IN_ACCESSORY,\
	SLOT_IN_HOLSTER,\
	SLOT_IN_S_HOLSTER,\
	SLOT_IN_B_HOLSTER,\
	SLOT_BACK,\
	SLOT_S_STORE,\
	SLOT_L_STORE,\
	SLOT_R_STORE,\
	SLOT_IN_STORAGE,\
	SLOT_IN_SUIT,\
	SLOT_IN_BELT,\
	SLOT_IN_BACKPACK\
	)

///Each slot you can draw from, used and messed with in your preferences.
#define SLOT_DRAW_ORDER list(\
	SLOT_IN_HOLSTER,\
	SLOT_IN_S_HOLSTER,\
	SLOT_IN_B_HOLSTER,\
	SLOT_IN_BACKPACK, \
	SLOT_IN_ACCESSORY,\
	SLOT_S_STORE,\
	SLOT_IN_L_POUCH,\
	SLOT_IN_R_POUCH,\
	SLOT_BELT,\
	SLOT_IN_BELT,\
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

/// A list of equip slots that are valid for quick equip preferences
#define VALID_EQUIP_SLOTS list(\
	SLOT_S_STORE,\
	SLOT_WEAR_SUIT,\
	SLOT_BELT,\
	SLOT_BACK,\
	SLOT_IN_BACKPACK,\
	SLOT_IN_BOOT,\
	SLOT_IN_HEAD,\
	SLOT_L_STORE,\
	SLOT_R_STORE,\
	SLOT_IN_ACCESSORY,\
	SLOT_IN_BELT,\
	SLOT_IN_HOLSTER,\
	SLOT_IN_S_HOLSTER,\
	SLOT_IN_B_HOLSTER,\
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
	"Belt Inside",\
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
		if("Backpack")
			return SLOT_IN_BACKPACK
		if("Helmet")
			return SLOT_IN_HEAD
		if("Left Pocket")
			return SLOT_L_STORE
		if("Left Pocket Inside")
			return SLOT_IN_L_POUCH
		if("Right Pocket")
			return SLOT_R_STORE
		if("Right Pocket Inside")
			return SLOT_IN_R_POUCH
		if("Webbing")
			return SLOT_IN_ACCESSORY
		if("Belt Inside")
			return SLOT_IN_BELT
		if("Belt Holster")
			return SLOT_IN_HOLSTER
		if("Suit Storage Holster")
			return SLOT_IN_S_HOLSTER
		if("Back Holster")
			return SLOT_IN_B_HOLSTER
		if("Active Storage")
			return SLOT_IN_STORAGE

/proc/slot_flag_to_fluff(slot)
	switch(slot)
		if(SLOT_S_STORE)
			return "Suit Storage"
		if(SLOT_WEAR_SUIT)
			return "Suit Inside"
		if(SLOT_BELT)
			return "Belt"
		if(SLOT_IN_BELT)
			return "Belt Inside"
		if(SLOT_BACK)
			return "Back"
		if(SLOT_IN_BOOT)
			return "Boot"
		if(SLOT_IN_BACKPACK)
			return "Backpack"
		if(SLOT_IN_HEAD)
			return "Helmet"
		if(SLOT_L_STORE)
			return "Left Pocket"
		if(SLOT_IN_L_POUCH)
			return "Left Pocket Inside"
		if(SLOT_R_STORE)
			return "Right Pocket"
		if(SLOT_IN_R_POUCH)
			return "Right Pocket Inside"
		if(SLOT_IN_ACCESSORY)
			return "Webbing"
		if(SLOT_IN_HOLSTER)
			return "Belt Holster"
		if(SLOT_IN_S_HOLSTER)
			return "Suit Storage Holster"
		if(SLOT_IN_B_HOLSTER)
			return "Back Holster"
		if(SLOT_IN_STORAGE)
			return "Active Storage"

