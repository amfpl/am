# delete.nim
import cli/profiles/manager
import cli/args
import core/logger

proc cmdDelete*(args: Args) =
  let opts = args.delete
  
  if opts.name == "auto":
    error("Cannot delete 'auto' profile")
    return
  
  var pm = ProfileManager.load()
  pm.delete(opts.name)
  
  info("Profile deleted: ", opts.name)