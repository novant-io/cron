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
  // montly on 1,15 at 10:00

//////////////////////////////////////////////////////////////////////////
// Every
//////////////////////////////////////////////////////////////////////////

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

//////////////////////////////////////////////////////////////////////////
// Daily
//////////////////////////////////////////////////////////////////////////

  Void testDaily()
  {
    verifySchedule("daily at 08:15", DailySchedule(Time(8,15,0)))
    verifySchedule("daily at 22:00", DailySchedule(Time(22,00,0)))

    verifyErr(ParseErr#) { x := CronSchedule.fromStr("daily 08:15")   }
    verifyErr(ParseErr#) { x := CronSchedule.fromStr("daily at 8:15") }
    verifyErr(ParseErr#) { x := CronSchedule.fromStr("daily at foo")  }

    // no last
    x := CronSchedule("daily at 16:00")
    verifyTrigger(x, "2014-09-10", "09:00", null, null, false)   // before
    verifyTrigger(x, "2014-09-10", "15:59", null, null, false)   // before
    verifyTrigger(x, "2014-09-10", "16:00", null, null, true)    // at
    verifyTrigger(x, "2014-09-10", "18:00", null, null, true)    // after

    // last
    verifyTrigger(x, "2014-09-10", "09:00", "2014-09-09", "16:00", false)   // before
    verifyTrigger(x, "2014-09-10", "15:59", "2014-09-09", "16:00", false)   // before
    verifyTrigger(x, "2014-09-10", "16:00", "2014-09-09", "16:00", true)    // exact
    verifyTrigger(x, "2014-09-10", "18:00", "2014-09-10", "16:00", false)   // after
    verifyTrigger(x, "2014-09-11", "09:00", "2014-09-10", "16:00", false)   // next-day before
    verifyTrigger(x, "2014-09-11", "15:59", "2014-09-10", "16:00", false)   // next-day before
    verifyTrigger(x, "2014-09-11", "16:01", "2014-09-10", "16:00", true)    // next-day at
  }

//////////////////////////////////////////////////////////////////////////
// Weekly
//////////////////////////////////////////////////////////////////////////

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
    verifyTrigger(x, "2015-10-14", "14:00", null, null, true)   // wed at
    verifyTrigger(x, "2015-10-14", "15:00", null, null, true)   // wed after
    verifyTrigger(x, "2015-10-15", "09:00", null, null, false)  // thur
    verifyTrigger(x, "2015-10-15", "14:30", null, null, false)  // thur
    verifyTrigger(x, "2015-10-15", "18:00", null, null, false)  // thur

    // single day - last week
    verifyTrigger(x, "2015-10-13", "15:00", "2015-10-07", "14:01", false)  // tue
    verifyTrigger(x, "2015-10-14", "13:00", "2015-10-07", "14:01", false)  // wed before
    verifyTrigger(x, "2015-10-14", "14:00", "2015-10-07", "14:01", true)   // wed at
    verifyTrigger(x, "2015-10-14", "15:00", "2015-10-07", "14:01", true)   // wed after

    // single day - last today
    verifyTrigger(x, "2015-10-13", "15:00", "2015-10-14", "14:01", false)  // tue
    verifyTrigger(x, "2015-10-14", "13:00", "2015-10-14", "14:01", false)  // wed before
    verifyTrigger(x, "2015-10-14", "14:00", "2015-10-14", "14:01", false)  // wed at
    verifyTrigger(x, "2015-10-14", "15:00", "2015-10-14", "14:01", false)  // wed after

    // multi-day
    y := CronSchedule("weekly on mon,wed,thu at 14:00")
    verifyTrigger(y, "2015-10-12", "10:00", null,         null,    false)  // mon before
    verifyTrigger(y, "2015-10-12", "14:00", null,         null,    true)   // mon at
    verifyTrigger(y, "2015-10-12", "14:00", "2015-10-12", "14:00", false)  // mon after
    verifyTrigger(y, "2015-10-13", "09:00", "2015-10-12", "14:00", false)  // tue
    verifyTrigger(y, "2015-10-13", "18:00", "2015-10-12", "14:00", false)  // tue
    verifyTrigger(y, "2015-10-14", "12:00", "2015-10-12", "14:00", false)  // wed before
    verifyTrigger(y, "2015-10-14", "14:00", "2015-10-12", "14:00", true)   // wed at
    verifyTrigger(y, "2015-10-14", "15:00", "2015-10-14", "14:00", false)  // wed after
    verifyTrigger(y, "2015-10-15", "08:00", "2015-10-14", "14:00", false)  // thu before
    verifyTrigger(y, "2015-10-15", "14:15", "2015-10-14", "14:00", true)   // thu at
    verifyTrigger(y, "2015-10-15", "15:00", "2015-10-15", "14:00", false)  // thu after
  }

//////////////////////////////////////////////////////////////////////////
// Monthly
//////////////////////////////////////////////////////////////////////////

  Void testMonthly()
  {
    verifySchedule("monthly on 15 at 09:45", MonthlySchedule([15], Time(9,45,0)))
    verifySchedule("monthly on 1,15 at 09:45", MonthlySchedule([1,15], Time(9,45,0)))
    verifySchedule("monthly on 5,1,5,1 at 09:45", MonthlySchedule([1,5], Time(9,45,0)), false)
    verifySchedule("monthly on 31,4,12 at 09:45", MonthlySchedule([4,12,31], Time(9,45,0)), false)

    verifyErr(ParseErr#) { x := CronSchedule.fromStr("monthly 08:15")   }
    verifyErr(ParseErr#) { x := CronSchedule.fromStr("monthly 15 08:15") }
    verifyErr(ParseErr#) { x := CronSchedule.fromStr("monthly on 15 08:15")  }
    verifyErr(ParseErr#) { x := CronSchedule.fromStr("monthly on 15 at 8:15")  }
    verifyErr(ParseErr#) { x := CronSchedule.fromStr("monthly on 15 at foo")  }
    verifyErr(ParseErr#) { x := CronSchedule.fromStr("monthly on mon at 12:00")  }
    verifyErr(ParseErr#) { x := CronSchedule.fromStr("monthly on 1, 15 at 12:00")  }

    // single day - no last
    x := CronSchedule("monthly on 15 at 10:00")
    verifyTrigger(x, "2015-10-14", "09:00", null, null, false)  // 10/14
    verifyTrigger(x, "2015-10-14", "12:00", null, null, false)  // 10/14
    verifyTrigger(x, "2015-10-15", "09:00", null, null, false)  // 10/15 before
    verifyTrigger(x, "2015-10-15", "10:00", null, null, true)   // 10/15 at
    verifyTrigger(x, "2015-10-15", "12:00", null, null, true)   // 10/15 after
    verifyTrigger(x, "2015-10-16", "09:00", null, null, false)  // 10/16
    verifyTrigger(x, "2015-10-16", "10:30", null, null, false)  // 10/16
    verifyTrigger(x, "2015-10-16", "18:00", null, null, false)  // 10/16

    // single day - last month
    verifyTrigger(x, "2015-10-14", "15:00", "2015-09-15", "10:01", false)  // 10/14
    verifyTrigger(x, "2015-10-15", "09:00", "2015-09-15", "14:01", false)  // 10/15 before
    verifyTrigger(x, "2015-10-15", "10:00", "2015-09-15", "14:01", true)   // 10/15 at
    verifyTrigger(x, "2015-10-15", "15:00", "2015-09-15", "14:01", true)   // 10/15 after

    // single day - last today
    verifyTrigger(x, "2015-10-14", "10:05", "2015-10-15", "10:01", false)  // 10/14
    verifyTrigger(x, "2015-10-15", "09:00", "2015-10-15", "10:01", false)  // 10/15 before
    verifyTrigger(x, "2015-10-15", "10:00", "2015-10-15", "10:01", false)  // 10/15 at
    verifyTrigger(x, "2015-10-15", "15:00", "2015-10-15", "10:01", false)  // 10/15 after

    // mulit-day
    z := CronSchedule("monthly on 1,15,16 at 14:00")
    verifyTrigger(z, "2015-09-30", "10:00", null,         null,    false)  // 9/30
    verifyTrigger(z, "2015-09-30", "15:00", null,         null,    false)  // 9/30
    verifyTrigger(z, "2015-10-01", "09:00", null,         null,    false)  // 10/1 before
    verifyTrigger(z, "2015-10-01", "14:00", null,         null,    true)   // 10/1 at
    verifyTrigger(z, "2015-10-01", "15:00", "2015-10-01", "14:01", false)  // 10/1 after
    verifyTrigger(z, "2015-10-02", "09:00", "2015-10-01", "14:01", false)  // 10/2
    verifyTrigger(z, "2015-10-02", "18:00", "2015-10-01", "14:01", false)  // 10/2
    verifyTrigger(z, "2015-10-14", "09:00", "2015-10-01", "14:01", false)  // 10/14
    verifyTrigger(z, "2015-10-14", "18:00", "2015-10-01", "14:01", false)  // 10/14
    verifyTrigger(z, "2015-10-15", "09:00", "2015-10-01", "14:01", false)  // 10/15 before
    verifyTrigger(z, "2015-10-15", "14:00", "2015-10-01", "14:01", true)   // 10/15 at
    verifyTrigger(z, "2015-10-15", "14:00", "2015-10-15", "14:00", false)  // 10/15 after
    verifyTrigger(z, "2015-10-16", "08:00", "2015-10-15", "14:00", false)  // 10/16 before
    verifyTrigger(z, "2015-10-16", "14:30", "2015-10-15", "14:00", true)   // 10/16 at
    verifyTrigger(z, "2015-10-16", "22:00", "2015-10-16", "14:30", false)  // 10/16 after
    verifyTrigger(z, "2015-10-17", "09:00", "2015-10-16", "14:30", false)  // 10/17
    verifyTrigger(z, "2015-10-17", "18:00", "2015-10-16", "14:30", false)  // 10/17
  }

//////////////////////////////////////////////////////////////////////////
// Util
//////////////////////////////////////////////////////////////////////////

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
