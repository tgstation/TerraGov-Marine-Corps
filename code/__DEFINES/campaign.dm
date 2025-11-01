///Number of victory points before a faction wins a campaign
#define CAMPAIGN_MAX_VICTORY_POINTS 7

///Respawn time in campaign mode
#define CAMPAIGN_RESPAWN_TIME 2 MINUTES

///This faction is allowed to select the next mission
#define CAMPAIGN_TEAM_MISSION_SELECT_ALLOWED (1<<0)
///This faction has already set attrition this mission
#define CAMPAIGN_TEAM_HAS_SET_ATTRITION (1<<1)

///How long after a mission ends players are returned to base
#define AFTER_MISSION_TELEPORT_DELAY 10 SECONDS
///How long after a mission ends a new leader is picked
#define AFTER_MISSION_LEADER_DELAY 1 MINUTES
///How long after a mission is selected that team balance is checked
#define CAMPAIGN_AUTOBALANCE_DELAY 1 MINUTES
///How long players get to choose to autobalance or not
#define CAMPAIGN_AUTOBALANCE_DECISION_TIME 30 SECONDS
///Standard amount of missions for a faction to have
#define CAMPAIGN_STANDARD_MISSION_QUANTITY 3
///Attrition bonus for losing
#define CAMPAIGN_LOSS_BONUS 0.15
///Max losing bonus
#define CAMPAIGN_MAX_LOSS_BONUS 0.45
///Limited loadout items can be multiplied by up to this mult, based on pop
#define CAMPAIGN_LOADOUT_MULT_MAX 3
///Pop floor to for base loadout amount
#define CAMPAIGN_LOADOUT_POP_MIN 40
///Pop required to reach max loadout mult
#define CAMPAIGN_LOADOUT_POP_MAX 100

//mission defines
///Mission has not been loaded
#define MISSION_STATE_NEW "mission state new"
///Mission loaded but not yet active
#define MISSION_STATE_LOADED "mission state loaded"
///Mission actively running
#define MISSION_STATE_ACTIVE "mission state active"
///Mission ended
#define MISSION_STATE_FINISHED "mission state finished"

#define MISSION_OUTCOME_MAJOR_VICTORY "major victory"
#define MISSION_OUTCOME_MINOR_VICTORY "minor victory"
#define MISSION_OUTCOME_DRAW "draw"
#define MISSION_OUTCOME_MINOR_LOSS "minor loss"
#define MISSION_OUTCOME_MAJOR_LOSS "major loss"

#define MISSION_STARTING_FACTION "mission_starting_faction"
#define MISSION_HOSTILE_FACTION "mission_hostile_faction"
//Attackers are usually the starting faction, but not always
#define MISSION_ATTACKING_FACTION "mission_attacking_faction"
#define MISSION_DEFENDING_FACTION "mission_defending_faction"

#define MISSION_DISALLOW_DROPPODS (1<<0)
#define MISSION_DISALLOW_MORTAR (1<<1)
#define MISSION_CRITICAL (1<<2)
#define MISSION_DISALLOW_TELEPORT (1<<3)
#define MISSION_DISALLOW_CAS (1<<4)

#define MISSION_CODE_BLUE "blue"
#define MISSION_CODE_RED "red"
#define MISSION_CODE_GREEN "green"

///Pauses campaign mission timer
#define CAMPAIGN_MISSION_TIMER_PAUSED "campaign_mission_timer_paused"

///Objective is disabled
#define CAMPAIGN_OBJECTIVE_DISABLED (1<<0)
///qdels when disabled
#define CAMPAIGN_OBJECTIVE_DEL_ON_DISABLE (1<<1)
///Explodes when disabled
#define CAMPAIGN_OBJECTIVE_EXPLODE_ON_DISABLE (1<<2)
