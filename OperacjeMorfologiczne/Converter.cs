using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Runtime.ExceptionServices;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Interop;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using Color = System.Drawing.Color;
using PixelFormat = System.Drawing.Imaging.PixelFormat;

namespace OperacjeMorfologiczne
{
    class Converter
    {
        

        public static IntPtr ByteToIntPtr(byte[] array)
        {
            int size = GetBytesSize(array);

            IntPtr pnt = Marshal.AllocHGlobal(size);

            Marshal.Copy(array, 0, pnt, array.Length);

            return pnt;
        }

        [HandleProcessCorruptedStateExceptions]
        public static byte[] IntPtrToBytes(IntPtr pnt, int size)
        {
            byte[] bytes = new byte[size];
            try
            {
                Marshal.Copy(pnt, bytes, 0, size);
            }
            catch (System.AccessViolationException exception)
            {
                MessageBox.Show(exception.Message, exception.Source);
            }

            return bytes;
        }

        internal static int GetSize(BitmapImage originalImage)
        {
            Bitmap bmp = BitmapImage2Bitmap(originalImage);
            byte[] array = BitmapToBytes(bmp);
            return GetBytesSize(array);
        }


        public static int GetBytesSize(byte[] array)
        {
            return Marshal.SizeOf(array[0]) * array.Length;
        }


        public static Bitmap BitmapImage2Bitmap(BitmapImage bitmapImage)
        {
            using (MemoryStream outStream = new MemoryStream())
            {
                BitmapEncoder enc = new BmpBitmapEncoder();
                enc.Frames.Add(BitmapFrame.Create(bitmapImage));
                enc.Save(outStream);
                Bitmap bitmap = new Bitmap(outStream);

                return new Bitmap(bitmap);
            }
        }


        


        public static BitmapImage Bitmap2BitmapImage(Bitmap bitmap)
        {
            using (var memory = new MemoryStream())
            {
                bitmap.Save(memory, ImageFormat.Png);
                memory.Position = 0;

                var bitmapImage = new BitmapImage();
                bitmapImage.BeginInit();
                bitmapImage.StreamSource = memory;
                bitmapImage.CacheOption = BitmapCacheOption.OnLoad;
                bitmapImage.EndInit();
                bitmapImage.Freeze();

                return bitmapImage;
            }
        }

        public static byte[] BitmapToBytes(Bitmap bmp)
        {
            byte[] array = new byte[bmp.Width * bmp.Height];

            for (int y = 0; y < bmp.Height; y++)
            {
                for (int x = 0; x < bmp.Width; x++)
                {
                    byte average = (byte) ((bmp.GetPixel(x, y).R + bmp.GetPixel(x, y).G + bmp.GetPixel(x, y).B) / 3);
                    if (average > 125)
                        array[y * bmp.Width + x] = 255;
                    else
                        array[y * bmp.Width + x] = 0;
                }
            }

            return array;
        }

        public static byte[] PadLines(byte[] bytes, int rows, int columns)
        {
            int currentStride = columns; // 3
            int newStride = (columns/4)*4+4; // 4
            //int newStride = columns;
            byte[] newBytes = new byte[newStride * rows];
            for (int i = 0; i < rows; i++)
                Buffer.BlockCopy(bytes, currentStride * i, newBytes, newStride * i, currentStride);
            return newBytes;
        }

        public static Bitmap BytesToBitmap(byte[] imageData, int imageWidth, int imageHeight)
        {
            int columns = imageWidth;
            int rows = imageHeight;
            int stride = (columns / 4) * 4 + 4;
            byte[] newbytes = PadLines(imageData, rows, columns);


            Bitmap im = new Bitmap(columns, rows, stride,
                PixelFormat.Format8bppIndexed,
                Marshal.UnsafeAddrOfPinnedArrayElement(newbytes, 0));
            //Change palette of 8bit indexed BITMAP. Make r(i)=g(i)=b(i)
            ColorPalette _palette = im.Palette;
            Color[] _entries = _palette.Entries;
            for (int i = 0; i < 256; i++)
            {
                Color b = new Color();
                b = Color.FromArgb((byte) i, (byte) i, (byte) i);
                _entries[i] = b;
            }

            im.Palette = _palette;
            return im;
        }

        public static IntPtr BitmapImageToIntPtr(BitmapImage image)
        {
            Bitmap bmp = BitmapImage2Bitmap(image);
            byte[] imageBytes = Converter.BitmapToBytes(bmp);
            IntPtr pnt = Converter.ByteToIntPtr(imageBytes);
            return pnt;
        }

        public static BitmapImage IntPtrToBitmapImage(IntPtr ptr, int size, int imageWidth, int imageHeight)
        {
            byte[] imageData = Converter.IntPtrToBytes(ptr, size);
            Bitmap bmp = Converter.BytesToBitmap(imageData, imageWidth, imageHeight);
            BitmapImage img = Converter.Bitmap2BitmapImage(bmp);
            return img;
        }
        /*public static int GetDataSize(byte[] array)
        {
            array = JPEG.GetData(array);
            return Marshal.SizeOf(array[0]) * array.Length;
        }

        public static double GetRatio(BitmapImage image)
        {
            double pixelWidth = image.PixelWidth;
            double pixelHeight = image.PixelHeight;
            return pixelWidth / pixelHeight;
        }*/

        /*public static int GetWidth(BitmapImage image)
        {
            byte[] array = BitmapImageToBytes(image);
            array = JPEG.GetData(array);
            double ratio = GetRatio(image);
            double width = Math.Sqrt(array.Length * ratio);
            return (int) width;
        }

        public static int GetHeight(BitmapImage image)
        {
            byte[] array = BitmapImageToBytes(image);
            array = JPEG.GetData(array);
            double ratio = GetRatio(image);
            double height = Math.Sqrt(array.Length / ratio);
            return (int)height;
        }*/

        /*public static BitmapImage BitmapSourceToBitmapImage(BitmapSource source)
        {

            JpegBitmapEncoder encoder = new JpegBitmapEncoder();
            MemoryStream memoryStream = new MemoryStream();
            BitmapImage bImg = new BitmapImage();

            encoder.Frames.Add(BitmapFrame.Create(source));
            encoder.Save(memoryStream);

            memoryStream.Position = 0;
            bImg.BeginInit();
            bImg.StreamSource = memoryStream;
            bImg.EndInit();

            memoryStream.Close();

            return bImg;
        }*/

        /*public static byte[] BitmapToBytes1(Bitmap bmp)
        {

            // Lock the bitmap's bits. 
            Rectangle rect = new Rectangle(0, 0, bmp.Width, bmp.Height);
            System.Drawing.Imaging.BitmapData bmpData =
                bmp.LockBits(rect, System.Drawing.Imaging.ImageLockMode.ReadOnly,
                    bmp.PixelFormat);

            // Get the address of the first line.
            IntPtr ptr = bmpData.Scan0;

            // Declare an array to hold the bytes of the bitmap.
            int bytes = bmpData.Stride * bmp.Height;
            byte[] rgbValues = new byte[bytes];

            // Copy the RGB values into the array.
            System.Runtime.InteropServices.Marshal.Copy(ptr, rgbValues, 0, bytes); bmp.UnlockBits(bmpData);

            return rgbValues;
        }*/

        /*public static Bitmap BytesToBitmap1(byte[] imageData, int imageWidth, int imageHeight, PixelFormat pxlFormat)
        { 

            int columns = imageWidth;
            int rows = imageHeight;
            int stride = columns;
            byte[] newbytes = PadLines(imageData, rows, columns);

            Bitmap im = new Bitmap(columns, rows, stride,
                pxlFormat,
                Marshal.UnsafeAddrOfPinnedArrayElement(newbytes, 0));
            return im;
        }*/

        /*public static byte[] GetHeader(BitmapImage image)
        {
            byte[] imageBytes = BitmapImageToBytes(image);
            return JPEG.GetHeader(imageBytes);
        }*/

        /*public static byte[] GetByteRange(byte[] array, int first, int second)
        {
            int n = second - first + 1;
            var result = new byte[n];
            for (int i = 0; i < n; i++)
            {
                result[i] = array[i + first];
            }
            return result;
        }*/

        /*public static byte[] ConcatenateBytes(byte[] first, byte[] second)
        {
            byte[] ret = new byte[first.Length + second.Length];
            first.CopyTo(ret, 0);
            second.CopyTo(ret, first.Length);
            return ret;
        }*/

        /*[System.Runtime.InteropServices.DllImport("gdi32.dll")]
        public static extern bool DeleteObject(IntPtr hObject);

        public static BitmapImage Bitmap2BitmapImage(Bitmap bitmap)
        {
            IntPtr hBitmap = bitmap.GetHbitmap();
            BitmapImage retval;

            try
            {
                retval = (BitmapImage)Imaging.CreateBitmapSourceFromHBitmap(
                    hBitmap,
                    IntPtr.Zero,
                    Int32Rect.Empty,
                    BitmapSizeOptions.FromEmptyOptions());
            }
            finally
            {
                DeleteObject(hBitmap);
            }

            return retval;
        }*/

        /*public static BitmapImage ByteToBitmapImage(byte[] array)
        {
            BitmapImage image = new BitmapImage();
            using (MemoryStream ms = new MemoryStream(array))
            {
                try
                {
                    image.BeginInit();
                    image.CacheOption = BitmapCacheOption.OnLoad;
                    image.StreamSource = ms;
                    image.EndInit();
                }
                catch (Exception exception)
                {
                    MessageBox.Show(exception.Message, exception.Source);
                }

                return image;
            }
        }*/

        /*public static byte[] BitmapImageToBytes(BitmapImage image)
        {
            byte[] imageBytes;
            BmpBitmapEncoder encoder = new BmpBitmapEncoder();
            encoder.Frames.Add(BitmapFrame.Create(image));
            using (MemoryStream ms = new MemoryStream())
            {
                encoder.Save(ms);
                imageBytes = ms.ToArray();
            }

            return imageBytes;
        }*/
    }
}