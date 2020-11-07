using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using System.Windows.Controls.DataVisualization.Charting;

namespace OperacjeMorfologiczne
{
    /// <summary>
    /// Logika interakcji dla klasy Histogram.xaml
    /// </summary>
    public partial class Histogram : Window
    {

        private int whitePixels = 0;
        private int blackPixels = 0;
        private BitmapImage imagus;

        public Histogram(BitmapImage image, string typeOfImage)
        {
            if (image != null)
            {
                InitializeComponent();
                typeImage.Text += typeOfImage + ": ";
                this.imagus = image;
                countPixels();
                LoadColumnChartData();
            }
            else
            {
                throw new Exception("Brak obrazu");
            }
            
        }

        private void countPixels()
        {
            byte[] imageBytes = Converter.BitmapToBytes(Converter.BitmapImage2Bitmap(this.imagus));

            foreach(var imageByte in imageBytes)
            {
                if (imageByte < 10)
                    this.blackPixels++;
                else
                    this.whitePixels++;
            }
        }


        private void LoadColumnChartData()
        {
            ((ColumnSeries) mcChart.Series[0]).ItemsSource =
                new KeyValuePair<string, int>[]{
        new KeyValuePair<string,int>("Białe piksele", this.whitePixels),
        new KeyValuePair<string,int>("Czarne Piksele", this.blackPixels) };
        }
    }
}
