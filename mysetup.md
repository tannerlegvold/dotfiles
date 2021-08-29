## General Comments
I want to set up a Kettelstassen, a large database of all my notes and files (organized a certain way). I would want to have great infrastructure for it since thats a bit of a big undertaking. I would want updates over time to be stored somehow (like git actually). I would want it stored securely in the cloud or on a drive and for my system to have a local copy (gotta figure out how to do this automagically), probably gotta use Google Drive or Github, Github has versioning but Google Drive has more storage and fewer restraints. Probably gonna try to organize my system using a database file of some sort and then have some sort of automatic setup for Google Drive syncing. On a related subject I found this site https://dotfiles.github.io/. It talks about all the different ways to manage dotfiles/system configuration. A favorite is naturally Home Manager with Nix. This will be an essential part of my Kettelstassen, though I have no clue how. Perhaps I should start making a list of things I will include in my KettelStassen, for starters: ~/idea, ~/Desktop/langideas, the several random idea files in my Google Drive, all my browser Favorites/Bookmarks, all my Youtube subscriptions, of course, all important files on my file system, my config files including mysetup

Currently I'm trying to move away from AutoKey for getting Alt + Left/Right to change tab focus in Chrome/Firefox because it only works in X11 and I want my setup to work in Wayland (touchpad gestures baby!). I'm struggling to find a good solution, right now Hawck seems like the closest thing to a solution but we'll see.

Another outstanding issue is getting images to work with Ranger, I think I will try Kitty for this. This brings up a problem, Kitty doesn't work with my current Bash setup, if Kitty does turn out to handle images well in Wayland then I should look into bash-it, a different Bash configuration framework that may work better with Kitty than oh-my-bash. Also, look in Kitty's config files, they may have something (like something capturing certain key combos) that explains why Kitty doesn't work with ble.sh and can be disabled.

Also see if you can get Activities icons (like desktop icons) that launch Chrome in a certain profile. Would be much more convinient. Also try to fix the problems with the three chrome profiles existing instead of two.

--------------------------------------------------------------------------------------------

## General
Its bad to be restricted to the standard Canonical repositories, lets add universe
```
sudo add-apt-repository universe
```
And lets install some basic stuff right now
```
sudo apt install curl python3-pip npm
```
I like to install source to a software directory in the home directory, so lets make one
```
mkdir software
```
I don't like all the addtional directories, lets remove them
```
rmdir Videos Pictures Documents Music Public Templates
```

--------------------------------------------------------------------------------------------

## Micro
To install micro, we'll use this script from their website
```
curl https://getmic.ro | bash
```
This sets the `$EDITOR` variable (nice, now we don't have to) and installs the exectuable to the current directory, lets move it to `/usr/local/bin` (this is where we should install binaries not intended to be managed by the system if we want all users on the system to have access to them, put it in `~/.local/bin` if we only want ourselves to have access to it)
```
sudo mv micro /usr/local/bin
```
To make copy/paste interact with the rest of the system we must also install xclip
```
sudo apt install xclip
```
I don't have any preferred settings or plugins, if I did, this is where I'd put them.

--------------------------------------------------------------------------------------------

## Git
Install it (we'll also need make)
```
sudo apt install git make
```
We'll need to set up authentication (following this post https://askubuntu.com/questions/773455/what-is-the-correct-way-to-use-git-with-gnome-keyring-and-https-repos/959662#959662)
```
sudo apt install libsecret-1-0 libsecret-1-dev
sudo make --directory=/usr/share/doc/git/contrib/credential/libsecret
git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret
```
Now the next time we clone a repo, Git will save our login info and we won't need to enter ever again. On that first login, use tannerlegvold as the username and go to Github and make a new "token" (to do this, follow the instructions here https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token) to use as the password.

--------------------------------------------------------------------------------------------

## Fonts
Several things in my terminal (ranger and oh-my-bash specifically) rely on special fonts with additional icons that look cool, the Nerd Fonts (https://www.nerdfonts.com/) project handles this stuff. 
Lets download my preferred font, Souce Code Pro (open source variations are sometimes called Sauce Code Pro for legal reasons)
```
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/SourceCodePro.zip
```
You can also go to https://github.com/ryanoasis/nerd-fonts in a broswer and click on Releases then find the appropriate download link and click it. In which case the .zip will be downloaded to the `~/Downloads` directory (typically), this modifies the below instructions slightly
For a system wide installation the fonts must go in `/usr/share/fonts` (for a user local installation put them in `~/.local/share/fonts`, make it if it doesn't already exist). Since what we downloaded is all stored as a buch of .ttf files, its best if we put it in the truetype directory specifically. We downloaded a zip so I'll use unzip to extract it to the appropriate location
```
sudo unzip SourceCodePro.zip -d /usr/share/fonts/truetype/SourceCodePro
```
Then in either case we rebuild the font cache
```
sudo fc-cache -f -v
```
Then delete the .zip file
```
rm SourceCodePro.zip
```
Now go to the settings/preferences of your terminal emulator (I only ever use Gnome Terminal and Terminator) and tell it to use SauceCodePro Nerd Font Mono (or any of the other options)
If you have trouble, install this package, sometimes that helps with the powerline fonts at least
```
sudo apt install fonts-powerline
```

--------------------------------------------------------------------------------------------

## Ranger
First lets install it
```
sudo apt install ranger
```
Then we install the one plugin I use (if you haven't installed the fonts don't install this plugin cause it will not look right)
```
git clone https://github.com/alexanderjeurissen/ranger_devicons ~/.config/ranger/plugins/ranger_devicons
```
Lets get ranger ready for image previews, the default method is through w3m but that only works in obscure terminal emulators, Kitty doesn't work with my Bash defaults, and ueberzug only works in X11... ueberzug seems like the least of three evils so we'll do that one for now. It has several dependencies, lets do those first
```
sudo apt install libxext-dev libx11-dev libxtst-dev python3-docopt python3-xlib python3-pil
```
Now we install ueberzug (through pip not apt)
```
pip3 install ueberzug
```
For more information, see https://github.com/ranger/ranger/wiki/Image-Previews
Ranger has four config files that should go in `~/.config/ranger` but don't exist by default, we must modify two, specifically `rc.conf` and `rifle.conf`. Its best to only add the changes we want to `rc.conf` and let Ranger use its builtin defaults for the rest
```
mkdir ~/.config/ranger
cd ~/.config/ranger
touch rc.conf
```
Then enter `rc.conf` and add these lines (don't add the first line if you didn't install the plugin)
```
default_linemode devicons
set preview_images true
set preview_images_method ueberzug
set draw_borders both
```
`rifle.conf` is different, if the user provides one then Ranger ONLY uses that file and does not use any defaults, since `rifle.conf` is how Ranger opens files of a given extension, it would be a lot of work on our part to make a file even remotely convienent, so Ranger provides a command that copies a default config to the config directory which we then make minor (or major) edits to. Lets do it
Have ranger make the default rifle.conf (it goes in ~/.config/ranger by default)
```
ranger --copy-config=rifle
```
Enter `rifle.conf` and add this (preferably near the top for visibility reasons)
```
# Begin my edits
# For Mathematica stuff
# should I make these for .m .wl and any other MMA files (CDFs?, .tr?)
ext nb, flag f = mathematica -- "$1"
# End my edits
```
See the Configuration section of the project wiki for more information (https://github.com/ranger/ranger/wiki/Official-user-guide#configuration-)
Lastly, adding this to your `.bashrc` makes a `ranger_cd` command that leaves you in the directory you ended in in Ranger (much more intuitive than the default) and binds it to Ctrl + o for convienence
```
# This is a small wrapper around ranger that puts me in the last 
# directory ranger was in when it closed. This works without me having
# to edit ranger's configs at all. Basically its ranger but more convienent
function ranger_cd() {
    temp_file="$(mktemp -t "ranger_cd.XXXXXXXXXX")"
    ranger --choosedir="$temp_file" -- "${@:-$PWD}"
    if chosen_dir="$(cat -- "$temp_file")" && [ -n "$chosen_dir" ] && [ "$chosen_dir" != "$PWD" ]; then
        cd -- "$chosen_dir"
    fi
    rm -f -- "$temp_file"
}

# This binds Ctrl-O to ranger_cd
[[ $- == *i* ]] && bind '"\C-o":"ranger_cd\C-m"'
# The [[ $- == *i* ]] && is so that it only runs in interactive shells. If I 
# don't add this I get errors on login. I got that from https://unix.stackexchange.com/questions/26676/how-to-check-if-a-shell-is-login-interactive-batch
 
# This is so that the ranger command will actually call the ranger_cd command
# alias ranger="ranger_cd"
```
Of course, its already in mine so if you do the Bash Stuff section below (where you install my `.bashrc`) you won't need to add it manually

--------------------------------------------------------------------------------------------

## Bash Stuff
Its best if we do Oh-My-Bash and Bash Line Editor.sh (ble.sh) in one go because they both modify the `.bashrc`.
First lets get Oh-My-Bash
```
bash -c "$(wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)"
```
We need git, make, and gawk to get ble.sh, we already have the first two so lets get the third
```
sudo apt install gawk
```
Installing ble.sh involves cloning the repo and running a install script, so lets do it in our software directory
```
cd software
git clone --recursive https://github.com/akinomyoga/ble.sh.git
make -C ble.sh install PREFIX=~/.local
cd ..
```
Now we ditch the `.bashrc` generated by Oh-My-Bash and the old `.bashrc`
```
rm .bashrc
rm .bashrc.pre-oh-my-bash
```
Now lets download my `.bashrc` (make sure you're in the home directory, so it downloads to there), its already got the Oh-My-Bash and ble.sh configuration setup
```
wget https://raw.githubusercontent.com/tannerlegvold/dotfiles/main/.bashrc
```
And I think we're good to go, try opening a new terminal and hopefully it all works
You can delete the ble.sh source if you don't want it in the software directory (since I don't think we'll be touching it any more), if you do, it will redownload itself to `~/.local/share/blesh/src` the next time we call `ble-update`, lets do that now
```
cd software
rm -rf ble.sh
cd ..
ble-update
```

--------------------------------------------------------------------------------------------

## Chrome
Make sure you've added the universe repositories, then just do this
```
sudo apt install google-chrome-stable
```
I don't like smooth scrolling and I don't know if Chrome saves that setting from instance to instance, to be sure it is set properly, enter
```
chrome://flags/#smooth-scrolling
```
into the address bar of Chrome and change the setting to `Disable`.

Most of these instructions are uneccesary
Since Chrome is not open source you can't get it in the Canonical repositories. Instead we will download the .deb from their website
```
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
```
And install it 
```
sudo dpkg -i google-chrome-stable_current_amd64.deb
```
Now that its installed we don't need the .deb anymore, so lets delete it
```
rm google-chrome-stable_current_amd64.deb
```
If you log in to one of your Google Accounts then all your extensions should be there automatically. Don't forget to set Chrome as the default web browser by opening Settings and going to Default Applications and setting Web to be Google Chrome.

--------------------------------------------------------------------------------------------

## Gnome
First install Gnome Tweaks if it isn't already
```
sudo apt install gnome-tweaks
```
Now open it and click on Extensions, now enable extensions by clicking the slider in the upper right hand corner. Now we can start using extensions.
Assuming your Chrome is logged into your Google Account you should already have the GNOME Shell Integration extension (if not for whatever reason, you can get it here https://chrome.google.com/webstore/detail/gnome-shell-integration/gphhapmejobijbbhgpjhcjognlahblep) and be able to access my extension list here (https://extensions.gnome.org/local/) to turn on whatever you want. If not, heres a list of my preferred extensions, simply go to the URL and click on the slider bar to install them
* https://extensions.gnome.org/extension/3357/material-shell/
* https://extensions.gnome.org/extension/517/caffeine/
* https://extensions.gnome.org/extension/4075/shell-restarter/
* https://extensions.gnome.org/extension/906/sound-output-device-chooser/
* https://extensions.gnome.org/extension/3499/application-volume-mixer/
* https://extensions.gnome.org/extension/7/removable-drive-menu/
* https://extensions.gnome.org/extension/758/no-workspace-switcher-popup/
* https://extensions.gnome.org/extension/1482/remove-audio-device-selection-dialog/
* https://extensions.gnome.org/extension/1401/bluetooth-quick-connect/

If you include Material Shell then open its settings (you can get it them through Gnome Tweaks) and change then to your liking (though hopefully Gnome saves that stuff from place to place)

--------------------------------------------------------------------------------------------

For Firefox, I use AutoKey to send Ctrl + PgUp when I hit Alt + Right and 
to send Ctrl + PgDown when I hit Alt + Left. I use the Shortkeys (Custom 
Keyboard Shortcuts) extension to stop tabs from going back or forward 
in their history when I hit Alt + Left or Alt + Plus. To do this, set 
alt+right to Do nothing (disable browser shortct) and alt+left to the same 
thing. I have also set ui.key.menuAccessKeyFocuses to false in the 
about:config menu to stop the Menu Bar Toolbar from briefly appearing every
time I hit the Alt key. I have also unchecked Title Bar and both ToolBars in
the Customize page.

--------------------------------------------------------------------------------------------

## Mathematica
Assuming MMA is installed
Here are some packages to consider installing
* Rubi
* SETools
* SciDraw
* MaTeX

Typically packages are installed to either ~/.Mathematica/Applications or ~/.Mathematica/Paclets/Repository
Ok now lets get my config files set up
```
cd ~/.Mathematica/Kernel
wget https://raw.githubusercontent.com/tannerlegvold/dotfiles/main/init.m
```
This directory may not exist at first, we'll mkdir it just to be sure
```
mkdir ~/.Mathematica/SystemFiles/FrontEnd/TextResources/X
cd ~/.Mathematica/SystemFiles/FrontEnd/TextResources/X
wget https://raw.githubusercontent.com/tannerlegvold/dotfiles/main/KeyEventTranslations.tr
wget https://raw.githubusercontent.com/tannerlegvold/dotfiles/main/MenuSetup.tr
```
And I think we're all good to go

--------------------------------------------------------------------------------------------

## Jupyter
... how to install Jupyter ...
Now that Jupyter is installed, lets make a nice icon for it in the Activities view. First we must create a .desktop file in the right place
```
cd ~/.local/share/applications
touch jupyter.desktop
```
Now enter jupyter.desktop and add this text
```
[Desktop Entry]
Name=Jupyter Lab
Terminal=false
Comment=Start Jupyter Lab
Exec=/home/tanner/.local/bin/startJupyter
Icon=jupyter-lab
Type=Application
Categories=Development;
StartupNotify=true
StartupWMClass=jupyter-lab
```
You'll notice we referenced a script called `startJupyter` in there which we haven't made yet, lets make it
```
cd ~/.local/bin
touch startJupyter
```
Now enter `startJupyter` and add this text
```
#!/bin/bash
# Checks if jupyter (server) is running, if it isn't, start it. Uses 
# setsid --fork fo ensure the process isn't killed when the script 
# finishes
pgrep jupyter || setsid --fork ~/.anaconda3/bin/jupyter lab --no-browser &> /dev/null

# Wait 1 second (otherwise the GUI can't find the server)
sleep 2

# Open the GUI
# Perhaps use --kiosk for kiosk mode, whatever that is
# For some reason the google-chrome command automatically forks itself
# thus it doesn't need setsid --fork to work
google-chrome --app=http://localhost:8888
```
And don't forget to set permissions so it is executable
```
chmod +x startJupyter
```
`startJupyter` can also be called from the terminal if you want to start Jupyter from there.
We also reference an icon called jupyter-lab that we haven't downloaded yet, all we must do is download it to the correct directory and the OS will take care of the rest
```
cd /usr/share/icons
sudo wget https://raw.githubusercontent.com/tannerlegvold/dotfiles/main/jupyter-lab.svg
```
You can also put it in `~/.local/share/icons` if you want a user local install. I have made some changes to my jupyter configuration files. I made changes to: 
`~/.jupyter/lab/user-settings/@jupyterlab/shortcuts-extension/shortcuts.jupyterlab-settings` by setting it to this code
```
{
    "shortcuts": [
        {
            "command": "application:activate-next-tab",
            "keys": [
                "Alt ArrowRight"
            ],
            "selector": "body"
        },
        {
            "command": "application:activate-previous-tab",
            "keys": [
                "Alt ArrowLeft"
            ],
            "selector": "body"
        }
    ]
}
```
To get the lsp to work I downloaded and built from source https://github.com/haskell/haskell-language-server. Then I installed the jupyter-lsp extension using their instructions on their github page https://github.com/krassowski/jupyterlab-lsp. Then I followed the steps at https://jupyterlab-lsp.readthedocs.io/en/latest/Configuring.html to get the haskell-language-server working with jupyterlab. Specifically I made this file `~/.jupyter/jupyter_server_config.json` and put this in it (you could probably put other stuff too)
```
{
    "LanguageServerManager": {
        "language_servers": {
            "haskell-language-server": {
                "version": 2,
                "argv": ["/home/tanner/.local/bin/haskell-language-server-wrapper", "--lsp"],
                "languages": ["haskell"],
                "mime_types": ["text/x-haskell", "text/haskell"]
            }
        }
    }
}
```
to get it up and running. And now hopefully I will configure the settings for the server in 
`~/.jupyter/lab/user-settings/@krassowski/jupyterlab-lsp/plugin.jupyterlab-settings`
and get something half decent working (cause right now it kinda sucks)






