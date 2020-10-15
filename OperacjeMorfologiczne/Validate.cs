using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Media.Imaging;

namespace OperacjeMorfologiczne
{
    class Validate
    {
        private int _elemWidth;
        private int _elemHeight;
        private int _centrPntX;
        private int _centrPntY;

        public Validate(int elemWidth, int elemHeight, int centrPntX, int centrPntY)
        {
            _elemWidth = elemWidth;
            _elemHeight = elemHeight;
            _centrPntX = centrPntX;
            _centrPntY = centrPntY;
        }

        public void IsCentrPntXLessThanElemWidth()
        {
            if(_centrPntX>=_elemWidth)
                throw new Exception("Wsp. X punktu centralnego musi być mniejsza niż szerokość elementu strukturalnego!");
        }

        public void IsCentrPntYLessThanElemHeight()
        {
            if (_centrPntY >= _elemHeight)
                throw new Exception("Wsp. Y punktu centralnego musi być mniejsza niż wysokość elementu strukturalnego!");
        }

        public void validate()
        {
            IsCentrPntXLessThanElemWidth();
            IsCentrPntYLessThanElemHeight();
        }
    }
}
