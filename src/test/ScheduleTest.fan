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
  // very 10sec
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
  }

  Void testDaily()
  {
    verifySchedule("daily at 08:15:00", DailySchedule(Time(8,15,0)))
    verifySchedule("daily at 22:00:00", DailySchedule(Time(22,00,0)))

    verifyErr(ParseErr#) { x := CronSchedule.fromStr("daily 08:15:00")   }
    verifyErr(ParseErr#) { x := CronSchedule.fromStr("daily at 8:15:00") }
    verifyErr(ParseErr#) { x := CronSchedule.fromStr("daily at 08:15")   }
    verifyErr(ParseErr#) { x := CronSchedule.fromStr("daily at foo")     }
  }

  private Void verifySchedule(Str str, CronSchedule s)
  {
    test := CronSchedule.fromStr(str)
    verifyEq(test, s)
    verifyEq(test.toStr, str)
    verifyEq(str, s.toStr)
  }
}
