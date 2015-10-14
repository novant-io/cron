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
  // daily at 10:00
  // weekly on sun at 10:00
  // montly on xxx at 10:00

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
    verifySchedule("daily at 08:15", DailySchedule(Time(8,15,0)))
    verifySchedule("daily at 22:00", DailySchedule(Time(22,00,0)))

    verifyErr(ParseErr#) { x := CronSchedule.fromStr("daily 08:15")   }
    verifyErr(ParseErr#) { x := CronSchedule.fromStr("daily at 8:15") }
    verifyErr(ParseErr#) { x := CronSchedule.fromStr("daily at foo")  }

    now := DateTime("2014-09-10T22:00:00-04:00 New_York")
    x := CronSchedule("daily at 16:00")
    verifyFalse(x.trigger(now-8hr, null))
    verify(x.trigger(now, null))
    verify(x.trigger(now, now-2day))
    verify(x.trigger(now, now-25hr))
    verify(x.trigger(now, now-24hr))
    verifyFalse(x.trigger(now, now-23hr))
    verifyFalse(x.trigger(now, now-1hr))
  }

  Void testWeekly()
  {
    verifySchedule("weekly on mon at 10:30", WeeklySchedule([Weekday.mon], Time(10,30,0)))
    verifySchedule("weekly on mon,wed at 22:00", WeeklySchedule([Weekday.mon, Weekday.wed], Time(22,00,0)))
    verifySchedule("weekly on tue,fri,sat at 16:30", WeeklySchedule([Weekday.tue, Weekday.fri, Weekday.sat], Time(16,30,0)))
    verifySchedule("weekly on fri,tue,fri,sat at 16:30", WeeklySchedule([Weekday.tue, Weekday.fri, Weekday.sat], Time(16,30,0)), false)

    verifyErr(ParseErr#) { x := CronSchedule.fromStr("weekly 08:15")   }
    verifyErr(ParseErr#) { x := CronSchedule.fromStr("weekly mon 08:15") }
    verifyErr(ParseErr#) { x := CronSchedule.fromStr("weekly on mon 08:15")  }
    verifyErr(ParseErr#) { x := CronSchedule.fromStr("weekly on mon at 8:15")  }
    verifyErr(ParseErr#) { x := CronSchedule.fromStr("weekly on mon at foo")  }
    verifyErr(ParseErr#) { x := CronSchedule.fromStr("weekly on Mon at 12:00")  }
    verifyErr(ParseErr#) { x := CronSchedule.fromStr("weekly on Monday at 12:00")  }
    verifyErr(ParseErr#) { x := CronSchedule.fromStr("weekly on mon, tue at 12:00")  }

    // single day - no last
    x := CronSchedule("weekly on wed at 14:00")
    verifyTrigger(x, "2015-10-13", "15:00", null, null, false)  // tue
    verifyTrigger(x, "2015-10-14", "13:00", null, null, false)  // wed before
    verifyTrigger(x, "2015-10-14", "14:00", null, null, true)   // wed exact
    verifyTrigger(x, "2015-10-14", "15:00", null, null, true)   // wed after
    verifyTrigger(x, "2015-10-15", "09:00", null, null, false)  // thur
    verifyTrigger(x, "2015-10-15", "14:30", null, null, false)  // thur
    verifyTrigger(x, "2015-10-15", "18:00", null, null, false)  // thur

    // single day - last week
    verifyTrigger(x, "2015-10-13", "15:00", "2015-10-07", "14:01", false)  // tue
    verifyTrigger(x, "2015-10-14", "13:00", "2015-10-07", "14:01", false)  // wed before
    verifyTrigger(x, "2015-10-14", "14:00", "2015-10-07", "14:01", true)   // wed exact
    verifyTrigger(x, "2015-10-14", "15:00", "2015-10-07", "14:01", true)   // wed after

    // single day - last today
    verifyTrigger(x, "2015-10-13", "15:00", "2015-10-14", "14:01", false)  // tue
    verifyTrigger(x, "2015-10-14", "13:00", "2015-10-14", "14:01", false)  // wed before
    verifyTrigger(x, "2015-10-14", "14:00", "2015-10-14", "14:01", false)  // wed exact
    verifyTrigger(x, "2015-10-14", "15:00", "2015-10-14", "14:01", false)  // wed after

    // multi-day
    y := CronSchedule("weekly on mon,wed,thu at 14:00")
    verifyTrigger(y, "2015-10-12", "10:00", null,         null,    false)  // mon before
    verifyTrigger(y, "2015-10-12", "14:00", null,         null,    true)   // mon exact
    verifyTrigger(y, "2015-10-12", "14:00", "2015-10-12", "14:00", false)  // mon after
    verifyTrigger(y, "2015-10-13", "09:00", "2015-10-12", "14:00", false)  // tue
    verifyTrigger(y, "2015-10-13", "18:00", "2015-10-12", "14:00", false)  // tue
    verifyTrigger(y, "2015-10-14", "12:00", "2015-10-12", "14:00", false)  // wed before
    verifyTrigger(y, "2015-10-14", "14:00", "2015-10-12", "14:00", true)   // wed exact
    verifyTrigger(y, "2015-10-14", "15:00", "2015-10-14", "14:00", false)  // wed after
    verifyTrigger(y, "2015-10-15", "08:00", "2015-10-14", "14:00", false)  // thu before
    verifyTrigger(y, "2015-10-15", "14:15", "2015-10-14", "14:00", true)   // thu exact
    verifyTrigger(y, "2015-10-15", "15:00", "2015-10-15", "14:00", false)  // thu after
  }

  private Void verifySchedule(Str str, CronSchedule s, Bool roundtrip := true)
  {
    test := CronSchedule.fromStr(str)
    verifyEq(test, s)
    if (roundtrip)
    {
      verifyEq(test.toStr, str)
      verifyEq(str, s.toStr)
    }
  }

  private Void verifyTrigger(CronSchedule s, Str date, Str time, Str? lastDate, Str? lastTime, Bool v)
  {
    now  := DateTime("${date}T${time}:00-04:00 New_York")
    last := lastDate==null || lastTime==null ? null : DateTime("${lastDate}T${lastTime}:00-04:00 New_York")
    verifyEq(s.trigger(now, last), v)
  }
}
