"""Activate virtualenv for current interpreter.

Use exec(open(this_file).read(), {'__file__': this_file}).

This can be used when you must use an existing Python interpreter, not the virtualenv
bin/python.
"""
import os
import site
import sys

try:
    __file__
except NameError:
    raise AssertionError(
        "You must use exec(open(this_file).read(), {'__file__': this_file}))"
    )

# prepend bin to PATH (this file is inside the bin directory)
bin_dir = os.path.dirname(os.path.abspath(__file__))
os.environ["PATH"] = os.pathsep.join(
    [bin_dir] + os.environ.get("PATH", "").split(os.pathsep)
)

base = os.path.dirname(bin_dir)

# virtual env is right above bin directory
os.environ["VIRTUAL_ENV"] = base

# add the virtual environments site-package to the host python import mechanism
if sys.platform == "win32":
    site_packages = os.path.join(base, "Lib", "site-packages")
else:
    site_packages = os.path.join(
        base, "lib", "python{}.{}".format(*sys.version_info), "site-packages"
    )

prev = set(sys.path)
site.addsitedir(site_packages)
sys.real_prefix = sys.prefix  # type: ignore
sys.prefix = base

# Move the added items to the front of the path, in place
new = list(sys.path)
sys.path[:] = [i for i in new if i not in prev] + [i for i in new if i in prev]
