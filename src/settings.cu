#include "settings.h"

//Ga：2.8e5 m/s(30kV),  电子：7.2587e7m/s（15kV））
const int BLOCK_SIZE = 32;//GPU参数设置

//double S2 = 151.4974;//离子束焦平面
//double S2 = 159.354;//离子束焦平面
//const double theta = 52;
const double theta = 52 * M_PI / 180; 

const int numDelLine = 6;//删掉前6行
//const double dt = 1e-13; // time step
//const double dt = 1e-12;
const double dt = 1e-13;
const double dt_focal = dt * 1000;//判断到达焦平面时间间隔
//const double t_focal_start = 1e-11;//开始判断到达焦平面的时间
//const double t_total = 5e-8;//总迭代时间，单位秒(s)
//const double t_total = 1e-7;//总迭代时间，单位秒(s)
//const double t_total = 6 * 1e-4;
//const double t_total = 6 * 1e-5;
const double t_total = 2 * 1e-4;
    
//ga离子 参数设置 
//case1
// std::string gaFileD = "./data/ion/50paond12-200s.zs6";//数据文件
// std::string gaFileT = "./data/ion/50paond12-200-test.hit";//时间戳文件
// float initZ_ga = 152.5; //在文件处理中变为毫米
// double S2 = 159.354;//离子束焦平面

// case 2
//std::string gaFileD = "./data/ion/20paond12-1-400s.zs6";//数据文件
// std::string gaFileT = "./data/ion/20paond12-1-400-test.hit";//时间戳文件
// float initZ_ga = 152.5; //在文件处理中变为毫米
// double S2 = 159.36;//离子束焦平面

// case 3
//std::string gaFileD = "./data/ion/100paond12-1000s.zs6";//数据文件
//std::string gaFileT = "./data/ion/100paond12-1000s-test152.2.hit";//时间戳文件
//float initZ_ga = 152.5; //在文件处理中变为毫米
//double S2 = 159.346;//离子束焦平面


// case 4
std::string gaFileD = "./data/ion/70paond12-1000s.zs6";//数据文件
std::string gaFileT = "./data/ion/70paond12-1000s-test152.5.hit";//时间戳文件
float initZ_ga = 152.5; //在文件处理中变为毫米
double S2 = 159.35;//离子束焦平面

//case 5
// std::string gaFileD = "./data/50paond12-200s.zs6";//数据文件
// std::string gaFileT = "./data/50paond12-200s.hit";//时间戳文件
// float initZ_ga = 152.5; //在文件处理中变为毫米
// double S2 = 159.354;//离子束焦平面




//电子 参数设置 
// case 1
// std::string eleFileD = "./data/ele/20pa1-s.zs3";
// std::string eleFileT = "./data/ele/20pa1-s-test.hit";
// float initZ_ele = 354;//投影至离子平面156.8950480675493
// double S1 = 357.997;//电子束焦平面

// std::string eleFileD = "./data/ele/20pa1-10kv-s.zs3";
// std::string eleFileT = "./data/ele/20pa1-10kv-s354.hit";
// float initZ_ele = 354;//投影至离子平面156.8950480675493
// double S1 = 357.997;//电子束焦平面

// case 2
// std::string eleFileD = "./data/ele/50pa-s.zs3";
// std::string eleFileT = "./data/ele/50pa-s-test1.hit";
// float initZ_ele = 354;//投影至离子平面156.8950480675493
// double S1 = 357.994;//电子束焦平面
// double dt_ele = 1e-11;

// std::string eleFileD = "./data/ele/50pa-10kv-s.zs3";
// std::string eleFileT = "./data/ele/50pa-10kv-s354.hit";
// float initZ_ele = 354;//投影至离子平面156.8950480675493
// double S1 = 357.996;//电子束焦平面
// double dt_ele = 1e-12;

// case 3 
// std::string eleFileD = "./data/ele/100pa_s.zs3";
// std::string eleFileT = "./data/ele/100pa_s354.hit";
// float initZ_ele = 354;//投影至离子平面156.8950480675493
// double S1 = 357.991;//电子束焦平面
// double dt_ele = 1e-11;

//std::string eleFileD = "./data/ele/100pa-10kv-s.zs3";
//std::string eleFileT = "./data/ele/100pa-10kv-s354.hit";
//float initZ_ele = 354;//投影至离子平面156.8950480675493
//double S1 = 357.996;//电子束焦平面
//double dt_ele = 1e-11;

// case 4
// std::string eleFileD = "./data/ele/300pa-s.zs3";
// std::string eleFileT = "./data/ele/300pa-s354.hit";
// float initZ_ele = 354;//投影至离子平面156.8950480675493
// double S1 = 357.991;//电子束焦平面
// double dt_ele = 1e-11;

// std::string eleFileD = "./data/ele/300pa-10kv-s.zs3";
// std::string eleFileT = "./data/ele/300pa-10kv-s354.hit";
// float initZ_ele = 354;//投影至离子平面156.8950480675493
// double S1 = 357.996;//电子束焦平面
// double dt_ele = 1e-11;


// case 5
// std::string eleFileD = "./data/ele/1na-s.zs4";
// std::string eleFileT = "./data/ele/1na-s354.hit";
// float initZ_ele = 354;//投影至离子平面156.8950480675493
// double S1 = 357.99;//电子束焦平面
// double dt_ele = 1e-11;

 //std::string eleFileD = "./data/ele/1na-10kv-s.zs3";
// std::string eleFileT = "./data/ele/1na-10kv-s354.hit";
// float initZ_ele = 354;//投影至离子平面156.8950480675493
// double S1 = 357.996;//电子束焦平面
// double dt_ele = 1e-11;

// case 6
// std::string eleFileD = "./data/ele/3na-s.zs4";
// std::string eleFileT = "./data/ele/3na-s354.hit";
// float initZ_ele = 354;//投影至离子平面156.8950480675493
// double S1 = 357.99;//电子束焦平面
// double dt_ele = 1e-11;

 std::string eleFileD = "./data/ele/3na-10kv-s.zs4";
 std::string eleFileT = "./data/ele/3na-10kv-s354.hit";
 float initZ_ele = 354;//投影至离子平面156.8950480675493
 double S1 = 357.996;//电子束焦平面
 double dt_ele = 1e-11;




//最终输出文件路径
std::string positionPathGa = "./data/results/GaPosition_final.txt";
std::string positionPathEle = "./data/results/ElePosition_final.txt";
std::string focalPlanePathGa = "./data/results/focalPlaneGa_final.txt";
std::string focalPlanePathEle = "./data/results/focalPlaneEle_final.txt";

//中间时刻输出文件路径前缀
std::string positionPathGaPrefix = "./data/results/GaPosition";
std::string positionPathElePrefix = "./data/results/ElePosition";
std::string focalPlanePathGaPrefix = "./data/results/focalPlaneGa";
std::string focalPlanePathElePrefix = "./data/results/focalPlaneEle";
