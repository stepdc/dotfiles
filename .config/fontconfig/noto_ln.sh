#! /bin/bash

[[ -f /etc/fonts/conf.d/64-language-selector-prefer.conf ]] && sudo rm /etc/fonts/conf.d/64-language-selector-prefer.conf 

sudo ln -s $HOME/.config/fontconfig/noto-sans-prefer-sc.conf  /etc/fonts/conf.d/64-language-selector-prefer.conf 
