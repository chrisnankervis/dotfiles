#!/usr/bin/env zsh

# Drives bin/better_branches through fzf in a detached tmux session against a
# throwaway git repository, then checks the query line and the branch it
# switched to. Requires git, fzf and tmux.

zmodload zsh/datetime

root=${0:A:h:h}
bin=$root/bin/better_branches
# A private tmux socket keeps the tests away from any running tmux server.
tmux_cmd=(tmux -L better_branches_test)
session=better_branches_test
# Delay between typed keys, close to human typing speed.
key_delay=0.06
# Longer than $idle in bin/better_branches, so search mode returns to normal mode.
pause=1

passed=0
failed=0

for cmd in git fzf tmux; do
  if ! command -v $cmd >/dev/null; then
    echo "better_branches_test: $cmd is not installed" >&2
    exit 1
  fi
done

tmp=$(mktemp -d)
trap '$tmux_cmd kill-server 2>/dev/null; rm -rf $tmp' EXIT

# Branches in --sort=-committerdate order. Each branch gets its own commit
# with a decreasing commit date, so the list order is fixed.
branches=(main feature-a feature-b fix-kafka jira-12 kite tls-167-a tls-167-b tls-168)

repo=$tmp/repo
git init -q -b main $repo
commit() {
  GIT_AUTHOR_DATE="2026-01-01T00:00:$1" GIT_COMMITTER_DATE="2026-01-01T00:00:$1" \
    git -C $repo -c user.name=test -c user.email=test@example.com commit -q --allow-empty -m $2
}
commit 10 init
for i in {${#branches}..2}; do
  git -C $repo switch -q -c $branches[i] main
  commit $(( 20 + ${#branches} - i )) $branches[i]
done
git -C $repo switch -q main
commit 59 main

# Starts better_branches in a new tmux session. The branch it switches to is
# written to $tmp/result.
start() {
  git -C $repo switch -q main
  rm -f $tmp/result
  $tmux_cmd kill-session -t $session 2>/dev/null
  $tmux_cmd new-session -d -s $session -x 80 -y 30 -c $repo \
    "$bin; git branch --show-current > $tmp/result; sleep 10"
  sleep 0.6
}

press() {
  for key in $@; do
    $tmux_cmd send-keys -t $session $key
    sleep $key_delay
  done
}

type_text() {
  for c in ${(s::)1}; do
    $tmux_cmd send-keys -t $session -l -- $c
    sleep $key_delay
  done
}

# Prints the fzf query line without the "> " prompt.
query() {
  local line=${${(f)"$($tmux_cmd capture-pane -pt $session)"}[1]}
  line=${line%%[[:space:]]#}
  line=${line#>}
  print -r -- ${line# }
}

# Presses Enter and prints the branch better_branches switched to.
accept() {
  press Enter
  local t0=$EPOCHREALTIME
  until [[ -s $tmp/result ]] || (( EPOCHREALTIME - t0 > 5 )); do sleep 0.05; done
  print -r -- "$(<$tmp/result)"
  $tmux_cmd kill-session -t $session 2>/dev/null
}

check() {
  local name=$1 actual=$2 expected=$3
  if [[ $actual == $expected ]]; then
    (( passed++ ))
    echo "ok   $name"
  else
    (( failed++ ))
    echo "FAIL $name: expected '$expected', got '$actual'"
  fi
}

# --- Normal mode -------------------------------------------------------------

start
press j; sleep 0.5; press j; sleep 0.5
check "j j scrolls the full list" "$(accept)" feature-b

start
press j; sleep 0.5; type_text fe; sleep 0.3; press BSpace BSpace; sleep 0.3
press j; sleep 0.4; press j; sleep 0.4
check "clearing the query returns to scrolling from the top" "$(accept)" feature-b

# --- Queries that start with j or k ------------------------------------------

for i in 1 2 3; do
  start
  type_text jira; sleep 0.3
  check "typed jira keeps the leading j (run $i)" "$(query)" "jira"
  check "typed jira selects jira-12 (run $i)" "$(accept)" jira-12
done

for i in 1 2 3; do
  start
  type_text kite; sleep 0.3
  check "typed kite at the top keeps the leading k (run $i)" "$(query)" "kite"
  check "typed kite selects kite (run $i)" "$(accept)" kite
done

# --- Search, pause, then scroll or keep typing -------------------------------

start
type_text 167; sleep $pause; press j; sleep 0.4
check "167, pause, j keeps the query" "$(query)" "167"
check "167, pause, j scrolls the filtered list" "$(accept)" tls-167-b

start
type_text 167; sleep $pause; press j; sleep 0.4; press k; sleep 0.4
check "167, pause, j, k scrolls back up" "$(accept)" tls-167-a

start
type_text 167; sleep $pause; type_text kj; sleep 0.3
check "167, pause, kj only scrolls" "$(query)" "167"
$tmux_cmd kill-session -t $session

start
type_text tls; sleep $pause; type_text -168; sleep 0.3
check "tls, pause, -168 appends to the query" "$(query)" "tls-168"
check "tls, pause, -168 selects tls-168" "$(accept)" tls-168

start
type_text fix-; sleep $pause; type_text kafka; sleep 0.3
check "fix-, pause, kafka keeps the k typed in normal mode" "$(query)" "fix-kafka"
check "fix-, pause, kafka selects fix-kafka" "$(accept)" fix-kafka

# --- Held keys ---------------------------------------------------------------

# 60 queued j presses, then x. fzf must not block on the j presses, and the
# run of j presses is too long to count as part of the query.
start
$tmux_cmd send-keys -t $session ${(s: :)${(l:120::j :)}}
$tmux_cmd send-keys -t $session -l x
t0=$EPOCHREALTIME
until [[ $(query) == *x ]] || (( EPOCHREALTIME - t0 > 5 )); do sleep 0.02; done
elapsed=$(( EPOCHREALTIME - t0 ))
check "held j then x drops the j run" "$(query)" "x"
check "held j responds within 0.5s (took ${elapsed[1,5]}s)" $(( elapsed < 0.5 )) 1
$tmux_cmd kill-session -t $session

echo
echo "$passed passed, $failed failed"
(( failed == 0 ))
