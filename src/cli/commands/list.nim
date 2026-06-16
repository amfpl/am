# src/cli/commands/list.nim
import cli/profiles/manager
import core/logger

proc cmdList*() =
  let pm = ProfileManager.load()
  let profiles = pm.listProfiles()
  
  if profiles.len == 0:
    info("No profiles defined. Use 'am add' to create one.")
    return
  
  info("Available profiles:")
  for p in profiles:
    echo "  ", p.name, " -> ", p.path