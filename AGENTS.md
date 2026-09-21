# Agent instructions

This repository is a single-workstation nix-darwin configuration with one
author. Do not open a pull request. Do not push a branch for review. All work
lands on local `main`.

## Branching

Work directly on `main` for a small, low-risk change.

Use a worktree when a change needs a build-and-verify cycle, or when more than
one agent works at the same time. worktrunk (`wt`) manages the worktrees:

```sh
wt switch --create <branch>   # create the branch and its worktree
# make the change, then commit
wt merge --no-squash          # rebase, fast-forward main, remove the worktree
```

`wt merge` merges the *current* branch into the target branch, not the reverse.
The target defaults to `main`.

Keep every commit. Do not squash. Write the commit message that belongs on
`main` before you merge.

Add `--no-remove` when you run `wt merge` inside the worktree that it merges.
`wt` deletes the worktree directory otherwise, and the shell loses its working
directory.

An agent cannot always run `wt merge`. `wt` moves the `main` ref, then checks
the files out in the main checkout. A sandbox that denies writes outside the
worktree makes that checkout fail with `Operation not permitted`. `wt` rolls the
ref back, and nothing changes. Ask the user to run the merge in that case.

## Commits

Sign every commit with both flags: `git commit -s -S`.

This repository does not use conventional commits, and it does not use
versionist. Write a short imperative subject, as the existing history does. Do
not add a `Change-type:` trailer.

## Build and activate

```sh
make build     # build only
make darwin    # build, then activate
```

Activation needs root and writes to system paths. An agent cannot run it. Build
the change first, then ask the user to run `make switch` to activate the build
that already exists.

Run the activation from this checkout after the merge, not from a worktree.

## Pushing

`origin` is a backup, not a review gate. Push `main` whenever it suits you.

An agent cannot push. The sandbox denies reads of `~/.ssh` and denies the
ssh-agent socket, so SSH authentication fails. Ask the user to run `git push`.

## Never commit

Do not add `CLAUDE.md` or `CLAUDE.local.md` to source control.
