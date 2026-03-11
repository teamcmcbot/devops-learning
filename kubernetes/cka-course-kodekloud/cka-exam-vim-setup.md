# Vim Setup for Kubernetes CKA Exam

First create or open (if already exists) file .vimrc :

```bash
vim ~/.vimrc
```

Now enter (in insert-mode activated with i) the following lines:

```bash
set expandtab
set tabstop=2
set shiftwidth=2
```

Settings explained:

expandtab: use spaces for tab
tabstop: amount of spaces used for tab
shiftwidth: amount of spaces used during indentation



## KodeKloud vim setup

```bash
cluster3-controlplane ~ ➜  cat .vimrc
set termguicolors
execute pathogen#infect()
syntax on
colorscheme dracula
filetype plugin indent on
:set paste

cluster3-controlplane ~ ➜  cat .bashrc 
alias vi="vim"
alias kubectl="k3s kubectl"
alias k=kubectl
complete -F __start_kubectl k
alias crictl="k3s crictl"
source /etc/profile.d/bash_completion.sh
source <(kubectl completion bash)
eval "$(starship init bash)"
export KUBE_EDITOR="vim"
export PS1="\h $ "
export PAGER=less
```


## Killer.sh

### Settings

If vim is not configured properly (e.g., issues with pasting copied content), configure via `~/.vimrc` or by entering manually in vim command mode (`:set ...`):

```bash
set tabstop=2
set expandtab
set shiftwidth=2
```

- `expandtab` makes sure to use spaces for tabs.

> **Note:** Changes in `~/.vimrc` will not be transferred when connecting to other instances via `ssh`.

### Toggle Line Numbers

| Action | Command |
|---|---|
| Show line numbers | `:set number` |
| Hide line numbers | `:set nonumber` |
| Jump to line 22 | `:22` + `Enter` |

- Useful for finding syntax errors based on line numbers
- Can be annoying when wanting to select & copy with mouse

### Copy & Paste

| Action | Keys |
|---|---|
| Mark lines | `Esc` + `V` (then arrow keys) |
| Copy marked lines | `y` |
| Cut marked lines | `d` |
| Paste lines | `p` (after) or `P` (before) |

### Indent Multiple Lines

1. Set indent width: `:set shiftwidth=2`
2. Mark multiple lines: `Shift` + `V` then arrow keys
3. Indent: `>` (right) or `<` (left)
4. Repeat last action: `.`
