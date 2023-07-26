/* Puck.pde
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

public class Puck extends FCircle
{
    public Puck(float bounce_)
    {
        super(67);
        //this.setFillColor(#FFFFFF); // white
        //this.setStrokeWeight(0.25);
        this.attachImage(puckImg);
        this.setDamping(0.1);
        this.setDensity(300.0);
        this.setRestitution(bounce_);
    }
    
  
    public void delete()
    {
      this.m_world.remove(this);
    }
    
}
