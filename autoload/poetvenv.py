"""Enable or disable a virtual environment."""

# pylint:disable=global-statement,exec-used,bare-except

import shutil
import sys
from pathlib import Path

PREV_SYSPATH = None


def activate(venv_dir):
    """Activate virtual environment in venv_dir."""
    global PREV_SYSPATH
    PREV_SYSPATH = list(sys.path)

    activator_dir = Path(venv_dir) / ('Scripts' if sys.platform == 'win32' else 'bin')
    activator_file = 'activate_this.py'
    activator = activator_dir / activator_file
    if not activator.exists():
        shutil.copy((Path(__file__).resolve().parent / activator_file).as_posix(), activator_dir.as_posix())
    with open(str(activator)) as f:
        exec(f.read(), {'__file__': str(activator)})


def deactivate():
    """Deactivate virtual environment."""
    global PREV_SYSPATH
    try:
        sys.path[:] = PREV_SYSPATH  # type: ignore
        PREV_SYSPATH = None
    except:  # noqa
        pass
