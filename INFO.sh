#!/bin/bash

source /pkgscripts-ng/include/pkg_util.sh

package="ch341"
version="1.0.0-0001"
displayname="ch341"
maintainer="chenzhuoyu1992@gmail.com"
arch="$(pkg_get_platform)"
description="CH341 driver for Synology DSM 7"

[ "$(caller)" != "0 NULL" ] && return 0
pkg_dump_info
