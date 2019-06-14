// Helpers for checking whether a z-level conforms to a specific requirement

// Basic levels
#define is_centcom_level(z) SSmapping.level_trait(z, ZTRAIT_CENTCOM)

#define is_station_level(z) SSmapping.level_trait(z, ZTRAIT_STATION)

#define is_ground_level(z) SSmapping.level_trait(z, ZTRAIT_GROUND)

#define is_mainship_level(z) SSmapping.level_trait(z, ZTRAIT_MARINE_MAIN_SHIP)

#define is_mining_level(z) SSmapping.level_trait(z, ZTRAIT_MINING)

#define is_reebe(z) SSmapping.level_trait(z, ZTRAIT_REEBE)

#define is_reserved_level(z) SSmapping.level_trait(z, ZTRAIT_RESERVED)

#define is_away_level(z) SSmapping.level_trait(z, ZTRAIT_AWAY)

#define is_gameplay_level(z) SSmapping.level_trait(z, ZTRAIT_MARINE_MAIN_SHIP) || SSmapping.level_trait(z, ZTRAIT_GROUND)
