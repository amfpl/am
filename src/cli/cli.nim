import std/exitprocs
import std/terminal
import core/diagnostics
import cli/args
import cli/commands/build
import cli/commands/test
import cli/commands/add
import cli/commands/delete
import cli/commands/list  # если добавили

proc run*() =
  addExitProc(resetAttributes)
  
  try:
    let args = parseArgs()
    
    case args.command:
    of CmdHelp:
      printHelp()
    of CmdVersion:
      printVersion()
    of CmdBuild:
      cmdBuild(args)
    of CmdTest:
      cmdTest(args)
    of CmdAdd:
      cmdAdd(args)
    of CmdDelete:
      cmdDelete(args)
      
  except UsageError as e:
    styledEcho styleBright, fgRed, "[Error] ", resetStyle, e.msg
    printHelp()
    quit(1)
    
  except CompilerError as e:
    styledEcho styleBright, fgRed, "[Error] ", resetStyle, e.msg
    quit(1)
    
  except:
    styledEcho styleBright, fgRed, "[Fatal] ", resetStyle, getCurrentExceptionMsg()
    quit(1)