/*!
 * This is just a file holding numerical defines for reference retrieval on /action datums
 * ideally you should never override the base list , and just add onto its length
 * The noting system for these is
 * VREF_[DATA_TYPE]_[WHAT_IS_IT_USED_FOR]
 */

// Base /datum/action visual references. All subdatums should have these
/// A define for accesing the mutable appearance of the linked obj. Holds a reference of the objects appearance
#define VREF_MUTABLE_LINKED_OBJ 1
/// A mutable appearance of icon made with action_icon_state and action_icon
#define VREF_MUTABLE_ACTION_STATE 2
/// A mutable appearance for keybinding maptext
#define VREF_MUTABLE_MAPTEXT 3
/// A mutable appearance to add a "selected" frame around the edges
#define VREF_MUTABLE_SELECTED_FRAME 4
/// A misc image holder for stuff thats meant to be added ontop , used by a few actions
#define VREF_IMAGE_ONTOP 5
// /datum/action/xeno_action. Additional references
/// A mutable appearance to add the "empowered" frame around the edges
#define VREF_MUTABLE_EMPOWERED_FRAME 6
/// A image to show the clock delay ticking.
#define VREF_IMAGE_XENO_CLOCK 7
// extra reference for ravager leech
#define VREF_MUTABLE_RAV_LEECH 8
