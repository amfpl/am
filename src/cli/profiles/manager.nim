import std/json
import std/os
import std/tables
import std/strutils

type
  Profile* = object
    name*: string      # Пользовательское имя
    path*: string      # Путь к компилятору
    extraFlags*: seq[string]

  ProfileManager* = object
    profiles*: Table[string, Profile]

proc getConfigPath(): string =
  let home = getEnv("HOME")
  if home.len > 0:
    result = home / ".config" / "amc" / "profiles.json"
  else:
    let appdata = getEnv("APPDATA")
    if appdata.len > 0:
      result = appdata / "AmC" / "profiles.json"
    else:
      result = getAppDir() / "profiles.json"

proc load*(): ProfileManager =
  result.profiles = initTable[string, Profile]()
  let path = getConfigPath()
  
  if not fileExists(path):
    # Нет профилей - пользователь должен создать их через 'add'
    return
  
  try:
    let json = parseFile(path)
    for key, val in json:
      var p = Profile(name: key)
      p.path = val["path"].getStr("")
      if p.path.len == 0:
        continue
      if val.hasKey("extraFlags"):
        for flag in val["extraFlags"]:
          p.extraFlags.add(flag.getStr(""))
      result.profiles[key] = p
  except:
    # Файл поврежден - игнорируем
    discard

proc save*(pm: ProfileManager) =
  let path = getConfigPath()
  let dir = path.parentDir()
  if not dirExists(dir):
    createDir(dir)
  
  var json = newJObject()
  for name, p in pm.profiles:
    var obj = newJObject()
    obj["path"] = %p.path
    if p.extraFlags.len > 0:
      var arr = newJArray()
      for flag in p.extraFlags:
        arr.add(%flag)
      obj["extraFlags"] = arr
    json[name] = obj
  
  writeFile(path, json.pretty())

proc add*(pm: var ProfileManager, name, path: string) =
  # Проверяем, что имя не пустое
  if name.strip().len == 0:
    raise newException(ValueError, "Profile name cannot be empty")
  
  # Проверяем, что путь существует
  if not fileExists(path):
    raise newException(ValueError, "Compiler not found: " & path)
  
  let p = Profile(name: name, path: path, extraFlags: @[])
  pm.profiles[name] = p
  pm.save()

proc delete*(pm: var ProfileManager, name: string) =
  if name == "auto":
    raise newException(ValueError, "Cannot delete 'auto' profile")
  
  if not pm.profiles.hasKey(name):
    raise newException(ValueError, "Profile not found: " & name)
  
  pm.profiles.del(name)
  pm.save()

proc getProfile*(pm: ProfileManager, name: string): Profile =
  if pm.profiles.hasKey(name):
    return pm.profiles[name]
  raise newException(ValueError, "Profile not found: " & name)

proc listProfiles*(pm: ProfileManager): seq[Profile] =
  result = @[]
  for _, p in pm.profiles:
    result.add(p)