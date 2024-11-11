project(n-body)
cmake_minimum_required(VERSION 3.10)

set(CMAKE_BUILD_TYPE "Release")
find_package(CUDA REQUIRED)

set(CMAKE_CXX_FLAGS_RELEASE "-std=c++14  -Wall -Wno-missing-field-initializers -Wno-deprecated-declarations -O3 -DENABLE_TEXT_BACKEND_STB")
set(CMAKE_CXX_FLAGS_DEBUG   "-std=c++14 -O0 -g -DENABLE_TEXT_BACKEND_STB")

set(CUDA_NVCC_FLAGS_RELEASE " -Xcompiler -std=c++14,-Wall,-Wno-deprecated-declarations,-O3 -DENABLE_TEXT_BACKEND_STB")
set(CUDA_NVCC_FLAGS_DEBUG   "-std=c++14 -O0 -g -DENABLE_TEXT_BACKEND_STB")

set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS}
  -gencode arch=compute_86,code=compute_86
)

include_directories(
    ./header
)

# cuda_add_library(nbody_lib SHARED
#     src/particle.cu
#     src/nbody.cu
# )

cuda_add_executable(nbody_cuda
    src/settings.cu
    src/particle.cu
    src/nbody.cu
    #src/main_v0.cu
    src/main.cu
)

# target_link_libraries(nbody_cuda
#     nbody_lib           
# )