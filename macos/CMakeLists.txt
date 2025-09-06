cmake_minimum_required(VERSION 3.20)
project(MaxKiller VERSION 0.0.1 LANGUAGES C CXX)

add_library(lz4shim SHARED
        ../native/lz4/lib/lz4.c
        ../native/lz4/lib/lz4hc.c
)

target_include_directories(lz4shim PUBLIC
        ../native/lz4/lib
)
