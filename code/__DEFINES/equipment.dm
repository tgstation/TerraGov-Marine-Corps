//PASS FLAGS
#define PASSTABLE	(1<<0)
#define PASSGLASS	(1<<1)
#define PASSGRILLE	(1<<2)
#define PASSBLOB	(1<<3)
#define PASSMOB		(1<<4)

//==========================================================================================

//flags_atom

#define NOINTERACT				(1<<0)		// You can't interact with it, at all. Useful when doing certain animations.
#define CONDUCT					(1<<1)		// conducts electricity (metal etc.)
#define ON_BORDER				(1<<2)		// 'border object'. item has priority to check when entering or leaving
#define NOBLOODY				(1<<3)		// Don't want a blood overlay on this one.
#define DIRLOCK					(1<<4)		// movable atom won't change direction when Moving()ing. Useful for items that have several dir states.
#define INITIALIZED				(1<<5)  	//Whether /atom/Initialize() has already run for the object
#define NODECONSTRUCT			(1<<6)
#define OVERLAY_QUEUED			(1<<7)

//==========================================================================================

//flags_barrier
#define HANDLE_BARRIER_CHANCE 1
#define HANDLE_BARRIER_BLOCK 2


//bitflags that were previously under flags_atom, these only apply to items.
//clothing specific stuff uses flags_inventory.
//flags_item
#define NODROP					(1<<0)	// Cannot be dropped/unequipped at all, only deleted.
#define NOBLUDGEON  			(1<<1)	// when an item has this it produces no "X has been hit by Y with Z" message with the default handler
#define NOSHIELD				(1<<2)	// weapon not affected by shield (does nothing currently)
#define DELONDROP				(1<<3)	// Deletes on drop instead of falling on the floor.
#define TWOHANDED				(1<<4)	// The item is twohanded.
#define WIELDED					(1<<5)	// The item is wielded with both hands.
#define	ITEM_ABSTRACT			(1<<6)	//The item is abstract (grab, powerloader_clamp, etc)

//==========================================================================================


//flags_inv_hide
//Bit flags for the flags_inv_hide variable, which determine when a piece of clothing hides another. IE a helmet hiding glasses.

#define HIDEGLOVES		(1<<0)
#define HIDESUITSTORAGE	(1<<1)
#define HIDEJUMPSUIT	(1<<2)
#define HIDESHOES		(1<<3)
#define HIDEMASK		(1<<4)
#define HIDEEARS		(1<<5)		//(ears means headsets and such)
#define HIDEEYES		(1<<6)		//(eyes means glasses)
#define HIDELOWHAIR		(1<<7)		// temporarily removes the user's facial hair overlay.
#define HIDETOPHAIR		(1<<8)		// temporarily removes the user's hair overlay. Leaves facial hair.
#define HIDEALLHAIR		(1<<9)		// temporarily removes the user's hair, facial and otherwise.
#define HIDETAIL 		(1<<10)
#define HIDEFACE		(1<<11)	//Dictates whether we appear as unknown.


//==========================================================================================

//flags_inventory

//SHOES ONLY===========================================================================================
#define NOSLIPPING		(1<<0) 	//prevents from slipping on wet floors, in space etc
//SHOES ONLY===========================================================================================

//HELMET AND MASK======================================================================================
#define COVEREYES		(1<<1) // Covers the eyes/protects them.
#define COVERMOUTH		(1<<2) // Covers the mouth.
#define ALLOWINTERNALS	(1<<3)	//mask allows internals
#define ALLOWREBREATH	(1<<4) //Mask allows to breath in really hot or really cold air.
#define BLOCKGASEFFECT	(1<<5) // blocks the effect that chemical clouds would have on a mob --glasses, mask and helmets
//HELMET AND MASK======================================================================================

//SUITS AND HELMETS====================================================================================
//To successfully stop taking all pressure damage you must have both a suit and head item with this flag.
#define BLOCKSHARPOBJ 	(1<<6)  //From /tg: prevents syringes, parapens and hypos if the external suit or helmet (if targeting head) has this flag. Example: space suits, biosuit, bombsuits, thick suits that cover your body.
#define NOPRESSUREDMAGE (1<<7) //This flag is used on the flags variable for SUIT and HEAD items which stop pressure damage.
//SUITS AND HELMETS====================================================================================

//vision obscuring facegear and etc.
#define TINT_NONE 0
#define TINT_MILD 1
#define TINT_HEAVY 2
#define TINT_BLIND 3

//Inventory depth: limits how many nested storage items you can access directly.
//1: stuff in mob, 2: stuff in backpack, 3: stuff in box in backpack, etc
#define INVENTORY_DEPTH		4
#define STORAGE_VIEW_DEPTH	3


//===========================================================================================
//Marine armor only, use for flags_marine_armor.
#define ARMOR_SQUAD_OVERLAY		(1<<0)
#define ARMOR_LAMP_OVERLAY		(1<<1)
#define ARMOR_LAMP_ON			(1<<2)
#define ARMOR_IS_REINFORCED		(1<<3)
//===========================================================================================

//===========================================================================================
//Marine helmet only, use for flags_marine_helmet.
#define HELMET_SQUAD_OVERLAY	(1<<0)
#define HELMET_GARB_OVERLAY		(1<<1)
#define HELMET_DAMAGE_OVERLAY	(1<<2)
#define HELMET_STORE_GARB		(1<<3)
#define HELMET_IS_DAMAGED		(1<<4)
//===========================================================================================

//ITEM INVENTORY SLOT BITMASKS
//flags_equip_slot
#define ITEM_SLOT_OCLOTHING 	(1<<0)
#define ITEM_SLOT_ICLOTHING 	(1<<1)
#define ITEM_SLOT_GLOVES 		(1<<2)
#define ITEM_SLOT_EYES 			(1<<3)
#define ITEM_SLOT_EARS 			(1<<4)
#define ITEM_SLOT_MASK 			(1<<5)
#define ITEM_SLOT_HEAD 			(1<<6)
#define ITEM_SLOT_FEET 			(1<<7)
#define ITEM_SLOT_ID 			(1<<8)
#define ITEM_SLOT_BELT			(1<<9)
#define ITEM_SLOT_BACK 			(1<<10)
#define ITEM_SLOT_POCKET 		(1<<11)	//this is to allow items with a w_class of 3 or 4 to fit in pockets.
#define ITEM_SLOT_DENYPOCKET	(1<<12)	//this is to deny items with a w_class of 2 or 1 to fit in pockets.
#define ITEM_SLOT_LEGS 			(1<<13)
//=================================================

//slots
//Text strings so that the slots can be associated when doing inventory lists.
#define SLOT_WEAR_ID		1
#define SLOT_EARS			2
#define SLOT_W_UNIFORM		3
#define SLOT_LEGS			4
#define SLOT_SHOES			5
#define SLOT_GLOVES			6
#define SLOT_BELT			7
#define SLOT_WEAR_SUIT		8
#define SLOT_GLASSES		9
#define SLOT_WEAR_MASK		10
#define SLOT_HEAD			11
#define SLOT_BACK			12
#define SLOT_L_STORE		13
#define SLOT_R_STORE		14
#define SLOT_ACCESSORY		15
#define SLOT_S_STORE		16
#define SLOT_L_HAND			17
#define SLOT_R_HAND			18
#define SLOT_HANDCUFFED		19
#define SLOT_LEGCUFFED		20
#define SLOT_IN_BOOT		21
#define SLOT_IN_BACKPACK	22
#define SLOT_IN_SUIT		23
#define SLOT_IN_ACCESSORY	24
#define SLOT_IN_HOLSTER		25
#define SLOT_IN_B_HOLSTER	26
#define SLOT_IN_S_HOLSTER	27
#define SLOT_IN_STORAGE		28
#define SLOT_IN_L_POUCH		29
#define SLOT_IN_R_POUCH		30
#define SLOT_IN_HEAD		31
#define SLOT_IN_BELT		32
//=================================================

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
#define HEAD			(1<<0)
#define FACE			(1<<1)
#define EYES			(1<<2)
#define CHEST			(1<<3)
#define GROIN			(1<<4)
#define LEG_LEFT		(1<<5)
#define LEG_RIGHT		(1<<6)
#define LEGS			(LEG_RIGHT|LEG_LEFT)
#define FOOT_LEFT		(1<<7)
#define FOOT_RIGHT		(1<<8)
#define FEET			(FOOT_RIGHT|FOOT_LEFT)
#define ARM_LEFT		(1<<9)
#define ARM_RIGHT		(1<<10)
#define ARMS			(ARM_RIGHT|ARM_LEFT)
#define HAND_LEFT		(1<<11)
#define HAND_RIGHT		(1<<12)
#define HANDS			(HAND_RIGHT|HAND_LEFT)
#define FULL_BODY		(~0)
//=================================================

//defense zones for selecting them via the hud.
#define DEFENSE_ZONES_LIVING list("head","chest","mouth","eyes","groin","l_leg","l_foot","r_leg","r_foot","l_arm","l_hand","r_arm","r_hand")

// bitflags for the percentual amount of protection a piece of clothing which covers the body part offers.
// Used with human/proc/get_flags_heat_protection() and human/proc/get_flags_cold_protection()
// The values here should add up to 1.
// Hands and feet have 2.5%, arms and legs 7.5%, each of the torso parts has 15% and the head has 30%
#define THERMAL_PROTECTION_HEAD			0.3
#define THERMAL_PROTECTION_UPPER_TORSO	0.15
#define THERMAL_PROTECTION_LOWER_TORSO	0.15
#define THERMAL_PROTECTION_LEG_LEFT		0.075
#define THERMAL_PROTECTION_LEG_RIGHT	0.075
#define THERMAL_PROTECTION_FOOT_LEFT	0.025
#define THERMAL_PROTECTION_FOOT_RIGHT	0.025
#define THERMAL_PROTECTION_ARM_LEFT		0.075
#define THERMAL_PROTECTION_ARM_RIGHT	0.075
#define THERMAL_PROTECTION_HAND_LEFT	0.025
#define THERMAL_PROTECTION_HAND_RIGHT	0.025
//=================================================

//=================================================
#define SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE 	2.0 //what min_cold_protection_temperature is set to for space-helmet quality headwear. MUST NOT BE 0.
#define SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE 		2.0 //what min_cold_protection_temperature is set to for space-suit quality jumpsuits or suits. MUST NOT BE 0.
#define SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE 		5000	//These need better heat protect, but not as good heat protect as firesuits.
#define FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE 		30000 //what max_heat_protection_temperature is set to for firesuit quality headwear. MUST NOT BE 0.
#define FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE 	30000 //for fire helmet quality items (red and white hardhats)
#define HELMET_MIN_COLD_PROTECTION_TEMPERATURE 			200	//For normal helmets
#define HELMET_MAX_HEAT_PROTECTION_TEMPERATURE 			600	//For normal helmets
#define ARMOR_MIN_COLD_PROTECTION_TEMPERATURE 			200	//For armor
#define ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE 			600	//For armor

#define GLOVES_MIN_COLD_PROTECTION_TEMPERATURE 			200	//For some gloves (black and)
#define GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE 			650	//For some gloves
#define SHOE_MIN_COLD_PROTECTION_TEMPERATURE 			200	//For gloves
#define SHOE_MAX_HEAT_PROTECTION_TEMPERATURE 			650	//For gloves

#define ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE 		200 //For the ice planet map protection from the elements.
//=================================================

//ITEM INVENTORY WEIGHT, FOR w_class
#define WEIGHT_CLASS_TINY     1 //Usually items smaller then a human hand, ex: Playing Cards, Lighter, Scalpel, Coins/Money
#define WEIGHT_CLASS_SMALL    2 //Pockets can hold small and tiny items, ex: Flashlight, Multitool, Grenades, GPS Device
#define WEIGHT_CLASS_NORMAL   3 //Standard backpacks can carry tiny, small & normal items, ex: Fire extinguisher, Stunbaton, Gas Mask, Metal Sheets
#define WEIGHT_CLASS_BULKY    4 //Items that can be weilded or equipped but not stored in an inventory, ex: Defibrillator, Backpack, Space Suits
#define WEIGHT_CLASS_HUGE     5 //Usually represents objects that require two hands to operate, ex: Shotgun, Two Handed Melee Weapons
#define WEIGHT_CLASS_GIGANTIC 6 //Essentially means it cannot be picked up or placed in an inventory, ex: Mech Parts, Safe

#define SLOT_EQUIP_ORDER list(\
	SLOT_IN_HOLSTER,\
	SLOT_IN_S_HOLSTER,\
	SLOT_IN_B_HOLSTER,\
	SLOT_BACK,\
	SLOT_WEAR_ID,\
	SLOT_GLASSES,\
	SLOT_IN_HEAD,\
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
	SLOT_IN_BOOT,\
	SLOT_IN_STORAGE,\
	SLOT_IN_L_POUCH,\
	SLOT_IN_R_POUCH,\
	SLOT_IN_ACCESSORY,\
	SLOT_IN_SUIT,\
	SLOT_IN_BACKPACK,\
	SLOT_IN_BELT\
	)

#define SLOT_DRAW_ORDER list(\
	SLOT_IN_HOLSTER,\
	SLOT_IN_S_HOLSTER,\
	SLOT_IN_B_HOLSTER,\
	SLOT_BACK,\
	SLOT_BELT,\
	SLOT_S_STORE,\
	SLOT_L_STORE,\
	SLOT_R_STORE,\
	SLOT_IN_BOOT,\
	SLOT_WEAR_SUIT,\
	SLOT_IN_ACCESSORY,\
	SLOT_IN_STORAGE,\
	SLOT_IN_BELT,\
	SLOT_IN_HEAD\
	)
