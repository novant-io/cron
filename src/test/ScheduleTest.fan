//
// Copyright (c) 2014, Andy Frank
// Licensed under the MIT License
//
// History:
//   10 Sep 2014  Andy Frank  Creation
//

**
** ScheduleTest.
**
internal class ScheduleTest : Test
{
  // every 10sec
  // daily at 10:00:00
  // weekly on sun at 10:00:00
  // montly on xxx at 10:00:00

  Void testEvery()
  {
    verifySchedule("every 1min", EverySchedule(1min))
    verifySchedule("every 2hr",  EverySchedule(2hr))
    verifySchedule("every 3day", EverySchedule(3day))

    verifyErr(ParseErr#) { x := CronSchedule.fromStr("every foo") }
    verifyErr(ParseErr#) { x := CronSchedule.fromStr("every 10s") }

    now := DateTime.now
    x := CronSchedule("every 10min")
    verifyFalse(x.trigger(now, null))
    verifyFalse(x.trigger(now, now-1min))
    verifyFalse(x.trigger(now, now-9min))
    verify(x.trigger(now, now-10min))
    verify(x.trigger(now, now-11min))
  }

  Void testDaily()
  {
    verifySchedule("daily at 08:15:00", DailySchedule(Time(8,15,0)))
    verifySchedule("daily at 22:00:00", DailySchedule(Time(22,00,0)))

    verifyErr(ParseErr#) { x := CronSchedule.fromStr("daily 08:15:00")   }
    verifyErr(ParseErr#) { x := CronSchedule.fromStr("daily at 8:15:00") }
    verifyErr(ParseErr#) { x := CronSchedule.fromStr("daily at 08:15")   }
    verifyErr(ParseErr#) { x := CronSchedule.fromStr("daily at foo")     }

    now := DateTime("2014-09-10T22:00:00-04:00 New_York")
    x := CronSchedule("daily at 16:00:00")
    verifyFalse(x.trigger(now-8hr, null))
    verify(x.trigger(now, null))
    verify(x.trigger(now, now-2day))
    verify(x.trigger(now, now-25hr))
    verify(x.trigger(now, now-24hr))
    verifyFalse(x.trigger(now, now-23hr))
    verifyFalse(x.trigger(now, now-1hr))
  }

  private Void verifySchedule(Str str, CronSchedule s)
  {
    test := CronSchedule.fromStr(str)
    verifyEq(test, s)
    verifyEq(test.toStr, str)
    verifyEq(str, s.toStr)
  }
}
