" Setup
if exists('g:poetv_loaded')
    finish
endif
let g:poetv_loaded = 1

if !has('python3')
    echoerr 'Python3 is needed for poet-v to work.'
endif
" FIXME: Using `py3eval('sys.executable')` doesn't seem to work at this point
let g:poetv_global_pypath = trim(system('python -c "import sys; print(sys.executable)"'))

" Config
if !exists('g:poetv_executables')
    let g:poetv_executables = ['poetry', 'pipenv']
endif
for binary in g:poetv_executables
    if !executable(binary)
        echoerr binary . ' executable not found.'
    endif
endfor
if !exists('g:poetv_auto_activate')
    let g:poetv_auto_activate = 0
endif
if !exists('g:poetv_statusline_symbol')
    let g:poetv_statusline_symbol = ''
endif
if !exists('g:poetv_set_environment')
    let g:poetv_set_environment = 1
endif

" Commands
command! -bar PoetvActivate
    \ :call setbufvar(bufname('%'), 'poetv_dir', 'unknown') |
    \ :call poetv#activate()
command! -bar PoetvDeactivate :call poetv#deactivate()

" Auto activate
if g:poetv_auto_activate == 1
    augroup poetv_autocmd
        au!
        au WinEnter,BufWinEnter *.py
            \ if &previewwindow != 1 && expand('%:p') !~# "/\\.git/" |
                \ call poetv#activate() |
            \ endif
    augroup END
endif
