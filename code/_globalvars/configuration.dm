GLOBAL_REAL(config, /datum/controller/configuration)

GLOBAL_DATUM(revdata, /datum/getrev)

GLOBAL_VAR(host)
GLOBAL_VAR_INIT(game_version, "TGMC")
GLOBAL_VAR_INIT(changelog_hash, "")
GLOBAL_VAR_INIT(hub_visibility, FALSE)


//This was a define, but I changed it to a variable so it can be changed in-game.(kept the all-caps definition because... code...) -Errorage
//Protecting these because the proper way to edit them is with the config/secrets
GLOBAL_VAR_INIT(MAX_EX_DEVESTATION_RANGE, 3)
GLOBAL_PROTECT(MAX_EX_DEVESTATION_RANGE)
GLOBAL_VAR_INIT(MAX_EX_HEAVY_RANGE, 7)
GLOBAL_PROTECT(MAX_EX_HEAVY_RANGE)
GLOBAL_VAR_INIT(MAX_EX_LIGHT_RANGE, 14)
GLOBAL_PROTECT(MAX_EX_LIGHT_RANGE)
GLOBAL_VAR_INIT(MAX_EX_FLASH_RANGE, 14)
GLOBAL_PROTECT(MAX_EX_FLASH_RANGE)
GLOBAL_VAR_INIT(MAX_EX_FLAME_RANGE, 14)
GLOBAL_PROTECT(MAX_EX_FLAME_RANGE)
GLOBAL_VAR_INIT(DYN_EX_SCALE, 0.5)
