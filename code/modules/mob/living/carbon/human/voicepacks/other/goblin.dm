/datum/voicepack/goblin/get_sound(soundin, modifiers)
	var/used
	switch(soundin)
		if("laugh")
			used = pick('sound/vo/mobs/gob/laugh (1).ogg','sound/vo/mobs/gob/laugh (2).ogg')
		if("aggro")
			used = pick('sound/vo/mobs/gob/aggro (1).ogg','sound/vo/mobs/gob/aggro (2).ogg','sound/vo/mobs/gob/aggro (3).ogg','sound/vo/mobs/gob/aggro (4).ogg')
		if("deathgurgle")
			used = pick('sound/vo/mobs/gob/death (1).ogg','sound/vo/mobs/gob/death (2).ogg')
		if("idle")
			used = pick('sound/vo/mobs/gob/idle (1).ogg','sound/vo/mobs/gob/idle (2).ogg','sound/vo/mobs/gob/idle (3).ogg','sound/vo/mobs/gob/idle (4).ogg','sound/vo/mobs/gob/idle (5).ogg')
		if("pain")
			used = pick('sound/vo/mobs/gob/pain (1).ogg','sound/vo/mobs/gob/pain (2).ogg','sound/vo/mobs/gob/pain (3).ogg','sound/vo/mobs/gob/pain (4).ogg','sound/vo/mobs/gob/pain (5).ogg')
		if("paincrit")
			used = pick('sound/vo/mobs/gob/pain (1).ogg','sound/vo/mobs/gob/pain (2).ogg','sound/vo/mobs/gob/pain (3).ogg','sound/vo/mobs/gob/pain (4).ogg','sound/vo/mobs/gob/pain (5).ogg')
		if("painscream")
			used = pick('sound/vo/mobs/gob/painscream (1).ogg','sound/vo/mobs/gob/painscream (2).ogg','sound/vo/mobs/gob/painscream (3).ogg','sound/vo/mobs/gob/painscream (4).ogg','sound/vo/mobs/gob/painscream (5).ogg')

	return used