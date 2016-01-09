//
// Copyright (c) 2016, Andy Frank
// Licensed under the MIT License
//
// History:
//   8 Jan 2016  Andy Frank  Creation
//

**
** CronCx manages the runtime state of cron jobs inside CronService.
**
internal class CronCx
{
  ** Job list.
  CronJob[] jobs := [,]

  ** Last run map.
  CronJob:DateTime lastRun := [:]
}