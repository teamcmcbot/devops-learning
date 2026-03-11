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