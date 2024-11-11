#include "nbody.h"

__global__ void coulombGaForce(Ga *p1,Ele* p2, float dt, int n_ga,int n_ele)//Ga库仑力计算
{
    double k = 8.988e9;
    int i = threadIdx.x + blockDim.x * blockIdx.x;
    if(i < n_ga)
    {
        double ax = 0.0;
        double ay = 0.0;
        double az = 0.0;
        for(int j=0;j<n_ga;j++)//离子与离子
        {
            if(j==i)
                continue;
            double dx = p1[i].x - p1[j].x;
            double dy = p1[i].y - p1[j].y;
            double dz = p1[i].z - p1[j].z;
            double distSqr = dx * dx + dy * dy + dz * dz;
            double invDist = rsqrtf(distSqr);//平方根的倒数，rsqrtf(25) = 0.2
            double invDist3 = invDist * invDist * invDist;
            ax += k * p1[i].charge * p1[j].charge* dx * invDist3;
            ay += k * p1[i].charge * p1[j].charge* dy * invDist3;
            az += k * p1[i].charge * p1[j].charge* dz * invDist3;
        }
        for(int j=0;j<n_ele;j++)//离子与电子
        {
            double dx = p1[i].x - p2[j].x;
            double dy = p1[i].y - p2[j].y;
            double dz = p1[i].z - p2[j].z;
            double distSqr = dx * dx + dy * dy + dz * dz;
            double invDist = rsqrtf(distSqr);//平方根的倒数，rsqrtf(25) = 0.2
            double invDist3 = invDist * invDist * invDist;

            ax += k * p1[i].charge * p2[j].charge* dx * invDist3;   //库仑力
            ay += k * p1[i].charge * p2[j].charge* dy * invDist3;
            az += k * p1[i].charge * p2[j].charge* dz * invDist3;
        }
        p1[i].vx += dt * ax / p1[i].mass;   //v=v0+at=v0+F/m*t
        p1[i].vy += dt * ay / p1[i].mass;
        p1[i].vz += dt * az / p1[i].mass;
    }
}

__global__ void coulombEleForce(Ga *p1,Ele* p2, float dt, int n_ga,int n_ele)//Ele 库仑力计算
{
    double k = 8.988e9;
    int i = threadIdx.x + blockDim.x * blockIdx.x;
    if(i < n_ele)
    {
        double ax = 0.0;
        double ay = 0.0;
        double az = 0.0;
        for(int j=0;j<n_ga;j++)//电子与离子
        {
            double dx = p2[i].x - p1[j].x;
            double dy = p2[i].y - p1[j].y;
            double dz = p2[i].z - p1[j].z;
            double distSqr = dx * dx + dy * dy + dz * dz;
            double invDist = rsqrtf(distSqr);//平方根的倒数，rsqrtf(25) = 0.2
            double invDist3 = invDist * invDist * invDist;

            ax += k * p2[i].charge * p1[j].charge* dx * invDist3;
            ay += k * p2[i].charge * p1[j].charge* dy * invDist3;
            az += k * p2[i].charge * p1[j].charge* dz * invDist3;
        }
        for(int j=0;j<n_ele;j++) //电子与电子
        {
            if(j==i)
                continue;
            double dx = p2[i].x - p2[j].x;
            double dy = p2[i].y - p2[j].y;
            double dz = p2[i].z - p2[j].z;
            double distSqr = dx * dx + dy * dy + dz * dz;
            double invDist = rsqrtf(distSqr);//平方根的倒数，rsqrtf(25) = 0.2
            double invDist3 = invDist * invDist * invDist;

            ax += k * p2[i].charge * p2[j].charge * dx * invDist3;
            ay += k * p2[i].charge * p2[j].charge * dy * invDist3;
            az += k * p2[i].charge * p2[j].charge * dz * invDist3;
        }
        p2[i].vx += dt * ax / p2[i].mass;
        p2[i].vy += dt * ay / p2[i].mass;
        p2[i].vz += dt * az / p2[i].mass;
    }
}

__global__ void integrate_ga_position(Ga *p, float dt, int n_ga,double thrZ)//Ga位置更新
{
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    if (i < n_ga)
    {
        p[i].x += p[i].vx * dt;  //x=x0+v*t
        p[i].y += p[i].vy * dt;
        p[i].z += p[i].vz * dt;

        /*新加代码，在离焦平面z_height距离时假设中和掉，不再受库仑力作用*/
        //double z_height = 0.02;//thrZ = 0.159354, start z = 0.1525
        // double z_height = 0.005;
        // //double z_height = 0.003;
        // //double z_height = 0.007;
        // //double z_height = 0.0005;
        // if((p[i].z+z_height) >= thrZ)
        // {
        //     p[i].charge = 0;
        // }
        // /*新加代码结束*/

        if(p[i].z > thrZ)
        {
            p[i].charge = 0;
            p[i].vx = 0;
            p[i].vy = 0;
            p[i].vz = 0;
        }
    }
}

__global__ void integrate_ele_position(Ele* p, float dt, int n_ele,double thrZ)//Ele位置更新
{
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    if (i < n_ele)
    {
        p[i].x += p[i].vx * dt;
        p[i].y += p[i].vy * dt;
        p[i].z += p[i].vz * dt;
        if(p[i].z > thrZ)
        {
            p[i].charge = 0;
            p[i].vx = 0;
            p[i].vy = 0;
            p[i].vz = 0;
        }
    }
}
