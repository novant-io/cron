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
  new make(ActorPool pool, CronJob job) : super(pool)
  {
    this.job = job
  }

  ** Job for this actor.
  const CronJob job

  override Obj? receive(Obj? msg)
  {
    try
    {
      instance := job.method.isStatic ? null : job.method.parent.make
      job.method.callOn(instance, null)
    }
    catch (Err err)
    {
      // TODO FIXIT
      err.trace
    }
    return null
  }
}