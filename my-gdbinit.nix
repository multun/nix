let peda_repo = builtins.fetchGit {
    url = "https://github.com/longld/peda.git";
    rev = "f76c34d5e0c1f8e5603d5f03a794d096507c402e";
    };
in
builtins.toFile "gdbinit" ''
  source ${peda_repo}/peda.py
''
