//This datum holds statistic that are needed for the state calculation and are not stored anywhere else
GLOBAL_DATUM_INIT(monitor_statistics, /datum/monitor_statistics, new)

/datum/monitor_statistics
    var/Ancient_Queen = 0
    var/Elder_Queen = 0
    var/Ancient_T3 = 0
    var/Elder_T3 = 0
    var/Ancient_T2 = 0
    var/Elder_T2 = 0
    var/list/Miniguns_in_use = new() 
    var/list/SADAR_in_use = new() 
    var/list/B18_in_use = new()
    var/list/B17_in_use = new()
    var/OB_available = 0