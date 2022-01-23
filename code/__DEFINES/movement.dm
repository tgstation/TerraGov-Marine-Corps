//The minimum for glide_size to be clamped to.
//If you want more classic style "delay" movement while still retaining the smoothness improvements at higher framerates, set this to 8
#define MIN_GLIDE_SIZE 0
//The maximum for glide_size to be clamped to.
//This shouldn't be higher than the icon size, and generally you shouldn't be changing this, but it's here just in case.
#define MAX_GLIDE_SIZE 32

#define DELAY_TO_GLIDE_SIZE(delay) (round((clamp(((32 / max(delay / world.tick_lag, 1)) * (1 - (SStime_track.time_dilation_current / 100)) * (CONFIG_GET(number/glide_size_mod) * 0.01)), MIN_GLIDE_SIZE, MAX_GLIDE_SIZE)), 0.1))

#define DELAY_TO_GLIDE_SIZE_STATIC(delay) (round(clamp((32 / (delay || 1)) * (CONFIG_GET(number/glide_size_mod) * 0.01), MIN_GLIDE_SIZE, MAX_GLIDE_SIZE), 0.1))

//Old behavior, client related. Currently unused.
#define DELAY_TO_GLIDE_SIZE_OLD(source, delay) (round(source.tick_lag ? ((32 / max(delay, source.tick_lag)) * source.tick_lag) : 0, 0.1))

#define GLIDE_MOD_PULLED (1<<0)
#define GLIDE_MOD_BUCKLED (1<<0)

#define TURF_CAN_ENTER (1<<0)
#define TURF_ENTER_ALREADY_MOVED (1<<1)
