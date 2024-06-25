// All signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// global signals
// These are signals which can be listened to by any component on any parent
// start global signals with "!", this used to be necessary but now it's just a formatting choice

///from base of datum/controller/subsystem/mapping/proc/add_new_zlevel(): (list/args)
#define COMSIG_GLOB_NEW_Z "!new_z"
#define COMSIG_GLOB_DEPLOY_TIMELOCK_ENDED "!deploy_timelock_ended"
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
/// called after a successful var edit somewhere in the world: (list/args)
#define COMSIG_GLOB_VAR_EDIT "!var_edit"
/// called after an explosion happened : (epicenter, devastation_range, heavy_impact_range, light_impact_range, weak_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
#define COMSIG_GLOB_EXPLOSION "!explosion"
///Gamemode has successfully loaded
#define COMSIG_GLOB_GAMEMODE_LOADED "!gamemode_loaded"

/// a client (re)connected, after all /client/New() checks have passed : (client/connected_client)
#define COMSIG_GLOB_CLIENT_CONNECT "!client_connect"

#define COMSIG_GLOB_PLAYER_ROUNDSTART_SPAWNED "!player_roundstart_spawned"
#define COMSIG_GLOB_PLAYER_LATE_SPAWNED "!player_late_spawned"

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

//Sent when a supply beacon is activated
#define COMSIG_GLOB_SUPPLY_BEACON_CREATED "!supply_beacon_created"

//Signals for shuttle
#define COMSIG_GLOB_SHUTTLE_TAKEOFF "!shuttle_take_off"

/// sent after world.maxx and/or world.maxy are expanded: (has_exapnded_world_maxx, has_expanded_world_maxy)
#define COMSIG_GLOB_EXPANDED_WORLD_BOUNDS "!expanded_world_bounds"

///called after a clone is produced and leaves his vat
#define COMSIG_GLOB_CLONE_PRODUCED "!clone_produced"

///called when an AI is requested by a holopad
#define COMSIG_GLOB_HOLOPAD_AI_CALLED "!holopad_calling"

///Sent when mob is deployed via a patrol point
#define COMSIG_GLOB_HVH_DEPLOY_POINT_ACTIVATED "!hvh_deploy_point_activated"
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
///Code computer starts running
#define COMSIG_GLOB_CAMPAIGN_NT_OVERRIDE_RUNNING "!campaign_nt_override_running"
///Code computer stops running
#define COMSIG_GLOB_CAMPAIGN_NT_OVERRIDE_STOP_RUNNING "!campaign_nt_override_stop_running"
///Campaign OB beacon deployed
#define COMSIG_GLOB_CAMPAIGN_OB_BEACON_ACTIVATION "!campaign_ob_beacon_activation"
///Campaign OB beacon going off
#define COMSIG_GLOB_CAMPAIGN_OB_BEACON_TRIGGERED "!campaign_ob_beacon_triggered"
///Enables the teleporter array
#define COMSIG_GLOB_TELEPORTER_ARRAY_ENABLED "!teleporter_array_enabled"

//////////////////////////////////////////////////////////////////
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

///Called on an object to "clean it", such as removing blood decals/overlays, etc. The clean types bitfield is sent with it. Return TRUE if any cleaning was necessary and thus performed.
#define COMSIG_COMPONENT_CLEAN_ACT "clean_act"
	///Returned by cleanable components when they are cleaned.
	#define COMPONENT_CLEANED (1<<0)
///from base of atom/max_stack_merging(): (obj/item/stack/S)
#define ATOM_MAX_STACK_MERGING "atom_max_stack_merging"
///from base of atom/recalculate_storage_space(): ()
#define ATOM_RECALCULATE_STORAGE_SPACE "atom_recalculate_storage_space"
#define COMSIG_ATOM_CONTENTS_DEL "atom_contents_del"			//from base of atom/handle_atom_del(): (atom/deleted)
#define COMSIG_ATOM_ENTERED "atom_entered"                      //from base of atom/Entered(): (atom/movable/entering, atom/oldloc, list/atom/oldlocs)
#define COMSIG_ATOM_EXIT "atom_exit"							//from base of atom/Exit(): (/atom/movable/exiting, direction)
	#define COMPONENT_ATOM_BLOCK_EXIT (1<<0)
#define COMSIG_ATOM_EXITED "atom_exited"						//from base of atom/Exited(): (atom/movable/exiting, direction)
#define COMSIG_ATOM_BUMPED "atom_bumped"						///from base of atom/Bumped(): (/atom/movable)
#define COMSIG_ATOM_DIR_CHANGE "atom_dir_change"				//from base of atom/setDir(): (old_dir, new_dir)
#define COMSIG_ATOM_CANREACH "atom_can_reach"					//from internal loop in atom/movable/proc/CanReach(): (list/next)
	#define COMPONENT_BLOCK_REACH (1<<0)
#define COMSIG_ATOM_ATTACK_HAND "atom_attack_hand"				//from base of atom/attack_hand(mob/living/user)
#define COMSIG_ATOM_ATTACK_HAND_ALTERNATE "atom_attack_hand_alternate"	//from base of /atom/attack_hand_alternate(mob/living/user)
#define COMSIG_ATOM_ATTACK_GHOST "atom_attack_ghost"			//from base of atom/attack_ghost(): (mob/dead/observer/ghost)
	#define COMPONENT_NO_ATTACK_HAND (1<<0)						//works on all attack_hands.
#define COMSIG_ATOM_ATTACK_POWERLOADER "atom_attack_powerloader"//from base of atom/attack_powerloader: (mob/living/user, obj/item/powerloader_clamp/attached_clamp)
///from base of atom/emp_act(): (severity)
#define COMSIG_ATOM_EMP_ACT "atom_emp_act"
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

///from base of [/atom/proc/update_appearance]: (updates)
#define COMSIG_ATOM_UPDATE_APPEARANCE "atom_update_appearance"
	/// If returned from [COMSIG_ATOM_UPDATE_APPEARANCE] it prevents the atom from updating its name.
	#define COMSIG_ATOM_NO_UPDATE_NAME UPDATE_NAME
	/// If returned from [COMSIG_ATOM_UPDATE_APPEARANCE] it prevents the atom from updating its desc.
	#define COMSIG_ATOM_NO_UPDATE_DESC UPDATE_DESC
	/// If returned from [COMSIG_ATOM_UPDATE_APPEARANCE] it prevents the atom from updating its icon.
	#define COMSIG_ATOM_NO_UPDATE_ICON UPDATE_ICON
///from base of [/atom/proc/update_name]: (updates)
#define COMSIG_ATOM_UPDATE_NAME "atom_update_name"
///from base of [/atom/proc/update_desc]: (updates)
#define COMSIG_ATOM_UPDATE_DESC "atom_update_desc"
///from base of [/atom/update_icon]: ()
#define COMSIG_ATOM_UPDATE_ICON "atom_update_icon"
	/// If returned from [COMSIG_ATOM_UPDATE_ICON] it prevents the atom from updating its icon state.
	#define COMSIG_ATOM_NO_UPDATE_ICON_STATE UPDATE_ICON_STATE
	/// If returned from [COMSIG_ATOM_UPDATE_ICON] it prevents the atom from updating its overlays.
	#define COMSIG_ATOM_NO_UPDATE_OVERLAYS UPDATE_OVERLAYS
///from base of [atom/update_icon_state]: ()
#define COMSIG_ATOM_UPDATE_ICON_STATE "atom_update_icon_state"
///from base of [/atom/update_overlays]: (list/new_overlays)
#define COMSIG_ATOM_UPDATE_OVERLAYS "atom_update_overlays"
///from base of [/atom/update_icon]: (signalOut, did_anything)
#define COMSIG_ATOM_UPDATED_ICON "atom_updated_icon"

#define COMSIG_ATOM_EX_ACT "atom_ex_act"						//from base of atom/ex_act(): (severity, target)
///from base of atom/contents_explosion(): (severity)
#define COMSIG_CONTENTS_EX_ACT "contents_ex_act"
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
///from /obj/vehicle/add_control_flags
#define COMSIG_VEHICLE_GRANT_CONTROL_FLAG "vehicle_grant_control_flag"
///from /obj/vehicle/remove_control_flags
#define COMSIG_VEHICLE_REVOKE_CONTROL_FLAG "vehicle_revoke_control_flag"
///from /obj/vehicle/sealed/proc/driver_move
#define COMSIG_VEHICLE_MOVE "vehicle_move"
///From obj/hitbox/owner_turned
#define  COMSIG_MULTITILE_VEHICLE_ROTATED "multitile_vehicle_rotated"
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
///Movable deployed via a patrol point
#define COMSIG_MOVABLE_PATROL_DEPLOYED "movable_patrol_deployed"

// /turf signals
#define COMSIG_TURF_CHANGE "turf_change"						//from base of turf/ChangeTurf(): (path, list/new_baseturfs, flags, list/transferring_comps)
#define COMSIG_TURF_WEED_REMOVED "turf_weed_removed"
#define COMSIG_TURF_THROW_ENDED_HERE "turf_throw_ended_here"						//From atom/movable/throw_at, sent right after a throw ends
#define COMSIG_TURF_JUMP_ENDED_HERE "turf_jump_ended_here"      //from datum/element/jump/end_jump(): (jumper)
#define COMSIG_TURF_RESUME_PROJECTILE_MOVE "resume_projetile"
#define COMSIG_TURF_PROJECTILE_MANIPULATED "projectile_manipulated"
#define COMSIG_TURF_CHECK_COVERED "turf_check_covered" //from /turf/open/liquid/Entered checking if something is covering the turf
#define COMSIG_TURF_TELEPORT_CHECK "turf_teleport_check" //from /turf/proc/can_teleport_here()
#define COMSIG_TURF_SUBMERGE_CHECK "turf_submerge_check" //from /turf/proc/get_submerge_height() checking if something on the turf should submerge an AM

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
#define COMSIG_ITEM_ATTACK_SELF_ALTERNATE "item_attack_self_alternate" //from base of obj/item/attack_self_alternate(): (/mob)
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

#define COMSIG_ITEM_MIDDLECLICKON "item_middleclickon"					//from base of mob/living/carbon/human/MiddleClickOn(): (/atom, /mob)
#define COMSIG_ITEM_SHIFTCLICKON "item_shiftclickon"					//from base of mob/living/carbon/human/ShiftClickOn(): (/atom, /mob)
#define COMSIG_ITEM_RIGHTCLICKON "item_rightclickon"					//from base of mob/living/carbon/human/RightClickOn(): (/atom, /mob)
	#define COMPONENT_ITEM_CLICKON_BYPASS (1<<0)
#define COMSIG_ITEM_TOGGLE_BUMP_ATTACK "item_toggle_bump_attack"		//from base of obj/item/proc/toggle_item_bump_attack(): (/mob/user, enable_bump_attack)

#define COMSIG_ITEM_SECONDARY_COLOR "item_secondary_color" //from base of /obj/item/proc/alternate_color_item() : (mob/user, list/obj/item)

#define COMSIG_ITEM_HYDRO_CANNON_TOGGLED "hydro_cannon_toggled"

#define COMSIG_ITEM_VARIANT_CHANGE "item_variant_change"			// called in color_item : (mob/user, variant)

#define COMSIG_CLOTHING_MECHANICS_INFO "clothing_mechanics_info"	//from base of /obj/item/clothing/get_mechanics_info()
	#define COMPONENT_CLOTHING_MECHANICS_TINTED (1<<0)
	#define COMPONENT_CLOTHING_BLUR_PROTECTION (1<<1)

#define COMSIG_ITEM_UNDEPLOY "item_undeploy" //from base of /obj/machinery/deployable

///from base of obj/item/quick_equip(): (mob/user)
#define COMSIG_ITEM_QUICK_EQUIP "item_quick_equip"
// Return signals for /datum/storage/proc/on_quick_equip_request
	#define COMSIG_QUICK_EQUIP_HANDLED (1<<0) //Our signal handler took care of quick equip
	#define COMSIG_QUICK_EQUIP_BLOCKED (1<<1) //Our signal handler blocked the quick equip, but does not want to block the remainder of the proc

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

// /obj/item/cell
#define COMSIG_CELL_SELF_RECHARGE "cell_self_recharge"

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

#define COMSIG_ARMORED_FIRE "armored_fire"
#define COMSIG_ARMORED_STOP_FIRE "armored_stop_fire"

// /obj/item/clothing signals
#define COMSIG_SHOES_STEP_ACTION "shoes_step_action"			//from base of obj/item/clothing/shoes/proc/step_action(): ()

// /obj/item/grab signals
#define COMSIG_GRAB_SELF_ATTACK "grab_self_attack"				//from base of obj/item/grab/attack() if attacked is the same as attacker: (mob/living/user)
	#define COMSIG_GRAB_SUCCESSFUL_SELF_ATTACK (1<<0)

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
/// from mob/proc/dropItemToGround()
#define COMSIG_MOB_DROPPING_ITEM "mob_dropping_item"
///From mob/do_after_coefficent()
#define MOB_GET_DO_AFTER_COEFFICIENT "mob_get_do_after_coefficient"
///From get_zone_with_miss_chance
#define MOB_GET_MISS_CHANCE_MOD "mob_get_miss_chance_mod"

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
///From base of mob/living/set_jump_component()
#define COMSIG_LIVING_SET_JUMP_COMPONENT "living_set_jump_component"

#define COMSIG_LIVING_SWAPPED_HANDS "living_swapped_hands"
/// From /obj/item/proc/pickup(): (/obj/item/picked_up_item)
#define COMSIG_LIVING_PICKED_UP_ITEM "living_picked_up_item"

//mob/living/carbon signals
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
///from /mob/living/carbon/xenomorph/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
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

#define COMSIG_XENOMORPH_LEAP_BUMP "xenomorph_leap_bump" //from /mob/living/carbon/xenomorph/bump

//human signals
#define COMSIG_CLICK_QUICKEQUIP "click_quickequip"

// /obj/item/radio signals
#define COMSIG_RADIO_NEW_FREQUENCY "radio_new_frequency"		//called from base of /obj/item/radio/proc/set_frequency(): (list/args)


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

#define COMSIG_ABILITY_SUCCEED_ACTIVATE "xeno_action_succeed_activate"
	#define SUCCEED_ACTIVATE_CANCEL (1<<0)

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

//Campaign signals
///Campaign asset obtained for the first time
#define COMSIG_CAMPAIGN_NEW_ASSET "campaign_new_asset"
///Campaign asset activation successful
#define COMSIG_CAMPAIGN_ASSET_ACTIVATION "campaign_asset_activation"
///Campaign asset disabler activated
#define COMSIG_CAMPAIGN_DISABLER_ACTIVATION "campaign_disabler_activation"
