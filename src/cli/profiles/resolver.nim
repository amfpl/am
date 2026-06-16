import std/os
import std/strutils
import cli/profiles/manager

type
  ProfileNotFound* = object of ValueError

proc findTcc(): string =
  # Ищем TCC в папке с amc.exe
  let exeDir = getAppDir()
  let candidates = @[
    exeDir / "tcc" / "tcc.exe",
    exeDir / "tcc.exe",
    exeDir / "third_party" / "tcc" / "tcc.exe",
    exeDir / ".." / "tcc" / "tcc.exe",
  ]
  
  for c in candidates:
    if fileExists(c):
      return c
  
  return ""

proc findSystemCompiler(): string =
  # Ищем системные компиляторы
  let compilers = @["gcc", "clang", "cc"]
  for c in compilers:
    let path = findExe(c)
    if path.len > 0:
      return path
  return ""

proc resolveProfile*(pm: ProfileManager, name: string): Profile =
  if name == "auto":
    # 1. Ищем TCC в папке с amc
    let tccPath = findTcc()
    if tccPath.len > 0:
      return Profile(name: "auto (tcc)", path: tccPath, extraFlags: @[])
    
    # 2. Ищем системный компилятор
    let sysPath = findSystemCompiler()
    if sysPath.len > 0:
      return Profile(name: "auto (" & sysPath.extractFilename() & ")", 
                     path: sysPath, extraFlags: @[])
    
    raise ProfileNotFound("No C compiler found. Install TCC, GCC, or Clang")
  
  # Пользовательский профиль
  if pm.profiles.hasKey(name):
    return pm.profiles[name]
  
  # Проверяем, может это путь к компилятору
  if fileExists(name):
    return Profile(name: name.extractFilename(), path: name, extraFlags: @[])
  
  # Проверяем системный PATH
  let sysPath = findExe(name)
  if sysPath.len > 0:
    return Profile(name: name, path: sysPath, extraFlags: @[])
  
  raise ProfileNotFound("Profile not found: " & name)