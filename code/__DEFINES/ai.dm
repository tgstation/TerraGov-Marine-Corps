///The AI component has finished moving towards a node, change the state because of that certain thing happening
#define REASON_FINISHED_NODE_MOVE "finished_moving_to_node"

///Signal that's sent whenever the AI component kills off it's current target, this triggers a state change which could then go into a "patrol" or decide to attack another nearby target
#define REASON_TARGET_KILLED "recently_killed_a_target"

///AI component spotted a valid target and wants to attack it
#define REASON_TARGET_SPOTTED "spotted_a_target_attacking_with_favorable conditions"

///Repick targets every so often so we don't get stuck on a single thing forever
#define REASON_REFRESH_TARGET "picking_a_new_target_while_having_a_target"

///AI component state where it's moving towards a node
#define MOVING_TO_NODE "moving_to_a_node" //Move to a node

///AI component state where we're escorting something and looking for a target nearby
#define ESCORTING_ATOM "escorting_atom"

///AI component state where we're moving towards *something*, probably something we want to hit
#define MOVING_TO_ATOM "moving_to_an_atom"

///Ai component state where the ai tries to flee to heal
#define MOVING_TO_SAFETY "moving_to_safety"

///Ai component state where the ai just does nothing
#define IDLE "idle"

///Ai component state where the ai is following a tile path
#define FOLLOWING_PATH "following path"

///A define for a node variable which is the last world.time that a AI visited it
#define NODE_LAST_VISITED "node_last_visited"

/**
 * Identifier tags
 * Ultilized for having AI look at weights based on if they're a "marine human" or a "xenomorph" or something else
 * This is mainly used for deciding what weights are to be looked at when determing a node waypoint of going towards
 */
#define IDENTIFIER_XENO "identifies_xeno"
#define IDENTIFIER_ZOMBIE "identifies_zombie"
#define IDENTIFIER_HUMAN "identifies_human"


//Flags for the get_nearest_target
#define TARGET_HUMAN_TURRETS (1<<0)
#define TARGET_XENO_TURRETS (1<<1)
#define TARGET_HUMAN (1<<2)
#define TARGET_XENO (1<<3)
#define TARGET_UNMANNED_VEHICLE (1<<4)
#define TARGET_FRIENDLY_XENO (1<<5)
#define TARGET_FRIENDLY_MOB (1<<6)
///Tanks and mechs
#define TARGET_VEHICLE (1<<7)
#define TARGET_HOSTILE (ALL &~ (TARGET_FRIENDLY_XENO|TARGET_FRIENDLY_MOB))

#define MAX_NODE_RANGE 15
#define PATHFINDER_MAX_TRIES 200
///NPC's will try this many times to path to a goal before ignoring it
#define AI_MAX_GOAL_PATH_FAILS 10

///The AI will maintain a combat target within this range, even without LOS
#define AI_COMBAT_TARGET_BLIND_DISTANCE 4 //required since byond LOS is not the same as true LOS, but also since either can be easily broken by stepping behind a corner etc

//AI will escort an ATOM up to this distance away from them
#define AI_ESCORTING_MAX_DISTANCE 10
///AI will give up escorting something beyond this distance
#define AI_ESCORTING_BREAK_DISTANCE 20

#define AI_ESCORT_RATING_FACTION_GOAL 10
#define AI_ESCORT_RATING_SQUAD_LEAD 13
#define AI_ESCORT_RATING_CLOSE_FRIENDLY 15
#define AI_ESCORT_RATING_BUDDY 16

GLOBAL_LIST_EMPTY(all_nodes)

///A GLOB of all /datum/component/ai_controller that currently exist
GLOBAL_LIST_EMPTY(ai_instances_active)

//To be implemented in later updates
GLOBAL_LIST_EMPTY(nodes_with_enemies)
GLOBAL_LIST_EMPTY(nodes_with_construction)
#define can_cross_lava_turf(turf_to_check) (!islava(turf_to_check) || turf_to_check.is_covered())

///Obstacle needs attacking
#define AI_OBSTACLE_ATTACK "ai_obstacle_attack"
///Obstacle can be jumped
#define AI_OBSTACLE_JUMP "ai_obstacle_jump"
///Obstacle can't be resolved, and is friendly so shouldn't be destroyed
#define AI_OBSTACLE_FRIENDLY "ai_obstacle_friendly"
///Obstacle has already been handled
#define AI_OBSTACLE_RESOLVED "ai_obstacle_resolved"
///Obstacle can be ignored
#define AI_OBSTACLE_IGNORED "ai_obstacle_ignored"

///If the mob parent can heal itself and so should flee
#define HUMAN_AI_SELF_HEAL (1<<0)
///Uses weapons
#define HUMAN_AI_USE_WEAPONS (1<<1)
///Listens to audible instructions
#define HUMAN_AI_AUDIBLE_CONTROL (1<<2)
///Will try avoid FF when possible
#define HUMAN_AI_NO_FF (1<<3)
///Will try avoid hazards when possible
#define HUMAN_AI_AVOID_HAZARDS (1<<4)

///Currently shooting
#define HUMAN_AI_FIRING (1<<0)
///Looking for weapons
#define HUMAN_AI_NEED_WEAPONS (1<<1)
///Healing or being healed
#define HUMAN_AI_HEALING (1<<2)
///Healing self
#define HUMAN_AI_SELF_HEALING (1<<3)
///Building something
#define HUMAN_AI_BUILDING (1<<4)

///Any action that we generally don't want to interrupt
#define HUMAN_AI_BUSY_ACTION (HUMAN_AI_HEALING|HUMAN_AI_SELF_HEALING|HUMAN_AI_BUILDING)

///We're good to shoot
#define AI_FIRE_CAN_HIT (1<<0)
///Invalid due to being deleted or something else strange
#define AI_FIRE_INVALID_TARGET (1<<1)
///Need ammo
#define AI_FIRE_NO_AMMO (1<<2)
///Out of range
#define AI_FIRE_OUT_OF_RANGE (1<<3)
///No line of sight
#define AI_FIRE_NO_LOS (1<<4)
///Friendly in the way
#define AI_FIRE_FRIENDLY_BLOCKED (1<<5)
///Target already dead
#define AI_FIRE_TARGET_DEAD (1<<6)

//Mob medic level
///Don't help anyone else
#define AI_MED_SELFISH 0
///Tries to inap crit friends
#define AI_MED_DEFAULT 1
///Tries to heal whenver possible
#define AI_MED_MEDIC 2
///Prioritises healing above combat
#define AI_MED_DOCTOR 3

//Mob engineer level
///Don't do engineering
#define AI_ENGIE_DEFAULT 0
///Basic tasks
#define AI_ENGIE_BASIC 1
///Engineer level
#define AI_ENGIE_STANDARD 2
///Dedicated engineer
#define AI_ENGIE_EXPERT 3

GLOBAL_LIST_INIT(ai_brute_heal_items, list(
	/obj/item/reagent_containers/pill/bicaridine,
	/obj/item/reagent_containers/hypospray/autoinjector/bicaridine,
	/obj/item/reagent_containers/hypospray/advanced/bicaridine,
	/obj/item/reagent_containers/hypospray/autoinjector/combat,
	/obj/item/reagent_containers/pill/tricordrazine,
	/obj/item/reagent_containers/hypospray/advanced/tricordrazine,
	/obj/item/reagent_containers/hypospray/advanced/combat_advanced,
	/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced,
	/obj/item/reagent_containers/pill/meralyne,
	/obj/item/reagent_containers/hypospray/advanced/meralyne,
	/obj/item/reagent_containers/hypospray/advanced/meraderm,
	/obj/item/reagent_containers/hypospray/autoinjector/neuraline,
	/obj/item/reagent_containers/hypospray/autoinjector/russian_red,
	/obj/item/reagent_containers/hypospray/autoinjector/elite,
	/obj/item/stack/medical/heal_pack/gauze/sectoid,
	/obj/item/stack/medical/heal_pack/advanced/bruise_pack,
	/obj/item/stack/medical/heal_pack/gauze,
))

GLOBAL_LIST_INIT(ai_burn_heal_items, list(
	/obj/item/reagent_containers/pill/kelotane,
	/obj/item/reagent_containers/hypospray/autoinjector/kelotane,
	/obj/item/reagent_containers/hypospray/advanced/kelotane,
	/obj/item/reagent_containers/hypospray/autoinjector/combat,
	/obj/item/reagent_containers/pill/tricordrazine,
	/obj/item/reagent_containers/hypospray/advanced/tricordrazine,
	/obj/item/reagent_containers/hypospray/advanced/combat_advanced,
	/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced,
	/obj/item/reagent_containers/pill/dermaline,
	/obj/item/reagent_containers/hypospray/advanced/dermaline,
	/obj/item/reagent_containers/hypospray/advanced/meraderm,
	/obj/item/reagent_containers/hypospray/autoinjector/neuraline,
	/obj/item/reagent_containers/hypospray/autoinjector/russian_red,
	/obj/item/reagent_containers/hypospray/autoinjector/elite,
	/obj/item/stack/medical/heal_pack/gauze/sectoid,
	/obj/item/stack/medical/heal_pack/advanced/burn_pack,
	/obj/item/stack/medical/heal_pack/ointment,
))

GLOBAL_LIST_INIT(ai_tox_heal_items, list(
	/obj/item/reagent_containers/hypospray/autoinjector/antitox_mix,
	/obj/item/reagent_containers/pill/dylovene,
	/obj/item/reagent_containers/hypospray/advanced/dylovene,
	/obj/item/reagent_containers/hypospray/autoinjector/dylovene,
	/obj/item/reagent_containers/pill/tricordrazine,
	/obj/item/reagent_containers/hypospray/advanced/tricordrazine,
))

GLOBAL_LIST_INIT(ai_oxy_heal_items, list(
	/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline,
	/obj/item/reagent_containers/hypospray/advanced/inaprovaline,
	/obj/item/reagent_containers/pill/inaprovaline,
	/obj/item/reagent_containers/hypospray/autoinjector/neuraline,
	/obj/item/reagent_containers/hypospray/autoinjector/russian_red,
	/obj/item/reagent_containers/hypospray/autoinjector/elite,
	/obj/item/reagent_containers/pill/tricordrazine,
	/obj/item/reagent_containers/hypospray/advanced/tricordrazine,
))

GLOBAL_LIST_INIT(ai_clone_heal_items, list(
	/obj/item/reagent_containers/hypospray/autoinjector/rezadone,
	/obj/item/reagent_containers/hypospray/autoinjector/elite,
))

GLOBAL_LIST_INIT(ai_pain_heal_items, list(
	/obj/item/reagent_containers/pill/tramadol,
	/obj/item/reagent_containers/hypospray/autoinjector/tramadol,
	/obj/item/reagent_containers/hypospray/advanced/tramadol,
	/obj/item/reagent_containers/hypospray/autoinjector/combat,
	/obj/item/reagent_containers/hypospray/advanced/oxycodone,
	/obj/item/reagent_containers/hypospray/autoinjector/oxycodone,
	/obj/item/reagent_containers/hypospray/advanced/combat_advanced,
	/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced,
	/obj/item/reagent_containers/hypospray/autoinjector/neuraline,
	/obj/item/reagent_containers/hypospray/autoinjector/russian_red,
	/obj/item/reagent_containers/hypospray/autoinjector/elite,
))

GLOBAL_LIST_INIT(ai_eye_heal_items, list(
	/obj/item/reagent_containers/hypospray/advanced/imialky,
	/obj/item/reagent_containers/pill/imidazoline,
	/obj/item/reagent_containers/hypospray/autoinjector/imidazoline,
))

GLOBAL_LIST_INIT(ai_brain_heal_items, list(
	/obj/item/reagent_containers/hypospray/advanced/imialky,
	/obj/item/reagent_containers/pill/alkysine,
	/obj/item/reagent_containers/hypospray/autoinjector/alkysine,
))

GLOBAL_LIST_INIT(ai_ib_heal_items, list(
	/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus,
	/obj/item/reagent_containers/hypospray/advanced/quickclotplus,
	/obj/item/reagent_containers/hypospray/advanced/quickclotplus_medkit,
	/obj/item/reagent_containers/hypospray/advanced/big/quickclot,
	/obj/item/reagent_containers/hypospray/autoinjector/quickclot,
	/obj/item/reagent_containers/pill/quickclot,
))

GLOBAL_LIST_INIT(ai_organ_heal_items, list(
	/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus,
	/obj/item/reagent_containers/hypospray/advanced/peridaxonplus,
	/obj/item/reagent_containers/hypospray/advanced/peridaxonplus_medkit,
))

GLOBAL_LIST_INIT(ai_infection_heal_items, list(
	/obj/item/reagent_containers/hypospray/advanced/big/spaceacillin,
	/obj/item/reagent_containers/hypospray/autoinjector/spaceacillin,
	/obj/item/reagent_containers/pill/spaceacillin,
))

///List of squads that can be spawned, and the roles in them, sorted in spawn order
GLOBAL_LIST_INIT(ai_squad_presets, list(
	"SOM breachers" = list(
		/datum/job/som/ert/breacher,
		/datum/job/som/ert/breacher,
		/datum/job/som/ert/leader/breacher,
		/datum/job/som/ert/medic/breacher,
		/datum/job/som/ert/breacher/specialist,
		/datum/job/som/ert/breacher,
		/datum/job/som/ert/breacher,
		/datum/job/som/ert/breacher/specialist,
		/datum/job/som/ert/breacher,
		/datum/job/som/ert/breacher,
	),
	"SOM squad" = list(
		/datum/job/som/ert/standard,
		/datum/job/som/ert/standard,
		/datum/job/som/ert/leader,
		/datum/job/som/ert/medic,
		/datum/job/som/ert/veteran,
		/datum/job/som/ert/standard,
		/datum/job/som/ert/specialist,
		/datum/job/som/ert/veteran,
		/datum/job/som/ert/standard,
		/datum/job/som/ert/specialist,
	),
	"PMC squad" = list(
		/datum/job/pmc/standard,
		/datum/job/pmc/standard,
		/datum/job/pmc/leader,
		/datum/job/pmc/gunner,
		/datum/job/pmc/standard,
		/datum/job/pmc/standard,
		/datum/job/pmc/gunner,
		/datum/job/pmc/standard,
		/datum/job/pmc/standard,
		/datum/job/pmc/gunner,
	),
	"ICC squad" = list(
		/datum/job/icc/standard,
		/datum/job/icc/standard,
		/datum/job/icc/leader,
		/datum/job/icc/medic,
		/datum/job/icc/guard,
		/datum/job/icc/standard,
		/datum/job/icc/standard,
		/datum/job/icc/guard,
		/datum/job/icc/standard,
		/datum/job/icc/guard,
	),
	"CLF squad" = list(
		/datum/job/clf/standard,
		/datum/job/clf/standard,
		/datum/job/clf/leader,
		/datum/job/clf/medic,
		/datum/job/clf/specialist,
		/datum/job/clf/standard,
		/datum/job/clf/standard,
		/datum/job/clf/specialist,
		/datum/job/clf/standard,
		/datum/job/clf/standard,
	),
	"Spec op squad" = list(
		/datum/job/special_forces/standard,
		/datum/job/special_forces/standard,
		/datum/job/special_forces/leader,
		/datum/job/special_forces/medic,
		/datum/job/special_forces/breacher,
		/datum/job/special_forces/standard,
		/datum/job/special_forces/standard,
		/datum/job/special_forces/breacher,
		/datum/job/special_forces/standard,
		/datum/job/special_forces/breacher,
	),
	"TGMC" = list(
		/datum/job/terragov/squad/standard/npc,
		/datum/job/terragov/squad/standard/npc,
		/datum/job/terragov/squad/leader/npc,
		/datum/job/terragov/squad/corpsman/npc,
		/datum/job/terragov/squad/smartgunner/npc,
		/datum/job/terragov/squad/standard/npc,
		/datum/job/terragov/squad/standard/npc,
		/datum/job/terragov/squad/smartgunner/npc,
		/datum/job/terragov/squad/standard/npc,
		/datum/job/terragov/squad/smartgunner/npc,
	),
))
