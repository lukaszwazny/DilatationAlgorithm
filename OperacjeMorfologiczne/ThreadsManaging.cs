using System;
using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Media.Imaging;

namespace OperacjeMorfologiczne
{
    class ThreadsManaging
    {
        private List<Thread> Threads;
        private List<IntPtr> transformedImages;
        private static Params parameters;
        private List<IntPtrWithSize> imagesIntPtr;
        private List<ImageWithIndex> imWithIndices;

        [DllImport(@"CFunction.dll", CallingConvention = CallingConvention.Cdecl)]
        private static extern IntPtr dilatationC(IntPtr image, IntPtr transImage, int imageWidth, int imageHeight, int elemWidth, int elemHeight, 
            int centrPntX, int centrPntY);

        [DllImport(@"asm_function.dll")]
        private static extern IntPtr dilatationAsm(IntPtr image, IntPtr transImage, int imageWidth, int imageHeight, int elemWidth, int elemHeight, 
            int centrPntX, int centrPntY);


        public struct IntPtrWithSize
        {
            public IntPtrWithSize(IntPtr ptr, int size, int width, int extraWidth) : this()
            {
                this.ptr = ptr;
                this.size = size;
                this.width = width;
                this.extraWidth = extraWidth;
            }

            private IntPtr ptr;
            private int size;
            private int width;
            private int extraWidth;

            public IntPtr GetPtr()
            {
                return this.ptr;
            }

            public int GetSize()
            {
                return this.size;
            }

            public int GetWidth()
            {
                return this.width;
            }

            public int GetExtraWidth()
            {
                return this.extraWidth;
            }
        }

        public void performOperation(Object image)
        {
            try
            {
                ImageWithIndex im = (ImageWithIndex) image;
                //IntPtr transformedImage = Marshal.AllocHGlobal(im.image);
                //c function
                if (!(bool)parameters.Function)
                {
                    dilatationC(im.image, this.transformedImages[im.index], im.extraWidth, parameters.ImageHeight,
                    parameters.ElemWidth, parameters.ElemHeight, parameters.CentrPntX, parameters.CentrPntY);
                }
                //asm function
                else
                {
                    dilatationAsm(im.image, this.transformedImages[im.index], im.extraWidth, parameters.ImageHeight,
                    parameters.ElemWidth, parameters.ElemHeight, parameters.CentrPntX, parameters.CentrPntY);
                }
                
                
                Marshal.FreeHGlobal(im.image);
            }
            catch (AccessViolationException error)
            {
                MessageBox.Show("Wątek nr " + Thread.CurrentThread.Name + ": " + error.Message, error.GetType().ToString());
            }
            catch (Exception XD)
            {
                MessageBox.Show("Wątek nr " + Thread.CurrentThread.Name + ": " + XD.Message, XD.GetType().ToString());
            }
            

        }

        public static List<IntPtrWithSize> SplitImage(BitmapImage image, int n)
        {
            int width = image.PixelWidth / n;
            Bitmap bmpImage = Converter.BitmapImage2Bitmap(image);
            List<IntPtrWithSize> result = new List<IntPtrWithSize>();
            for (int i = 0; i < n; i++){
                int widthOfThisPart = width;
                if (i == n - 1)
                {
                    int extraWidth = image.PixelWidth - (width * n);
                    widthOfThisPart += extraWidth;
                }

                //szerokość bez dodatkowych kolumn
                int orgWidthOfThisPart = widthOfThisPart;

                //add columns from adjacent parts (just for good result at the ends of part)
                int leftAdd = parameters.CentrPntX;
                int rightAdd = parameters.ElemWidth - parameters.CentrPntX - 1;
                if (i == 0)
                {
                    widthOfThisPart += rightAdd;
                }
                else if (i == n - 1)
                {
                    widthOfThisPart += leftAdd;
                }
                else
                {
                    widthOfThisPart += rightAdd;
                    widthOfThisPart += leftAdd;
                }

                //zabezpieczenie przed przekroczeniem zakresu z prawej strony
                if(Math.Max(i * width - leftAdd, 0) + widthOfThisPart > image.PixelWidth)
                {
                    widthOfThisPart = image.PixelWidth - Math.Max(i * width - leftAdd, 0);
                }

                Rectangle cropArea;
                if (i == 0)
                    cropArea = new Rectangle(0, 0, widthOfThisPart, image.PixelHeight);
                else
                    cropArea = new Rectangle(Math.Max(i * width - leftAdd, 0), 0, widthOfThisPart, image.PixelHeight);

                Bitmap bmpCrop = bmpImage.Clone(cropArea,
                    bmpImage.PixelFormat);

                byte[] bmpBytes = Converter.BitmapToBytes(bmpCrop);
                int size = Converter.GetBytesSize(bmpBytes);
                IntPtr cropIntPtr = Converter.ByteToIntPtr(Converter.BitmapToBytes(bmpCrop));

                IntPtrWithSize intPtrWithSize = new IntPtrWithSize(cropIntPtr, size, orgWidthOfThisPart, widthOfThisPart);
                result.Add(intPtrWithSize);
            }
            return result;
        }

        public static BitmapImage MergeImage(List<IntPtrWithSize> images, int heightOfOneImage) {
            List<byte[]> imageBitmapsBytes = new List<byte[]>();
            int width = 0;
            foreach (var image in images)
            {
                byte[] imageBytes = Converter.IntPtrToBytes(image.GetPtr(), image.GetSize());
                imageBitmapsBytes.Add(imageBytes);
                width += image.GetWidth();
            }

            
            byte[] finalImageBytes = new byte[heightOfOneImage * width];

            for (int i = 0; i < heightOfOneImage; i++) {
                for(int j = 0; j < images.Count; j++)
                {
                    Buffer.BlockCopy(imageBitmapsBytes[j], (j == 0 ? (images[j].GetExtraWidth() * i) : ((images[j].GetExtraWidth() * i) + parameters.CentrPntX)), finalImageBytes, width * i + j * images[0].GetWidth(), 
                        images[j].GetWidth());
                }
            }
            
            Bitmap bitmapImage = Converter.BytesToBitmap(finalImageBytes, width, heightOfOneImage);

            return Converter.Bitmap2BitmapImage(bitmapImage);
        }

        //function: 0 for C, 1 for Asm
        public ThreadsManaging(BitmapImage image, Params _parameters)
        {
            this.Threads = new List<Thread>();
            this.transformedImages = new List<IntPtr>();
            parameters = _parameters;
            this.imagesIntPtr = SplitImage(image, parameters.NrOfThreads);
            this.imWithIndices = new List<ImageWithIndex>();
            for (int i = 0; i < parameters.NrOfThreads; i++)
            {
                unsafe
                {
                    transformedImages.Add(Marshal.AllocHGlobal(parameters.ImageHeight*imagesIntPtr[i].GetExtraWidth()));
                }
                imWithIndices.Add(new ImageWithIndex(imagesIntPtr[i].GetPtr(), i, imagesIntPtr[i].GetWidth(), imagesIntPtr[i].GetExtraWidth()));
                Thread t = new Thread(performOperation)
                {
                    Name = "" + i
                };
                Threads.Add(t);
            }

        }

        public void start() {
            for (int i = 0; i < parameters.NrOfThreads; i++) {
                Threads[i].Start(imWithIndices[i]);
            }
            for (int i = 0; i < parameters.NrOfThreads; i++) {
                Threads[i].Join();
            }
        }

        public BitmapImage GetResult()
        {
            List<IntPtrWithSize> list = new List<IntPtrWithSize>();
            for (int i = 0; i < transformedImages.Count; i++)
            {
                list.Add(new IntPtrWithSize(transformedImages[i], imagesIntPtr[i].GetSize(), imagesIntPtr[i].GetWidth(), imagesIntPtr[i].GetExtraWidth()));
            }

            return MergeImage(list, parameters.ImageHeight);
        }

        struct ImageWithIndex
        {
            public IntPtr image;
            public int index;
            public int width;
            public int extraWidth;

            public ImageWithIndex(IntPtr image, int index, int width, int extraWidth)
            {
                this.image = image;
                this.index = index;
                this.width = width;
                this.extraWidth = extraWidth;
            }
        }
    }
}
