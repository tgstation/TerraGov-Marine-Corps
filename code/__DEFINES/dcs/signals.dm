// All signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// global signals
// These are signals which can be listened to by any component on any parent
// start global signals with "!", this used to be necessary but now it's just a formatting choice

///from base of datum/controller/subsystem/mapping/proc/add_new_zlevel(): (list/args)
#define COMSIG_GLOB_NEW_Z "!new_z"
#define COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE "!open_timed_shutters_late"
#define COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND "!open_timed_shutters_xeno_hivemind"
#define COMSIG_GLOB_OPEN_TIMED_SHUTTERS_CRASH "!open_timed_shutters_crash"
#define COMSIG_GLOB_OPEN_SHUTTERS_EARLY "!open_shutters_early"

#define COMSIG_GLOB_TADPOLE_LAUNCHED "!tadpole_launched"
#define COMSIG_GLOB_DROPPOD_LANDED "!pod_landed"
#define COMSIG_GLOB_EVACUATION_STARTED "!evacuation_started"

#define COMSIG_GLOB_REMOVE_VOTE_BUTTON "!remove_vote_button"
#define COMSIG_GLOB_NUKE_START "!nuke_start"
#define COMSIG_GLOB_NUKE_STOP "!nuke_stop"
#define COMSIG_GLOB_NUKE_EXPLODED "!nuke_exploded"
#define COMSIG_GLOB_NUKE_DIFFUSED "!nuke_diffused"
#define COMSIG_GLOB_DISK_GENERATED "!disk_produced"

#define COMSIG_GLOB_SHIP_SELF_DESTRUCT_ACTIVATED "!ship_self_destruct_activated"

/// from /obj/machinery/setAnchored(): (machine, anchoredstate)
#define COMSIG_GLOB_MACHINERY_ANCHORED_CHANGE "!machinery_anchored_change"

/// called after an explosion happened : (epicenter, devastation_range, heavy_impact_range, light_impact_range, weak_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
#define COMSIG_GLOB_EXPLOSION "!explosion"

#define COMSIG_GLOB_MOB_LOGIN "!mob_login"
#define COMSIG_GLOB_MOB_LOGOUT "!mob_logout"
#define COMSIG_GLOB_MOB_DEATH "!mob_death"
#define COMSIG_GLOB_MOB_GET_STATUS_TAB_ITEMS "!mob_get_status_tab_items"

#define COMSIG_GLOB_AI_GOAL_SET "!ai_goal_set"
#define COMSIG_GLOB_AI_MINION_RALLY "!ai_minion_rally"
#define COMSIG_GLOB_HIVE_TARGET_DRAINED "!hive_target_drained"


/// Sent when a marine dropship enters transit level
#define COMSIG_GLOB_DROPSHIP_TRANSIT "!dropship_transit"
///Sent when xenos launch a hijacked dropship
#define COMSIG_GLOB_DROPSHIP_HIJACKED "!dropship_hijacked"
///Sent when nightfall is casted
#define COMSIG_GLOB_LIGHT_OFF "item_light_off"
///Sent when the floodlight switch is powered
#define COMSIG_GLOB_FLOODLIGHT_SWITCH "!floodlight_switch_power_change"
/// Sent when the xenos lock the dropship controls
#define COMSIG_GLOB_DROPSHIP_CONTROLS_CORRUPTED "!dropship_locked"
/// Sent when the xenos destroy the tadpole controls
#define COMSIG_GLOB_MINI_DROPSHIP_DESTROYED "!tad_ruined"

//Signals for fire support
#define COMSIG_GLOB_OB_LASER_CREATED "!ob_laser_sent"
#define COMSIG_GLOB_CAS_LASER_CREATED "!cas_laser_sent"
#define COMSIG_GLOB_RAILGUN_LASER_CREATED "!railgun_laser_sent"

//Signals for shuttle
#define COMSIG_GLOB_SHUTTLE_TAKEOFF "!shuttle_take_off"

/// sent after world.maxx and/or world.maxy are expanded: (has_exapnded_world_maxx, has_expanded_world_maxy)
#define COMSIG_GLOB_EXPANDED_WORLD_BOUNDS "!expanded_world_bounds"

///called after a clone is produced and leaves his vat
#define COMSIG_GLOB_CLONE_PRODUCED "!clone_produced"

///called when an AI is requested by a holopad
#define COMSIG_GLOB_HOLOPAD_AI_CALLED "!holopad_calling"

///Opens the TGMC shipside shutters on campaign
#define COMSIG_GLOB_OPEN_CAMPAIGN_SHUTTERS_TGMC "!open_campaign_shutters_tgmc"
///Opens the SOM shipside shutters on campaign
#define COMSIG_GLOB_OPEN_CAMPAIGN_SHUTTERS_SOM "!open_campaign_shutters_som"
///Sent when a new campaign mission is loaded
#define COMSIG_GLOB_CAMPAIGN_MISSION_LOADED "!campaign_mission_loaded"
///Sent when a campaign mission is started
#define COMSIG_GLOB_CAMPAIGN_MISSION_STARTED "!campaign_mission_started"
///Sent when a campaign mission ends
#define COMSIG_GLOB_CAMPAIGN_MISSION_ENDED "!campaign_mission_ended"
///Sent when a campaign objective has been destroyed
#define COMSIG_GLOB_CAMPAIGN_OBJECTIVE_DESTROYED "!campaign_objective_destroyed"
///Sent when a campaign capture objective has been captured
#define COMSIG_GLOB_CAMPAIGN_CAPTURE_OBJECTIVE_CAPTURED "!campaign_capture_objective_captured"
///Sent when a campaign capture objective has been decaptured
#define COMSIG_GLOB_CAMPAIGN_CAPTURE_OBJECTIVE_DECAPTURED "!campaign_capture_objective_decaptured"
///Sent when a campaign capture objective has started the capture process
#define COMSIG_GLOB_CAMPAIGN_CAPTURE_OBJECTIVE_CAP_STARTED "!campaign_capture_objective_started"
///Enables droppod use during campaign
#define COMSIG_GLOB_CAMPAIGN_ENABLE_DROPPODS "!campaign_enable_droppods"
///Disables droppod use during campaign
#define COMSIG_GLOB_CAMPAIGN_DISABLE_DROPPODS "!campaign_disable_droppods"
///Removes teleporter restrictions from a mission
#define COMSIG_GLOB_CAMPAIGN_TELEBLOCKER_DISABLED "!campaign_teleblocker_disabled"
///Removes droppod restrictions from a mission
#define COMSIG_GLOB_CAMPAIGN_DROPBLOCKER_DISABLED "!campaign_dropblocker_disabled"
///Override code for NT base rescue mission
#define COMSIG_GLOB_CAMPAIGN_NT_OVERRIDE_CODE "!campaign_nt_override_code"

///Campaign asset activation successful
#define COMSIG_CAMPAIGN_ASSET_ACTIVATION "campaign_asset_activation"
///Campaign asset disabler activated
#define COMSIG_CAMPAIGN_DISABLER_ACTIVATION "campaign_disabler_activation"

//////////////////////////////////////////////////////////////////

// /datum signals
/// when a component is added to a datum: (/datum/component)
#define COMSIG_COMPONENT_ADDED "component_added"
/// before a component is removed from a datum because of RemoveComponent: (/datum/component)
#define COMSIG_COMPONENT_REMOVING "component_removing"
/// before a datum's Destroy() is called: (force), returning a nonzero value will cancel the qdel operation
#define COMSIG_PREQDELETED "parent_preqdeleted"
/// just before a datum's Destroy() is called: (force), at this point none of the other components chose to interrupt qdel and Destroy will be called
#define COMSIG_QDELETING "parent_qdeleting"
/// generic topic handler (usr, href_list)
#define COMSIG_TOPIC "handle_topic"

/// fires on the target datum when an element is attached to it (/datum/element)
#define COMSIG_ELEMENT_ATTACH "element_attach"
/// fires on the target datum when an element is attached to it  (/datum/element)
#define COMSIG_ELEMENT_DETACH "element_detach"

// /datum/component signals
#define COMSIG_AUTOFIRE_ONMOUSEDOWN "autofire_onmousedown"
	#define COMPONENT_AUTOFIRE_ONMOUSEDOWN_BYPASS (1<<0)
#define COMSIG_AUTOFIRE_SHOT "autofire_shot"
	#define COMPONENT_AUTOFIRE_SHOT_SUCCESS (1<<0)
#define COMSIG_ELEMENT_CLOSE_SHUTTER_LINKED "close_shutter_linked"
///from turf/open/get_footstep_override(), to find an override footstep sound
#define COMSIG_FIND_FOOTSTEP_SOUND "find_footstep_sound"

///from /datum/element/jump when a jump has started and ended
#define COMSIG_ELEMENT_JUMP_STARTED "element_jump_started"
#define COMSIG_ELEMENT_JUMP_ENDED "element_jump_ended"

// /datum/limb signals
#define COMSIG_LIMB_DESTROYED "limb_destroyed"
#define COMSIG_LIMB_UNDESTROYED "limb_undestroyed"

// /datum/aura_bearer signals
//From /datum/aura_bearer/New(), fires on the aura_bearer's emitter. Provides a list of aura types started.
#define COMSIG_AURA_STARTED "aura_started"
//From /datum/aura_bearer/stop_emitting(), fires on the aura_bearer's emitter. Provides a list of aura types finished.
#define COMSIG_AURA_FINISHED "aura_finished"

/// Admin helps
/// From /datum/admin_help/RemoveActive().
/// Fired when an adminhelp is made inactive either due to closing or resolving.
#define COMSIG_ADMIN_HELP_MADE_INACTIVE "admin_help_made_inactive"

/// Called when the player replies. From /client/proc/cmd_admin_pm().
#define COMSIG_ADMIN_HELP_REPLIED "admin_help_replied"


// /area signals
#define COMSIG_AREA_ENTERED "area_entered" 						//from base of area/Entered(): (atom/movable/M)
#define COMSIG_AREA_EXITED "area_exited" 							//from base of area/Exited(): (atom/movable/M)

#define COMSIG_ENTER_AREA "enter_area" 						//from base of area/Entered(): (/area)
#define COMSIG_EXIT_AREA "exit_area" 							//from base of area/Exited(): (/area)


#define COMSIG_CLICK "atom_click"								//from base of atom/Click(): (location, control, params, mob/user)
#define COMSIG_CLICK_SHIFT "shift_click"						//from base of atom/ShiftClick(): (/mob)
#define COMSIG_CLICK_CTRL "ctrl_click"							//from base of atom/CtrlClickOn(): (/mob)
#define COMSIG_CLICK_ALT "alt_click"							//from base of atom/AltClick(): (/mob)
#define COMSIG_CLICK_CTRL_SHIFT "ctrl_shift_click"				//from base of atom/CtrlShiftClick(/mob)
#define COMSIG_CLICK_CTRL_MIDDLE "ctrl_middle_click"			//from base of atom/CtrlMiddleClick(): (/mob)
#define COMSIG_CLICK_RIGHT "right_click"						//from base of atom/RightClick(): (/mob)
#define COMSIG_CLICK_SHIFT_RIGHT "shift_right_click"						//from base of atom/ShiftRightClick(): (/mob)
#define COMSIG_CLICK_ALT_RIGHT "alt_right_click"							//from base of atom/AltRightClick(): (/mob)

#define COMSIG_DBLCLICK_SHIFT_MIDDLE "dblclick_shift_middle"
#define COMSIG_DBLCLICK_CTRL_SHIFT "dblclick_ctrl_shift"
#define COMSIG_DBLCLICK_CTRL_MIDDLE "dblclick_ctrl_middle"
#define COMSIG_DBLCLICK_MIDDLE "dblclick_middle"
#define COMSIG_DBLCLICK_SHIFT "dblclick_shift"
#define COMSIG_DBLCLICK_ALT "dblclick_alt"
#define COMSIG_DBLCLICK_CTRL "dblclick_ctrl"


// /client signals
#define COMSIG_CLIENT_MOUSEDOWN "client_mousedown"			//from base of client/MouseDown(): (/client, object, location, control, params)
#define COMSIG_CLIENT_MOUSEUP "client_mouseup"				//from base of client/MouseUp(): (/client, object, location, control, params)
	#define COMPONENT_CLIENT_MOUSEUP_INTERCEPT (1<<0)
#define COMSIG_CLIENT_MOUSEDRAG "client_mousedrag"			//from base of client/MouseUp(): (/client, object, location, control, params)
#define COMSIG_CLIENT_DISCONNECTED "client_disconnecred"	//from base of /client/Destroy(): (/client)
#define COMSIG_CLIENT_PREFERENCES_UIACTED "client_preferences_uiacted" //called after preferences have been updated for this client after /datum/preferences/ui_act has completed
/// Called after one or more verbs are added: (list of verbs added)
#define COMSIG_CLIENT_VERB_ADDED "client_verb_added"
/// Called after one or more verbs are removed: (list of verbs added)
#define COMSIG_CLIENT_VERB_REMOVED "client_verb_removed"

// Xeno larva queue stuff for clients
#define COMSIG_CLIENT_MOB_LOGIN "client_mob_login" //! Called on the client that just logged into a mob
#define COMSIG_CLIENT_MOB_LOGOUT "client_mob_logout" //! Called on the client that just logged out from the mob: (/mob)
#define COMSIG_CLIENT_GET_LARVA_QUEUE_POSITION "client_get_larva_queue_position" //! from /datum/component/larva_queue
#define COMSIG_CLIENT_SET_LARVA_QUEUE_POSITION "client_set_larva_queue_position" //! from /datum/component/larva_queue

// /atom signals
#define COMSIG_ATOM_ATTACKBY "atom_attackby"			        //from base of atom/attackby(): (/obj/item, /mob/living)
#define COMSIG_ATOM_ATTACKBY_ALTERNATE "atom_attackby_alternate" //from base of atom/attackby_alternate(): (/obj/item, /mob/living)
	#define COMPONENT_NO_AFTERATTACK (1<<0)						//Return this in response if you don't want afterattack to be called

#define COMSIG_ATOM_CONTENTS_DEL "atom_contents_del"			//from base of atom/handle_atom_del(): (atom/deleted)
#define COMSIG_ATOM_ENTERED "atom_entered"                      //from base of atom/Entered(): (atom/movable/entering, atom/oldloc, list/atom/oldlocs)
#define COMSIG_ATOM_EXIT "atom_exit"							//from base of atom/Exit(): (/atom/movable/exiting, direction)
	#define COMPONENT_ATOM_BLOCK_EXIT (1<<0)
#define COMSIG_ATOM_EXITED "atom_exited"						//from base of atom/Exited(): (atom/movable/exiting, direction)
#define COMSIG_ATOM_BUMPED "atom_bumped"						///from base of atom/Bumped(): (/atom/movable)
#define COMSIG_ATOM_DIR_CHANGE "atom_dir_change"				//from base of atom/setDir(): (old_dir, new_dir)
#define COMSIG_ATOM_CANREACH "atom_can_reach"					//from internal loop in atom/movable/proc/CanReach(): (list/next)
	#define COMPONENT_BLOCK_REACH (1<<0)
#define COMSIG_ATOM_SCREWDRIVER_ACT "atom_screwdriver_act"		//from base of atom/screwdriver_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_ATTACK_HAND "atom_attack_hand"				//from base of atom/attack_hand(mob/living/user)
#define COMSIG_ATOM_ATTACK_HAND_ALTERNATE "atom_attack_hand_alternate"	//from base of /atom/attack_hand_alternate(mob/living/user)
#define COMSIG_ATOM_ATTACK_GHOST "atom_attack_ghost"			//from base of atom/attack_ghost(): (mob/dead/observer/ghost)
	#define COMPONENT_NO_ATTACK_HAND (1<<0)						//works on all attack_hands.
#define COMSIG_ATOM_ATTACK_POWERLOADER "atom_attack_powerloader"//from base of atom/attack_powerloader: (mob/living/user, obj/item/powerloader_clamp/attached_clamp)
#define COMSIG_ATOM_EXAMINE "atom_examine"					//from base of atom/examine(): (/mob)
///from base of atom/get_examine_name(): (/mob, list/overrides)
#define COMSIG_ATOM_GET_EXAMINE_NAME "atom_examine_name"
	//Positions for overrides list
	#define EXAMINE_POSITION_ARTICLE (1<<0)
	#define EXAMINE_POSITION_BEFORE (1<<1)
	//End positions
	#define COMPONENT_EXNAME_CHANGED (1<<0)
///from base of atom/get_mechanics_info(): (/mob)
#define COMSIG_ATOM_GET_MECHANICS_INFO "atom_mechanics_info"
	#define COMPONENT_MECHANICS_CHANGE (1<<0)
#define COMSIG_ATOM_UPDATE_ICON "atom_update_icon"				//from base of atom/update_icon(): ()
	#define COMSIG_ATOM_NO_UPDATE_ICON_STATE (1<<0)
	#define COMSIG_ATOM_NO_UPDATE_OVERLAYS (1<<1)
#define COMSIG_ATOM_UPDATE_OVERLAYS "atom_update_overlays"		//from base of atom/update_overlays(): (list/new_overlays)
#define COMSIG_ATOM_EX_ACT "atom_ex_act"						//from base of atom/ex_act(): (severity, target)
#define COMSIG_ATOM_SET_LIGHT "atom_set_light"					//from base of atom/set_light(): (l_range, l_power, l_color)
#define COMSIG_ATOM_BULLET_ACT "atom_bullet_act"				//from base of atom/bullet_act(): (/obj/projectile)
#define COMSIG_ATOM_INITIALIZED_ON "atom_initialized_on"		//called from atom/Initialize() of target: (atom/target)
//from SSatoms InitAtom - Only if the  atom was not deleted or failed initialization
#define COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE "atom_init_success"
#define COMSIG_ATOM_ORBIT_BEGIN "atom_orbit_begin"				//called when an atom starts orbiting another atom: (atom)
#define COMSIG_ATOM_ORBIT_STOP "atom_orbit_stop"				//called when an atom stops orbiting another atom: (atom)
#define COMSIG_ATOM_ACIDSPRAY_ACT "atom_acidspray_act"			//called when acid spray acts on an entity; associated with /acidspray_act(): (obj/effect/xenomorph/spray/acid_puddle)

///from base of atom/set_opacity(): (new_opacity)
#define COMSIG_ATOM_SET_OPACITY "atom_set_opacity"

///Called right before the atom changes the value of light_range to a different one, from base atom/set_light_range(): (new_range)
#define COMSIG_ATOM_SET_LIGHT_RANGE "atom_set_light_range"
///Called right before the atom changes the value of light_power to a different one, from base atom/set_light_power(): (new_power)
#define COMSIG_ATOM_SET_LIGHT_POWER "atom_set_light_power"
///Called right before the atom changes the value of light_color to a different one, from base atom/set_light_color(): (new_color)
#define COMSIG_ATOM_SET_LIGHT_COLOR "atom_set_light_color"
///Called right before the atom changes the value of light_on to a different one, from base atom/set_light_on(): (new_value)
#define COMSIG_ATOM_SET_LIGHT_ON "atom_set_light_on"
///Called right before the atom changes the value of light_flags to a different one, from base atom/set_light_flags(): (new_value)
#define COMSIG_ATOM_SET_LIGHT_FLAGS "atom_set_light_flags"


// /atom/movable signals
#define COMSIG_MOVABLE_PRE_MOVE "movable_pre_move"				//from base of atom/movable/Move(): (/atom, new_loc, direction)
	#define COMPONENT_MOVABLE_BLOCK_PRE_MOVE (1<<0)
#define COMSIG_MOVABLE_MOVED "movable_moved"					//from base of atom/movable/Moved(): (/atom, movement_dir, forced, old_locs)
#define COMSIG_MOVABLE_PULL_MOVED "movable_pull_moved"		//base base of atom/movable/Moved() (/atom, movement_dir, forced, old_locs)
///from base of atom/movable/Cross(): (/atom/movable)
#define COMSIG_MOVABLE_CROSS "movable_cross"
///from base of atom/movable/update_loc(): (/atom/oldloc)
#define COMSIG_MOVABLE_LOCATION_CHANGE "location_changed"
#define COMSIG_MOVABLE_BUMP "movable_bump"						//from base of atom/movable/Bump(): (/atom)
	#define COMPONENT_BUMP_RESOLVED (1<<0)
#define COMSIG_MOVABLE_IMPACT "movable_impact"					//from base of atom/movable/throw_impact(): (/atom/hit_atom)
///from /atom/movable/proc/buckle_mob(): (mob/living/M, force, check_loc, buckle_mob_flags)
#define COMSIG_MOVABLE_PREBUCKLE "prebuckle" // this is the last chance to interrupt and block a buckle before it finishes
	#define COMPONENT_BLOCK_BUCKLE	(1<<0)
#define COMSIG_MOVABLE_BUCKLE "buckle"							//from base of atom/movable/buckle_mob(): (mob, force)
	#define COMPONENT_MOVABLE_BUCKLE_STOPPED (1<<0)
#define COMSIG_MOVABLE_UNBUCKLE "unbuckle"						//from base of atom/movable/unbuckle_mob(): (mob, force)
///from /obj/vehicle/proc/driver_move, caught by the riding component to check and execute the driver trying to drive the vehicle
#define COMSIG_RIDDEN_DRIVER_MOVE "driver_move"
	#define COMPONENT_DRIVER_BLOCK_MOVE (1<<0)
#define COMSIG_MOVABLE_PRE_THROW "movable_pre_throw"			//from base of atom/movable/throw_at()
	#define COMPONENT_MOVABLE_BLOCK_PRE_THROW (1<<0)
#define COMSIG_LIVING_PRE_THROW_IMPACT "movable_living_throw_impact_check" //sent before an item impacts a living mob
	#define COMPONENT_PRE_THROW_IMPACT_HIT (1<<0)
#define COMSIG_MOVABLE_POST_THROW "movable_post_throw"			//called on tail of atom/movable/throw_at()
#define COMSIG_MOVABLE_DISPOSING "movable_disposing"			//called when the movable is added to a disposal holder object for disposal movement: (obj/structure/disposalholder/holder, obj/machinery/disposal/source)
#define COMSIG_MOVABLE_HEAR "movable_hear"						//from base of atom/movable/Hear(): (message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
#define COMSIG_MOVABLE_Z_CHANGED "movable_ztransit" 			//from base of atom/movable/onTransitZ(): (old_z, new_z)
#define COMSIG_MOVABLE_PREBUMP_TURF "movable_prebump_turf"
#define COMSIG_MOVABLE_PREBUMP_MOVABLE "movable_prebump_movable"
	#define COMPONENT_MOVABLE_PREBUMP_STOPPED (1<<0)
	#define COMPONENT_MOVABLE_PREBUMP_PLOWED (1<<1)
	#define COMPONENT_MOVABLE_PREBUMP_ENTANGLED (1<<2)
#define COMSIG_MOVABLE_PREBUMP_EXIT_MOVABLE "movable_prebump_exit_movable" //from base of /turf/Exit(): (/atom/movable)
#define COMSIG_MOVABLE_UPDATE_GLIDE_SIZE "movable_glide_size"	//from base of /atom/movable/proc/set_glide_size(): (target)
/// sent before a thing is crushed by a shuttle
#define COMSIG_MOVABLE_SHUTTLE_CRUSH "movable_shuttle_crush"

// /turf signals
#define COMSIG_TURF_CHANGE "turf_change"						//from base of turf/ChangeTurf(): (path, list/new_baseturfs, flags, list/transferring_comps)
#define COMSIG_TURF_WEED_REMOVED "turf_weed_removed"
#define COMSIG_TURF_THROW_ENDED_HERE "turf_throw_ended_here"						//From atom/movable/throw_at, sent right after a throw ends
#define COMSIG_TURF_JUMP_ENDED_HERE "turf_jump_ended_here"      //from datum/element/jump/end_jump(): (jumper)
#define COMSIG_TURF_RESUME_PROJECTILE_MOVE "resume_projetile"
#define COMSIG_TURF_PROJECTILE_MANIPULATED "projectile_manipulated"
#define COMSIG_TURF_CHECK_COVERED "turf_check_covered" //from /turf/open/liquid/Entered checking if something is covering the turf
#define COMSIG_TURF_TELEPORT_CHECK "turf_teleport_check" //from /turf/proc/can_teleport_here()

// /obj signals
#define COMSIG_OBJ_SETANCHORED "obj_setanchored"				//called in /obj/structure/setAnchored(): (value)
#define COMSIG_OBJ_DECONSTRUCT "obj_deconstruct"				//from base of obj/deconstruct(): (disassembled)
#define COMSIG_OBJ_TRY_ALLOW_THROUGH "obj_try_allow_through"	//from obj/CanAllowThrough()
///from base of /turf/proc/levelupdate(). (intact) true to hide and false to unhide
#define COMSIG_OBJ_HIDE "obj_hide"
#define COMSIG_OBJ_ATTACK_ALIEN "obj_attack_alien"				//from obj/attack_alien(): (/mob/living/carbon/xenomorph)
	#define COMPONENT_NO_ATTACK_ALIEN (1<<0)

#define COMSIG_MACHINERY_POWERED "machinery_powered"			/// from /obj/machinery/proc/powered: ()
	#define COMPONENT_POWERED (1<<0)
#define COMSIG_MACHINERY_USE_POWER "machinery_use_power"		/// from /obj/machinery/proc/use_power: (amount, chan, list/power_sources)
	#define COMPONENT_POWER_USED (1<<0)

#define COMSIG_PORTGEN_POWER_TOGGLE "portgen_power_toggle"		/// from /obj/machinery/power/port_gen/proc/TogglePower: ()
#define COMSIG_PORTGEN_PROCESS "portgen_process"				/// from /obj/machinery/power/port_gen/process: ()

#define COMSIG_UNMANNED_TURRET_UPDATED "unmanned_turret_update" /// from /obj/vehicle/unmanned/attackby: (newtype)
#define COMSIG_UNMANNED_ABILITY_UPDATED "unmanned_ability_update"
#define COMSIG_UNMANNED_COORDINATES "unmanned_coordinates"

// /obj/item signals
#define COMSIG_ITEM_APPLY_CUSTOM_OVERLAY "item_apply_custom_overlay" //from base of obj/item/apply_custom(): (/image/standing)
#define COMSIG_ITEM_ATTACK "item_attack"						//from base of obj/item/attack(): (/mob/living/target, /mob/living/user)
#define COMSIG_ITEM_ATTACK_ALTERNATE "item_attack_alt"			//from base of obj/item/attack_alternate(): (/mob/living/target, /mob/living/user)
#define COMSIG_ITEM_ATTACK_SELF "item_attack_self"				//from base of obj/item/attack_self(): (/mob)
	#define COMPONENT_NO_INTERACT (1<<0)
#define COMSIG_ITEM_EQUIPPED "item_equip"						//from base of obj/item/equipped(): (/mob/equipper, slot)
#define COMSIG_ITEM_EQUIPPED_TO_SLOT "item_equip_to_slot"			//from base of obj/item/equipped(): (/mob/equipper, slot)
#define COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT "item_equip_not_in_slot"	//from base of obj/item/equipped(): (/mob/equipper, slot)
#define COMSIG_ITEM_UNEQUIPPED "item_unequip"						//from base of obj/item/unequipped(): (/mob/unequipper, slot)
#define COMSIG_ITEM_DROPPED "item_drop"							//from base of obj/item/dropped(): (mob/user)
#define COMSIG_ITEM_REMOVED_INVENTORY "item_removed_inventory"		//from base of obj/item/removed_from_inventory() :(mov/user)
#define COMSIG_ITEM_WIELD "item_wield"
#define COMSIG_ITEM_UNWIELD "item_unwield"                      //from base of obj/item/
#define COMSIG_ITEM_AFTERATTACK "item_afterattack"				//from base of obj/item/afterattack(): (atom/target, mob/user, has_proximity, click_parameters)
#define COMSIG_ITEM_AFTERATTACK_ALTERNATE "item_afterattack_alternate"	//from base of obj/item/afterattack_alternate(): (atom/target, mob/user, has_proximity, click_parameters)
#define COMSIG_ITEM_ATTACK_OBJ "item_attack_obj"				//from base of obj/item/attack_obj(): (/obj, /mob)
	#define COMPONENT_NO_ATTACK_OBJ (1<<0)
#define COMSIG_ITEM_ATTACK_TURF "item_attack_turf"				//from base of obj/item/attack_turf(): (/turf, /mob)
	#define COMPONENT_NO_ATTACK_TURF (1<<0)
#define COMSIG_ITEM_UNZOOM "item_unzoom"
#define COMSIG_ITEM_ZOOM "item_zoom"                            //from base of /obj/item/zoom(), used for telling when a scope zooms and for checking if another zoom is already on mob.
	#define COMSIG_ITEM_ALREADY_ZOOMED (1<<0)                         //bitshift that tells to a item when zoom checking that there already soemthing zooming user.
#define COMSIG_ITEM_UNIQUE_ACTION "item_unique_action" //from base of /obj/item/unique_action(): (atom/target, mob/user)

#define COMSIG_ITEM_IS_ATTACHING "item_is_attaching" //from base of /datum/component/attachment_handler/handle_attachment : (/obj/item, /mob)

#define COMSIG_ITEM_TOGGLE_ACTION "item_toggle_action"			//from base of obj/item/ui_interact(): (/mob/user)
#define COMSIG_ITEM_TOGGLE_ACTIVE "item_toggle_active"			//from base of /obj/item/toggle_active(): (new_state)
#define COMSIG_ITEM_EXCLUSIVE_TOGGLE "item_exclusive_toggle"

#define COMSIG_ITEM_MIDDLECLICKON "item_middleclickon"					//from base of mob/living/carbon/human/MiddleClickOn(): (/atom, /mob)
#define COMSIG_ITEM_SHIFTCLICKON "item_shiftclickon"					//from base of mob/living/carbon/human/ShiftClickOn(): (/atom, /mob)
#define COMSIG_ITEM_RIGHTCLICKON "item_rightclickon"					//from base of mob/living/carbon/human/RightClickOn(): (/atom, /mob)
	#define COMPONENT_ITEM_CLICKON_BYPASS (1<<0)
#define COMSIG_ITEM_TOGGLE_BUMP_ATTACK "item_toggle_bump_attack"		//from base of obj/item/proc/toggle_item_bump_attack(): (/mob/user, enable_bump_attack)

#define COMSIG_ITEM_SECONDARY_COLOR "item_secondary_color" //from base of /obj/item/proc/alternate_color_item() : (mob/user, list/obj/item)

#define COMSIG_ITEM_HYDRO_CANNON_TOGGLED "hydro_cannon_toggled"

#define COMSIG_ITEM_VARIANT_CHANGE "item_variant_change"			// called in color_item : (mob/user, variant)

#define COMSIG_NEW_REAGENT_ADD "new_reagent_add"					//from add_reagent(): (reagent_path, amount); it is sent when a reagent gets added for the first time to a holder
#define COMSIG_REAGENT_DELETING "reagent_deleting"					//from /datum/reagents/del_reagent(): (reagent_path) When a reagent is entirely removed from its holder

#define COMSIG_CLOTHING_MECHANICS_INFO "clothing_mechanics_info"	//from base of /obj/item/clothing/get_mechanics_info()
	#define COMPONENT_CLOTHING_MECHANICS_TINTED (1<<0)
	#define COMPONENT_CLOTHING_BLUR_PROTECTION (1<<1)

#define COMSIG_ITEM_UNDEPLOY "item_undeploy" //from base of /obj/machinery/deployable

#define COMSIG_ATTACHMENT_ATTACHED "attachment_attached"
#define COMSIG_ATTACHMENT_ATTACHED_TO_ITEM "attachment_attached_to_item"
#define COMSIG_ATTACHMENT_DETACHED "attachment_detached"
#define COMSIG_ATTACHMENT_DETACHED_FROM_ITEM "attachment_detached_from_item"

#define COMSIG_LOADOUT_VENDOR_VENDED_GUN_ATTACHMENT "loadout_vended_gun_attachment" //from base of /datum/item_representation/gun_attachement/proc/install_on_gun() : (/obj/item/attachment)
#define COMSIG_LOADOUT_VENDOR_VENDED_ATTACHMENT_GUN "loadout_vended_attachment_gun" //from base of /datum/item_representation/gunproc/install_on_gun() : (/obj/item/attachment)
#define COMSIG_LOADOUT_VENDOR_VENDED_ARMOR_ATTACHMENT "loadout_vended_armor_attachment" //from base of /datum/item_representation/armor_module/proc/install_on_armor() : (/obj/item/attachment)

// /obj/item/armor_module signals
#define COMSIG_ARMOR_MODULE_ATTACHING "armor_module_attaching"
#define COMSIG_ARMOR_MODULE_DETACHED "armor_module_detached"

// vali specific
#define COMSIG_CHEMSYSTEM_TOGGLED "chemsystem_toggled"

// /obj/item/helmet_module signals
#define COMSIG_HELMET_MODULE_ATTACHING "helmet_module_attaching"
#define COMSIG_HELMET_MODULE_DETACHED "helmet_module_detached"


// /obj/item/weapon/gun signals
#define COMSIG_GUN_FIRE "gun_fire"
#define COMSIG_MOB_GUN_FIRE "mob_gun_fire"
#define COMSIG_GUN_STOP_FIRE "gun_stop_fire"
#define COMSIG_GUN_FIRE_MODE_TOGGLE "gun_firemode_toggle"		//from /obj/item/weapon/gun/verb/toggle_firemode()
#define COMSIG_GUN_AUTOFIREDELAY_MODIFIED "gun_firedelay_modified"
#define COMSIG_GUN_BURST_SHOTS_TO_FIRE_MODIFIED "gun_burstamount_modified"
#define COMSIG_GUN_BURST_SHOT_DELAY_MODIFIED "gun_burstdelay_modified"
#define COMSIG_GUN_AUTO_BURST_SHOT_DELAY_MODIFIED "gun_auto_burstdelay_modified"
#define COMSIG_GUN_USER_UNSET "gun_user_unset"
#define COMSIG_GUN_USER_SET "gun_user_set"
#define COMSIG_MOB_GUN_FIRED "mob_gun_fired"
#define COMSIG_MOB_GUN_AUTOFIRED "mob_gun_autofired"
#define COMSIG_MOB_GUN_COOLDOWN "mob_gun_cooldown"

#define COMSIG_XENO_FIRE "xeno_fire"
#define COMSIG_XENO_STOP_FIRE "xeno_stop_fire"
#define COMSIG_XENO_AUTOFIREDELAY_MODIFIED "xeno_firedelay_modified"

#define COMSIG_MECH_FIRE "mech_fire"
#define COMSIG_MECH_STOP_FIRE "mech_stop_fire"


// /obj/item/clothing signals
#define COMSIG_SHOES_STEP_ACTION "shoes_step_action"			//from base of obj/item/clothing/shoes/proc/step_action(): ()

// /obj/item/grab signals
#define COMSIG_GRAB_SELF_ATTACK "grab_self_attack"				//from base of obj/item/grab/attack() if attacked is the same as attacker: (mob/living/user)
	#define COMSIG_GRAB_SUCCESSFUL_SELF_ATTACK (1<<0)

// /obj/projectile signals
#define COMSIG_PROJ_SCANTURF "proj_scanturf"
	#define COMPONENT_PROJ_SCANTURF_TURFCLEAR (1<<0)
	#define COMPONENT_PROJ_SCANTURF_TARGETFOUND (1<<1)

// /mob signals
#define COMSIG_MOB_DEATH "mob_death"							//from base of mob/death(): (gibbing)
#define COMSIG_MOB_PRE_DEATH "mob_pre_death"
	#define COMPONENT_CANCEL_DEATH (1<<0)						//interrupt death
#define COMSIG_MOB_REVIVE "mob_revive"							//from base of mob/on_revive(): ()
#define COMSIG_MOB_GHOSTIZE "mob_ghostize"							//from base of mob/ghostize(): (gibbing)
#define COMSIG_MOB_STAT_CHANGED "stat_changed"					//from base of mob/stat_change(): (old_stat, new_stat)
#define COMSIG_MOB_MOUSEDOWN "mob_mousedown"					//from /client/MouseDown(): (atom/object, turf/location, control, params)
#define COMSIG_MOB_MOUSEUP "mob_mouseup"						//from /client/MouseUp(): (atom/object, turf/location, control, params)
#define COMSIG_MOB_MOUSEDRAG "mob_mousedrag"				//from /client/MouseDrag(): (atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
#define COMSIG_MOUSEDROP_ONTO "mousedrop_onto"					//! from base of atom/MouseDrop(): (/atom/over, /mob/user)
	#define COMPONENT_NO_MOUSEDROP (1<<0)
#define COMSIG_MOUSEDROPPED_ONTO "mousedropped_onto"			//! from base of atom/MouseDrop_T: (/atom/from, /mob/user)
#define COMSIG_MOB_CLICKON "mob_clickon"						//from base of mob/clickon(): (atom/A, params)
#define COMSIG_MOB_MIDDLE_CLICK "mob_middle_click"				//from base of mob/MiddleClickOn(): (atom/A)
#define COMSIG_MOB_CLICK_SHIFT "mob_click_shift"				//from base of mob/ShiftClickOn(): (atom/A)
#define COMSIG_MOB_CLICK_ALT "mob_click_alt"					//from base of mob/AltClickOn(): (atom/A)
#define COMSIG_MOB_CLICK_RIGHT "mob_click_right"				//from base of mob/RightClickOn(): (atom/A)
#define COMSIG_MOB_CLICK_SHIFT_RIGHT "mob_click_shift_right"	//from base of mob/ShiftRightClick(): (atom/A)
#define COMSIG_MOB_CLICK_ALT_RIGHT "mob_click_alt_right"		//from base of mob/AltRightClick(): (atom/A)
	#define COMSIG_MOB_CLICK_CANCELED (1<<0)
	#define COMSIG_MOB_CLICK_HANDLED (1<<1)
#define COMSIG_MOB_ATTACK_RANGED "mob_attack_ranged"			//from base of mob/RangedAttack(): (atom/A, params)
#define COMSIG_MOB_THROW "mob_throw"							//from base of /mob/throw_item(): (atom/target)
///from base of /mob/verb/examinate(): (atom/target)
#define COMSIG_MOB_EXAMINATE "mob_examinate"
#define COMSIG_MOB_UPDATE_SIGHT "mob_update_sight"				//from base of /mob/update_sight(): ()
#define COMSIG_MOB_HUD_CREATED "mob_hud_created"				//from base of mob/create_mob_hud(): ()
#define COMSIG_MOB_KEYBINDINGS_UPDATED "mob_bindings_changed"   //from base of datum/preferences/ui_act(): (/datum/keybinding)

#define COMSIG_MOB_SHIELD_DETACH "mob_shield_detached"
#define COMSIG_MOB_ITEM_ATTACK "mob_item_attack"				//from base of /obj/item/attack(): (mob/target, /obj/item/attacking_item)
#define COMSIG_MOB_ITEM_ATTACK_ALTERNATE "mob_item_attack_alt"	//from base of /obj/item/attack_alternate(): (mob/target, /obj/item/attacking_item)
	#define COMPONENT_ITEM_NO_ATTACK (1<<0)						//return this if you dont want attacka and altattacks to run

///Called when an object is grilled ontop of a griddle
#define COMSIG_ITEM_GRILLED "item_griddled"
	#define COMPONENT_HANDLED_GRILLING (1<<0)
///Called when an object is turned into another item through grilling ontop of a griddle
#define COMSIG_GRILL_COMPLETED "item_grill_completed"

#define COMSIG_MOB_ITEM_AFTERATTACK "mob_item_afterattack"		//from base of obj/item/afterattack(): (atom/target, mob/user, has_proximity, click_parameters)
#define COMSIG_MOB_ITEM_AFTERATTACK_ALTERNATE "mob_item_afterattack_alternate" //from base of obj/item/afterattack_alternate(): (atom/target, mob/user, has_proximity, click_parameters)
#define COMSIG_MOB_SAY "mob_say" 								// from /mob/living/say(): (proc args list)
	#define COMPONENT_UPPERCASE_SPEECH (1<<0)
	// used to access COMSIG_MOB_SAY argslist
	#define SPEECH_MESSAGE 1
	// #define SPEECH_BUBBLE_TYPE 2
	#define SPEECH_SPANS 3
	// #define SPEECH_SANITIZE 4
	#define SPEECH_LANGUAGE 5
	/* #define SPEECH_IGNORE_SPAM 6
	#define SPEECH_FORCED 7 */
#define COMSIG_MOB_DEADSAY "mob_deadsay" 							// from /mob/living/say_dead(): (proc args list)
	#define MOB_DEADSAY_SIGNAL_INTERCEPT (1<<0)
#define COMSIG_MOB_LOGIN "mob_login"							//from /mob/Login(): ()
#define COMSIG_MOB_LOGOUT "mob_logout"							//from /mob/Logout(): ()
#define COMSIG_MOB_ATTACHMENT_FIRED "mob_attachment_fired"
#define COMSIG_MOB_TOGGLEMOVEINTENT "mob_togglemoveintent"		//drom base of mob/toggle_move_intent(): (new_intent)
#define COMSIG_MOB_FACE_DIR "mob_face_dir"
#define COMSIG_MOB_ENABLE_STEALTH "mob_togglestealth"
	#define STEALTH_ALREADY_ACTIVE (1<<0)
#define COMSIG_RANGED_ACCURACY_MOD_CHANGED "ranged_accuracy_mod_changed"
#define COMSIG_RANGED_SCATTER_MOD_CHANGED "ranged_scatter_mod_changed"
#define COMSIG_MOB_SKILLS_CHANGED "mob_skills_changed"
#define COMSIG_MOB_SHOCK_STAGE_CHANGED "mob_shock_stage_changed"
/// from mob/get_status_tab_items(): (list/items)
#define COMSIG_MOB_GET_STATUS_TAB_ITEMS "mob_get_status_tab_items"

//mob/dead/observer
#define COMSIG_OBSERVER_CLICKON "observer_clickon"				//from mob/dead/observer/ClickOn(): (atom/A, params)

//mob/living signals
#define COMSIG_LIVING_JOB_SET "living_job_set"	//from mob/living/proc/apply_assigned_role_to_spawn()
#define COMSIG_LIVING_DO_RESIST "living_do_resist"		//from the base of /mob/living/do_resist()
#define COMSIG_LIVING_DO_MOVE_RESIST "living_do_move_resist"			//from the base of /client/Move()
	#define COMSIG_LIVING_RESIST_SUCCESSFUL (1<<0)
#define COMSIG_LIVING_SET_CANMOVE "living_set_canmove"			//from base of /mob/living/set_canmove(): (canmove)
#define COMSIG_LIVING_MELEE_ALIEN_DISARMED "living_melee_alien_disarmed"	//from /mob/living/proc/attack_alien_disarm(): (mob/living/carbon/xenomorph/X)
#define COMSIG_LIVING_SHIELDCALL "living_shieldcall"
#define COMSIG_LIVING_PROJECTILE_STUN "living_stun_mitigation" //from /datum/ammo/proc/staggerstun
#define COMSIG_LIVING_JETPACK_STUN "living_jetpack_stun" //from /obj/item/jetpack_marine/heavy/proc/mob_hit()
///from /mob/living/proc/set_lying_angle
#define COMSIG_LIVING_SET_LYING_ANGLE "living_set_lying_angle"
#define COMSIG_LIVING_IGNITED "living_ignited" //from /mob/living/proc/IgniteMob() : (fire_stacks)

/// From mob/living/treat_message(): (list/message_args)
#define COMSIG_LIVING_TREAT_MESSAGE "living_treat_message"
	/// The index of message_args that corresponds to the actual message
	#define TREAT_MESSAGE_ARG 1
	#define TREAT_TTS_MESSAGE_ARG 2
	#define TREAT_TTS_FILTER_ARG 3

//ALL OF THESE DO NOT TAKE INTO ACCOUNT WHETHER AMOUNT IS 0 OR LOWER AND ARE SENT REGARDLESS!
#define COMSIG_LIVING_STATUS_STUN "living_stun"					//from base of mob/living/Stun() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_KNOCKDOWN "living_knockdown"		//from base of mob/living/Knockdown() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_PARALYZE "living_paralyze"			//from base of mob/living/Paralyze() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_IMMOBILIZE "living_immobilize"		//from base of mob/living/Immobilize() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_UNCONSCIOUS "living_unconscious"	//from base of mob/living/Unconscious() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_SLEEP "living_sleeping"			//from base of mob/living/Sleeping() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_CONFUSED "living_confused"			//from base of mob/living/Confused() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_STAGGER "living_stagger"			//from base of mob/living/adjust_stagger() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_SLOWDOWN "living_slowdown"			//from base of mob/living/set_slowdown() (amount, update)
	#define COMPONENT_NO_STUN (1<<0)			//For all of them

///from end of fully_heal(): (admin_revive)
#define COMSIG_LIVING_POST_FULLY_HEAL "living_post_fully_heal"

#define COMSIG_LIVING_STATUS_MUTE "living_mute"					//from base of mob/living/Mute()
	#define COMPONENT_NO_MUTE (1<<0)

#define COMSIG_LIVING_ADD_VENTCRAWL "living_add_ventcrawl"
#define COMSIG_LIVING_WEEDS_AT_LOC_CREATED "living_weeds_at_loc_created"	///from obj/alien/weeds/Initialize()
#define COMSIG_LIVING_WEEDS_ADJACENT_REMOVED "living_weeds_adjacent_removed"	///from obj/alien/weeds/Destroy()

#define COMSIG_LIVING_UPDATE_PLANE_BLUR "living_update_plane_blur"
	#define COMPONENT_CANCEL_BLUR (1<<0)

//mob/living/carbon signals
#define COMSIG_CARBON_SWAPPED_HANDS "carbon_swapped_hands"
#define COMSIG_CARBON_SETAFKSTATUS "carbon_setafkstatus"		//from base of /mob/living/set_afk_status(): (new_status, afk_timer)

// /mob/living/carbon/human signals
#define COMSIG_HUMAN_MELEE_UNARMED_ATTACK "human_melee_unarmed_attack"	//from mob/living/carbon/human/UnarmedAttack(): (atom/target)
#define COMSIG_HUMAN_MELEE_UNARMED_ATTACK_ALTERNATE "human_melee_unarmed_attack_alternate"	//same as above, but right click
#define COMSIG_HUMAN_DAMAGE_TAKEN "human_damage_taken"					//from human damage receiving procs: (mob/living/carbon/human/wearer, damage)
#define COMSIG_HUMAN_LIMB_FRACTURED "human_limb_fractured"				//from [datum/limb/proc/fracture]: (mob/living/carbon/human/wearer, datum/limb/limb)
///from [/mob/living/carbon/human/proc/apply_overlay]: (cache_index, list/overlays_to_apply)
#define COMSIG_HUMAN_APPLY_OVERLAY "human_overlay_applied"
///from [/mob/living/carbon/human/proc/remove_overlay]: (cache_index, list/overlays_to_remove)
#define COMSIG_HUMAN_REMOVE_OVERLAY "human_overlay_removed"

#define COMSIG_HUMAN_SET_UNDEFIBBABLE "human_set_undefibbable"

#define COMSIG_HUMAN_MARKSMAN_AURA_CHANGED "human_marksman_aura_changed"

// shuttle signals
#define COMSIG_SHUTTLE_SETMODE "shuttle_setmode"

#define COMSIG_DROPSHIP_EQUIPMENT_UNEQUIPPED "shuttle_equipment_unequipped"

// xeno stuff
#define COMSIG_HIVE_BECOME_RULER "hive_become_ruler"
#define COMSIG_HIVE_XENO_DEATH "hive_xeno_death"
#define COMSIG_HIVE_XENO_MOTHER_PRE_CHECK "hive_xeno_mother_pre_check"		//from datum/hive_status/normal/proc/attempt_to_spawn_larva()
#define COMSIG_HIVE_XENO_MOTHER_CHECK "hive_xeno_mother_check"				//from /datum/hive_status/normal/proc/spawn_larva()

#define COMSIG_XENO_ACTION_SUCCEED_ACTIVATE "xeno_action_succeed_activate"
	#define SUCCEED_ACTIVATE_CANCEL (1<<0)
#define COMSIG_XENOACTION_TOGGLECHARGETYPE "xenoaction_togglechargetype"

#define COMSIG_WARRIOR_USED_GRAB "warrior_used_grab"
#define COMSIG_WARRIOR_NECKGRAB "warrior_neckgrab"
	#define COMSIG_WARRIOR_CANT_NECKGRAB (1<<0)
#define COMSIG_WARRIOR_USED_FLING "warrior_used_fling"
#define COMSIG_WARRIOR_USED_GRAPPLE_TOSS "warrior_used_grapple_toss"

#define COMSIG_XENOABILITY_HUNTER_MARK "xenoability_hunter_mark"
#define COMSIG_XENOABILITY_PSYCHIC_TRACE "xenoability_psychic_trace"

#define COMSIG_XENOMORPH_PLASMA_REGEN "xenomorph_plasma_regen"
#define COMSIG_XENOMORPH_HEALTH_REGEN "xenomorph_health_regen"
#define COMSIG_XENOMORPH_SUNDER_REGEN "xenomorph_sunder_regen"
#define COMSIG_XENOMORPH_RESIN_JELLY_APPLIED "xenomorph_resin_jelly_applied"

#define COMSIG_XENOMORPH_REST "xenomorph_rest"
#define COMSIG_XENOMORPH_UNREST "xenomorph_unrest"

#define COMSIG_XENOMORPH_ZONE_SELECT "xenomorph_zone_select"
	#define COMSIG_ACCURATE_ZONE (1<<0)

#define COMSIG_XENOMORPH_POUNCE "xenomorph_pounce"
#define COMSIG_XENOMORPH_POUNCE_END "xenomorph_pounce_end"

#define COMSIG_XENOMORPH_HEADBITE "headbite"

#define COMSIG_XENOMORPH_GIBBING "xenomorph_gibbing"
#define COMSIG_XENOMORPH_POSTEVOLVING "xenomorph_evolving"
#define COMSIG_XENOMORPH_ABILITY_ON_UPGRADE "xenomorph_ability_on_upgrade"

#define COMSIG_XENOMORPH_GRAB "xenomorph_grab"
#define COMSIG_XENOMORPH_ATTACK_OBJ "xenomorph_attack_obj"
///from /mob/living/proc/attack_alien_harm(mob/living/carbon/xenomorph/X, dam_bonus, set_location, random_location, no_head, no_crit, force_intent)
#define COMSIG_XENOMORPH_ATTACK_LIVING "xenomorph_attack_living"
	#define COMSIG_XENOMORPH_BONUS_APPLIED (1<<0)
///from /mob/living/carbon/xenomorph/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
///only on INTENT_HARM, INTENT_DISARM, IF it does damaage
#define COMSIG_XENOMORPH_ATTACK_HOSTILE_XENOMORPH "xenomorph_attack_xenomorph"

///after attacking, accounts for armor
#define COMSIG_XENOMORPH_POSTATTACK_LIVING "xenomorph_postattack_living"
#define COMSIG_XENOMORPH_ATTACK_HUMAN "xenomorph_attack_human"
#define COMSIG_XENOMORPH_DISARM_HUMAN "xenomorph_disarm_human"
	#define COMPONENT_BYPASS_SHIELDS (1<<0)
	#define COMPONENT_BYPASS_ARMOR (1<<1)

#define COMSIG_XENOMORPH_THROW_HIT "xenomorph_throw_hit"

#define COMSIG_XENOMORPH_TAKING_DAMAGE "xenomorph_taking_damage" // (target, damagetaken)

#define COMSIG_XENOMORPH_BRUTE_DAMAGE "xenomorph_brute_damage" // (amount, amount_mod, passive)
#define COMSIG_XENOMORPH_BURN_DAMAGE "xenomorph_burn_damage" // (amount, amount_mod, passive)

#define COMSIG_XENOMORPH_EVOLVED "xenomorph_evolved"
#define COMSIG_XENOMORPH_DEEVOLVED "xenomorph_deevolved"
#define COMSIG_XENOMORPH_WATCHXENO "xenomorph_watchxeno"

#define COMSIG_XENOMORPH_LEADERSHIP "xenomorph_leadership"
#define COMSIG_XENOMORPH_QUEEN_PLASMA "xenomorph_queen_plasma"

#define COMSIG_XENOMORPH_CORE_RETURN "xenomorph_core_return"
#define COMSIG_XENOMORPH_HIVEMIND_CHANGE_FORM "xenomorph_hivemind_change_form"
#define COMISG_XENOMORPH_HIVEMIND_TELEPORT "xeno_hivemind_teleport"

#define COMSIG_XENO_OBJ_THROW_HIT "xeno_obj_throw_hit"				///from [/mob/living/carbon/xenomorph/throw_impact]: (obj/target, speed)
#define COMSIG_XENO_LIVING_THROW_HIT "xeno_living_throw_hit"		///from [/mob/living/carbon/xenomorph/throw_impact]: (mob/living/target)
	#define COMPONENT_KEEP_THROWING (1<<0)
#define COMSIG_XENO_PROJECTILE_HIT "xeno_projectile_hit"			///from [/mob/living/carbon/xenomorph/projectile_hit] called when a projectile hits a xeno but before confirmation of a hit (can miss due to inaccuracy/evasion)
	#define COMPONENT_PROJECTILE_DODGE (1<<0)

#define COMSIG_XENOMORPH_WRAITH_RECALL "xenomorph_wraith_recall"
	#define COMPONENT_BANISH_TARGETS_EXIST (1<<0)

#define COMSIG_XENO_PSYCHIC_LINK_REMOVED "xeno_psychic_link_removed"

//human signals
#define COMSIG_CLICK_QUICKEQUIP "click_quickequip"

// /obj/item/radio signals
#define COMSIG_RADIO_NEW_FREQUENCY "radio_new_frequency"		//called from base of /obj/item/radio/proc/set_frequency(): (list/args)

//keybindings

#define COMSIG_KB_ACTIVATED (1<<0)
#define COMSIG_KB_NOT_ACTIVATED (1<<1) //used in unique action
#define COMSIG_KB_ADMIN_ASAY_DOWN "keybinding_admin_asay_down"
#define COMSIG_KB_ADMIN_MSAY_DOWN "keybinding_admin_msay_down"
#define COMSIG_KB_ADMIN_DSAY_DOWN "keybinding_admin_dsay_down"
#define COMSIG_KB_CARBON_HOLDRUNMOVEINTENT_DOWN "keybinding_carbon_holdrunmoveintent_down"
#define COMSIG_KB_ADMIN_TOGGLEBUILDMODE_DOWN "keybinding_admin_togglebuildmode_down"
#define COMSIG_KB_CARBON_TOGGLETHROWMODE_DOWN "keybinding_carbon_togglethrowmode_down"
#define COMSIG_KB_CARBON_TOGGLEREST_DOWN "kebinding_carbon_togglerest_down"
#define COMSIG_KB_CARBON_SELECTHELPINTENT_DOWN "keybinding_carbon_selecthelpintent_down"
#define COMSIG_KB_CARBON_SELECTDISARMINTENT_DOWN "keybinding_carbon_selectdisarmintent_down"
#define COMSIG_KB_CARBON_SELECTGRABINTENT_DOWN "keybinding_carbon_selectgrabintent_down"
#define COMSIG_KB_CARBON_SELECTHARMINTENT_DOWN "keybinding_carbon_selectharmintent_down"
#define COMSIG_KB_CARBON_SPECIALCLICK_DOWN "keybinding_carbon_specialclick_down"
#define COMSIG_KB_CLIENT_GETHELP_DOWN "keybinding_client_gethelp_down"
#define COMSIG_KB_CLIENT_SCREENSHOT_DOWN "keybinding_client_screenshot_down"
#define COMSIG_KB_CLIENT_MINIMALHUD_DOWN "keybinding_client_minimalhud_down"
#define COMSIG_KB_CLIENT_SAY_DOWN "keybinding_client_say_down"
#define COMSIG_KB_CLIENT_RADIO_DOWN "keybinding_client_radio_down"
#define COMSIG_KB_CLIENT_ME_DOWN "keybinding_client_me_down"
#define COMSIG_KB_CLIENT_OOC_DOWN "keybinding_client_ooc_down"
#define COMSIG_KB_CLIENT_XOOC_DOWN "keybinding_client_xooc_down"
#define COMSIG_KB_CLIENT_MOOC_DOWN "keybinding_client_mooc_down"
#define COMSIG_KB_CLIENT_LOOC_DOWN "keybinding_client_looc_down"
#define COMSIG_KB_LIVING_RESIST_DOWN "keybinding_living_resist_down"
#define COMSIG_KB_LIVING_JUMP "keybind_jump"
#define COMSIG_KB_MOB_FACENORTH_DOWN "keybinding_mob_facenorth_down"
#define COMSIG_KB_MOB_FACEEAST_DOWN "keybinding_mob_faceeast_down"
#define COMSIG_KB_MOB_FACESOUTH_DOWN "keybinding_mob_facesouth_down"
#define COMSIG_KB_MOB_FACEWEST_DOWN "keybinding_mob_facewest_down"
#define COMSIG_KB_MOB_STOPPULLING_DOWN "keybinding_mob_stoppulling_down"
#define COMSIG_KB_MOB_CYCLEINTENTRIGHT_DOWN "keybinding_mob_cycleintentright_down"
#define COMSIG_KB_MOB_CYCLEINTENTLEFT_DOWN "keybinding_mob_cycleintentleft_down"
#define COMSIG_KB_MOB_SWAPHANDS_DOWN "keybinding_mob_swaphands_down"
#define COMSIG_KB_MOB_ACTIVATEINHAND_DOWN "keybinding_mob_activateinhand_down"
#define COMSIG_KB_MOB_DROPITEM_DOWN "keybinding_mob_dropitem_down"
#define COMSIG_KB_MOB_EXAMINE_DOWN "keybinding_mob_examine_down"
#define COMSIG_KB_MOB_TOGGLEMOVEINTENT_DOWN "keybinding_mob_togglemoveintent_down"
#define COMSIG_KB_MOB_TARGETCYCLEHEAD_DOWN "keybinding_mob_targetcyclehead_down"
#define COMSIG_KB_MOB_TARGETRIGHTARM_DOWN "keybinding_mob_targetrightarm_down"
#define COMSIG_KB_MOB_TARGETBODYCHEST_DOWN "keybinding_mob_targetbodychest_down"
#define COMSIG_KB_MOB_TARGETLEFTARM_DOWN "keybinding_mob_targetleftarm_down"
#define COMSIG_KB_MOB_TARGETRIGHTLEG_DOWN "keybinding_mob_targetrightleg_down"
#define COMSIG_KB_MOB_TARGETBODYGROIN_DOWN "keybinding_mob_targetbodygroin_down"
#define COMSIG_KB_MOB_TARGETLEFTLEG_DOWN "keybinding_mob_targetleftleg_down"
#define COMSIG_KB_MOVEMENT_NORTH_DOWN "keybinding_movement_north_down"
#define COMSIG_KB_MOVEMENT_SOUTH_DOWN "keybinding_movement_south_down"
#define COMSIG_KB_MOVEMENT_WEST_DOWN "keybinding_movement_west_down"
#define COMSIG_KB_MOVEMENT_EAST_DOWN "keybinding_movement_east_down"

// mob keybinds
#define COMSIG_KB_HOLD_RUN_MOVE_INTENT_UP "keybinding_hold_run_move_intent_up"
#define COMSIG_KB_EMOTE "keybinding_emote"
#define COMSIG_KB_TOGGLE_MINIMAP "toggle_minimap"
#define COMSIG_KB_TOGGLE_EXTERNAL_MINIMAP "toggle_external_minimap"
#define COMSIG_KB_SELFHARM "keybind_selfharm"

// mecha keybinds
#define COMSIG_MECHABILITY_TOGGLE_INTERNALS "mechability_toggle_internals"
#define COMSIG_MECHABILITY_TOGGLE_STRAFE "mechability_toggle_strafe"
#define COMSIG_MECHABILITY_VIEW_STATS "mechability_view_stats"
#define COMSIG_MECHABILITY_SMOKE "mechability_smoke"
#define COMSIG_MECHABILITY_TOGGLE_ZOOM "mechability_toggle_zoom"
#define COMSIG_MECHABILITY_SKYFALL "mechability_skyfall"
#define COMSIG_MECHABILITY_STRIKE "mechability_strike"

// xeno abilities for keybindings

#define COMSIG_XENOABILITY_REST "xenoability_rest"
#define COMSIG_XENOABILITY_HEADBITE "xenoability_headbite"
#define COMSIG_XENOABILITY_REGURGITATE "xenoability_regurgitate"
#define COMSIG_XENOABILITY_BLESSINGSMENU "xenoability_blesssingsmenu"
#define COMSIG_XENOABILITY_DROP_WEEDS "xenoability_drop_weeds"
#define COMSIG_XENOABILITY_CHOOSE_WEEDS "xenoability_choose_weeds"
#define COMSIG_XENOABILITY_DROP_PLANT "xenoability_drop_plant"
#define COMSIG_XENOABILITY_CHOOSE_PLANT "xenoability_choose_plant"
#define COMSIG_XENOABILITY_SECRETE_RESIN "xenoability_secrete_resin"
#define COMSIG_XENOABILITY_PLACE_ACID_WELL "place_acid_well"
#define COMSIG_XENOABILITY_EMIT_RECOVERY "xenoability_emit_recovery"
#define COMSIG_XENOABILITY_EMIT_WARDING "xenoability_emit_warding"
#define COMSIG_XENOABILITY_EMIT_FRENZY "xenoability_emit_frenzy"
#define COMSIG_XENOABILITY_TRANSFER_PLASMA "xenoability_transfer_plasma"
#define COMSIG_XENOABILITY_CORROSIVE_ACID "xenoability_corrosive_acid"
#define COMSIG_XENOABILITY_SPRAY_ACID "xenoability_spray_acid"
#define COMSIG_XENOABILITY_ACID_DASH "xenoability_acid_dash"
#define COMSIG_XENOABILITY_XENO_SPIT "xenoability_xeno_spit"
#define COMSIG_XENOABILITY_HIDE "xenoability_hide"
#define COMSIG_XENOABILITY_NEUROTOX_STING "xenoability_neurotox_sting"
#define COMSIG_XENOABILITY_OZELOMELYN_STING "xenoability_ozelomelyn_sting"
#define COMSIG_XENOABILITY_INJECT_EGG_NEUROGAS "xenoability_inject_egg_neurogas"
#define COMSIG_XENOABILITY_RALLY_HIVE "xenoability_rally_hive"
#define COMSIG_XENOABILITY_RALLY_MINION "xenoability_rally_minion"
#define COMSIG_XENOABILITY_MINION_BEHAVIOUR "xenoability_minion_behavior"
#define COMSIG_XENOABILITY_SILENCE "xenoability_silence"

#define COMSIG_XENOABILITY_TOXIC_SPIT "xenoability_toxic_spit"
#define COMSIG_XENOABILITY_TOXIC_SLASH "xenoability_toxic_slash"
#define COMSIG_XENOABILITY_DRAIN_STING "xenoability_drain_sting"
#define COMSIG_XENOABILITY_TOXIC_GRENADE "xenoability_toxic_grenade"

#define COMSIG_XENOABILITY_ACIDIC_SALVE "xenoability_acidic_salve"
#define COMSIG_XENOABILITY_ESSENCE_LINK "xenoability_essence_link"
#define COMSIG_XENOABILITY_ESSENCE_LINK_REMOVE "xenoability_essence_link_remove"
#define COMSIG_XENOABILITY_ENHANCEMENT "xenoability_enhancement"

#define COMSIG_XENOABILITY_LONG_RANGE_SIGHT "xenoability_long_range_sight"
#define COMSIG_XENOABILITY_TOGGLE_BOMB "xenoability_toggle_bomb"
#define COMSIG_XENOABILITY_TOGGLE_BOMB_RADIAL "xenoability_toggle_bomb_radial"
#define COMSIG_XENOABILITY_CREATE_BOMB "xenoability_create_bomb"
#define COMSIG_XENOABILITY_ROOT "xenoability_root"
#define COMSIG_XENOABILITY_BOMBARD "xenoability_bombard"

#define COMSIG_XENOABILITY_THROW_HUGGER "xenoability_throw_hugger"
#define COMSIG_XENOABILITY_CALL_YOUNGER "xenoability_call_younger"
#define COMSIG_XENOABILITY_PLACE_TRAP "xenoability_place_trap"
#define COMSIG_XENOABILITY_SPAWN_HUGGER "xenoability_spawn_hugger"
#define COMSIG_XENOABILITY_SWITCH_HUGGER "xenoability_switch_hugger"
#define COMSIG_XENOABILITY_CHOOSE_HUGGER "xenoability_choose_hugger"
#define COMSIG_XENOABILITY_DROP_ALL_HUGGER "xenoability_drop_all_hugger"
#define COMSIG_XENOABILITY_BUILD_HUGGER_TURRET "xenoability_build_hugger_turret"

#define COMSIG_XENOABILITY_STOMP "xenoability_stomp"
#define COMSIG_XENOABILITY_TOGGLE_CHARGE "xenoability_toggle_charge"
#define COMSIG_XENOABILITY_CRESTTOSS "xenoability_cresttoss"
#define COMSIG_XENOABILITY_ADVANCE "xenoability_advance"

#define COMSIG_XENOABILITY_DEVOUR "xenoability_devour"
#define COMSIG_XENOABILITY_DRAIN "xenoability_drain"
#define COMSIG_XENOABILITY_TRANSFUSION "xenoability_transfusion"
#define COMSIG_XENOABILITY_REJUVENATE "xenoability_rejuvenate"
#define COMSIG_XENOABILITY_PSYCHIC_LINK "xenoability_psychic_link"
#define COMSIG_XENOABILITY_CARNAGE "xenoability_carnage"
#define COMSIG_XENOABILITY_FEAST "xenoability_feast"

#define COMSIG_XENOABILITY_BULLCHARGE "xenoability_bullcharge"
#define COMSIG_XENOABILITY_BULLHEADBUTT "xenoability_bullheadbutt"
#define COMSIG_XENOABILITY_BULLGORE "xenoability_bullgore"

#define COMSIG_XENOABILITY_TAIL_SWEEP "xenoability_tail_sweep"
#define COMSIG_XENOABILITY_FORWARD_CHARGE "xenoability_forward_charge"
#define COMSIG_XENOABILITY_CREST_DEFENSE "xenoability_crest_defense"
#define COMSIG_XENOABILITY_FORTIFY "xenoability_fortify"
#define COMSIG_XENOABILITY_REGENERATE_SKIN "xenoability_regenerate_skin"
#define COMSIG_XENOABILITY_CENTRIFUGAL_FORCE "xenoability_centrifugal_force"

#define COMSIG_XENOABILITY_EMIT_NEUROGAS "xenoability_emit_neurogas"
#define COMSIG_XENOABILITY_SELECT_REAGENT "xenoability_select_reagent"
#define COMSIG_XENOABILITY_RADIAL_SELECT_REAGENT "xenoability_radial_select_reagent"
#define COMSIG_XENOABILITY_REAGENT_SLASH "xenoability_reagent_slash"
#define COMSIG_XENOABILITY_DEFILE "xenoability_defile"
#define COMSIG_XENOABILITY_TENTACLE "xenoability tentacle"

#define COMSIG_XENOABILITY_RESIN_WALKER "xenoability_resin_walker"
#define COMSIG_XENOABILITY_BUILD_TUNNEL "xenoability_build_tunnel"
#define COMSIG_XENOABILITY_PLACE_JELLY_POD "xenoability_place_jelly_pod"
#define COMSIG_XENOABILITY_CREATE_JELLY "xenoability_create_jelly"
#define COMSIG_XENOABILITY_HEALING_INFUSION "xenoability_healing_infusion"
#define COMSIG_XENOABILITY_RECYCLE "xenoability_recycle"

#define COMSIG_XENOABILITY_TOGGLE_STEALTH "xenoability_toggle_stealth"
#define COMSIG_XENOABILITY_TOGGLE_DISGUISE "xenoability_toggle_disguise"
#define COMSIG_XENOABILITY_MIRAGE "xenoability_mirage"

#define COMSIG_XENOABILITY_SCREECH "xenoability_screech"
#define COMSIG_XENOABILITY_PSYCHIC_WHISPER "xenoability_psychic_whisper"
#define COMSIG_XENOABILITY_TOGGLE_QUEEN_ZOOM "xenoability_toggle_queen_zoom"
#define COMSIG_XENOABILITY_XENO_LEADERS "xenoability_xeno_leaders"
#define COMSIG_XENOABILITY_QUEEN_HEAL "xenoability_queen_heal"
#define COMSIG_XENOABILITY_QUEEN_GIVE_PLASMA "xenoability_queen_give_plasma"
#define COMSIG_XENOABILITY_QUEEN_HIVE_MESSAGE "xenoability_queen_hive_message"
#define COMSIG_XENOABILITY_DEEVOLVE "xenoability_deevolve"
#define COMSIG_XENOABILITY_QUEEN_BULWARK "xenoability_queen_bulwark"

#define COMSIG_XENOABILITY_LAY_HIVEMIND "xenoability_lay_hivemind"
#define COMSIG_XENOABILITY_LAY_EGG "xenoability_lay_egg"
#define COMSIG_XENOABILITY_CALL_OF_THE_BURROWED "xenoability_call_of_the_burrowed"
#define COMSIG_XENOABILITY_PSYCHIC_FLING "xenoability_psychic_fling"
#define COMSIG_XENOABILITY_PSYCHIC_CURE "xenoability_psychic_cure"
#define COMSIG_XENOABILITY_UNRELENTING_FORCE "xenoability_unrelenting_force"
#define COMSIG_XENOABILITY_UNRELENTING_FORCE_SELECT "xenoability_unrelenting_force_select"
#define COMSIG_XENOABILITY_PSYCHIC_VORTEX "xenoability_psychic_vortex"

#define COMSIG_XENOABILITY_RAVAGER_CHARGE "xenoability_ravager_charge"
#define COMSIG_XENOABILITY_RAVAGE "xenoability_ravage"
#define COMSIG_XENOABILITY_RAVAGE_SELECT "xenoability_ravage_select"
#define COMSIG_XENOABILITY_SECOND_WIND "xenoability_second_wind"
#define COMSIG_XENOABILITY_ENDURE "xenoability_endure"
#define COMSIG_XENOABILITY_RAGE "xenoability_rage"
#define COMSIG_XENOABILITY_VAMPIRISM "xenoability_vampirism"

#define COMSIG_XENOABILITY_RUNNER_POUNCE "xenoability_runner_pounce"
#define COMSIG_XENOABILITY_HUNTER_POUNCE "xenoability_hunter_pounce"
#define COMSIG_XENOABILITY_TOGGLE_SAVAGE "xenoability_toggle_savage"
#define COMSIG_XENOABILITY_EVASION "xenoability_evasion"
#define COMSIG_XENOABILITY_AUTO_EVASION "xenoability_auto_evasion"
#define COMSIG_XENOABILITY_SNATCH "xenoability_snatch"

#define COMSIG_XENOABILITY_VENTCRAWL "xenoability_vent_crawl"

#define COMSIG_XENOABILITY_TOGGLE_AGILITY "xenoability_toggle_agility"
#define COMSIG_XENOABILITY_LUNGE "xenoability_lunge"
#define COMSIG_XENOABILITY_FLING "xenoability_fling"
#define COMSIG_XENOABILITY_PUNCH "xenoability_punch"
#define COMSIG_XENOABILITY_GRAPPLE_TOSS "xenoability_grapple_toss"
#define COMSIG_XENOABILITY_JAB "xenoability_jab"

#define COMSIG_XENOABILITY_PORTAL "xenoablity_portal"
#define COMSIG_XENOABILITY_PORTAL_ALTERNATE "xenoability_portal_alternate"
#define COMSIG_XENOABILITY_BLINK "xenoability_blink"
#define COMSIG_XENOABILITY_BANISH "xenoability_banish"
#define COMSIG_XENOABILITY_RECALL "xenoability_recall"
#define COMSIG_XENOABILITY_TIMESTOP "xenoability_timestop"
#define COMSIG_XENOABILITY_REWIND "xenoability_rewind"

#define COMSIG_XENOABILITY_NIGHTFALL "xenoability_nightfall"
#define COMSIG_XENOABILITY_PETRIFY "xenoability_petrify"
#define COMSIG_XENOABILITY_OFFGUARD "xenoability_offguard"
#define COMSIG_XENOABILITY_SHATTERING_ROAR "xenoability_shattering_roar"
#define COMSIG_XENOABILITY_ZEROFORMBEAM "xenoability_zeroformbeam"
#define COMSIG_XENOABILITY_HIVE_SUMMON "xenoability_hive_summon"

#define COMSIG_XENOABILITY_SCATTER_SPIT "xenoability_scatter_spit"

#define COMSIG_XENOABILITY_WEB_SPIT "xenoability_web_spit"
#define COMSIG_XENOABILITY_BURROW "xenoability_burrow"
#define COMSIG_XENOABILITY_LEASH_BALL "xenoability_leash_ball"
#define COMSIG_XENOABILITY_CREATE_SPIDERLING "xenoability_create_spiderling"
#define COMSIG_XENOABILITY_CREATE_SPIDERLING_USING_CC "xenoability_create_spiderling_using_cc"
#define COMSIG_XENOABILITY_ATTACH_SPIDERLINGS "xenoability_attach_spiderlings"
#define COMSIG_XENOABILITY_CANNIBALISE_SPIDERLING "xenoability_cannibalise_spiderling"
#define COMSIG_XENOABILITY_WEB_HOOK "xenoability_web_hook"
#define COMSIG_XENOABILITY_SPIDERLING_MARK "xenoability_spiderling_mark"

#define COMSIG_XENOABILITY_PSYCHIC_SHIELD "xenoability_psychic_shield"
#define COMSIG_XENOABILITY_TRIGGER_PSYCHIC_SHIELD "xenoability_trigger_psychic_shield"
#define COMSIG_XENOABILITY_PSYCHIC_BLAST "xenoability_psychic_blast"
#define COMSIG_XENOABILITY_PSYCHIC_CRUSH "xenoability_psychic_crush"

#define COMSIG_XENOABILITY_TENDRILS "xenoability_tendrils"
#define COMSIG_XENOABILITY_ORGANICBOMB "xenoability_puppeteerorganicbomb"
#define COMSIG_XENOABILITY_PUPPET "xenoability_puppet"
#define COMSIG_XENOABILITY_REFURBISHHUSK "xenoability_refurbishhusk"
#define COMSIG_XENOABILITY_DREADFULPRESENCE "xenoability_dreadfulpresence"
#define COMSIG_XENOABILITY_PINCUSHION "xenoability_pincushion"
#define COMSIG_XENOABILITY_FLAY "xenoability_flay"
#define COMSIG_XENOABILITY_SENDORDERS "xenoability_sendorders"
#define COMSIG_XENOABILITY_BESTOWBLESSINGS "xenoability_giveblessings"

#define COMSIG_XENOABILITY_BANELING_EXPLODE "xenoability_baneling_explode"
#define COMSIG_XENOABILITY_BANELING_SPAWN_POD "xenoability_baneling_spawn_pod"
#define COMSIG_XENOABILITY_BANELING_CHOOSE_REAGENT "xenoability_baneling_choose_reagent"
#define COMSIG_XENOABILITY_BANELING_DASH_EXPLOSION "xenoability_baneling_dash_explosion"

#define COMSIG_XENOABILITY_BEHEMOTH_ROLL "xenoability_behemoth_roll"
#define COMSIG_XENOABILITY_LANDSLIDE "xenoability_landslide"
#define COMSIG_XENOABILITY_EARTH_RISER "xenoability_earth_riser"
#define COMSIG_XENOABILITY_EARTH_RISER_ALTERNATE "xenoability_earth_riser_alternate"
#define COMSIG_XENOABILITY_SEISMIC_FRACTURE "xenoability_seismic_fracture"
#define COMSIG_XENOABILITY_PRIMAL_WRATH "xenoability_primal_wrath"

//sectoid abilities
#define COMSIG_ABILITY_MINDMELD "ability_mindmeld"
#define COMSIG_ABILITY_MINDFRAY "ability_mindfray"
#define COMSIG_ABILITY_REKNIT_FORM "ability_reknit_form"
#define COMSIG_ABILITY_FUSE "ability_fuse"
#define COMSIG_ABILITY_STASIS "ability_stasis"
#define COMSIG_ABILITY_TELEKINESIS "ability_telekinesis"
#define COMSIG_ABILITY_REANIMATE "ability_reanimate"

// throw parry signals
#define COMSIG_THROW_PARRY_CHECK "throw_parry_check"
#define COMSIG_PARRY_TRIGGER "parry_trigger"

// xeno iff tag signals
#define COMSIG_XENO_IFF_CHECK "xeno_iff_check" //! Signal used by certain IFF checking things to see if a xeno carries an IFF tag of the faction.

// remote control signals
#define COMSIG_REMOTECONTROL_TOGGLE "remotecontrol_toggle"
#define COMSIG_REMOTECONTROL_UNLINK "remotecontrol_unlink"
#define COMSIG_REMOTECONTROL_CHANGED "remotecontrol_changed"
#define COMSIG_RELAYED_SPEECH "relayed_speech"
	#define COMSIG_RELAYED_SPEECH_DEALT (1<<0)

// human signals for keybindings
#define COMSIG_KB_QUICKEQUIP "keybinding_quickequip"
#define COMSIG_KB_GUN_SAFETY "keybinding_gun_safety"
#define COMSIG_KB_UNIQUEACTION "keybinding_uniqueaction"
#define COMSIG_KB_RAILATTACHMENT "keybinding_railattachment"
#define COMSIG_KB_UNDERRAILATTACHMENT "keybinding_underrailattachment"
#define COMSIG_KB_UNLOADGUN "keybinding_unloadgun"
#define COMSIG_KB_AIMMODE "keybinding_aimmode"
#define COMSIG_KB_FIREMODE "keybind_firemode"
#define COMSIG_KB_AUTOEJECT "keybind_autoeject"
#define COMSIG_KB_GIVE "keybind_give"
#define COMSIG_KB_HELMETMODULE "keybinding_helmetmodule"
#define COMSIG_KB_ROBOT_AUTOREPAIR "keybinding_robot_autorepair"
#define COMSIG_KB_SUITLIGHT "keybinding_suitlight"
#define COMSIG_KB_MOVEORDER "keybind_moveorder"
#define COMSIG_KB_HOLDORDER "keybind_holdorder"
#define COMSIG_KB_FOCUSORDER "keybind_focusorder"
#define COMSIG_KB_RALLYORDER "keybind_rallyorder"
#define COMSIG_KB_SENDORDER "keybind_sendorder"
#define COMSIG_KB_ATTACKORDER "keybind_attackorder"
#define COMSIG_KB_DEFENDORDER "keybind_defendorder"
#define COMSIG_KB_RETREATORDER "keybind_retreatorder"


// human modules signals for keybindings
#define COMSIG_KB_VALI_CONFIGURE "keybinding_vali_configure"
#define COMSIG_KB_VALI_HEAL "keybinding_vali_heal"
#define COMSIG_KB_VALI_CONNECT "keybiding_vali_connect"
#define COMSIG_KB_SUITANALYZER "keybinding_suitanalyzer"

// Ability adding/removing signals
#define ACTION_GIVEN "gave_an_action"		//from base of /datum/action/proc/give_action(): (datum/action)
#define ACTION_REMOVED "removed_an_action"	//from base of /datum/action/proc/remove_action(): (datum/action)

// Action state signal that's sent whenever the action state has a distance maintained with the target being walked to
#define COMSIG_STATE_MAINTAINED_DISTANCE "action_state_maintained_dist_with_target"
	#define COMSIG_MAINTAIN_POSITION (1<<0)
#define COMSIG_OBSTRUCTED_MOVE "unable_to_step_towards_thing" //Tried to step in a direction and there was a obstruction
	#define COMSIG_OBSTACLE_DEALT_WITH (1<<0)

// /datum/song signals

///sent to the instrument when a song starts playing
#define COMSIG_SONG_START "song_start"
///sent to the instrument when a song stops playing
#define COMSIG_SONG_END "song_end"

// /obj/vehicle/sealed/mecha signals

///sent from mecha action buttons to the mecha they're linked to
#define COMSIG_MECHA_ACTION_TRIGGER "mecha_action_activate"

///sent from clicking while you have no equipment selected. Sent before cooldown and adjacency checks, so you can use this for infinite range things if you want.
#define COMSIG_MECHA_MELEE_CLICK "mecha_action_melee_click"
	/// Prevents click from happening.
	#define COMPONENT_CANCEL_MELEE_CLICK (1<<0)
///sent from clicking while you have equipment selected.
#define COMSIG_MECHA_EQUIPMENT_CLICK "mecha_action_equipment_click"
	/// Prevents click from happening.
	#define COMPONENT_CANCEL_EQUIPMENT_CLICK (1<<0)

/*******Non-Signal Component Related Defines*******/


// /datum/action signals
#define COMSIG_ACTION_TRIGGER "action_trigger"                        //from base of datum/action/proc/Trigger(): (datum/action)
	#define COMPONENT_ACTION_BLOCK_TRIGGER (1<<0)

//Signals for CIC orders
#define COMSIG_ORDER_SELECTED "order_selected"
#define COMSIG_ORDER_SENT "order_updated"

//Signals for automatic fire at component
#define COMSIG_AUTOMATIC_SHOOTER_START_SHOOTING_AT "start_shooting_at"
#define COMSIG_AUTOMATIC_SHOOTER_STOP_SHOOTING_AT "stop_shooting_at"
#define COMSIG_AUTOMATIC_SHOOTER_SHOOT "shoot"

//Signals for gun auto fire component
#define COMSIG_GET_BURST_FIRE "get_burst_fire"
	#define BURST_FIRING (1<<0)

//Signals for ais
#define COMSIG_ESCORTING_ATOM_BEHAVIOUR_CHANGED "escorting_behaviour_changed"
#define COMSIG_ESCORTED_ATOM_CHANGING "escorted_atom_changing"
#define COMSIG_POINT_TO_ATOM "point_to_atom"

/// from datum ui_act (usr, action)
#define COMSIG_UI_ACT "COMSIG_UI_ACT"

/// From reequip components
#define COMSIG_REEQUIP_FAILURE "reequip failure"

//spatial grid signals

///Called from base of /datum/controller/subsystem/spatial_grid/proc/enter_cell: (/atom/movable)
#define SPATIAL_GRID_CELL_ENTERED(contents_type) "spatial_grid_cell_entered_[contents_type]"
///Called from base of /datum/controller/subsystem/spatial_grid/proc/exit_cell: (/atom/movable)
#define SPATIAL_GRID_CELL_EXITED(contents_type) "spatial_grid_cell_exited_[contents_type]"

// widow spiderling signals
#define COMSIG_SPIDERLING_MARK "spiderling_mark"
#define COMSIG_SPIDERLING_RETURN "spiderling_return"
#define COMSIG_SPIDERLING_GUARD "spiderling_guard"
#define COMSIG_SPIDERLING_UNGUARD "spiderling_unguard"

//puppet
#define COMSIG_PUPPET_CHANGE_ORDER "puppetchangeorder"
#define COMSIG_PUPPET_CHANGE_ALL_ORDER "puppetglobalorder"

#define COMSIG_CAVE_INTERFERENCE_CHECK "cave_interference_check" //! Cave comms interference check signal.
