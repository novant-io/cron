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
const class CronJob
{
  ** It-block constructor.
  new make(|This| f) { f(this) }

  ** Job name.
  const Str name

  ** Method to invoke for job.
  const Method func

  ** Job schedule.
  const CronSchedule schedule

  override Str toStr() { "$name.toCode -> $func @ $schedule" }
}