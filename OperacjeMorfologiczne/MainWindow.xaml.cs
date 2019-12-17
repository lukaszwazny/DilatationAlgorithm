using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Security.RightsManagement;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Markup.Localizer;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using Microsoft.Win32;
using Path = System.IO.Path;

namespace OperacjeMorfologiczne
{
    /// <summary>
    /// Logika interakcji dla klasy MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        private BitmapImage _originalImage;
        private BitmapImage _transformedImage;

        [DllImport(@"D:\studia\JAproj\OperacjeMorfologiczne\c_function\CFunction.dll", CallingConvention = CallingConvention.Cdecl)]
        private static extern IntPtr dilatation(IntPtr image, int imageWidth, int imageHeight, int elemWidth, int elemHeight, int centrPntX, int centrPntY);

        public MainWindow()
        {
            InitializeComponent();
            threads.Text = Environment.ProcessorCount.ToString();
        }

        private void DodajObraz_OnClick(object sender, RoutedEventArgs e)
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();
            openFileDialog.ShowDialog();
            _originalImage = new BitmapImage(new Uri(openFileDialog.FileName));
            OriginalImage.Source = _originalImage;
        }

        private void TransformObraz_OnClick(object sender, RoutedEventArgs e)
        {
            //preparing image
            byte[] imageBytes = Converter.BitmapImageToBytes(_originalImage);
            int size = Converter.GetBytesSize(imageBytes);
            IntPtr imagePtr = Converter.BitmapImageToIntPtr(_originalImage);
            int width = Converter.GetWidth(_originalImage);
            int height = Converter.GetHeight(_originalImage);
            //pomiar czasu
            Stopwatch watch = new Stopwatch();
            watch.Start();
            //operation
            IntPtr transformedIntPtrBytes = dilatation(imagePtr, width, height, 3, 3, 1, 1); 
            watch.Stop();
            speed.Text = ((((double)watch.ElapsedTicks)/((double)Stopwatch.Frequency))*1000*1000) + " \u00b5s";
            //displaying
            BitmapImage transformedImage = Converter.IntPtrToBitmapImage(transformedIntPtrBytes, size);
            _transformedImage = transformedImage;
//            BitmapSource transformedImage = MakeBitmapSource.FromNativePointer(transformedIntPtrBytes,
//                width, height, 1);
//            _transformedImage = Converter.BitmapSourceToBitmapImage(transformedImage);
            TranformedImage.Source = transformedImage;
            
        }

        private void Save_OnClick(object sender, RoutedEventArgs e)
        {
            SaveFileDialog saveFileDialog = new SaveFileDialog
            {
                Filter = "PNG Image|*.png|JPeg Image|*.jpg|Bitmap Image|*.bmp|Gif Image|*.gif"
            };
            saveFileDialog.ShowDialog();
            Uri uri = new Uri(saveFileDialog.FileName);
            SaveImage(_transformedImage, uri.AbsolutePath);

        }

        public static void SaveImage(BitmapImage image, string filePath)
        {
            BitmapEncoder encoder = new PngBitmapEncoder();
            encoder.Frames.Add(BitmapFrame.Create(image));

            using (var fileStream = new System.IO.FileStream(filePath, System.IO.FileMode.Create))
            {
                encoder.Save(fileStream);
            }
        }

    }
}
