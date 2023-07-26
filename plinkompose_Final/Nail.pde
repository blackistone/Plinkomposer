/* Nail.pde
 *
 * Copyright 2018-2021 Roland Richter
 * Copyright 2021 Kevin Blackistone
 *
 * This file is part of Plinkompose
 *  - originally part of FisicaGame.
 *
 * FisicaGame is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty
 * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

public class Pin extends FCircle
{
    public Pin()
    {
        this(8, #000000); // Steel blue, see http://latexcolor.com/
    }
    
    
    public Pin(float size, color col)
    {
        super(size);
        this.setFillColor(col);
        this.setStrokeWeight(0.25);
        this.setStrokeColor(#FFFFFF);
        
        this.setStatic(true);
        this.setDensity(10000.0);
    }
}
