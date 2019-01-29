{ lib }:

let
  concatStringsSep = lib.strings.concatStringsSep;
in
{
  # ========================= #
  # User-defined functions    #
  # ========================= #
  functions = (concatStringsSep "\n" [
    ''
    # Function safe_path_add
    # @description add path to $PATH variable, if it is not already there.
    function safe_path_add {
      if [ -d "$1" ]; then
        if [[ "$PATH" =~ $1 ]]; then
          export PATH="$1:$PATH"
        elif [[ "$PATH" == *"$1"* ]]; then
          # echo "ADDING WITH FALLBACK CHECK $1"
          export PATH="$1:$PATH"
        elif echo "$PATH" | grep -o -E "(^|:)$1" | head -1 &> /dev/null; then
          # echo "ADDING WITH SLOWER, GREP FALLBACK"
          export PATH="$1:$PATH"
        fi
      fi
    }
    ''

    ''
    function can_safe_add {
      local strings="$1"
      local newstr="$2"

      if [ -d "$newstr" ]; then
        if [[ "$strings" =~ $newstr ]]; then
          # exists in end? but we add????
          return 0
        elif [[ "$strings" == *"$newstr"* ]]; then
          # exists in middle? but we add????
          return 0
        elif echo "$strings" | grep -o -E "(^|:)$newstr" | head -1 &> /dev/null; then
          # exists in beginning? but we add????
          return 0
        fi
      fi
      return 1
    }
    ''

    "
    # Function safe_prompt_add
    # @description add a command to the $PROMPT_COMMAND only if it is not already present
    function safe_prompt_add {
      local promptcmd
      promptcmd=\"\${PROMPT_COMMAND:-}\"
      if [[ \"$promptcmd\" != *\"$1\"* ]]; then
        export PROMPT_COMMAND=\"$1; $promptcmd\"
      fi
    }
    "

    "
    function find_git_branch {
      # Based on: http://stackoverflow.com/a/13003854/170413
      local branch tag_0 tag t0 SLOW_DIR
      SLOW_DIR=$HOME/.bash/_find_git_brach.last
      MILLI_CAP=40
      touch \"$SLOW_DIR\"

      if branch=$(\\git rev-parse --abbrev-ref HEAD 2> /dev/null) && [[ \"$branch\" == \"HEAD\" ]]; then
        if [[ \"$(\\cat \"$SLOW_DIR\")\" == \"$PWD\" ]]; then
          branch=\"$(\\git rev-parse --short=7 HEAD)-notags\"
        else
          t0=$(date +%s%3N)
          tag_0=\"$(\\git describe --tags --abbrev=0 2> /dev/null)\"
          tdiff=$(($(date +%s%3N)-t0))

          if (( tdiff > MILLI_CAP )); then
            echo \"$PWD\" > \"$SLOW_DIR\"
            branch=\"$(\\git rev-parse --short=7 HEAD)-notags\"
          else
            echo \"\" > \"$SLOW_DIR\"

            tag=\"$(\\git describe --tags 2> /dev/null)\"

            branch=\"\${branch//[^a-z0-9\\/]/-}\"
            if [[ -n \"$tag\" ]] && [[ \"$tag_0\" == \"$tag\" ]]; then
              branch=\"tag:\${tag//[^a-z0-9\\/]/.}\"

            elif [[ \"$branch\" == \"HEAD\" ]]; then
              branch=\"$(\\git rev-parse --short=7 HEAD)\"
            fi
          fi
        fi
      fi
      echo \"$branch\"
    }
    "

    ''
    function find_git_dirty {
      # find all new files, but only show the first one (we don't need more)
      # git ls-files --others --exclude-standard | head -n 1
      # See https://stackoverflow.com/questions/11122410/fastest-way-to-get-git-status-in-bash
      # for more speed tips
      if [[ "$(git status -uno --porcelain 2> /dev/null)" != "" ]]; then
        echo '*'
      fi
    }
    ''

    ''
    # Function safe_source
    function safe_source {
      # File may not exist, so don't follow for shellcheck linting (SC1090).
      # shellcheck source=/dev/null
      [[ ! -f "$1" ]] || source "$1"
    }
    ''

    ''
    # Function append_history
    # @description After each command, append to the history file and reread it. To be used in $PROMPT_COMMAND
    function append_history {
      history -a; history -c; history -r;
    }
    ''

    ''
    # Function append_history
    # @description log all commands to a logfile. To be used in $PROMPT_COMMAND
    function log_all_commands {
       if [ "$(id -u)" -ne 0 ]; then
         echo "$(date '+%Y-%m-%d.%H:%M:%S') $(pwd) $(history 1)" >> ~/.bash/log/bash-history-"$(date '+%Y-%m-%d')".log
       fi
    }
    ''

    ''
    # Function myReload
    # @description source bashrc if in shell, rebuild stack if in stack project
    function myReload {
      # if [ -z "`ls | grep 'stack.yaml'`" ]; then
        exec "$SHELL"
      #else
      #  stack build
      #fi
    }
    ''

    "
    # Function virtualenvPrompt
    # @description because of numerous PROMPT_COMMANDs, virtualenv gets overwritten.
    # Requires virtual environments to be written to a path including the phrase \"virtualenv\"
    #
    # @mutates variable venv_prompt
    function virtualenvPrompt {
      if test -z \"$VIRTUAL_ENV\" ; then
        venv_prompt=\"\"
      else
        venv_prompt=\"\${BLUE}[$(basename \\\"\"$VIRTUAL_ENV\"\\\")]\${RESET} \"
      fi
      export venv_prompt
    }
    "

    "
    # Function dotFolder
    # @description touch personal dot folder if it does not exist
    function dotFolder {
      if [ ! -d \"$HOME/.stites/\" ]; then
        mkdir ~/.stites
      fi
    }
    "

    ''
    # Function notes
    # @description open up notes
    function notes {
      dotFolder
      vim ~/.stites
    }
    ''

    ''
    # Function workingmemory
    # @description open up workingmemory
    function workingmemory {
      dotFolder
      vim ~/.stites/workingmemory.md
    }
    ''

    "
    function draft {
      local DRAFT_FOLDER=\"$HOME/.stites/emails/drafts/\"
      mkdir -p \"$DRAFT_FOLDER\"
      local NUM_DRAFTS
      NUM_DRAFTS=$(\\exa -l \"$DRAFT_FOLDER\" | wc -l)

      if echo \"$NUM_DRAFTS\" >> /dev/null; then
        echo \"You have $NUM_DRAFTS in $DRAFT_FOLDER\"
        sleep 1
      fi
      local NEXT_DRAFT=$(( NUM_DRAFTS+1 ))
      nvim -c 'set tw=72 et' '+/^$' \"\${DRAFT_FOLDER}draft_\${NEXT_DRAFT}\"
    }
    "

    ''
    # Function stack-intero
    # @description run stack ghci with intero as the backend
    function stackintero {
      stack ghci --with-ghc intero
    }
    ''

    ''
    function retry {
      for _ in 1 2 3 4 5; do
        "$@" && break
        if $?; then
          sleep 15
        fi
      done
    }
    ''

    ''
    function note {
      vim "$HOME/.stites/$1"
    }
    ''
    ]);

  # ========================= #
  # Export functions          #
  # ========================= #
  initConfig = ''
    export -f safe_path_add
    export -f safe_source
    export -f safe_prompt_add
    export -f append_history;
    export -f log_all_commands;
    export -f myReload
    export -f virtualenvPrompt
    export -f dotFolder
    export -f notes
    export -f workingmemory
    export -f stackintero
    export -f retry
    export -f note
  '';
}
