// All signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// global signals
// These are signals which can be listened to by any component on any parent
// start global signals with "!", this used to be necessary but now it's just a formatting choice
#define COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE "!open_timed_shutters_late"
#define COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND "!open_timed_shutters_xeno_hivemind"
#define COMSIG_GLOB_OPEN_TIMED_SHUTTERS_CRASH "!open_timed_shutters_crash"

#define COMSIG_GLOB_REMOVE_VOTE_BUTTON "!remove_vote_button"
#define COMSIG_GLOB_NUKE_START "!nuke_start"
#define COMSIG_GLOB_NUKE_STOP "!nuke_stop"
#define COMSIG_GLOB_NUKE_EXPLODED "!nuke_exploded"
#define COMSIG_GLOB_NUKE_DIFFUSED "!nuke_diffused"

/// called after an explosion happened : (epicenter, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
#define COMSIG_GLOB_EXPLOSION "!explosion"

#define COMSIG_GLOB_MOB_LOGIN "!mob_login"
#define COMSIG_GLOB_MOB_LOGOUT "!mob_logout"
#define COMSIG_GLOB_MOB_DEATH "!mob_death"


/// Sent when a marine dropship enters transit level
#define COMSIG_GLOB_DROPSHIP_TRANSIT "!dropship_transit"

//////////////////////////////////////////////////////////////////

// /datum signals
/// when a component is added to a datum: (/datum/component)
#define COMSIG_COMPONENT_ADDED "component_added"
/// before a component is removed from a datum because of RemoveComponent: (/datum/component)
#define COMSIG_COMPONENT_REMOVING "component_removing"
/// before a datum's Destroy() is called: (force), returning a nonzero value will cancel the qdel operation
#define COMSIG_PARENT_PREQDELETED "parent_preqdeleted"
/// just before a datum's Destroy() is called: (force), at this point none of the other components chose to interrupt qdel and Destroy will be called
#define COMSIG_PARENT_QDELETING "parent_qdeleting"
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
#define ELEMENT_CLOSE_SHUTTER_LINKED "close_shutter_linked"

// /datum/limb signals
#define COMSIG_LIMB_DESTROYED "limb_destroyed"
#define COMSIG_LIMB_UNDESTROYED "limb_undestroyed"

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
#define COMSIG_CLICK_CTRL_MIDDLE "ctrl_middle_click"

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
#define COMSIG_CLIENT_DISCONNECTED "client_disconnecred"	//from base of /client/Del(): (/client)


// /atom signals
#define COMSIG_PARENT_ATTACKBY "atom_attackby"			        //from base of atom/attackby(): (/obj/item, /mob/living)
	#define COMPONENT_NO_AFTERATTACK 1								//Return this in response if you don't want afterattack to be called
#define COMSIG_ATOM_CONTENTS_DEL "atom_contents_del"			//from base of atom/handle_atom_del(): (atom/deleted)
#define COMSIG_ATOM_ENTERED "atom_entered"                      //from base of atom/Entered(): (atom/movable/entering, /atom)
#define COMSIG_ATOM_EXIT "atom_exit"							//from base of atom/Exit(): (/atom/movable/exiting, /atom/newloc)
	#define COMPONENT_ATOM_BLOCK_EXIT 1
#define COMSIG_ATOM_EXITED "atom_exited"						//from base of atom/Exited(): (atom/movable/exiting, atom/newloc)
#define COMSIG_ATOM_BUMPED "atom_bumped"						///from base of atom/Bumped(): (/atom/movable)
#define COMSIG_ATOM_DIR_CHANGE "atom_dir_change"				//from base of atom/setDir(): (old_dir, new_dir)
#define COMSIG_ATOM_CANREACH "atom_can_reach"					//from internal loop in atom/movable/proc/CanReach(): (list/next)
	#define COMPONENT_BLOCK_REACH 1
#define COMSIG_ATOM_SCREWDRIVER_ACT "atom_screwdriver_act"		//from base of atom/screwdriver_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_ATTACK_HAND "atom_attack_hand"				//from base of atom/attack_hand(mob/living/user)
#define COMSIG_ATOM_ATTACK_GHOST "atom_attack_ghost"			//from base of atom/attack_ghost(): (mob/dead/observer/ghost)
	#define COMPONENT_NO_ATTACK_HAND 1							//works on all attack_hands.
#define COMSIG_PARENT_EXAMINE "atom_examine"					//from base of atom/examine(): (/mob)
#define COMSIG_ATOM_UPDATE_ICON "atom_update_icon"				//from base of atom/update_icon(): ()
	#define COMSIG_ATOM_NO_UPDATE_ICON_STATE	(1<<0)
	#define COMSIG_ATOM_NO_UPDATE_OVERLAYS		(1<<1)
#define COMSIG_ATOM_UPDATE_OVERLAYS "atom_update_overlays"		//from base of atom/update_overlays(): (list/new_overlays)
#define COMSIG_ATOM_EX_ACT "atom_ex_act"						//from base of atom/ex_act(): (severity, target)
#define COMSIG_ATOM_SET_LIGHT "atom_set_light"					//from base of atom/set_light(): (l_range, l_power, l_color)
#define COMSIG_ATOM_BULLET_ACT "atom_bullet_act"				//from base of atom/bullet_act(): (/obj/projectile)
#define COMSIG_ATOM_INITIALIZED_ON "atom_initialized_on"		//called from atom/Initialize() of target: (atom/target)
#define COMSIG_ATOM_ORBIT_BEGIN "atom_orbit_begin"				//called when an atom starts orbiting another atom: (atom)
#define COMSIG_ATOM_ORBIT_STOP "atom_orbit_stop"				//called when an atom stops orbiting another atom: (atom)

// /atom/movable signals
#define COMSIG_MOVABLE_PRE_MOVE "movable_pre_move"					//from base of atom/movable/Moved(): (/atom)
#define COMSIG_MOVABLE_MOVED "movable_moved"					//from base of atom/movable/Moved(): (/atom, dir)
#define COMSIG_MOVABLE_CROSSED_BY "movable_crossed_by"			//from base of atom/movable/Crossed(): (/atom/movable, oldloc)
#define COMSIG_MOVABLE_CROSSED "movable_crossed"				//from base of atom/movable/Crossed(): (/atom/movable, oldloc)
#define COMSIG_MOVABLE_BUMP "movable_bump"						//from base of atom/movable/Bump(): (/atom)
	#define COMPONENT_BUMP_RESOLVED (1<<0)
#define COMSIG_MOVABLE_IMPACT "movable_impact"					//from base of atom/movable/throw_impact(): (/atom/hit_atom)
#define COMSIG_MOVABLE_BUCKLE "buckle"							//from base of atom/movable/buckle_mob(): (mob, force)
	#define COMPONENT_MOVABLE_BUCKLE_STOPPED (1<<0)
#define COMSIG_MOVABLE_UNBUCKLE "unbuckle"						//from base of atom/movable/unbuckle_mob(): (mob, force)
#define COMSIG_MOVABLE_PRE_THROW "movable_pre_throw"			//from base of atom/movable/throw_at(): (list/args)
	#define COMPONENT_CANCEL_THROW (1<<0)
#define COMSIG_MOVABLE_DISPOSING "movable_disposing"			//called when the movable is added to a disposal holder object for disposal movement: (obj/structure/disposalholder/holder, obj/machinery/disposal/source)
#define COMSIG_MOVABLE_HEAR "movable_hear"						//from base of atom/movable/Hear(): (message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
#define COMSIG_MOVABLE_Z_CHANGED "movable_ztransit" 			//from base of atom/movable/onTransitZ(): (old_z, new_z)
#define COMSIG_MOVABLE_CROSS "movable_cross"					//from base of atom/movable/Cross(): (/atom/movable)
#define COMSIG_MOVABLE_UNCROSS "movable_uncross"				//from base of atom/movable/Uncross(): (/atom/movable)
	#define COMPONENT_MOVABLE_BLOCK_UNCROSS 1
#define COMSIG_MOVABLE_UNCROSSED "movable_uncrossed"            //from base of atom/movable/Uncrossed(): (/atom/movable)
#define COMSIG_MOVABLE_RELEASED_FROM_STOMACH "movable_released_from_stomach" //from base of mob/living/carbon/xenomorph/proc/empty_gut(): (prey, predator)
#define COMSIG_MOVABLE_CLOSET_DUMPED "movable_closet_dumped"
#define COMSIG_MOVABLE_PREBUMP_TURF "movable_prebump_turf"
#define COMSIG_MOVABLE_PREBUMP_MOVABLE "movable_prebump_movable"
	#define COMPONENT_MOVABLE_PREBUMP_STOPPED		(1<<0)
	#define COMPONENT_MOVABLE_PREBUMP_PLOWED		(1<<1)
	#define COMPONENT_MOVABLE_PREBUMP_ENTANGLED		(1<<2)
#define COMSIG_MOVABLE_PREBUMP_EXIT_MOVABLE "movable_prebump_exit_movable" //from base of /turf/Exit(): (/atom/movable)
#define COMSIG_MOVABLE_UPDATE_GLIDE_SIZE "movable_glide_size"	//from base of /atom/movable/proc/set_glide_size(): (target)

// /turf signals
#define COMSIG_TURF_CHANGE "turf_change"						//from base of turf/ChangeTurf(): (path, list/new_baseturfs, flags, list/transferring_comps)

// /obj signals
#define COMSIG_OBJ_SETANCHORED "obj_setanchored"				//called in /obj/structure/setAnchored(): (value)
#define COMSIG_OBJ_DECONSTRUCT "obj_deconstruct"				//from base of obj/deconstruct(): (disassembled)
#define COMSIG_OBJ_ATTACK_ALIEN "obj_attack_alien"				//from obj/attack_alien(): (/mob/living/carbon/xenomorph)
	#define COMPONENT_NO_ATTACK_ALIEN (1<<0)

// /obj/item signals
#define COMSIG_ITEM_ATTACK "item_attack"						//from base of obj/item/attack(): (/mob/living/target, /mob/living/user)
#define COMSIG_ITEM_ATTACK_SELF "item_attack_self"				//from base of obj/item/attack_self(): (/mob)
	#define COMPONENT_NO_INTERACT 1
#define COMSIG_ITEM_EQUIPPED "item_equip"						//from base of obj/item/equipped(): (/mob/equipper, slot)
#define COMSIG_ITEM_EQUIPPED_TO_SLOT "item_equip_to_slot"			//from base of obj/item/equipped(): (/mob/equipper)
#define COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT "item_equip_not_in_slot"	//from base of obj/item/equipped(): (/mob/equipper, slot)
#define COMSIG_ITEM_UNEQUIPPED "item_unequip"						//from base of obj/item/unequipped(): (/mob/unequipper, slot)
#define COMSIG_ITEM_DROPPED "item_drop"							//from base of obj/item/dropped(): (mob/user)
#define COMSIG_ITEM_AFTERATTACK "item_afterattack"				//from base of obj/item/afterattack(): (atom/target, mob/user, proximity_flag, click_parameters)
#define COMSIG_ITEM_ATTACK_OBJ "item_attack_obj"				//from base of obj/item/attack_obj(): (/obj, /mob)
	#define COMPONENT_NO_ATTACK_OBJ 1
#define COMSIG_ITEM_TOGGLE_ACTION "item_toggle_action"			//from base of obj/item/ui_interact(): (/mob/user)
#define COMSIG_ITEM_TOGGLE_ACTIVE "item_toggle_active"			//from base of /obj/item/toggle_active(): (new_state)

#define COMSIG_ITEM_MIDDLECLICKON "item_middleclickon"					//from base of mob/MiddleClickOn(): (/atom, /mob)
#define COMSIG_ITEM_SHIFTCLICKON "item_shiftclickon"					//from base of mob/ShiftClickOn(): (/atom, /mob)
	#define COMPONENT_ITEM_CLICKON_BYPASS (1<<0)

#define COMSIG_CLOTHING_MECHANICS_INFO "clothing_mechanics_info"	//from base of /obj/item/clothing/get_mechanics_info()
	#define COMPONENT_CLOTHING_MECHANICS_TINTED	(1<<0)
#define COMSIG_TOGGLE_JETPACK_DASH "toggle_jetpack_dash"		//from the /obj/item/tank/jetpack/oxygen/combat/attack_self()

// /obj/item/weapon/gun signals
#define COMSIG_GUN_FIRE "gun_fire"
	#define COMPONENT_GUN_FIRED 1
#define COMSIG_GUN_AUTOFIRE "gun_autofire"
#define COMSIG_GUN_CLICKEMPTY "gun_clickempty"
#define COMSIG_GUN_FIREMODE_TOGGLE "gun_firemode_toggle"		//from /obj/item/weapon/gun/verb/toggle_firemode()
#define COMSIG_GUN_FIREDELAY_MODIFIED "gun_firedelay_modified"
#define COMSIG_GUN_BURSTDELAY_MODIFIED "gun_burstdelay_modified"
#define COMSIG_GUN_BURSTAMOUNT_MODIFIED "gun_burstamount_modified"

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
#define COMSIG_MOB_DEATH "mob_death"							//from base of mob/death(): (gibbed)
#define COMSIG_MOB_REVIVE "mob_revive"							//from base of mob/on_revive(): ()
#define COMSIG_MOB_MOUSEDOWN "mob_mousedown"					//from /client/MouseDown(): (atom/object, turf/location, control, params)
#define COMSIG_MOB_MOUSEUP "mob_mouseup"						//from /client/MouseUp(): (atom/object, turf/location, control, params)
#define COMSIG_MOB_CLICKON "mob_clickon"						//from base of mob/clickon(): (atom/A, params)
#define COMSIG_MOB_CLICK_SHIFT "mob_click_shift"				//from base of mob/ShiftClickOn(): (atom/A)
#define COMSIG_MOB_CLICK_ALT "mob_click_alt"					//from base of mob/AltClickOn(): (atom/A)
	#define COMSIG_MOB_CLICK_CANCELED (1<<0)
	#define COMSIG_MOB_CLICK_HANDLED (1<<1)
#define COMSIG_MOB_ATTACK_RANGED "mob_attack_ranged"			//from base of mob/RangedAttack(): (atom/A, params)
#define COMSIG_MOB_THROW "mob_throw"							//from base of /mob/throw_item(): (atom/target)
#define COMSIG_MOB_UPDATE_SIGHT "mob_update_sight"				//from base of /mob/update_sight(): ()
#define COMSIG_MOB_HUD_CREATED "mob_hud_created"				//from base of mob/create_mob_hud(): ()
#define COMSIG_MOB_ITEM_ATTACK "mob_item_attack"				//from base of /obj/item/attack(): (mob/target, /obj/item/attacking_item)
	#define COMPONENT_ITEM_NO_ATTACK (1<<0)
#define COMSIG_MOB_ITEM_AFTERATTACK "mob_item_afterattack"		//from base of obj/item/afterattack(): (atom/target, mob/user, proximity_flag, click_parameters)
#define COMSIG_MOB_SAY "mob_say" 								// from /mob/living/say(): (proc args list)
#define COMSIG_MOB_LOGIN "mob_login"							//from /mob/Login(): ()
#define COMSIG_MOB_LOGOUT "mob_logout"							//from /mob/Logout(): ()
#define COMSIG_MOB_GUN_FIRED "mob_gun_fired"					//from gun system: (atom/target,obj/item/weapon/gun/gun, mob/living/user)
#define COMSIG_MOB_GUN_AUTOFIRED "mob_gun_autofired"
#define COMSIG_MOB_ATTACHMENT_FIRED "mob_attachment_fired"
#define COMSIG_MOB_TOGGLEMOVEINTENT "mob_togglemoveintent"		//drom base of mob/toggle_move_intent(): (new_intent)

//mob/dead/observer
#define COMSIG_OBSERVER_CLICKON "observer_clickon"				//from mob/dead/observer/ClickOn(): (atom/A, params)

//mob/living signals
#define COMSIG_LIVING_DO_RESIST			"living_do_resist"		//from the base of /mob/living/do_resist()
#define COMSIG_LIVING_DO_MOVE_RESIST "living_do_move_resist"			//from the base of /client/Move()
	#define COMSIG_LIVING_RESIST_SUCCESSFUL (1<<0)
#define COMSIG_LIVING_LEGCUFFED "living_legcuffed"	//from the base of /mob/living/carbon/proc/update_legcuffed(): (obj/item/restraints/legcuffs/restraints)
#define COMSIG_LIVING_SET_CANMOVE "living_set_canmove"			//from base of /mob/living/set_canmove(): (canmove)
#define COMSIG_LIVING_MELEE_ALIEN_DISARMED "living_melee_alien_disarmed"	//from /mob/living/proc/attack_alien_disarm(): (mob/living/carbon/xenomorph/X)
#define COMSIG_LIVING_SHIELDCALL "living_shieldcall"

//ALL OF THESE DO NOT TAKE INTO ACCOUNT WHETHER AMOUNT IS 0 OR LOWER AND ARE SENT REGARDLESS!
#define COMSIG_LIVING_STATUS_STUN "living_stun"					//from base of mob/living/Stun() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_KNOCKDOWN "living_knockdown"		//from base of mob/living/Knockdown() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_PARALYZE "living_paralyze"			//from base of mob/living/Paralyze() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_IMMOBILIZE "living_immobilize"		//from base of mob/living/Immobilize() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_UNCONSCIOUS "living_unconscious"	//from base of mob/living/Unconscious() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_SLEEP "living_sleeping"			//from base of mob/living/Sleeping() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_CONFUSED "living_confused"			//from base of mob/living/Confused() (amount, update, ignore)
	#define COMPONENT_NO_STUN (1<<0)			//For all of them

#define COMSIG_LIVING_ADD_VENTCRAWL "living_add_ventcrawl"

//mob/living/carbon signals
#define COMSIG_CARBON_DEVOURED_BY_XENO "carbon_devoured_by_xeno"
#define COMSIG_CARBON_SWAPPED_HANDS "carbon_swapped_hands"
#define COMSIG_CARBON_SETAFKSTATUS "carbon_setafkstatus"		//from base of /mob/living/set_afk_status(): (new_status, afk_timer)

// /mob/living/carbon/human signals
#define COMSIG_HUMAN_MELEE_UNARMED_ATTACK "human_melee_unarmed_attack"	//from mob/living/carbon/human/UnarmedAttack(): (atom/target)
#define COMSIG_HUMAN_DAMAGE_TAKEN "human_damage_taken"					//from human damage receiving procs: (mob/living/carbon/human/wearer, damage)
#define COMSIG_HUMAN_LIMB_FRACTURED "human_limb_fractured"				//from [datum/limb/proc/fracture]: (mob/living/carbon/human/wearer, datum/limb/limb)

// shuttle signals
#define COMSIG_SHUTTLE_SETMODE "shuttle_setmode"

// xeno stuff
#define COMSIG_HIVE_BECOME_RULER "hive_become_ruler"
#define COMSIG_HIVE_XENO_DEATH "hive_xeno_death"
#define COMSIG_HIVE_XENO_MOTHER_PRE_CHECK "hive_xeno_mother_pre_check"		//from datum/hive_status/normal/proc/attempt_to_spawn_larva()
#define COMSIG_HIVE_XENO_MOTHER_CHECK "hive_xeno_mother_check"				//from /datum/hive_status/normal/proc/spawn_larva()

#define COMSIG_XENOACTION_TOGGLECHARGETYPE "xenoaction_togglechargetype"

#define COMSIG_WARRIOR_USED_GRAB "warrior_used_grab"
#define COMSIG_WARRIOR_NECKGRAB "warrior_neckgrab"
	#define COMSIG_WARRIOR_CANT_NECKGRAB 1
#define COMSIG_WARRIOR_CTRL_CLICK_ATOM "warrior_ctrl_click_atom"
	#define COMSIG_WARRIOR_USED_LUNGE 1

#define COMSIG_XENOMORPH_PLASMA_REGEN "xenomorph_plasma_regen"

#define COMSIG_XENOMORPH_ZONE_SELECT "xenomorph_zone_select"
	#define COMSIG_ACCURATE_ZONE (1<<0)

#define COMSIG_XENOMORPH_POUNCE "xenomorph_pounce"

#define COMSIG_XENOMORPH_GIBBING "xenomorph_gibbing"
#define COMSIG_XENOMORPH_POSTEVOLVING "xenomorph_evolving"

#define COMSIG_XENOMORPH_GRAB "xenomorph_grab"
#define COMSIG_XENOMORPH_ATTACK_BARRICADE "xenomorph_attack_barricade"
#define COMSIG_XENOMORPH_ATTACK_CLOSET "xenomorph_attack_closet"
#define COMSIG_XENOMORPH_ATTACK_RAZORWIRE "xenomorph_attack_razorwire"
#define COMSIG_XENOMORPH_ATTACK_BED "xenomorph_attack_bed"
#define COMSIG_XENOMORPH_ATTACK_NEST "xenomorph_attack_nest"
#define COMSIG_XENOMORPH_ATTACK_TABLE "xenomorph_attack_table"
#define COMSIG_XENOMORPH_ATTACK_RACK "xenomorph_attack_rack"
#define COMSIG_XENOMORPH_ATTACK_SENTRY "xenomorph_attack_sentry"
#define COMSIG_XENOMORPH_ATTACK_M56_POST "xenomorph_attack_m56_post"
#define COMSIG_XENOMORPH_ATTACK_M56 "xenomorph_attack_m56"
#define COMSIG_XENOMORPH_ATTACK_TANK "xenomorph_attack_tank"
#define COMSIG_XENOMORPH_ATTACK_LIVING "xenomorph_attack_living"
	#define COMSIG_XENOMORPH_BONUS_APPLIED 1

#define COMSIG_XENOMORPH_ATTACK_HUMAN "xenomorph_attack_human"
#define COMSIG_XENOMORPH_DISARM_HUMAN "xenomorph_disarm_human"

#define COMSIG_XENOMORPH_THROW_HIT "xenomorph_throw_hit"

#define COMSIG_XENOMORPH_FIRE_BURNING "xenomorph_fire_burning"
#define COMSIG_XENOMORPH_TAKING_DAMAGE "xenomorph_taking_damage" // (target, damagetaken)

#define COMSIG_XENOMORPH_BRUTE_DAMAGE "xenomorph_brute_damage"
#define COMSIG_XENOMORPH_BURN_DAMAGE "xenomorph_burn_damage"

#define COMSIG_XENOMORPH_EVOLVED "xenomorph_evolved"
#define COMSIG_XENOMORPH_DEEVOLVED "xenomorph_deevolved"
#define COMSIG_XENOMORPH_WATCHXENO "xenomorph_watchxeno"

#define COMSIG_XENO_OBJ_THROW_HIT "xeno_obj_throw_hit"				///from [/mob/living/carbon/xenomorph/throw_impact]: (obj/target, speed)
#define COMSIG_XENO_NONE_THROW_HIT "xeno_none_throw_hit"			///from [/mob/living/carbon/xenomorph/throw_impact]: ()
#define COMSIG_XENO_LIVING_THROW_HIT "xeno_living_throw_hit"		///from [/mob/living/carbon/xenomorph/throw_impact]: (mob/living/target)
	#define COMPONENT_KEEP_THROWING 1

//human signals
#define COMSIG_CLICK_QUICKEQUIP "click_quickequip"

// /obj/item/radio signals
#define COMSIG_RADIO_NEW_FREQUENCY "radio_new_frequency"		//called from base of /obj/item/radio/proc/set_frequency(): (list/args)

//keybindings

#define COMSIG_KB_ACTIVATED (1<<0)
#define COMSIG_KB_ADMIN_ASAY_DOWN "keybinding_admin_asay_down"
#define COMSIG_KB_ADMIN_MSAY_DOWN "keybinding_admin_msay_down"
#define COMSIG_KB_ADMIN_DSAY_DOWN "keybinding_admin_dsay_down"
#define COMSIG_KB_CARBON_HOLDRUNMOVEINTENT_DOWN "keybinding_carbon_holdrunmoveintent_down"
#define COMSIG_KB_ADMIN_TOGGLEBUILDMODE_DOWN "keybinding_admin_togglebuildmode_down"
#define COMSIG_KB_CARBON_TOGGLETHROWMODE_DOWN "keybinding_carbon_togglethrowmode_down"
#define COMSIG_KB_CARBON_SELECTHELPINTENT_DOWN "keybinding_carbon_selecthelpintent_down"
#define COMSIG_KB_CARBON_SELECTDISARMINTENT_DOWN "keybinding_carbon_selectdisarmintent_down"
#define COMSIG_KB_CARBON_SELECTGRABINTENT_DOWN "keybinding_carbon_selectgrabintent_down"
#define COMSIG_KB_CARBON_SELECTHARMINTENT_DOWN "keybinding_carbon_selectharmintent_down"
#define COMSIG_KB_CARBON_SPECIALCLICK_DOWN "keybinding_carbon_specialclick_down"
#define COMSIG_KB_CLIENT_GETHELP_DOWN "keybinding_client_gethelp_down"
#define COMSIG_KB_CLIENT_SCREENSHOT_DOWN "keybinding_client_screenshot_down"
#define COMSIG_KB_CLIENT_MINIMALHUD_DOWN "keybinding_client_minimalhud_down"
#define COMSIG_KB_CLIENT_OOC_DOWN "keybinding_client_ooc_down"
#define COMSIG_KB_CLIENT_LOOC_DOWN "keybinding_client_looc_down"
#define COMSIG_KB_LIVING_RESIST_DOWN "keybinding_living_resist_down"
#define COMSIG_KB_MOB_FACENORTH_DOWN "keybinding_mob_facenorth_down"
#define COMSIG_KB_MOB_FACEEAST_DOWN "keybinding_mob_faceeast_down"
#define COMSIG_KB_MOB_FACESOUTH_DOWN "keybinding_mob_facesouth_down"
#define COMSIG_KB_MOB_FACEWEST_DOWN "keybinding_mob_facewest_down"
#define COMSIG_KB_MOB_STOPPULLING_DOWN "keybinding_mob_stoppulling_down"
#define COMSIG_KB_MOB_CYCLEINTENTRIGHT_DOWN "keybinding_mob_cycleintentright_down"
#define COMSIG_KB_MOB_CYCLEINTENTLEFT_DOWN "keybinding_mob_cycleintentleft_down"
#define COMSIG_KB_MOB_SWAPHANDS_DOWN "keybinding_mob_swaphands_down"
#define COMSIG_KB_MOB_SAY_DOWN "keybinding_mob_say_down"
#define COMSIG_KB_MOB_ME_DOWN "keybinding_mob_me_down"
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
#define COMSIG_KB_MOB_DASHNORTH_DOWN "keybinding_mob_dashnorth_down"
#define COMSIG_KB_MOB_DASHEAST_DOWN "keybinding_mob_dasheast_down"
#define COMSIG_KB_MOB_DASHSOUTH_DOWN "keybinding_mob_dashsouth_down"
#define COMSIG_KB_MOB_DASHWEST_DOWN "keybinding_mob_dashwest_down"

// mob keybinds
#define COMSIG_KB_HOLD_RUN_MOVE_INTENT_UP "keybinding_hold_run_move_intent_up"

// xeno abilities for keybindings

#define COMSIG_XENOABILITY_REGURGITATE "xenoability_regurgitate"
#define COMSIG_XENOABILITY_DROP_WEEDS "xenoability_drop_weeds"
#define COMSIG_XENOABILITY_CHOOSE_RESIN "xenoability_choose_resin"
#define COMSIG_XENOABILITY_SECRETE_RESIN "xenoability_secrete_resin"
#define COMSIG_XENOABILITY_EMIT_RECOVERY "xenoability_emit_recovery"
#define COMSIG_XENOABILITY_EMIT_WARDING "xenoability_emit_warding"
#define COMSIG_XENOABILITY_EMIT_FRENZY "xenoability_emit_frenzy"
#define COMSIG_XENOABILITY_TRANSFER_PLASMA "xenoability_transfer_plasma"
#define COMSIG_XENOABILITY_LARVAL_GROWTH_STING "xenoability_larval_growth_sting"
#define COMSIG_XENOABILITY_SHIFT_SPITS "xenoability_shift_spits"
#define COMSIG_XENOABILITY_CORROSIVE_ACID "xenoability_corrosive_acid"
#define COMSIG_XENOABILITY_SPRAY_ACID "xenoability_spray_acid"
#define COMSIG_XENOABILITY_XENO_SPIT "xenoability_xeno_spit"
#define COMSIG_XENOABILITY_HIDE "xenoability_hide"
#define COMSIG_XENOABILITY_NEUROTOX_STING "xenoability_neurotox_sting"

#define COMSIG_XENOABILITY_LONG_RANGE_SIGHT "xenoability_long_range_sight"
#define COMSIG_XENOABILITY_TOGGLE_BOMB "xenoability_toggle_bomb"
#define COMSIG_XENOABILITY_CREATE_BOMB "xenoability_create_bomb"
#define COMSIG_XENOABILITY_BOMBARD "xenoability_bombard"

#define COMSIG_XENOABILITY_THROW_HUGGER "xenoability_throw_hugger"
#define COMSIG_XENOABILITY_RETRIEVE_EGG "xenoability_retrieve_egg"
#define COMSIG_XENOABILITY_PLACE_TRAP "xenoability_place_trap"
#define COMSIG_XENOABILITY_SPAWN_HUGGER "xenoability_spawn_hugger"

#define COMSIG_XENOABILITY_STOMP "xenoability_stomp"
#define COMSIG_XENOABILITY_TOGGLE_CHARGE "xenoability_toggle_charge"
#define COMSIG_XENOABILITY_CRESTTOSS "xenoability_cresttoss"

#define COMSIG_XENOABILITY_BULLCHARGE "xenoability_bullcharge"
#define COMSIG_XENOABILITY_BULLHEADBUTT "xenoability_bullheadbutt"
#define COMSIG_XENOABILITY_BULLGORE "xenoability_bullgore"

#define COMSIG_XENOABILITY_HEADBUTT "xenoability_headbutt"
#define COMSIG_XENOABILITY_TAIL_SWEEP "xenoability_tail_sweep"
#define COMSIG_XENOABILITY_FORWARD_CHARGE "xenoability_forward_charge"
#define COMSIG_XENOABILITY_CREST_DEFENSE "xenoability_crest_defense"
#define COMSIG_XENOABILITY_FORTIFY "xenoability_fortify"

#define COMSIG_XENOABILITY_EMIT_NEUROGAS "xenoability_emit_neurogas"

#define COMSIG_XENOABILITY_SALVAGE_PLASMA "xenoability_salvage_plasma"

#define COMSIG_XENOABILITY_RESIN_WALKER "xenoability_resin_walker"
#define COMSIG_XENOABILITY_BUILD_TUNNEL "xenoability_build_tunnel"

#define COMSIG_XENOABILITY_TOGGLE_STEALTH "xenoability_toggle_stealth"

#define COMSIG_XENOABILITY_SCREECH "xenoability_screech"
#define COMSIG_XENOABILITY_WATCH_XENO "xenoability_watch_xeno"
#define COMSIG_XENOABILITY_PSYCHIC_WHISPER "xenoability_psychic_whisper"
#define COMSIG_XENOABILITY_TOGGLE_QUEEN_ZOOM "xenoability_toggle_queen_zoom"
#define COMSIG_XENOABILITY_XENO_LEADERS "xenoability_xeno_leaders"
#define COMSIG_XENOABILITY_QUEEN_HEAL "xenoability_queen_heal"
#define COMSIG_XENOABILITY_QUEEN_GIVE_PLASMA "xenoability_queen_give_plasma"
#define COMSIG_XENOABILITY_QUEEN_GIVE_ORDER "xenoability_queen_give_order"
#define COMSIG_XENOABILITY_DEEVOLVE "xenoability_deevolve"
#define COMSIG_XENOABILITY_QUEEN_LARVAL_GROWTH "xenoability_queen_larval_growth"

#define COMSIG_XENOABILITY_LAY_HIVEMIND "xenoability_lay_hivemind"
#define COMSIG_XENOABILITY_LAY_EGG "xenoability_lay_egg"
#define COMSIG_XENOABILITY_CALL_OF_THE_BURROWED "xenoability_call_of_the_burrowed"
#define COMSIG_XENOABILITY_PSYCHIC_FLING "xenoability_psychic_fling"
#define COMSIG_XENOABILITY_PSYCHIC_CHOKE "xenoability_psychic_choke"
#define COMSIG_XENOABILITY_PSYCHIC_CURE "xenoability_psychic_cure"
#define COMSIG_XENOABILITY_UNRELENTING_FORCE "xenoability_unrelenting_force"

#define COMSIG_XENOABILITY_RAVAGER_CHARGE "xenoability_ravager_charge"
#define COMSIG_XENOABILITY_RAVAGE "xenoability_ravage"
#define COMSIG_XENOABILITY_SECOND_WIND "xenoability_second_wind"

#define COMSIG_XENOABILITY_TOGGLE_SAVAGE "xenoability_toggle_savage"
#define COMSIG_XENOABILITY_POUNCE "xenoability_pounce"

#define COMSIG_XENOABILITY_TOGGLE_AGILITY "xenoability_toggle_agility"
#define COMSIG_XENOABILITY_LUNGE "xenoability_lunge"
#define COMSIG_XENOABILITY_FLING "xenoability_fling"
#define COMSIG_XENOABILITY_PUNCH "xenoability_punch"

// human signals for keybindings
#define COMSIG_KB_QUICKEQUIP "keybinding_quickequip"
#define COMSIG_KB_HOLSTER "keybinding_holster"
#define COMSIG_KB_UNIQUEACTION "keybinding_uniqueaction"

// Ability adding/removing signals
#define ACTION_GIVEN "gave_an_action"		//from base of /datum/action/proc/give_action(): (datum/action)
#define ACTION_REMOVED "removed_an_action"	//from base of /datum/action/proc/remove_action(): (datum/action)

// Action state signal that's sent whenever the action state has a distance maintained with the target being walked to
#define COMSIG_STATE_MAINTAINED_DISTANCE "action_state_maintained_dist_with_target"
#define COMSIG_OBSTRUCTED_MOVE "unable_to_step_towards_thing" //Tried to step in a direction and there was a obstruction

/*******Non-Signal Component Related Defines*******/

//Redirection component init flags
#define REDIRECT_TRANSFER_WITH_TURF 1


// /datum/action signals
#define COMSIG_ACTION_TRIGGER "action_trigger"                        //from base of datum/action/proc/Trigger(): (datum/action)
	#define COMPONENT_ACTION_BLOCK_TRIGGER (1<<0)
