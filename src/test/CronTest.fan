//
// Copyright (c) 2016, Andy Frank
// Licensed under the MIT License
//
// History:
//   8 Jan 2016  Andy Frank  Creation
//

using concurrent

**
** CronTest.
**
internal class CronTest : Test
{
  Void testBasics()
  {
    cron := CronService()
    cron.start

    // test empty
    verifyEq(cron.jobs.size, 0)

    // add jobs
    cron.addJob(CronJob("test-a", JobTest#jobA, CronSchedule("every 5sec")))
    cron.addJob(CronJob("test-b", JobTest#jobB, CronSchedule("every 8sec")))
    cron.addJob(CronJob("test-c", JobTest#jobC, CronSchedule("daily at " + (Time.now + 10sec).toLocale("hh:mm"))))
    Actor.sleep(21sec)

    // verify results
    verifyEq(JobTest.a.val, 4)
    verifyEq(JobTest.b.val, 3)
    verifyEq(JobTest.c.val, 1)

    cron.stop
  }
}

internal class JobTest
{
  Void jobA() { echo("# jobA [$a.incrementAndGet]") }
  Void jobB() { echo("# jobB [$b.incrementAndGet]") }
  Void jobC() { echo("# jobC [$c.incrementAndGet]") }

  static const AtomicInt a := AtomicInt(0)
  static const AtomicInt b := AtomicInt(0)
  static const AtomicInt c := AtomicInt(0)
}