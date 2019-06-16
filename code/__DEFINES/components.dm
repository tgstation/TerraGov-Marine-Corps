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
#define COMSIG_TOPIC "handle_topic"                             //generic topic handler (usr, href_list)

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
#define COMSIG_ATOM_ATTACK_HAND "atom_attack_hand"				//from base of atom/attack_hand(): (mob/user)
#define COMSIG_ATOM_ATTACK_GHOST "atom_attack_ghost"			//from base of atom/attack_ghost(): (mob/dead/observer/ghost)
	#define COMPONENT_NO_ATTACK_HAND 1							//works on all attack_hands.
#define COMSIG_PARENT_EXAMINE "atom_examine"                    //from base of atom/examine(): (/mob)
#define COMSIG_ATOM_EX_ACT "atom_ex_act"						//from base of atom/ex_act(): (severity, target)

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
#define COMSIG_MOVABLE_RELEASED_FROM_STOMACH "movable_released_from_stomach" //from base of mob/living/carbon/xenomorph/proc/empty_gut(): (prey, predator)

// /turf signals
#define COMSIG_TURF_CHANGE "turf_change"						//from base of turf/ChangeTurf(): (path, list/new_baseturfs, flags, list/transferring_comps)

// /obj/item signals
#define COMSIG_ITEM_ATTACK "item_attack"						//from base of obj/item/attack(): (/mob/living/target, /mob/living/user)
#define COMSIG_ITEM_ATTACK_SELF "item_attack_self"				//from base of obj/item/attack_self(): (/mob)
	#define COMPONENT_NO_INTERACT 1
#define COMSIG_ITEM_EQUIPPED "item_equip"						//from base of obj/item/equipped(): (/mob/equipper, slot)
#define COMSIG_ITEM_DROPPED "item_drop"							//from base of obj/item/dropped(): (mob/user)
#define COMSIG_ITEM_AFTERATTACK "item_afterattack"				//from base of obj/item/afterattack(): (atom/target, mob/user, proximity_flag, click_parameters)

// /obj/item/clothing signals
#define COMSIG_SHOES_STEP_ACTION "shoes_step_action"			//from base of obj/item/clothing/shoes/proc/step_action(): ()

// /obj/item/grab signals
#define COMSIG_GRAB_SELF_ATTACK "grab_self_attack"				//from base of obj/item/grab/attack() if attacked is the same as attacker: (mob/living/user)
	#define COMSIG_GRAB_SUCCESSFUL_SELF_ATTACK (1<<0)

// /mob signals
#define COMSIG_MOB_CLICKON "mob_clickon"						//from base of mob/clickon(): (atom/A, params)
	#define COMSIG_MOB_CANCEL_CLICKON 1
#define COMSIG_MOB_ATTACK_RANGED "mob_attack_ranged"			//from base of mob/RangedAttack(): (atom/A, params)
#define COMSIG_MOB_UPDATE_SIGHT "mob_update_sight"				//from base of /mob/update_sight(): ()
#define COMSIG_MOB_HUD_CREATED "mob_hud_created"				//from base of mob/create_mob_hud(): ()
#define COMSIG_MOB_ITEM_AFTERATTACK "mob_item_afterattack"		//from base of obj/item/afterattack(): (atom/target, mob/user, proximity_flag, click_parameters)

//mob/living/carbon signals
#define COMSIG_CARBON_DEVOURED_BY_XENO "carbon_devoured_by_xeno"

// /mob/living/carbon/human signals
#define COMSIG_HUMAN_MELEE_UNARMED_ATTACK "human_melee_unarmed_attack"			//from mob/living/carbon/human/UnarmedAttack(): (atom/target)


// xeno stuff
#define COMSIG_WARRIOR_USED_GRAB "warrior_used_grab"
#define COMSIG_WARRIOR_NECKGRAB "warrior_neckgrab"
	#define COMSIG_WARRIOR_CANT_NECKGRAB 1
#define COMSIG_WARRIOR_CTRL_CLICK_ATOM "warrior_ctrl_click_atom"
	#define COMSIG_WARRIOR_USED_LUNGE 1

#define COMSIG_XENOMORPH_GIBBING "xenomorph_gibbing"

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

#define COMSIG_XENOMORPH_DISARM_HUMAN "xenomorph_disarm_human"

#define COMSIG_XENOMORPH_THROW_HIT "xenomorph_throw_hit"

#define COMSIG_XENOMORPH_FIRE_BURNING "xenomorph_fire_burning"
#define COMSIG_XENOMORPH_TAKING_DAMAGE "xenomorph_taking_damage" // (target, damagetaken)

//human signals
#define COMSIG_CLICK_QUICKEQUIP "click_quickequip"

// /obj/item/radio signals
#define COMSIG_RADIO_NEW_FREQUENCY "radio_new_frequency"		//called from base of /obj/item/radio/proc/set_frequency(): (list/args)

//keybindings

#define COMSIG_KB_ACTIVATED (1<<0)

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
#define COMSIG_XENOABILITY_BOMBARD "xenoability_bombard"

#define COMSIG_XENOABILITY_THROW_HUGGER "xenoability_throw_hugger"
#define COMSIG_XENOABILITY_RETRIEVE_EGG "xenoability_retrieve_egg"
#define COMSIG_XENOABILITY_PLACE_TRAP "xenoability_place_trap"
#define COMSIG_XENOABILITY_SPAWN_HUGGER "xenoability_spawn_hugger"

#define COMSIG_XENOABILITY_STOMP "xenoability_stomp"
#define COMSIG_XENOABILITY_TOGGLE_CHARGE "xenoability_toggle_charge"
#define COMSIG_XENOABILITY_CRESTTOSS "xenoability_cresttoss"

#define COMSIG_XENOABILITY_HEADBUTT "xenoability_headbutt"
#define COMSIG_XENOABILITY_TAIL_SWEEP "xenoability_tail_sweep"
#define COMSIG_XENOABILITY_CREST_DEFENSE "xenoability_crest_defense"
#define COMSIG_XENOABILITY_FORTIFY "xenoability_fortify"

#define COMSIG_XENOABILITY_NEUROCLAWS "xenoability_neuroclaws"
#define COMSIG_XENOABILITY_EMIT_NEUROGAS "xenoability_emit_neurogas"

#define COMSIG_XENOABILITY_SALVAGE_PLASMA "xenoability_salvage_plasma"

#define COMSIG_XENOABILITY_RESIN_WALKER "xenoability_resin_walker"
#define COMSIG_XENOABILITY_BUILD_TUNNEL "xenoability_build_tunnel"

#define COMSIG_XENOABILITY_TOGGLE_STEALTH "xenoability_toggle_stealth"

#define COMSIG_XENOABILITY_SCREECH "xenoability_screech"
#define COMSIG_XENOABILITY_GROW_OVIPOSITOR "xenoability_grow_ovipositor"
#define COMSIG_XENOABILITY_REMOVE_EGGSAC "xenoability_remove_eggsac"
#define COMSIG_XENOABILITY_WATCH_XENO "xenoability_watch_xeno"
#define COMSIG_XENOABILITY_PSYCHIC_WHISPER "xenoability_psychic_whisper"
#define COMSIG_XENOABILITY_TOGGLE_QUEEN_ZOOM "xenoability_toggle_queen_zoom"
#define COMSIG_XENOABILITY_XENO_LEADERS "xenoability_xeno_leaders"
#define COMSIG_XENOABILITY_QUEEN_HEAL "xenoability_queen_heal"
#define COMSIG_XENOABILITY_QUEEN_GIVE_PLASMA "xenoability_queen_give_plasma"
#define COMSIG_XENOABILITY_QUEEN_GIVE_ORDER "xenoability_queen_give_order"
#define COMSIG_XENOABILITY_DEEVOLVE "xenoability_deevolve"
#define COMSIG_XENOABILITY_QUEEN_LARVAL_GROWTH "xenoability_queen_larval_growth"

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

/*******Non-Signal Component Related Defines*******/

//Redirection component init flags
#define REDIRECT_TRANSFER_WITH_TURF 1
