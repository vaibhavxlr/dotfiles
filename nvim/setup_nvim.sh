#!/usr/bin/env bash

set -e

echo ">>> Installing Neovim + essentials..."

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt update
    sudo apt install -y neovim git curl build-essential unzip ripgrep fd-find nodejs npm python3 python3-pip
elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install neovim git ripgrep fd node python
else
    echo "Unsupported OS. Please install Neovim manually."
    exit 1
fi

if ! command -v go &> /dev/null; then
    echo ">>> Installing Go..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt install -y golang
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install go
    fi
fi

if ! command -v cargo &> /dev/null; then
    echo ">>> Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

if ! command -v opam &> /dev/null; then
    echo ">>> Installing OPAM..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt install -y opam
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install opam
    fi
    opam init -y --disable-sandboxing
    eval $(opam env)
fi

echo ">>> Installing OCaml LSP..."
opam install -y ocaml-lsp-server ocamlformat

echo ">>> Setting up Neovim config..."
NVIM_CONFIG_DIR="$HOME/.config/nvim"
mkdir -p "$NVIM_CONFIG_DIR"

cp ./init.lua "$NVIM_CONFIG_DIR/init.lua"

echo ">>> Bootstrapping plugins..."
nvim --headless "+Lazy! sync" +qa

echo ">>> Done! Open Neovim with 'nvim'"

