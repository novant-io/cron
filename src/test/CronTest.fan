//
// Copyright (c) 2016, Andy Frank
// Licensed under the MIT License
//
// History:
//   8 Jan 2016  Andy Frank  Creation
//

**
** CronTest.
**
internal class CronTest : Test
{
  Void testBasics()
  {
    cron := CronService()
    verifyEq(cron.jobs.size, 0)
  }
}