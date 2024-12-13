cmake_minimum_required(VERSION 3.21)
project(importer LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE INTERNAL "")

set(PROJECT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(GENERATED_DIR ${PROJECT_DIR}/generated)

include(FetchContent)

FetchContent_Declare(
    flatbuffers
    GIT_REPOSITORY https://github.com/google/flatbuffers.git
    GIT_TAG        1f4a9038ce84e68fcba82ca427557c5ddde23eec
)

FetchContent_Declare(
    tinygltf
    GIT_REPOSITORY https://github.com/syoyo/tinygltf.git
    GIT_TAG        116d0030f9a55151eb1890b7b7131e4c0602de96
)
FetchContent_MakeAvailable(flatbuffers tinygltf)


# flatbuffers_schema(
#    TARGET dependent
#    INPUT filename
#    OUTPUT_DIR path
# )
function(flatbuffers_schema)
    cmake_parse_arguments(ARG "" "TARGET;INPUT;OUTPUT_DIR" "" ${ARGN})

    get_filename_component(INPUT_FILENAME ${ARG_INPUT} NAME_WE)

    set(OUTPUT_HEADER "${ARG_OUTPUT_DIR}/${INPUT_FILENAME}_flatbuffers.h")
    add_custom_command(
        COMMAND ${CMAKE_COMMAND} -E make_directory "${ARG_OUTPUT_DIR}"
        COMMAND "$<TARGET_FILE:flatc>"
            --warnings-as-errors
            --cpp
            --cpp-std c++17
            --cpp-static-reflection
            --gen-object-api
            --filename-suffix _flatbuffers
            -o "${ARG_OUTPUT_DIR}"
            "${ARG_INPUT}"
        MAIN_DEPENDENCY ${ARG_INPUT}
        OUTPUT "${OUTPUT_HEADER}"
        COMMENT "Generating flatbuffer schema ${ARG_INPUT}"
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")

    target_sources(${ARG_TARGET} PUBLIC "${OUTPUT_HEADER}")
    target_include_directories(${ARG_TARGET}
        PUBLIC
            $<BUILD_INTERFACE:${FLATBUFFERS_INCLUDE_DIR}>) # For includes starting with "flatbuffers/"
endfunction()

add_executable(importer
    "conversions.cc"
    "importer_gltf.cc"
    "scenec_main.cc"
    "vertices_builder.cc"
)

target_link_libraries(importer PUBLIC tinygltf)
target_include_directories(importer PUBLIC
    "${PROJECT_DIR}"
    "${flatbuffers_SOURCE_DIR}/include"
    "${tinygltf_SOURCE_DIR}/include")

flatbuffers_schema(
    TARGET importer
    INPUT ${PROJECT_DIR}/scene.fbs
    OUTPUT_DIR ${GENERATED_DIR}
)

install(TARGETS importer flatc
    CONFIGURATIONS Debug
    RUNTIME
        DESTINATION Debug/bin
)
install(TARGETS importer flatc
    CONFIGURATIONS Release
    RUNTIME
        DESTINATION Release/bin
)
