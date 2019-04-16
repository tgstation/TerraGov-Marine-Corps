
// Pressure limits.
#define HAZARD_HIGH_PRESSURE 550	//This determins at what pressure the ultra-high pressure red icon is displayed. (This one is set as a constant)
#define WARNING_HIGH_PRESSURE 325 	//This determins when the orange pressure icon is displayed (it is 0.7 * HAZARD_HIGH_PRESSURE)
#define WARNING_LOW_PRESSURE 50 	//This is when the gray low pressure icon is displayed. (it is 2.5 * HAZARD_LOW_PRESSURE)
#define HAZARD_LOW_PRESSURE 20		//This is when the black ultra-low pressure icon is displayed. (This one is set as a constant)

#define TEMPERATURE_DAMAGE_COEFFICIENT 1.5	//This is used in handle_temperature_damage() for humans, and in reagents that affect body temperature. Temperature damage is multiplied by this amount.

#define BODYTEMP_NORMAL 310.15		//The natural temperature for a body
#define BODYTEMP_AUTORECOVERY_DIVISOR 20 //This is the divisor which handles how much of the temperature difference between the current body temperature and 310.15K (optimal temperature) humans auto-regenerate each tick. The higher the number, the slower the recovery. This is applied each tick, so long as the mob is alive.
#define BODYTEMP_AUTORECOVERY_MINIMUM 1 //Minimum amount of kelvin moved toward 310.15K per tick. So long as abs(310.15 - bodytemp) is more than 50.
#define BODYTEMP_COLD_DIVISOR 6 //Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is lower than their body temperature. Make it lower to lose bodytemp faster.
#define BODYTEMP_HEAT_DIVISOR 6 //Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is higher than their body temperature. Make it lower to gain bodytemp faster.
#define BODYTEMP_COOLING_MAX -30 //The maximum number of degrees that your body can cool in 1 tick, when in a cold area.
#define BODYTEMP_HEATING_MAX 30 //The maximum number of degrees that your body can heat up in 1 tick, when in a hot area.

#define BODYTEMP_HEAT_DAMAGE_LIMIT_ONE		360.15 // The limit the human body can take before it starts taking damage from heat.
#define BODYTEMP_HEAT_DAMAGE_LIMIT_TWO		400.15
#define BODYTEMP_HEAT_DAMAGE_LIMIT_THREE	1000

#define BODYTEMP_COLD_DAMAGE_LIMIT_ONE		260.15 // The limit the human body can take before it starts taking damage from coldness.
#define BODYTEMP_COLD_DAMAGE_LIMIT_TWO		240.15
#define BODYTEMP_COLD_DAMAGE_LIMIT_THREE	120.15

#define PRESSURE_DAMAGE_COEFFICIENT 4 //The amount of pressure damage someone takes is equal to (pressure / HAZARD_HIGH_PRESSURE)*PRESSURE_DAMAGE_COEFFICIENT, with the maximum of MAX_PRESSURE_DAMAGE
#define MAX_HIGH_PRESSURE_DAMAGE 4	//This used to be 20... I got this much random rage for some retarded decision by polymorph?! Polymorph now lies in a pool of blood with a katana jammed in his spleen. ~Errorage --PS: The katana did less than 20 damage to him :(
#define LOW_PRESSURE_DAMAGE 2 	//The amounb of damage someone takes when in a low pressure area (The pressure threshold is so low that it doesn't make sense to do any calculations, so it just applies this flat value).


#define R_IDEAL_GAS_EQUATION	8.31 //kPa*L/(K*mol)
#define ONE_ATMOSPHERE		101.325	//kPa
#define IDEAL_GAS_ENTROPY_CONSTANT 	1164	//(mol^3 * s^3) / (kg^3 * L). Equal to (4*pi/(avrogadro's number * planck's constant)^2)^(3/2) / (avrogadro's number * 1000 Liters per m^3).


#define CELL_VOLUME 2500	//liters in a cell
#define MOLES_CELLSTANDARD (ONE_ATMOSPHERE*CELL_VOLUME/(T20C*R_IDEAL_GAS_EQUATION))	//moles in a 2.5 m^3 cell at 101.325 Pa and 20 degC

#define O2STANDARD 0.21
#define N2STANDARD 0.79


#define MIN_TOXIN_DAMAGE 1	//This and MAX_TOXIN_DAMAGE are for when a mob breathes poisonous air
#define MAX_TOXIN_DAMAGE 10	//This and MIN_TOXIN_DAMAGE are for when a mob breathes poisonous air

#define SPEED_OF_LIGHT 3e8 //not exact but hey!
#define SPEED_OF_LIGHT_SQ 9e+16
#define FIRE_DAMAGE_MODIFIER 0.0215 //Higher values result in more external fire damage to the skin (default 0.0215)
#define AIR_DAMAGE_MODIFIER 2.025 //More means less damage from hot air scalding lungs, less = more damage. (default 2.025)

#define SOUND_MINIMUM_PRESSURE 10

#define T0C 273.15					// 0degC
#define T20C 293.15					// 20degC
#define TCMB 2.7					// -270.3degC
#define ICE_COLONY_TEMPERATURE	255.15	//-18degC

#define GAS_TYPE_AIR		"air"
#define GAS_TYPE_OXYGEN		"oxygen"
#define GAS_TYPE_NITROGEN	"nitrogen"
#define GAS_TYPE_N2O		"anesthetic"
#define GAS_TYPE_PHORON		"phoron"
#define GAS_TYPE_CO2		"carbon dioxyde"

#define RADIATION_SPEED_COEFFICIENT 0.1

//PIPES
//Atmos pipe limits
#define MAX_OUTPUT_PRESSURE					4500 // (kPa) What pressure pumps and powered equipment max out at.
#define MAX_TRANSFER_RATE					200 // (L/s) Maximum speed powered equipment can work at.

//used for device_type vars
#define UNARY		1
#define BINARY 		2
#define TRINARY		3
#define QUATERNARY	4


//HEAT TRANSFER COEFFICIENTS
//Must be between 0 and 1. Values closer to 1 equalize temperature faster
//Should not exceed 0.4 else strange heat flow occur
#define WALL_HEAT_TRANSFER_COEFFICIENT		0.0
#define OPEN_HEAT_TRANSFER_COEFFICIENT		0.4
#define WINDOW_HEAT_TRANSFER_COEFFICIENT	0.1		//a hack for now

//MULTIPIPES
//IF YOU EVER CHANGE THESE CHANGE SPRITES TO MATCH.
#define PIPING_LAYER_MIN 1
#define PIPING_LAYER_MAX 3
#define PIPING_LAYER_DEFAULT 2
#define PIPING_LAYER_P_X 5
#define PIPING_LAYER_P_Y 5
#define PIPING_LAYER_LCHANGE 0.05

#define PIPING_ALL_LAYER				(1<<0)	//intended to connect with all layers, check for all instead of just one.
#define PIPING_ONE_PER_TURF				(1<<1) 	//can only be built if nothing else with this flag is on the tile already.
#define PIPING_DEFAULT_LAYER_ONLY		(1<<2)	//can only exist at PIPING_LAYER_DEFAULT
#define PIPING_CARDINAL_AUTONORMALIZE	(1<<3)	//north/south east/west doesn't matter, auto normalize on build.

//HELPERS
#define PIPING_LAYER_SHIFT(T, PipingLayer) \
	if(T.dir & (NORTH|SOUTH)) {									\
		T.pixel_x = (PipingLayer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X;\
	}																		\
	if(T.dir & (EAST|WEST)) {										\
		T.pixel_y = (PipingLayer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y;\
	}

#define PIPING_LAYER_DOUBLE_SHIFT(T, PipingLayer) \
	T.pixel_x = (PipingLayer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X;\
	T.pixel_y = (PipingLayer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y;
	