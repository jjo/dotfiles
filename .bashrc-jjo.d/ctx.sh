ctx (){
    test -n "${CONTEXT}" || : "${1:?"Usage: ctx {work|personal|um}"}"
    case "$1" in
        work)
            export HISTFILE="${HISTFILE%-*}"
            export KUBECONFIG=~/.kube/config
            export CONTEXT="$1"
            ;;
        p|personal)
            export HISTFILE="${HISTFILE%-*}-personal"
            export KUBECONFIG=~/.kube/kind-kind
            export CONTEXT="personal"
            ;;
        um)
            export HISTFILE="${HISTFILE%-*}-um"
            export KUBECONFIG=~/.kube/um-metal.kubeconfig
            export CONTEXT="$1"
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
}
