//
// Copyright (c) 2014, Andy Frank
// Licensed under the MIT License
//
// History:
//   10 Sep 2014  Andy Frank  Creation
//

**
** CronJob
**
internal const class CronJob
{
  ** It-block constructor.
  new make(Str name, Method m, CronSchedule s)
  {
    this.name = name
    this.method = m
    this.schedule = s
  }

  ** Job name.
  const Str name

  ** Method to invoke for job.
  const Method method

  ** Job schedule.
  const CronSchedule schedule

  ** Hash is 'name.hash'
  override Int hash() { name.hash }

  ** CronJobs are equal if 'name' is equal.
  override Bool equals(Obj? that)
  {
    that is CronJob ? ((CronJob)that).name == name : false
  }

  override Str toStr() { "$name.toCode -> $method @ $schedule" }
}