/datum/voicepack/male/knight/get_sound(soundin, modifiers)
	var/used
	switch(soundin)
		if("agony")
			used = list('sound/vo/male/knight/agony (1).ogg','sound/vo/male/knight/agony (2).ogg','sound/vo/male/knight/agony (3).ogg')
		if("firescream")
			used = list('sound/vo/male/knight/firescream (1).ogg','sound/vo/male/knight/firescream (2).ogg','sound/vo/male/knight/firescream (3).ogg')
		if("laugh")
			used = list('sound/vo/male/knight/laugh (1).ogg','sound/vo/male/knight/laugh (2).ogg','sound/vo/male/knight/laugh (3).ogg','sound/vo/male/knight/laugh (4).ogg')
		if("pain")
			used = list('sound/vo/male/knight/pain (1).ogg','sound/vo/male/knight/pain (2).ogg','sound/vo/male/knight/pain (3).ogg','sound/vo/male/knight/pain (4).ogg','sound/vo/male/knight/pain (5).ogg','sound/vo/male/knight/pain (6).ogg','sound/vo/male/knight/pain (7).ogg','sound/vo/male/knight/pain (8).ogg','sound/vo/male/knight/pain (9).ogg','sound/vo/male/knight/pain (10).ogg','sound/vo/male/knight/pain (11).ogg','sound/vo/male/knight/pain (12).ogg')
		if("paincrit")
			used = list('sound/vo/male/knight/paincrit (1).ogg','sound/vo/male/knight/paincrit (2).ogg','sound/vo/male/knight/paincrit (3).ogg')
		if("painmoan")
			used = list('sound/vo/male/knight/painmoan (1).ogg','sound/vo/male/knight/painmoan (2).ogg','sound/vo/male/knight/painmoan (3).ogg','sound/vo/male/knight/painmoan (4).ogg')
		if("painscream")
			used = list('sound/vo/male/knight/painscream (1).ogg','sound/vo/male/knight/painscream (2).ogg','sound/vo/male/knight/painscream (3).ogg')
		if("rage")
			used = list('sound/vo/male/knight/rage (1).ogg','sound/vo/male/knight/rage (2).ogg','sound/vo/male/knight/rage (3).ogg','sound/vo/male/knight/rage (4).ogg','sound/vo/male/knight/rage (5).ogg','sound/vo/male/knight/rage (6).ogg')
	if(!used)
		used = ..(soundin, modifiers)
	return used

//chivalrous warriors