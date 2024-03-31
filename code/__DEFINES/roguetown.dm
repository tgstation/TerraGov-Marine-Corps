//used in various places
#define ALL_RACES_LIST		list("human", "dwarf", "elf", "tiefling", "aasimar")

#define ALL_RACES_LIST_NAMES		list("Humen", "Humen", "Half-Elf", "Elf", "Elf", "Dwarf","Dwarf","Tiefling", "Aasimar")

#define ALL_PATRON_NAMES_LIST		list("Astrata", "Noc", "Xylix", "Eora", "Malum", "Dendor", "Abyssor", "Necra", "Pestra", "Malum", "Ravox")

#define PLATEHIT "plate"
#define CHAINHIT "chain"
#define SOFTHIT "soft"

/proc/get_armor_sound(blocksound, blade_dulling)
	switch(blocksound)
		if(PLATEHIT)
			if(blade_dulling == BCLASS_CUT||blade_dulling == BCLASS_CHOP)
				return pick('sound/combat/hits/armor/plate_slashed (1).ogg','sound/combat/hits/armor/plate_slashed (2).ogg','sound/combat/hits/armor/plate_slashed (3).ogg','sound/combat/hits/armor/plate_slashed (4).ogg')
			if(blade_dulling == BCLASS_STAB||blade_dulling == BCLASS_PICK||blade_dulling == BCLASS_BITE)
				return pick('sound/combat/hits/armor/plate_stabbed (1).ogg','sound/combat/hits/armor/plate_stabbed (2).ogg','sound/combat/hits/armor/plate_stabbed (3).ogg')
			else
				return pick('sound/combat/hits/armor/plate_blunt (1).ogg','sound/combat/hits/armor/plate_blunt (2).ogg','sound/combat/hits/armor/plate_blunt (3).ogg')
		if(CHAINHIT)
			if(blade_dulling == BCLASS_BITE||blade_dulling == BCLASS_STAB||blade_dulling == BCLASS_PICK||blade_dulling == BCLASS_CUT||blade_dulling == BCLASS_CHOP)
				return pick('sound/combat/hits/armor/chain_slashed (1).ogg','sound/combat/hits/armor/chain_slashed (2).ogg','sound/combat/hits/armor/chain_slashed (3).ogg','sound/combat/hits/armor/chain_slashed (4).ogg')
			else
				return pick('sound/combat/hits/armor/chain_blunt (1).ogg','sound/combat/hits/armor/chain_blunt (2).ogg','sound/combat/hits/armor/chain_blunt (3).ogg')
		if(SOFTHIT)
			if(blade_dulling == BCLASS_BITE||blade_dulling == BCLASS_STAB||blade_dulling == BCLASS_PICK||blade_dulling == BCLASS_CUT||blade_dulling == BCLASS_CHOP)
				return pick('sound/combat/hits/armor/light_stabbed (1).ogg','sound/combat/hits/armor/light_stabbed (2).ogg','sound/combat/hits/armor/light_stabbed (3).ogg')
			else
				return pick('sound/combat/hits/armor/light_blunt (1).ogg','sound/combat/hits/armor/light_blunt (2).ogg','sound/combat/hits/armor/light_blunt (3).ogg')

#define BCLASS_BLUNT		"blunt"
#define BCLASS_SMASH		"smashing"
#define BCLASS_CUT			"slashing"
#define BCLASS_CHOP			"chopping"
#define BCLASS_STAB			"stabbing"
#define BCLASS_PICK			"piercing"
#define BCLASS_TWIST		"twist"
#define BCLASS_PUNCH		"punch"
#define BCLASS_BITE			"bite"

GLOBAL_LIST_INIT(lockhashes, list())
GLOBAL_LIST_INIT(lockids, list())
GLOBAL_LIST_EMPTY(credits_icons)
GLOBAL_LIST_EMPTY(confessors)

GLOBAL_LIST_INIT(wolf_prefixes, list("Red", "Moon", "Bloody", "Hairy", "Eager", "Sharp"))
GLOBAL_LIST_INIT(wolf_suffixes, list("Fang", "Claw", "Stalker", "Prowler", "Roar", "Ripper"))

//preference stuff
#define FAMILY_NONE 1
#define FAMILY_PARTIAL 2
#define FAMILY_FULL 3

#define FAITH_NONE 0
#define FAITH_PSYDON 1
#define FAITH_ELF 2
#define FAITH_DWARF 3
#define FAITH_SPIDER 4
#define FAITH_ZIZO 5

/proc/get_faith_name(faith)
	switch(faith)
		if(FAITH_PSYDON)
			return "Father-Son"
		if(FAITH_ELF)
			return "Elfish Pantheon"
		if(FAITH_DWARF)
			return "Dwarfish Paganism"
		if(FAITH_SPIDER)
			return "Spider Queen"
		if(FAITH_ZIZO)
			return "Zizo"

/proc/get_faith_desc(faith)
	switch(faith)
		if(FAITH_PSYDON)
			return "You believe in the Father-Son. Only through His sun SAVIOR PSYDON may you join His golden kingdom in death."
		if(FAITH_ELF)
			return "You believe in the FAERIE PANTHEON, may Brother Courage and Sister Pride protect you from the wrath of the Trickster."
		if(FAITH_DWARF)
			return "By rock, you believe in DWARFISH PAGANISM! Only by respecting the gods of soil and water may you survive this week."
		if(FAITH_SPIDER)
			return "You pledged your faith in the SPIDER QUEEN, a godlike creature who ruled the Under-World before her untimely death."
		if(FAITH_ZIZO)
			return "You are a disgusting slave of ZIZO! Let the scum of creation die in obscene ways as your beautiful evil turns the world dark and miserable."


GLOBAL_LIST_EMPTY(sunlights)
