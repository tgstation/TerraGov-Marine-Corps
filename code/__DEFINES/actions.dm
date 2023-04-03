#define XACT_USE_INCAP (1 << 0) // ignore incapacitated
#define XACT_USE_LYING (1 << 1) // ignore lying down
#define XACT_USE_BUCKLED (1 << 2) // ignore buckled
#define XACT_USE_STAGGERED (1 << 3) // ignore staggered
#define XACT_USE_FORTIFIED (1 << 4) // ignore fortified
#define XACT_USE_CRESTED (1 << 5) // ignore being in crest defense
#define XACT_USE_NOTTURF (1 << 6) // ignore not being on a turf (like in a vent)
#define XACT_USE_BUSY (1 << 7) // ignore being in a do_after or similar
#define XACT_USE_AGILITY (1 << 8) // ignore agility mode
#define XACT_TARGET_SELF (1 << 9) // allow self-targetting
#define XACT_IGNORE_PLASMA (1 << 10) // ignore plasma cost
#define XACT_USE_CLOSEDTURF (1 << 11) // can be used while being on a closed turf.
#define XACT_IGNORE_COOLDOWN (1 << 12) // ignore cooldown
#define XACT_IGNORE_DEAD_TARGET (1 << 13) // bypass checks of a dead target
#define XACT_IGNORE_SELECTED_ABILITY (1 << 14) // bypass the check of the selected ability
#define XACT_DO_AFTER_ATTACK (1 << 15) //Let the xeno attack the object and perform the ability.
#define XACT_USE_BURROWED (1 << 16) // ignore being burrowed

#define XABB_TURF_TARGET (1 << 0) // ability targets turfs
#define XABB_MOB_TARGET (1 << 1) // ability targets mobs

#define XACT_KEYBIND_USE_ABILITY (1 << 0) // immediately activate even if selectable


#define ABILITY_CRASH (1<<0)
#define ABILITY_DISTRESS (1<<1)
#define ABILITY_ALL_GAMEMODE (ABILITY_CRASH|ABILITY_DISTRESS)
