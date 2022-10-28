#!/bin/bash

# Implémentation de la clef publique

mkdir ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys

cat << EOM > ~/.ssh/authorized_keys
ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBKtwmkAffyMfwgGnw+kgfgNHPmElZj9qMUlXPnQibizA/tzO3UEWapFiq1/0Rc6h2ixJFLvKeef5NnFo1AMDWNg= ecdsa-key-20221015
EOM
