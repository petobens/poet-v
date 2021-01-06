python3 << EOF
import vim
curr_dir = vim.eval('expand("<sfile>:p:h")')
if curr_dir not in sys.path:
    sys.path.append(curr_dir)
import poetvenv
EOF

let s:venv_dir = $VIRTUAL_ENV

function! poetv#deactivate() abort
    python3 poetvenv.deactivate()

    if exists('s:prev_path')
        let $PATH = s:prev_path
        unlet! s:prev_path
        unlet $VIRTUAL_ENV
    endif
    unlet! g:poetv_name

    if exists(':JediChooseEnvironment')
        call s:jedi_venv('')
    endif

    if get(g:, 'deoplete#enable_at_startup', 0)
        call s:jedi_venv('', 1)
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
    if len(s:venv_dir) > 0
        if poetv_dir ==# s:venv_dir
            execute 'lcd ' . save_pwd
            return
        else
            call poetv#deactivate()
        endif
    endif

    " Now try to get the venv dir (if it exists)
    if poetv_dir ==# 'unknown'
        for binary in g:poetv_executables
            let virtual_env_cmd = s:get_venv_cmd(binary)
            let poetv_out_list = split(trim(system(virtual_env_cmd)), '\n')
            if v:shell_error == 0 && !empty(poetv_out_list)
                if len(poetv_out_list) == 1
                    let poetv_out = poetv_out_list[0]
                endif
                for i in poetv_out_list
                    " Only poetry allows for multiple envs and signals the active
                    " env with an `Activated` keyword
                    if match (i, '\S*\s\+\zs(Activated)\ze') != -1
                        let poetv_out =  i
                        break
                    endif
                endfor
                let poetv_out = substitute(poetv_out, ' (Activated)$', '', '')
                call setbufvar(curr_buffer_name, 'poetv_dir', poetv_out)
                break
            else
                call setbufvar(curr_buffer_name, 'poetv_dir', 'none')
            endif
        endfor
    endif
    let s:venv_dir =  getbufvar(curr_buffer_name, 'poetv_dir')
    if s:venv_dir ==# 'none'
        execute 'lcd ' . save_pwd
        return
    endif

    " Actually activate the environment
    python3 poetvenv.activate(vim.eval('s:venv_dir'))
    if g:poetv_set_environment
        let s:prev_path = $PATH
        let $PATH = s:venv_dir . (has('win32')? '/Scripts;': '/bin:') . $PATH
        let $VIRTUAL_ENV = s:venv_dir
    endif
    let g:poetv_name = fnamemodify(s:venv_dir, ':t')

    if exists(':JediChooseEnvironment')
        call s:jedi_venv(s:venv_dir)
    endif

    if get(g:, 'deoplete#enable_at_startup', 0)
        call s:jedi_venv(s:venv_dir, 1)
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
function! s:get_venv_cmd(executable) abort
    if a:executable ==# 'poetry'
        " TODO: Use `env info` (and remove list logic above) once the following
        " is fixed: https://github.com/python-poetry/poetry/issues/1870
        let venv_cmd = 'poetry env list --full-path'
    elseif a:executable ==# 'pipenv'
        let venv_cmd = 'pipenv --venv'
    else
       echoerr 'Valid options are `poetry` and `pipenv`'
    endif
    return venv_cmd
endfunction

function! s:jedi_venv(venv, ...) abort
    if a:venv ==# ''
        let venv_python_path = g:poetv_global_pypath
    else
        let venv_python_path = a:venv . (has('win32')? '/Scripts': '/bin') . '/python'
    endif

    let set_deoplete_jedi = get(a:, 1, 0)
    if !set_deoplete_jedi
        if empty(g:jedi#environment_path) || g:jedi#environment_path !=# venv_python_path
            let g:jedi#environment_path = venv_python_path
        endif
    else
        let deoplete_jedi_pypath = get(g:, 'deoplete#sources#jedi#python_path')
        if !deoplete_jedi_pypath || deoplete_jedi_pypath !=# venv_python_path
            let g:deoplete#sources#jedi#python_path = venv_python_path
        endif
    endif
endfunction
