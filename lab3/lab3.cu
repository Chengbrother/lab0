#include "lab3.h"
#include <cstdio>

__device__ __host__ int CeilDiv(int a, int b) { return (a-1)/b + 1; }
__device__ __host__ int CeilAlign(int a, int b) { return CeilDiv(a, b) * b; }

__global__ void SimpleClone
(
	const float *background,
	const float *target,
	const float *mask,
	float *output,
	const int wb, const int hb, const int wt, const int ht,
	const int oy, const int ox
)
{
	const int yt = blockIdx.y * blockDim.y + threadIdx.y;
	const int xt = blockIdx.x * blockDim.x + threadIdx.x;
	const int curt = wt*yt+xt;
	if (yt < ht and xt < wt and mask[curt] > 127.0f)
	{
		const int yb = oy+yt, xb = ox+xt;
		const int curb = wb*yb+xb;
		if (0 <= yb and yb < hb and 0 <= xb and xb < wb)
		{
			output[curb*3+0] = target[curt*3+0];
			output[curb*3+1] = target[curt*3+1];
			output[curb*3+2] = target[curt*3+2];
		}
	}
}

__global__ void CalculateFixed//算出fixed
(
const float *background,const float *target,const float *mask,float *fixed,
const int wb, const int hb, const int wt, const int ht,const int oy, const int ox
)

{
	const int yt = blockIdx.y * blockDim.y + threadIdx.y;
	const int xt = blockIdx.x * blockDim.x + threadIdx.x;
	const int curt = wt*yt+xt;
	const int yb = oy+yt, xb = ox+xt;
	const int curb = wb*yb+xb;

	float nb0=0;
	float wbe0=0;
	float sb0=0;
	float eb0=0;

	float nb1=0;
	float wbe1=0;
	float sb1=0;
	float eb1=0;

	float nb2=0;
	float wbe2=0;
	float sb2=0;
	float eb2=0;


	float nt0=0;
	float wte0=0;
	float st0=0;
	float et0=0;

	float nt1=0;
	float wte1=0;
	float st1=0;
	float et1=0;

	float nt2=0;
	float wte2=0;
	float st2=0;
	float et2=0;


	if (mask[curt] < 127.0f)
		{
		}
	else
		{
			//n
			if(curt>=wt)
			{
				if(mask[(curt-wt)] > 127.0f)
				{
				}
				else
				{
					nb0=background[(curb-wb)*3+0];
					nb1=background[(curb-wb)*3+1];
					nb2=background[(curb-wb)*3+2];
				}
					nt0=target[(curt-wt)*3+0];
					nt1=target[(curt-wt)*3+1];
					nt2=target[(curt-wt)*3+2];
			 }
				else
				{
					nt0=target[(curt)*3+0];
					nt1=target[(curt)*3+1];
					nt2=target[(curt)*3+2];
					nb0=background[(curb-wb)*3+0];
					nb1=background[(curb-wb)*3+1];
					nb2=background[(curb-wb)*3+2];
				}

			//w
			if (curt%wt != 0)
			 {
                if(mask[(curt-1)] > 127.0f)
                {
                }
                else
                {
                	wbe0=background[(curb-1)*3+0];
                	wbe1=background[(curb-1)*3+1];
                	wbe2=background[(curb-1)*3+2];
                }
                	wte0=target[(curt-1)*3+0];
                	wte1=target[(curt-1)*3+1];
                	wte2=target[(curt-1)*3+2];
             }
                else
                {
                	wte0=target[curt*3+0];
                	wte1=target[curt*3+1];
                	wte2=target[curt*3+2];
                	wbe0=background[(curb-1)*3+0];
                	wbe1=background[(curb-1)*3+1];
                	wbe2=background[(curb-1)*3+2];
                }

            //s
            if (curt + wt<wt*ht)
              {
                if(mask[(curt+wt)] > 127.0f)
                {
                }
                else
                {
                	sb0=background[(curb+wb)*3+0];
                	sb1=background[(curb+wb)*3+1];
                	sb2=background[(curb+wb)*3+2];
                }
                	st0=target[(curt+wt)*3+0];
                	st1=target[(curt+wt)*3+1];
                	st2=target[(curt+wt)*3+2];
              	}
                else
                {
                	st0=target[curt*3+0];
                	st1=target[curt*3+1];
                	st2=target[curt*3+2];
                	sb0=background[(curb+wb)*3+0];
                	sb1=background[(curb+wb)*3+1];
                	sb2=background[(curb+wb)*3+2];

                }

             //e
             if ((curt + 1) % wt != 0)
              {
                if(mask[(curt+1)] > 127.0f)
                {
                }
                else
                {
                	eb0=background[(curb+1)*3+0];
                	eb1=background[(curb+1)*3+1];
                	eb2=background[(curb+1)*3+2];
                }
                	et0=target[(curt+1)*3+0];
                	et1=target[(curt+1)*3+1];
                	et2=target[(curt+1)*3+2];
              }
                else
                {
                	et0=target[curt*3+0];
                	et1=target[curt*3+1];
                	et2=target[curt*3+2];
                	eb0=background[(curb+1)*3+0];
                	eb1=background[(curb+1)*3+1];
                	eb2=background[(curb+1)*3+2];
                }
                fixed[curt*3+0]=4*target[curt*3+0]-nt0-st0-wte0-et0+nb0+sb0+wbe0+eb0;
                fixed[curt*3+1]=4*target[curt*3+1]-nt1-st1-wte1-et1+nb1+sb1+wbe1+eb1;
                fixed[curt*3+2]=4*target[curt*3+2]-nt2-st2-wte2-et2+nb2+sb2+wbe2+eb2;
			}
		}





__global__ void PoissonImageCloningIteration
(
const float *fixed, const float *mask, float *bufnow, float *bufnext, const int wt, const int ht
)
{
	const int yt = blockIdx.y * blockDim.y + threadIdx.y;
	const int xt = blockIdx.x * blockDim.x + threadIdx.x;
	int curt = wt*yt+xt;

	float nbw0=0;
	float wbw0=0;
	float sbw0=0;
	float ebw0=0;

	float nbw1=0;
	float wbw1=0;
	float sbw1=0;
	float ebw1=0;

	float nbw2=0;
	float wbw2=0;
	float sbw2=0;
	float ebw2=0;
					//n
					if(curt>=wt)
					{
						if(mask[(curt-wt)] > 127.0f)
						{
							nbw0=bufnow[(curt-wt)*3+0];
							nbw1=bufnow[(curt-wt)*3+1];
							nbw2=bufnow[(curt-wt)*3+2];
						}
					}

					//w
					if (curt%wt !=0)
					{
		                if(mask[(curt-1)] > 127.0f)
		                {
		                	wbw0=bufnow[(curt-1)*3+0];
		                	wbw1=bufnow[(curt-1)*3+1];
		                	wbw2=bufnow[(curt-1)*3+2];
		                }
					}

					//s
		           if (curt+wt<wt*ht)
		           	   {

		                if(mask[(curt+wt)] > 127.0f)
		                {
		                	sbw0=bufnow[(curt+wt)*3+0];
		                	sbw1=bufnow[(curt+wt)*3+1];
		                	sbw2=bufnow[(curt+wt)*3+2];
		                }

		           	   	}

		           //e
		           if ((curt+1)%wt!=0)
		           {
		                if(mask[(curt+1)] > 127.0f)
		                {
		                	ebw0=bufnow[(curt+1)*3+0];
		                	ebw1=bufnow[(curt+1)*3+1];
		                	ebw2=bufnow[(curt+1)*3+2];
		                }
		            }
		           	   	bufnext[curt*3+0]= (fixed[curt*3+0]+ (nbw0+wbw0+sbw0+ebw0))/4;
		                bufnext[curt*3+1]= (fixed[curt*3+1]+ (nbw1+wbw1+sbw1+ebw1))/4;
		                bufnext[curt*3+2]= (fixed[curt*3+2]+ (nbw2+wbw2+sbw2+ebw2))/4;

			}
void PoissonImageCloning
(
	const float *background,
	const float *target,
	const float *mask,
	float *output,
	const int wb, const int hb, const int wt, const int ht,
	const int oy, const int ox
)
{
	//set up
	float *fixed, *buf1, *buf2;
	cudaMalloc(&fixed, 3*wt*ht*sizeof(float));
	cudaMalloc(&buf1, 3*wt*ht*sizeof(float));
	cudaMalloc(&buf2, 3*wt*ht*sizeof(float));

	// initialize the iteration
	dim3 gdim(CeilDiv(wt,32), CeilDiv(ht,16)), bdim(32,16);

	CalculateFixed<<<gdim, bdim>>>
			(
			background, target, mask, fixed,
			wb, hb, wt, ht, oy, ox
			);

	cudaMemcpy(buf1, target, sizeof(float)*3*wt*ht, cudaMemcpyDeviceToDevice);

	// iterate

	for(int i=0;i<3000;++i)
	{

		dim3 gdim(CeilDiv(wt,32), CeilDiv(ht,16)), bdim(32,16);

		PoissonImageCloningIteration<<<gdim, bdim>>>(
				fixed, mask, buf1, buf2, wt, ht
				);


	    PoissonImageCloningIteration<<<gdim, bdim>>>(
				fixed, mask, buf2, buf1, wt, ht
			   );
	}


	//copy the image back
	cudaMemcpy(output, background, wb*hb*sizeof(float)*3, cudaMemcpyDeviceToDevice);



	SimpleClone<<<gdim, bdim>>>
	(
	   background, buf1, mask, output,
	   wb, hb, wt, ht, oy, ox
	);

	//SimpleClone<<<dim3(CeilDiv(wt,32), CeilDiv(ht,16)), dim3(32,16)>>>(
		//background, target, mask, output,
		//wb, hb, wt, ht, oy, ox
	//);


	//clean up
	cudaFree(fixed);
	cudaFree(buf1);
	cudaFree(buf2);
}

