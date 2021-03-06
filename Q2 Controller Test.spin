''**********************************************
''*  Quantum Robotics, Inc.                    *
''*  Q2 Controller Test Program                *
''*  Author: Paul Krasinski                    *
''*  See end of file for terms of use.         *
''**********************************************
''
{{
Notes:

This program is a simple test program.  The program cycles thru all A/D's and displays
raw data on the LCD screen.

Ideal values range from 0 -> 4095.  These values may vary as tolerances on certain components offest
these values.

EX:  When trying to determine if a toggle switch has been flipped on or off. Instead of
looking for a value of 0 or 4095 its better to look if the value is above or below 2047.  If toggle switch
3 has been flipped the value drops to around 0 when open its more likely to be < ~4000    

A/D Data Mapout & Var's containing specific data as shown running and displayed on LCD.
There are 4 12bt A/D's with 8 outputs from each. 
  
  ADC1 := adc[0].in(0)   '1 = Joystick 2 Vertical                                   
  ADC2 := adc[0].in(1)   '2 = Joystick 2 Horizontal
  ADC3 := adc[0].in(2)   '3 = Joystick 1 Horizontal                                   
  ADC4 := adc[0].in(3)   '4 = Joystick 1 Vertical
  ADC5 := adc[0].in(4)   '5 = Potentiometer 2                                
  ADC6 := adc[0].in(5)   '6 = Potentiometer 1
  ADC7 := adc[0].in(6)   '7 = Potentiometer 4                            
  ADC8 := adc[0].in(7)   '8 = Potentiometer 3
  
  ADC21 := adc[1].in(0)  '21 = Oval Right                                    
  ADC22 := adc[1].in(1)  '22 = Oval Left
  ADC23 := adc[1].in(2)  '23 = Toggle Switch 1
  ADC24 := adc[1].in(3)  '24 = Toggle Switch 2
  ADC25 := adc[1].in(4)  '25 = Toggle Switch 3                            
  ADC26 := adc[1].in(5)  '26 = Toggle Switch 4
  ADC27 := adc[1].in(6)  '27 = Toggle Switch 5                              
  ADC28 := adc[1].in(7)  '28 = Toggle Switch 6
    
  ADC31 := adc[2].in(0)  '31 = Right Top                              
  ADC32 := adc[2].in(1)  '32 = Right Right
  ADC33 := adc[2].in(2)  '33 = Right Left
  ADC34 := adc[2].in(3)  '34 = Right Botttom
  ADC35 := adc[2].in(4)  '35 = Left Right                                 
  ADC36 := adc[2].in(5)  '36 = Left Bottom
  ADC37 := adc[2].in(6)  '37 = Left Top                                 
  ADC38 := adc[2].in(7)  '38 = Left Left
}}
     
CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

'A/D#1
  CS1   = 1  'CS  = pin connected to CS on MCP3208        
  DPIN1 = 2  'dpin  = pin connected to both DIN and DOUT on MCP3208 
  CPIN1 = 3  'cpin  = pin connected to CLK on MCP3208   

'A/D#2
  CS2   = 4  'CS  = pin connected to CS on MCP3208         
  DPIN2 = 5  'dpin  = pin connected to both DIN and DOUT on MCP3208 
  CPIN2 = 6  'cpin  = pin connected to CLK on MCP3208    

'A/D#3
  CS3   = 7  'CS  = pin connected to CS on MCP3208        
  DPIN3 = 8  'dpin  = pin connected to both DIN and DOUT on MCP3208 
  CPIN3 = 9  'cpin  = pin connected to CLK on MCP3208   

  Mode = $FF 'A/D Mode/// mode not used, included for compatability with older programs         
 
  LCD_PIN = 0      'LCD on Pin 0 
  LCD_BAUD = 9600  'LCD Baud Rate

  DEBUG_RX_PIN = 31
  DEBUG_TX_PIN = 30
  DEBUG_BAUD = 9600


'---------------------------------------------------------------------       
OBJ
  LCD  : "Q2_Serial_LCD"
  ADC[3]  : "MCP3208_Fast"
  DEBUG : "simple_serial"                              ' bit-bang serial driver
  
VAR

  LONG ADC1, ADC2, ADC3, ADC4, ADC5, ADC6, ADC7, ADC8
  LONG ADC21, ADC22, ADC23, ADC24, ADC25, ADC26, ADC27, ADC28
  LONG ADC31, ADC32, ADC33, ADC34, ADC35, ADC36, ADC37, ADC38
  LONG recv
  LONG stack[500]
DAT
'     column number     =1234567890123456=  
title_line0   byte      "     Q2 TX     ", 0
title_line1   byte      "Quantum Robotics", 0    
PUB Start
  'Set up the DEBUG interface
  DEBUG.init(DEBUG_RX_PIN, DEBUG_TX_PIN, DEBUG_BAUD)
  WaitCnt(5_000_000 + Cnt)

  println(string("Debugging Started"))

  cognew(ADGroup,@stack)  'start cog
  WaitCnt(5_000_000 + Cnt)
  Main

PUB println(s)
  DEBUG.str(s)
  DEBUG.tx(13)
  DEBUG.tx(10)

PUB print(s)
  DEBUG.str(s)

PUB Main

  'Setup the LCD
  LCD.init(LCD_Pin, LCD_BAUD, 2, 16)  '2 line, 16 column display
  waitcnt(cnt + clkfreq/10)
  LCD.CLS                             'Clears LCD and moves cursor to home (0, 0) position
  waitcnt(cnt + clkfreq/10)
  LCD.backlight(5)                  '40% backlight
  waitcnt(cnt + clkfreq/10)
  LCD.contrast(40)

  println(string("LCD Cleared"))

  waitcnt(cnt + clkfreq/10)

  LCD.gotoxy(0,0)
  LCD.Home
  LCD.Str(@title_line0)
  LCD.Gotoxy(0, 1)  
  LCD.Str(@title_line1)

  println(string("LCD set up"))

  waitcnt(cnt + clkfreq * 3)    'wait a moment before showing data       
  LCD.Cls                       'clear the LCD

  println(string("LCD cleared"))

  repeat

    Repeat 40
       LCD.gotoxy(0, 0)
       LCD.str(string("1 ")) 
       LCD.dec(ADC1)
       LCD.gotoxy(7,0)
       LCD.str(string("2 "))
       LCD.dec(ADC2)

       println(string("1 "))
       println(string("2 "))

       LCD.gotoxy(0, 1)
       LCD.str(string("3 ")) 
       LCD.dec(ADC3)
       LCD.gotoxy(7,1)
       LCD.str(string("4 "))
       LCD.dec(ADC4)

       println(string("3 "))
       println(string("4 "))

       WaitCnt(25_000_000 + Cnt)     
       LCD.CLS

    Repeat 40
       LCD.gotoxy(0, 0)
       LCD.str(string("5 ")) 
       LCD.dec(ADC5)
       LCD.gotoxy(7,0)
       LCD.str(string("6 "))
       LCD.dec(ADC6)

       LCD.gotoxy(0, 1)
       LCD.str(string("7 ")) 
       LCD.dec(ADC7)
       LCD.gotoxy(7,1)
       LCD.str(string("8 "))
       LCD.dec(ADC8)

       WaitCnt(25_000_000 + Cnt)     
       LCD.CLS

    Repeat 40
       LCD.gotoxy(0, 0)
       LCD.str(string("21 ")) 
       LCD.dec(ADC21)
       LCD.gotoxy(8,0)
       LCD.str(string("22 "))
       LCD.dec(ADC22)

       LCD.gotoxy(0, 1)
       LCD.str(string("23 ")) 
       LCD.dec(ADC23)
       LCD.gotoxy(8,1)
       LCD.str(string("24 "))
       LCD.dec(ADC24)

       WaitCnt(25_000_000 + Cnt)     
       LCD.CLS

    Repeat 40
       LCD.gotoxy(0, 0)
       LCD.str(string("25 ")) 
       LCD.dec(ADC25)
       LCD.gotoxy(8,0)
       LCD.str(string("26 "))
       LCD.dec(ADC26)

       LCD.gotoxy(0, 1)
       LCD.str(string("27 ")) 
       LCD.dec(ADC27)
       LCD.gotoxy(8,1)
       LCD.str(string("28 "))
       LCD.dec(ADC28)

       WaitCnt(25_000_000 + Cnt)     
       LCD.CLS

    Repeat 40
       LCD.gotoxy(0, 0)
       LCD.str(string("31 ")) 
       LCD.dec(ADC31)
       LCD.gotoxy(8,0)
       LCD.str(string("32 "))
       LCD.dec(ADC32)

       LCD.gotoxy(0, 1)
       LCD.str(string("33 ")) 
       LCD.dec(ADC33)
       LCD.gotoxy(8,1)
       LCD.str(string("34 "))
       LCD.dec(ADC34)

       WaitCnt(25_000_000 + Cnt)     
       LCD.CLS

    Repeat 40
       LCD.gotoxy(0, 0)
       LCD.str(string("35 ")) 
       LCD.dec(ADC35)
       LCD.gotoxy(8,0)
       LCD.str(string("36 "))
       LCD.dec(ADC36)

       LCD.gotoxy(0, 1)
       LCD.str(string("37 ")) 
       LCD.dec(ADC37)
       LCD.gotoxy(8,1)
       LCD.str(string("38 "))
       LCD.dec(ADC38)

       WaitCnt(25_000_000 + Cnt)     
       LCD.CLS
  
Pub ADGroup
  ADC[0].start(DPIN1, CPIN1, CS1, MODE)   
  ADC[1].start(DPIN2, CPIN2, CS2, MODE)
  ADC[2].start(DPIN3, CPIN3, CS3, MODE)
 repeat  
   
    ADC1 := adc[0].in(0)   'Joystick 2 Vertical                                   
    ADC2 := adc[0].in(1)   'Joystick 2 Horizontal
    ADC3 := adc[0].in(2)   'Joystick 1 Horizontal                                   
    ADC4 := adc[0].in(3)   'Joystick 1 Vertical
    ADC5 := adc[0].in(4)   'Potentiometer 2                                
    ADC6 := adc[0].in(5)   'Potentiometer 1
    ADC7 := adc[0].in(6)   'Potentiometer 4                            
    ADC8 := adc[0].in(7)   'Potentiometer 3
  
    
    ADC21 := adc[1].in(0)  'Oval Right                                    
    ADC22 := adc[1].in(1)  'Oval Left
    ADC23 := adc[1].in(2)  'Toggle Switch 1
    ADC24 := adc[1].in(3)  'Toggle Switch 2
    ADC25 := adc[1].in(4)  'Toggle Switch 3                            
    ADC26 := adc[1].in(5)  'Toggle Switch 4
    ADC27 := adc[1].in(6)  'Toggle Switch 5                              
    ADC28 := adc[1].in(7)  'Toggle Switch 6

    
    ADC31 := adc[2].in(0)  'Right Top                              
    ADC32 := adc[2].in(1)  'Right Right
    ADC33 := adc[2].in(2)  'Right Left
    ADC34 := adc[2].in(3)  'Right Botttom
    ADC35 := adc[2].in(4)  'Left Right                                 
    ADC36 := adc[2].in(5)  'Left Bottom
    ADC37 := adc[2].in(6)  'Left Top                                 
    ADC38 := adc[2].in(7)  'Left Left
    
                    
{{   
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}
