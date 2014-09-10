#! /usr/bin/env fan
//
// Copyright (c) 2014, Andy Frank
// Licensed under the MIT License
//
// History:
//   10 Sep 2014  Andy Frank  Creation
//

using build

**
** Build: cron
**
class Build : BuildPod
{
  new make()
  {
    podName = "cron"
    summary = "Cron Scheduling API"
    version = Version("1.0.0")
    //meta = ["vcs.uri" : "http://bitbucket.org/afrankvt/cron/", "license.name":"MIT"]
    depends = ["sys 1.0", "util 1.0", "concurrent 1.0"]
    srcDirs = [`fan/`, `test/`]
    docSrc = true
  }
}