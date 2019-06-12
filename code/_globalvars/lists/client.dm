GLOBAL_LIST_EMPTY(keybinding_list_by_key)
GLOBAL_LIST_EMPTY(keybindings_by_name)

GLOBAL_VAR_INIT(external_rsc_url, TRUE)

GLOBAL_LIST_INIT(blacklisted_builds, list(
	"1407" = "bug preventing client display overrides from working leads to clients being able to see things/mobs they shouldn't be able to see",
	"1408" = "bug preventing client display overrides from working leads to clients being able to see things/mobs they shouldn't be able to see",
	"1428" = "bug causing right-click menus to show too many verbs that's been fixed in version 1429"))