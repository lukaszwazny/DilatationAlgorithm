using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Media.Imaging;

namespace OperacjeMorfologiczne
{
    class Converter
    {
        public static BitmapImage ByteToBitmapImage(byte[] array)
        {
            using (MemoryStream ms = new MemoryStream(array))
            {
                BitmapImage image = new BitmapImage();
                image.BeginInit();
                image.CacheOption = BitmapCacheOption.OnLoad;
                image.StreamSource = ms;
                image.EndInit();
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

        public static byte[] IntPtrToBytes(IntPtr pnt, int size)
        {

            byte[] bytes = new byte[size];
            Marshal.Copy(pnt, bytes, 0, size);

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
    }
}
