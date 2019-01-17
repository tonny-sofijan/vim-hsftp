" Title: hsftp
" Description: Upload and download files through sftp
" Usage: :Hupload and :Hdownload
"        By default mapped to
"        <leader>hsd (hsftp download) and
"        <leader>hsu (hsftp upload)
"        See README for more
" Github: https://github.com/hesselbom/vim-hsftp
" Author: Viktor Hesselbom (hesselbom.net)
" License: MIT
"
" Before you use this, you must use passwordless ssh public key
" command:
"   ssh-keygen -t rsa -b 4096 // DO NOT USE PASSWORD, LEFT IT BLANK
"   ssh-copy-id user@host 


function! H_GetConf()
  let conf = {}

  let l_configpath = expand('%:p:h')
  let l_configfile = l_configpath . '/.hsftp'
  let l_foundconfig = ''
  if filereadable(l_configfile)
    let l_foundconfig = l_configfile
  else
    while !filereadable(l_configfile)
      let slashindex = strridx(l_configpath, '/')
      if slashindex >= 0
        let l_configpath = l_configpath[0:slashindex]
        let l_configfile = l_configpath . '.hsftp'
        let l_configpath = l_configpath[0:slashindex-1]
        if filereadable(l_configfile)
          let l_foundconfig = l_configfile
          break
        endif
        if slashindex == 0 && !filereadable(l_configfile)
          break
        endif
      else
        break
      endif
    endwhile
  endif

  if strlen(l_foundconfig) > 0
    let options = readfile(l_foundconfig)
    for i in options
      let vname = substitute(i[0:stridx(i, ' ')], '^\s*\(.\{-}\)\s*$', '\1', '')
      let vvalue = escape(substitute(i[stridx(i, ' '):], '^\s*\(.\{-}\)\s*$', '\1', ''), "%#!")
      let conf[vname] = vvalue
    endfor

    let conf['local'] = fnamemodify(l_foundconfig, ':h:p') . '/'
    let conf['localpath'] = expand('%:p')
    let conf['remotepath'] = conf['remote'] . conf['localpath'][strlen(conf['local']):]
  endif

  return conf
endfunction

function! H_DownloadFile()
  let conf = H_GetConf()

  if has_key(conf, 'host')
    let cmd = printf('scp -P %s %s@%s:%s %s', conf['port'], conf['user'], conf['host'], conf['remotepath'], conf['localpath'])

    if conf['confirm_download'] == 1
      let choice = confirm('Download file?', "&Yes\n&No", 2)
      if choice != 1
        echo 'Canceled.'
        return
      endif
    endif

    execute '!' . cmd
  else
    echo 'Could not find .hsftp config file'
  endif
endfunction

function! H_UploadFile()
  let conf = H_GetConf()

  if has_key(conf, 'host')
    let cmd = printf('scp -P %s %s %s@%s:%s', conf['port'], conf['localpath'], conf['user'], conf['host'], conf['remotepath'])

    if conf['confirm_upload'] == 1
      let choice = confirm('Upload file?', "&Yes\n&No", 2)
      if choice != 1
        echo 'Canceled.'
        return
      endif
    endif

    execute '!' . cmd
  else
    echo 'Could not find .hsftp config file'
  endif
endfunction

function! H_UploadFolder()
  let conf = H_GetConf()

  if has_key(conf, 'host')
    let conf['localpath'] = expand('%:p:h')
    let conf['remotepath'] = conf['remote'] . conf['localpath'][strlen(conf['local']):]
    let cmd = printf('scp -r -P %s %s %s@%s:%s', conf['port'], conf['localpath'], conf['user'], conf['host'], conf['remotepath'])

    if conf['confirm_updir'] == 1
      let choice = confirm('Upload file?', "&Yes\n&No", 2)
      if choice != 1
        echo 'Canceled.'
        return
      endif
    endif

    echo cmd
    execute '!' . cmd
  else
    echo 'Could not find .hsftp config file'
  endif

endfunction

command! Hdownload call H_DownloadFile()
command! Hupload call H_UploadFile()
command! Hupdir  call H_UploadFolder()

nmap <leader>hsd :Hdownload<Esc>
nmap <leader>hsu :Hupload<Esc>
nmap <leader>hsf :Hupdir<Esc>
