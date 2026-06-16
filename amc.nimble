# Package
version       = "0.1.0"
author        = "Am Programming Language"
description   = "Am is high-Level native-compile programming language with static types"
license       = "Apache-2.0"
srcDir        = "src"
binDir        = "bin"
bin           = @["amc"]

# Dependencies
requires "nim >= 2.0.0"

# Tasks
task release, "Release build":
  exec "nim c -d:release src/skrp.nim"