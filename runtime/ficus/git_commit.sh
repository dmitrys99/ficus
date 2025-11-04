#!/bin/bash
# Скрипт готовит номер коммита для использования в команде 
# ficus --version
#
# Для этого в файл version.git_commit записывается строчка
#
# #define FX_GIT_COMMIT "XXXXXX"
#

echo "#define FX_GIT_COMMIT \"`git rev-parse --short HEAD`\"" > version.git_commit