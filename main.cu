#include <cstdio>
#include <cstdlib>
#include <cuda_runtime.h>
#include <cuda.h>

#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <fstream>

#include "SyncedMemory.h"
#include "device_launch_parameters.h"

using namespace std;



__global__ void SomeTransform(char *input_gpu, int fsize) 

{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	if (idx < fsize && input_gpu[idx] != '\n') 
	{
		input_gpu[idx] = input_gpu[idx]+input_gpu[idx];//copy two same part
	}
}


int main(int argc, char **argv)
{

	// init, and check
	if (argc != 2) 
	{
		printf("Usage %s <input text file>\n", argv[0]);
		
	}
	
	FILE *fp = fopen(argv[1], "r");
	if (not fp) 
	{
		printf("Cannot open %s", argv[1]);
		
	}
	
	// get file size
	fseek(fp, 0, SEEK_END);
	size_t fsize = ftell(fp);
	fseek(fp, 0, SEEK_SET);

	// read files
	MemoryBuffer<char> text(fsize + 1);
	auto text_smem = text.CreateSync(fsize);

	fread(text_smem.get_cpu_wo(), 1, fsize, fp);
	text_smem.get_cpu_wo()[fsize] = '\0';
	fclose(fp);

	// TODO: do your transform here
	char *input_gpu = text_smem.get_gpu_rw();


	SomeTransform<<<2, 32>>>(input_gpu, fsize);

	puts(text_smem.get_cpu_ro());
	
	printf("%d" ,text_smem );
	
	
	return 0;

}









dim3 block(1, 1, 1);

dim3 grid(W / block.x, H / block.y, 1);

simple_kernel << < grid, block >> >(yuv, W, H, impl->t);


__global__ void simple_kernel

(uint8_t *pos, unsigned int width, unsigned int height, float time)

{

unsigned int x = blockIdx.x*blockDim.x + threadIdx.x;

unsigned int y = blockIdx.y*blockDim.y + threadIdx.y;

pos[y*width + x] = (uint8_t)(x) *(int)time % 256;

}


































