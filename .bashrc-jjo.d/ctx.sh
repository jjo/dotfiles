ctx_prompt() {
    case "${CONTEXT}" in
        none|"")
            PROMPT="${PROMPT#*|}"
            ;;
        *)
            PROMPT='${CONTEXT}|'"${PROMPT#*|}"
            ;;
    esac
}

ctx (){
    test -n "${CONTEXT}" || : "${1:?"Usage: ctx {work|personal|um|none}"}"
    case "$1" in
        w|work)
            export HISTFILE="${HISTFILE%-*}" ## <- default HISTFILE
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
        "")
            echo "Current context: $CONTEXT"
            return 0
            ;;
        *)
            echo "Unknown context: $1"
            return 1
            ;;
    esac
    ctx_prompt
}

ctx_prompt
