/* Plank.pde
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
 
public class Plank extends FBox
{
    public Plank()
    {
        this(350, 15);
    }
    
    public Plank(float w, float h)
    {
        this(w, h, #402306);
    }
    
    
    public Plank(float w, float h, color col)
    {
        super(w, h);
        this.setFillColor(col);
        
        this.setStatic(true);
        this.setDamping(0.95);
        this.setDensity(7000.0);
        this.setRestitution(0.1);
    }
}
