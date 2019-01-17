vim-hsftp
=========

Vim: Upload and download files through scp with passwordless public key

Usage:
------
First, you have to create ssh public key and copy the id to remote computer.

    ssh-keygen -t rsa -b 4096, LEAVE THE PASSWORD BLANK. JUST KLIK ENTER
    ssh-copy-id user@host
    
Then, you have to create a config file called .hsftp in your project directory.

When uploading/downloading hsftp searches backwards for a config file so if the edited file is e.g. `/test/dir/file.txt` and the config file is `/test/.hsftp` it will upload/download as `dir/file.txt`

The config file should be structured like this (amount of spaces doesn't matter):

    host   1.1.1.1
    user   username
    pass   test123
    port   22
    remote /var/www/
    confirm_download 0
    confirm_upload 0

### Commands
    :Hdownload
Downloads current file from remote path

    :Hupload
Uploads current file to remote path

    :Hupdir
Uploads current folder of current buffer to remote path


### Mappings
    <leader>hsd
Calls :Hdownload

    <leader>hsu
Calls :Hupload

    <leader>hsf
Calls :Hupdir
