# Poet-v

Poet-v is a vim/nvim plugin that detects and activates virtual environments in your python
[poetry](https://github.com/python-poetry/poetry) or
[pipenv](https://github.com/pypa/pipenv) project.

It is inspired (and closely resembles) both
[vim-virtualenv](https://github.com/jmcantrell/vim-virtualenv) and its pipenv spin-off
[vim-pipenv](https://github.com/PieterjanMontens/vim-pipenv). However it also adds the
ability to interact with virtual environments created by poetry and integrates nicely with
[jedi-vim](https://github.com/davidhalter/jedi-vim) (and
[deoplete-jedi](https://github.com/deoplete-plugins/deoplete-jedi)).

![](https://user-images.githubusercontent.com/2583971/71567884-35dd0580-2aa1-11ea-9109-829baa65392a.png)

## Installation

Install using your preferred package manager. For example using [dein.vim](https://github.com/Shougo/dein.vim):

```viml
call dein#add('petobens/poet-v')
```

## Usage (commands)

Poet-v provides just two commands:

- `PoetvActivate`: activates the corresponding poetry or pipenv venv (see below for
    details regarding order) and enforces jedi (and deoplete-jedi) to use it (if
    [jedi-vim](https://github.com/davidhalter/jedi-vim)/[deoplete-jedi](https://github.com/deoplete-plugins/deoplete-jedi)
    is installed).
- `PoetvDeactivate`: deactivates the current venv.

There is also a function, `poetv#statusline()`, that retrieves the current venv name. It
can be used for instance to display such information in the statusline (poet-v in fact
employs this to provide out of the box integration with
[vim-airline](https://github.com/vim-airline/vim-airline)).

## Configuration (options)

The following variables (along with their default values) control poet-v behaviour:

- `g:poetv_executables = ['poetry', 'pipenv']`
    - (Ordered) list of dependency managers to be used when attempting to activate a venv
    (or switch between existing ones).
- `g:poetv_auto_activate = 0`
    - If set to 1 poet-v will attempt to automatically activate a venv (or switch between
     existing ones) when entering a python window.
- `g:poetv_statusline_symbol = ''`
    - Symbol to be displayed after venv name returned by `poetv#statusline()` function.
- `g:poetv_set_environment = 1`
    - If set to 1 poet-v will set the `$VIRTUAL_ENV` and `$PATH` environment variables
      when a venv gets activated.
