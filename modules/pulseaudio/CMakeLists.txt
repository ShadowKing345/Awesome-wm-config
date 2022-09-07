cmake_minimum_required(VERSION 3.23)
project(pulseaudio)

set(CMAKE_C_STANDARD 17)
set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR})

include_directories(src)

file(GLOB SOURCES src/*.c src/*.h)

add_library(pulseaudio SHARED ${SOURCES})

target_link_libraries(pulseaudio lua pulse)
target_include_directories(pulseaudio PRIVATE lua pulse)
set_target_properties(pulseaudio PROPERTIES PREFIX "" OUTPUT_NAME init SUFFIX .so)
