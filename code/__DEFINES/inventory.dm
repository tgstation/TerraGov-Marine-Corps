/*ALL DEFINES RELATED TO INVENTORY OBJECTS, MANAGEMENT, ETC, GO HERE*/

//ITEM INVENTORY WEIGHT, FOR w_class
#define WEIGHT_CLASS_TINY     1 //Usually items smaller then a human hand, (e.g. playing cards, lighter, scalpel, coins/holochips)
#define WEIGHT_CLASS_SMALL    2 //Pockets can hold small and tiny items, (e.g. flashlight, multitool, grenades, GPS device)
#define WEIGHT_CLASS_NORMAL   3 //Standard backpacks can carry tiny, small & normal items, (e.g. fire extinguisher, stun baton, gas mask, metal sheets)
#define WEIGHT_CLASS_BULKY    4 //Items that can be weilded or equipped but not stored in an inventory, (e.g. defibrillator, backpack, space suits)
#define WEIGHT_CLASS_HUGE     5 //Usually represents objects that require two hands to operate, (e.g. shotgun, two-handed melee weapons)
#define WEIGHT_CLASS_GIGANTIC 6 //Essentially means it cannot be picked up or placed in an inventory, (e.g. mech parts, safe)

//Inventory depth: limits how many nested storage items you can access directly.
//1: stuff in mob, 2: stuff in backpack, 3: stuff in box in backpack, etc
#define INVENTORY_DEPTH		2
#define STORAGE_VIEW_DEPTH	2

//ITEM INVENTORY SLOT BITMASKS

#define ITEM_SLOT_PANTS			(1<<0)
#define ITEM_SLOT_SHIRT			(1<<1)
#define ITEM_SLOT_ARMOR			(1<<2)
#define ITEM_SLOT_SHOES			(1<<3)
#define ITEM_SLOT_GLOVES		(1<<4)
#define ITEM_SLOT_RING			(1<<5)
//#define ITEM_SLOT_MASK			(1<<6) Redefined twice, now we have a nazty azz empty bitflag 6 here cause it was using the def below by default
#define ITEM_SLOT_MOUTH			(1<<7)
#define ITEM_SLOT_HEAD			(1<<8)
#define ITEM_SLOT_CLOAK			(1<<9)
#define ITEM_SLOT_NECK			(1<<10)
#define ITEM_SLOT_MASK			(1<<11)
#define ITEM_SLOT_HANDS			(1<<12)
#define ITEM_SLOT_BELT			(1<<13)
#define ITEM_SLOT_BACK_R		(1<<14)
#define ITEM_SLOT_BACK_L		(1<<15)
#define ITEM_SLOT_INBACK		(1<<16)
#define ITEM_SLOT_HIP			(1<<17)
#define ITEM_SLOT_WRISTS		(1<<18)
#define ITEM_SLOT_OCLOTHING		(1<<19)
#define ITEM_SLOT_ICLOTHING		(1<<20)
#define ITEM_SLOT_POCKET		(1<<21) // this is to allow items with a w_class of WEIGHT_CLASS_NORMAL or WEIGHT_CLASS_BULKY to fit in pockets.
#define ITEM_SLOT_DENYPOCKET	(1<<22) // this is to deny items with a w_class of WEIGHT_CLASS_SMALL or WEIGHT_CLASS_TINY to fit in pockets.
#define ITEM_SLOT_BACKPACK		(1<<23)

#define ITEM_SLOT_BACK			ITEM_SLOT_BACK_L | ITEM_SLOT_BACK_R

//SLOTS

#define SLOT_BACK_L			1
#define SLOT_BACK_R			2
#define SLOT_HANDCUFFED		3
#define SLOT_HANDS			4
#define SLOT_CLOAK			5
#define SLOT_HEAD			6
#define SLOT_MOUTH			7
#define SLOT_WEAR_MASK		8
#define SLOT_NECK			9
#define SLOT_GLOVES			10
#define SLOT_RING			11
#define SLOT_WRISTS			12
#define SLOT_BELT_L			13
#define SLOT_BELT_R			14
#define SLOT_ARMOR			15
#define SLOT_SHIRT			16
#define SLOT_SHOES			17
#define SLOT_PANTS			18
#define SLOT_IN_BACKPACK	19
#define SLOT_LEGCUFFED		20


//old slots
#define SLOT_BACK			21
#define SLOT_BELT			22
#define SLOT_GLASSES		23
#define SLOT_L_STORE		24
#define SLOT_R_STORE		25
#define SLOT_S_STORE		26
#define SLOT_GENERC_DEXTROUS_STORAGE	26

#define SLOTS_AMT			28 // Keep this up to date!


//I hate that this has to exist
/proc/slotdefine2slotbit(slotdefine) //Keep this up to date with the value of SLOT BITMASKS and SLOTS (the two define sections above)
	. = 0
	switch(slotdefine)
		if(SLOT_BACK)
			. = ITEM_SLOT_BACK
		if(SLOT_WEAR_MASK)
			. = ITEM_SLOT_MASK
		if(SLOT_MOUTH)
			. = ITEM_SLOT_MOUTH
		if(SLOT_NECK)
			. = ITEM_SLOT_NECK
		if(SLOT_RING)
			. = ITEM_SLOT_RING
		if(SLOT_WRISTS)
			. = ITEM_SLOT_WRISTS
		if(SLOT_BELT_L)
			. = ITEM_SLOT_HIP
		if(SLOT_BELT_R)
			. = ITEM_SLOT_HIP
		if(SLOT_BELT)
			. = ITEM_SLOT_BELT
		if(SLOT_GLOVES)
			. = ITEM_SLOT_GLOVES
		if(SLOT_HEAD)
			. = ITEM_SLOT_HEAD
		if(SLOT_SHOES)
			. = ITEM_SLOT_SHOES
		if(SLOT_ARMOR)
			. = ITEM_SLOT_ARMOR
		if(SLOT_PANTS)
			. = ITEM_SLOT_PANTS
		if(SLOT_SHIRT)
			. = ITEM_SLOT_SHIRT
		if(SLOT_L_STORE, SLOT_R_STORE)
			. = ITEM_SLOT_POCKET
		if(SLOT_HANDS)
			. = ITEM_SLOT_HANDS
		if(SLOT_IN_BACKPACK)
			. = ITEM_SLOT_INBACK
		if(SLOT_BACK_L)
			. = ITEM_SLOT_BACK_L
		if(SLOT_BACK_R)
			. = ITEM_SLOT_BACK_R
		if(SLOT_CLOAK)
			. = ITEM_SLOT_CLOAK

//Bit flags for the flags_inv variable, which determine when a piece of clothing hides another. IE a helmet hiding glasses.
//Make sure to update check_obscured_slots() if you add more.
#define HIDEGLOVES		(1<<0)
#define HIDESUITSTORAGE	(1<<1)
#define HIDEJUMPSUIT	(1<<2)	//these first four are only used in exterior suits
#define HIDESHOES		(1<<3)
#define HIDEMASK		(1<<4)	//these last six are only used in masks and headgear.
#define HIDEEARS		(1<<5)	// (ears means headsets and such)
#define HIDEEYES		(1<<6)	// Whether eyes and glasses are hidden
#define HIDEFACE		(1<<7)	// Whether we appear as unknown.
#define HIDEHAIR		(1<<8)
#define HIDEFACIALHAIR	(1<<9)
#define HIDENECK		(1<<10)
#define HIDEBOOB		(1<<11)
#define HIDEBELT		(1<<12)

//blocking_behavior var on clothing items
#define BLOCKBOOTS		(1<<0)
#define BLOCKGLOVES		(1<<1)
#define BLOCKWRISTS		(1<<2)
#define BLOCKARMOR		(1<<3)
#define BLOCKSHIRT		(1<<4)
#define BLOCKPANTS		(1<<5)
#define BLOCKCLOAK		(1<<6)
#define BULKYBLOCKS		(1<<7)

//bitflags for clothing coverage - also used for limbs
#define HEAD		(1<<0)
#define CHEST		(1<<1)
#define GROIN		(1<<2)
#define LEG_LEFT	(1<<3)
#define LEG_RIGHT	(1<<4)
#define LEGS		(LEG_LEFT | LEG_RIGHT)
#define FOOT_LEFT	(1<<5)
#define FOOT_RIGHT	(1<<6)
#define FEET		(FOOT_LEFT | FOOT_RIGHT)
#define ARM_LEFT	(1<<7)
#define ARM_RIGHT	(1<<8)
#define ARMS		(ARM_LEFT | ARM_RIGHT)
#define HAND_LEFT	(1<<9)
#define HAND_RIGHT	(1<<10)
#define HANDS		(HAND_LEFT | HAND_RIGHT)
#define NECK		(1<<11)
#define VITALS		(1<<13)
#define MOUTH		(1<<14)
#define EARS		(1<<15)
#define NOSE		(1<<16)
#define RIGHT_EYE	(1<<17)
#define LEFT_EYE	(1<<18)
#define HAIR		(1<<19) 
#define EYES		(LEFT_EYE | RIGHT_EYE)
#define FACE		(MOUTH | NOSE | EYES)
#define FULL_HEAD	(HEAD | MOUTH | NOSE | EYES | EARS | HAIR)
#define BELOW_HEAD	(CHEST | GROIN | VITALS | ARMS | HANDS | LEGS | FEET)
#define BELOW_CHEST	(GROIN | VITALS | LEGS | FEET) //for water
#define FULL_BODY	(FULL_HEAD | NECK | BELOW_HEAD)

//defines for the index of hands
#define LEFT_HANDS 1
#define RIGHT_HANDS 2

/// sleeve flags
#define SLEEVE_NORMAL 0
#define SLEEVE_TORN 1
#define SLEEVE_ROLLED 2
#define SLEEVE_NOMOD 3

//flags for female outfits: How much the game can safely "take off" the uniform without it looking weird
#define NO_FEMALE_UNIFORM			0
#define FEMALE_UNIFORM_FULL			1
#define FEMALE_UNIFORM_TOP			2

//flags for alternate styles: These are hard sprited so don't set this if you didn't put the effort in
#define NORMAL_STYLE		0
#define ALT_STYLE			1
#define DIGITIGRADE_STYLE 	2

//flags for outfits that have mutantrace variants (try not to use this): Currently only needed if you're trying to add tight fitting bootyshorts
#define NO_MUTANTRACE_VARIATION		0
#define MUTANTRACE_VARIATION		1

#define NOT_DIGITIGRADE				0
#define FULL_DIGITIGRADE			1
#define SQUISHED_DIGITIGRADE		2

//flags for covering body parts
#define GLASSESCOVERSEYES	(1<<0)
#define MASKCOVERSEYES		(1<<1)		// get rid of some of the other retardation in these flags
#define HEADCOVERSEYES		(1<<2)		// feel free to realloc these numbers for other purposes
#define MASKCOVERSMOUTH		(1<<3)		// on other items, these are just for mask/head
#define HEADCOVERSMOUTH		(1<<4)
#define PEPPERPROOF			(1<<5)	//protects against pepperspray

#define TINT_DARKENED 2			//Threshold of tint level to apply weld mask overlay
#define TINT_BLIND 3			//Threshold of tint level to obscure vision fully

#define CANT_CADJUST 0
#define CAN_CADJUST 1
#define CADJUSTED 2

//Allowed equipment lists for security vests and hardsuits.

GLOBAL_LIST_INIT(advanced_hardsuit_allowed, typecacheof(list(
	/obj/item/ammo_box,
	/obj/item/ammo_casing,
	/obj/item/flashlight,
	/obj/item/gun,
	/obj/item/melee/baton,
	/obj/item/reagent_containers/spray/pepper,
	/obj/item/restraints/handcuffs,
	/obj/item/tank/internals)))

GLOBAL_LIST_INIT(security_hardsuit_allowed, typecacheof(list(
	/obj/item/ammo_box,
	/obj/item/ammo_casing,
	/obj/item/flashlight,
	/obj/item/gun/ballistic,
	/obj/item/gun/energy,
	/obj/item/melee/baton,
	/obj/item/reagent_containers/spray/pepper,
	/obj/item/restraints/handcuffs,
	/obj/item/tank/internals)))

GLOBAL_LIST_INIT(detective_vest_allowed, typecacheof(list(
	/obj/item/ammo_box,
	/obj/item/ammo_casing,
	/obj/item/detective_scanner,
	/obj/item/flashlight,
	/obj/item/taperecorder,
	/obj/item/gun/ballistic,
	/obj/item/gun/energy,
	/obj/item/lighter,
	/obj/item/melee/baton,
	/obj/item/melee/classic_baton,
	/obj/item/reagent_containers/spray/pepper,
	/obj/item/restraints/handcuffs,
	/obj/item/storage/fancy/cigarettes,
	/obj/item/tank/internals/emergency_oxygen,
	/obj/item/tank/internals/plasmaman)))

GLOBAL_LIST_INIT(security_vest_allowed, typecacheof(list(
	/obj/item/ammo_box,
	/obj/item/ammo_casing,
	/obj/item/flashlight,
	/obj/item/gun/ballistic,
	/obj/item/gun/energy,
	/obj/item/kitchen/knife/combat,
	/obj/item/melee/baton,
	/obj/item/melee/classic_baton/telescopic,
	/obj/item/reagent_containers/spray/pepper,
	/obj/item/restraints/handcuffs,
	/obj/item/tank/internals/emergency_oxygen,
	/obj/item/tank/internals/plasmaman)))

GLOBAL_LIST_INIT(security_wintercoat_allowed, typecacheof(list(
	/obj/item/ammo_box,
	/obj/item/ammo_casing,
	/obj/item/flashlight,
	/obj/item/storage/fancy/cigarettes,
	/obj/item/gun/ballistic,
	/obj/item/gun/energy,
	/obj/item/lighter,
	/obj/item/melee/baton,
	/obj/item/melee/classic_baton/telescopic,
	/obj/item/reagent_containers/spray/pepper,
	/obj/item/restraints/handcuffs,
	/obj/item/tank/internals/emergency_oxygen,
	/obj/item/tank/internals/plasmaman,
	/obj/item/toy)))
