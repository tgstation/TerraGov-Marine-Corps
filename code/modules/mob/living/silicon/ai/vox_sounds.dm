// List is required to compile the resources into the game when it loads.
// Dynamically loading it has bad results with sounds overtaking each other, even with the wait variable.
#ifdef AI_VOX

// Regex for collecting a list of ogg files
// (([a-zA-Z,.]+)\.ogg)

// For vim
// :%s/\(\(.*\)\.ogg\)/"\2" = 'sound\/vox_fem\/\1',/g
GLOBAL_LIST_INIT(vox_sounds, list())
#endif
