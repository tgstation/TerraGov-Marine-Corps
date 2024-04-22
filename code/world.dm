//This file is just for the necessary /world definition
//Try looking in game/world.dm

/**
  * # WorldR
  *
  * Two possibilities exist: either we are alone in the Universe or we are not. Both are equally terrifying. ~ Arthur C. Clarke
  *
  * The byond world object stores some basic byond level config, and has a few hub specific procs for managing hub visiblity
  *
  * The world /New() is the root of where a round itself begins
  */
/world
	mob = /mob/dead/new_player
	turf = /turf/closed
	area = /area/rogue
	view = "15x15"
	hub = "Exadv1.spacestation13"
#ifdef ROGUEWORLD
	name = "BLACKSTONE"
#else
	name = "BLACKSTONE"
#endif
	fps = 20
#ifdef FIND_REF_NO_CHECK_TICK
	loop_checks = FALSE
#endif
