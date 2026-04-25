//The different states possible
#define XENOS_LOSING -1
#define XENOS_DELAYING -2
#define STATE_BALANCED 0
#define MARINES_LOSING 1
#define MARINES_DELAYING 2

//The threshold to get to those state, after correction from number of players
#define XENOS_DELAYING_THRESHOLD 40
#define XENOS_LOSING_THRESHOLD 20
#define MARINES_LOSING_THRESHOLD -20
#define MARINES_DELAYING_THRESHOLD -40

//How many times we must see the same state to consider the situation a stalemate
#define STALEMATE_THRESHOLD 5

//We consider that marines are FOB hugging if 80% of them are in LZ for 3 consecutive state checks
#define PROPORTION_MARINE_FOB_HUGGING_THRESHOLD 0.8
#define CONSECUTIVE_FOb_HUGGING 3

// All different gamestates.
#define SHUTTERS_CLOSED "shutters closed"
#define GROUNDSIDE "groundside"
#define SHIPSIDE "shipside"

// Weights for state calculator related to xenomorphs.
#define PSY_STRATEGIC_POINT_WEIGHT -0.125
#define PSY_TACTICAL_POINT_WEIGHT PSY_STRATEGIC_POINT_WEIGHT * 4
#define RESIN_SILO_WEIGHT RESIN_SILO_PRICE * PSY_STRATEGIC_POINT_WEIGHT
#define EVOLUTION_TOWER_WEIGHT EVOLUTION_TOWER_PRICE * PSY_STRATEGIC_POINT_WEIGHT
#define PSYCHIC_RELAY_WEIGHT PSYCHIC_RELAY_PRICE * PSY_STRATEGIC_POINT_WEIGHT
#define PHEROMONE_TOWER_WEIGHT PHEROMONE_TOWER_PRICE * PSY_TACTICAL_POINT_WEIGHT
#define SPAWNER_WEIGHT SPAWNER_PRICE * PSY_TACTICAL_POINT_WEIGHT
#define ACID_POOL_WEIGHT ACID_POOL_PRICE * PSY_TACTICAL_POINT_WEIGHT
#define ACID_JAWS_WEIGHT ACID_JAWS_PRICE * PSY_TACTICAL_POINT_WEIGHT
#define XENO_ACID_TURRET_WEIGHT XENO_ACID_TURRET_PRICE * PSY_TACTICAL_POINT_WEIGHT
#define XENO_RESIN_TURRET_WEIGHT XENO_RESIN_TURRET_PRICE * PSY_TACTICAL_POINT_WEIGHT

#define BURROWED_LARVA_WEIGHT -20
#define MINION_XENO_LIFE_WEIGHT -20
#define T0_XENO_LIFE_WEIGHT -80
#define T1_XENO_LIFE_WEIGHT -180
#define T2_XENO_LIFE_WEIGHT -220
#define T3_XENO_LIFE_WEIGHT -240
#define T4_XENO_LIFE_WEIGHT -260
#define PRIMO_XENO_BONUS_WEIGHT -40

// Weights for the state calculator related to humans.
#define REQ_POINTS_WEIGHT 0.2
#define SHIPSIDE_HUMAN_LIFE_WEIGHT 100
#define GROUNDSIDE_HUMAN_LIFE_ON_GROUND_WEIGHT 100
#define GROUNDSIDE_HUMAN_LIFE_ON_SHIP_WEIGHT 70

//Minimum proportion of burrowed larvas compared to live xenos for the unbalance join detector to show up
#define TOO_MUCH_BURROWED_PROPORTION 0.2

///How much xeno stats (health, damage and recov) are buffed
GLOBAL_VAR_INIT(xeno_stat_multiplicator_buff, 1)

///50% is the maximum buff that xeno can receive
#define MAXIMUM_XENO_BUFF_POSSIBLE 1.5

#define MAX_SPAWNABLE_MOB_PER_PLAYER 0.15 //So for 50 players, each spawner can generate 7 mobs
#define SPAWN_RATE_PER_PLAYER 72 //For each player, the time between two consecutive spawns is reduced by 72ticks. So for 35 players, it's one mob every 30 seconds
