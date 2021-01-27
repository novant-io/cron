//
// Copyright (c) 2016, Novant LLC
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
    cron := CronService
    {
      it.dir = tempDir + `cron/`
      it.jobLogLimit = 5
    }
    cron.start

    // test empty
    verifyEq(cron.jobs.size, 0)

    // add jobs
    cron.addJob("testa", JobTest#jobA, CronSchedule("every 1sec"))
    cron.addJob("testb", JobTest#jobB, CronSchedule("every 5sec"))
    cron.addJob("testc", JobTest#jobC, CronSchedule("daily at " + (Time.now + 10sec).toLocale("hh:mm")))
    cron.addJob("testd", JobTest#jobD, CronSchedule("daily at " + (Time.now + 12sec).toLocale("hh:mm")))

    // test dup name
    verifyErr(Err#) { cron.addJob("testa", JobTest#jobC, CronSchedule("every 2sec")) }
    verifyEq(cron.jobs.size, 4)

    // wait 15sec and check vals
    Actor.sleep(15100ms)
    verifyEq(JobTest.a.val, 15)
    verifyEq(JobTest.b.val, 3)
    verifyEq(JobTest.c.val, 1)

    // remove job-a
    cron.removeJob("not-exist")
    cron.removeJob("testa")
    verifyEq(cron.jobs.size, 3)

    // wait another 5sec and check vals
    Actor.sleep(5100ms)
    verifyEq(JobTest.a.val, 15)
    verifyEq(JobTest.b.val, 4)
    verifyEq(JobTest.c.val, 1)

    // stop service
    cron.stop

    // restart and check runTimes
    cron = CronService { it.dir = tempDir + `cron/` }
    cron.start
    verifyEq(JobTest.c.val, 1)
    verifyEq(cron.jobs.size, 0)
    cron.addJob("testc", JobTest#jobC, CronSchedule("daily at " + (Time.now + 5sec).toLocale("hh:mm")))
    verifyEq(cron.jobs.size, 1)
    verifyNotNull(cron.jobs.first["lastRun"])
    Actor.sleep(6sec)
    verifyEq(JobTest.c.val, 1)

    cron.stop
  }
}

internal class JobTest
{
  Void jobA() { echo("# jobA [$a.incrementAndGet]") }
  static Void jobB() { echo("# jobB [$b.incrementAndGet]") }
  Void jobC(Log log) { log.info("# jobC [$c.incrementAndGet]") }
  static Void jobD() { throw Err("Oops") }

  static const AtomicInt a := AtomicInt(0)
  static const AtomicInt b := AtomicInt(0)
  static const AtomicInt c := AtomicInt(0)
}