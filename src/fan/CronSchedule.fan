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
        case "every": return parseEvery(s)
        case "daily": return parseDaily(s)
        default: throw Err()
      }

      return DailySchedule(Time(10,0,0))
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
    return DailySchedule(Time.fromStr(s[2]))
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

  override Str toStr() { "daily at $time" }
}