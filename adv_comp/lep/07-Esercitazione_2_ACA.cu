
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <chrono>
#include <stdio.h>

using TimePoint = std::chrono::time_point<std::chrono::high_resolution_clock>;

void compute_elapsed_time(TimePoint start_time, double& elapsed_duration) {
    auto end_time = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> duration = end_time - start_time;

    elapsed_duration = duration.count();
}

__global__ void matMultKernel(float *c, const float *a, const float *b, int rows, int cols)
{
    int tid_c = blockIdx.x * blockDim.x + threadIdx.x;
    int tid_r = blockIdx.y * blockDim.y + threadIdx.y;

    if (tid_r < rows && tid_c < cols) {
        c[tid_r * cols + tid_c] = 0;
        float sum = 0;
        int i_a = 0;
        int i_b = 0;

        for (int i = 0; i < cols; i++) {
            i_a = tid_r * cols + i;
            i_b = i * cols + tid_c;
            sum += (a[i_a] * b[i_b]);
        }

        c[tid_r * cols + tid_c] = sum;
    }
}

typedef struct {
    int row;
    int col;
    float* data;
} Matrix;


void initialize_matrix(Matrix* mat, int rows, int cols, float init_val) {
    mat->row = rows;
    mat->col = cols;
    mat->data = (float*) malloc(sizeof(float) * rows * cols);
    for (int i = 0; i < rows * cols; i++) {
        //mat->data[i] = (int)(i / rows + 1) * init_val;
        mat->data[i] = init_val;
    }
}

void visualize_matrix(Matrix* mat) {
    int rows = mat->row;
    int cols = mat->col;
    
    for (int row = 0; row < rows; row++) {
        for (int col = 0; col < cols; col++) {
            printf("%f ", mat->data[row * rows + col]);
        }
        printf("\n");
    }
    printf("\n");
}

void serial_multiplication(Matrix* outputMat,  Matrix* matA, Matrix* matB) {
    int rows = outputMat->row;
    int cols = outputMat->col;

    for (int row = 0; row < rows; row++) {
        for (int col = 0; col < cols; col++) {
            float tmp = 0;
            for (int i = 0; i < cols; i++){
                tmp += (matA->data[row * rows + i] * matB->data[i * rows + col]);
            }
            outputMat->data[row * rows + col] = tmp;
        }
    }

}

bool check_errors(Matrix* matA, Matrix* matB, float tol) {
    int num_elements = matA->row * matA->col;
    float error_accumulator = 0.0;
    for (int i = 0; i < num_elements; i++) {
        error_accumulator += std::abs(matA->data[i] - matB->data[i]);
    }
    return error_accumulator <= tol;
}

cudaError_t matrixMultiplicationWithCuda(Matrix* c, const Matrix* a, const Matrix* b)
{
    printf("Parallel Execution start.\n");
    // Create cuda events to mesure preciselly the time for each parts
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    float milliseconds = 0;

    int rows = c->row;
    int cols = c->col;

    float* dev_matrix_a = 0;
    float* dev_matrix_b = 0;
    float* dev_matrix_c = 0;
    cudaError_t cudaStatus;


    cudaStatus = cudaSetDevice(0);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
        cudaFree(dev_matrix_a);
        cudaFree(dev_matrix_b);
        cudaFree(dev_matrix_c);
        return cudaStatus;

    }

    
    cudaMalloc((void**)&dev_matrix_c, rows * cols * sizeof(float));
    cudaMalloc((void**)&dev_matrix_a, rows * cols * sizeof(float));
    cudaMalloc((void**)&dev_matrix_b, rows * cols * sizeof(float));

    // Perform MemCopy #########################################################################
    cudaEventRecord(start);
    // Move data from Host -> Device
    cudaMemcpy(dev_matrix_a, a->data, rows * cols * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_matrix_b, b->data, rows * cols * sizeof(float), cudaMemcpyHostToDevice);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&milliseconds, start, stop);

    printf("[DEV]\tH2D Memory Transfer took: %f [s].\n", milliseconds / 1000);
    // ########################################################################################


    // Mesure Kernel execution time and Throughput ############################################
    cudaEventRecord(start);

    // Code implementation here

    dim3 numThreads(256, 1);
    int block_y = (rows + numThreads.y - 1) / numThreads.y;
    int block_x = (cols + numThreads.x - 1) / numThreads.x;
    dim3 blocks(block_x, block_y);


    matMultKernel << <blocks, numThreads >> > (dev_matrix_c,
                                               dev_matrix_a,
                                               dev_matrix_b,
                                               rows,
                                               cols);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&milliseconds, start, stop);
    printf("[DEV]\tKernel Execution took:    %f [s]\n", milliseconds / 1000);

    double throughput = (2.0 * rows * rows * rows) / (milliseconds / 1000.0);
    // #######################################################################################

    // Check for any errors launching the kernel
    cudaStatus = cudaGetLastError();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "[DEV]\taddKernel launch failed: %s\n", cudaGetErrorString(cudaStatus));
        cudaFree(dev_matrix_a);
        cudaFree(dev_matrix_b);
        cudaFree(dev_matrix_c);
        return cudaStatus;
    }

    cudaDeviceSynchronize();


    // Perform MemCopy #########################################################################
    cudaEventRecord(start);
    cudaMemcpy(c->data, dev_matrix_c, rows * cols * sizeof(float), cudaMemcpyDeviceToHost);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&milliseconds, start, stop);
    printf("[DEV]\tD2H Memory Transfer took: %f [s].\n", milliseconds/1000);


    // Compute bandwith = total bytes transfered / device 2 host time
    float bandwidth = (3 * rows * cols * sizeof(float)) / (milliseconds / 1000);
    printf("[DEV]\tBandwidth  %f [GB/s].\n", bandwidth/1e9);
    printf("[DEV]\tThroughput %f [GFLOP/s].\n", throughput / 1e9);

    printf("Parallel Execution ends.\n");


    cudaFree(dev_matrix_a);
    cudaFree(dev_matrix_b);
    cudaFree(dev_matrix_c);
    return cudaStatus;
}


int main(int argc, char * argv[])
{
    // Trick to force cold start
    cudaFree(0); // Try to comment it and recompile to see the difference
    // #########################

    int dim = 3;
    if (argc > 1) {
        dim = std::atoi(argv[1]);
        if (dim <= 1) {
            printf("Error. Dimension of the matrix must be grater than 1.");
            return 1;
        }
    }
    printf("--- Program start ---\n");
    printf("\nInitialize Matrices with dimension %d x %d.\n\n", dim, dim);

    // Time variabiles
    TimePoint start_time;
    double elapsed_time = 0;

    Matrix matrix_a;
    Matrix matrix_b;
    Matrix matrix_serial;
    Matrix matrix_parallel;

    // Inizializzation
    initialize_matrix(&matrix_a,        dim,dim, 1);
    initialize_matrix(&matrix_b,        dim,dim, -1);
    initialize_matrix(&matrix_serial,   dim,dim, 0);
    initialize_matrix(&matrix_parallel, dim,dim, 0);
    
    //visualize_matrix(&matrix_a);
    //visualize_matrix(&matrix_b);

    start_time = std::chrono::high_resolution_clock::now();
    serial_multiplication(&matrix_serial, &matrix_a, &matrix_b);
    compute_elapsed_time(start_time, elapsed_time);
    printf("--- Serial Matrix Multiplication took: %lf [s].\n", elapsed_time);

    start_time = std::chrono::high_resolution_clock::now();
    cudaError_t cudaStatus = matrixMultiplicationWithCuda(&matrix_parallel, &matrix_a, &matrix_b);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "matrixMultiplicationWithCuda failed!");
    }
    compute_elapsed_time(start_time, elapsed_time);
    printf("Parallel Matrix Multiplication took: %lf [s].\n", elapsed_time);

    if (dim < 5) {
        visualize_matrix(&matrix_serial);
        printf("\n");
        visualize_matrix(&matrix_parallel);
    }

    float tol = 0.001;
    bool check = check_errors(&matrix_parallel, &matrix_serial, tol);

    if (check) {
        printf("[Good] No errors between parallel and serial implementation.\n");
    }
    else {
        printf("[Bad] There are some errors between parallel and serial implementation.\n");
    }


    free(matrix_a.data       );
    free(matrix_b.data       );
    free(matrix_serial.data  );
    free(matrix_parallel.data);

    return 0;
}