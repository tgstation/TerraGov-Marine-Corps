GLOBAL_VAR_INIT(ooc_allowed, TRUE)
GLOBAL_VAR_INIT(dooc_allowed, TRUE)
GLOBAL_VAR_INIT(dsay_allowed, TRUE)
GLOBAL_VAR_INIT(enter_allowed, TRUE)
GLOBAL_VAR_INIT(aliens_allowed, TRUE)
GLOBAL_VAR_INIT(guests_allowed, FALSE)
GLOBAL_VAR_INIT(respawn_allowed, FALSE)

GLOBAL_VAR_INIT(respawntime, 5 MINUTES)
GLOBAL_VAR_INIT(fileaccess_timer, 0)

GLOBAL_VAR_INIT(custom_info, "")
GLOBAL_VAR_INIT(motd, "")

GLOBAL_LIST_EMPTY(custom_outfits)

GLOBAL_LIST_EMPTY(admin_datums)
GLOBAL_PROTECT(admin_datums)
GLOBAL_LIST_EMPTY(protected_admins)
GLOBAL_PROTECT(protected_admins)

GLOBAL_VAR_INIT(href_token, GenerateToken())
GLOBAL_PROTECT(href_token)

GLOBAL_LIST_EMPTY(admin_ranks)
GLOBAL_PROTECT(admin_ranks)

GLOBAL_LIST_EMPTY(protected_ranks)
GLOBAL_PROTECT(protected_ranks)