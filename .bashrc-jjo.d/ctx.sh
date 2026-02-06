ctx_prompt() {
    # If starship is active, it handles CONTEXT via env_var module
    if ! type starship >/dev/null 2>&1; then
        case "${CONTEXT}" in
            none|"")
                PROMPT="${PROMPT#*|}"
                ;;
            *)
                PROMPT='${CONTEXT}|'"${PROMPT#*|}"
                ;;
        esac
    fi
    test -n "${ZSH_VERSION}" && fc -R
}

ctx_update (){
    case "${1}" in
        w|work)
            export HISTFILE="${HISTFILE%-*}-work"
            export KUBECONFIG=~/.kube/config
            export CONTEXT="work"
            ;;
        p|personal)
            export HISTFILE="${HISTFILE%-*}-personal"
            export KUBECONFIG=~/.kube/kind-kind
            export CONTEXT="personal"
            ;;
        u|um)
            export HISTFILE="${HISTFILE%-*}-um"
            export KUBECONFIG=~/.kube/um-metal.kubeconfig
            export CONTEXT="um"
            ;;
        n|none)
            export HISTFILE="${HISTFILE%-*}"
            unset KUBECONFIG
            unset CONTEXT
            ;;
    esac
    ctx_prompt
}
ctx (){
    test -n "${1}" || : "${1:?"Usage: ctx {work|personal|um|none}"}"
    test -z "${1}" && echo "Current context: $CONTEXT" && return
    ctx_update "${1}"
}

test -n "${CONTEXT}" && ctx_update "${CONTEXT}"
