using System;
using System.Collections.Generic;
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

namespace OperacjeMorfologiczne
{
    /// <summary>
    /// Logika interakcji dla klasy MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        private BitmapImage _originalImage;

        [DllImport(@"D:\studia\JAproj\OperacjeMorfologiczne\c_function\CFunction.dll", CallingConvention = CallingConvention.Cdecl)]
        private static extern IntPtr dilatation(IntPtr image);

        public MainWindow()
        {
            InitializeComponent();
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
            //operation
            IntPtr transformedIntPtrBytes = dilatation(imagePtr); 
            //displaying
            BitmapImage transformedImage = Converter.IntPtrToBitmapImage(transformedIntPtrBytes, size);
            TranformedImage.Source = transformedImage;
        }
    }
}
