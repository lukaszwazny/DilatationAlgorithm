#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#define EXPORT __declspec(dllexport)

EXPORT unsigned char* dilatationC(const unsigned char* image, int imageWidth, int imageHeight, int elemWidth, int elemHeight, int centrPntX, int centrPntY);