//
// Copyright (c) 2014, Andy Frank
// Licensed under the MIT License
//
// History:
//   10 Sep 2014  Andy Frank  Creation
//

**
** CronSchedule defines a schedule for when a CronJob should run.
**
@Serializable { simple=true }
abstract const class CronSchedule
{

//////////////////////////////////////////////////////////////////////////
// Methods
//////////////////////////////////////////////////////////////////////////

  ** Return true if this schedule triggers for the given timestamp.
  abstract Bool trigger(DateTime now, DateTime? last)

//////////////////////////////////////////////////////////////////////////
// Serializable
//////////////////////////////////////////////////////////////////////////

  static new fromStr(Str str, Bool checked := true)
  {
    try
    {
      s := str.split(' ')
      switch (s.first)
      {
        case "every":   return parseEvery(s)
        case "daily":   return parseDaily(s)
        case "weekly":  return parseWeekly(s)
        case "monthly": return parseMonthly(s)
        default: throw Err()
      }
    }
    catch (Err err)
    {
      if (checked) throw ParseErr("Invalid schedule str '$str'", err)
      return null
    }
  }

  private static EverySchedule parseEvery(Str[] s)
  {
    if (s.size != 2) throw Err()
    return EverySchedule(Duration.fromStr(s[1]))
  }

  private static DailySchedule parseDaily(Str[] s)
  {
    if (s.size != 3) throw Err()
    if (s[1] != "at") throw Err()
    return DailySchedule(Time.fromStr(s[2] + ":00"))
  }

  private static WeeklySchedule parseWeekly(Str[] s)
  {
    if (s.size != 5) throw Err()
    if (s[1] != "on") throw Err()
    w := Weekday[,]
    s[2].split(',').each |x| { w.add(Weekday.fromStr(x)) }
    if (s[3] != "at") throw Err()
    return WeeklySchedule(w.unique.sort, Time.fromStr(s[4] + ":00"))
  }

  private static MonthlySchedule parseMonthly(Str[] s)
  {
    if (s.size != 5) throw Err()
    if (s[1] != "on") throw Err()
    days := Int[,]
    s[2].split(',').each |x|
    {
      d := x.toInt(10, false)
      if (d == null || d < 1 || d > 31) throw Err()
      days.add(d)
    }
    if (s[3] != "at") throw Err()
    return MonthlySchedule(days.unique.sort, Time.fromStr(s[4] + ":00"))
  }
}

**************************************************************************
** EverySchedule
**************************************************************************

internal const class EverySchedule : CronSchedule
{
  new make(Duration dur) { this.dur=dur }

  const Duration dur

  override Bool trigger(DateTime now, DateTime? last)
  {
    last==null ? false : now - last >= dur
  }

  override Int hash() { toStr.hash }

  override Bool equals(Obj? obj)
  {
    that := obj as EverySchedule
    return that?.dur == this.dur
  }

  override Str toStr() { "every $dur" }
}

**************************************************************************
** DailySchedule
**************************************************************************

internal const class DailySchedule : CronSchedule
{
  new make(Time time) { this.time=time }

  const Time time

  override Bool trigger(DateTime now, DateTime? last)
  {
    last==null
      ? now.time >= time
      : (now.time >= time && (now-last >= 24hr))
  }

  override Int hash() { toStr.hash }

  override Bool equals(Obj? obj)
  {
    that := obj as DailySchedule
    return that?.time == this.time
  }

  override Str toStr() { "daily at " + time.toLocale("hh:mm") }
}

**************************************************************************
** WeeklySchedule
**************************************************************************

internal const class WeeklySchedule : CronSchedule
{
  new make(Weekday[] weekdays, Time time)
  {
    this.weekdays = weekdays
    this.time = time
  }

  const Weekday[] weekdays
  const Time time

  override Bool trigger(DateTime now, DateTime? last)
  {
    if (!weekdays.contains(now.date.weekday)) return false
    if (now.time < time) return false
    return last==null ? true : now.date > last.date
  }

  override Int hash() { toStr.hash }

  override Bool equals(Obj? obj)
  {
    that := obj as WeeklySchedule
    if (that == null) return false
    return that.weekdays == this.weekdays && that.time == this.time
  }

  override Str toStr() { "weekly on " + weekdays.join(",") + " at " + time.toLocale("hh:mm") }
}

**************************************************************************
** MonthlySchedule
**************************************************************************

internal const class MonthlySchedule : CronSchedule
{
  new make(Int[] days, Time time)
  {
    this.days = days
    this.time = time
  }

  const Int[] days
  const Time time

  override Bool trigger(DateTime now, DateTime? last)
  {
    if (!days.contains(now.date.day)) return false
    if (now.time < time) return false
    return last==null ? true : now.date > last.date
  }

  override Int hash() { toStr.hash }

  override Bool equals(Obj? obj)
  {
    that := obj as MonthlySchedule
    if (that == null) return false
    return that.days == this.days && that.time == this.time
  }

  override Str toStr() { "monthly on " + days.join(",") + " at " + time.toLocale("hh:mm") }
}