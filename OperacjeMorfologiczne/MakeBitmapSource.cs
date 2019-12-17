using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace OperacjeMorfologiczne
{
    class MakeBitmapSource
    {
        [DllImport("kernel32.dll", EntryPoint = "RtlMoveMemory")]
        public static extern void CopyMemory(IntPtr Destination, IntPtr Source, uint Length);



        public static BitmapSource FromNativePointer(IntPtr pData, int w, int h, int ch)
        {
            PixelFormat format = PixelFormats.Default;

            if (ch == 1) format = PixelFormats.Gray8; //grey scale image 0-255
            if (ch == 3) format = PixelFormats.Bgr24; //RGB
            if (ch == 4) format = PixelFormats.Bgr32; //RGB + alpha


            WriteableBitmap wbm = new WriteableBitmap(w, h, 1, 1, format, null);
            CopyMemory(wbm.BackBuffer, pData, (uint)(w * h * ch));

            wbm.Lock();
            wbm.AddDirtyRect(new Int32Rect(0, 0, wbm.PixelWidth, wbm.PixelHeight));
            wbm.Unlock();

            return wbm;
        }

        public static BitmapSource FromArray(byte[] data, int w, int h, int ch)
        {
            PixelFormat format = PixelFormats.Default;

            if (ch == 1) format = PixelFormats.Gray8; //grey scale image 0-255
            if (ch == 3) format = PixelFormats.Bgr24; //RGB
            if (ch == 4) format = PixelFormats.Bgr32; //RGB + alpha


            WriteableBitmap wbm = new WriteableBitmap(w, h, 96, 96, format, null);
            wbm.WritePixels(new Int32Rect(0, 0, w, h), data, ch * w, 0);

            return wbm;
        }
    }
}
