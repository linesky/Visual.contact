
#include "fbgfx.bi"
#include "crt.bi"
#include "file.bi"
enum
		SC_ESCAPE     = &h01
		SC_1
		SC_2
		SC_3
		SC_4
		SC_5
		SC_6
		SC_7
		SC_8
		SC_9
		SC_0
		SC_MINUS
		SC_EQUALS
		SC_BACKSPACE
		SC_TAB
		SC_Q
		SC_W
		SC_E
		SC_R
		SC_T
		SC_Y
		SC_U
		SC_I
		SC_O
		SC_P
		SC_LEFTBRACKET
		SC_RIGHTBRACKET
		SC_ENTER
		SC_CONTROL
		SC_A
		SC_S
		SC_D
		SC_F
		SC_G
		SC_H
		SC_J
		SC_K
		SC_L
		SC_SEMICOLON
		SC_QUOTE
		SC_TILDE
		SC_LSHIFT
		SC_BACKSLASH
		SC_Z
		SC_X
		SC_C
		SC_V
		SC_B
		SC_N
		SC_M
		SC_COMMA
		SC_PERIOD
		SC_SLASH
		SC_RSHIFT
		SC_MULTIPLY
		SC_ALT
		SC_SPACE
		SC_CAPSLOCK
		SC_F1
		SC_F2
		SC_F3
		SC_F4
		SC_F5
		SC_F6
		SC_F7
		SC_F8
		SC_F9
		SC_F10
		SC_NUMLOCK
		SC_SCROLLLOCK
		SC_HOME
		SC_UP
		SC_PAGEUP
		'' &h4A unused (?)
		SC_LEFT       = &h4B
		SC_CLEAR      = &h4C
		SC_CENTER     = &h4C
		SC_RIGHT
		SC_PLUS
		SC_END
		SC_DOWN
		SC_PAGEDOWN
		SC_INSERT
		SC_DELETE
		'' &h54
		'' &h55
		'' &h56
		SC_F11        = &h57
		SC_F12
		'' &h59
		'' &h5A
		SC_LWIN       = &h5B
		SC_RWIN
		SC_MENU
		'' &h5E
		'' &h5F
		'' &h60
		'' &h61
		'' &h62
		'' &h63
		SC_ALTGR      = &h64
	end enum
Const SCREEN_WIDTH = 400
Const SCREEN_HEIGHT = 240
Const CANVAS_WIDTH = 320
Const CANVAS_HEIGHT = 240
Const BUTTON_WIDTH = 60
Const BUTTON_HEIGHT = 30
Const MAX_OBJECTS = 50

Type Rect
    x As Integer
    y As Integer
    w As Integer
    h As Integer
End Type

Dim Shared objectList(MAX_OBJECTS) As Rect
Dim Shared objectCount As Integer = 0
Dim Shared mouseX As Integer, mouseY As Integer
Dim Shared mousePressed As Integer

Sub DrawCanvas()
    ScreenLock()
    ' Limpa a área do canvas
    Line (0, 0)-(CANVAS_WIDTH, CANVAS_HEIGHT), 0, BF

    ' Desenha todos os retângulos na lista
    For i As Integer = 0 To objectCount - 1
        Dim r As Rect = objectList(i)
       
        Line (r.x, r.y)-(r.x + r.w, r.y + r.h), 15,bf
    Next
	
    ScreenUnlock()
End Sub

Sub DrawButton(x As Integer, y As Integer, label As String)
    ' Desenha o botão
    
	Line (x, y)-(x + BUTTON_WIDTH, y + BUTTON_HEIGHT), 15, B
    Draw String (x + 10, y + 10), label, 15
End Sub

Function IsMouseInRect(x As Integer, y As Integer, w As Integer, h As Integer) As Integer
    Return mouseX >= x And mouseX <= x + w And mouseY >= y And mouseY <= y + h
End Function

Sub NewCanvas()
    ' Limpa a lista de objetos
    objectCount = 0
    DrawCanvas()
End Sub

Sub EraseLast()
    If objectCount > 0 Then
        objectCount -= 1
        DrawCanvas() ' Redesenha todos os objetos
    End If
End Sub

Sub SaveList(filename As String)
    Dim f As Integer = FreeFile
    If Open(filename For Output As #f) = 0 Then
        For i As Integer = 0 To objectCount - 1
            Dim r As Rect = objectList(i)
            Print #f, r.x; ","; r.y; ","; r.w; ","; r.h
        Next
        Close #f
    End If
End Sub

Sub LoadList(filename As String)
    Dim f As Integer = FreeFile
    If Open(filename For Input As #f) = 0 Then
        objectCount = 0
        While Not Eof(f) And objectCount < MAX_OBJECTS
            Dim r As Rect
            Input #f, r.x, r.y, r.w, r.h
            objectList(objectCount) = r
            objectCount += 1
        Wend
        Close #f
        DrawCanvas()
    End If
End Sub

' Configura o modo gráfico
dim nx as Integer=0
dim ny as integer=0
dim xymax as integer=CANVAS_WIDTH
if CANVAS_WIDTH<CANVAS_HEIGHT then xymax=CANVAS_HEIGHT

screen 9
for ny=0 to  xymax step 10
			    
	if ny<CANVAS_WIDTH then  line(ny,0)-(ny, CANVAS_HEIGHT),8
	if ny<CANVAS_HEIGHT then  line(0,ny)-(CANVAS_HEIGHT,ny),8
				
next     
Do
    ' Limpa a área ao redor da área de desenho
    Line (CANVAS_WIDTH, 0)-(SCREEN_WIDTH/2, SCREEN_HEIGHT), 0, BF

    ' Obtém o estado do mouse
    GetMouse(mouseX, mouseY,, mousePressed)

    ' Desenha botões
    DrawButton(CANVAS_WIDTH + 10, 10, "New")
    DrawButton(CANVAS_WIDTH + 10, 50, "Erase")
    DrawButton(CANVAS_WIDTH + 10, 90, "Save")
    DrawButton(CANVAS_WIDTH + 10, 130, "Load")

    ' Verifica cliques nos botões
    If mousePressed Then
        If IsMouseInRect(CANVAS_WIDTH + 10, 10, BUTTON_WIDTH, BUTTON_HEIGHT) Then
            NewCanvas()
        ElseIf IsMouseInRect(CANVAS_WIDTH + 10, 50, BUTTON_WIDTH, BUTTON_HEIGHT) Then
            EraseLast()
        ElseIf IsMouseInRect(CANVAS_WIDTH + 10, 90, BUTTON_WIDTH, BUTTON_HEIGHT) Then
            SaveList("rectangles.csv")
        ElseIf IsMouseInRect(CANVAS_WIDTH + 10, 130, BUTTON_WIDTH, BUTTON_HEIGHT) Then
            LoadList("rectangles.csv")
        End If
    End If

    ' Verifica se o mouse está desenhando dentro da área de desenho
    If mousePressed And IsMouseInRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT) Then
        If objectCount < MAX_OBJECTS Then
            objectList(objectCount).x = int(mouseX/10)*10
            objectList(objectCount).y = int(mouseY/10)*10
            objectList(objectCount).w = 50
            objectList(objectCount).h = 30
            objectCount += 1
            DrawCanvas()
			for ny=0 to  xymax step 10
			    
	            if ny<CANVAS_WIDTH then  line(ny,0)-(ny, CANVAS_HEIGHT),8
	            if ny<CANVAS_HEIGHT then  line(0,ny)-(CANVAS_HEIGHT,ny),8
				
            next   
        End If
    End If

    Sleep 5
Loop Until Multikey(SC_ESCAPE)

End

