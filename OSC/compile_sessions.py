# compile all sessions
#
# Axel Roest

import py_compile
# import compileall
import re

# py_compile.compile("OSC.py")
py_compile.compile("OSCClient.py")
py_compile.compile("osc_test.py")
# compileall.compile_dir(".", rx=re.compile(r'/\.svn'), force=0)