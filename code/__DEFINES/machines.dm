// channel numbers for power
#define EQUIP 1
#define LIGHT 2
#define ENVIRON 3
#define TOTAL 4	//for total power used only
#define STATIC_EQUIP 5
#define STATIC_LIGHTS 6
#define STATIC_ENVIRON 7

//Power use
#define NO_POWER_USE 0
#define IDLE_POWER_USE 1
#define ACTIVE_POWER_USE 2


//bitflags for door switches.
#define OPEN (1<<0)
#define IDSCAN (1<<1)
#define BOLTS (1<<2)
#define SHOCK (1<<3)
#define SAFE (1<<4)

//used in design to specify which machine can build it
#define IMPRINTER (1<<0)	//For circuits. Uses glass/chemicals.
#define PROTOLATHE (1<<1)	//New stuff. Uses glass/metal/chemicals
#define CRAFTLATHE (1<<2)	//Uses fuck if I know. For use eventually.
#define MECHFAB (1<<3) 	//Remember, objects utilising this flag should have construction_time and construction_cost vars.
#define BIOGENERATOR (1<<4) 	//Uses biomass
#define LIMBGROWER (1<<5) 	//Uses synthetic flesh
#define SMELTER (1<<6) 	//uses various minerals
#define NANITE_COMPILER (1<<7) //Prints nanite disks


#define FIREDOOR_OPEN 1
#define FIREDOOR_CLOSED 2


#define DOOR_NOT_FORCED 0
#define DOOR_FORCED_NORMAL 1


//Cables directions and helping
#define CABLE_NODE 0


#define UP_OR_DOWN 16

#define MACHINE_NOT_ELECTRIFIED 0
#define MACHINE_ELECTRIFIED_PERMANENT -1
#define MACHINE_DEFAULT_ELECTRIFY_TIME 30


#define TURRET_SAFETY (1<<0)
#define TURRET_LOCKED (1<<1)
#define TURRET_ON (1<<2)
#define TURRET_HAS_CAMERA (1<<3)
#define TURRET_ALERTS (1<<4)
#define TURRET_RADIAL (1<<5)
#define TURRET_IMMOBILE (1<<6)
#define TURRET_INACCURATE (1<<7)

#define SQUAD_LOCK (1<<0)
#define JOB_LOCK (1<<1)
