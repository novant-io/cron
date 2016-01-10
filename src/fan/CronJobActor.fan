//
// Copyright (c) 2016, Andy Frank
// Licensed under the MIT License
//
// History:
//   9 Jan 2016  Andy Frank  Creation
//

using concurrent

**
** CronJobActor runs a job in an Actor.
**
internal const class CronJobActor : Actor
{
  ** It-block constructor.
  new make(ActorPool pool, CronService service, CronJob job, DateTime ts) : super(pool)
  {
    this.service = service
    this.job = job
    this.ts  = ts
  }

  ** Parent CronService.
  const CronService service

  ** Job for this actor.
  const CronJob job

  ** Timestamp for this job run.
  const DateTime ts

  override Obj? receive(Obj? msg)
  {
    try
    {
      // get job subdirectory
      dir := service.dir + `$job.name/`
      dir.create

      // create log
      key := ts.toLocale("YYMMDD-hhmm")
      log := CronJobLog(dir + `${job.name}-${key}.log`)
      log.info("Job started")

      try
      {
        // invoke job
        instance := job.method.isStatic ? null : job.method.parent.make
        job.method.callOn(instance, [log])

        // update sucess
        log.info("Job completed")
      }
      catch (Err jobErr)
      {
        // update fail
        log.err("*** JOB FAILED ***", jobErr)
      }
      finally { log.file.out(true).sync }
    }
    catch (Err err)
    {
      // TODO?
      err.trace
    }
    return null
  }
}

**************************************************************************
** CronJobLog
**************************************************************************

internal const class CronJobLog : Log
{
  ** Constructor.
  new make(File file) : super(file.basename, false)
  {
    this.file = file
  }

  ** Log file.
  const File file

  ** Log to file.
  override Void log(LogRec rec)
  {
    // TODO FIXIT: don't open/close stream?
    file.out(true).printLine(rec).close
  }
}