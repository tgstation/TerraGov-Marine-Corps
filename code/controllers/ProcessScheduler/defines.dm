// Process status defines
#define PROCESS_STATUS_IDLE 1
#define PROCESS_STATUS_QUEUED 2
#define PROCESS_STATUS_RUNNING 3
#define PROCESS_STATUS_MAYBE_HUNG 4
#define PROCESS_STATUS_PROBABLY_HUNG 5
#define PROCESS_STATUS_HUNG 6

// Process time thresholds
#define PROCESS_DEFAULT_HANG_WARNING_TIME 	3000 // 300 seconds
#define PROCESS_DEFAULT_HANG_ALERT_TIME 	6000 // 600 seconds
#define PROCESS_DEFAULT_HANG_RESTART_TIME 	9000 // 900 seconds
#define PROCESS_DEFAULT_SCHEDULE_INTERVAL 	50  // 50 ticks
#define PROCESS_DEFAULT_TICK_ALLOWANCE		41	// 41% of one tick
#define LAGCHECK(x) while (world.tick_usage > x) stoplag(world.tick_lag)

#define TICK_LIMIT_RUNNING 80
#define TICK_LIMIT_TO_RUN 70
#define TICK_LIMIT_MC 70
#define TICK_LIMIT_MC_INIT_DEFAULT 98
//#define UPDATE_QUEUE_DEBUG
// If btime.dll is available, do this shit
/*

#ifdef PRECISE_TIMER_AVAILABLE
var/global/__btime__lastTimeOfHour = 0
var/global/__btime__callCount = 0
var/global/__btime__lastTick = 0
#define TimeOfHour __btime__timeofhour()
#define __extern__timeofhour text2num(call("btime.[world.system_type==MS_WINDOWS?"dll":"so"]", "gettime")())
proc/__btime__timeofhour()
	if (!(__btime__callCount++ % 50))
		if (world.time > __btime__lastTick)
			__btime__callCount = 0
			__btime__lastTick = world.time
		global.__btime__lastTimeOfHour = __extern__timeofhour
	return global.__btime__lastTimeOfHour
#else
*/
#define TimeOfHour world.timeofday % 36000
