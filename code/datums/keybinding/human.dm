/datum/keybinding/human
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB
	description = ""

/datum/keybinding/human/quick_equip
	keybind_signal = COMSIG_KB_QUICKEQUIP
	///The quick equip slot the keybind will equip to, checked by the reciever of the keybind signal.
	var/quick_equip_slot

/datum/keybinding/human/quick_equip/quick_equip_primary
	hotkey_keys = list("E")
	name = "quick_equip_1"
	full_name = "Quick equip 1"
	quick_equip_slot = 1

/datum/keybinding/human/quick_equip/quick_equip_secondary
	hotkey_keys = list("ShiftE")
	name = "quick_equip_2"
	full_name = "Quick equip 2"
	quick_equip_slot = 2

/datum/keybinding/human/quick_equip/quick_equip_tertiary
	name = "quick_equip_3"
	full_name = "Quick equip 3"
	quick_equip_slot = 3

/datum/keybinding/human/quick_equip/quick_equip_quaternary
	name = "quick_equip_4"
	full_name = "Quick equip 4"
	quick_equip_slot = 4

/datum/keybinding/human/quick_equip/quick_equip_quinary
	name = "quick_equip_5"
	full_name = "Quick equip 5"
	quick_equip_slot = 5

/datum/keybinding/human/interact_other_hand
	hotkey_keys = list("Unbound")
	name = "interact_other_hand"
	full_name = "Interact with other hand"
	keybind_signal = COMSIG_KB_HUMAN_INTERACT_OTHER_HAND

/datum/keybinding/human/interact_other_hand/down(client/user)
	. = ..()
	if(.)
		return

	if(!ishuman(user.mob))
		return
	var/mob/living/carbon/human/human_user = user.mob

	human_user.interact_other_hand()

/datum/keybinding/human/unique_action
	hotkey_keys = list("Space")
	name = "unique_action"
	full_name = "Perform unique action"
	keybind_signal = COMSIG_KB_UNIQUEACTION

/datum/keybinding/human/rail_attachment
	hotkey_keys = list("F")
	name = "rail_attachment"
	full_name = "Activate Rail attachment"
	keybind_signal = COMSIG_KB_RAILATTACHMENT

/datum/keybinding/human/muzzle_attachment
	name = "muzzle_attachment"
	full_name = "Activate Barrel attachment"
	keybind_signal = COMSIG_KB_MUZZLEATTACHMENT

/datum/keybinding/human/underrail_attachment
	name = "underrail_attachment"
	full_name = "Activate Underrail attachment"
	keybind_signal = COMSIG_KB_UNDERRAILATTACHMENT

/datum/keybinding/human/unload_gun
	name = "unload_gun"
	full_name = "Unload gun"
	keybind_signal = COMSIG_KB_UNLOADGUN

/datum/keybinding/human/toggle_gun_safety
	name = "toggle_safety"
	full_name = "Toggle gun safety"
	keybind_signal = COMSIG_KB_GUN_SAFETY

/datum/keybinding/human/toggle_aim_mode
	hotkey_keys = list("6")
	name = "toggle_aim_mode"
	full_name = "Toggle aim mode"
	keybind_signal = COMSIG_KB_AIMMODE

/datum/keybinding/human/switch_fire_mode
	name = "switch_fire_mode"
	full_name = "Switch fire mode"
	keybind_signal = COMSIG_KB_FIREMODE

/datum/keybinding/human/toggle_auto_eject
	name = "toggle_auto_eject"
	full_name = "Toggle automatic magazine ejection"
	keybind_signal = COMSIG_KB_AUTOEJECT

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
	keybind_signal = COMSIG_KB_VALI_HEAL

/datum/keybinding/human/vali_connect
	name = "vali_connect"
	full_name = "Connect Vali"
	description = "Connect Vali system to your weapon"
	keybind_signal = COMSIG_KB_VALI_CONNECT

/datum/keybinding/human/suit_analyzer
	name = "suit_analyzer"
	full_name = "Activate suit health analyzer"
	keybind_signal = COMSIG_KB_SUITANALYZER

/datum/keybinding/human/toggle_helmet_module
	hotkey_keys = list("h")
	name = "toggle_helmet_module"
	full_name = "Toggle helmet module"
	description = "Toggles your helmet module on or off or activates it"
	keybind_signal = COMSIG_KB_HELMETMODULE

/datum/keybinding/human/toggle_armor_module
	hotkey_keys = list("j")
	name = "toggle_armor_module"
	full_name = "Toggle armor module"
	description = "Toggles your armor module or activates it"
	keybind_signal = COMSIG_KB_ARMORMODULE

/datum/keybinding/human/toggle_suit_light
	hotkey_keys = list("l")
	name = "toggle_suit_light"
	full_name = "Toggle suit light"
	description = "Toggles your suit light on or off"
	keybind_signal = COMSIG_KB_SUITLIGHT

/datum/keybinding/human/activate_robot_autorepair
	hotkey_keys = list("g")
	name = "autorepair"
	full_name = "Activate combat robot autorepair"
	description = "Activate combat robot's autorepair"
	keybind_signal = COMSIG_KB_ROBOT_AUTOREPAIR

/datum/keybinding/human/stims_menu
	hotkey_keys = list("g")
	name = "stims menu"
	full_name = "Supersoldier Stims"
	description = "Manage injecting stims as a prototype supersoldier."
	keybind_signal = COMSIG_KB_STIMS


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

/datum/keybinding/human/vehicle_honk
	name = "vehicle_honk"
	full_name = "Honk Horn"
	description = "Tell marines to move so that they don't get run over"
	keybind_signal = COMSIG_KB_VEHICLEHONK

/datum/keybinding/human/place_hologram
	name = "place_hologram"
	full_name = "Place Hologram"
	description = "Place a holographic template of a structure"
	keybind_signal = COMSIG_ABILITY_PLACE_HOLOGRAM
	hotkey_keys = list("E")

/datum/keybinding/human/select_buildtype
	name = "select_buildtype"
	full_name = "Select Buildtype"
	description = "Select the structure to use when using Place Hologram"
	keybind_signal = COMSIG_ABILITY_SELECT_BUILDTYPE
	hotkey_keys = list("Q")
