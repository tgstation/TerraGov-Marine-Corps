//Anything related to clicking

//Atom clicks

///from base of atom/Click(): (location, control, params, mob/user)
#define COMSIG_CLICK "atom_click"

//Left Clicks
///from base of atom/LeftClick(): (/mob)
#define COMSIG_LEFT_CLICK "atom_left_click"
///from base of atom/CtrlClick(): (/mob)
#define COMSIG_CTRL_LEFT_CLICK "atom_ctrl_click"
///from base of atom/ShiftClick(): (/mob)
#define COMSIG_SHIFT_LEFT_CLICK "atom_shift_click"
///from base of atom/AltClick(): (/mob)
#define COMSIG_ALT_LEFT_CLICK "atom_alt_click"
///from base of atom/CtrlShiftClick(): (/mob)
#define COMSIG_CTRL_SHIFT_LEFT_CLICK "atom_ctrl_shift_click"

//Middle Clicks
///from base of atom/MiddleClick(): (/mob)
#define COMSIG_MIDDLE_CLICK "atom_middle_click"
///from base of atom/CtrlMiddleClick(): (/mob)
#define COMSIG_CTRL_MIDDLE_CLICK "atom_ctrl_middle_click"
///from base of atom/ShiftMiddleClick(): (/mob)
#define COMSIG_SHIFT_MIDDLE_CLICK "atom_shift_middle_click"
///from base of atom/AltMiddleClick(): (/mob)
#define COMSIG_ALT_MIDDLE_CLICK "atom_alt_middle_click"

//Right Clicks
///from base of atom/RightClick(): (/mob)
#define COMSIG_RIGHT_CLICK "atom_right_click"
///from base of atom/CtrlRightClick(): (/mob)
#define COMSIG_CTRL_RIGHT_CLICK "atom_ctrl_right_click"
///from base of atom/ShiftRightClick(): (/mob)
#define COMSIG_SHIFT_RIGHT_CLICK "atom_shift_right_click"
///from base of atom/AltRightClick(): (/mob)
#define COMSIG_ALT_RIGHT_CLICK "atom_alt_right_click"

#define COMSIG_DBLCLICK_SHIFT_MIDDLE "dblclick_shift_middle"
#define COMSIG_DBLCLICK_CTRL_SHIFT "dblclick_ctrl_shift"
#define COMSIG_DBLCLICK_CTRL_MIDDLE "dblclick_ctrl_middle"
#define COMSIG_DBLCLICK_MIDDLE "dblclick_middle"
#define COMSIG_DBLCLICK_SHIFT "dblclick_shift"
#define COMSIG_DBLCLICK_ALT "dblclick_alt"
#define COMSIG_DBLCLICK_CTRL "dblclick_ctrl"

//Mob clicks
///from base of mob/clickon(): (atom/A, params)
#define COMSIG_MOB_CLICKON "mob_clickon"
	#define COMSIG_MOB_CLICK_CANCELED (1<<0)
	#define COMSIG_MOB_CLICK_HANDLED (1<<1)

//Left Clicks
///from base of mob/LeftClick(): (/mob)
#define COMSIG_MOB_LEFT_CLICK "mob_left_click"
///from base of mob/CtrlClick(): (/mob)
#define COMSIG_MOB_CTRL_LEFT_CLICK "mob_ctrl_click"
///from base of mob/ShiftClick(): (/mob)
#define COMSIG_MOB_SHIFT_LEFT_CLICK "mob_shift_click"
///from base of mob/AltClick(): (/mob)
#define COMSIG_MOB_ALT_LEFT_CLICK "mob_alt_click"
///from base of mob/CtrlShiftClick(): (/mob)
#define COMSIG_MOB_CTRL_SHIFT_LEFT_CLICK "mob_ctrl_shift_click"

//Middle Clicks
///from base of mob/MiddleClick(): (/mob)
#define COMSIG_MOB_MIDDLE_CLICK "mob_middle_click"
///from base of mob/CtrlMiddleClick(): (/mob)
#define COMSIG_MOB_CTRL_MIDDLE_CLICK "mob_ctrl_middle_click"
///from base of mob/ShiftMiddleClick(): (/mob)
#define COMSIG_MOB_SHIFT_MIDDLE_CLICK "mob_shift_middle_click"
///from base of mob/AltMiddleClick(): (/mob)
#define COMSIG_MOB_ALT_MIDDLE_CLICK "mob_alt_middle_click"

//Right Clicks
///from base of mob/RightClick(): (/mob)
#define COMSIG_MOB_RIGHT_CLICK "mob_right_click"
///from base of mob/CtrlRightClick(): (/mob)
#define COMSIG_MOB_CTRL_RIGHT_CLICK "mob_ctrl_right_click"
///from base of mob/ShiftRightClick(): (/mob)
#define COMSIG_MOB_SHIFT_RIGHT_CLICK "mob_shift_right_click"
///from base of mob/AltRightClick(): (/mob)
#define COMSIG_MOB_ALT_RIGHT_CLICK "mob_alt_right_click"

//Item clicks
///from base of mob/living/carbon/human/ShiftClickOn(): (/atom, /mob)
#define COMSIG_ITEM_SHIFTCLICKON "item_shiftclickon"
///from base of mob/living/carbon/human/MiddleClickOn(): (/atom, /mob)
#define COMSIG_ITEM_MIDDLECLICKON "item_middleclickon"
///from base of mob/living/carbon/human/RightClickOn(): (/atom, /mob)
#define COMSIG_ITEM_RIGHTCLICKON "item_rightclickon"
	#define COMPONENT_ITEM_CLICKON_BYPASS (1<<0)

///from base of obj/item/afterattack(): (atom/target, mob/user, has_proximity, click_parameters)
#define COMSIG_MOB_ITEM_AFTERATTACK "mob_item_afterattack"
///from base of obj/item/afterattack_alternate(): (atom/target, mob/user, has_proximity, click_parameters)
#define COMSIG_MOB_ITEM_AFTERATTACK_ALTERNATE "mob_item_afterattack_alternate"


