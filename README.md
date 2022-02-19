# dotfiles
This repo will contain `mysetup` a file with instructions on how to take stock Ubuntu with Gnome and install all the necessary programs and configure all the necessary things to get the major components of my preferred computer setup up and running. As such this repo will also contain (hopefully all) files (mostly my dotfiles, hence the name) necessary for the configuration of my system (hopefully I keep them up to date). 

## General Comments
I want to set up a Kettelstassen, a large database of all my notes and files (organized a certain way). I would want to have great infrastructure for it since thats a bit of a big undertaking. I would want updates over time to be stored somehow (like git actually). I would want it stored securely in the cloud or on a drive and for my system to have a local copy (gotta figure out how to do this automagically), probably gotta use Google Drive or Github, Github has versioning but Google Drive has more storage and fewer restraints. Probably gonna try to organize my system using a database file of some sort and then have some sort of automatic setup for Google Drive syncing. On a related subject I found this site https://dotfiles.github.io/. It talks about all the different ways to manage dotfiles/system configuration. A favorite is naturally Home Manager with Nix. This will be an essential part of my Kettelstassen, though I have no clue how. Perhaps I should start making a list of things I will include in my KettelStassen, for starters: ~/idea, ~/Desktop/langideas, the several random idea files in my Google Drive, all my browser Favorites/Bookmarks, all my Youtube subscriptions, of course, all important files on my file system, my config files including mysetup. Maybe consider Obsidian for the Kettelstassen (theres a free version) https://obsidian.md/. I installed it like this
```
sudo apt install flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub md.obsidian.Obsidian
```
It is then run using `flatpak run md.obsidian.Obsidian` I should make an icon and a command line launch script called 'obsidian' for this. I should probably use the AppImage on their site since using flatpak doesn't make this any easier. I have much more customized now. I will include this at a later date.

Another outstanding issue is getting images to work with Ranger, I think I will try Kitty for this. This brings up a problem, Kitty doesn't work with my current Bash setup, if Kitty does turn out to handle images well in Wayland then I should look into bash-it, a different Bash configuration framework that may work better with Kitty than oh-my-bash. Also, look in Kitty's config files, they may have something (like something capturing certain key combos) that explains why Kitty doesn't work with ble.sh and can be disabled.

See this for how to remove snap I haven't done it though, may be dangerous https://askubuntu.com/questions/1035915/how-to-remove-snap-store-from-ubuntu/1114686#1114686.

For ranger consider getting it to use `bat` as a pager, and perhaps some terminal markdown viewer as the pager for markdown files.

--------------------------------------------------------------------------------------------

## General Knowledge
* The `$EDITOR` environment variable should be set to your preferred text editor, thus something like `$EDITOR=micro` should be in your bash config
* A user should put executables in `/usr/local/bin` if they are intended to be used by all users of the system, and in `~/.local/bin` if they are only intended to be used by themselves (to be clear though, this is not where package manager programs like `apt` put their stuff)
* Similarly, `/usr/share/fonts` is the system wide place to put fonts, `~/.local/share/fonts` is the user local one
* Put `.desktop` files in `~/.local/share/applications`, these are files Gnome uses to make new items in the Applications menu
* Many (most) programs these days put their config files in a directory of `~/.config`
* On Linux, its not uncommon for rarely used directories such as `~/.local/share/fonts` to not exist on a new system, if so you'll have to make it yourself (not hard, just use `mkdir`); this may seem weird at first, but you get used to it
* If your not sure whether to put things in their system wide or user local locations on a system only you use (like a laptop), then put them in the system wide, on the off chance you make another user or someone `ssh`s into your laptop in the future, you won't need to deal with a bunch of "this thing works on my normal user, but not for this user".
* XDG
  * Its a Linux standard many desktop environments and programs conform to for where config files should go, where the "downloads" folder should be, etc. This [Arch wiki page](https://wiki.archlinux.org/title/XDG_user_directories) has good info (though it may be outdated)
  * Change XDG's "downloads" directory to `~/down`: `xdg-user-dirs-update --set DOWNLOAD ~/down`
  * According to the man page you can also set `DESKTOP`, `TEMPLATES`, `PUBLICSHARE`, `DOCUMENTS`, `MUSIC`, `PICTURES`, and `VIDEOS`
  * Query a setting's current value: `xdg-user-dir DESKTOP`
  * If one of the settings' directories doesn't exist (eg if you deleted it) then that setting defaults to the home directory
* When you open a terminal, it sources (executes the code in) an "initialization file" for your convienence, thus you can put commonly used aliases, functions etc in there and they will be availiable to you every time you start up a terminal. There are both global "init" files and user local ones, further there are two "kinds" of ways to run a shell, login and interactive, each have their own init files
  * `/etc/profile` is the system-wide initialization file, executed for login shells
  * `~/.bash_profile` is the personal initialization file, executed for login shells
  * `~/.bashrc` is the individual per-interactive-shell startup file
  * `~/.bash_logout` is the individual login shell cleanup file, executed when a login shell exits
* Ubuntu uses `.profile` instead of `.bash_profile`, this confuses older programs that expect `.bash_profile` to exist. See [General](#general) for the solution.

--------------------------------------------------------------------------------------------

## General
This looks like something for Obsidian
```
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub md.obsidian.Obsidian
```
This is the easiest way to get Discord
```
sudo snap install discord
```
Its bad to be restricted to the standard Canonical repositories, lets add universe
```
sudo add-apt-repository universe
```
And lets install some basic stuff right now
```
sudo apt install curl python3-pip npm
```
I use a program called `fd` to search the file system, its a more modern `find`. To install
```
sudo apt install fd-find
ln -s $(which fdfind) ~/.local/bin/fd
```
its complicated to install because the name `fd` must be symlinked to `fdfind` (the acutal name of the executable) because `fd` is taken by another program in the Ubuntu repositories. Viddy is a better `watch`
```
wget -O viddy.tar.gz https://github.com/sachaos/viddy/releases/download/v0.3.3/viddy_0.3.3_Linux_x86_64.tar.gz
tar xvf viddy.tar.gz
sudo mv viddy /usr/local/bin
rm viddy.tar.gz
```
Historically, Unix has used `.bash_profile` for "login shells" and ".bashrc" for "interactive shells". These days, Ubuntu switched to `.profile` instead of `.bash_profile`, of course this means older programs get confused by the lack of a `.bash_profile`. The solution is simple
```
ln -s ~/.profile ~/.bash_profile
```
Execute that in the home directory, thats where all these files live.

--------------------------------------------------------------------------------------------

## Fixing the Home Directory
I like to install source to a software directory in the home directory, so lets make one
```
cd ~
mkdir software
```
Remove the directories I don't use
```
rmdir Videos Pictures Documents Music Public Templates
```
I think the names `Downloads` and `Desktop` are too long, lets switch them to `down` and `desk` (this part is still tentative)
```
mv Downloads down
mv Desktop desk
```
Tell xdg to change the default downloads and desktop locations
```
xdg-user-dirs-update --set DOWNLOAD ~/down
xdg-user-dirs-update --set DESKTOP ~/desk
```
Chrome does not respect the `XDG` directories. Set its download location to `/home/tanner/down` manually by navigating to `chrome://settings/downloads` and using the GUI (do this for both profiles). If you haven't downloaded Chrome yet, do this later, in the [Chrome](#chrome) section

--------------------------------------------------------------------------------------------

## Micro
To install micro, we'll use this script from their website
```
curl https://getmic.ro | bash
```
This sets the `$EDITOR` variable (nice, now we don't have to) and places the exectuable in the current directory, lets move it to `/usr/local/bin`
```
sudo mv micro /usr/local/bin
```
To make copy/paste interact with the rest of the system we must also install xclip
```
sudo apt install xclip
```
Micro's config files are in `~/.config/micro`. Go there, open `settings.json`
```
cd ~/.config/micro
micro settings.json
```
and set its contents to
```
{
    "*.hs": {
        "tabmovement": true,
        "tabstospaces": true
    },
    "*.md": {
        "softwrap": true,
        "wordwrap": true
    },
    "*.txt": {
        "softwrap": true,
        "wordwrap": true
    }
}
```

--------------------------------------------------------------------------------------------

## Jet
Theres a neat little JSON editor called [Jet](https://github.com/ChrisPenner/jet). I have [my own version](https://github.com/tannerlegvold/jet) where I've changed the navigation to use arrow keys instead of the original's hjkl. To install
```
cd ~/software
git clone https://github.com/tannerlegvold/jet.git
cd jet
stack build --copy-bins # this takes a while the first time
```
See the [Haskell](#haskell) section below for how to install `stack`.

I should update Ranger to use this for JSON files.

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

## Htop
I have a customized `htoprc` file. It changes `htop`'s layout, colorscheme, and update delay (default is every 1.5 seconds, mine is every 0.5 seconds). All we must do is download it to the right location
```
cd ~/.config/htop
wget https://raw.githubusercontent.com/tannerlegvold/dotfiles/main/htoprc
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

Now lets add icons to Gnome's Application menu so we can open Chrome instances in particular profiles
```
cd ~/.local/share/applications
touch chrome-tanner-personal.desktop
touch chrome-tanner-rice.desktop
chmod +x chrome-tanner-personal.desktop
chmod +x chrome-tanner-rice.desktop
```
Now enter `chrome-tanner-personal.desktop` and give it this text
```
[Desktop Entry]
Name=Chrome Personal
Terminal=false
Comment=Open Chrome in the Tanner (Personal) profile
Exec=/usr/bin/google-chrome-stable --new-window --profile-directory=Default
Type=Application
Categories=Development;
StartupNotify=true
```
Now enter `chrome-tanner-rice.desktop` and give it this text
```
[Desktop Entry]
Name=Chrome Rice
Terminal=false
Comment=Open Chrome in the Tanner (Rice) profile
Exec=/usr/bin/google-chrome-stable --new-window --profile-directory="Profile 1"
Type=Application
Categories=Development;
StartupNotify=true
```
Reload Gnome (warning if your in Wayland this will close all applications) and the icons should be in the Applications menu with the default icon (maybe I'll give them special icons in the future). 

If you log in to one of your Google Accounts then all your extensions should be there automatically. Don't forget to set Chrome as the default web browser by opening Settings and going to Default Applications and setting Web to be Google Chrome.

My perferred download directory is `~/down`. To set Chrome to download to there, navigate to `chrome://settings/downloads` and use the GUI. Do this for both Chrome profiles (this may only be necessary on new profiles, I don't know what Chrome does for existing profiles getting used on new machines).

--------------------------------------------------------------------------------------------

## AutoKey
To install AutoKey we will wget the .deb files from one of the recent releases (you can look for more recent releases here: https://github.com/autokey/autokey/releases)
```
wget https://github.com/autokey/autokey/releases/download/v0.95.10/autokey-common_0.95.10-0_all.deb
wget https://github.com/autokey/autokey/releases/download/v0.95.10/autokey-gtk_0.95.10-0_all.deb
```
And now we will install them
```
VERSION="0.95.10-0"    # substitute with the version you downloaded
sudo dpkg --install autokey-common_${VERSION}_all.deb autokey-gtk_${VERSION}_all.deb
sudo apt --fix-broken install
```
Now we can run AutoKey from the Application menu. To get my scripts on the system do the below
```
cd ~/.config/autokey/data/My Phrases

wget https://raw.githubusercontent.com/tannerlegvold/dotfiles/main/AutoKeyScripts/.chromeTabLeft.json
wget https://raw.githubusercontent.com/tannerlegvold/dotfiles/main/AutoKeyScripts/.chromeTabRight.json
wget https://raw.githubusercontent.com/tannerlegvold/dotfiles/main/AutoKeyScripts/.firefoxTabLeft.json
wget https://raw.githubusercontent.com/tannerlegvold/dotfiles/main/AutoKeyScripts/.firefoxTabRight.json

wget https://raw.githubusercontent.com/tannerlegvold/dotfiles/main/AutoKeyScripts/chromeTabLeft.txt
wget https://raw.githubusercontent.com/tannerlegvold/dotfiles/main/AutoKeyScripts/chromeTabRight.txt
wget https://raw.githubusercontent.com/tannerlegvold/dotfiles/main/AutoKeyScripts/firefoxTabLeft.txt
wget https://raw.githubusercontent.com/tannerlegvold/dotfiles/main/AutoKeyScripts/firefoxTabRight.txt
```
This is untested however (hopefully it works).

--------------------------------------------------------------------------------------------

## WebCatalog
I use this to convert websites to desktop apps (an alternative, accessable through the command line is https://github.com/nativefier/nativefier). We can download the app from the website (https://webcatalog.io/webcatalog/) or directly from the Github page, for the script we'll use the latter (be careful of naming, it can change slightly depending on where the download came from), then we'll give it execution permissions and put it in a directory on the path 
```
cd
wget https://github.com/webcatalog/webcatalog-app/releases/download/v37.0.0/webcatalog-37.0.0.AppImage
chmod +x webcatalog-37.0.0.AppImage
sudo mv webcatalog-37.0.0.AppImage /usr/local/bin
```
Now we'll make a .desktop file for it
```
cd ~/.local/share/applications
touch webcatalog.desktop
```
Now enter `webcatalog.desktop` and give it this text
```
[Desktop Entry]
Name=WebCatalog
Terminal=false
Comment=WebCatalog
Exec=/usr/bin/webcatalog-37.0.0.AppImage
Type=Application
Categories=Development;
StartupNotify=true
```
Reload Gnome (warning on Wayland this requires logging out which will close all applications without saving them). Now open WebCatalog from the Gnome Applications menu and navigate the GUI to install the apps you want. Right now I use it for
* GroupMe
Thats it: I won't bother to give it an icon right now. Some alternatives are Linux Mint's [Web App Manager](https://github.com/linuxmint/webapp-manager) or opening the websites in a separate Chrome window (what we did for JupyterLab). 

--------------------------------------------------------------------------------------------

## Gnome
First install Gnome Tweaks if it isn't already
```
sudo apt install gnome-tweaks
```
Now open it and click on Extensions, now enable extensions by clicking the slider in the upper right hand corner. Now we can start using extensions.
Assuming your Chrome is logged into your Google Account you should already have the GNOME Shell Integration extension (if not for whatever reason, you can get it [here](https://chrome.google.com/webstore/detail/gnome-shell-integration/gphhapmejobijbbhgpjhcjognlahblep) and be able to access my extension list [here](https://extensions.gnome.org/local/) to turn on whatever you want. If not, heres a list of my preferred extensions, simply go to the URL and click on the slider bar to install them
* [Material Shell](https://extensions.gnome.org/extension/3357/material-shell/)
* [Caffeine](https://extensions.gnome.org/extension/517/caffeine/)
* [Shell Restarter](https://extensions.gnome.org/extension/4075/shell-restarter/)
* [Sound Output Device Chooser](https://extensions.gnome.org/extension/906/sound-output-device-chooser/)
* [Application Volume Mixer](https://extensions.gnome.org/extension/3499/application-volume-mixer/)
* [Removable Drive Menu](https://extensions.gnome.org/extension/7/removable-drive-menu/)
* [No Workspace Switcher Popup](https://extensions.gnome.org/extension/758/no-workspace-switcher-popup/)
* [Remove Audio Device Selection Dialog](https://extensions.gnome.org/extension/1482/remove-audio-device-selection-dialog/)
* [Bluetooth Quick Connect](https://extensions.gnome.org/extension/1401/bluetooth-quick-connect/)

If you include Material Shell then open its settings (you can get it them through Gnome Tweaks) and change then to your liking (though hopefully Gnome saves that stuff from place to place)

--------------------------------------------------------------------------------------------

## Arduino
Following [this](https://ubuntu.com/tutorials/install-the-arduino-ide#1-overview). Using the download links at the time of writing (Dec. 2021) (if they've expired just follow the tutorial and maybe update this document)
```
cd ~/software
wget https://downloads.arduino.cc/arduino-1.8.16-linux64.tar.xz
tar xvf arduino-1.8.16-linux64.tar.xz
cd arduino-1.8.16/
sudo ./install.sh
cd ..
rm arduino-1.8.16-linux64.tar.xz
sudo usermod -a -G dialout tanner # don't skip, this line is neccessary
```
Then I had to restart, not just relog, otherwise the Arduino IDE didn't notice I was added to the `dialout` group. Note for the `usermod` line, the group you must be added to can change vary with distro, on Debian its `dialout`, on Arch supposedly its `uucp`.

To set the default location sketchbooks are saved to. Make the directory
```
cd ~/desk
mkdir arduino
```
Open the Arduino IDE, go to File -> Preferences, the first option is "Sketchbook location", change it to `/home/tanner/desk/arduino`. This can be done programmatically by opening `~/.arduino15/preferences.txt` and editing the `sketchbook.path` field (for me right now this on line 91) to be `/home/tanner/desk/arduino`. Its probably best to not do this while the IDE is running.

--------------------------------------------------------------------------------------------

## Mathematica
Assuming MMA is installed
Here are some packages to consider installing
* Rubi
* SETools
* SciDraw
* MaTeX
* GTPack
* [MaXrd](https://github.com/Stianpr20/MaXrd)

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

## Docker
I use Docker for KLayout since it only runs well on earlier Ubuntu versions.
```
sudo apt install docker.io
sudo systemctl start docker
sudo systemctl enable docker
```
Use `sudo docker run hello-world` to check for a proper installation. To not need to put `sudo` in front of every `docker` call add yourself to the `docker` group
```
sudo usermod -aG docker tanner
```
now log out and in for this to take effect (don't call `su - tanner` this confuses `x11docker` since it changes the environment (you may notice the bash history changes), in particular `$DISPLAY` will no longer have a value, it will also take two Ctrl + d's to close the terminal).

To deal with GUI applications I use `x11docker` (https://github.com/mviereck/x11docker/)
```
curl -fsSL https://raw.githubusercontent.com/mviereck/x11docker/master/x11docker | sudo bash -s -- --update
sudo docker pull x11docker/xserver
```
To test this install you can use some of the `x11docker` project's premade containers
```
sudo docker pull x11docker/xfce
sudo x11docker x11docker/xfce xfce-terminal
```
After hunting on https://hub.docker.com/_/ubuntu?tab=tags&page=2 I found a docker image called `ubuntu:16.04`, then I wrote a barebones Dockerfile that downloads the most recent version of KLayout for Ubuntu 16.04 (which I found at https://www.klayout.de/build.html) and installs it (after installing the dependencies apt complains about if you don't), lets make it
```
docker pull ubuntu:16:04 # doesn't hurt to do this step now
cd ~/software
mkdir docker-klayout
touch Dockerfile
```
Now open the Dockerfile text file and give it the following
```
FROM ubuntu:16.04
RUN apt-get update
RUN apt-get install -y x11-apps xterm wget
RUN wget https://www.klayout.org/downloads/Ubuntu-16/klayout_0.27.8-1_amd64.deb
RUN apt-get install -y libqt4-designer libqt4-xml libqt4-sql libqt4-network libqtcore4 libqtgui4 libruby2.3 python3 libpython3.5
RUN dpkg -i /klayout_0.27.8-1_amd64.deb
```
Now exit the file and run
```
docker build -t docker-klayout .
```
You can now start and enter this docker container through the terminal with `docker run -it docker-klayout` or run KLayout in all its graphical glory (the point of all this) with
```
x11docker docker-klayout klayout
```
Docker images by default don't save state, its best to use `x11docker`'s `--share` option so that KLayout can affect files in our filesystem
```
x11docker --share ~/down docker-klayout klayout
```
Now in KLayout in `/home.host/down` we should see any files we put in `~/down`, similarly this is how we access anything we make in KLayout, this is now a fully functioning KLayout setup.

--------------------------------------------------------------------------------------------

## Virtual Machines
Start installing a Ubuntu `.iso` cause it takes a while. Navigate to https://ubuntu.com/download/desktop and click download. Now get Virtual Box
```
sudo apt install virtualbox
```
Also, make a directory to put the vms and related items in
```
cd ~/desk
mkdir vms
```
When VirtualBox is installed open it. Go to File -> Preferences -> General and then change Default Machine Folder to `/home/tanner/desk/vms`. Once the `.iso` is downloaded (assuming it has been downloaded to the `~/down` directory)
```
mv ~/down/ubuntu-20.04.3-desktop-amd64.iso ~/desk/vms
```
Now in Virtual Box 
1. click New
2. enter UbuntuTestingVM as the Name, verify Machine Folder is `/home/tanner/desk/vms`, Type is Linux, and Version is Ubuntu (64-bit), then click Next
3. for Memory Size, use default, click Next
4. for Hard Disk, it should default to "Create a virtual hard disk now", click Create
5. for Hard Disk file type, it should default to VDI (VirtualBox Disk Image), click Next
6. for Storage on physical hard disk, it should default to Dynamically allocated, click Next
7. for File location and size, use the default file location, use the slider to change the size to 25 GB (or whatever you want), click Create
8. Now with UbuntuTestingVM selected on the left, click Settings, click Storage, in the Storage Devices area click Empty, now in the Attributes area, next to the combobox for Optical Drive, click the little blue disk icon, navigate to the `.iso` in `~/desk/vms` and double click it, the part that used to say Empty should now say `ubuntu-20.04.3-desktop-amd64.iso`, now click Ok
9. Now click Start, and give the VM a minute or two to start up and bring up the Install window. Once the Install window looks done loading, click Try Ubuntu, and you'll have an up and running Ubuntu Live VM.

The `.iso` we downloaded was a "Live" distribution, that means its a minimal version of Ubuntu with basic utilities and a Install program which can do a full blown Ubuntu install at the press of a button. The idea is to play around in Ubuntu Live, and if you like it, run the Install program to install permanently. Ubuntu Live won't save any thing permanently, so if we download programs and edit files, after a restart all those actions will be gone. This makes it ideal for testing. So I never run the Install program. Actually VirtualBox will by default, on closing the VM, save its state, kinda like pausing it. So if you want to properly reset the VM, you must hit Discard in VirtualBox if you ever save its state.

--------------------------------------------------------------------------------------------

## Software and libraries
### Haskell
First run
```
sudo apt install haskell-platform
```
this installs GHC and GHCi (along with GHC's profiler and debugger), Cabal, and a couple other tools (see https://en.wikipedia.org/wiki/Haskell_Platform). By default, Cabal installs user local things to `~/.cabal/bin` (and I'm not sure Cabal even can install thing globally, perhaps by design), so make sure this is on the PATH (in my `.bashrc` it is).

Lets also get Stack (I don't make new Haskell projects often but it is necessary to install stuff from Stackage (Hackage?) sometimes)
```
curl -sSL https://get.haskellstack.org/ | sh
```
Heres a list of (hopefully all) the libraries I have used in my projects, download what looks relevant
HLint is a Haskell source linter that is used commonly
```
cabal install hlint
```
Reanimate (https://github.com/reanimate/reanimate)
These give Reanimate additional capabilites
```
sudo apt install ffmpeg potrace povray inkscape imagemagick
```
Povray also requires a particular symbolic link to exist in the home directory
```
cd
sudo ln -s /etc/povray .povray
```
The Github page also mentions blender, which I won't bother with, and Latex which will be dealt with elsewhere in this document.

This downloads a project that has Reanimate listed as one of it dependencies
```
stack new animate github:reanimate/plain
```
Reanimate and its dependencies will be downloaded if we enter the project and do something that would require a build to occur, like directly building the project or starting a repl (which requires building it I think), on my current system this takes like ten minutes
```
cd animate
cabal repl
```
This article shows how to get a good dev setup for Haskell using VSCode https://medium.com/@dogwith1eye/setting-up-haskell-in-vs-code-with-stack-and-the-ide-engine-81d49eda3ecf

### LaTeX

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
chmod +x startJupyter
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







