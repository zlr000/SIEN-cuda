#ifndef __PARTICLE_H__
#define __PARTICLE_H__

#include <string>
#include <vector>
#include <iomanip>
#include <iostream>
#include <fstream>
#include <sstream>
#include <queue>

using namespace std;
//粒子定义
struct Ga
{
    int id;
    double x, y, z, vx, vy, vz;
    double mass = 1.15798282e-25;//kg
    double charge = 1.6e-19;
    //是否中和掉信息还未定义
};

struct Ele
{
    int id;
    double x, y, z, vx, vy, vz;
    // double mass = 9.10956e-31;
    double mass = 9.109383560e-31;
    double charge = -1.6e-19;
    //double charge = 0;
};

//解析Ga离子文件
queue<Ga> parsing_ga_file(queue<long> &gaTimes);
queue<Ele> parsing_ele_file(queue<long> &eleTimes);
//vector<Ga> parsing_ga_file(vector<long> &gaTimes);
//vector<Ele> parsing_ele_file(vector<long> &eleTimes);
//vector<vector<Ga>> parsing_ga_file(string filename,int numDelLine,int N,float initZ);
//vector<vector<Ele>> parsing_ele_file(string filename,int numDelLine,int N,float initZ_ga,float initZ_ele,double theta);

//筛选到达样品平面的粒子

//写入文件
//template <typename T>
//void writeFile(string filename,vector<T> data);

template <typename T>
void writeFile(string filename,vector<T> data)
{
    std::ofstream fout;
    fout.open(filename, std::ios::out);
    if (!fout.is_open())
    {
        std::cout << filename << " cannot open!" << std::endl;
        exit(-1);
    }
    for(size_t i=0;i<data.size();i++)
    {
        fout << std::setw(5) << std::setfill(' ') << std::left << data[i].id;
        fout << std::setw(15) << std::setfill(' ') << std::left << data[i].x * 1e6;
        fout << std::setw(15) << std::setfill(' ') << std::left << data[i].y * 1e6;
        fout << std::setw(15) << std::setfill(' ') << std::left << data[i].z * 1e3;
        fout << endl;
        //fout << std::setw(5) << std::setfill(' ') << std::left << std::endl;
        // fout << std::setw(5) << std::setfill(' ') << std::left << data[i].id << " ";
        // fout << std::setw(15) << std::setfill(' ') << std::left << data[i].x << " ";
        // fout << std::setw(5) << std::setfill(' ') << std::left << data[i].y << " ";
        // fout << std::setw(5) << std::setfill(' ') << std::left << data[i].z;
        // fout << std::setw(5) << std::setfill(' ') << std::left << std::endl;
    }
    fout.close();
}

#endif


