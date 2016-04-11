#include "lab2.h"


static const unsigned W = 640;
static const unsigned H = 480;
static const unsigned NFRAME = 240;

struct Lab2VideoGenerator::Impl {
	int t = 0;
};

Lab2VideoGenerator::Lab2VideoGenerator(): impl(new Impl) {
}

Lab2VideoGenerator::~Lab2VideoGenerator() {}

void Lab2VideoGenerator::get_info(Lab2VideoInfo &info)
{
	info.w = W;
	info.h = H;
	info.n_frame = NFRAME;
	// fps = 24/1 = 24
	info.fps_n = 24;
	info.fps_d = 1;
};

__global__ void simple_kernel(uint8_t *pos, unsigned int width, unsigned int height, float time)

{
	unsigned int x = blockIdx.x*blockDim.x + threadIdx.x;
	unsigned int y = blockIdx.y*blockDim.y + threadIdx.y;

	// calculate uv coordinates
	//x = x / (float) width;
	//y = y / (float) height;
	float v = x*6.0f - 1.0f;
	float u = y*2.5f - 1.0f;


    // calculate simple sine wave pattern

	float freq = 4.345f;
	float w = sinf(x*freq + time) * cosf(y*freq + time) * 4.5f;

	// write output vertex

    if(time<120)
    pos[y*width + x] = (uint8_t)(u*v+time)*987 % 256;
    if(time>120)
    pos[y*width + x] = (uint8_t)(w+u)*987 % 256;
}

void Lab2VideoGenerator::Generate(uint8_t*yuv)
{

	dim3 block(1, 1, 1);
	dim3 grid(W / block.x, H*1.5 / block.y, 1);
	simple_kernel <<< grid, block >>>(yuv, W, H,(impl->t));

	//int brightness1;
	//int brightness2;
	//brightness1=(rand()%255)+1;
	//brightness2=(rand()%255)+1;

	//int color;
	//color=(rand()%128)+1;

	//cudaMemset(yuv,          (impl->t)*brightness1/NFRAME, W*H/2);
	//cudaMemset(yuv+W*H/2,    (impl->t)*brightness2/NFRAME, W*H/2);
	//cudaMemset(yuv+W*H,      color, W*H/2);

	++(impl->t);
}

