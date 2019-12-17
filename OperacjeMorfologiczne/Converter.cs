using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Runtime.ExceptionServices;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace OperacjeMorfologiczne
{
    class Converter
    {
        public static BitmapImage ByteToBitmapImage(byte[] array)
        {
            BitmapImage image = new BitmapImage();
            using (MemoryStream ms = new MemoryStream(array))
            {
                try
                {
                    image.BeginInit();
                    image.CacheOption = BitmapCacheOption.OnLoad;
                    image.DecodePixelWidth = 0;
                    image.StreamSource = ms;
                    image.EndInit();
                }
                catch (Exception exception)
                {
                    MessageBox.Show(exception.Message, exception.Source);
                }

                return image;
            }
        }

        public static byte[] BitmapImageToBytes(BitmapImage image)
        {
            byte[] imageBytes;
            JpegBitmapEncoder encoder = new JpegBitmapEncoder();
            encoder.Frames.Add(BitmapFrame.Create(image));
            using (MemoryStream ms = new MemoryStream())
            {
                encoder.Save(ms);
                imageBytes = ms.ToArray();
            }

            return imageBytes;
        }

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

        public static IntPtr BitmapImageToIntPtr(BitmapImage image) {
            byte[] imageBytes = Converter.BitmapImageToBytes(image);
            IntPtr pnt = Converter.ByteToIntPtr(imageBytes);
            return pnt;
        }

        public static BitmapImage IntPtrToBitmapImage(IntPtr ptr, int size)
        {
            byte[] imageBytes = Converter.IntPtrToBytes(ptr, size);
            BitmapImage image = Converter.ByteToBitmapImage(imageBytes);
            return image;
        }

        public static int GetBytesSize(byte[] array)
        {
            return Marshal.SizeOf(array[0]) * array.Length;
        }

        public static double GetRatio(BitmapImage image)
        {
            double pixelWidth = image.PixelWidth;
            double pixelHeight = image.PixelHeight;
            return pixelWidth / pixelHeight;
        }

        public static int GetWidth(BitmapImage image)
        {
            byte[] array = BitmapImageToBytes(image);
            double ratio = GetRatio(image);
            double width = Math.Sqrt(array.Length * ratio);
            return (int) width;
        }

        public static int GetHeight(BitmapImage image)
        {
            byte[] array = BitmapImageToBytes(image);
            double ratio = GetRatio(image);
            double height = Math.Sqrt(array.Length / ratio);
            return (int)height;
        }

        public static BitmapImage BitmapSourceToBitmapImage(BitmapSource source)
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
        }

    }
}
