#!/bin/bash

export ARCH="mips"
export CROSS_COMPILE="ccache mips64el-linux-gnuabi64-"

export __bd=$PWD
alias bd='cd ${__bd}'
alias BD='__bd=$PWD'
