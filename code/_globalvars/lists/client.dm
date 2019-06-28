GLOBAL_LIST_EMPTY(classic_keybinding_list_by_key)
GLOBAL_LIST_EMPTY(hotkey_keybinding_list_by_key)
GLOBAL_LIST_EMPTY(keybindings_by_name)

GLOBAL_VAR_INIT(external_rsc_url, TRUE)

GLOBAL_LIST_INIT(blacklisted_builds, list(
	"1428" = "bug causing right-click menus to show too many verbs that's been fixed in version 1429"))