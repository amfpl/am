# add.nim
import cli/profiles/manager
import cli/args
import core/logger

proc cmdAdd*(args: Args) =
  let opts = args.add
  
  var pm = ProfileManager.load()
  pm.add(opts.name, opts.path)
  
  info("Profile added: ", opts.name, " -> ", opts.path)