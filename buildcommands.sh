#!/bin/bash -e
alias build='zig build'
alias run=' zig build; if [ $? -eq 0 ]; then
./zig-out/bin/ZigChess 
fi'
