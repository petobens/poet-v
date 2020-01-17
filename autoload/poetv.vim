python3 << EOF
import vim
curr_dir = vim.eval('expand("<sfile>:p:h")')
if curr_dir not in sys.path:
    sys.path.append(curr_dir)
import poetvenv
EOF

function! poetv#deactivate() abort
    python3 poetvenv.deactivate()

    if exists('s:prev_path')
        let $PATH = s:prev_path
        unlet! s:prev_path
    endif
    unlet $VIRTUAL_ENV
    unlet! g:poetv_name

    if exists(':JediUseEnvironment')
        call s:jedi_venv('')
    endif

    if exists('*airline#extensions#poetv#update')
        call airline#extensions#poetv#update()
    endif
endfunction

function! poetv#activate() abort
    " Get current file info
    let l:save_pwd = getcwd()
    silent! lcd %:p:h
    let curr_buffer_name = bufname('%')

    " Check if a venv is active and matches the current one
    let poetv_dir = getbufvar(curr_buffer_name, 'poetv_dir', 'unknown')
    if len($VIRTUAL_ENV) > 0
        if poetv_dir ==# $VIRTUAL_ENV
            execute 'lcd ' . save_pwd
            return
        else
            call poetv#deactivate()
        endif
    endif

    " Now try to get the venv dir (if it exists)
    if poetv_dir ==# 'unknown'
        for binary in g:poetv_executables
            let get_venv_cmd = s:get_venv_cmd(binary)
            let poetv_out = trim(system(get_venv_cmd))
            if v:shell_error == 0 && !empty(poetv_out)
                let poetv_out = matchstr(poetv_out, '\S*')
                call setbufvar(curr_buffer_name, 'poetv_dir', poetv_out)
                break
            else
                call setbufvar(curr_buffer_name, 'poetv_dir', 'none')
            endif
        endfor
    endif
    let venv_dir =  getbufvar(curr_buffer_name, 'poetv_dir')
    if venv_dir ==# 'none'
        execute 'lcd ' . save_pwd
        return
    endif

    " Actually activate the environment
    let s:prev_path = $PATH
    python3 poetvenv.activate(vim.eval('l:venv_dir'))
    let $PATH = venv_dir . (has('win32')? '/Scripts': '/bin') . ':'  . $PATH
    let $VIRTUAL_ENV = venv_dir
    let g:poetv_name = fnamemodify(venv_dir, ':t')

    if exists(':JediUseEnvironment')
        call s:jedi_venv(venv_dir)
    endif

    if exists('*airline#extensions#poetv#update')
        call airline#extensions#poetv#update()
    endif
    execute 'lcd ' . save_pwd
endfunction

function! poetv#statusline() abort
    if exists('g:poetv_name')
        return g:poetv_name[:20] . ' ' . g:poetv_statusline_symbol
    else
        return ''
    endif
endfunction


" Helpers
function! s:get_venv_cmd(executable)
    if a:executable ==# 'poetry'
        let venv_cmd = 'poetry env list --full-path'
    elseif a:executable ==# 'pipenv'
        let venv_cmd = 'pipenv --venv'
    else
       echoerr 'Valid options are `poetry` and `pipenv`'
    endif
    return venv_cmd
endfunction

function! s:jedi_venv(venv) abort
    if a:venv ==# ''
        let venv_python_path = g:poetv_global_pypath
    else
        let venv_python_path = a:venv . '/bin/python'
    endif
    if empty(g:jedi#use_environment) || g:jedi#use_environment !=# venv_python_path
        silent! execute 'JediUseEnvironment ' . venv_python_path
    endif
endfunction
