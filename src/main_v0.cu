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
    long  focalStart = t_focal_start / dt;
    long  log_step = (iterNum + dt / 2.0) / 100;
    //long ele_offset_step = 0;
    //std::cout << "Total/ga/ele iters:"<< iterNum << " " << gaStep << " " << eleStep << std::endl;
    Ga* ga_gpu;
    Ele* ele_gpu;
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
        }

        //在i为10的整数倍，判断是否需要添加ga离子
        //if(i % 10 == 0)
        if(true)
        {
            //ga离子判断
            //if(gaTimes[0] <= i)//增加ga离子
            if(gaTimes.front() <= i)
            {
                if(!gaBuff.empty())//如果ga离子非空，释放显存
                {
                    //cudaDeviceSynchronize();
                    int bytes_ga = gaNum * sizeof(Ga);
                    cudaMemcpy(gaBuff.data(),ga_gpu,bytes_ga,cudaMemcpyDeviceToHost);
                    cudaFree(ga_gpu);
                }
                gaBuff.push_back(gaData.front());
                gaData.pop();
                gaTimes.pop();
                gaNum = gaBuff.size();
                int bytes_ga = gaNum * sizeof(Ga);
                cudaMallocManaged(&ga_gpu, bytes_ga);
                cudaMemcpy(ga_gpu, gaBuff.data(), bytes_ga, cudaMemcpyHostToDevice);
            }
            //ele离子判断,添加电子
            /*
            if(eleTimes.front() <= i)
            {
                if(!eleBuff.empty())
                {
                    int bytes_ele = eleNum * sizeof(Ele);
                    cudaMemcpy(eleBuff.data(),ele_gpu,bytes_ele,cudaMemcpyDeviceToHost);
                    cudaFree(ele_gpu);
                }
                eleBuff.push_back(eleData.front());
                eleData.pop();
                eleTimes.pop();
                eleNum = eleBuff.size();
                int bytes_ele = eleNum * sizeof(Ele);
                cudaMallocManaged(&ele_gpu,bytes_ele);
                cudaMemcpy(ele_gpu,eleBuff.data(),bytes_ele,cudaMemcpyHostToDevice);
            }
            */
        }

        size_t threadsPerBlock = BLOCK_SIZE;

        //size_t threadsPerBlockGa = N_p_ga;
        //size_t threadsPerBlockEle = N_p_ele;
        size_t numberOfBlocksGa = (gaNum + threadsPerBlock - 1)/threadsPerBlock;
        size_t numberOfBlocksEle =(eleNum+ threadsPerBlock - 1)/threadsPerBlock;
        coulombGaForce<<<numberOfBlocksGa,threadsPerBlock>>>(ga_gpu,ele_gpu, dt,gaNum,eleNum);
        coulombEleForce<<<numberOfBlocksEle,threadsPerBlock>>>(ga_gpu,ele_gpu, dt,gaNum,eleNum);
        integrate_ga_position<<<numberOfBlocksGa,threadsPerBlock>>>(ga_gpu,dt,gaNum);
        integrate_ele_position<<<numberOfBlocksEle,threadsPerBlock>>>(ele_gpu,dt,eleNum);      
        if(i % focalStep == 0 && i >= focalStart)
        {
            int bytes_ga = gaNum * sizeof(Ga);
            int bytes_ele = eleNum * sizeof(Ele);
            cudaMemcpy(gaBuff.data(),ga_gpu,bytes_ga,cudaMemcpyDeviceToHost);//
            cudaMemcpy(eleBuff.data(),ele_gpu,bytes_ele,cudaMemcpyDeviceToHost);//
            //S2
            std::vector<Ga> tmpGaBuff;
            std::vector<Ele> tmpEleBuff;
            //首先判断中和，gpt距离为0.529A = 5.29 * 1e-11m
            //double zhonghe = 5.29 * 1e-11;
            double zhonghe = 5.29 * 1e-5;
	        //double zhonghe = 5.29 * 1e-4;
            //for(int j=gaBuff.size()-1;j>=0;j--)
            // double z_thr = 156 * 1e-3;//z阈值
            // for(size_t j=0;j<gaBuff.size();j++)
            // {
            //     if(gaBuff[j].z > z_thr)
            //     {
            //         gaBuff[j].charge = 0;
            //     }
            // }
            // for(size_t j=0;j<gaBuff.size();j++)
            // {
            //         gaBuff[j].charge = 0;
            // }

            // for(size_t j=0;j<gaBuff.size();j++)
            // {
            //     //for(int k=eleBuff.size()-1;k>=0;k--)
            //     for(size_t k = 0;k<eleBuff.size();k++)
            //     {
            //         double x2 = (gaBuff[j].x - eleBuff[k].x) * (gaBuff[j].x - eleBuff[k].x);
            //         double y2 = (gaBuff[j].y - eleBuff[k].y) * (gaBuff[j].y - eleBuff[k].y);
            //         double z2 = (gaBuff[j].z - eleBuff[k].z) * (gaBuff[j].z - eleBuff[k].z);
            //         double r2 = x2 + y2 + z2;
            //         double r  = sqrt(r2);
            //         if(r < zhonghe && gaBuff[j].charge > 1e-19 && eleBuff[k].charge < -1e-19)//1.6e-19
            //         {
            //             gaBuff[j].charge = 0;
            //             eleBuff[k].charge = 0;
            //             zhGa.push_back(gaBuff[j]);
            //             zhEle.push_back(eleBuff[k]);
			//             //gaBuff.erase(gaBuff.begin() + j);
            //             //eleBuff.erase(eleBuff.begin() + k);
            //             break;
            //         }
            //     }
            // }


            //然后判断到达焦平面
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
                // else
                // {
                //     focalPlaneEle.push_back(eleBuff[j]);
                //     //tmpEleBuff.push_back(eleBuff[j]);
                // }
            }
            gaBuff = tmpGaBuff;
            eleBuff = tmpEleBuff;
            cudaFree(ga_gpu);
            cudaFree(ele_gpu);
            gaNum = gaBuff.size();
            eleNum = eleBuff.size();
            bytes_ga = gaNum * sizeof(Ga);
            bytes_ele = eleNum * sizeof(Ele);
            cudaMallocManaged(&ga_gpu, bytes_ga);
            cudaMallocManaged(&ele_gpu, bytes_ele);
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
