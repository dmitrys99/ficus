
val msg_ficus_root_not_found = f"Ficus root directory is not found.
Please, add the directory 'lib' containing Builtins.fx to
'FICUS_PATH' environment variable or make sure that either
1. 'ficus' executable is put in a directory <ficus_root>/bin
and there are <ficus_root>/runtime and <ficus_root>/lib.
2. or 'ficus' executable is in (/usr|/usr/local|/opt|...)/bin and
   there are (/usr|...)/lib/ficus-{__ficus_major__}.{__ficus_minor__}/{{runtime, lib}}"
