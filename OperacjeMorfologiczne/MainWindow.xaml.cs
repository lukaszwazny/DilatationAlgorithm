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
using System.Drawing;
using Color = System.Drawing.Color;
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



        public MainWindow()
        {
            InitializeComponent();
            threads.Text = Environment.ProcessorCount.ToString();
            Threads.Text = Environment.ProcessorCount.ToString();
        }

        private void DodajObraz_OnClick(object sender, RoutedEventArgs e)
        {
            try
            {
                OpenFileDialog openFileDialog = new OpenFileDialog();
                openFileDialog.ShowDialog();
                _originalImage = new BitmapImage(new Uri(openFileDialog.FileName));
                OriginalImage.Source = _originalImage;
            }
            catch (Exception XD)
            {
                MessageBox.Show(XD.Message, XD.GetType().ToString());
            }
            
        }

        private void TransformObraz_OnClick(object sender, RoutedEventArgs e)
        {
            try
            {
                //validation
                new Validate(Int32.Parse(ElemWidth.Text), Int32.Parse(ElemHeight.Text), Int32.Parse(CentrPntX.Text), Int32.Parse(CentrPntY.Text)).validate();
                //preparing image
                //byte[] imageBytes = Converter.BitmapImageToBytes(_originalImage);
                //            Bitmap bitmap = Converter.BitmapImage2Bitmap(_originalImage);
                //            byte[] imageBytes = Converter.BitmapToBytes(bitmap);
                //            byte[] imageHeader = Converter.GetHeader(_originalImage);
                int size = Converter.GetSize(_originalImage);
                int width = _originalImage.PixelWidth;
                int height = _originalImage.PixelHeight;
                //            IntPtr imagePtr = Converter.BitmapImageToIntPtr(_originalImage);

                Params parameters = new Params(
                    width,
                    height,
                    Int32.Parse(ElemWidth.Text),
                    Int32.Parse(ElemHeight.Text),
                    Int32.Parse(CentrPntX.Text),
                    Int32.Parse(CentrPntY.Text),
                    Int32.Parse(Threads.Text),
                    AsmButton.IsChecked
                );


                //sprawdzenie rozdzielenia i połączenia od razu
                /*List<ThreadsManaging.IntPtrWithSize> intPtrs = ThreadsManaging.SplitImage(_originalImage, Int32.Parse(Threads.Text));
                BitmapImage hejBitmapImage = ThreadsManaging.MergeImage(intPtrs, height);
                //IntPtr imagePtr = Converter.BitmapImageToIntPtr(hejBitmapImage);
                //int width = Converter.GetWidth(_originalImage);
                //int height = Converter.GetHeight(_originalImage);
                _transformedImage = hejBitmapImage;
                TranformedImage.Source = hejBitmapImage;
                return;*/

                //sprawdzanie podziału
                /*List<ThreadsManaging.IntPtrWithSize> intPtrs = ThreadsManaging.SplitImage(_originalImage, Int32.Parse(Threads.Text));
                OriginalImage_Copy.Source = Converter.IntPtrToBitmapImage(intPtrs[0].GetPtr(), intPtrs[0].GetSize(), intPtrs[0].GetWidth(), 10);
                OriginalImage_Copy1.Source = Converter.IntPtrToBitmapImage(intPtrs[1].GetPtr(), intPtrs[1].GetSize(), intPtrs[1].GetWidth(), 10);
                OriginalImage_Copy2.Source = Converter.IntPtrToBitmapImage(intPtrs[2].GetPtr(), intPtrs[2].GetSize(), intPtrs[2].GetWidth(), 10);
                return;*/

                ThreadsManaging action = new ThreadsManaging(_originalImage, parameters);

                //pomiar czasu
                Stopwatch watch = new Stopwatch();
                watch.Start();
                //operation
                action.start();
                watch.Stop();
                speed.Text = ((((double) watch.ElapsedTicks) / ((double) Stopwatch.Frequency)) * 1000 * 1000) +
                             " \u00b5s";
                //displaying
                //            BitmapImage transformedImage = Converter.IntPtrToBitmapImage(transformedIntPtrBytes, size, imageHeader);
                //            _transformedImage = transformedImage;
                //            BitmapSource transformedImage = MakeBitmapSource.FromNativePointer(transformedIntPtrBytes,
                //                width, height, 1);
                //            _transformedImage = Converter.BitmapSourceToBitmapImage(transformedImage);
                //            byte[] tranformedBytes = Converter.IntPtrToBytes(transformedIntPtrBytes, size);
                //            Bitmap transformedBitmap = Converter.BytesToBitmap(tranformedBytes, width, height);
                //BitmapImage transformedImage =
                    //Converter.IntPtrToBitmapImage(transformedIntPtrBytes, size, width, height);

                BitmapImage transformedImage = action.GetResult();

                _transformedImage = transformedImage;
                TranformedImage.Source = transformedImage;
            }
            catch (Exception XD)
            {
                MessageBox.Show(XD.Message, XD.GetType().ToString());
            }
            

        }

        private void Save_OnClick(object sender, RoutedEventArgs e)
        {
            try
            {
                SaveFileDialog saveFileDialog = new SaveFileDialog
                {
                    Filter = "PNG Image|*.png|JPeg Image|*.jpg|Bitmap Image|*.bmp|Gif Image|*.gif"
                };
                saveFileDialog.ShowDialog();
                Uri uri = new Uri(saveFileDialog.FileName);
                SaveImage(_transformedImage, uri.AbsolutePath);
            }
            catch (Exception XD)
            {
                MessageBox.Show(XD.Message, XD.GetType().ToString());
            }
           

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

        private void ShowHistogramOriginal_OnClick(object sender, RoutedEventArgs e)
        {
            try
            {
                new Histogram(this._originalImage, "oryginalnego").Show();
            }
            catch (Exception XD)
            {
                MessageBox.Show(XD.Message, XD.GetType().ToString());
            }

        }

        private void ShowHistogramTransformed_OnClick(object sender, RoutedEventArgs e)
        {
            try
            {
                new Histogram(this._transformedImage, "przetworzonego").Show();
            }
            catch (Exception XD)
            {
                MessageBox.Show(XD.Message, XD.GetType().ToString());
            }
        }
    }

    struct Params
    {
        public int ImageWidth;
        public int ImageHeight;
        public int ElemWidth;
        public int ElemHeight;
        public int CentrPntX;
        public int CentrPntY;
        public int NrOfThreads;
        public bool? Function;      //0 for C, 1 for Asm

        public Params(int imageWidth, int imageHeight, int elemWidth, int elemHeiht, int centrPntX, int centrPntY, int nrOfThreads, bool? function)
        {
            ImageWidth = imageWidth;
            ImageHeight = imageHeight;
            ElemWidth = elemWidth;
            ElemHeight = elemHeiht;
            CentrPntX = centrPntX;
            CentrPntY = centrPntY;
            NrOfThreads = nrOfThreads;
            Function = function;
        }
    }
}
