#include "c_function.h"

EXPORT unsigned char* dilatationC(const unsigned char* image, unsigned char* buffer, int imageWidth, int imageHeight, int elemWidth, int elemHeight, int centrPntX, int centrPntY){
    
    //unsigned char* buffer = (unsigned char*)malloc(imageHeight*imageWidth * sizeof(unsigned char));

    //kopiuję dane z image do bufora
	for (int j = 0; j < imageHeight; j++)
	{
		for (int i = 0; i < imageWidth; i++)
		{
			buffer[i + j * imageWidth] = image[i + j * imageWidth];
		}
	}

	for (int h = 0; h < imageHeight; h++)
	{
		for (int w = 0; w < imageWidth; w++)
		{
			//sprawdzam, czy w obrebie elementu strukturalnego sa piksele o wartosci < 10, jeżeli tak - piksel o wsp. w i h,
			//przyjmuje wartość 0
			if (h < centrPntY && w < centrPntX)
			{
				int czy_jest = 0;
				for (int j = 0; j < elemHeight - h && h + j < imageHeight && !czy_jest; j++)
				{
					for (int i = 0; i < elemWidth - w && w + i - centrPntX < imageWidth && !czy_jest; i++)
					{
						if (image[i + j * imageWidth] < 10)
						{
							czy_jest = 1;
							buffer[w + h * imageWidth] = 0;
						}
					}
				}
			}
			else
			{
				if (h < centrPntY)
				{
					int czy_jest = 0;
					for (int j = 0; j < elemHeight + h - centrPntY && h + j < imageHeight && !czy_jest; j++)
					{
						for (int i = 0; i < elemWidth && w + i - centrPntX < imageWidth && !czy_jest; i++)
						{
							if (image[w - centrPntX + i + j * imageWidth] < 10)
							{
								czy_jest = 1;
								buffer[w + h * imageWidth] = 0;
							}
						}
					}
				}
				else if (w < centrPntX)
				{
					int czy_jest = 0;
					for (int j = 0; j < elemHeight && h + j < imageHeight && !czy_jest; j++)
					{
						for (int i = 0; i < elemWidth + w - centrPntX && w + i - centrPntX < imageWidth && !czy_jest; i++)
						{
							if (image[h * imageWidth - imageWidth * centrPntY + i + j * imageWidth] < 10)
							{
								czy_jest = 1;
								buffer[w + h * imageWidth] = 0;
							}
						}
					}
				}
				else
				{
					int czy_jest = 0;
					for (int j = 0; j < elemHeight && h + j < imageHeight && !czy_jest; j++)
					{
						for (int i = 0; i < elemWidth && w + i - centrPntX < imageWidth && !czy_jest; i++)
						{
							if (image[w + h * imageWidth - imageWidth * centrPntY - centrPntX + i + j * imageWidth] < 10)
							{
								czy_jest = 1;
								buffer[w + h * imageWidth] = 0;
							}
						}
					}
				}
			}
		}
	}
	return buffer;
}


/*
 unsigned char* buffer = (unsigned char*)malloc(imageWidth*imageWidth * sizeof(unsigned char));

    //kopiuję dane z plik_we do bufora
	for (int j = 0; j < imageHeight; j++)
	{
		for (int i = 0; i < imageWidth; i++)
		{
			buffer[i + j * imageWidth] = image[i + j * imageWidth];
		}
	}

	for (int h = 0; h < imageHeight; h++)
	{
		for (int w = 0; w < imageWidth; w++)
		{
			//sprawdzam, czy w obrebie elementu strukturalnego sa piksele o wartosci < 10, jeżeli tak - piksel o wsp. w i h,
			//przyjmuje wartość 0
			if (h <= centrPntY && w <= centrPntX)
			{
				int czy_jest = 0;
				for (int j = 0; j < elemHeight - h && h + j < imageHeight && !czy_jest; j++)
				{
					for (int i = 0; i < elemWidth - w && w + i < imageWidth && !czy_jest; i++)
					{
						if (image[i + j * imageWidth] < 10)
						{
							czy_jest = 1;
							buffer[w + h * imageWidth] = 0;
						}
					}
				}
			}
			else
			{
				if (h <= centrPntY)
				{
					int czy_jest = 0;
					for (int j = 0; j < elemHeight - h && h + j < imageHeight && !czy_jest; j++)
					{
						for (int i = 0; i < elemWidth && w + i < imageWidth && !czy_jest; i++)
						{
							if (image[w - centrPntX + i + j * imageWidth] < 10)
							{
								czy_jest = 1;
								buffer[w + h * imageWidth] = 0;
							}
						}
					}
				}
				else if (w <= centrPntX)
				{
					int czy_jest = 0;
					for (int j = 0; j < elemHeight && h + j < imageHeight && !czy_jest; j++)
					{
						for (int i = 0; i < elemWidth - w && w + i < imageWidth && !czy_jest; i++)
						{
							if (image[h * imageWidth - imageWidth * centrPntY + i + j * imageWidth] < 10)
							{
								czy_jest = 1;
								buffer[w + h * imageWidth] = 0;
							}
						}
					}
				}
				else
				{
					int czy_jest = 0;
					for (int j = 0; j < elemHeight && h + j < imageHeight && !czy_jest; j++)
					{
						for (int i = 0; i < elemWidth && w + i < imageWidth && !czy_jest; i++)
						{
							if (image[w + h * imageWidth - imageWidth * centrPntY - centrPntX + i + j * imageWidth] < 10)
							{
								czy_jest = 1;
								buffer[w + h * imageWidth] = 0;
							}
						}
					}
				}
			}
		}
	}
	return buffer;*/
