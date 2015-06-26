CH_INSTALL_DIR=$HOME/.ch/install
CH_ENV_DIR=$HOME/.ch/env

# Core {{{

function _ch-abort() {
  echo "error: $@" >&2
  return 1
}

function _ch-path-add() {
  local old_path="$(eval "echo \"\$$1\"")"
  [ -n "$old_path" ] && old_path=":$old_path"
  export $1="${2}${old_path}"
}

function _ch-path-remove() {
  local old_path=":$(eval "echo \"\$$1\""):"
  old_path="${old_path/:$2:/:}"
  old_path="${old_path#:}"
  old_path="${old_path%:}"
  eval "$1=\"$old_path\""
}

function _ch-complete() {
  eval "_$1() { _arguments \"1:version:(\$(ls \$CH_INSTALL_DIR/$2))\"}"
  compdef "_$1" "$1"
}

# }}}

# Go {{{

function ch-go-reset() {
  [ -n "$GOPATH" ] && _ch-path-remove PATH "$GOPATH/bin"
  [ -n "$GOROOT" ] && _ch-path-remove PATH "$GOROOT/bin"
  unset GOPATH GOROOT
}

function ch-go() {
  local go_root="$CH_INSTALL_DIR/go/$1"
  if [ ! -d "$go_root" ]; then
    _ch-abort "no go version matching '$1'"
    return
  fi

  ch-go-reset
  _ch-path-add GOROOT "$go_root"
  _ch-path-add GOPATH "$CH_ENV_DIR/go/$1"
  _ch-path-add PATH "$GOPATH/bin"
  _ch-path-add PATH "$GOROOT/bin"
}
_ch-complete ch-go go

# }}}

# Ruby {{{

function ch-rb-reset() {
  [ -n "$RUBY_ROOT" ] && _ch-path-remove PATH "$RUBY_ROOT/bin"
  [ -n "$GEM_HOME" ] && _ch-path-remove PATH "$GEM_HOME/bin"
  [ -n "$GEM_HOME" ] && _ch-path-remove GEM_PATH "$GEM_HOME"
  [ -n "$GEM_ROOT" ] && _ch-path-remove GEM_PATH "$GEM_ROOT"
  [ -z "$GEM_PATH" ] && unset GEM_PATH
  unset RUBY_ROOT GEM_ROOT GEM_HOME
}

function ch-rb() {
  local rb_root="$CH_INSTALL_DIR/ruby/$1"
  if [ ! -d "$rb_root" ]; then
    _ch-abort "no ruby version matching '$1'"
    return
  fi

  ch-rb-reset
  export RUBY_ROOT="$rb_root"
  export GEM_ROOT="$($rb_root/bin/ruby -e 'puts Gem.default_dir')"
  export GEM_HOME="$CH_ENV_DIR/ruby/$1"
  _ch-path-add GEM_PATH "$GEM_ROOT"
  _ch-path-add GEM_PATH "$GEM_HOME"
  _ch-path-add PATH "$RUBY_ROOT/bin"
  _ch-path-add PATH "$GEM_HOME/bin"
}
_ch-complete ch-rb ruby

# }}}

# Python {{{

function ch-py-reset() {
  [ -n "$PYTHON_ROOT" ] && _ch-path-remove PATH "$PYTHON_ROOT/bin"
  unset PYTHON_ROOT
}

function ch-py() {
  local py_root="$CH_INSTALL_DIR/python/$1"
  if [ ! -d "$py_root" ]; then
    _ch-abort "no python version matching '$1'"
    return
  fi

  ch-py-reset
  export PYTHON_ROOT="$py_root"
  _ch-path-add PATH "$PYTHON_ROOT/bin"
}
_ch-complete ch-py python

# }}}

# vim:foldmethod=marker
