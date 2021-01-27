#! /usr/bin/env fan
//
// Copyright (c) 2014, Novant LLC
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
    version = Version("1.1")
    meta = [
      "org.name":     "Novant",
      "org.uri":      "https://novant.io/",
      "license.name": "MIT",
      "vcs.name":     "Git",
      "vcs.uri":      "https://github.com/novant-io/cron",
      "repo.public":  "true",
    ]
    depends = ["sys 1.0", "util 1.0", "concurrent 1.0"]
    srcDirs = [`fan/`, `test/`]
    docSrc = true
  }
}