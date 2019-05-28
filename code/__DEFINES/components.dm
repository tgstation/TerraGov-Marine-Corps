#define SEND_SIGNAL(target, sigtype, arguments...) ( !target.comp_lookup || !target.comp_lookup[sigtype] ? NONE : target._SendSignal(sigtype, list(target, ##arguments)) )

#define SEND_GLOBAL_SIGNAL(sigtype, arguments...) ( SEND_SIGNAL(SSdcs, sigtype, ##arguments) )

//shorthand
#define GET_COMPONENT_FROM(varname, path, target) var##path/##varname = ##target.GetComponent(##path)
#define GET_COMPONENT(varname, path) GET_COMPONENT_FROM(varname, path, src)

#define COMPONENT_INCOMPATIBLE 1
#define COMPONENT_NOTRANSFER 2

// How multiple components of the exact same type are handled in the same datum

#define COMPONENT_DUPE_HIGHLANDER		0		//old component is deleted (default)
#define COMPONENT_DUPE_ALLOWED			1	//duplicates allowed
#define COMPONENT_DUPE_UNIQUE			2	//new component is deleted
#define COMPONENT_DUPE_UNIQUE_PASSARGS	4	//old component is given the initialization args of the new

// All signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /datum signals
#define COMSIG_COMPONENT_ADDED "component_added"				//when a component is added to a datum: (/datum/component)
#define COMSIG_COMPONENT_REMOVING "component_removing"			//before a component is removed from a datum because of RemoveComponent: (/datum/component)
#define COMSIG_PARENT_PREQDELETED "parent_preqdeleted"			//before a datum's Destroy() is called: (force), returning a nonzero value will cancel the qdel operation
#define COMSIG_PARENT_QDELETED "parent_qdeleted"				//after a datum's Destroy() is called: (force, qdel_hint), at this point none of the other components chose to interrupt qdel and Destroy has been called

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


// /atom signals
#define COMSIG_PARENT_ATTACKBY "atom_attackby"			        //from base of atom/attackby(): (/obj/item, /mob/living)
	#define COMPONENT_NO_AFTERATTACK 1								//Return this in response if you don't want afterattack to be called
#define COMSIG_ATOM_ENTERED "atom_entered"                      //from base of atom/Entered(): (atom/movable/entering, /atom)
#define COMSIG_ATOM_EXIT "atom_exit"							//from base of atom/Exit(): (/atom/movable/exiting, /atom/newloc)
	#define COMPONENT_ATOM_BLOCK_EXIT 1
#define COMSIG_ATOM_EXITED "atom_exited"						//from base of atom/Exited(): (atom/movable/exiting, atom/newloc)
#define COMSIG_ATOM_DIR_CHANGE "atom_dir_change"				//from base of atom/setDir(): (old_dir, new_dir)
#define COMSIG_ATOM_CANREACH "atom_can_reach"					//from internal loop in atom/movable/proc/CanReach(): (list/next)
	#define COMPONENT_BLOCK_REACH 1
#define COMSIG_ATOM_SCREWDRIVER_ACT "atom_screwdriver_act"		//from base of atom/screwdriver_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_ATTACK_GHOST "atom_attack_ghost"			//from base of atom/attack_ghost(): (mob/dead/observer/ghost)
	#define COMPONENT_NO_ATTACK_HAND 1							//works on all 3.

// /atom/movable signals
#define COMSIG_MOVABLE_PRE_MOVE "movable_pre_move"					//from base of atom/movable/Moved(): (/atom)
#define COMSIG_MOVABLE_MOVED "movable_moved"					//from base of atom/movable/Moved(): (/atom, dir)
#define COMSIG_MOVABLE_CROSSED "movable_crossed"                //from base of atom/movable/Crossed(): (/atom/movable)
#define COMSIG_MOVABLE_BUMP "movable_bump"						//from base of atom/movable/Bump(): (/atom)
#define COMSIG_MOVABLE_IMPACT "movable_impact"					//from base of atom/movable/throw_impact(): (/atom/hit_atom)
#define COMSIG_MOVABLE_DISPOSING "movable_disposing"			//called when the movable is added to a disposal holder object for disposal movement: (obj/structure/disposalholder/holder, obj/machinery/disposal/source)
#define COMSIG_MOVABLE_HEAR "movable_hear"						//from base of atom/movable/Hear(): (message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
#define COMSIG_MOVABLE_Z_CHANGED "movable_ztransit" 			//from base of atom/movable/onTransitZ(): (old_z, new_z)
#define COMSIG_MOVABLE_CROSS "movable_cross"					//from base of atom/movable/Cross(): (/atom/movable)
#define COMSIG_MOVABLE_UNCROSS "movable_uncross"				//from base of atom/movable/Uncross(): (/atom/movable)
	#define COMPONENT_MOVABLE_BLOCK_UNCROSS 1
#define COMSIG_MOVABLE_UNCROSSED "movable_uncrossed"            //from base of atom/movable/Uncrossed(): (/atom/movable)

// /obj/item signals
#define COMSIG_ITEM_ATTACK "item_attack"						//from base of obj/item/attack(): (/mob/living/target, /mob/living/user)
#define COMSIG_ITEM_ATTACK_SELF "item_attack_self"				//from base of obj/item/attack_self(): (/mob)
	#define COMPONENT_NO_INTERACT 1
#define COMSIG_ITEM_EQUIPPED "item_equip"						//from base of obj/item/equipped(): (/mob/equipper, slot)
#define COMSIG_ITEM_DROPPED "item_drop"							//from base of obj/item/dropped(): (mob/user)

// /obj/item/clothing signals
#define COMSIG_SHOES_STEP_ACTION "shoes_step_action"			//from base of obj/item/clothing/shoes/proc/step_action(): ()


// /mob signals
#define COMSIG_MOB_CLICKON "mob_clickon"						//from base of mob/clickon(): (atom/A, params)
	#define COMSIG_MOB_CANCEL_CLICKON 1
#define COMSIG_MOB_ATTACK_RANGED "mob_attack_ranged"			//from base of mob/RangedAttack(): (atom/A, params)
#define COMSIG_MOB_UPDATE_SIGHT "mob_update_sight"				//from base of /mob/update_sight(): ()

// xeno stuff
#define COMSIG_WARRIOR_USED_GRAB "warrior_used_grab"
#define COMSIG_WARRIOR_NECKGRAB "warrior_neckgrab"
	#define COMSIG_WARRIOR_CANT_NECKGRAB 1
#define COMSIG_WARRIOR_CTRL_CLICK_ATOM "warrior_ctrl_click_atom"
	#define COMSIG_WARRIOR_USED_LUNGE 1

#define COMSIG_XENOMORPH_GIBBING "xenomorph_gibbing"

// /obj/item/radio signals
#define COMSIG_RADIO_NEW_FREQUENCY "radio_new_frequency"		//called from base of /obj/item/radio/proc/set_frequency(): (list/args)

// xeno abilities for keybindings
#define COMSIG_XENOABILITY_HAS_ABILITY 1

#define COMSIG_XENOABILITY_REGURGITATE "xenoability_regurgitate"
#define COMSIG_XENOABILITY_DROP_WEEDS "xenoability_drop_weeds"
#define COMSIG_XENOABILITY_CHOOSE_RESIN "xenoability_choose_resin"
#define COMSIG_XENOABILITY_SECRETE_RESIN "xenoability_secrete_resin"
#define COMSIG_XENOABILITY_EMIT_RECOVERY "xenoability_emit_recovery"
#define COMSIG_XENOABILITY_EMIT_WARDING "xenoability_emit_warding"
#define COMSIG_XENOABILITY_EMIT_FRENZY "xenoability_emit_frenzy"
#define COMSIG_XENOABILITY_TRANSFER_PLASMA "xenoability_transfer_plasma"

#define COMSIG_XENOABILITY_LONG_RANGE_SIGHT "xenoability_long_range_sight"
COMSIG_XENOABILITY_TOGGLE_BOMB
COMSIG_XENOABILITY_BOMBARD

COMSIG_XENOABILITY_THROW_HUGGER
COMSIG_XENOABILITY_RETRIEVE_EGG
COMSIG_XENOABILITY_PLACE_TRAP
COMSIG_XENOABILITY_SPAWN_HUGGER

COMSIG_XENOABILITY_STOMP
COMSIG_XENOABILITY_TOGGLE_CHARGE
COMSIG_XENOABILITY_CRESTTOSS

COMSIG_XENOABILITY_HEADBUTT
#define COMSIG_XENOABILITY_TAIL_SWEEP "xenoability_tail_sweep"
COMSIG_XENOABILITY_CREST_DEFENSE
COMSIG_XENOABILITY_FORTIFY

COMSIG_XENOABILITY_NEUROCLAWS
COMSIG_XENOABILITY_EMIT_NEUROGAS

COMSIG_XENOABILITY_SALVAGE_PLASMA

COMSIG_XENOABILITY_RESIN_WALKER
COMSIG_XENOABILITY_BUILD_TUNNEL

COMSIG_XENOABILITY_TOGGLE_STEALTH

COMSIG_XENOABILITY_SCREECH
COMSIG_XENOABILITY_GROW_OVIPOSITOR
COMSIG_XENOABILITY_REMOVE_EGGSAC
COMSIG_XENOABILITY_WATCH_XENO
COMSIG_XENOABILITY_PSYCHIC_WHISPER
COMSIG_XENOABILITY_TOGGLE_QUEEN_ZOOM
COMSIG_XENOABILITY_XENO_LEADERS
COMSIG_XENOABILITY_QUEEN_HEAL
COMSIG_XENOABILITY_QUEEN_GIVE_PLASMA
COMSIG_XENOABILITY_QUEEN_GIVE_ORDER
COMSIG_XENOABILITY_DEEVOLVE
COMSIG_XENOABILITY_QUEEN_LARVAL_GROWTH

COMSIG_XENOABILITY_RAVAGER_CHARGE
COMSIG_XENOABILITY_RAVAGE
COMSIG_XENOABILITY_SECOND_WIND

COMSIG_XENOABILITY_TOGGLE_SAVAGE
COMSIG_XENOABILITY_POUNCE

COMSIG_XENOABILITY_TOGGLE_AGILITY
COMSIG_XENOABILITY_LUNGE
COMSIG_XENOABILITY_FLING

