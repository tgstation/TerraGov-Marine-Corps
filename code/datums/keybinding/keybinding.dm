/datum/keybinding
    var/key
    var/name
    var/full_name
    var/description = ""
    var/category = CATEGORY_MISC
    var/weight = WEIGHT_LOWEST
    var/keybind_signal

/datum/keybinding/proc/down(client/user)
    return FALSE
    
/datum/keybinding/proc/up(client/user)
    return FALSE
