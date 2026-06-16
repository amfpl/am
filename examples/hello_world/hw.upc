#!: comment
#[main]
  version="0.1.0"
  realVersion="MyDesiredVersion"
  name="Example"

#[build]
  main={./src/main.am}
  platform=@["win", "linux"]
  test=[:test_build]
  release=[:release_build]

#[test_build]
  outfile=("test_" + name + "-" + version)
  outpath={./testificate/}

#[release_build]
  outfile=(name + "-" + version)
  outpath={./bin/}

#[license]
  display="Apache-2.0"
  path={./LICENSE.txt}
  notice=[:noticing]

#[noticing]
  enabled=true
  path={./NOTICE.txt}

#[repository]
  url="https://github.com/ampl/am"