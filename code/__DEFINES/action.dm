/*!
 * This is just a file holding string defines for reference retrieval on /action datums
 * ideally you should never override the base list , and just add onto its length
 * The noting system for these is
 * VREF_[DATA_TYPE]_[WHAT_IS_IT_USED_FOR]
 */

// Base /datum/action visual references. All subdatums should have these
/// A define for accesing the mutable appearance of the linked obj. Holds a reference of the objects appearance
#define VREF_MUTABLE_LINKED_OBJ "VREF_LINKED_OBJ"
/// A mutable appearance of icon made with action_icon_state and action_icon
#define VREF_MUTABLE_ACTION_STATE "VREF_ACTION_STATE"
#define VREF_MUTABLE_ACTIVE_FRAME "VREF_ACTIVE_FRAME"
/// A mutable appearance for keybinding maptext
#define VREF_MUTABLE_MAPTEXT "VREF_BIND_TEXT"
/// A mutable appearance to add a "selected" frame around the edges
#define VREF_MUTABLE_SELECTED_FRAME "VREF_SELECTED_FRAME"
/// A misc image holder for stuff thats meant to be added ontop , used by a few actions
#define VREF_IMAGE_ONTOP "VREF_LAYERED_IMAGE"
// /datum/action/ability/xeno_action. Additional references
/// A mutable appearance to add the "empowered" frame around the edges
#define VREF_MUTABLE_EMPOWERED_FRAME "VREF_EMPOWERED_FRAME"
/// A reference for the build counter of a xeno
#define VREF_MUTABLE_BUILDING_COUNTER "VREF_BUILD_COUNTER"
//A reference for the special resin build counter of a xeno
#define VREF_MUTABLE_SPECIAL_RESIN_COUNTER "VREF_SPECIAL_RESIN_COUNTER"
// extra reference for the amount of landslide charges we have
#define VREF_MUTABLE_LANDSLIDE "VREF_LANDSLIDE"
// extra reference for the amount of earth pillars we have
#define VREF_MUTABLE_EARTH_PILLAR "VREF_EARTH_PILLAR"
// extra reference for savage's cooldown
#define VREF_MUTABLE_SAVAGE_COOLDOWN "VREF_SAVAGE_COOLDOWN"
// extra define for jab charges
#define VREF_MUTABLE_JAB "VREF_JAB"
// extra reference for how many boiler neuro globs we have
#define VREF_MUTABLE_NEUROGLOB_COUNTER "VREF_NEUROGLOB_COUNTER"
// extra reference for how many boiler acid globs we have
#define VREF_MUTABLE_CORROSIVEGLOB_COUNTER "VREF_CORROSIVEGLOB_COUNTER"
// extra reference for how many boiler acid globs we have
#define VREF_MUTABLE_AMMO_COUNTER "VREF_AMMO_COUNTER"
// extra reference for how many globadier acid mines we have
#define VREF_MUTABLE_ACID_MINES_COUNTER "VREF_ACIDMINE_COUNTER"
// extra reference for how many globadier grenades we have
#define VREF_MUTABLE_GLOB_GRENADES_COUNTER "VREF_GLOBGRENADE_COUNTER"
// extra reference for how many globadier gas mines we have
#define VREF_MUTABLE_GAS_MINES_COUNTER "VREF_GASMINE_COUNTER"
// extra reference for how long untill we recharge a new globadier grenade
#define VREF_MUTABLE_GLOB_GRENADES_CHARGETIMER "VREF_GLOBGRENADE_CHARGETIMER"
// extra reference for how long untill we recharge a new acid mine
#define VREF_MUTABLE_GAS_MINE_TIMER "VREF_GASMINE_CHARGETIMER"
// extra reference for how long untill we recharge a new gas mine
#define VREF_MUTABLE_ACID_MINE_TIMER "VREF_ACIDMINE_CHARGETIMER"
// The extra reference for Conqueror's Dash ability if it uses the charge cooldown system. Shows how many charges are available.
#define VREF_MUTABLE_CONQ_DASH_CHARGES "VREF_CONQDASH_CHARGES"
// The extra reference for Conqueror's Dash ability if it uses the charge cooldown system. Shows how much time is left before a charge is restored.
#define VREF_MUTABLE_CONQ_DASH_CHARGETIMER "VREF_CONQDASH_CHARGETIMER"

/// Actions that toggle on click/trigger
#define ACTION_TOGGLE "toggle"
/// Actions that trigger when clicked/triggered
#define ACTION_CLICK "click"
/// Actions that get selected and can be targeted when clicked/triggered
#define ACTION_SELECT "select"

/// Normal keybinding , calls keybind_activation
#define KEYBINDING_NORMAL "normal_trigger"
/// Alternate keybinding , calls alternate_ability_activation
#define KEYBINDING_ALTERNATE "alternate_trigger"

/* Defines for layering action overlays
Numbers closer to 0 get drawn above everything thats smaller
*/

#define ACTION_LAYER_MAPTEXT FLOAT_LAYER // Maptext only
#define ACTION_LAYER_CLOCK FLOAT_LAYER - 0.1 // Clock only
#define ACTION_LAYER_SELECTED FLOAT_LAYER - 0.2 // Selected frame only
#define ACTION_LAYER_EMPOWERED FLOAT_LAYER - 0.3 // Empowered frame only
#define ACTION_LAYER_IMAGE_ONTOP FLOAT_LAYER - 0.4 // LINKED_OBJ , IMAGE_ONTOP, RAV_LEECH
#define ACTION_LAYER_ACTION_ICON_STATE FLOAT_LAYER - 1 // Action icon frame only
