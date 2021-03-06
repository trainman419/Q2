{{
  *************************************************
  *  Quantum Q4 TX Serial LCD Object              *
  *  Version 1.0                                  *
  *  By: Daniel Harris                            *               
  *  See end of file for terms of use.            *     
  *************************************************
  *  Modeled after Parallax Serial LCD Driver     *
  *  Authors: Jon Williams, Jeff Martin           *
  *                                               *
  *  DEC and HEX methods from:                    *
  *  Full-Duplex Serial Driver v1.2               *
  *  Author: Chip Gracey, Jeff Martin             *
  *                                               *
  * Questions? Please post on the Propeller forum *
  *       http://forums.parallax.com/forums/      *
  *************************************************
                
}}  

CON

  LCD_CMD         = $FE            'command prefix

  LCD_SPECCMD     = $7C            'special command prefix
  LCD_CONTRAST    = $52            'Set Contrast
  LCD_BRIGHT      = $53            'Brightness
  LCD_CLS         = $51            'Clear entire LCD screen
  LCD_HOME        = $46            'Puts the cursor at 0, 0                        
  LCD_OFF         = $42            'Display off
  LCD_ON          = $41            'Display ON
  LCD_NOCURS      = $0C            'Make cursor invisible
  LCD_ULCURS      = $0E            'Show underline cursor
  LCD_BLKCURS     = $0D            'Show blinking block cursor

  LCD_CURPOS      = $45            'set cursor  + position  

  LCD_SCRRIGHT    = $1C            'scroll right
  LCD_SCRLEFT     = $18            'scroll left
  LCD_RIGHT       = $14            'Move cursor right 
  LCD_LEFT        = $10            'Move cursor left

  LCD_SHOWVER     = $70            'Show version
  LCD_SHOWBAUD    = $71            'Show Baud rate

VAR

  long dispidx, lineidx, colidx, started
  byte ix, lpos[4]                             'array of LCD line start positions

OBJ

  serial : "simple_serial"                              ' bit-bang serial driver

  
PUB init(pin, baud, lines, columns): okay

'' Qualifies pin, baud, # lines, # columns input
'' -- makes tx pin an output and sets up other values if valid

  started~                                                    ' clear started flag
  if lookdown(pin : 0..27)                                    ' qualify tx pin 
    if lookdown(baud : 300, 1200, 2400, 4800, 9600, 14400, 19200, 38400) ' qualify baud rate setting
      if lookdown(lines : 2, 4)                               ' qualify lcd rows (lines)
        if lookdown(columns : 16, 20)                         ' qualify lcd columns
          dispidx := lookup(columns: 16, 20)                  ' set 1st array index
          if serial.init(-1, pin, baud)                       ' tx pin only, true mode
            lineidx := lines - 1                              ' save lines size
            colidx := columns - 1                             ' save columns size
            repeat ix from 0 to 3                             ' load lpos based on # of display columns
              if dispidx == 16
                lpos[ix] := disp16[ix]
              else
                lpos[ix] := disp20[ix]                       
            started~~                                         ' mark started flag true
  return started

PUB finalize
'' Finalizes serial object, disable LCD object

  if started
    serial.finalize
    started~                                            ' set to false

PUB putc(txByte) 
'' Transmit a byte

  serial.tx(txByte)

PUB str(strAddr)
'' Transmit z-string at strAddr

  serial.str(strAddr)

PUB dec(value) | i, x
'' Print a decimal number

  x := value == NEGX                                                            'Check for max negative
  if value < 0
    value := ||(value+x)                                                        'If negative, make positive; adjust for max negative
    serial.tx("-")                                                              'and output sign
                                                                     
  i := 1_000_000_000                                                            'Initialize divisor

  repeat 10                                                                     'Loop for 10 digits
    if value => i                                                               
      serial.tx(value / i + "0" + x*(i == 1))                                   'If non-zero digit, output digit; adjust for max negative
      value //= i                                                               'and digit from value
      result~~                                                                  'flag non-zero found
    elseif result or i == 1
      serial.tx("0")                                                            'If zero digit (or only digit) output it
    i /= 10                                                                     'Update divisor

PUB hex(value, digits)
'' Print a hexadecimal number

  value <<= (8 - digits) << 2
  repeat digits
    serial.tx(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))
    
PUB cls
'' Clears LCD and moves cursor to home (0, 0) position

  if started
    putc(LCD_CMD)
    putc(LCD_CLS)
    waitcnt(clkfreq / 200 + cnt)                        ' 5 ms delay 

PUB home
'' Moves cursor to 0, 0

  if started
    putc(LCD_CMD)
    putc(LCD_HOME)

PUB gotoxy(col, line)        
'' Moves cursor to col/line

  if started
    putc(LCD_CMD)
    putc(LCD_CURPOS) ' move to target position
    putc(line*$40 + col)
   

PRI Posit(col, line)
  putc(LCD_CMD)
  putc(LCD_CURPOS) ' move to target position
  putc(line*$40 + col)

PUB clrln(line)
'' Clears line

  if started
    if lookdown(line : 0..lineidx)                       ' qualify line input
      Posit(0, line)
      repeat colidx + 1
        putc(32)                                          ' clear line with spaces
      Posit(0, line)

PUB cursor(type)
'' Selects cursor type
''   0 : cursor off
''   1 : underline cursor       
''   2 : blinking box cursor

   if started
     if lookdown(type: 0..2)
       putc(LCD_CMD)
       putc(DispMode[type])                              ' get mode from table
       waitcnt(clkfreq / 200 + cnt)                      ' 5 ms delay 

PUB scrollLeft
'' Scrolls display left
  if started
    putc(LCD_CMD)
    putc(LCD_SCRLEFT) 

PUB scrollRight
'' Scrolls display right
  if started
    putc(LCD_CMD)
    putc(LCD_SCRRight) 

PUB cursorLeft
'' Moves cursor left
  if started
    putc(LCD_CMD)
    putc(LCD_LEFT) 

PUB cursorRight
'' Moves cursor right
  if started
    putc(LCD_CMD)
    putc(LCD_Right) 

PUB displayOff
'' Turns display off

  if started
    putc(LCD_CMD)
    putc(LCD_OFF) 

PUB displayOn
'' Turns display on
  if started
    putc(LCD_CMD)
    putc(LCD_ON) 

PUB backLight(brightness)
'' Sets backlight brightness: 128 to 157 
'' e.g. 128 off 
''      140 40% on
''      150 73% on
''      157 Fully on

  if started
     if lookdown(brightness: 1..8)
       putc(LCD_CMD)
       putc(LCD_BRIGHT)
       putc(brightness) 

PUB contrast(c)
  if started
    if lookdown(c: 1..50)
      putc(LCD_CMD)
      putc(LCD_CONTRAST)
      putc(c)

PUB showver
  if started
    putc(LCD_CMD)
    putc(LCD_SHOWVER)

PUB showbaud
  if started
    putc(LCD_CMD)
    putc(LCD_SHOWBAUD)
DAT
  DispMode    byte   LCD_NOCURS, LCD_ULCURS, LCD_BLKCURS
  disp16      byte   0, 64, 16, 80   'line pos for 16 column displays
  disp20      byte   0, 64, 20, 84   'line pos for 20 column displays

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
