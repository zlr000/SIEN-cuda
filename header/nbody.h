#ifndef __NBODY_H__
#define __NBODY_H__
#include "particle.h"
#include <cuda_runtime.h>

__global__ void coulombGaForce(Ga *p1,Ele* p2, float dt, int n_ga,int n_ele);//Ga库仑力计算
__global__ void coulombEleForce(Ga *p1,Ele* p2, float dt, int n_ga,int n_ele);//Ele 库仑力计算
__global__ void integrate_ga_position(Ga *p, float dt, int n_ga,double thrZ);//Ga位置更新
__global__ void integrate_ele_position(Ele* p, float dt, int n_ele,double thrZ);//Ele位置更新

#endif