#define ABILITY_USE_INCAP (1 << 0) // ignore incapacitated
#define ABILITY_USE_LYING (1 << 1) // ignore lying down
#define ABILITY_USE_BUCKLED (1 << 2) // ignore buckled
#define ABILITY_USE_STAGGERED (1 << 3) // ignore staggered
#define ABILITY_USE_FORTIFIED (1 << 4) // ignore fortified
#define ABILITY_USE_CRESTED (1 << 5) // ignore being in crest defense
#define ABILITY_USE_NOTTURF (1 << 6) // ignore not being on a turf (like in a vent)
#define ABILITY_USE_BUSY (1 << 7) // ignore being in a do_after or similar
#define ABILITY_USE_AGILITY (1 << 8) // ignore agility mode
#define ABILITY_TARGET_SELF (1 << 9) // allow self-targetting
#define ABILITY_IGNORE_PLASMA (1 << 10) // ignore plasma cost
#define ABILITY_USE_CLOSEDTURF (1 << 11) // can be used while being on a closed turf.
#define ABILITY_IGNORE_COOLDOWN (1 << 12) // ignore cooldown
#define ABILITY_IGNORE_DEAD_TARGET (1 << 13) // bypass checks of a dead target
#define ABILITY_IGNORE_SELECTED_ABILITY (1 << 14) // bypass the check of the selected ability
#define ABILITY_DO_AFTER_ATTACK (1 << 15) //Let the xeno attack the object and perform the ability.
#define ABILITY_USE_BURROWED (1 << 16) // ignore being burrowed
#define ABILITY_USE_ROOTED (1 << 17) // ignore being currently rooted

#define ABILITY_TURF_TARGET (1 << 0) // ability targets turfs
#define ABILITY_MOB_TARGET (1 << 1) // ability targets mobs

#define ABILITY_KEYBIND_USE_ABILITY (1 << 0) // immediately activate even if selectable


#define ABILITY_CRASH (1<<0)
#define ABILITY_NUCLEARWAR (1<<1)
#define ABILITY_ALL_GAMEMODE (ABILITY_CRASH|ABILITY_NUCLEARWAR)

#define PSIONIC_INTERACTION_STRENGTH_WEAK 1
#define PSIONIC_INTERACTION_STRENGTH_STANDARD 2
#define PSIONIC_INTERACTION_STRENGTH_STRONG 3
