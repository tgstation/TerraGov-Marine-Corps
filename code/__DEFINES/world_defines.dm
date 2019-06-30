GLOBAL_VAR(restart_counter)
//TODO: Replace INFINITY with the version that fixes http://www.byond.com/forum/?post=2407430
GLOBAL_VAR_INIT(bypass_tgs_reboot, world.system_type == UNIX && world.byond_build < INFINITY)
