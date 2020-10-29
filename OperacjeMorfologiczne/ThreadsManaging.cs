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
        private Params parameters;
        private List<IntPtrWithSize> imagesIntPtr;
        private List<ImageWithIndex> imWithIndices;

        [DllImport(@"D:\studia\JAproj\OperacjeMorfologiczne\c_function\CFunction.dll", CallingConvention = CallingConvention.Cdecl)]
        private static extern IntPtr dilatation(IntPtr image, int imageWidth, int imageHeight, int elemWidth, int elemHeight, int centrPntX, int centrPntY);


        public struct IntPtrWithSize
        {
            public IntPtrWithSize(IntPtr ptr, int size, int width) : this()
            {
                this.ptr = ptr;
                this.size = size;
                this.width = width;
            }

            private IntPtr ptr;
            private int size;
            private int width;

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
        }

        public void performOperation(Object image)
        {
            try
            {
                ImageWithIndex im = (ImageWithIndex) image;
                //IntPtr transformedImage = Marshal.AllocHGlobal(im.image);
                IntPtr transformedImage = dilatation(im.image, im.width, parameters.ImageHeight,
                    parameters.ElemWidth, parameters.ElemHeight, parameters.CentrPntX, parameters.CentrPntY);
                this.transformedImages[im.index] = transformedImage;
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
            for (int i = 0; i < n; i++)
            {
                int widthOfThisPart = width;
                if (i == n - 1)
                {
                    int extraWidth = image.PixelWidth - (width * n);
                    widthOfThisPart += extraWidth;
                }
                Rectangle cropArea = new Rectangle(0 + i * width, 0, widthOfThisPart, image.PixelHeight);

                Bitmap bmpCrop = bmpImage.Clone(cropArea,
                    bmpImage.PixelFormat);

                byte[] bmpBytes = Converter.BitmapToBytes(bmpCrop);
                int size = Converter.GetBytesSize(bmpBytes);
                IntPtr cropIntPtr = Converter.ByteToIntPtr(Converter.BitmapToBytes(bmpCrop));

                IntPtrWithSize intPtrWithSize = new IntPtrWithSize(cropIntPtr, size, widthOfThisPart);
                result.Add(intPtrWithSize);
            }

            return result;

        }

        public static BitmapImage MergeImage(List<IntPtrWithSize> images, int heightOfOneImage)
        {
            List<byte[]> imageBitmapsBytes = new List<byte[]>();
            int width = 0;
            foreach (var image in images)
            {
                byte[] imageBytes = Converter.IntPtrToBytes(image.GetPtr(), image.GetSize());
                imageBitmapsBytes.Add(imageBytes);
                width += image.GetWidth();
            }

            
            byte[] finalImageBytes = new byte[heightOfOneImage * width];

            for (int i = 0; i < heightOfOneImage; i++)
            {
                for(int j = 0; j < images.Count; j++)
                {
                    Buffer.BlockCopy(imageBitmapsBytes[j], images[j].GetWidth() * i, finalImageBytes, width * i + j * images[0].GetWidth(), images[j].GetWidth());
                }
            }
            
            Bitmap bitmapImage = Converter.BytesToBitmap(finalImageBytes, width, heightOfOneImage);

            return Converter.Bitmap2BitmapImage(bitmapImage);

        }

        //function: 0 for C, 1 for Asm
        public ThreadsManaging(BitmapImage image, Params parameters)
        {
            this.Threads = new List<Thread>();
            this.transformedImages = new List<IntPtr>();
            this.parameters = parameters;
            this.imagesIntPtr = SplitImage(image, parameters.NrOfThreads);
            this.imWithIndices = new List<ImageWithIndex>();
            for (int i = 0; i < parameters.NrOfThreads; i++)
            {
                unsafe
                {
                    transformedImages.Add(new IntPtr(null));
                }
                imWithIndices.Add(new ImageWithIndex(imagesIntPtr[i].GetPtr(), i, imagesIntPtr[i].GetWidth()));
                Thread t = new Thread(performOperation)
                {
                    Name = "" + i
                };
                Threads.Add(t);
            }

        }

        public void start()
        {
            for (int i = 0; i < parameters.NrOfThreads; i++)
            {
                Threads[i].Start(imWithIndices[i]);
            }
            for (int i = 0; i < parameters.NrOfThreads; i++)
            {
                Threads[i].Join();
            }
        }

        public BitmapImage GetResult()
        {
            List<IntPtrWithSize> list = new List<IntPtrWithSize>();
            for (int i = 0; i < transformedImages.Count; i++)
            {
                list.Add(new IntPtrWithSize(transformedImages[i], imagesIntPtr[i].GetSize(), imagesIntPtr[i].GetWidth()));
            }

            return MergeImage(list, parameters.ImageHeight);
        }

        struct ImageWithIndex
        {
            public IntPtr image;
            public int index;
            public int width;

            public ImageWithIndex(IntPtr image, int index, int width)
            {
                this.image = image;
                this.index = index;
                this.width = width;
            }
        }
    }
}
