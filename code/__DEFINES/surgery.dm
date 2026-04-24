#define SURGERY_TOOL_CUTTING "surgery_tool_cutting"
#define SURGERY_TOOL_CLAMPING "surgery_tool_clamping"
#define SURGERY_TOOL_RETRACTING "surgery_tool_RETRACTING"
#define SURGERY_TOOL_CAUTERIZING "surgery_tool_cauterizing"

///List of tools for generic cutting surgery steps
GLOBAL_LIST_INIT(surgery_cut_tools, list(
	/obj/item/tool/surgery/scalpel = 100,
	/obj/item/tool/kitchen/knife = 75,
	/obj/item/shard = 50,
	/obj/item/weapon/combat_knife = 25,
	/obj/item/attachable/bayonet = 25,
	/obj/item/weapon/shiv = 15,
	/obj/item/stack/throwing_knife = 15,
	/obj/item/weapon/sword = 5,
))
///List of tools for generic clamping surgery steps
GLOBAL_LIST_INIT(surgery_clamp_tools, list(
	/obj/item/tool/surgery/hemostat = 100,
	/obj/item/stack/cable_coil = 75,
	/obj/item/assembly/mousetrap = 10,
))
///List of tools for generic retracting surgery steps
GLOBAL_LIST_INIT(surgery_retract_tools, list(
	/obj/item/tool/surgery/retractor = 100,
	/obj/item/tool/crowbar = 75,
	/obj/item/tool/kitchen/utensil/fork = 50,
))
///List of tools for generic cauterising surgery steps
GLOBAL_LIST_INIT(surgery_cauterize_tools, list(
	/obj/item/tool/surgery/cautery = 100,
	/obj/item/clothing/mask/cigarette = 75,
	/obj/item/tool/lighter = 50,
	/obj/item/tool/weldingtool = 25,
	/obj/item/tool/pickaxe/plasmacutter = 5, //you gotta be desperate
))

GLOBAL_LIST_INIT(surgery_steps, init_surgery())

/// Surgery Steps - Initialize all /datum/surgery_step into a list
/proc/init_surgery()
	var/list/surgeries = list()
	for(var/surgery_step_type in subtypesof(/datum/surgery_step))
		var/datum/surgery_step/step = new surgery_step_type
		surgeries += step

	return sort_surgeries(surgeries)
