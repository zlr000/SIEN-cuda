#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "timer.h"
#include "check.h"
#include "particle.h"
#include "nbody.h"
#include <fstream>
#include <iostream>
#include "settings.h"
#include <algorithm>

int main()
{
    std::queue<long> gaTimes;
    std::queue<Ga> gaData; 
    std::queue<long> eleTimes;
    std::queue<Ele> eleData;
    //std::vector<std::vector<Ga>> gaData = parsing_ga_file(gaFile,numDelLine,N_p_ga,initZ_ga);
    //std::vector<std::vector<Ele>> eleData = parsing_ele_file(eleFile,numDelLine,N_p_ele,initZ_ga,initZ_ele,theta);
    gaData = parsing_ga_file(gaTimes);
    eleData = parsing_ele_file(eleTimes);
    std::cout << "Ga number:" << gaData.size() << " " << "Ga times number:" << gaTimes.size() << std::endl;
    std::cout << "Ele number:" << eleData.size() << " " << "Ele times number:" << eleTimes.size() << std::endl;
    //std::cout << "Ga  bunch number:"<<gaData.size()  << " " <<"Particle number per bunch:"<< gaData[0].size()  << std::endl;
    //std::cout << "ele bunch number:"<<eleData.size() << " " <<"Particle number per bunch:"<< eleData[0].size() << std::endl;
    std::vector<Ga> gaBuff;
    std::vector<Ele> eleBuff;
    std::vector<Ga> focalPlaneGa;
    std::vector<Ele> focalPlaneEle;
    std::vector<Ga> zhGa;
    std::vector<Ele> zhEle;
    int gaNum = 0,eleNum = 0;//ga,ele数
    long iterNum = (t_total + dt / 2.0) / dt; 
    long focalStep = (dt_focal  + dt / 2.0)/dt;
    //long  focalStart = t_focal_start / dt;
    long  log_step = (iterNum + dt / 2.0) / 100;
    //long ele_offset_step = 0;
    //std::cout << "Total/ga/ele iters:"<< iterNum << " " << gaStep << " " << eleStep << std::endl;
    Ga* ga_gpu;
    Ele* ele_gpu;
    cudaMallocManaged(&ga_gpu, 10000 * sizeof(Ga));
    cudaMallocManaged(&ele_gpu,1000 * sizeof(Ele));
    StartTimer();
    std::cout << iterNum << std::endl;
    for(long i = 0; i < iterNum;i++)
    {
        //每次log输出GaBUff/GaFocal/EleBuff/EleFocal数量信息
        //每次log保存一次GaBUff/GaFocal/EleBuff/EleFocal的中间结果信息
        if(i%log_step==0)
        {
            //输出log信息
            const double tElapsed = GetTimer() / 1000.0;
            StartTimer();
            std::cout << "Iter number:" << i << "/" << iterNum << " Total time:" << tElapsed << std::endl;
            std::cout << "GaBUff/GaFocal/EleBuff/EleFocal number:";
            std::cout << gaBuff.size() << " "<< focalPlaneGa.size() << " "<< eleBuff.size() << " " << focalPlaneEle.size() << std::endl;
            std::cout << "neutralization number Ga/Ele:" << zhGa.size() << " " << zhEle.size() << std::endl;
            //保存中间文件
            string suffix = "_" + std::to_string((int)(i/log_step)) + ".txt";
            writeFile<Ga>(positionPathGaPrefix+suffix,gaBuff);
            writeFile<Ga>(focalPlanePathGaPrefix+suffix,focalPlaneGa);
            writeFile<Ele>(positionPathElePrefix+suffix,eleBuff);
            writeFile<Ele>(focalPlanePathElePrefix+suffix,focalPlaneEle); 

            std::vector<double> ga_rs;
            std::vector<double> ele_rs;
            if(focalPlaneGa.size() >= 1000)
            {
                for(long unsigned int tmpIdx = 0;tmpIdx < focalPlaneGa.size();tmpIdx++)
                {
                    double gaX2 = focalPlaneGa[tmpIdx].x * focalPlaneGa[tmpIdx].x;
                    double gaY2 = focalPlaneGa[tmpIdx].y * focalPlaneGa[tmpIdx].y;
                    double gaR = sqrt(gaX2 + gaY2);
                    ga_rs.push_back(gaR);
                }
                std::sort(ga_rs.begin(),ga_rs.end());
                int dIdx = (int)(ga_rs.size() * 0.88) - 1;
                std::cout << "The d1288 value of Ga+:"<<ga_rs[dIdx] * 1e9 << "nm" << std::endl;

            }
            if(focalPlaneEle.size() >= 1000)//电子d1288
            {
                for(long unsigned int tmpIdx = 0;tmpIdx < focalPlaneEle.size();tmpIdx++)
                {
                    double eleX2 = focalPlaneEle[tmpIdx].x * focalPlaneEle[tmpIdx].x;
                    double eleY2 = focalPlaneEle[tmpIdx].y * focalPlaneEle[tmpIdx].y;
                    //double eleR = sqrt(eleX2 + eleY2);
                    double eleR = sqrt(eleY2);
                    ele_rs.push_back(eleR);
                }
                std::sort(ele_rs.begin(),ele_rs.end());
                int dIdx = (int)(ele_rs.size() * 0.88) - 1;
                std::cout << "The d1288 value of ele:"<<ele_rs[dIdx] * 1e9 << "nm" << std::endl;
            }



        }

        //在i为10的整数倍，判断是否需要添加ga离子
        //if(i % 10 == 0)
        if(true)
        {
            // //ga离子判断
            if(gaTimes.front() <= i)
            {
                Ga tmpGa[1] = {gaData.front()};
                gaData.pop();
                gaTimes.pop();
                cudaMemcpy(ga_gpu + gaNum, tmpGa, sizeof(Ga), cudaMemcpyHostToDevice);
                gaNum += 1;
            }
            //ele离子判断
            if(eleTimes.front() <= i)
            {
                Ele tmpEle[1] = {eleData.front()};
                eleData.pop();
                eleTimes.pop();
                cudaMemcpy(ele_gpu + eleNum,tmpEle,sizeof(Ele),cudaMemcpyHostToDevice);
                eleNum += 1;
            }
        }

        size_t threadsPerBlock = BLOCK_SIZE;

        //size_t threadsPerBlockGa = N_p_ga;
        //size_t threadsPerBlockEle = N_p_ele;
        size_t numberOfBlocksGa = (gaNum + threadsPerBlock - 1)/threadsPerBlock;
        size_t numberOfBlocksEle =(eleNum+ threadsPerBlock - 1)/threadsPerBlock;
        coulombGaForce<<<numberOfBlocksGa,threadsPerBlock>>>(ga_gpu,ele_gpu, dt,gaNum,eleNum);
        coulombEleForce<<<numberOfBlocksEle,threadsPerBlock>>>(ga_gpu,ele_gpu, dt,gaNum,eleNum);
        integrate_ga_position<<<numberOfBlocksGa,threadsPerBlock>>>(ga_gpu,dt,gaNum,S2 * 1e-3);
        integrate_ele_position<<<numberOfBlocksEle,threadsPerBlock>>>(ele_gpu,dt,eleNum,S2 * 1e-3);      
        //判断到达焦平面
        //if(i % focalStep == 0 && i >= focalStart)
        //if(i % (focalStep * 10) == 0)
        if(i % focalStep == 0)
        {
            //首先是数据拷贝，GPU->CPU
            int bytes_ga = gaNum * sizeof(Ga);
            int bytes_ele = eleNum * sizeof(Ele);
            gaBuff = std::vector<Ga>(gaNum);
            eleBuff = std::vector<Ele>(eleNum);
            cudaMemcpy(gaBuff.data(),ga_gpu,bytes_ga,cudaMemcpyDeviceToHost);
            cudaMemcpy(eleBuff.data(),ele_gpu,bytes_ele,cudaMemcpyDeviceToHost);

            //然后是拆分运行中粒子与到达焦平面粒子
            std::vector<Ga> tmpGaBuff;
            std::vector<Ele> tmpEleBuff;
            for(size_t j=0;j<gaBuff.size();j++)
            {
                if(gaBuff[j].z >= S2 * 1e-3)
                {
                    focalPlaneGa.push_back(gaBuff[j]);
                }
                else
                {
                    tmpGaBuff.push_back(gaBuff[j]);
                }
            }
            for(size_t j=0;j<eleBuff.size();j++)
            {
                if(eleBuff[j].z < S2 * 1e-3)
                {
                    tmpEleBuff.push_back(eleBuff[j]);
                }
                else
                {
                    focalPlaneEle.push_back(eleBuff[j]);
                }
            }
            gaBuff = tmpGaBuff;
            eleBuff = tmpEleBuff;
            //cudaFree(ga_gpu);
            //cudaFree(ele_gpu);
            gaNum = gaBuff.size();
            eleNum = eleBuff.size();
            bytes_ga = gaNum * sizeof(Ga);
            bytes_ele = eleNum * sizeof(Ele);
            //cudaMallocManaged(&ga_gpu, bytes_ga);
            //cudaMallocManaged(&ele_gpu, bytes_ele);
            cudaMemcpy(ga_gpu, gaBuff.data(), bytes_ga, cudaMemcpyHostToDevice);
            cudaMemcpy(ele_gpu,eleBuff.data(),bytes_ele,cudaMemcpyHostToDevice);
            // cudaError_t err = cudaGetLastError();
            // if (err != cudaSuccess) {
            //     printf("CUDA Error: %s\n", cudaGetErrorString(err));
            //     // Possibly: exit(-1) if program cannot continue....
            // }

        }
        //if((i+1)%gaStep == 0 || (i+1)%eleStep ==0)
        //{
        //    cudaDeviceSynchronize();
        //}
    } 

    //保存位置文件
    std::cout << "Final output:" << gaBuff.size() << " "<< focalPlaneGa.size() << " "<< eleBuff.size() << " " << focalPlaneEle.size() << std::endl;
    //writeFile(positionPathGa,gaBuff);
    writeFile<Ga>(positionPathGa,gaBuff);
    writeFile<Ga>(focalPlanePathGa,focalPlaneGa);
    writeFile<Ele>(positionPathEle,eleBuff);
    writeFile<Ele>(focalPlanePathEle,focalPlaneEle);

    return 0;
}
