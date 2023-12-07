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
/// A image to show the clock delay ticking.
#define VREF_IMAGE_XENO_CLOCK "VREF_ACTION_CLOCK"
/// A reference for baneling's respawn charges
#define VREF_MUTABLE_BANE_CHARGES "VREF_BANE_CHARGES"
/// A reference for the build counter of a xeno
#define VREF_MUTABLE_BUILDING_COUNTER "VREF_BUILD_COUNTER"
// extra reference for the amount of landslide charges we have
#define VREF_MUTABLE_LANDSLIDE "VREF_LANDSLIDE"
// extra reference for the amount of earth pillars we have
#define VREF_MUTABLE_EARTH_PILLAR "VREF_EARTH_PILLAR"
// extra reference for savage's cooldown
#define VREF_MUTABLE_SAVAGE_COOLDOWN "VREF_SAVAGE_COOLDOWN"


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
