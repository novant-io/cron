//
// Copyright (c) 2016, Novant LLC
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

      // props file
      props := dir + `${job.name}.props`
      map   := Str:Str[:] { ordered=true }
      map["name"]    = job.name
      map["lastRun"] = ts.toStr

      // create log
      key := ts.toLocale("YYMMDD-hhmm")
      log := CronJobLog(dir + `${job.name}-${key}.log`)
      log.info("Job started")

      try
      {
        // invoke job
        instance := job.method.isStatic ? null : job.method.parent.make
        job.method.callOn(instance, [log])
        log.info("Job completed")
      }
      catch (Err jobErr)
      {
        // log err
        log.err("*** JOB FAILED ***", jobErr)
        map["lastErr"] = jobErr.traceToStr
      }
      finally
      {
        props.out.writeProps(map).flush.close // sync throws IOErr on OSX?
        log.file.out(true).sync.close
      }
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
    out := file.out(true)
    out.printLine(rec)
    if (rec.err != null) out.printLine(rec.err.traceToStr)
    out.flush.close
  }
}