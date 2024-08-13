/*
 ============================================================================
 Name        : Minesweeper_GUI.c
 Author      : KaiUR
 Version     : 1.0
 Copyright   : Your copyright notice
 Description : Minesweeper GUI Version using WIN32 API
 ============================================================================
 */

/*
 ============================================================================
 	 INCLUDES
 ============================================================================
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>
#include <tchar.h>
#include "resource.h"

/*
 ============================================================================
 	 DEFENITIONS
 ============================================================================
 */
const char g_szClassName[] = "Prime_Numbers";

/*
 ============================================================================
 	 COLOUR DEFENITIONS
 ============================================================================
 */
const COLORREF rgbText = RGB(0, 0, 240);
const COLORREF window_bgd = RGB(210, 210, 210);


/*
 ============================================================================
 	 Global
 ============================================================================
 */
// Create an array of lines to display.
int lines =  1;
char **numbers;
BOOL calc = FALSE;


/*
 ============================================================================
 	 WIN32 API ENTRYPOINT
 ============================================================================
 */
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	numbers = malloc(1*sizeof(char*));
	numbers[0] = malloc(2 * sizeof(TEXT(" ")));
	sprintf(numbers[0], " ");


	//Window creation settings
    WNDCLASSEX wc;
    HWND hwnd;
    MSG Msg;

    wc.cbSize        = sizeof(WNDCLASSEX);
    wc.style         = 0;
    wc.lpfnWndProc   = WndProc;
    wc.cbClsExtra    = 0;
    wc.cbWndExtra    = 0;
    wc.hInstance     = hInstance;
    wc.hIcon         = LoadIcon(NULL, IDI_APPLICATION);
    wc.hCursor       = LoadCursor(NULL, IDC_ARROW);
    wc.hbrBackground = (HBRUSH)CreateSolidBrush(window_bgd);
    wc.lpszMenuName  = NULL;
    wc.lpszClassName = g_szClassName;
    wc.hIconSm       = LoadIcon(NULL, IDI_APPLICATION);
    wc.lpszMenuName  = MAKEINTRESOURCE(IDR_MAIN_MENU);
    wc.hIcon  		 = LoadIcon(GetModuleHandle(NULL), MAKEINTRESOURCE(IDI_MYICON));
    wc.hIconSm 		 = (HICON)LoadImage(GetModuleHandle(NULL), MAKEINTRESOURCE(IDI_MYICON), IMAGE_ICON, 16, 16, 0);

    //Error Checking
    if(!RegisterClassEx(&wc))
    {
        MessageBox(NULL, "Window Registration Failed!", "Error!", MB_ICONEXCLAMATION | MB_OK);
        return 0;
    }

    //Create Window
    hwnd = CreateWindowEx(
        WS_EX_CLIENTEDGE,
        g_szClassName,
        "Prime Numbers GUI",
        WS_OVERLAPPEDWINDOW | WS_HSCROLL | WS_VSCROLL,
        CW_USEDEFAULT, CW_USEDEFAULT, MAIN_WINDO_WIDTH, MAIN_WINDO_HEIGHT,
        NULL, NULL, hInstance, NULL);

    //Error Checking
    if(hwnd == NULL)
    {
        MessageBox(NULL, "Window Creation Failed!", "Error!", MB_ICONEXCLAMATION | MB_OK);
        return 0;
    }


   //Setup Callback loop
    ShowWindow(hwnd, nCmdShow);
    UpdateWindow(hwnd);

    while(GetMessage(&Msg, NULL, 0, 0) > 0)
    {
        TranslateMessage(&Msg);
        DispatchMessage(&Msg);
    }
    return Msg.wParam;
}


/*
 ============================================================================
 	 Callback for main window
 ============================================================================
 */
LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	HDC hdc;
	PAINTSTRUCT ps;
	TEXTMETRIC tm;
	SCROLLINFO si;

	// These variables are required to display text.
	static int xClient;     // width of client area
	static int yClient;     // height of client area
	static int xClientMax;  // maximum width of client area

	static int xChar;       // horizontal scrolling unit
	static int yChar;       // vertical scrolling unit
	static int xUpper;      // average width of uppercase letters

	static int xPos;        // current horizontal scrolling position
	static int yPos;        // current vertical scrolling position

	int i;                  // loop counter
	int x, y;               // horizontal and vertical coordinates

	int FirstLine;          // first line in the invalidated area
	int LastLine;           // last line in the invalidated area

    switch(msg)
    {

    	//Window Menu
    	case WM_COMMAND:
    		switch(LOWORD(wParam))
    		{
    			//Exit
            	case ID_FILE_EXIT:
            			PostMessage(hwnd, WM_CLOSE, 0, 0);
            		break;
            	case ID_FILE_NEW:
            		int ret_new = DialogBox(GetModuleHandle(NULL), MAKEINTRESOURCE(IDD_NEW), hwnd, (DLGPROC)new_DlgProc);
					if(ret_new == -1)
					{
						MessageBox(NULL, "Window Creation Failed!", "Error!", MB_ICONEXCLAMATION | MB_OK);
						PostMessage(hwnd, WM_CLOSE, 0, 0);
					}
					else if(ret_new == IDOK)
					{
						// Retrieve the dimensions of the client area.
						yClient = HIWORD (lParam);
						xClient = LOWORD (lParam);

						// Set the vertical scrolling range and page size
						si.cbSize = sizeof(si);
						si.fMask  = SIF_RANGE | SIF_PAGE;
						si.nMin   = 0;
						si.nMax   = lines - 1;
						si.nPage  = yClient / yChar;
						SetScrollInfo(hwnd, SB_VERT, &si, TRUE);

						// Set the horizontal scrolling range and page size.
						si.cbSize = sizeof(si);
						si.fMask  = SIF_RANGE | SIF_PAGE;
						si.nMin   = 0;
						si.nMax   = 2 + xClientMax / xChar;
						si.nPage  = xClient / xChar;
						SetScrollInfo(hwnd, SB_HORZ, &si, TRUE);
						InvalidateRect(hwnd, 0, TRUE);
					}
				break;
				//Shows helptext
				case ID_HELP_HELP:
					int ret_help = DialogBox(GetModuleHandle(NULL), MAKEINTRESOURCE(IDD_HELP), hwnd, (DLGPROC)STD_DlgProc);
					if(ret_help == -1)
					{
						MessageBox(NULL, "Window Creation Failed!", "Error!", MB_ICONEXCLAMATION | MB_OK);
						PostMessage(hwnd, WM_CLOSE, 0, 0);
					}
					break;
				//Shows about text
				case ID_HELP_ABOUT:
					int ret_about = DialogBox(GetModuleHandle(NULL), MAKEINTRESOURCE(IDD_ABOUT), hwnd, (DLGPROC)STD_DlgProc);
					if(ret_about == -1)
					{
						MessageBox(NULL, "Window Creation Failed!", "Error!", MB_ICONEXCLAMATION | MB_OK);
						PostMessage(hwnd, WM_CLOSE, 0, 0);
					}
					break;
    		}
    		break;
    	//Creates assets for program
    		case WM_CREATE :
			// Get the handle to the client area's device context.
			hdc = GetDC (hwnd);

			// Extract font dimensions from the text metrics.
			GetTextMetrics (hdc, &tm);
			xChar = tm.tmAveCharWidth;
			xUpper = (tm.tmPitchAndFamily & 1 ? 3 : 2) * xChar/2;
			yChar = tm.tmHeight + tm.tmExternalLeading;

			// Free the device context.
			ReleaseDC (hwnd, hdc);

			// Set an arbitrary maximum width for client area.
			// (xClientMax is the sum of the widths of 48 average
			// lowercase letters and 12 uppercase letters.)
			xClientMax = 48 * xChar + 12 * xUpper;

			return 0;

		case WM_SIZE:

			// Retrieve the dimensions of the client area.
			yClient = HIWORD (lParam);
			xClient = LOWORD (lParam);

			// Set the vertical scrolling range and page size
			si.cbSize = sizeof(si);
			si.fMask  = SIF_RANGE | SIF_PAGE;
			si.nMin   = 0;
			si.nMax   = lines - 1;
			si.nPage  = yClient / yChar;
			SetScrollInfo(hwnd, SB_VERT, &si, TRUE);

			// Set the horizontal scrolling range and page size.
			si.cbSize = sizeof(si);
			si.fMask  = SIF_RANGE | SIF_PAGE;
			si.nMin   = 0;
			si.nMax   = 2 + xClientMax / xChar;
			si.nPage  = xClient / xChar;
			SetScrollInfo(hwnd, SB_HORZ, &si, TRUE);

			return 0;
		case WM_HSCROLL:
			// Get all the vertial scroll bar information.
			si.cbSize = sizeof (si);
			si.fMask  = SIF_ALL;

			// Save the position for comparison later on.
			GetScrollInfo (hwnd, SB_HORZ, &si);
			xPos = si.nPos;
			switch (LOWORD (wParam))
			{
			// User clicked the left arrow.
			case SB_LINELEFT:
				si.nPos -= 1;
				break;

			// User clicked the right arrow.
			case SB_LINERIGHT:
				si.nPos += 1;
				break;

			// User clicked the scroll bar shaft left of the scroll box.
			case SB_PAGELEFT:
				si.nPos -= si.nPage;
				break;

			// User clicked the scroll bar shaft right of the scroll box.
			case SB_PAGERIGHT:
				si.nPos += si.nPage;
				break;

			// User dragged the scroll box.
			case SB_THUMBTRACK:
				si.nPos = si.nTrackPos;
				break;

			default :
				break;
			}

			// Set the position and then retrieve it.  Due to adjustments
			// by Windows it may not be the same as the value set.
			si.fMask = SIF_POS;
			SetScrollInfo (hwnd, SB_HORZ, &si, TRUE);
			GetScrollInfo (hwnd, SB_HORZ, &si);

			// If the position has changed, scroll the window.
			if (si.nPos != xPos)
			{
				ScrollWindow(hwnd, xChar * (xPos - si.nPos), 0, NULL, NULL);
			}

			return 0;

		case WM_VSCROLL:
			// Get all the vertial scroll bar information.
			si.cbSize = sizeof (si);
			si.fMask  = SIF_ALL;
			GetScrollInfo (hwnd, SB_VERT, &si);

			// Save the position for comparison later on.
			yPos = si.nPos;
			switch (LOWORD (wParam))
			{

			// User clicked the HOME keyboard key.
			case SB_TOP:
				si.nPos = si.nMin;
				break;

			// User clicked the END keyboard key.
			case SB_BOTTOM:
				si.nPos = si.nMax;
				break;

			// User clicked the top arrow.
			case SB_LINEUP:
				si.nPos -= 1;
				break;

			// User clicked the bottom arrow.
			case SB_LINEDOWN:
				si.nPos += 1;
				break;

			// User clicked the scroll bar shaft above the scroll box.
			case SB_PAGEUP:
				si.nPos -= si.nPage;
				break;

			// User clicked the scroll bar shaft below the scroll box.
			case SB_PAGEDOWN:
				si.nPos += si.nPage;
				break;

			// User dragged the scroll box.
			case SB_THUMBTRACK:
				si.nPos = si.nTrackPos;
				break;

			default:
				break;
			}

			// Set the position and then retrieve it.  Due to adjustments
			// by Windows it may not be the same as the value set.
			si.fMask = SIF_POS;
			SetScrollInfo (hwnd, SB_VERT, &si, TRUE);
			GetScrollInfo (hwnd, SB_VERT, &si);

			// If the position has changed, scroll window and update it.
			if (si.nPos != yPos)
			{
				ScrollWindow(hwnd, 0, yChar * (yPos - si.nPos), NULL, NULL);
				UpdateWindow (hwnd);
			}

			return 0;

		case WM_PAINT :
			// Prepare the window for painting.
			hdc = BeginPaint (hwnd, &ps);

			HGDIOBJ original = NULL;
			original = SelectObject(hdc,GetStockObject(DC_PEN));

			SelectObject(hdc, GetStockObject(DC_PEN));
			SelectObject(hdc, GetStockObject(DC_BRUSH));
			SetDCBrushColor(hdc, window_bgd);
			SetDCPenColor(hdc, window_bgd);

			RECT rcWindow;
			GetClientRect(hwnd, &rcWindow);
			Rectangle(hdc, rcWindow.left, rcWindow.top, rcWindow.right, rcWindow.bottom);

			SetTextColor(hdc, rgbText);
			SetBkMode(hdc, TRANSPARENT);

			// Get vertical scroll bar position.
			si.cbSize = sizeof (si);
			si.fMask  = SIF_POS;
			GetScrollInfo (hwnd, SB_VERT, &si);
			yPos = si.nPos;

			// Get horizontal scroll bar position.
			GetScrollInfo (hwnd, SB_HORZ, &si);
			xPos = si.nPos;

			// Find painting limits.
			FirstLine = max (0, yPos + ps.rcPaint.top / yChar);
			LastLine = min (lines - 1, yPos + ps.rcPaint.bottom / yChar);

			for (i = FirstLine; i <= LastLine; i++)
			{
				x = xChar * (1 - xPos);
				y = yChar * (i - yPos);

				TextOut(hdc, x, y, (TCHAR*)numbers[i], (size_t)strlen(numbers[i]));
			}

			// Indicate that painting is finished.
			SelectObject(hdc,original);
			EndPaint (hwnd, &ps);
			return 0;
    	break;
    	//Reduce flickering
    	case WM_ERASEBKGND:
    		break;
    	//Left click
    	case WM_LBUTTONDOWN:
    	break;
    	//Right click
    	case WM_RBUTTONDOWN:
    	break;
		case WM_KEYDOWN:
		{
			WORD wScrollNotify = 0xFFFF;

			switch (wParam)
			{
				case VK_UP:
					wScrollNotify = SB_LINEUP;
					break;

				case VK_PRIOR:
					wScrollNotify = SB_PAGEUP;
					break;

				case VK_NEXT:
					wScrollNotify = SB_PAGEDOWN;
					break;

				case VK_DOWN:
					wScrollNotify = SB_LINEDOWN;
					break;

				case VK_HOME:
					wScrollNotify = SB_TOP;
					break;

				case VK_END:
					wScrollNotify = SB_BOTTOM;
					break;
			}

			if (wScrollNotify != -1)
				SendMessage(hwnd, WM_VSCROLL, MAKELONG(wScrollNotify, 0), 0L);

			break;
		}
    	//Close window
        case WM_CLOSE:
        	if ( MessageBox( hwnd, "Are you sure you want to quit?", "Confirmation", MB_ICONQUESTION | MB_YESNO ) == IDYES )
        	{
        		DestroyWindow(hwnd);
        	}
        break;
        //cleanup
        case WM_DESTROY:
        	for(int i = 0; i < lines; i++)
        	{
        		free(numbers[i]);
        	}
        	free(numbers);
            PostQuitMessage(0);
        break;
        default:
            return DefWindowProc(hwnd, msg, wParam, lParam);
    }
    return 0;
}

/*
 ============================================================================
 	 STD Callback for message boxes
 ============================================================================
 */
BOOL CALLBACK STD_DlgProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam)
{
    switch(Message)
    {
        case WM_INITDIALOG:

        return TRUE;
        case WM_COMMAND:
            switch(LOWORD(wParam))
            {
                case IDOK:
                    EndDialog(hwnd, IDOK);
                break;
                case IDCANCEL:
                    EndDialog(hwnd, IDCANCEL);
                break;
            }
        break;
        default:
            return FALSE;
    }
    return TRUE;
}

/*
 ============================================================================
 	 CUSTOM GAME Callback for message boxes
 ============================================================================
 */
BOOL CALLBACK new_DlgProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam)
{
    switch(Message)
    {
        case WM_INITDIALOG:

        return TRUE;
        case WM_COMMAND:
            switch(LOWORD(wParam))
            {
                case IDOK:
                   	for(int i = 0; i < lines; i++)
                    {
                    	free(numbers[i]);
                    }
                   	free(numbers);
                	numbers = malloc(1*sizeof(char*));
                	numbers[0] = malloc(2 * sizeof(TEXT("Prime Numbers:")));
                	sprintf(numbers[0], "Prime Numbers:");
                	lines = 1;

                	int input;

                	TCHAR buff_input[BUFFER_INT] = {0};
                	GetDlgItemText(hwnd, IDE_INPUT_NUMBER, buff_input, 1024);

                	sscanf(buff_input, "%d", &input);


                	if(input < 0)														//Check for min values
                	{
                		input = 1;;
                	}

                	caculate_primes(input);

                    EndDialog(hwnd, IDOK);
                break;
                case IDCANCEL:
                    EndDialog(hwnd, IDCANCEL);
                break;
            }
        break;
        default:
            return FALSE;
    }
    return TRUE;
}

void caculate_primes(int current_n)
{
    int num;
    int i;
    int count;

    for(num = 1; num<=current_n; num++)
    {
    	count = 0;

        for(i=2; i<=num/2; i++)
        {
        	if(num%i==0)
        	{
                 count++;
                 break;
        	}
        }

        if(count==0 && num!= 1)
        {
        	int temp_int = num;
        	int temp_count = 0;
        	while(temp_int > 0)
        	{
        		temp_int = temp_int / 10;
        		temp_count++;
        	}
        	char *temp_char = malloc(temp_count + 1 * sizeof(char*));

        	sprintf(temp_char, "%d", num);
        	lines ++;

        	char **temp;
        	temp = realloc(numbers, lines * sizeof(*numbers));
        	numbers = temp;
        	numbers[lines - 1] = temp_char;
        }
    }

   return;
}
