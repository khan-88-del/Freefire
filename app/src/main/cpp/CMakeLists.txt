cmake_minimum_required(VERSION 3.22.1)
project("nativeinput")

add_library(nativeinput SHARED input_filter.cpp)
find_library(log-lib log)
target_link_libraries(nativeinput ${log-lib})
