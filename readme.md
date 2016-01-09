# Cron

A job scheduling API for Fantom:

    // start service
    cron := CronService()
    cron.start

    // add jobs
    cron.addJob(CronJob("job-a", JobA#run, CronSchedule("every 20min")))
    cron.addJob(CronJob("job-b", JobB#run, CronSchedule("daily at 10:15")))

    ...

    // stop service
    cron.stop
