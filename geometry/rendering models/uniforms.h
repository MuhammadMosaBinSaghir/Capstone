#ifndef uniforms_h
#define uniforms_h

#import <simd/simd.h>

typedef struct {
  matrix_float4x4 model;
  matrix_float4x4 view;
  matrix_float4x4 projection;
} Uniforms;

#endif
