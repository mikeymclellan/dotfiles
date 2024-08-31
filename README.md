## Dotfiles

To install these dotfiles on a new machine:

    git clone git@github.com:mikeymclellan/dotfiles.git
    cd dotfiles
    brew install stow
    stow -t ~ nvim lazygit bin tmux tmuxinator

To add a new package to be stowed from ~/.config:

    mkdir -p [package-name]/.config
    mv ~/.config/[package-name] [package-name]/.config
