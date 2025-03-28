alias d := deb
alias t := test
alias bf := build-fast

deb:
    zig build run -- examples/t1.dlt

test: 
    zig build test

build-fast: 
    zig build --release=fast
