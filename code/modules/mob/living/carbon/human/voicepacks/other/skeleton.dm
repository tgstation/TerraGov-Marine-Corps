/datum/voicepack/skeleton/get_sound(soundin, modifiers)
	var/used
	switch(soundin)
		if("aggro")
			used = pick('sound/vo/mobs/skel/skeleton_rage (1).ogg','sound/vo/mobs/skel/skeleton_rage (2).ogg','sound/vo/mobs/skel/skeleton_rage (3).ogg')
		if("rage")
			used = pick('sound/vo/mobs/skel/skeleton_rage (1).ogg','sound/vo/mobs/skel/skeleton_rage (2).ogg','sound/vo/mobs/skel/skeleton_rage (3).ogg')
		if("laugh")
			used = pick('sound/vo/mobs/skel/skeleton_laugh.ogg')
		if("deathgurgle")
			used = pick('sound/vo/mobs/skel/skeleton_scream (1).ogg','sound/vo/mobs/skel/skeleton_scream (2).ogg','sound/vo/mobs/skel/skeleton_scream (3).ogg','sound/vo/mobs/skel/skeleton_scream (4).ogg','sound/vo/mobs/skel/skeleton_scream (5).ogg')
		if("firescream")
			used = pick('sound/vo/mobs/skel/skeleton_scream (1).ogg','sound/vo/mobs/skel/skeleton_scream (2).ogg','sound/vo/mobs/skel/skeleton_scream (3).ogg','sound/vo/mobs/skel/skeleton_scream (4).ogg','sound/vo/mobs/skel/skeleton_scream (5).ogg')
		if("pain")
			used = pick('sound/vo/mobs/skel/skeleton_pain (1).ogg','sound/vo/mobs/skel/skeleton_pain (2).ogg','sound/vo/mobs/skel/skeleton_pain (3).ogg','sound/vo/mobs/skel/skeleton_pain (4).ogg','sound/vo/mobs/skel/skeleton_pain (5).ogg')
		if("paincrit")
			used = pick('sound/vo/mobs/skel/skeleton_scream (1).ogg','sound/vo/mobs/skel/skeleton_scream (2).ogg','sound/vo/mobs/skel/skeleton_scream (3).ogg','sound/vo/mobs/skel/skeleton_scream (4).ogg','sound/vo/mobs/skel/skeleton_scream (5).ogg')
		if("scream")
			used = pick('sound/vo/mobs/skel/skeleton_scream (1).ogg','sound/vo/mobs/skel/skeleton_scream (2).ogg','sound/vo/mobs/skel/skeleton_scream (3).ogg','sound/vo/mobs/skel/skeleton_scream (4).ogg','sound/vo/mobs/skel/skeleton_scream (5).ogg')


	return used