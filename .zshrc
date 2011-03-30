# Filename:      /etc/zsh/zshrc
# Purpose:       config file for zsh (z shell)
# Authors:       grml-team (grml.org), (c) Michael Prokop <mika@grml.org>
# Bug-Reports:   see http://grml.org/bugs/
# License:       This file is licensed under the GPL v2.
################################################################################
# This file is sourced only for interactive shells. It
# should contain commands to set up aliases, functions,
# options, key bindings, etc.
#
# Global Order: zshenv, zprofile, zshrc, zlogin
################################################################################

# USAGE
# If you are using this file as your ~/.zshrc file, please use ~/.zshrc.pre
# and ~/.zshrc.local for your own customisations. The former file is read
# before ~/.zshrc, the latter is read after it. Also, consider reading the
# refcard and the reference manual for this setup, both available from:
#     <http://grml.org/zsh/>

# Contributing:
# If you want to help to improve grml's zsh setup, clone the grml-etc-core
# repository from git.grml.org:
#   git clone git://git.grml.org/grml-etc-core.git
#
# Make your changes, commit them; use 'git format-patch' to create a series
# of patches and send those to the following address via 'git send-email':
#   grml-etc-core@grml.org
#
# Doing so makes sure the right people get your patches for review and
# possibly inclusion.

# load .zshrc.pre to give the user the chance to overwrite the defaults
[[ -r ${HOME}/.zshrc.pre ]] && source ${HOME}/.zshrc.pre

# {{{ check for version/system
# check for versions (compatibility reasons)
is4(){
    [[ $ZSH_VERSION == <4->* ]] && return 0
    return 1
}

is41(){
    [[ $ZSH_VERSION == 4.<1->* || $ZSH_VERSION == <5->* ]] && return 0
    return 1
}

is42(){
    [[ $ZSH_VERSION == 4.<2->* || $ZSH_VERSION == <5->* ]] && return 0
    return 1
}

is425(){
    [[ $ZSH_VERSION == 4.2.<5->* || $ZSH_VERSION == 4.<3->* || $ZSH_VERSION == <5->* ]] && return 0
    return 1
}

is43(){
    [[ $ZSH_VERSION == 4.<3->* || $ZSH_VERSION == <5->* ]] && return 0
    return 1
}

is433(){
    [[ $ZSH_VERSION == 4.3.<3->* || $ZSH_VERSION == 4.<4->* || $ZSH_VERSION == <5->* ]] && return 0
    return 1
}

is439(){
    [[ $ZSH_VERSION == 4.3.<9->* || $ZSH_VERSION == 4.<4->* || $ZSH_VERSION == <5->* ]] && return 0
    return 1
}

#f1# Checks whether or not you're running grml
isgrml(){
    [[ -f /etc/grml_version ]] && return 0
    return 1
}

#f1# Checks whether or not you're running a grml cd
isgrmlcd(){
    [[ -f /etc/grml_cd ]] && return 0
    return 1
}

if isgrml ; then
#f1# Checks whether or not you're running grml-small
    isgrmlsmall() {
        [[ ${${${(f)"$(</etc/grml_version)"}%% *}##*-} == 'small' ]] && return 0 ; return 1
    }
else
    isgrmlsmall() { return 1 }
fi

isdarwin(){
    [[ $OSTYPE == darwin* ]] && return 0
    return 1
}

#f1# are we running within an utf environment?
isutfenv() {
    case "$LANG $CHARSET $LANGUAGE" in
        *utf*) return 0 ;;
        *UTF*) return 0 ;;
        *)     return 1 ;;
    esac
}

# check for user, if not running as root set $SUDO to sudo
(( EUID != 0 )) && SUDO='sudo' || SUDO=''

# change directory to home on first invocation of zsh
# important for rungetty -> autologin
# Thanks go to Bart Schaefer!
isgrml && checkhome() {
    if [[ -z "$ALREADY_DID_CD_HOME" ]] ; then
        export ALREADY_DID_CD_HOME=$HOME
        cd
    fi
}

# check for zsh v3.1.7+

if ! [[ ${ZSH_VERSION} == 3.1.<7->*      \
     || ${ZSH_VERSION} == 3.<2->.<->*    \
     || ${ZSH_VERSION} == <4->.<->*   ]] ; then

    printf '-!-\n'
    printf '-!- In this configuration we try to make use of features, that only\n'
    printf '-!- require version 3.1.7 of the shell; That way this setup can be\n'
    printf '-!- used with a wide range of zsh versions, while using fairly\n'
    printf '-!- advanced features in all supported versions.\n'
    printf '-!-\n'
    printf '-!- However, you are running zsh version %s.\n' "$ZSH_VERSION"
    printf '-!-\n'
    printf '-!- While this *may* work, it might as well fail.\n'
    printf '-!- Please consider updating to at least version 3.1.7 of zsh.\n'
    printf '-!-\n'
    printf '-!- DO NOT EXPECT THIS TO WORK FLAWLESSLY!\n'
    printf '-!- If it does today, you'\''ve been lucky.\n'
    printf '-!-\n'
    printf '-!- Ye been warned!\n'
    printf '-!-\n'

    function zstyle() { : }
fi

# autoload wrapper - use this one instead of autoload directly
# We need to define this function as early as this, because autoloading
# 'is-at-least()' needs it.
function zrcautoload() {
    emulate -L zsh
    setopt extended_glob
    local fdir ffile
    local -i ffound

    ffile=$1
    (( found = 0 ))
    for fdir in ${fpath} ; do
        [[ -e ${fdir}/${ffile} ]] && (( ffound = 1 ))
    done

    (( ffound == 0 )) && return 1
    if [[ $ZSH_VERSION == 3.1.<6-> || $ZSH_VERSION == <4->* ]] ; then
        autoload -U ${ffile} || return 1
    else
        autoload ${ffile} || return 1
    fi
    return 0
}

# Load is-at-least() for more precise version checks
# Note that this test will *always* fail, if the is-at-least
# function could not be marked for autoloading.
zrcautoload is-at-least || is-at-least() { return 1 }

# }}}

# {{{ set some important options (as early as possible)
# Please update these tags, if you change the umask settings below.
#o# r_umask     002
#o# r_umaskstr  rwxrwxr-x
#o# umask       022
#o# umaskstr    rwxr-xr-x
(( EUID != 0 )) && umask 002 || umask 022

setopt append_history       # append history list to the history file (important for multiple parallel zsh sessions!)
is4 && setopt SHARE_HISTORY # import new commands from the history file also in other zsh-session
setopt extended_history     # save each command's beginning timestamp and the duration to the history file
is4 && setopt histignorealldups # If  a  new  command  line being added to the history
                            # list duplicates an older one, the older command is removed from the list
setopt histignorespace      # remove command lines from the history list when
                            # the first character on the line is a space
setopt auto_cd              # if a command is issued that can't be executed as a normal command,
                            # and the command is the name of a directory, perform the cd command to that directory
setopt extended_glob        # in order to use #, ~ and ^ for filename generation
                            # grep word *~(*.gz|*.bz|*.bz2|*.zip|*.Z) ->
                            # -> searches for word not in compressed files
                            # don't forget to quote '^', '~' and '#'!
setopt longlistjobs         # display PID when suspending processes as well
setopt notify               # report the status of backgrounds jobs immediately
setopt hash_list_all        # Whenever a command completion is attempted, make sure \
                            # the entire command path is hashed first.
setopt completeinword       # not just at the end
setopt nohup                # and don't kill them, either
setopt auto_pushd           # make cd push the old directory onto the directory stack.
setopt nonomatch            # try to avoid the 'zsh: no matches found...'
setopt nobeep               # avoid "beep"ing
setopt pushd_ignore_dups    # don't push the same dir twice.
setopt noglobdots           # * shouldn't match dotfiles. ever.
setopt noshwordsplit        # use zsh style word splitting
setopt unset                # don't error out when unset parameters are used

# }}}

# setting some default values {{{

NOCOR=${NOCOR:-0}
NOMENU=${NOMENU:-0}
NOPRECMD=${NOPRECMD:-0}
COMMAND_NOT_FOUND=${COMMAND_NOT_FOUND:-0}
GRML_ZSH_CNF_HANDLER=${GRML_ZSH_CNF_HANDLER:-/usr/share/command-not-found/command-not-found}
BATTERY=${BATTERY:-0}
GRMLSMALL_SPECIFIC=${GRMLSMALL_SPECIFIC:-1}
GRML_ALWAYS_LOAD_ALL=${GRML_ALWAYS_LOAD_ALL:-0}
ZSH_NO_DEFAULT_LOCALE=${ZSH_NO_DEFAULT_LOCALE:-0}

# }}}

# utility functions {{{
# this function checks if a command exists and returns either true
# or false. This avoids using 'which' and 'whence', which will
# avoid problems with aliases for which on certain weird systems. :-)
# Usage: check_com [-c|-g] word
#   -c  only checks for external commands
#   -g  does the usual tests and also checks for global aliases
check_com() {
    emulate -L zsh
    local -i comonly gatoo

    if [[ $1 == '-c' ]] ; then
        (( comonly = 1 ))
        shift
    elif [[ $1 == '-g' ]] ; then
        (( gatoo = 1 ))
    else
        (( comonly = 0 ))
        (( gatoo = 0 ))
    fi

    if (( ${#argv} != 1 )) ; then
        printf 'usage: check_com [-c] <command>\n' >&2
        return 1
    fi

    if (( comonly > 0 )) ; then
        [[ -n ${commands[$1]}  ]] && return 0
        return 1
    fi

    if   [[ -n ${commands[$1]}    ]] \
      || [[ -n ${functions[$1]}   ]] \
      || [[ -n ${aliases[$1]}     ]] \
      || [[ -n ${reswords[(r)$1]} ]] ; then

        return 0
    fi

    if (( gatoo > 0 )) && [[ -n ${galiases[$1]} ]] ; then
        return 0
    fi

    return 1
}

# creates an alias and precedes the command with
# sudo if $EUID is not zero.
salias() {
    emulate -L zsh
    local only=0 ; local multi=0
    while [[ $1 == -* ]] ; do
        case $1 in
            (-o) only=1 ;;
            (-a) multi=1 ;;
            (--) shift ; break ;;
            (-h)
                printf 'usage: salias [-h|-o|-a] <alias-expression>\n'
                printf '  -h      shows this help text.\n'
                printf '  -a      replace '\'' ; '\'' sequences with '\'' ; sudo '\''.\n'
                printf '          be careful using this option.\n'
                printf '  -o      only sets an alias if a preceding sudo would be needed.\n'
                return 0
                ;;
            (*) printf "unkown option: '%s'\n" "$1" ; return 1 ;;
        esac
        shift
    done

    if (( ${#argv} > 1 )) ; then
        printf 'Too many arguments %s\n' "${#argv}"
        return 1
    fi

    key="${1%%\=*}" ;  val="${1#*\=}"
    if (( EUID == 0 )) && (( only == 0 )); then
        alias -- "${key}=${val}"
    elif (( EUID > 0 )) ; then
        (( multi > 0 )) && val="${val// ; / ; sudo }"
        alias -- "${key}=sudo ${val}"
    fi

    return 0
}

# a "print -l ${(u)foo}"-workaround for pre-4.2.0 shells
# usage: uprint foo
#   Where foo is the *name* of the parameter you want printed.
#   Note that foo is no typo; $foo would be wrong here!
if ! is42 ; then
    uprint () {
        emulate -L zsh
        local -a u
        local w
        local parameter=$1

        if [[ -z ${parameter} ]] ; then
            printf 'usage: uprint <parameter>\n'
            return 1
        fi

        for w in ${(P)parameter} ; do
            [[ -z ${(M)u:#$w} ]] && u=( $u $w )
        done

        builtin print -l $u
    }
fi

# Check if we can read given files and source those we can.
xsource() {
    if (( ${#argv} < 1 )) ; then
        printf 'usage: xsource FILE(s)...\n' >&2
        return 1
    fi

    while (( ${#argv} > 0 )) ; do
        [[ -r "$1" ]] && source "$1"
        shift
    done
    return 0
}

# Check if we can read a given file and 'cat(1)' it.
xcat() {
    emulate -L zsh
    if (( ${#argv} != 1 )) ; then
        printf 'usage: xcat FILE\n' >&2
        return 1
    fi

    [[ -r $1 ]] && cat $1
    return 0
}

# Remove these functions again, they are of use only in these
# setup files. This should be called at the end of .zshrc.
xunfunction() {
    emulate -L zsh
    local -a funcs
    funcs=(salias xcat xsource xunfunction zrcautoload)

    for func in $funcs ; do
        [[ -n ${functions[$func]} ]] \
            && unfunction $func
    done
    return 0
}

# this allows us to stay in sync with grml's zshrc and put own
# modifications in ~/.zshrc.local
zrclocal() {
    xsource "/etc/zsh/zshrc.local"
    xsource "${HOME}/.zshrc.local"
    return 0
}

#}}}

# locale setup {{{
if (( ZSH_NO_DEFAULT_LOCALE == 0 )); then
    xsource "/etc/default/locale"
fi

for var in LANG LC_ALL LC_MESSAGES ; do
    [[ -n ${(P)var} ]] && export $var
done

xsource "/etc/sysconfig/keyboard"

TZ=$(xcat /etc/timezone)
# }}}

# {{{ set some variables
if check_com -c vim ; then
#v#
    export EDITOR=${EDITOR:-vim}
else
    export EDITOR=${EDITOR:-vi}
fi

#v#
export PAGER=${PAGER:-less}

#v#
export MAIL=${MAIL:-/var/mail/$USER}

# if we don't set $SHELL then aterm, rxvt,.. will use /bin/sh or /bin/bash :-/
export SHELL='/bin/zsh'

# color setup for ls:
check_com -c dircolors && eval $(dircolors -b)
# color setup for ls on OS X:
isdarwin && export CLICOLOR=1

# do MacPorts setup on darwin
if isdarwin && [[ -d /opt/local ]]; then
    # Note: PATH gets set in /etc/zprofile on Darwin, so this can't go into
    # zshenv.
    PATH="/opt/local/bin:/opt/local/sbin:$PATH"
    MANPATH="/opt/local/share/man:$MANPATH"
fi
# do Fink setup on darwin
isdarwin && xsource /sw/bin/init.sh

# load our function and completion directories
for fdir in /usr/share/grml/zsh/completion /usr/share/grml/zsh/functions; do
    fpath=( ${fdir} ${fdir}/**/*(/N) ${fpath} )
    if [[ ${fpath} == '/usr/share/grml/zsh/functions' ]] ; then
        for func in ${fdir}/**/[^_]*[^~](N.) ; do
            zrcautoload ${func:t}
        done
    fi
done
unset fdir func

# support colors in less
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

MAILCHECK=30       # mailchecks
REPORTTIME=5       # report about cpu-/system-/user-time of command if running longer than 5 seconds
watch=(notme root) # watch for everyone but me and root

# automatically remove duplicates from these arrays
typeset -U path cdpath fpath manpath
# }}}

# {{{ keybindings
if [[ "$TERM" != emacs ]] ; then
    [[ -z "$terminfo[kdch1]" ]] || bindkey -M emacs "$terminfo[kdch1]" delete-char
    [[ -z "$terminfo[khome]" ]] || bindkey -M emacs "$terminfo[khome]" beginning-of-line
    [[ -z "$terminfo[kend]"  ]] || bindkey -M emacs "$terminfo[kend]"  end-of-line
    [[ -z "$terminfo[kdch1]" ]] || bindkey -M vicmd "$terminfo[kdch1]" vi-delete-char
    [[ -z "$terminfo[khome]" ]] || bindkey -M vicmd "$terminfo[khome]" vi-beginning-of-line
    [[ -z "$terminfo[kend]"  ]] || bindkey -M vicmd "$terminfo[kend]"  vi-end-of-line
    [[ -z "$terminfo[cuu1]"  ]] || bindkey -M viins "$terminfo[cuu1]"  vi-up-line-or-history
    [[ -z "$terminfo[cuf1]"  ]] || bindkey -M viins "$terminfo[cuf1]"  vi-forward-char
    [[ -z "$terminfo[kcuu1]" ]] || bindkey -M viins "$terminfo[kcuu1]" vi-up-line-or-history
    [[ -z "$terminfo[kcud1]" ]] || bindkey -M viins "$terminfo[kcud1]" vi-down-line-or-history
    [[ -z "$terminfo[kcuf1]" ]] || bindkey -M viins "$terminfo[kcuf1]" vi-forward-char
    [[ -z "$terminfo[kcub1]" ]] || bindkey -M viins "$terminfo[kcub1]" vi-backward-char
    # ncurses stuff:
    [[ "$terminfo[kcuu1]" == $'\eO'* ]] && bindkey -M viins "${terminfo[kcuu1]/O/[}" vi-up-line-or-history
    [[ "$terminfo[kcud1]" == $'\eO'* ]] && bindkey -M viins "${terminfo[kcud1]/O/[}" vi-down-line-or-history
    [[ "$terminfo[kcuf1]" == $'\eO'* ]] && bindkey -M viins "${terminfo[kcuf1]/O/[}" vi-forward-char
    [[ "$terminfo[kcub1]" == $'\eO'* ]] && bindkey -M viins "${terminfo[kcub1]/O/[}" vi-backward-char
    [[ "$terminfo[khome]" == $'\eO'* ]] && bindkey -M viins "${terminfo[khome]/O/[}" beginning-of-line
    [[ "$terminfo[kend]"  == $'\eO'* ]] && bindkey -M viins "${terminfo[kend]/O/[}"  end-of-line
    [[ "$terminfo[khome]" == $'\eO'* ]] && bindkey -M emacs "${terminfo[khome]/O/[}" beginning-of-line
    [[ "$terminfo[kend]"  == $'\eO'* ]] && bindkey -M emacs "${terminfo[kend]/O/[}"  end-of-line
fi

## keybindings (run 'bindkeys' for details, more details via man zshzle)
# use emacs style per default:
bindkey -e
# use vi style:
# bindkey -v

#if [[ "$TERM" == screen ]] ; then
bindkey '\e[1~' beginning-of-line       # home
bindkey '\e[4~' end-of-line             # end
bindkey '\e[A'  up-line-or-search       # cursor up
bindkey '\e[B'  down-line-or-search     # <ESC>-

bindkey '^xp'   history-beginning-search-backward
bindkey '^xP'   history-beginning-search-forward
# bindkey -s '^L' "|less\n"             # ctrl-L pipes to less
# bindkey -s '^B' " &\n"                # ctrl-B runs it in the background
# if terminal type is set to 'rxvt':
bindkey '\e[7~' beginning-of-line       # home
bindkey '\e[8~' end-of-line             # end
#fi

# insert unicode character
# usage example: 'ctrl-x i' 00A7 'ctrl-x i' will give you an §
# See for example http://unicode.org/charts/ for unicode characters code
zrcautoload insert-unicode-char
zle -N insert-unicode-char
#k# Insert Unicode character
bindkey '^Xi' insert-unicode-char

#m# k Shift-tab Perform backwards menu completion
if [[ -n "$terminfo[kcbt]" ]]; then
    bindkey "$terminfo[kcbt]" reverse-menu-complete
elif [[ -n "$terminfo[cbt]" ]]; then # required for GNU screen
    bindkey "$terminfo[cbt]"  reverse-menu-complete
fi

## toggle the ,. abbreviation feature on/off
# NOABBREVIATION: default abbreviation-state
#                 0 - enabled (default)
#                 1 - disabled
NOABBREVIATION=${NOABBREVIATION:-0}

grml_toggle_abbrev() {
    if (( ${NOABBREVIATION} > 0 )) ; then
        NOABBREVIATION=0
    else
        NOABBREVIATION=1
    fi
}

zle -N grml_toggle_abbrev
bindkey '^xA' grml_toggle_abbrev

# add a command line to the shells history without executing it
commit-to-history() {
    print -s ${(z)BUFFER}
    zle send-break
}
zle -N commit-to-history
bindkey "^x^h" commit-to-history

# only slash should be considered as a word separator:
slash-backward-kill-word() {
    local WORDCHARS="${WORDCHARS:s@/@}"
    # zle backward-word
    zle backward-kill-word
}
zle -N slash-backward-kill-word

#k# Kill everything in a word up to its last \kbd{/}
bindkey '\ev' slash-backward-kill-word
#k# Kill everything in a word up to its last \kbd{/}
bindkey '\e^h' slash-backward-kill-word
#k# Kill everything in a word up to its last \kbd{/}
bindkey '\e^?' slash-backward-kill-word

# use the new *-pattern-* widgets for incremental history search
if is439 ; then
    bindkey '^r' history-incremental-pattern-search-backward
    bindkey '^s' history-incremental-pattern-search-forward
fi
# }}}

# a generic accept-line wrapper {{{

# This widget can prevent unwanted autocorrections from command-name
# to _command-name, rehash automatically on enter and call any number
# of builtin and user-defined widgets in different contexts.
#
# For a broader description, see:
# <http://bewatermyfriend.org/posts/2007/12-26.11-50-38-tooltime.html>
#
# The code is imported from the file 'zsh/functions/accept-line' from
# <http://ft.bewatermyfriend.org/comp/zsh/zsh-dotfiles.tar.bz2>, which
# distributed under the same terms as zsh itself.

# A newly added command will may not be found or will cause false
# correction attempts, if you got auto-correction set. By setting the
# following style, we force accept-line() to rehash, if it cannot
# find the first word on the command line in the $command[] hash.
zstyle ':acceptline:*' rehash true

function Accept-Line() {
    emulate -L zsh
    local -a subs
    local -xi aldone
    local sub

    zstyle -a ":acceptline:${alcontext}" actions subs

    (( ${#subs} < 1 )) && return 0

    (( aldone = 0 ))
    for sub in ${subs} ; do
        [[ ${sub} == 'accept-line' ]] && sub='.accept-line'
        zle ${sub}

        (( aldone > 0 )) && break
    done
}

function Accept-Line-getdefault() {
    emulate -L zsh
    local default_action

    zstyle -s ":acceptline:${alcontext}" default_action default_action
    case ${default_action} in
        ((accept-line|))
            printf ".accept-line"
            ;;
        (*)
            printf ${default_action}
            ;;
    esac
}

function accept-line() {
    emulate -L zsh
    local -a cmdline
    local -x alcontext
    local buf com fname format msg default_action

    alcontext='default'
    buf="${BUFFER}"
    cmdline=(${(z)BUFFER})
    com="${cmdline[1]}"
    fname="_${com}"

    zstyle -t ":acceptline:${alcontext}" rehash \
        && [[ -z ${commands[$com]} ]]           \
        && rehash

    if    [[ -n ${reswords[(r)$com]} ]] \
       || [[ -n ${aliases[$com]}     ]] \
       || [[ -n ${functions[$com]}   ]] \
       || [[ -n ${builtins[$com]}    ]] \
       || [[ -n ${commands[$com]}    ]] ; then

        # there is something sensible to execute, just do it.
        alcontext='normal'
        zle Accept-Line

        default_action=$(Accept-Line-getdefault)
        zstyle -T ":acceptline:${alcontext}" call_default \
            && zle ${default_action}
        return
    fi

    if    [[ -o correct              ]] \
       || [[ -o correctall           ]] \
       && [[ -n ${functions[$fname]} ]] ; then

        # nothing there to execute but there is a function called
        # _command_name; a completion widget. Makes no sense to
        # call it on the commandline, but the correct{,all} options
        # will ask for it nevertheless, so warn the user.
        if [[ ${LASTWIDGET} == 'accept-line' ]] ; then
            # Okay, we warned the user before, he called us again,
            # so have it his way.
            alcontext='force'
            zle Accept-Line

            default_action=$(Accept-Line-getdefault)
            zstyle -T ":acceptline:${alcontext}" call_default \
                && zle ${default_action}
            return
        fi

        # prepare warning message for the user, configurable via zstyle.
        zstyle -s ":acceptline:${alcontext}" compwarnfmt msg

        if [[ -z ${msg} ]] ; then
            msg="%c will not execute and completion %f exists."
        fi

        zformat -f msg "${msg}" "c:${com}" "f:${fname}"

        zle -M -- "${msg}"
        return
    elif [[ -n ${buf//[$' \t\n']##/} ]] ; then
        # If we are here, the commandline contains something that is not
        # executable, which is neither subject to _command_name correction
        # and is not empty. might be a variable assignment
        alcontext='misc'
        zle Accept-Line

        default_action=$(Accept-Line-getdefault)
        zstyle -T ":acceptline:${alcontext}" call_default \
            && zle ${default_action}
        return
    fi

    # If we got this far, the commandline only contains whitespace, or is empty.
    alcontext='empty'
    zle Accept-Line

    default_action=$(Accept-Line-getdefault)
    zstyle -T ":acceptline:${alcontext}" call_default \
        && zle ${default_action}
}

zle -N accept-line
zle -N Accept-Line

# }}}

# power completion - abbreviation expansion {{{
# power completion / abbreviation expansion / buffer expansion
# see http://zshwiki.org/home/examples/zleiab for details
# less risky than the global aliases but powerful as well
# just type the abbreviation key and afterwards ',.' to expand it
declare -A abk
setopt extendedglob
setopt interactivecomments
abk=(
#   key   # value                  (#d additional doc string)
#A# start
    '...'  '../..'
    '....' '../../..'
    'BG'   '& exit'
    'C'    '| wc -l'
    'G'    '|& grep --color=auto '
    'H'    '| head'
    'Hl'   ' --help |& less -r'    #d (Display help in pager)
    'L'    '| less'
    'LL'   '|& less -r'
    'M'    '| most'
    'N'    '&>/dev/null'           #d (No Output)
    'R'    '| tr A-z N-za-m'       #d (ROT13)
    'SL'   '| sort | less'
    'S'    '| sort -u'
    'T'    '| tail'
    'V'    '|& vim -'
#A# end
    'co'   './configure && make && sudo make install'
)

globalias() {
    emulate -L zsh
    setopt extendedglob
    local MATCH

    if (( NOABBREVIATION > 0 )) ; then
        LBUFFER="${LBUFFER},."
        return 0
    fi

    matched_chars='[.-|_a-zA-Z0-9]#'
    LBUFFER=${LBUFFER%%(#m)[.-|_a-zA-Z0-9]#}
    LBUFFER+=${abk[$MATCH]:-$MATCH}
}

zle -N globalias
bindkey ",." globalias
# }}}

# {{{ autoloading
zrcautoload zmv    # who needs mmv or rename?
zrcautoload history-search-end

# we don't want to quote/espace URLs on our own...
# if autoload -U url-quote-magic ; then
#    zle -N self-insert url-quote-magic
#    zstyle ':url-quote-magic:*' url-metas '*?[]^()~#{}='
# else
#    print 'Notice: no url-quote-magic available :('
# fi
alias url-quote='autoload -U url-quote-magic ; zle -N self-insert url-quote-magic'

#m# k ESC-h Call \kbd{run-help} for the 1st word on the command line
alias run-help >&/dev/null && unalias run-help
for rh in run-help{,-git,-svk,-svn}; do
    zrcautoload $rh
done; unset rh

# completion system
if zrcautoload compinit ; then
    compinit || print 'Notice: no compinit available :('
else
    print 'Notice: no compinit available :('
    function zstyle { }
    function compdef { }
fi

is4 && zrcautoload zed # use ZLE editor to edit a file or function

is4 && \
for mod in complist deltochar mathfunc ; do
    zmodload -i zsh/${mod} 2>/dev/null || print "Notice: no ${mod} available :("
done

# autoload zsh modules when they are referenced
if is4 ; then
    zmodload -a  zsh/stat    zstat
    zmodload -a  zsh/zpty    zpty
    zmodload -ap zsh/mapfile mapfile
fi

if is4 && zrcautoload insert-files && zle -N insert-files ; then
    #k# Insert files
    bindkey "^Xf" insert-files # C-x-f
fi

bindkey ' '   magic-space    # also do history expansion on space
#k# Trigger menu-complete
bindkey '\ei' menu-complete  # menu completion via esc-i

# press esc-e for editing command line in $EDITOR or $VISUAL
if is4 && zrcautoload edit-command-line && zle -N edit-command-line ; then
    #k# Edit the current line in \kbd{\$EDITOR}
    bindkey '\ee' edit-command-line
fi

if is4 && [[ -n ${(k)modules[zsh/complist]} ]] ; then
    #k# menu selection: pick item but stay in the menu
    bindkey -M menuselect '\e^M' accept-and-menu-complete

    # accept a completion and try to complete again by using menu
    # completion; very useful with completing directories
    # by using 'undo' one's got a simple file browser
    bindkey -M menuselect '^o' accept-and-infer-next-history
fi

# press "ctrl-e d" to insert the actual date in the form yyyy-mm-dd
insert-datestamp() { LBUFFER+=${(%):-'%D{%Y-%m-%d}'}; }
zle -N insert-datestamp

#k# Insert a timestamp on the command line (yyyy-mm-dd)
bindkey '^Ed' insert-datestamp

# press esc-m for inserting last typed word again (thanks to caphuso!)
insert-last-typed-word() { zle insert-last-word -- 0 -1 };
zle -N insert-last-typed-word;

#k# Insert last typed word
bindkey "\em" insert-last-typed-word

function grml-zsh-fg() {
  if (( ${#jobstates} )); then
    zle .push-input
    [[ -o hist_ignore_space ]] && BUFFER=' ' || BUFFER=''
    BUFFER="${BUFFER}fg"
    zle .accept-line
  else
    zle -M 'No background jobs. Doing nothing.'
  fi
}
zle -N grml-zsh-fg
#k# A smart shortcut for \kbd{fg<enter>}
bindkey '^z' grml-zsh-fg

# run command line as user root via sudo:
sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
}
zle -N sudo-command-line

#k# Put the current command line into a \kbd{sudo} call
bindkey "^Os" sudo-command-line

### jump behind the first word on the cmdline.
### useful to add options.
function jump_after_first_word() {
    local words
    words=(${(z)BUFFER})

    if (( ${#words} <= 1 )) ; then
        CURSOR=${#BUFFER}
    else
        CURSOR=${#${words[1]}}
    fi
}
zle -N jump_after_first_word

bindkey '^x1' jump_after_first_word

# }}}

# {{{ history

ZSHDIR=$HOME/.zsh

#v#
HISTFILE=$HOME/.zsh_history
isgrmlcd && HISTSIZE=500  || HISTSIZE=5000
isgrmlcd && SAVEHIST=1000 || SAVEHIST=10000 # useful for setopt append_history

# }}}

# dirstack handling {{{

DIRSTACKSIZE=${DIRSTACKSIZE:-20}
DIRSTACKFILE=${DIRSTACKFILE:-${HOME}/.zdirs}

if [[ -f ${DIRSTACKFILE} ]] && [[ ${#dirstack[*]} -eq 0 ]] ; then
    dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
    # "cd -" won't work after login by just setting $OLDPWD, so
    [[ -d $dirstack[0] ]] && cd $dirstack[0] && cd $OLDPWD
fi

chpwd() {
    local -ax my_stack
    my_stack=( ${PWD} ${dirstack} )
    if is42 ; then
        builtin print -l ${(u)my_stack} >! ${DIRSTACKFILE}
    else
        uprint my_stack >! ${DIRSTACKFILE}
    fi
}

# }}}

# directory based profiles {{{

if is433 ; then

CHPWD_PROFILE='default'
function chpwd_profiles() {
    # Say you want certain settings to be active in certain directories.
    # This is what you want.
    #
    # zstyle ':chpwd:profiles:/usr/src/grml(|/|/*)'   profile grml
    # zstyle ':chpwd:profiles:/usr/src/debian(|/|/*)' profile debian
    #
    # When that's done and you enter a directory that matches the pattern
    # in the third part of the context, a function called chpwd_profile_grml,
    # for example, is called (if it exists).
    #
    # If no pattern matches (read: no profile is detected) the profile is
    # set to 'default', which means chpwd_profile_default is attempted to
    # be called.
    #
    # A word about the context (the ':chpwd:profiles:*' stuff in the zstyle
    # command) which is used: The third part in the context is matched against
    # ${PWD}. That's why using a pattern such as /foo/bar(|/|/*) makes sense.
    # Because that way the profile is detected for all these values of ${PWD}:
    #   /foo/bar
    #   /foo/bar/
    #   /foo/bar/baz
    # So, if you want to make double damn sure a profile works in /foo/bar
    # and everywhere deeper in that tree, just use (|/|/*) and be happy.
    #
    # The name of the detected profile will be available in a variable called
    # 'profile' in your functions. You don't need to do anything, it'll just
    # be there.
    #
    # Then there is the parameter $CHPWD_PROFILE is set to the profile, that
    # was is currently active. That way you can avoid running code for a
    # profile that is already active, by running code such as the following
    # at the start of your function:
    #
    # function chpwd_profile_grml() {
    #     [[ ${profile} == ${CHPWD_PROFILE} ]] && return 1
    #   ...
    # }
    #
    # The initial value for $CHPWD_PROFILE is 'default'.
    #
    # Version requirement:
    #   This feature requires zsh 4.3.3 or newer.
    #   If you use this feature and need to know whether it is active in your
    #   current shell, there are several ways to do that. Here are two simple
    #   ways:
    #
    #   a) If knowing if the profiles feature is active when zsh starts is
    #      good enough for you, you can put the following snippet into your
    #      .zshrc.local:
    #
    #   (( ${+functions[chpwd_profiles]} )) && print "directory profiles active"
    #
    #   b) If that is not good enough, and you would prefer to be notified
    #      whenever a profile changes, you can solve that by making sure you
    #      start *every* profile function you create like this:
    #
    #   function chpwd_profile_myprofilename() {
    #       [[ ${profile} == ${CHPWD_PROFILE} ]] && return 1
    #       print "chpwd(): Switching to profile: $profile"
    #     ...
    #   }
    #
    #      That makes sure you only get notified if a profile is *changed*,
    #      not everytime you change directory, which would probably piss
    #      you off fairly quickly. :-)
    #
    # There you go. Now have fun with that.
    local -x profile

    zstyle -s ":chpwd:profiles:${PWD}" profile profile || profile='default'
    if (( ${+functions[chpwd_profile_$profile]} )) ; then
        chpwd_profile_${profile}
    fi

    CHPWD_PROFILE="${profile}"
    return 0
}
chpwd_functions=( ${chpwd_functions} chpwd_profiles )

fi # is433

# }}}

# {{{ display battery status on right side of prompt via running 'BATTERY=1 zsh'
if [[ $BATTERY -gt 0 ]] ; then
    if ! check_com -c acpi ; then
        BATTERY=0
    fi
fi

battery() {
if [[ $BATTERY -gt 0 ]] ; then
    PERCENT="${${"$(acpi 2>/dev/null)"}/(#b)[[:space:]]#Battery <->: [^0-9]##, (<->)%*/${match[1]}}"
    if [[ -z "$PERCENT" ]] ; then
        PERCENT='acpi not present'
    else
        if [[ "$PERCENT" -lt 20 ]] ; then
            PERCENT="warning: ${PERCENT}%%"
        else
            PERCENT="${PERCENT}%%"
        fi
    fi
fi
}
# }}}

# set colors for use in prompts {{{
if zrcautoload colors && colors 2>/dev/null ; then
    BLUE="%{${fg[blue]}%}"
    RED="%{${fg_bold[red]}%}"
    GREEN="%{${fg[green]}%}"
    CYAN="%{${fg[cyan]}%}"
    MAGENTA="%{${fg[magenta]}%}"
    YELLOW="%{${fg[yellow]}%}"
    WHITE="%{${fg[white]}%}"
    NO_COLOUR="%{${reset_color}%}"
else
    BLUE=$'%{\e[1;34m%}'
    RED=$'%{\e[1;31m%}'
    GREEN=$'%{\e[1;32m%}'
    CYAN=$'%{\e[1;36m%}'
    WHITE=$'%{\e[1;37m%}'
    MAGENTA=$'%{\e[1;35m%}'
    YELLOW=$'%{\e[1;33m%}'
    NO_COLOUR=$'%{\e[0m%}'
fi

# }}}

# gather version control information for inclusion in a prompt {{{

if ! is41 ; then
    # Be quiet about version problems in grml's zshrc as the user cannot disable
    # loading vcs_info() as it is *in* the zshrc - as you can see. :-)
    # Just unset most probable variables and disable vcs_info altogether.
    local -i i
    for i in {0..9} ; do
        unset VCS_INFO_message_${i}_
    done
    zstyle ':vcs_info:*' enable false
fi

if zrcautoload vcs_info; then
    GRML_VCS_INFO=0
    # `vcs_info' in zsh versions 4.3.10 and below have a broken `_realpath'
    # function, which can cause a lot of trouble with our directory-based
    # profiles. So:
    if [[ ${ZSH_VERSION} == 4.3.<-10> ]] ; then
        function VCS_INFO_realpath () {
            setopt localoptions NO_shwordsplit chaselinks
            ( builtin cd -q $1 2> /dev/null && pwd; )
        }
    fi
else
# I'm not reindenting the whole code below.
GRML_VCS_INFO=1

# The following code is imported from the file 'zsh/functions/vcs_info'
# from <http://ft.bewatermyfriend.org/comp/zsh/zsh-dotfiles.tar.bz2>,
# which distributed under the same terms as zsh itself.

# we will be using two variables, so let the code know now.
zstyle ':vcs_info:*' max-exports 2

# vcs_info() documentation:
#{{{
# REQUIREMENTS:
#{{{
#     This functionality requires zsh version >= 4.1.*.
#}}}
#
# LOADING:
#{{{
# To load vcs_info(), copy this file to your $fpath[] and do:
#   % autoload -Uz vcs_info && vcs_info
#
# To work, vcs_info() needs 'setopt prompt_subst' in your setup.
#}}}
#
# QUICKSTART:
#{{{
# To get vcs_info() working quickly (including colors), you can do the
# following (assuming, you loaded vcs_info() properly - see above):
#
# % RED=$'%{\e[31m%}'
# % GR=$'%{\e[32m%}'
# % MA=$'%{\e[35m%}'
# % YE=$'%{\e[33m%}'
# % NC=$'%{\e[0m%}'
#
# % zstyle ':vcs_info:*' actionformats \
#       "${MA}(${NC}%s${MA})${YE}-${MA}[${GR}%b${YE}|${RED}%a${MA}]${NC} "
#
# % zstyle ':vcs_info:*' formats       \
#       "${MA}(${NC}%s${MA})${Y}-${MA}[${GR}%b${MA}]${NC}%} "
#
# % zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat "%b${RED}:${YE}%r"
#
# % precmd () { vcs_info }
# % PS1='${MA}[${GR}%n${MA}] ${MA}(${RED}%!${MA}) ${YE}%3~ ${VCS_INFO_message_0_}${NC}%# '
#
# Obviously, the las two lines are there for demonstration: You need to
# call vcs_info() from your precmd() function (see 'SPECIAL FUNCTIONS' in
# 'man zshmisc'). Once that is done you need a *single* quoted
# '${VCS_INFO_message_0_}' in your prompt.
#
# Now call the 'vcs_info_printsys' utility from the command line:
#
# % vcs_info_printsys
# # list of supported version control backends:
# # disabled systems are prefixed by a hash sign (#)
# git
# hg
# bzr
# darcs
# svk
# mtn
# svn
# cvs
# cdv
# tla
# # flavours (cannot be used in the disable style; they
# # are disabled with their master [git-svn -> git]):
# git-p4
# git-svn
#
# Ten version control backends as you can see. You may not want all
# of these. Because there is no point in running the code to detect
# systems you do not use. ever. So, there is a way to disable some
# backends altogether:
#
# % zstyle ':vcs_info:*' disable bzr cdv darcs mtn svk tla
#
# If you rerun 'vcs_info_printsys' now, you will see the backends listed
# in the 'disable' style marked as diabled by a hash sign. That means the
# detection of these systems is skipped *completely*. No wasted time there.
#
# For more control, read the reference below.
#}}}
#
# CONFIGURATION:
#{{{
# The vcs_info() feature can be configured via zstyle.
#
# First, the context in which we are working:
#       :vcs_info:<vcs-string>:<user-context>
#
# ...where <vcs-string> is one of:
#   - git, git-svn, git-p4, hg, darcs, bzr, cdv, mtn, svn, cvs, svk or tla.
#
# ...and <user-context> is a freely configurable string, assignable by the
# user as the first argument to vcs_info() (see its description below).
#
# There is are three special values for <vcs-string>: The first is named
# 'init', that is in effect as long as there was no decision what vcs
# backend to use. The second is 'preinit; it is used *before* vcs_info()
# is run, when initializing the data exporting variables. The third
# special value is 'formats' and is used by the 'vcs_info_lastmsg' for
# looking up its styles.
#
# There are two pre-defined values for <user-context>:
#   default  - the one used if none is specified
#   command  - used by vcs_info_lastmsg to lookup its styles.
#
# You may *not* use 'print_systems_' as a user-context string, because it
# is used internally.
#
# You can of course use ':vcs_info:*' to match all VCSs in all
# user-contexts at once.
#
# Another special context is 'formats', which is used by the
# vcs_info_lastmsg() utility function (see below).
#
#
# This is a description of all styles, that are looked up:
#   formats             - A list of formats, used when actionformats is not
#                         used (which is most of the time).
#   actionformats       - A list of formats, used if a there is a special
#                         action going on in your current repository;
#                         (like an interactive rebase or a merge conflict)
#   branchformat        - Some backends replace %b in the formats and
#                         actionformats styles above, not only by a branch
#                         name but also by a revision number. This style
#                         let's you modify how that string should look like.
#   nvcsformats         - These "formats" are exported, when we didn't detect
#                         a version control system for the current directory.
#                         This is useful, if you want vcs_info() to completely
#                         take over the generation of your prompt.
#                         You would do something like
#                           PS1='${VCS_INFO_message_0_}'
#                         to accomplish that.
#   max-exports         - Defines the maximum number if VCS_INFO_message_*_
#                         variables vcs_info() will export.
#   enable              - Checked in the 'init' context. If set to false,
#                         vcs_info() will do nothing.
#   disable             - Provide a list of systems, you don't want
#                         the vcs_info() to check for repositories
#                         (checked in the 'init' context, too).
#   disable-patterns    - A list of patterns that are checked against $PWD.
#                         If the pattern matches, vcs_info will be disabled.
#                         Say, ~/.zsh is a directory under version control,
#                         in which you do not want vcs_info to be active, do:
#                         zstyle ':vcs_info:*' disable-patterns "$HOME/.zsh+(|/*)"
#   use-simple          - If there are two different ways of gathering
#                         information, you can select the simpler one
#                         by setting this style to true; the default
#                         is to use the not-that-simple code, which is
#                         potentially a lot slower but might be more
#                         accurate in all possible cases.
#   use-prompt-escapes  - determines if we assume that the assembled
#                         string from vcs_info() includes prompt escapes.
#                         (Used by vcs_info_lastmsg().
#
# The use-simple style is only available for the bzr backend.
#
# The default values for these in all contexts are:
#   formats             " (%s)-[%b|%a]-"
#   actionformats       " (%s)-[%b]-"
#   branchformat        "%b:%r" (for bzr, svn and svk)
#   nvcsformats         ""
#   max-exports         2
#   enable              true
#   disable             (empty list)
#   disable-patterns    (empty list)
#   use-simple          false
#   use-prompt-escapes  true
#
#
# In normal formats and actionformats, the following replacements
# are done:
#   %s  - The vcs in use (git, hg, svn etc.)
#   %b  - Information about the current branch.
#   %a  - An identifier, that describes the action.
#         Only makes sense in actionformats.
#   %R  - base directory of the repository.
#   %r  - repository name
#         If %R is '/foo/bar/repoXY', %r is 'repoXY'.
#   %S  - subdirectory within a repository. if $PWD is
#         '/foo/bar/reposXY/beer/tasty', %S is 'beer/tasty'.
#
#
# In branchformat these replacements are done:
#   %b  - the branch name
#   %r  - the current revision number
#
# Not all vcs backends have to support all replacements.
# nvcsformat does not perform *any* replacements. It is just a string.
#}}}
#
# ODDITIES:
#{{{
# If you want to use the %b (bold off) prompt expansion in 'formats', which
# expands %b itself, use %%b. That will cause the vcs_info() expansion to
# replace %%b with %b. So zsh's prompt expansion mechanism can handle it.
# Similarly, to hand down %b from branchformat, use %%%%b. Sorry for this
# inconvenience, but it cannot be easily avoided. Luckily we do not clash
# with a lot of prompt expansions and this only needs to be done for those.
# See 'man zshmisc' for details about EXPANSION OF PROMPT SEQUENCES.
#}}}
#
# FUNCTION DESCRIPTIONS (public API):
#{{{
#   vcs_info()
#       The main function, that runs all backends and assembles
#       all data into ${VCS_INFO_message_*_}. This is the function
#       you want to call from precmd() if you want to include
#       up-to-date information in your prompt (see VARIABLE
#       DESCRIPTION below).
#
#   vcs_info_printsys()
#       Prints a list of all supported version control systems.
#       Useful to find out possible contexts (and which of them are enabled)
#       or values for the 'disable' style.
#
#   vcs_info_lastmsg()
#       Outputs the last ${VCS_INFO_message_*_} value. Takes into account
#       the value of the use-prompt-escapes style in ':vcs_info:formats'.
#       It also only prints max-exports values.
#
# All functions named VCS_INFO_* are for internal use only.
#}}}
#
# VARIABLE DESCRIPTION:
#{{{
#   ${VCS_INFO_message_N_}    (Note the trailing underscore)
#       Where 'N' is an integer, eg: VCS_INFO_message_0_
#       These variables are the storage for the informational message the
#       last vcs_info() call has assembled. These are strongly connected
#       to the formats, actionformats and nvcsformats styles described
#       above. Those styles are lists. the first member of that list gets
#       expanded into ${VCS_INFO_message_0_}, the second into
#       ${VCS_INFO_message_1_} and the Nth into ${VCS_INFO_message_N-1_}.
#       These parameters are exported into the environment.
#       (See the max-exports style above.)
#}}}
#
# EXAMPLES:
#{{{
#   Don't use vcs_info at all (even though it's in your prompt):
#   % zstyle ':vcs_info:*' enable false
#
#   Disable the backends for bzr and svk:
#   % zstyle ':vcs_info:*' disable bzr svk
#
#   Provide a special formats for git:
#   % zstyle ':vcs_info:git:*' formats       ' GIT, BABY! [%b]'
#   % zstyle ':vcs_info:git:*' actionformats ' GIT ACTION! [%b|%a]'
#
#   Use the quicker bzr backend (if you do, please report if it does
#   the-right-thing[tm] - thanks):
#   % zstyle ':vcs_info:bzr:*' use-simple true
#
#   Display the revision number in yellow for bzr and svn:
#   % zstyle ':vcs_info:(svn|bzr):*' branchformat '%b%{'${fg[yellow]}'%}:%r'
#
# If you want colors, make sure you enclose the color codes in %{...%},
# if you want to use the string provided by vcs_info() in prompts.
#
# Here is how to print the vcs infomation as a command:
#   % alias vcsi='vcs_info command; vcs_info_lastmsg'
#
#   This way, you can even define different formats for output via
#   vcs_info_lastmsg() in the ':vcs_info:command:*' namespace.
#}}}
#}}}
# utilities
VCS_INFO_adjust () { #{{{
    [[ -n ${vcs_comm[overwrite_name]} ]] && vcs=${vcs_comm[overwrite_name]}
    return 0
}
# }}}
VCS_INFO_check_com () { #{{{
    (( ${+commands[$1]} )) && [[ -x ${commands[$1]} ]] && return 0
    return 1
}
# }}}
VCS_INFO_formats () { # {{{
    setopt localoptions noksharrays
    local action=$1 branch=$2 base=$3
    local msg
    local -i i

    if [[ -n ${action} ]] ; then
        zstyle -a ":vcs_info:${vcs}:${usercontext}" actionformats msgs
        (( ${#msgs} < 1 )) && msgs[1]=' (%s)-[%b|%a]-'
    else
        zstyle -a ":vcs_info:${vcs}:${usercontext}" formats msgs
        (( ${#msgs} < 1 )) && msgs[1]=' (%s)-[%b]-'
    fi

    (( ${#msgs} > maxexports )) && msgs[$(( maxexports + 1 )),-1]=()
    for i in {1..${#msgs}} ; do
        zformat -f msg ${msgs[$i]}                      \
                        a:${action}                     \
                        b:${branch}                     \
                        r:${base:t}                     \
                        s:${vcs}                        \
                        R:${base}                       \
                        S:"$(VCS_INFO_reposub ${base})"
        msgs[$i]=${msg}
    done
    return 0
}
# }}}
VCS_INFO_maxexports () { #{{{
    zstyle -s ":vcs_info:${vcs}:${usercontext}" "max-exports" maxexports || maxexports=2
    if [[ ${maxexports} != <-> ]] || (( maxexports < 1 )); then
        printf 'vcs_info(): expecting numeric arg >= 1 for max-exports (got %s).\n' ${maxexports}
        printf 'Defaulting to 2.\n'
        maxexports=2
    fi
}
# }}}
VCS_INFO_nvcsformats () { #{{{
    setopt localoptions noksharrays
    local c v

    if [[ $1 == 'preinit' ]] ; then
        c=default
        v=preinit
    fi
    zstyle -a ":vcs_info:${v:-$vcs}:${c:-$usercontext}" nvcsformats msgs
    (( ${#msgs} > maxexports )) && msgs[${maxexports},-1]=()
}
# }}}
VCS_INFO_realpath () { #{{{
    # a portable 'readlink -f'
    # forcing a subshell, to ensure chpwd() is not removed
    # from the calling shell (if VCS_INFO_realpath() is called
    # manually).
    (
        (( ${+functions[chpwd]} )) && unfunction chpwd
        setopt chaselinks
        cd $1 2>/dev/null && pwd
    )
}
# }}}
VCS_INFO_reposub () { #{{{
    setopt localoptions extendedglob
    local base=${1%%/##}

    [[ ${PWD} == ${base}/* ]] || {
        printf '.'
        return 1
    }
    printf '%s' ${PWD#$base/}
    return 0
}
# }}}
VCS_INFO_set () { #{{{
    setopt localoptions noksharrays
    local -i i j

    if [[ $1 == '--clear' ]] ; then
        for i in {0..9} ; do
            unset VCS_INFO_message_${i}_
        done
    fi
    if [[ $1 == '--nvcs' ]] ; then
        [[ $2 == 'preinit' ]] && (( maxexports == 0 )) && (( maxexports = 1 ))
        for i in {0..$((maxexports - 1))} ; do
            typeset -gx VCS_INFO_message_${i}_=
        done
        VCS_INFO_nvcsformats $2
    fi

    (( ${#msgs} - 1 < 0 )) && return 0
    for i in {0..$(( ${#msgs} - 1 ))} ; do
        (( j = i + 1 ))
        typeset -gx VCS_INFO_message_${i}_=${msgs[$j]}
    done
    return 0
}
# }}}
# information gathering
VCS_INFO_bzr_get_data () { # {{{
    setopt localoptions noksharrays
    local bzrbase bzrbr
    local -a bzrinfo

    if zstyle -t ":vcs_info:${vcs}:${usercontext}" "use-simple" ; then
        bzrbase=${vcs_comm[basedir]}
        bzrinfo[2]=${bzrbase:t}
        if [[ -f ${bzrbase}/.bzr/branch/last-revision ]] ; then
            bzrinfo[1]=$(< ${bzrbase}/.bzr/branch/last-revision)
            bzrinfo[1]=${${bzrinfo[1]}%% *}
        fi
    else
        bzrbase=${${(M)${(f)"$( bzr info )"}:# ##branch\ root:*}/*: ##/}
        bzrinfo=( ${${${(M)${(f)"$( bzr version-info )"}:#(#s)(revno|branch-nick)*}/*: /}/*\//} )
        bzrbase="$(VCS_INFO_realpath ${bzrbase})"
    fi

    zstyle -s ":vcs_info:${vcs}:${usercontext}" branchformat bzrbr || bzrbr="%b:%r"
    zformat -f bzrbr "${bzrbr}" "b:${bzrinfo[2]}" "r:${bzrinfo[1]}"
    VCS_INFO_formats '' "${bzrbr}" "${bzrbase}"
    return 0
}
# }}}
VCS_INFO_cdv_get_data () { # {{{
    local cdvbase

    cdvbase=${vcs_comm[basedir]}
    VCS_INFO_formats '' "${cdvbase:t}" "${cdvbase}"
    return 0
}
# }}}
VCS_INFO_cvs_get_data () { # {{{
    local cvsbranch cvsbase basename

    cvsbase="."
    while [[ -d "${cvsbase}/../CVS" ]]; do
        cvsbase="${cvsbase}/.."
    done
    cvsbase="$(VCS_INFO_realpath ${cvsbase})"
    cvsbranch=$(< ./CVS/Repository)
    basename=${cvsbase:t}
    cvsbranch=${cvsbranch##${basename}/}
    [[ -z ${cvsbranch} ]] && cvsbranch=${basename}
    VCS_INFO_formats '' "${cvsbranch}" "${cvsbase}"
    return 0
}
# }}}
VCS_INFO_darcs_get_data () { # {{{
    local darcsbase

    darcsbase=${vcs_comm[basedir]}
    VCS_INFO_formats '' "${darcsbase:t}" "${darcsbase}"
    return 0
}
# }}}
VCS_INFO_git_getaction () { #{{{
    local gitaction='' gitdir=$1
    local tmp

    for tmp in "${gitdir}/rebase-apply" \
               "${gitdir}/rebase"       \
               "${gitdir}/../.dotest" ; do
        if [[ -d ${tmp} ]] ; then
            if   [[ -f "${tmp}/rebasing" ]] ; then
                gitaction="rebase"
            elif [[ -f "${tmp}/applying" ]] ; then
                gitaction="am"
            else
                gitaction="am/rebase"
            fi
            printf '%s' ${gitaction}
            return 0
        fi
    done

    for tmp in "${gitdir}/rebase-merge/interactive" \
               "${gitdir}/.dotest-merge/interactive" ; do
        if [[ -f "${tmp}" ]] ; then
            printf '%s' "rebase-i"
            return 0
        fi
    done

    for tmp in "${gitdir}/rebase-merge" \
               "${gitdir}/.dotest-merge" ; do
        if [[ -d "${tmp}" ]] ; then
            printf '%s' "rebase-m"
            return 0
        fi
    done

    if [[ -f "${gitdir}/MERGE_HEAD" ]] ; then
        printf '%s' "merge"
        return 0
    fi

    if [[ -f "${gitdir}/BISECT_LOG" ]] ; then
        printf '%s' "bisect"
        return 0
    fi
    return 1
}
# }}}
VCS_INFO_git_getbranch () { #{{{
    local gitbranch gitdir=$1 tmp actiondir
    local gitsymref='git symbolic-ref HEAD'

    actiondir=''
    for tmp in "${gitdir}/rebase-apply" \
               "${gitdir}/rebase"       \
               "${gitdir}/../.dotest"; do
        if [[ -d ${tmp} ]]; then
            actiondir=${tmp}
            break
        fi
    done
    if [[ -n ${actiondir} ]]; then
        gitbranch="$(${(z)gitsymref} 2> /dev/null)"
        [[ -z ${gitbranch} ]] && [[ -r ${actiondir}/head-name ]] \
            && gitbranch="$(< ${actiondir}/head-name)"

    elif [[ -f "${gitdir}/MERGE_HEAD" ]] ; then
        gitbranch="$(${(z)gitsymref} 2> /dev/null)"
        [[ -z ${gitbranch} ]] && gitbranch="$(< ${gitdir}/MERGE_HEAD)"

    elif [[ -d "${gitdir}/rebase-merge" ]] ; then
        gitbranch="$(< ${gitdir}/rebase-merge/head-name)"

    elif [[ -d "${gitdir}/.dotest-merge" ]] ; then
        gitbranch="$(< ${gitdir}/.dotest-merge/head-name)"

    else
        gitbranch="$(${(z)gitsymref} 2> /dev/null)"

        if [[ $? -ne 0 ]] ; then
            gitbranch="refs/tags/$(git describe --exact-match HEAD 2>/dev/null)"

            if [[ $? -ne 0 ]] ; then
                gitbranch="${${"$(< $gitdir/HEAD)"}[1,7]}..."
            fi
        fi
    fi

    printf '%s' "${gitbranch##refs/[^/]##/}"
    return 0
}
# }}}
VCS_INFO_git_get_data () { # {{{
    setopt localoptions extendedglob
    local gitdir gitbase gitbranch gitaction

    gitdir=${vcs_comm[gitdir]}
    gitbranch="$(VCS_INFO_git_getbranch ${gitdir})"

    if [[ -z ${gitdir} ]] || [[ -z ${gitbranch} ]] ; then
        return 1
    fi

    VCS_INFO_adjust
    gitaction="$(VCS_INFO_git_getaction ${gitdir})"
    gitbase=${PWD%/${$( git rev-parse --show-prefix )%/##}}
    VCS_INFO_formats "${gitaction}" "${gitbranch}" "${gitbase}"
    return 0
}
# }}}
VCS_INFO_hg_get_data () { # {{{
    local hgbranch hgbase file

    hgbase=${vcs_comm[basedir]}

    file="${hgbase}/.hg/branch"
    if [[ -r ${file} ]] ; then
        hgbranch=$(< ${file})
    else
        hgbranch='default'
    fi

    VCS_INFO_formats '' "${hgbranch}" "${hgbase}"
    return 0
}
# }}}
VCS_INFO_mtn_get_data () { # {{{
    local mtnbranch mtnbase

    mtnbase=${vcs_comm[basedir]}
    mtnbranch=${${(M)${(f)"$( mtn status )"}:#(#s)Current branch:*}/*: /}
    VCS_INFO_formats '' "${mtnbranch}" "${mtnbase}"
    return 0
}
# }}}
VCS_INFO_svk_get_data () { # {{{
    local svkbranch svkbase

    svkbase=${vcs_comm[basedir]}
    zstyle -s ":vcs_info:${vcs}:${usercontext}" branchformat svkbranch || svkbranch="%b:%r"
    zformat -f svkbranch "${svkbranch}" "b:${vcs_comm[branch]}" "r:${vcs_comm[revision]}"
    VCS_INFO_formats '' "${svkbranch}" "${svkbase}"
    return 0
}
# }}}
VCS_INFO_svn_get_data () { # {{{
    setopt localoptions noksharrays
    local svnbase svnbranch
    local -a svninfo

    svnbase="."
    while [[ -d "${svnbase}/../.svn" ]]; do
        svnbase="${svnbase}/.."
    done
    svnbase="$(VCS_INFO_realpath ${svnbase})"
    svninfo=( ${${${(M)${(f)"$( svn info )"}:#(#s)(URL|Revision)*}/*: /}/*\//} )

    zstyle -s ":vcs_info:${vcs}:${usercontext}" branchformat svnbranch || svnbranch="%b:%r"
    zformat -f svnbranch "${svnbranch}" "b:${svninfo[1]}" "r:${svninfo[2]}"
    VCS_INFO_formats '' "${svnbranch}" "${svnbase}"
    return 0
}
# }}}
VCS_INFO_tla_get_data () { # {{{
    local tlabase tlabranch

    tlabase="$(VCS_INFO_realpath ${vcs_comm[basedir]})"
    # tree-id gives us something like 'foo@example.com/demo--1.0--patch-4', so:
    tlabranch=${${"$( tla tree-id )"}/*\//}
    VCS_INFO_formats '' "${tlabranch}" "${tlabase}"
    return 0
}
# }}}
# detection
VCS_INFO_detect_by_dir() { #{{{
    local dirname=$1
    local basedir="." realbasedir

    realbasedir="$(VCS_INFO_realpath ${basedir})"
    while [[ ${realbasedir} != '/' ]]; do
        [[ -r ${realbasedir} ]] || return 1
        if [[ -n ${vcs_comm[detect_need_file]} ]] ; then
            [[ -d ${basedir}/${dirname} ]] && \
            [[ -e ${basedir}/${dirname}/${vcs_comm[detect_need_file]} ]] && \
                break
        else
            [[ -d ${basedir}/${dirname} ]] && break
        fi

        basedir=${basedir}/..
        realbasedir="$(VCS_INFO_realpath ${basedir})"
    done

    [[ ${realbasedir} == "/" ]] && return 1
    vcs_comm[basedir]=${realbasedir}
    return 0
}
# }}}
VCS_INFO_bzr_detect() { #{{{
    VCS_INFO_check_com bzr || return 1
    vcs_comm[detect_need_file]=branch/format
    VCS_INFO_detect_by_dir '.bzr'
    return $?
}
# }}}
VCS_INFO_cdv_detect() { #{{{
    VCS_INFO_check_com cdv || return 1
    vcs_comm[detect_need_file]=format
    VCS_INFO_detect_by_dir '.cdv'
    return $?
}
# }}}
VCS_INFO_cvs_detect() { #{{{
    VCS_INFO_check_com cvs || return 1
    [[ -d "./CVS" ]] && [[ -r "./CVS/Repository" ]] && return 0
    return 1
}
# }}}
VCS_INFO_darcs_detect() { #{{{
    VCS_INFO_check_com darcs || return 1
    vcs_comm[detect_need_file]=format
    VCS_INFO_detect_by_dir '_darcs'
    return $?
}
# }}}
VCS_INFO_git_detect() { #{{{
    if VCS_INFO_check_com git && git rev-parse --is-inside-work-tree &> /dev/null ; then
        vcs_comm[gitdir]="$(git rev-parse --git-dir 2> /dev/null)" || return 1
        if   [[ -d ${vcs_comm[gitdir]}/svn ]]             ; then vcs_comm[overwrite_name]='git-svn'
        elif [[ -d ${vcs_comm[gitdir]}/refs/remotes/p4 ]] ; then vcs_comm[overwrite_name]='git-p4' ; fi
        return 0
    fi
    return 1
}
# }}}
VCS_INFO_hg_detect() { #{{{
    VCS_INFO_check_com hg || return 1
    vcs_comm[detect_need_file]=store
    VCS_INFO_detect_by_dir '.hg'
    return $?
}
# }}}
VCS_INFO_mtn_detect() { #{{{
    VCS_INFO_check_com mtn || return 1
    vcs_comm[detect_need_file]=revision
    VCS_INFO_detect_by_dir '_MTN'
    return $?
}
# }}}
VCS_INFO_svk_detect() { #{{{
    setopt localoptions noksharrays extendedglob
    local -a info
    local -i fhash
    fhash=0

    VCS_INFO_check_com svk || return 1
    [[ -f ~/.svk/config ]] || return 1

    # This detection function is a bit different from the others.
    # We need to read svk's config file to detect a svk repository
    # in the first place. Therefore, we'll just proceed and read
    # the other information, too. This is more then any of the
    # other detections do but this takes only one file open for
    # svk at most. VCS_INFO_svk_get_data() get simpler, too. :-)
    while IFS= read -r line ; do
        if [[ -n ${vcs_comm[basedir]} ]] ; then
            line=${line## ##}
            [[ ${line} == depotpath:* ]] && vcs_comm[branch]=${line##*/}
            [[ ${line} == revision:* ]] && vcs_comm[revision]=${line##*[[:space:]]##}
            [[ -n ${vcs_comm[branch]} ]] && [[ -n ${vcs_comm[revision]} ]] && break
            continue
        fi
        (( fhash > 0 )) && [[ ${line} == '  '[^[:space:]]*:* ]] && break
        [[ ${line} == '  hash:'* ]] && fhash=1 && continue
        (( fhash == 0 )) && continue
        [[ ${PWD}/ == ${${line## ##}%:*}/* ]] && vcs_comm[basedir]=${${line## ##}%:*}
    done < ~/.svk/config

    [[ -n ${vcs_comm[basedir]} ]]  && \
    [[ -n ${vcs_comm[branch]} ]]   && \
    [[ -n ${vcs_comm[revision]} ]] && return 0
    return 1
}
# }}}
VCS_INFO_svn_detect() { #{{{
    VCS_INFO_check_com svn || return 1
    [[ -d ".svn" ]] && return 0
    return 1
}
# }}}
VCS_INFO_tla_detect() { #{{{
    VCS_INFO_check_com tla || return 1
    vcs_comm[basedir]="$(tla tree-root 2> /dev/null)" && return 0
    return 1
}
# }}}
# public API
vcs_info_printsys () { # {{{
    vcs_info print_systems_
}
# }}}
vcs_info_lastmsg () { # {{{
    emulate -L zsh
    local -i i

    VCS_INFO_maxexports
    for i in {0..$((maxexports - 1))} ; do
        printf '$VCS_INFO_message_%d_: "' $i
        if zstyle -T ':vcs_info:formats:command' use-prompt-escapes ; then
            print -nP ${(P)${:-VCS_INFO_message_${i}_}}
        else
            print -n ${(P)${:-VCS_INFO_message_${i}_}}
        fi
        printf '"\n'
    done
}
# }}}
vcs_info () { # {{{
    emulate -L zsh
    setopt extendedglob

    [[ -r . ]] || return 1

    local pat
    local -i found
    local -a VCSs disabled dps
    local -x vcs usercontext
    local -ix maxexports
    local -ax msgs
    local -Ax vcs_comm

    vcs="init"
    VCSs=(git hg bzr darcs svk mtn svn cvs cdv tla)
    case $1 in
        (print_systems_)
            zstyle -a ":vcs_info:${vcs}:${usercontext}" "disable" disabled
            print -l '# list of supported version control backends:' \
                     '# disabled systems are prefixed by a hash sign (#)'
            for vcs in ${VCSs} ; do
                [[ -n ${(M)disabled:#${vcs}} ]] && printf '#'
                printf '%s\n' ${vcs}
            done
            print -l '# flavours (cannot be used in the disable style; they' \
                     '# are disabled with their master [git-svn -> git]):'   \
                     git-{p4,svn}
            return 0
            ;;
        ('')
            [[ -z ${usercontext} ]] && usercontext=default
            ;;
        (*) [[ -z ${usercontext} ]] && usercontext=$1
            ;;
    esac

    zstyle -T ":vcs_info:${vcs}:${usercontext}" "enable" || {
        [[ -n ${VCS_INFO_message_0_} ]] && VCS_INFO_set --clear
        return 0
    }
    zstyle -a ":vcs_info:${vcs}:${usercontext}" "disable" disabled

    zstyle -a ":vcs_info:${vcs}:${usercontext}" "disable-patterns" dps
    for pat in ${dps} ; do
        if [[ ${PWD} == ${~pat} ]] ; then
            [[ -n ${vcs_info_msg_0_} ]] && VCS_INFO_set --clear
            return 0
        fi
    done

    VCS_INFO_maxexports

    (( found = 0 ))
    for vcs in ${VCSs} ; do
        [[ -n ${(M)disabled:#${vcs}} ]] && continue
        vcs_comm=()
        VCS_INFO_${vcs}_detect && (( found = 1 )) && break
    done

    (( found == 0 )) && {
        VCS_INFO_set --nvcs
        return 0
    }

    VCS_INFO_${vcs}_get_data || {
        VCS_INFO_set --nvcs
        return 1
    }

    VCS_INFO_set
    return 0
}

VCS_INFO_set --nvcs preinit
# }}}

fi

# Change vcs_info formats for the grml prompt. The 2nd format sets up
# $vcs_info_msg_1_ to contain "zsh: repo-name" used to set our screen title.
# TODO: The included vcs_info() version still uses $VCS_INFO_message_N_.
#       That needs to be the use of $VCS_INFO_message_N_ needs to be changed
#       to $vcs_info_msg_N_ as soon as we use the included version.
if [[ "$TERM" == dumb ]] ; then
    zstyle ':vcs_info:*' actionformats "(%s%)-[%b|%a] " "zsh: %r"
    zstyle ':vcs_info:*' formats       "(%s%)-[%b] "    "zsh: %r"
else
    # these are the same, just with a lot of colours:
    zstyle ':vcs_info:*' actionformats "${MAGENTA}(${NO_COLOUR}%s${MAGENTA})${YELLOW}-${MAGENTA}[${GREEN}%b${YELLOW}|${RED}%a${MAGENTA}]${NO_COLOUR} " \
                                       "zsh: %r"
    zstyle ':vcs_info:*' formats       "${MAGENTA}(${NO_COLOUR}%s${MAGENTA})${YELLOW}-${MAGENTA}[${GREEN}%b${MAGENTA}]${NO_COLOUR}%} " \
                                       "zsh: %r"
    zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat "%b${RED}:${YELLOW}%r"
fi

if [[ -o restricted ]]; then
    zstyle ':vcs_info:*' enable false
fi

# }}}

# command not found handling {{{

(( ${COMMAND_NOT_FOUND} == 1 )) &&
function command_not_found_handler() {
    emulate -L zsh
    if [[ -x ${GRML_ZSH_CNF_HANDLER} ]] ; then
        ${GRML_ZSH_CNF_HANDLER} $1
    fi
    return 1
}

# }}}

# {{{ set prompt
if zrcautoload promptinit && promptinit 2>/dev/null ; then
    promptinit # people should be able to use their favourite prompt
else
    print 'Notice: no promptinit available :('
fi

setopt prompt_subst

# make sure to use right prompt only when not running a command
is41 && setopt transient_rprompt


function ESC_print () {
    info_print $'\ek' $'\e\\' "$@"
}
function set_title () {
    info_print  $'\e]0;' $'\a' "$@"
}

function info_print () {
    local esc_begin esc_end
    esc_begin="$1"
    esc_end="$2"
    shift 2
    printf '%s' ${esc_begin}
    for item in "$@" ; do
        printf '%s ' "$item"
    done
    printf '%s' "${esc_end}"
}

# TODO: revise all these NO* variables and especially their documentation
#       in zsh-help() below.
is4 && [[ $NOPRECMD -eq 0 ]] && precmd () {
    [[ $NOPRECMD -gt 0 ]] && return 0
    # update VCS information
    vcs_info

    if [[ $TERM == screen* ]] ; then
        if [[ -n ${VCS_INFO_message_1_} ]] ; then
            ESC_print ${VCS_INFO_message_1_}
        elif [[ -n ${vcs_info_msg_1_} ]] ; then
            ESC_print ${vcs_info_msg_1_}
        else
            ESC_print "zsh"
        fi
    fi
    # just use DONTSETRPROMPT=1 to be able to overwrite RPROMPT
    if [[ $DONTSETRPROMPT -eq 0 ]] ; then
        if [[ $BATTERY -gt 0 ]] ; then
            # update battery (dropped into $PERCENT) information
            battery
            RPROMPT="%(?..:() ${PERCENT}"
        else
            RPROMPT="%(?..:() "
        fi
    fi
    # adjust title of xterm
    # see http://www.faqs.org/docs/Linux-mini/Xterm-Title.html
    [[ ${NOTITLE} -gt 0 ]] && return 0
    case $TERM in
        (xterm*|rxvt*)
            set_title ${(%):-"%n@%m: %~"}
            ;;
    esac
}

# preexec() => a function running before every command
is4 && [[ $NOPRECMD -eq 0 ]] && \
preexec () {
    [[ $NOPRECMD -gt 0 ]] && return 0
# set hostname if not running on host with name 'grml'
    if [[ -n "$HOSTNAME" ]] && [[ "$HOSTNAME" != $(hostname) ]] ; then
       NAME="@$HOSTNAME"
    fi
# get the name of the program currently running and hostname of local machine
# set screen window title if running in a screen
    if [[ "$TERM" == screen* ]] ; then
        # local CMD=${1[(wr)^(*=*|sudo|ssh|-*)]}       # don't use hostname
        local CMD="${1[(wr)^(*=*|sudo|ssh|-*)]}$NAME" # use hostname
        ESC_print ${CMD}
    fi
# adjust title of xterm
    [[ ${NOTITLE} -gt 0 ]] && return 0
    case $TERM in
        (xterm*|rxvt*)
            set_title "${(%):-"%n@%m:"}" "$1"
            ;;
    esac
}

EXITCODE="%(?..%?%1v )"
PS2='\`%_> '      # secondary prompt, printed when the shell needs more information to complete a command.
PS3='?# '         # selection prompt used within a select loop.
PS4='+%N:%i:%_> ' # the execution trace prompt (setopt xtrace). default: '+%N:%i>'

# set variable debian_chroot if running in a chroot with /etc/debian_chroot
if [[ -z "$debian_chroot" ]] && [[ -r /etc/debian_chroot ]] ; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# don't use colors on dumb terminals (like emacs):
if [[ "$TERM" == dumb ]] ; then
    PROMPT="${EXITCODE}${debian_chroot:+($debian_chroot)}%n@%m %40<...<%B%~%b%<< "
else
    # only if $GRMLPROMPT is set (e.g. via 'GRMLPROMPT=1 zsh') use the extended prompt
    # set variable identifying the chroot you work in (used in the prompt below)
    if [[ $GRMLPROMPT -gt 0 ]] ; then
        PROMPT="${RED}${EXITCODE}${CYAN}[%j running job(s)] ${GREEN}{history#%!} ${RED}%(3L.+.) ${BLUE}%* %D
${BLUE}%n${NO_COLOUR}@%m %40<...<%B%~%b%<< "
    else
        # This assembles the primary prompt string
        if (( EUID != 0 )); then
            PROMPT="${RED}${EXITCODE}${WHITE}${debian_chroot:+($debian_chroot)}${BLUE}%n${NO_COLOUR}@%m %40<...<%B%~%b%<< "
        else
            PROMPT="${BLUE}${EXITCODE}${WHITE}${debian_chroot:+($debian_chroot)}${RED}%n${NO_COLOUR}@%m %40<...<%B%~%b%<< "
        fi
    fi
fi

if (( GRML_VCS_INFO )); then
    PROMPT="${PROMPT}"'${VCS_INFO_message_0_}'"%# "
else
    PROMPT="${PROMPT}"'${vcs_info_msg_0_}'"%# "
fi

# if we are inside a grml-chroot set a specific prompt theme
if [[ -n "$GRML_CHROOT" ]] ; then
    PROMPT="%{$fg[red]%}(CHROOT) %{$fg_bold[red]%}%n%{$fg_no_bold[white]%}@%m %40<...<%B%~%b%<< %\# "
fi
# }}}

# {{{ 'hash' some often used directories
#d# start
hash -d deb=/var/cache/apt/archives
hash -d doc=/usr/share/doc
hash -d linux=/lib/modules/$(command uname -r)/build/
hash -d log=/var/log
hash -d slog=/var/log/syslog
hash -d src=/usr/src
hash -d templ=/usr/share/doc/grml-templates
hash -d tt=/usr/share/doc/texttools-doc
hash -d www=/var/www
#d# end
# }}}

# {{{ some aliases
if check_com -c screen ; then
    if [[ $UID -eq 0 ]] ; then
        [[ -r /etc/grml/screenrc ]] && alias screen="${commands[screen]} -c /etc/grml/screenrc"
    elif [[ -r $HOME/.screenrc ]] ; then
        alias screen="${commands[screen]} -c $HOME/.screenrc"
    else
        if [[ -r /etc/grml/screenrc_grml ]]; then
            alias screen="${commands[screen]} -c /etc/grml/screenrc_grml"
        else
            [[ -r /etc/grml/screenrc ]] && alias screen="${commands[screen]} -c /etc/grml/screenrc"
        fi
    fi
fi

# do we have GNU ls with color-support?
if ls --help 2>/dev/null | grep -- --color= >/dev/null && [[ "$TERM" != dumb ]] ; then
    #a1# execute \kbd{@a@}:\quad ls with colors
    alias ls='ls -b -CF --color=auto'
    #a1# execute \kbd{@a@}:\quad list all files, with colors
    alias la='ls -la --color=auto'
    #a1# long colored list, without dotfiles (@a@)
    alias ll='ls -l --color=auto'
    #a1# long colored list, human readable sizes (@a@)
    alias lh='ls -hAl --color=auto'
    #a1# List files, append qualifier to filenames \\&\quad(\kbd{/} for directories, \kbd{@} for symlinks ...)
    alias l='ls -lF --color=auto'
else
    alias ls='ls -b -CF'
    alias la='ls -la'
    alias ll='ls -l'
    alias lh='ls -hAl'
    alias l='ls -lF'
fi

alias mdstat='cat /proc/mdstat'
alias ...='cd ../../'

# generate alias named "$KERNELVERSION-reboot" so you can use boot with kexec:
if [[ -x /sbin/kexec ]] && [[ -r /proc/cmdline ]] ; then
    alias "$(uname -r)-reboot"="kexec -l --initrd=/boot/initrd.img-"$(uname -r)" --command-line=\"$(cat /proc/cmdline)\" /boot/vmlinuz-"$(uname -r)""
fi

alias cp='nocorrect cp'         # no spelling correction on cp
alias mkdir='nocorrect mkdir'   # no spelling correction on mkdir
alias mv='nocorrect mv'         # no spelling correction on mv
alias rm='nocorrect rm'         # no spelling correction on rm

#a1# Execute \kbd{rmdir}
alias rd='rmdir'
#a1# Execute \kbd{mkdir}
alias md='mkdir'

# see http://www.cl.cam.ac.uk/~mgk25/unicode.html#term for details
alias term2iso="echo 'Setting terminal to iso mode' ; print -n '\e%@'"
alias term2utf="echo 'Setting terminal to utf-8 mode'; print -n '\e%G'"

# make sure it is not assigned yet
[[ -n ${aliases[utf2iso]} ]] && unalias utf2iso
utf2iso() {
    if isutfenv ; then
        for ENV in $(env | command grep -i '.utf') ; do
            eval export "$(echo $ENV | sed 's/UTF-8/iso885915/ ; s/utf8/iso885915/')"
        done
    fi
}

# make sure it is not assigned yet
[[ -n ${aliases[iso2utf]} ]] && unalias iso2utf
iso2utf() {
    if ! isutfenv ; then
        for ENV in $(env | command grep -i '\.iso') ; do
            eval export "$(echo $ENV | sed 's/iso.*/UTF-8/ ; s/ISO.*/UTF-8/')"
        done
    fi
}

# set up software synthesizer via speakup
swspeak() {
    if [ -x /usr/sbin/swspeak-setup ] ; then
       setopt singlelinezle
       unsetopt prompt_cr
       export PS1="%m%# "
       /usr/sbin/swspeak-setup $@
     else # old version:
        if ! [[ -r /dev/softsynth ]] ; then
            flite -o play -t "Sorry, software synthesizer not available. Did you boot with swspeak bootoption?"
            return 1
        else
           setopt singlelinezle
           unsetopt prompt_cr
           export PS1="%m%# "
            nice -n -20 speechd-up
            sleep 2
            flite -o play -t "Finished setting up software synthesizer"
        fi
     fi
}

# I like clean prompt, so provide simple way to get that
check_com 0 || alias 0='return 0'

# for really lazy people like mika:
check_com S &>/dev/null || alias S='screen'
check_com s &>/dev/null || alias s='ssh'

# especially for roadwarriors using GNU screen and ssh:
if ! check_com asc &>/dev/null ; then
  asc() { autossh -t "$@" 'screen -RdU' }
  compdef asc=ssh
fi

# get top 10 shell commands:
alias top10='print -l ? ${(o)history%% *} | uniq -c | sort -nr | head -n 10'

# truecrypt; use e.g. via 'truec /dev/ice /mnt/ice' or 'truec -i'
if check_com -c truecrypt ; then
    if isutfenv ; then
        alias truec='truecrypt --mount-options "rw,sync,dirsync,users,uid=1000,gid=users,umask=077,utf8" '
    else
        alias truec='truecrypt --mount-options "rw,sync,dirsync,users,uid=1000,gid=users,umask=077" '
    fi
fi

#f1# Hints for the use of zsh on grml
zsh-help() {
    print "$bg[white]$fg[black]
zsh-help - hints for use of zsh on grml
=======================================$reset_color"

    print '
Main configuration of zsh happens in /etc/zsh/zshrc.
That file is part of the package grml-etc-core, if you want to
use them on a non-grml-system just get the tar.gz from
http://deb.grml.org/ or (preferably) get it from the git repository:

  http://git.grml.org/f/grml-etc-core/etc/zsh/zshrc

This version of grml'\''s zsh setup does not use skel/.zshrc anymore.
The file is still there, but it is empty for backwards compatibility.

For your own changes use these two files:
    $HOME/.zshrc.pre
    $HOME/.zshrc.local

The former is sourced very early in our zshrc, the latter is sourced
very lately.

System wide configuration without touching configuration files of grml
can take place in /etc/zsh/zshrc.local.

Normally, the root user (EUID == 0) does not get the whole grml setup.
If you want to force the whole setup for that user, too, set
GRML_ALWAYS_LOAD_ALL=1 in .zshrc.pre in root'\''s home directory.

For information regarding zsh start at http://grml.org/zsh/

Take a look at grml'\''s zsh refcard:
% xpdf =(zcat /usr/share/doc/grml-docs/zsh/grml-zsh-refcard.pdf.gz)

Check out the main zsh refcard:
% '$BROWSER' http://www.bash2zsh.com/zsh_refcard/refcard.pdf

And of course visit the zsh-lovers:
% man zsh-lovers

You can adjust some options through environment variables when
invoking zsh without having to edit configuration files.
Basically meant for bash users who are not used to the power of
the zsh yet. :)

  "NOCOR=1    zsh" => deactivate automatic correction
  "NOMENU=1   zsh" => do not use auto menu completion (note: use ctrl-d for completion instead!)
  "NOPRECMD=1 zsh" => disable the precmd + preexec commands (set GNU screen title)
  "NOTITLE=1  zsh" => disable setting the title of xterms without disabling
                      preexec() and precmd() completely
  "BATTERY=1  zsh" => activate battery status (via acpi) on right side of prompt
  "COMMAND_NOT_FOUND=1 zsh"
                   => Enable a handler if an external command was not found
                      The command called in the handler can be altered by setting
                      the GRML_ZSH_CNF_HANDLER variable, the default is:
                      "/usr/share/command-not-found/command-not-found"

A value greater than 0 is enables a feature; a value equal to zero
disables it. If you like one or the other of these settings, you can
add them to ~/.zshrc.pre to ensure they are set when sourcing grml'\''s
zshrc.'

    print "
$bg[white]$fg[black]
Please report wishes + bugs to the grml-team: http://grml.org/bugs/
Enjoy your grml system with the zsh!$reset_color"
}

# debian stuff
if [[ -r /etc/debian_version ]] ; then
    #a3# Execute \kbd{apt-cache search}
    alias acs='apt-cache search'
    #a3# Execute \kbd{apt-cache show}
    alias acsh='apt-cache show'
    #a3# Execute \kbd{apt-cache policy}
    alias acp='apt-cache policy'
    #a3# Execute \kbd{apt-get dist-upgrade}
    salias adg="apt-get dist-upgrade"
    #a3# Execute \kbd{apt-get install}
    salias agi="apt-get install"
    #a3# Execute \kbd{aptitude install}
    salias ati="aptitude install"
    #a3# Execute \kbd{apt-get upgrade}
    salias ag="apt-get upgrade"
    #a3# Execute \kbd{apt-get update}
    salias au="apt-get update"
    #a3# Execute \kbd{aptitude update ; aptitude safe-upgrade}
    salias -a up="aptitude update ; aptitude safe-upgrade"
    #a3# Execute \kbd{dpkg-buildpackage}
    alias dbp='dpkg-buildpackage'
    #a3# Execute \kbd{grep-excuses}
    alias ge='grep-excuses'

    # debian upgrade
    #f3# Execute \kbd{apt-get update \&\& }\\&\quad \kbd{apt-get dist-upgrade}
    upgrade() {
        emulate -L zsh
        if [[ -z $1 ]] ; then
            $SUDO apt-get update
            $SUDO apt-get -u upgrade
        else
            ssh $1 $SUDO apt-get update
            # ask before the upgrade
            local dummy
            ssh $1 $SUDO apt-get --no-act upgrade
            echo -n 'Process the upgrade?'
            read -q dummy
            if [[ $dummy == "y" ]] ; then
                ssh $1 $SUDO apt-get -u upgrade --yes
            fi
        fi
    }

    # get a root shell as normal user in live-cd mode:
    if isgrmlcd && [[ $UID -ne 0 ]] ; then
       alias su="sudo su"
     fi

    #a1# Take a look at the syslog: \kbd{\$PAGER /var/log/syslog}
    salias llog="$PAGER /var/log/syslog"     # take a look at the syslog
    #a1# Take a look at the syslog: \kbd{tail -f /var/log/syslog}
    salias tlog="tail -f /var/log/syslog"    # follow the syslog
fi

# sort installed Debian-packages by size
if check_com -c grep-status ; then
    #a3# List installed Debian-packages sorted by size
    alias debs-by-size='grep-status -FStatus -sInstalled-Size,Package -n "install ok installed" | paste -sd "  \n" | sort -rn'
fi

# if cdrecord is a symlink (to wodim) or isn't present at all warn:
if [[ -L /usr/bin/cdrecord ]] || ! check_com -c cdrecord; then
    if check_com -c wodim; then
        cdrecord() {
            cat <<EOMESS
cdrecord is not provided under its original name by Debian anymore.
See #377109 in the BTS of Debian for more details.

Please use the wodim binary instead
EOMESS
            return 1
        }
    fi
fi

# get_tw_cli has been renamed into get_3ware
if check_com -c get_3ware ; then
    get_tw_cli() {
        echo 'Warning: get_tw_cli has been renamed into get_3ware. Invoking get_3ware for you.'>&2
        get_3ware
    }
fi

# I hate lacking backward compatibility, so provide an alternative therefore
if ! check_com -c apache2-ssl-certificate ; then

    apache2-ssl-certificate() {

    print 'Debian does not ship apache2-ssl-certificate anymore (see #398520). :('
    print 'You might want to take a look at Debian the package ssl-cert as well.'
    print 'To generate a certificate for use with apache2 follow the instructions:'

    echo '

export RANDFILE=/dev/random
mkdir /etc/apache2/ssl/
openssl req $@ -new -x509 -days 365 -nodes -out /etc/apache2/ssl/apache.pem -keyout /etc/apache2/ssl/apache.pem
chmod 600 /etc/apache2/ssl/apache.pem

Run "grml-tips ssl-certificate" if you need further instructions.
'
    }
fi
# }}}

# {{{ Use hard limits, except for a smaller stack and no core dumps
unlimit
is425 && limit stack 8192
isgrmlcd && limit core 0 # important for a live-cd-system
limit -s
# }}}

# {{{ completion system

# called later (via is4 && grmlcomp)
# note: use 'zstyle' for getting current settings
#         press ^Xh (control-x h) for getting tags in context; ^X? (control-x ?) to run complete_debug with trace output
grmlcomp() {
    # TODO: This could use some additional information

    # allow one error for every three characters typed in approximate completer
    zstyle ':completion:*:approximate:'    max-errors 'reply=( $((($#PREFIX+$#SUFFIX)/3 )) numeric )'

    # don't complete backup files as executables
    zstyle ':completion:*:complete:-command-::commands' ignored-patterns '(aptitude-*|*\~)'

    # start menu completion only if it could find no unambiguous initial string
    zstyle ':completion:*:correct:*'       insert-unambiguous true
    zstyle ':completion:*:corrections'     format $'%{\e[0;31m%}%d (errors: %e)%{\e[0m%}'
    zstyle ':completion:*:correct:*'       original true

    # activate color-completion
    zstyle ':completion:*:default'         list-colors ${(s.:.)LS_COLORS}

    # format on completion
    zstyle ':completion:*:descriptions'    format $'%{\e[0;31m%}completing %B%d%b%{\e[0m%}'

    # automatically complete 'cd -<tab>' and 'cd -<ctrl-d>' with menu
    # zstyle ':completion:*:*:cd:*:directory-stack' menu yes select

    # insert all expansions for expand completer
    zstyle ':completion:*:expand:*'        tag-order all-expansions
    zstyle ':completion:*:history-words'   list false

    # activate menu
    zstyle ':completion:*:history-words'   menu yes

    # ignore duplicate entries
    zstyle ':completion:*:history-words'   remove-all-dups yes
    zstyle ':completion:*:history-words'   stop yes

    # match uppercase from lowercase
    zstyle ':completion:*'                 matcher-list 'm:{a-z}={A-Z}'

    # separate matches into groups
    zstyle ':completion:*:matches'         group 'yes'
    zstyle ':completion:*'                 group-name ''

    if [[ "$NOMENU" -eq 0 ]] ; then
        # if there are more than 5 options allow selecting from a menu
        zstyle ':completion:*'               menu select=5
    else
        # don't use any menus at all
        setopt no_auto_menu
    fi

    zstyle ':completion:*:messages'        format '%d'
    zstyle ':completion:*:options'         auto-description '%d'

    # describe options in full
    zstyle ':completion:*:options'         description 'yes'

    # on processes completion complete all user processes
    zstyle ':completion:*:processes'       command 'ps -au$USER'

    # offer indexes before parameters in subscripts
    zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

    # provide verbose completion information
    zstyle ':completion:*'                 verbose true

    # recent (as of Dec 2007) zsh versions are able to provide descriptions
    # for commands (read: 1st word in the line) that it will list for the user
    # to choose from. The following disables that, because it's not exactly fast.
    zstyle ':completion:*:-command-:*:'    verbose false

    # set format for warnings
    zstyle ':completion:*:warnings'        format $'%{\e[0;31m%}No matches for:%{\e[0m%} %d'

    # define files to ignore for zcompile
    zstyle ':completion:*:*:zcompile:*'    ignored-patterns '(*~|*.zwc)'
    zstyle ':completion:correct:'          prompt 'correct to: %e'

    # Ignore completion functions for commands you don't have:
    zstyle ':completion::(^approximate*):*:functions' ignored-patterns '_*'

    # Provide more processes in completion of programs like killall:
    zstyle ':completion:*:processes-names' command 'ps c -u ${USER} -o command | uniq'

    # complete manual by their section
    zstyle ':completion:*:manuals'    separate-sections true
    zstyle ':completion:*:manuals.*'  insert-sections   true
    zstyle ':completion:*:man:*'      menu yes select

    # provide .. as a completion
    zstyle ':completion:*' special-dirs ..

    # run rehash on completion so new installed program are found automatically:
    _force_rehash() {
        (( CURRENT == 1 )) && rehash
        return 1
    }

    ## correction
    # some people don't like the automatic correction - so run 'NOCOR=1 zsh' to deactivate it
    if [[ "$NOCOR" -gt 0 ]] ; then
        zstyle ':completion:*' completer _oldlist _expand _force_rehash _complete _files _ignored
        setopt nocorrect
    else
        # try to be smart about when to use what completer...
        setopt correct
        zstyle -e ':completion:*' completer '
            if [[ $_last_try != "$HISTNO$BUFFER$CURSOR" ]] ; then
                _last_try="$HISTNO$BUFFER$CURSOR"
                reply=(_complete _match _ignored _prefix _files)
            else
                if [[ $words[1] == (rm|mv) ]] ; then
                    reply=(_complete _files)
                else
                    reply=(_oldlist _expand _force_rehash _complete _ignored _correct _approximate _files)
                fi
            fi'
    fi

    # command for process lists, the local web server details and host completion
    zstyle ':completion:*:urls' local 'www' '/var/www/' 'public_html'

    # caching
    [[ -d $ZSHDIR/cache ]] && zstyle ':completion:*' use-cache yes && \
                            zstyle ':completion::complete:*' cache-path $ZSHDIR/cache/

    # host completion /* add brackets as vim can't parse zsh's complex cmdlines 8-) {{{ */
    if is42 ; then
        [[ -r ~/.ssh/known_hosts ]] && _ssh_hosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[\|]*}%%\ *}%%,*}) || _ssh_hosts=()
        [[ -r /etc/hosts ]] && : ${(A)_etc_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}} || _etc_hosts=()
    else
        _ssh_hosts=()
        _etc_hosts=()
    fi
    hosts=(
        $(hostname)
        "$_ssh_hosts[@]"
        "$_etc_hosts[@]"
        grml.org
        localhost
    )
    zstyle ':completion:*:hosts' hosts $hosts
    # TODO: so, why is this here?
    #  zstyle '*' hosts $hosts

    # use generic completion system for programs not yet defined; (_gnu_generic works
    # with commands that provide a --help option with "standard" gnu-like output.)
    for compcom in cp deborphan df feh fetchipac head hnb ipacsum mv \
                   pal stow tail uname ; do
        [[ -z ${_comps[$compcom]} ]] && compdef _gnu_generic ${compcom}
    done; unset compcom

    # see upgrade function in this file
    compdef _hosts upgrade
}
# }}}

# {{{ now run the functions
isgrml && checkhome
is4    && isgrml    && grmlstuff
is4    && grmlcomp
# }}}

# {{{ keephack
is4 && xsource "/etc/zsh/keephack"
# }}}

# shell functions {{{

#f1# Provide csh compatibility
setenv()  { typeset -x "${1}${1:+=}${(@)argv[2,$#]}" }  # csh compatibility

#f1# Reload an autoloadable function
freload() { while (( $# )); do; unfunction $1; autoload -U $1; shift; done }
compdef _functions freload

#f1# List symlinks in detail (more detailed version of 'readlink -f' and 'whence -s')
sll() {
    [[ -z "$1" ]] && printf 'Usage: %s <file(s)>\n' "$0" && return 1
    for file in "$@" ; do
        while [[ -h "$file" ]] ; do
            ls -l $file
            file=$(readlink "$file")
        done
    done
}

# fast manual access
if check_com qma ; then
    #f1# View the zsh manual
    manzsh()  { qma zshall "$1" }
    compdef _man qma
else
    manzsh()  { /usr/bin/man zshall |  vim -c "se ft=man| se hlsearch" +/"$1" - ; }
fi

#f1# Edit an alias via zle
edalias() {
    [[ -z "$1" ]] && { echo "Usage: edalias <alias_to_edit>" ; return 1 } || vared aliases'[$1]' ;
}
compdef _aliases edalias

#f1# Edit a function via zle
edfunc() {
    [[ -z "$1" ]] && { echo "Usage: edfun <function_to_edit>" ; return 1 } || zed -f "$1" ;
}
compdef _functions edfunc

#f1# Provides useful information on globbing
H-Glob() {
    echo -e "
    /      directories
    .      plain files
    @      symbolic links
    =      sockets
    p      named pipes (FIFOs)
    *      executable plain files (0100)
    %      device files (character or block special)
    %b     block special files
    %c     character special files
    r      owner-readable files (0400)
    w      owner-writable files (0200)
    x      owner-executable files (0100)
    A      group-readable files (0040)
    I      group-writable files (0020)
    E      group-executable files (0010)
    R      world-readable files (0004)
    W      world-writable files (0002)
    X      world-executable files (0001)
    s      setuid files (04000)
    S      setgid files (02000)
    t      files with the sticky bit (01000)

  print *(m-1)          # Files modified up to a day ago
  print *(a1)           # Files accessed a day ago
  print *(@)            # Just symlinks
  print *(Lk+50)        # Files bigger than 50 kilobytes
  print *(Lk-50)        # Files smaller than 50 kilobytes
  print **/*.c          # All *.c files recursively starting in \$PWD
  print **/*.c~file.c   # Same as above, but excluding 'file.c'
  print (foo|bar).*     # Files starting with 'foo' or 'bar'
  print *~*.*           # All Files that do not contain a dot
  chmod 644 *(.^x)      # make all plain non-executable files publically readable
  print -l *(.c|.h)     # Lists *.c and *.h
  print **/*(g:users:)  # Recursively match all files that are owned by group 'users'
  echo /proc/*/cwd(:h:t:s/self//) # Analogous to >ps ax | awk '{print $1}'<"
}
alias help-zshglob=H-Glob

check_com -c qma && alias ?='qma zshall'

# a wrapper for vim, that deals with title setting
#   VIM_OPTIONS
#       set this array to a set of options to vim you always want
#       to have set when calling vim (in .zshrc.local), like:
#           VIM_OPTIONS=( -p )
#       This will cause vim to send every file given on the
#       commandline to be send to it's own tab (needs vim7).
vim() {
    VIM_PLEASE_SET_TITLE='yes' command vim ${VIM_OPTIONS} "$@"
}

# {{{ make sure our environment is clean regarding colors
for color in BLUE RED GREEN CYAN YELLOW MAGENTA WHITE ; unset $color
# }}}

# "persistent history" {{{
# just write important commands you always need to ~/.important_commands
if [[ -r ~/.important_commands ]] ; then
    fc -R ~/.important_commands
fi
# }}}

# load the lookup subsystem if it's available on the system
zrcautoload lookupinit && lookupinit

# variables {{{

# set terminal property (used e.g. by msgid-chooser)
export COLORTERM="yes"

zrclocal

## genrefcard.pl settings {{{

### doc strings for external functions from files
#m# f5 grml-wallpaper() Sets a wallpaper (try completion for possible values)

### example: split functions-search 8,16,24,32
#@# split functions-search 8

## }}}

## END OF FILE #################################################################
# vim:filetype=zsh foldmethod=marker autoindent expandtab shiftwidth=4
# Local variables:
# mode: sh
# End:
