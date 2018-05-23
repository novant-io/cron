# Cron

A job scheduling API for Fantom:

```fantom
// start service
cron := CronService()
cron.start

// add jobs
cron.addJob("job-a", JobA#run, CronSchedule("every 20min"))
cron.addJob("job-b", JobB#run, CronSchedule("daily at 10:15"))

...

// stop service
cron.stop

...

class JobA
{
  // no-arg job function
  Void run() { ... }
}

class JobB
{
  // optionally take a job specific Log instance for logging
  Void run(Log log) { ... }
}
```