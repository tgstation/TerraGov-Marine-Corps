/datum/keybinding/human
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB


/datum/keybinding/human/quick_equip
	hotkey_keys = list("E")
	name = "quick_equip"
	full_name = "Quick equip"
	description = ""
	keybind_signal = COMSIG_KB_QUICKEQUIP

/datum/keybinding/human/quick_equip_alt
	hotkey_keys = list("ShiftE")
	name = "quick_equip_alt"
	full_name = "Quick equip alternate"
	description = ""
	keybind_signal = COMSIG_KB_QUICKEQUIPALT

/datum/keybinding/human/unique_action
	hotkey_keys = list("Space")
	name = "unique_action"
	full_name = "Perform unique action"
	description = ""
	keybind_signal = COMSIG_KB_UNIQUEACTION

/datum/keybinding/human/rail_attachment
	hotkey_keys = list("F")
	name = "rail_attachment"
	full_name = "Activate Rail attachment"
	description = ""
	keybind_signal = COMSIG_KB_RAILATTACHMENT

/datum/keybinding/human/underrail_attachment
	name = "underrail_attachment"
	full_name = "Activate Underrail attachment"
	description = ""
	keybind_signal = COMSIG_KB_UNDERRAILATTACHMENT

/datum/keybinding/human/unload_gun
	name = "unload_gun"
	full_name = "Unload gun"
	description = ""
	keybind_signal = COMSIG_KB_UNLOADGUN

/datum/keybinding/human/toggle_gun_safety
	name = "toggle_safety"
	full_name = "Toggle gun safety"
	description = ""
	keybind_signal = COMSIG_KB_GUN_SAFETY

/datum/keybinding/human/toggle_aim_mode
	hotkey_keys = list("6")
	name = "toggle_aim_mode"
	full_name = "Toggle aim mode"
	description = ""
	keybind_signal = COMSIG_KB_AIMMODE

/datum/keybinding/human/switch_fire_mode
	name = "switch_fire_mode"
	full_name = "Switch fire mode"
	description = ""
	keybind_signal = COMSIG_KB_FIREMODE

/datum/keybinding/human/give
	name = "give"
	full_name = "Give"
	description = "Give the held item to the nearby marine"
	keybind_signal = COMSIG_KB_GIVE

/datum/keybinding/human/vali_configure
	name = "vali_configure"
	full_name = "Configure Vali Chemical Enhancement"
	description = "Vali settings menu"
	keybind_signal = COMSIG_KB_VALI_CONFIGURE

/datum/keybinding/human/vali_heal
	name = "vali_heal"
	full_name = "Activate Vali healing"
	description = ""
	keybind_signal = COMSIG_KB_VALI_HEAL

/datum/keybinding/human/vali_connect
	name = "vali_connect"
	full_name = "Connect Vali"
	description = "Connect Vali system to your weapon"
	keybind_signal = COMSIG_KB_VALI_CONNECT

/datum/keybinding/human/suit_analyzer
	name = "suit_analyzer"
	full_name = "Activate suit health analyzer"
	description = ""
	keybind_signal = COMSIG_KB_SUITANALYZER

/datum/keybinding/human/move_order
	name = "move_order"
	full_name = "Issue Move Order"
	description = "Order marines to move faster"
	keybind_signal = COMSIG_KB_MOVEORDER

/datum/keybinding/human/hold_order
	name = "hold_order"
	full_name = "Issue Hold Order"
	description = "Order marines to hold ground"
	keybind_signal = COMSIG_KB_HOLDORDER

/datum/keybinding/human/focus_order
	name = "focus_order"
	full_name = "Issue Focus Order"
	description = "Order marines to aim better"
	keybind_signal = COMSIG_KB_FOCUSORDER

/datum/keybinding/human/rally_order
	name = "rally_order"
	full_name = "Send Rally Order"
	description = "Order marines to rally"
	keybind_signal = COMSIG_KB_RALLYORDER

/datum/keybinding/human/send_order
	name = "send_order"
	full_name = "Send Order"
	description = "Order marines a certain message"
	keybind_signal = COMSIG_KB_SENDORDER

/datum/keybinding/human/attack_order
	name = "attack_order"
	full_name = "Issue Attack Order"
	description = "Order and rally marines to attack"
	keybind_signal = COMSIG_KB_ATTACKORDER

/datum/keybinding/human/defend_order
	name = "defend_order"
	full_name = "Issue Defend Order"
	description = "Order and rally marines to defend"
	keybind_signal = COMSIG_KB_DEFENDORDER

/datum/keybinding/human/retreat_order
	name = "retreat_order"
	full_name = "Issue Retreat Order"
	description = "Order and rally marines to retreat"
	keybind_signal = COMSIG_KB_RETREATORDER
