/* This is just a file holding numerical defines for reference retrieval on /action datums
ideally you should never override the base list , and just add onto its length
The noting system for these is
VREF_[DATA_TYPE]_[WHAT_IS_IT_USED_FOR]

*/

// Base /datum/action visual references. All subdatums should have these
/// A define for accesing the mutable appearance of the linked obj. Holds a reference of the objects appearance
#define VREF_APPEARANCE_LINKED_OBJ "VREF_LINKED_OBJ"
/// A mutable appearance of icon made with action_icon_state and action_icon
#define VREF_MUTABLE_ACTION_STATE "VREF_ACTION_STATE"
/// A mutable appearance for keybinding maptext
#define VREF_MUTABLE_MAPTEXT "VREF_BIND_TEXT"
/// A mutable appearance to add a "selected" frame around the edges
#define VREF_MUTABLE_SELECTED_FRAME "VREF_SELECTED_FRAME"
/// A misc image holder for stuff thats meant to be added ontop , used by a few actions
#define VREF_IMAGE_ONTOP "VREF_LAYERED_IMAGE"
// /datum/action/xeno_action. Additional references
/// A mutable appearance to add the "empowered" frame around the edges
#define VREF_MUTABLE_EMPOWERED_FRAME "VREF_EMPOWERED_FRAME"
/// A image to show the clock delay ticking.
#define VREF_IMAGE_XENO_CLOCK "VREF_ACTION_CLOCK"
// extra reference for ravager leech
#define VREF_MUTABLE_RAV_LEECH "VREF_RAV_LEECH"
