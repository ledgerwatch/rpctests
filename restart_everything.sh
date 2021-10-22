#!/bin/sh

BASE=$(pwd)

# copies nginx configurations (in case there was a change) and reloads nginx
$BASE/vm_init/copy_nginx_conf.sh
# note:
# changes made to js/css may not be recognized by browsers immediately,
# because they cache these files.

# that's all that is required at this moment
