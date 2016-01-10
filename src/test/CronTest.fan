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
    cron.addJob("testa", JobTest#jobA, CronSchedule("every 1sec"))
    cron.addJob("testb", JobTest#jobB, CronSchedule("every 5sec"))
    cron.addJob("testc", JobTest#jobC, CronSchedule("daily at " + (Time.now + 10sec).toLocale("hh:mm")))

    // test dup name
    verifyErr(Err#) { cron.addJob("test-a", JobTest#jobC, CronSchedule("every 2sec")) }
    verifyEq(cron.jobs.size, 3)

    // wait 15sec and check vals
    Actor.sleep(15100ms)
    verifyEq(JobTest.a.val, 15)
    verifyEq(JobTest.b.val, 3)
    verifyEq(JobTest.c.val, 1)

    // remove job-a
    cron.removeJob("not-exist")
    cron.removeJob("test-a")
    verifyEq(cron.jobs.size, 2)

    // wait another 5sec and check vals
    Actor.sleep(5100ms)
    verifyEq(JobTest.a.val, 15)
    verifyEq(JobTest.b.val, 4)
    verifyEq(JobTest.c.val, 1)

    cron.stop
  }
}

internal class JobTest
{
  Void jobA() { echo("# jobA [$a.incrementAndGet]") }
  static Void jobB() { echo("# jobB [$b.incrementAndGet]") }
  Void jobC(Log log) { log.info("# jobC [$c.incrementAndGet]") }

  static const AtomicInt a := AtomicInt(0)
  static const AtomicInt b := AtomicInt(0)
  static const AtomicInt c := AtomicInt(0)
}