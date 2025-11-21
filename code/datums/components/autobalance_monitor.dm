/**
 * A component that actively sets the value of requisition points for this item in [/datum/controller/subsystem/monitor].
 * Points are changed whenever the gamestate changes to shipside OR the item changes z-level.
 * Should be applied to meaningful requisition items.
 */

/datum/component/autobalance_monitor
	/// The value in requisition points that this item is worth.
	var/point_value = 0

/datum/component/autobalance_monitor/Initialize(_point_value)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE // This should be an item.
	if(!_point_value)
		return COMPONENT_INCOMPATIBLE // This should be a meaningful number.
	point_value = _point_value

/datum/component/autobalance_monitor/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(changed_zlevel))
	if(SSmonitor.gamestate != SHIPSIDE)
		RegisterSignal(SSdcs, COMSIG_GLOB_GAMESTATE_SHIPSIDE, PROC_REF(changed_to_shipside_gamestate))
	var/obj/item/item_parent = parent
	SSmonitor.requisition_item_keys[item_parent] = (SSmonitor.gamestate == SHIPSIDE && !is_mainship_level(item_parent.z)) ? 0 : point_value

/datum/component/autobalance_monitor/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED)
	if(SSmonitor.gamestate != SHIPSIDE)
		UnregisterSignal(SSdcs, COMSIG_GLOB_GAMESTATE_SHIPSIDE)
	SSmonitor.requisition_item_keys -= parent

/// Called whenever the gamestate is changed to SHIPSIDE.
/datum/component/autobalance_monitor/proc/changed_to_shipside_gamestate(atom/source)
	SIGNAL_HANDLER
	UnregisterSignal(SSdcs, COMSIG_GLOB_GAMESTATE_SHIPSIDE)
	var/obj/item/item_parent = parent
	if(is_mainship_level(item_parent.z))
		return
	SSmonitor.requisition_item_keys[item_parent] = 0

/// Called whenever the parent changes z-levels.
/datum/component/autobalance_monitor/proc/changed_zlevel(atom/source, old_zlevel, new_zlevel, is_same_zlayer)
	SIGNAL_HANDLER
	SSmonitor.requisition_item_keys[parent] = (SSmonitor.gamestate == SHIPSIDE && !is_mainship_level(ZTRAIT_MARINE_MAIN_SHIP)) ? 0 : point_value
