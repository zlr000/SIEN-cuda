# 聚焦离子束程序使用说明

1.在cuda-nbody文件夹下，新建build文件夹

```
mkdir build
```

2.进入build文件夹，cmake && make

```
cd build
cmake ..
make
```

3.编译完成且无异常后，重新进入cuda-nbody文件夹下，运行程序

```
cd ..
./build/nbody_cuda
```

4.结果保存在cuda-nbody/data/results文件夹下