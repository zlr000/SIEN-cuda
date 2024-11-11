#ifndef __SETTINGS_H__
#define __SETTINGS_H__
#include <string>

extern const int BLOCK_SIZE;// 32

//Ga：2.8e5 m/s(30kV),  电子：7.2587e7m/s（15kV））

extern double S1;//电子束焦平面
extern double S2;//离子束焦平面
extern const double theta; //theta 角

extern const int numDelLine;//加载文件删除前几行
extern const double dt; // 每迭代一步时长
extern const double dt_focal;//判断到达焦平面时间间隔
extern const double t_focal_start;//开始判断到达焦平面的时间
extern const double t_total;//总迭代时间，单位秒(s)
    
//ga离子 参数设置
//extern std::string gaFile;//ga+ 文件路径
extern std::string gaFileD;//数据文件
extern std::string gaFileT;//时间戳文件
//extern int N_p_ga; //每个bunch ga+数
//extern int N_bunch_ga;//ga+ bunch数
extern float initZ_ga; //在文件处理中变为毫米,初始化ga Z值
//extern const double t_bunch_ga;//发射bunch时间间隔,单位秒(s)

//电子 参数设置
//extern std::string eleFile;
extern std::string eleFileD;//数据文件
extern std::string eleFileT;//时间戳文件
//extern const int N_p_ele;
//extern const int N_bunch_ele;
extern float initZ_ele;
extern double dt_ele;
//extern const double t_bunch_ele;

//最后时刻输出文件路径
extern std::string positionPathGa;
extern std::string positionPathEle;
extern std::string focalPlanePathGa;
extern std::string focalPlanePathEle;

//中间时刻输出文件路径前缀
extern std::string positionPathGaPrefix;
extern std::string positionPathElePrefix;
extern std::string focalPlanePathGaPrefix;
extern std::string focalPlanePathElePrefix;

#endif