// Damage filters for flamethrowers
#define BURN_XENOBUILDINGS (1<<0) 
#define BURN_XENOS (1<<1)
#define BURN_HUMANS (1<<2)
#define BURN_ENVIRONMENT (1<<3) // If it burns enviroment stuff like vines or snow
#define IGNITES_MOBS (1<<4)

// Shape to ignite in for the flamethrower projectile
#define SINGLE "single" // One tile, doesnt' spread
#define NO_CORNERS "NO_CORNERS" // Center tile and expanding along cardinals alone
