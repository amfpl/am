import std/parseopt
import std/strutils

type
  Command* = enum
    CmdHelp
    CmdVersion
    CmdBuild
    CmdTest
    CmdAdd
    CmdDelete

  BuildOptions* = object
    configPath*: string
    saveC*: bool
    ast*: bool
    tokens*: bool
    verbose*: bool
    profile*: string  # "auto" или имя пользовательского профиля

  TestOptions* = object
    configPath*: string
    saveC*: bool
    ast*: bool
    tokens*: bool
    verbose*: bool
    profile*: string

  AddOptions* = object
    name*: string      # Любое имя, которое придумает пользователь
    path*: string      # Путь к компилятору

  DeleteOptions* = object
    name*: string      # Имя профиля для удаления

  Args* = object
    command*: Command
    build*: BuildOptions
    test*: TestOptions
    add*: AddOptions
    delete*: DeleteOptions

type
  UsageError* = object of ValueError

proc parseArgs*(): Args =
  var p = initOptParser()
  var positional: seq[string] = @[]
  
  # Временные переменные
  var saveC = false
  var ast = false
  var tokens = false
  var verbose = false
  var profile = "auto"  # По умолчанию auto
  
  # Парсим флаги
  for kind, key, val in p.getopt():
    case kind
    of cmdArgument:
      positional.add(key)
      
    of cmdLongOption, cmdShortOption:
      case key
      of "help", "h":
        return Args(command: CmdHelp)
      of "version", "v":
        return Args(command: CmdVersion)
      of "save-c":
        saveC = true
      of "ast":
        ast = true
      of "tokens":
        tokens = true
      of "verbose":
        verbose = true
      of "profile":
        if val.len > 0:
          profile = val
        else:
          # Поддержка --profile gcc
          var next = p.getopt()
          if next.kind == cmdArgument:
            profile = next.key
          else:
            raise UsageError("--profile requires a value")
    
    of cmdEnd:
      discard
  
  if positional.len == 0:
    raise UsageError("No command specified")
  
  let cmd = positional[0].toLowerAscii()
  
  case cmd
  of "build":
    if positional.len < 2:
      raise UsageError("build requires config path")
      
    result.command = CmdBuild
    result.build = BuildOptions(
      configPath: positional[1],
      saveC: saveC,
      ast: ast,
      tokens: tokens,
      verbose: verbose,
      profile: profile
    )
    
  of "test":
    if positional.len < 2:
      raise UsageError("test requires config path")
      
    result.command = CmdTest
    result.test = TestOptions(
      configPath: positional[1],
      saveC: saveC,
      ast: ast,
      tokens: tokens,
      verbose: verbose,
      profile: profile
    )
    
  of "add":
    # am add "mygcc" : "/usr/bin/gcc-13"
    # am add "myclang" : "/usr/bin/clang-15"
    # am add "tcc" : "./tcc/tcc.exe"
    if positional.len < 3:
      raise UsageError("add requires: name : path")
    
    let name = positional[1]
    var idx = 2
    if positional[idx] == ":":
      idx += 1
    if idx >= positional.len:
      raise UsageError("add requires path after ':'")
    let path = positional[idx]
    
    result.command = CmdAdd
    result.add = AddOptions(name: name, path: path)
    
  of "delete":
    # am delete "mygcc"
    if positional.len < 2:
      raise UsageError("delete requires profile name")
      
    result.command = CmdDelete
    result.delete = DeleteOptions(name: positional[1])
    
  of "help", "-h", "--help":
    return Args(command: CmdHelp)
    
  of "version", "-v", "--version":
    return Args(command: CmdVersion)
    
  else:
    raise UsageError("Unknown command: " & cmd)

proc printHelp*() =
  echo """
Am Compiler - High-level statically typed compiled language

USAGE:
  am [COMMAND] [OPTIONS] [ARGUMENTS]

COMMANDS:
  help, -h, --help       Show this help message
  version, -v, --version Show version information
  
  add <name> : <path>    Add compiler profile with custom name
                         Example: am add "mygcc" : "/usr/bin/gcc-13"
                         Example: am add "tcc" : "./tools/tcc.exe"
  
  delete <name>          Delete compiler profile
                         Example: am delete "mygcc"
  
  build <config.upc>     Build project from config
                         Example: am build myCoolProject.upc
  
  test <config.upc>      Build and run tests
                         Example: am test myCoolProject.upc

OPTIONS:
  --save-c               Save intermediate C code
  --profile=<name>       Use specific compiler profile (default: auto)
                         Profile names are created by user via 'add' command
  --verbose              Show detailed compilation output
  --ast                  Show AST after parsing
  --tokens               Show tokens after lexing

PROFILES:
  auto                   Automatically detect TCC in the same directory as amc.exe
                         Or fallback to system GCC/Clang/CC
  
  <custom_name>          Any name you defined with 'add' command
                         Examples: mygcc, myclang, tcc, msvc2022, etc.

EXAMPLES:
  # Add custom profiles
  am add "gcc13" : "/usr/bin/gcc-13"
  am add "clang16" : "/opt/clang+llvm-16.0.0/bin/clang"
  am add "tcc" : "./third_party/tcc/tcc.exe"
  
  # Build with specific profile
  am build project.upc --profile=gcc13 --verbose
  
  # Build with auto-detection
  am build project.upc --profile=auto --save-c
  
  # Delete profile
  am delete "clang16"
  
  # Show AST and tokens
  am build project.upc --ast --tokens
"""