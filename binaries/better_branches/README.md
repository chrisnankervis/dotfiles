# better_branches

Lists local git branches in fzf, most recently committed first, and switches to
the selected branch.

`better_branches` starts in normal mode, where `j`/`k` move the cursor. Any
other key starts filtering with fzf. After 0.5s without typing, `j`/`k` scroll
the filtered list again, so you can type a ticket number such as `167`, pause,
then scroll to the branch. Typing again adds to the query, and clearing the
query returns to the full list.

`j`/`k` presses followed quickly by another key become part of the query, so
names that contain `j` or `k`, such as `jira-12` or `fix-kafka`, still match.

## Requirements

- zsh
- git
- fzf 0.45 or later (`bg-transform`, `unbind`, `rebind`)
- tmux (tests only)

## Install

Symlink the binary into a directory on your `PATH`:

```sh
ln -s ~/Code/dotfiles/binaries/better_branches/bin/better_branches ~/.local/bin/better_branches
```

## Configuration

These variables at the top of `bin/better_branches` control the timing:

| Variable     | Default | Effect                                                                  |
| ------------ | ------- | ----------------------------------------------------------------------- |
| `timeout`    | `0.3`   | Maximum gap in seconds between `j`/`k` presses that become query text.  |
| `max_prefix` | `2`     | Longest run of `j`/`k` presses that becomes query text.                 |
| `idle`       | `0.5`   | Seconds without typing before `j`/`k` scroll the filtered list again.   |

## Tests

```sh
test/better_branches_test.zsh
```

The suite creates a throwaway git repository, runs `bin/better_branches` in a
detached tmux session on a private socket (`tmux -L better_branches_test`),
sends keys at typing speed, and checks the fzf query line and the branch it
switches to. It takes about 30 seconds and exits non-zero if any check fails.
