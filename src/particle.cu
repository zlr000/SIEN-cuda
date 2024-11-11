#include "particle.h"
#include<fstream>
#include<iostream>
#include<math.h>
#include<settings.h>
#include <algorithm>
#include <numeric>

int CountLines(std::string& filename);

queue<Ga> parsing_ga_file(queue<long> &gaTimes)  //解析Ga文件
{
    int n1 = CountLines(gaFileD) - numDelLine;//总行数减去删掉行
    int cols = 8;

    std::ifstream file;
    file.open(gaFileD, std::ios::in);
    if (!file.is_open())
    {
        std::cout << "Fail to open file" << std::endl;
        exit(-1);
    }
    for (int i = 0; i < numDelLine; i++)
    {
        std::string tmpLine;
        std::getline(file, tmpLine);
    }
    std::vector<std::vector<double> > tmp(n1, std::vector<double>(cols));
    for (int i = 0; i < n1; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            file >> tmp[i][j];
        }
    }
    file.close();
    vector<Ga> gaData_(n1);
    for(int i = 0;i<n1;i++)
    {
        Ga tmpGa;
        tmpGa.id = tmp[i][0];
        tmpGa.vz = sqrt((2 * 1.6e-19 * tmp[i][6]) / tmpGa.mass);
        tmpGa.vx = tmp[i][3] * tmpGa.vz;
        tmpGa.vy = tmp[i][4] * tmpGa.vz;
        tmpGa.x  = tmp[i][1] * 1e-6;
        tmpGa.y  = tmp[i][2] * 1e-6;
        tmpGa.z  = initZ_ga * 1e-3;
        gaData_[i] = tmpGa;
    }

    int n2 = CountLines(gaFileT) - numDelLine;//总行数减去删掉行
    vector<long> gaTimes_(n2);
    //gaTimes_ = vector<long>(n2);
    file.open(gaFileT, std::ios::in);
    for (int i = 0; i < numDelLine; i++)
    {
        std::string tmpLine;
        std::getline(file, tmpLine);
    }
    //tmp n2
    for (int i = 0; i < n2; i++)
    {
        string tmpS;
        double tmpD;
        //13按Time started时间，14按Time Removed时间
        //13对应3，14对应2
        for (int j = 0; j < 14; j++)
        {
            file >> tmpS;
        }
        file >> tmpD;
        //tmpD = tmpD * 1e-12;
        gaTimes_[i] = (tmpD * 1e-12) / dt;
        //gaTimes_[i] = (gaTimes_[i] + 4) / 10 * 10;//此公式保证gaTimes数据为10的倍数
        for(int j=0;j<2;j++)
        {
            file >> tmpS;
        }
    }
    file.close();
    //判断长度是否一致，不一致则给出报错信息并退出程序
    if((gaData_.size() != gaTimes_.size()) ||(gaData_.size() == 0))
    {
        cout << "The size of gaData should bigger than 0 and equal to gaTimes!"<<endl;
        exit(-1);
    }
    //gaData 排序
    std::vector<int> indices(gaData_.size());//初始化索引数组
    std::iota(indices.begin(), indices.end(), 0);//生成从0开始连续递增的数组
    std::sort(indices.begin(), indices.end(), [&gaTimes_](size_t i1, size_t i2) { return gaTimes_[i1] < gaTimes_[i2]; });
    
    //vector<Ga> gaData(n1);
    queue<Ga> gaData;
    //gaTimes = vector<long>(n1);
    for(int i=0;i<n1;i++)
    {
        gaData.push(gaData_[indices[i]]);
        gaTimes.push(gaTimes_[indices[i]] - gaTimes_[indices[0]]);
    }
    
    //以下代码为输出实验
    // for(int i=0;i<101;i++)
    // {
    //     std::cout << gaData[i].id << " " << indices[i] << " " << gaTimes_[i] << std::endl;
    // }
    // //std::sort(gaTimes.begin(), gaTimes.end());
    // cout << endl;
    // for(int i=0;i<101;i++)
    // {
    //     std::cout << gaData[i].id << " " << gaTimes[i] << std::endl;
    // }
    // std::cout << "end" << std::endl;

    return gaData;
}

//vector<Ele> parsing_ele_file(vector<long> &eleTimes)
queue<Ele> parsing_ele_file(queue<long> &eleTimes)
{
    //theta 已转为弧度制
    double C1 = sin(theta) * S1;
    double C2 = S2 - cos(theta) * S1;
    C1 = C1 * 1e-3;
    C2 = C2 * 1e-3;

    int n1 = CountLines(eleFileD) - numDelLine;
    int cols = 8;
    std::ifstream file;
    file.open(eleFileD, std::ios::in);
    if (!file.is_open())
    {
        std::cout << "Fail to open file" << std::endl;
        exit(-1);
    }
    for (int i = 0; i < numDelLine; i++)
    {
        std::string tmpLine;
        std::getline(file, tmpLine);
    }
    std::vector<std::vector<double> > tmp(n1, std::vector<double>(cols));
    for (int i = 0; i < n1; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            file >> tmp[i][j];
        }
    }
    file.close();
    vector<Ele> eleData_(n1);
    for(int i = 0;i<n1;i++)
    {
        Ele tmpEle;
        tmpEle.id = tmp[i][0];
        tmpEle.vz = sqrt((2 * 1.6e-19 * tmp[i][6]) / tmpEle.mass);
        tmpEle.vx = tmp[i][3] * tmpEle.vz;
        tmpEle.vy = tmp[i][4] * tmpEle.vz;
        tmpEle.x  = tmp[i][1] * 1e-6;
        tmpEle.y  = tmp[i][2] * 1e-6;
        tmpEle.z  = initZ_ele * 1e-3;

        //坐标变换
        double tmpX,tmpZ;
        double tmpVX,tmpVZ;
        tmpX  = cos(theta) * tmpEle.x -  sin(theta) * tmpEle.z + C1;
        tmpZ  = sin(theta) * tmpEle.x +  cos(theta) * tmpEle.z + C2;
        tmpVX = cos(theta) * tmpEle.vx - sin(theta) * tmpEle.vz;
        tmpVZ = sin(theta) * tmpEle.vx + cos(theta) * tmpEle.vz;
        tmpEle.x = tmpX;
        tmpEle.z = tmpZ-0.004;
        tmpEle.vx= tmpVX;
        tmpEle.vz= tmpVZ;

        eleData_[i] = tmpEle;        
    }
    int n2 = CountLines(eleFileT) - numDelLine;
    vector<long> eleTimes_(n2);
    file.open(eleFileT,std::ios::in);
    for (int i = 0; i < numDelLine; i++)
    {
        std::string tmpLine;
        std::getline(file, tmpLine);
    }
    for(int i=0;i<n2;i++)
    {
        string tmpS;
        double tmpD;
        //13改成14，按Time Removed时间
        for (int j = 0; j < 14; j++)
        {
            file >> tmpS;
        }
        file >> tmpD;
        eleTimes_[i] = (tmpD * 1e-12) / dt;
        //eleTimes_[i] = (eleTimes_[i] + 4) / 10 * 10;
        for(int j=0;j<2;j++)
        {
            file >> tmpS;
        }        
    }
    file.close();
    //判断长度是否一致，不一致则给出报错信息并退出程序
    if((eleData_.size() != eleTimes_.size()) ||(eleData_.size() == 0))
    {
        cout << "The size of eleData should bigger than 0 and equal to eleTimes!"<<endl;
        exit(-1);
    }
    std::vector<int> indices(eleData_.size());//初始化索引数组
    std::iota(indices.begin(), indices.end(), 0);//生成从0开始连续递增的数组
    std::sort(indices.begin(), indices.end(), [&eleTimes_](size_t i1, size_t i2) { return eleTimes_[i1] < eleTimes_[i2]; });

    //vector<Ele> eleData(n1);
    //eleTimes = vector<long>(n1);
    queue<Ele> eleData;
    long dt_int = (long)((dt_ele + dt / 2) / dt);
    for(int i=0;i<n1;i++)
    {
        eleData.push(eleData_[indices[i]]);

        //case1 按照文件时间发射
        eleTimes.push(eleTimes_[indices[i]] - eleTimes_[indices[0]]);
        //case1 结束

        //case2 按照自定义dt_ele发射
        //eleTimes.push(dt_int);
        //dt_int += (long)((dt_ele + dt / 2) / dt);
        //case2 结束

    }
    long iterNum = (t_total + dt / 2.0) / dt;
    while(eleTimes.back() < iterNum)
    {
        long addOffset = eleTimes.back();
        for(int i=0;i<n1;i++)
        {
            eleData.push(eleData_[indices[i]]);
            eleTimes.push(eleTimes_[indices[i]] - eleTimes_[indices[0]] + addOffset);
        }

    }
    return eleData;
}

int CountLines(std::string& filename)
{
    std::ifstream Readfile;
    int line = 0;
    std::string tmp;

    Readfile.open(filename, std::ios::in);
    if (!Readfile.is_open())
    {
        std::cout << "cannot open file" << filename << std::endl;
        return -1;
    }
    else
    {
        while (std::getline(Readfile, tmp, '\n'))
        {
            line++;
        }
        Readfile.close();
        return line;
    }
}

// template <typename T>
// void writeFile(string filename,vector<T> data)
// {
//     std::ofstream fout;
//     fout.open(filename, std::ios::out);
//     if (!fout.is_open())
//     {
//         std::cout << filename << " cannot open!" << std::endl;
//         exit(-1);
//     }
//     for(int i=0;i<data.size();i++)
//     {
//         fout << data[i].id << " ";
//         fout << data[i].x << " ";
//         fout << data[i].y << " ";
//         fout << data[i].z;
//         fout << std::endl;
//     }
//     fout.close();
// }
