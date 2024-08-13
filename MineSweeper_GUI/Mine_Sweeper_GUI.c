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
#include <windows.h>
#include <time.h>
#include "resource.h"

/*
 ============================================================================
 	 DEFENITIONS
 ============================================================================
 */
const char g_szClassName[] = "Mine_Sweeper";
const int adjacents[8][2] = { { 1, 1 }, { -1, -1 }, { 0, 1 },  { 0, -1 },{ 1, 0 }, { -1, 0 },  { -1, 1 }, { 1, -1 } };
const int ID_TIMER = 1;

/*
 ============================================================================
 	 COLOUR DEFENITIONS
 ============================================================================
 */
const COLORREF mines_rgbText = RGB(255, 0, 0);
const COLORREF timer_rgbText = RGB(0, 0, 0);
const COLORREF window_bgd = RGB(210, 210, 210);

/*
 ============================================================================
 	 GLOBAL VARIABLES
 ============================================================================
 */
struct game_board_s game_board;
struct game_board_s copy_game_board;
int play = 0;
int custom_x = MIN_X;
int custom_y = MIN_Y;
int custom_mines = MIN_MINES;
unsigned long timer_value = 0;

/*
 ============================================================================
 	 BITMAPS
 ============================================================================
 */
HBITMAP blank_space = NULL;
HBITMAP blank_space_empty = NULL;
HBITMAP mine_black = NULL;
HBITMAP mine_red = NULL;
HBITMAP space_flag = NULL;
HBITMAP space_numbers[8] = {};

/*
 ============================================================================
 	 WIN32 API ENTRYPOINT
 ============================================================================
 */
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	//Game Variables
	game_board.first_start = 1;
	play = 0;

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
        "Mine Sweeper GUI",
        WS_OVERLAPPEDWINDOW & ~WS_MAXIMIZEBOX & ~WS_THICKFRAME,
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
            	//Start New Game
            	case ID_FILE_NEW_GAME:
            		//Get Current window position
        			RECT Rect;
        			GetWindowRect(hwnd, &Rect);
        			//New Game options
                    int ret_new_game = DialogBox(GetModuleHandle(NULL), MAKEINTRESOURCE(IDD_NEW_GAME), hwnd, (DLGPROC)New_Game_DlgProc);
                    if(ret_new_game == -1)
                    {
                        MessageBox(NULL, "Window Creation Failed!", "Error!", MB_ICONEXCLAMATION | MB_OK);
                        PostMessage(hwnd, WM_CLOSE, 0, 0);
                    }
                    //Setup Game for easy options
                    else if(ret_new_game == IDP_EASY)
                    {
                    	new_game_board(EASY_X, EASY_Y, EASY_MINES);
                    	game_board.first_start = 1;
                    	play = 1;
                        int ret_timer = SetTimer(hwnd, ID_TIMER, TIME_INTERVAL, NULL);
                        if(ret_timer == 0)
                        {
                            MessageBox(hwnd, "Could not SetTimer()!", "Error", MB_OK | MB_ICONEXCLAMATION);
                        }
                        timer_value = 0;
                    	SetWindowPos(hwnd, 0, Rect.left, Rect.top, INDENT_X+EASY_X*PIXEL_X, INDENT_Y+EASY_Y*PIXEL_Y+PIXEL_Y, SWP_SHOWWINDOW);
                    	InvalidateRect(hwnd, 0, TRUE);
                    }
                    //Setup game for normal options
                    else if(ret_new_game == IDP_NORMAL)
                    {
                    	new_game_board(NORMAL_X, NORMAL_Y, NORMAL_MINES);
                    	game_board.first_start = 1;
                    	play = 1;
                        int ret_timer = SetTimer(hwnd, ID_TIMER, TIME_INTERVAL, NULL);
                        if(ret_timer == 0)
                        {
                            MessageBox(hwnd, "Could not SetTimer()!", "Error", MB_OK | MB_ICONEXCLAMATION);
                        }
                        timer_value = 0;
                    	SetWindowPos(hwnd, 0, Rect.left, Rect.top, INDENT_X+NORMAL_X*PIXEL_X, INDENT_Y+NORMAL_Y*PIXEL_Y+PIXEL_Y, SWP_SHOWWINDOW);
                    	InvalidateRect(hwnd, 0, TRUE);
                    }
                    //Setup game for hard options
                    else if(ret_new_game == IDP_HARD)
                    {
                    	new_game_board(HARD_X, HARD_Y, HARD_MINES);
                    	game_board.first_start = 1;
                    	play = 1;
                        int ret_timer = SetTimer(hwnd, ID_TIMER, TIME_INTERVAL, NULL);
                        if(ret_timer == 0)
                        {
                            MessageBox(hwnd, "Could not SetTimer()!", "Error", MB_OK | MB_ICONEXCLAMATION);
                        }
                        timer_value = 0;
                    	SetWindowPos(hwnd, 0, Rect.left, Rect.top, INDENT_X+HARD_X*PIXEL_X, INDENT_Y+HARD_Y*PIXEL_Y+PIXEL_Y, SWP_SHOWWINDOW);
                    	InvalidateRect(hwnd, 0, TRUE);
                    }
                    //Setup game for custom options
                    else if(ret_new_game == IDP_CUSTOM)
                    {
                    	int ret_custom_game = DialogBox(GetModuleHandle(NULL), MAKEINTRESOURCE(IDD_CUSTOM_GAME), hwnd, (DLGPROC)Custom_Game_DlgProc);
                        if(ret_custom_game == -1)
                        {
                            MessageBox(NULL, "Window Creation Failed!", "Error!", MB_ICONEXCLAMATION | MB_OK);
                            PostMessage(hwnd, WM_CLOSE, 0, 0);
                        }
                        else if( ret_custom_game == IDOK)
                        {
                        	new_game_board(custom_x, custom_y, custom_mines);
                        	game_board.first_start = 1;
                        	play = 1;
                            int ret_timer = SetTimer(hwnd, ID_TIMER, TIME_INTERVAL, NULL);
                            if(ret_timer == 0)
                            {
                                MessageBox(hwnd, "Could not SetTimer()!", "Error", MB_OK | MB_ICONEXCLAMATION);
                            }
                            timer_value = 0;
                        	SetWindowPos(hwnd, 0, Rect.left, Rect.top, INDENT_X+custom_x*PIXEL_X, INDENT_Y+custom_y*PIXEL_Y+PIXEL_Y, SWP_SHOWWINDOW);
                        	InvalidateRect(hwnd, 0, TRUE);
                        }
                    }
            		break;
            	//Allows to replay last game
            	case ID_FILE_REPLAY_GAME:
                    int ret_replay_game = DialogBox(GetModuleHandle(NULL), MAKEINTRESOURCE(IDD_REPLAY_GAME), hwnd, (DLGPROC)STD_DlgProc);
                    if(ret_replay_game == -1)
                    {
                        MessageBox(NULL, "Window Creation Failed!", "Error!", MB_ICONEXCLAMATION | MB_OK);
                        PostMessage(hwnd, WM_CLOSE, 0, 0);
                    }
                    else if(ret_replay_game == IDOK)
                    {
                    	//Check if there was previous game
                    	if(game_board.first_start == 1)
                    	{
                    		break;
                    	}
                    	play = 1;
                    	game_board.lost = 0;
                    	game_board.remain_mines = game_board.mines;
                    	//Cover up the board
                    	for( int index_x = 0; index_x < game_board.x; index_x++)			//Cycle
                    	{
                    		for(int index_y = 0; index_y < game_board.y; index_y++)			//Cycle
                    		{
                    			if(game_board.game_board[index_x][index_y] == 'B')			//Reset 'B' to '0'
                    			{
                    				game_board.game_board[index_x][index_y] = '0';
                    			}
                    			if(game_board.game_board[index_x][index_y] >= '1' && game_board.game_board[index_x][index_y] < '9')	//Reset numbers to '0'
                    			{
                    				game_board.game_board[index_x][index_y] = '0';
                    			}
                    			if(game_board.flag_board[index_x][index_y] == 'F')
                    			{
                    				game_board.flag_board[index_x][index_y] = '0';
                    			}
                    		}
                    	}
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
    	case WM_CREATE:
    		blank_space = LoadBitmap(GetModuleHandle(NULL), MAKEINTRESOURCE(IDB_BLANK_SPACE));
            if(blank_space == NULL)
            {
                MessageBox(hwnd, "Could not load blank_space", "Error", MB_OK | MB_ICONEXCLAMATION);
            }
    		blank_space_empty = LoadBitmap(GetModuleHandle(NULL), MAKEINTRESOURCE(IDB_BLANK_SPACE_EMPTY));
            if(blank_space_empty == NULL)
            {
                MessageBox(hwnd, "Could not load blank_space_empty", "Error", MB_OK | MB_ICONEXCLAMATION);
            }
    		mine_black = LoadBitmap(GetModuleHandle(NULL), MAKEINTRESOURCE(IDB_MINE_BLACK));
            if(mine_black == NULL)
            {
                MessageBox(hwnd, "Could not load mine_black", "Error", MB_OK | MB_ICONEXCLAMATION);
            }
    		mine_red = LoadBitmap(GetModuleHandle(NULL), MAKEINTRESOURCE(IDB_MINE_RED));
            if(mine_red == NULL)
            {
                MessageBox(hwnd, "Could not load mine_red", "Error", MB_OK | MB_ICONEXCLAMATION);
            }
    		space_flag = LoadBitmap(GetModuleHandle(NULL), MAKEINTRESOURCE(IDB_SPACE_FLAG));
            if(space_flag == NULL)
            {
                MessageBox(hwnd, "Could not load sapce_flag", "Error", MB_OK | MB_ICONEXCLAMATION);
            }
            for(int index_create = 0; index_create < 8; index_create++)
            {
            	space_numbers[index_create] = LoadBitmap(GetModuleHandle(NULL), MAKEINTRESOURCE(IDB_SPACE_1 + index_create));
                if(space_numbers[index_create] == NULL)
                {
                    MessageBox(hwnd, "Could not load sapce_number", "Error", MB_OK | MB_ICONEXCLAMATION);
                }
            }
    	break;
    	// Paint graphics to screen
    	case WM_PAINT:
    			PAINTSTRUCT ps;

    			RECT rcWindow;
				GetClientRect(hwnd, &rcWindow);

				BITMAP bm_blank_space;
				BITMAP bm_blank_space_empty;
				BITMAP bm_mine_black;
				BITMAP bm_mine_red;
				BITMAP bm_space_flag;
				BITMAP bm_space_numbers[8];

				HDC hdc = BeginPaint(hwnd, &ps);

				HDC hdcMem_blank_space = CreateCompatibleDC(hdc);
				HDC hdcMem_blank_space_empty = CreateCompatibleDC(hdc);
				HDC hdcMem_mine_black = CreateCompatibleDC(hdc);
				HDC hdcMem_mine_red = CreateCompatibleDC(hdc);
				HDC hdcMem_space_flag = CreateCompatibleDC(hdc);
				HDC hdcMem_space_numbers[8];
				for(int index_hdc_mem = 0; index_hdc_mem < 8 ; index_hdc_mem++)
				{
					hdcMem_space_numbers[index_hdc_mem]= CreateCompatibleDC(hdc);
				}


				HBITMAP hbmOld_blank_space = SelectObject(hdcMem_blank_space, blank_space);
				HBITMAP hbmOld_blank_space_empty = SelectObject(hdcMem_blank_space_empty, blank_space_empty);
				HBITMAP hbmOld_mine_black = SelectObject(hdcMem_mine_black, mine_black);
				HBITMAP hbmOld_mine_red = SelectObject(hdcMem_mine_red, mine_red);
				HBITMAP hbmOld_space_flag = SelectObject(hdcMem_space_flag, space_flag);
				HBITMAP hbmOld_space_numbers[8];
				for(int index_hbm_old = 0; index_hbm_old < 8 ; index_hbm_old++)
				{
					hbmOld_space_numbers[index_hbm_old] = SelectObject(hdcMem_space_numbers[index_hbm_old], space_numbers[index_hbm_old]);
				}


				GetObject(blank_space, sizeof(bm_blank_space), &bm_blank_space);
				GetObject(blank_space_empty, sizeof(bm_blank_space_empty), &bm_blank_space_empty);
				GetObject(mine_black, sizeof(bm_mine_black), &bm_mine_black);
				GetObject(mine_red, sizeof(bm_mine_red), &bm_mine_red);
				GetObject(space_flag, sizeof(bm_space_flag), &bm_space_flag);

				for(int index_get = 0; index_get < 8; index_get++)
				{
					GetObject(space_numbers[index_get], sizeof(bm_space_numbers[index_get]), &bm_space_numbers[index_get]);
				}

				if(play == 1 || game_board.lost > 0)
				{
					for(int index_x = 0; index_x < game_board.x; index_x ++)							//Cycle
					{
						for(int index_y = 0; index_y < game_board.y; index_y++)							//Cycle
						{
							if(game_board.lost == 1)													//Formating for end of game
							{
								if(game_board.l_x == index_x && game_board.l_y == index_y)				//Display loosing move differently
								{
									BitBlt(hdc, INDENT_X+index_x*bm_mine_red.bmWidth, INDENT_Y+index_y*bm_mine_red.bmHeight,
											bm_mine_red.bmWidth, bm_mine_red.bmHeight, hdcMem_mine_red, 0, 0, SRCCOPY);
								}
								else if(game_board.game_board[index_x][index_y] == 'M')					//Print all mines
								{
									BitBlt(hdc, INDENT_X+index_x*bm_mine_black.bmWidth, INDENT_Y+index_y*bm_mine_black.bmHeight,
											bm_mine_black.bmWidth, bm_mine_black.bmHeight, hdcMem_mine_black, 0, 0, SRCCOPY);
								}
								else
								{
									if(game_board.game_board[index_x][index_y] == 'B' || game_board.game_board[index_x][index_y] == '0')	//Print blank fields
									{
										BitBlt(hdc, INDENT_X+index_x*bm_blank_space_empty.bmWidth, INDENT_Y+index_y*bm_blank_space_empty.bmHeight,
												bm_blank_space_empty.bmWidth, bm_blank_space_empty.bmHeight, hdcMem_blank_space_empty, 0, 0, SRCCOPY);
									}
									if(game_board.game_board[index_x][index_y] > '0' && game_board.game_board[index_x][index_y] < '9')		//Print numbered fields
									{
										BitBlt(hdc, INDENT_X+index_x*bm_space_numbers[game_board.game_board[index_x][index_y] - 1 -'0'].bmWidth,
												INDENT_Y+index_y*bm_space_numbers[game_board.game_board[index_x][index_y] - 1 -'0'].bmHeight,
												bm_space_numbers[game_board.game_board[index_x][index_y] - 1 -'0'].bmWidth,
												bm_space_numbers[game_board.game_board[index_x][index_y] - 1 -'0'].bmHeight,
												hdcMem_space_numbers[game_board.game_board[index_x][index_y] - 1 -'0'], 0, 0, SRCCOPY);
									}
								}
							}
							else if(game_board.flag_board[index_x][index_y] == 'F')						//Print flags
							{
								BitBlt(hdc, INDENT_X+index_x*bm_space_flag.bmWidth, INDENT_Y+index_y*bm_space_flag.bmHeight,
										bm_space_flag.bmWidth, bm_space_flag.bmHeight, hdcMem_space_flag, 0, 0, SRCCOPY);
							}
							else if(game_board.game_board[index_x][index_y] != 'M')						//Print numbered fields
							{
								if(game_board.game_board[index_x][index_y] == 'B')
								{
									BitBlt(hdc, INDENT_X+index_x*bm_blank_space_empty.bmWidth, INDENT_Y+index_y*bm_blank_space_empty.bmHeight,
											bm_blank_space_empty.bmWidth, bm_blank_space_empty.bmHeight, hdcMem_blank_space_empty, 0, 0, SRCCOPY);
								}
								if(game_board.game_board[index_x][index_y] == '0')
								{
									BitBlt(hdc, INDENT_X+index_x*bm_blank_space.bmWidth, INDENT_Y+index_y*bm_blank_space.bmHeight,
											bm_blank_space.bmWidth, bm_blank_space.bmHeight, hdcMem_blank_space, 0, 0, SRCCOPY);
								}
								if(game_board.game_board[index_x][index_y] > '0' && game_board.game_board[index_x][index_y] < '9')
								{
									BitBlt(hdc, INDENT_X+index_x*bm_space_numbers[game_board.game_board[index_x][index_y] - 1 -'0'].bmWidth,
											INDENT_Y+index_y*bm_space_numbers[game_board.game_board[index_x][index_y] - 1 -'0'].bmHeight,
											bm_space_numbers[game_board.game_board[index_x][index_y] - 1 -'0'].bmWidth,
											bm_space_numbers[game_board.game_board[index_x][index_y] - 1 -'0'].bmHeight,
											hdcMem_space_numbers[game_board.game_board[index_x][index_y] - 1 -'0'], 0, 0, SRCCOPY);
								}

							}
							else
							{
								BitBlt(hdc, INDENT_X+index_x*bm_blank_space.bmWidth, INDENT_Y+index_y*bm_blank_space.bmHeight,
										bm_blank_space.bmWidth, bm_blank_space.bmHeight, hdcMem_blank_space, 0, 0, SRCCOPY);
							}

						}
					}
				}

				if(play == 1 || game_board.lost > 0)
				{
					RECT r_left, r_right, r_top, r_bottom;

					r_left.left = rcWindow.left;
					r_left.right = INDENT_X;
					r_left.top = INDENT_Y;
					r_left.bottom = INDENT_Y+game_board.y*BITMAP_PIXEL_Y;

					r_right.left = INDENT_X+game_board.x*BITMAP_PIXEL_X;
					r_right.right = rcWindow.right;
					r_right.top = INDENT_Y;
					r_right.bottom = INDENT_Y+game_board.y*BITMAP_PIXEL_Y;

					r_top.top = rcWindow.top;
					r_top.bottom = INDENT_Y;
					r_top.left = rcWindow.left;
					r_top.right = rcWindow.right;

					r_bottom.top = INDENT_Y+game_board.y*BITMAP_PIXEL_Y;
					r_bottom.bottom = rcWindow.bottom;
					r_bottom.left = rcWindow.left;
					r_bottom.right = rcWindow.right;

					HGDIOBJ original = NULL;
					original = SelectObject(hdc,GetStockObject(DC_PEN));

					SelectObject(hdc, GetStockObject(DC_PEN));
					SelectObject(hdc, GetStockObject(DC_BRUSH));
					SetDCBrushColor(hdc, window_bgd);
					SetDCPenColor(hdc, window_bgd);

					Rectangle(hdc, r_left.left, r_left.top, r_left.right, r_left.bottom);
					Rectangle(hdc, r_right.left, r_right.top, r_right.right, r_right.bottom);
					Rectangle(hdc, r_top.left, r_top.top, r_top.right, r_top.bottom);
					Rectangle(hdc, r_bottom.left, r_bottom.top, r_bottom.right, r_bottom.bottom);

					char message_str[30];
					sprintf(message_str, "Mines remaining: %d", game_board.remain_mines);

					SetTextColor(hdc, mines_rgbText);
					SetBkMode(hdc, TRANSPARENT);

					TextOut(hdc, INDENT_X+10, INDENT_Y+game_board.y*BITMAP_PIXEL_Y, TEXT(message_str) ,strlen(message_str));

					unsigned long hours = timer_value / 3600;
					unsigned long mins = ( timer_value - (hours * 3600) ) / 60;
					unsigned long secs = timer_value - (hours * 3600) - (mins * 60);

					char message_str_timer[30];
					sprintf(message_str_timer, "Time: %02lu:%02lu:%02lu", hours, mins, secs);

					SetTextColor(hdc, timer_rgbText);
					SetBkMode(hdc, TRANSPARENT);

					TextOut(hdc, INDENT_X+10, INDENT_Y+game_board.y*BITMAP_PIXEL_X+BITMAP_PIXEL_X, TEXT(message_str_timer) ,strlen(message_str_timer));

					SelectObject(hdc,original);
				}
				else
				{
					HGDIOBJ original = NULL;
					original = SelectObject(hdc,GetStockObject(DC_PEN));

					SelectObject(hdc, GetStockObject(DC_PEN));
					SelectObject(hdc, GetStockObject(DC_BRUSH));
					SetDCBrushColor(hdc, window_bgd);
					SetDCPenColor(hdc, window_bgd);

					Rectangle(hdc, rcWindow.left, rcWindow.top, rcWindow.right, rcWindow.bottom);
					SelectObject(hdc,original);
				}

				SelectObject(hdcMem_blank_space, hbmOld_blank_space);
				SelectObject(hdcMem_blank_space_empty, hbmOld_blank_space_empty);
				SelectObject(hdcMem_mine_black, hbmOld_mine_black);
				SelectObject(hdcMem_mine_red, hbmOld_mine_red);
				SelectObject(hdcMem_space_flag, hbmOld_space_flag);
				for(int index_sel = 0; index_sel < 8; index_sel++)
				{
					SelectObject(hdcMem_space_numbers[index_sel], hbmOld_space_numbers[index_sel]);
				}

				DeleteDC(hdcMem_blank_space);
				DeleteDC(hdcMem_blank_space_empty);
				DeleteDC(hdcMem_mine_black);
				DeleteDC(hdcMem_mine_red);
				DeleteDC(hdcMem_space_flag);
				for(int index_del; index_del < 8; index_del++)
				{
					DeleteDC(hdcMem_space_numbers[index_del]);
				}

				EndPaint(hwnd, &ps);
    	break;
    	//Reduce flickering
    	case WM_ERASEBKGND:
    	{
    	    return TRUE;
    	}
    	//Left click to play
    	case WM_LBUTTONDOWN:
    		if(play == 1)
    		{
    			POINT mouse_point;

				int x = 0;
				int y = 0;

				GetCursorPos(&mouse_point);
				ScreenToClient(hwnd, &mouse_point);

				x = (mouse_point.x-INDENT_X) / BITMAP_PIXEL_X;
				y = (mouse_point.y-INDENT_Y) / BITMAP_PIXEL_Y;

				if(x > game_board.x || y > game_board.y || x < 0 || y < 0)
				{
					break;
				}

				if(game_board.flag_board[x][y] == 'F')
				{
					break;
				}

    			if(game_board.first_start == 1)
    			{
    				game_board.first_start = 0;

    				time_t t;													//Time variable for rand() seed
    				int mines = game_board.mines;								//Get number of mines
    				int x_rand = 0;												//x for rand
    				int y_rand = 0;												//y for rand

    				game_board.game_board[x][y] = 'B';							//Sets first move as not a mine


    				srand((unsigned) time(&t));									//Seed rand function with current time

    				while (mines > 0)											//While not all mines generated
    				{
    					x_rand = rand() % game_board.x;							//Random x mod size of board
    					y_rand = rand() % game_board.y;							//random y mod size of board

    					if(game_board.game_board[x_rand][y_rand] == '0')		//Make sure only to generate mines on empty and not duplicate
    					{
    						game_board.game_board[x_rand][y_rand] = 'M';
    						mines--;
    					}
    				}

    				game_board_reveal(x, y);									//Make first move to reveal board

    				copy_game_board = game_board;
    			}
    			else
    			{
    				game_board_reveal(x, y);									//Check move and reveal board

    				int count = 0;

    				for( int index_x = 0; index_x < game_board.x; index_x++)			//Cycle
    				{
    					for(int index_y = 0; index_y < game_board.y; index_y++)			//Cycle
    					{
    						if(game_board.game_board[index_x][index_y] == '0')			//Count unraveled spaces
    						{
    							count++;
    						}
    					}
    				}

    				if(count == 0)														//If no spaces remain
    				{
    					game_board.lost = 2;											//Set game over to won
    				}
    			}
    			if(game_board.lost == 1)
    			{
    				KillTimer(hwnd, ID_TIMER);
    				play = 0;

    				for( int index_x = 0; index_x < game_board.x; index_x++)			//Cycle
    				{
    					for(int index_y = 0; index_y < game_board.y; index_y++)			//Cycle
    					{
    						if(game_board.game_board[index_x][index_y] == '0')			//Count unraveled spaces
    						{
    							game_board_reveal(index_x, index_y);
    						}
    					}
    				}

    				InvalidateRect(hwnd, 0, TRUE);
                    int ret_lost = DialogBox(GetModuleHandle(NULL), MAKEINTRESOURCE(IDD_GAME_OVER), hwnd, (DLGPROC)STD_DlgProc);
                    if(ret_lost == -1)
                    {
                        MessageBox(NULL, "Window Creation Failed!", "Error!", MB_ICONEXCLAMATION | MB_OK);
                        PostMessage(hwnd, WM_CLOSE, 0, 0);
                    }
    			}
    			if(game_board.lost == 2)
    			{
    				KillTimer(hwnd, ID_TIMER);
    				play = 0;
    				InvalidateRect(hwnd, 0, TRUE);
                    int ret_won = DialogBox(GetModuleHandle(NULL), MAKEINTRESOURCE(IDD_GAME_WON), hwnd, (DLGPROC)STD_DlgProc);
                    if(ret_won == -1)
                    {
                        MessageBox(NULL, "Window Creation Failed!", "Error!", MB_ICONEXCLAMATION | MB_OK);
                        PostMessage(hwnd, WM_CLOSE, 0, 0);
                    }
    			}
    		}
    		InvalidateRect(hwnd, 0, TRUE);
    	break;
    	//Right click for flag
    	case WM_RBUTTONDOWN:
    		if(play ==1)
    		{
    			POINT mouse_point;

				int x = 0;
				int y = 0;

				GetCursorPos(&mouse_point);
				ScreenToClient(hwnd, &mouse_point);

				y = (mouse_point.x-INDENT_X) / BITMAP_PIXEL_X;
				x = (mouse_point.y-INDENT_Y) / BITMAP_PIXEL_Y;

				if(x > game_board.x || y > game_board.y || x < 0 || y < 0)
				{
					break;
				}


				if(game_board.game_board[y][x] != '0' && game_board.game_board[y][x] != 'M' )
				{
					break;
				}
				if(game_board.flag_board[y][x] == 'F')					//If flag remove
				{
					game_board.flag_board[y][x] = '0';
					game_board.remain_mines++;
				}
				else if(game_board.flag_board[y][x] == '0')				//If no flag add
				{
					if(game_board.remain_mines == 0)							//Check to not more flags than mines are set
					{
						break;
					}
					game_board.flag_board[y][x] = 'F';
					game_board.remain_mines--;
				}

				if(game_board.remain_mines == 0)
				{
					int won = 0;														//Set to not won

					for( int index_x = 0; index_x < game_board.x; index_x++)			//Cycle
					{
						for(int index_y = 0; index_y < game_board.y; index_y++)			//cycle
						{
							if (game_board.flag_board[index_x][index_y] == 'F')			//if flag at this location
							{
								if(game_board.game_board[index_x][index_y] == 'M')		//check for mine
								{
									won++;											//if mine set to won
								}
							}
						}
					}
					if(won == game_board.mines)														//If won game
					{
						game_board.lost = 2;											//Set game over to won
					}
				}
    			if(game_board.lost == 2)
    			{
    				play = 0;
    				KillTimer(hwnd, ID_TIMER);
    				InvalidateRect(hwnd, 0, TRUE);
                    int ret_won = DialogBox(GetModuleHandle(NULL), MAKEINTRESOURCE(IDD_GAME_WON), hwnd, (DLGPROC)STD_DlgProc);
                    if(ret_won == -1)
                    {
                        MessageBox(NULL, "Window Creation Failed!", "Error!", MB_ICONEXCLAMATION | MB_OK);
                        PostMessage(hwnd, WM_CLOSE, 0, 0);
                    }
    			}
				InvalidateRect(hwnd, 0, TRUE);
    		}
    	break;
    	//Timer counting is seconds
    	case WM_TIMER:
    		{
    			timer_value++;
    		}
    		InvalidateRect(hwnd, 0, TRUE);
    		break;
    	//Close window
        case WM_CLOSE:
        	if ( MessageBox( hwnd, "Are you sure you want to quit?", "Confirmation", MB_ICONQUESTION | MB_YESNO ) == IDYES )
        	{
        		DestroyWindow(hwnd);
        	}
        break;
        //cleanup
        case WM_DESTROY:
        	clear_game_board();
        	KillTimer(hwnd, ID_TIMER);
        	DeleteObject(blank_space);
        	DeleteObject(blank_space_empty);
        	DeleteObject(mine_black);
        	DeleteObject(mine_red);
        	for(int index = 0; index < 8; index++)
        	{
            	DeleteObject(space_numbers[index]);
        	}
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
 	 Callback for new game message box
 ============================================================================
 */
BOOL CALLBACK New_Game_DlgProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam)
{
    switch(Message)
    {
        case WM_INITDIALOG:

        return TRUE;
        case WM_COMMAND:
            switch(LOWORD(wParam))
            {
                case IDP_EASY:
                    EndDialog(hwnd, IDP_EASY);
                break;
                case IDP_NORMAL:
                    EndDialog(hwnd, IDP_NORMAL);
                break;
                case IDP_HARD:
                    EndDialog(hwnd, IDP_HARD);
                break;
                case IDP_CUSTOM:
                    EndDialog(hwnd, IDP_CUSTOM);
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
BOOL CALLBACK Custom_Game_DlgProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam)
{
    switch(Message)
    {
        case WM_INITDIALOG:

        return TRUE;
        case WM_COMMAND:
            switch(LOWORD(wParam))
            {
                case IDOK:
                	TCHAR buff_X[BUFFER_INT] = {0};
                	GetDlgItemText(hwnd, IDE_CUSTOM_X, buff_X, 1024);
                	TCHAR buff_Y[BUFFER_INT] = {0};
                	GetDlgItemText(hwnd, IDE_CUSTOM_Y, buff_Y, 1024);
                	TCHAR buff_mines[BUFFER_INT] = {0};
                	GetDlgItemText(hwnd, IDE_CUSTOM_MINES, buff_mines, 1024);

                	int x = 0;
                	int y = 0;
                	int mines = 0;

                	sscanf(buff_X, "%d", &x);
                	sscanf(buff_Y, "%d", &y);
                	sscanf(buff_mines, "%d", &mines);

                	if(mines < MIN_MINES)														//Check for min values
                	{
                		mines = MIN_MINES;
                	}
                	if(x < MIN_X)
                	{
                		x = MIN_X;
                	}
                	if(y < MIN_Y)
                	{
                		y = MIN_Y;
                	}

                 	if(mines > MAX_MINES)														//Check for min values
					{
						mines = MAX_MINES;
					}
                 	if(mines > x*y)
                 	{
                 		mines = x*y - 2;														//Ensure they dont just auto win
                 	}


					if(x > MAX_X)
					{
						x = MAX_X;
					}
					if(y > MAX_Y)
					{
						y = MAX_Y;
					}

                	custom_x = x;
                	custom_y = y;
                	custom_mines = mines;

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
 	 Function to make a new game board
 ============================================================================
 */
void new_game_board(int x, int y, int mines)
{
	game_board.x = 0;													//Initialize 0
	game_board.y = 0;													//Initialize 0
	game_board.mines = 0;												//Initialize 0
	game_board.remain_mines = 0;										//Initialize 0
	game_board.lost = 0;												//Initialize 0
	game_board.l_x = 0;
	game_board.l_y = 0;
	game_board.first_start = 1;

	int ** game_board_int = malloc(x*sizeof(int *));					//Create 2D pointer array of int and allocate memory
	for(int index = 0; index < x; index++)								//Cycle
	{
		game_board_int[index] = malloc(y*sizeof(int *));				//Allocate memory
	}

	for(int index_x = 0; index_x < x; index_x++)						//Cycle All
	{
		for(int index_y = 0; index_y < y; index_y++)					//Cycle
		{
			game_board_int[index_x][index_y] = '0';						//Initialize '0'
		}
	}
	int ** flag_board_int = malloc(x*sizeof(int *));					//Create 2D pointer array of int and allocate memory
	for(int index = 0; index < x; index++)								//Cycle
	{
		flag_board_int[index] = malloc(y*sizeof(int *));				//Allocate Memory
	}

	for(int index_x = 0; index_x < x; index_x++)						//Cycle All
	{
		for(int index_y = 0; index_y < y; index_y++)					//Cycle
		{
			flag_board_int[index_x][index_y] = '0';						//Initialise '0'
		}
	}
	game_board.game_board = game_board_int;								//Assign allocated memory
	game_board.flag_board = flag_board_int;								//Assign allocated memory
	game_board.x = x;													//Assign x from input
	game_board.y = y;													//Assign y from input
	game_board.mines = mines;											//Assign mines from input
	game_board.remain_mines = mines;									//Assign equal to mines

	return;													//Return game_board structure
}


/*
 ============================================================================
 	Function to free memory
 ============================================================================
 */
void clear_game_board()
{
	free(game_board.game_board);										//Free memory
	free(game_board.flag_board);										//Free Memory
	return;
}

/*
 ============================================================================
 	Function to reveal parts of the board, calls a recursive function
 ============================================================================
 */
void game_board_reveal(int x, int y)
{
	if(game_board.game_board[x][y] == 'M')				//If move hit mine
	{
		game_board.lost = 1;							//Game over and lost
		game_board.l_x = x;								//x of losing move
		game_board.l_y = y;								//y of losing move
		return;								//return board
	}

	reveal_r(x, y);						//Call recursive function with move

	return;												//Return
}

/*
 ============================================================================
 	 Recursive function to check adjacent cells
 ============================================================================
 */
void reveal_r(int x, int y)
{
	int count = 0;																										//Set count to zero

	for(int index = 0; index < 8; index++)																				//Cycle surrounding mines
	{
		int x1 = x + adjacents[index][0];
		int y1 = y + adjacents[index][1];

		if( x1 >= 0 && y1 >= 0 && x1 < game_board.x && y1 < game_board.y && game_board.game_board[x1][y1] == 'M')	//Count mines
		{
			count++;
		}
	}

	if(count > 0)																										//If mines found
	{
		game_board.game_board[x][y] = count + '0';																		//Store value
		game_board.flag_board[x][y] = '0';
		return;																											//Exit
	}

	game_board.game_board[x][y] = 'B';																					//If no mines found set to 'B'
	game_board.flag_board[x][y] = '0';

	for(int index = 0; index < 8; index++)																				//Cycle surrounding fields
	{
		int x1 = x + adjacents[index][0];
		int y1 = y + adjacents[index][1];

		if( x1 >= 0 && y1 >= 0 && x1 < game_board.x && y1 < game_board.y && game_board.game_board[x1][y1] == '0')	//If not revealed yet
		{
			reveal_r(x1, y1);																				//Recursive call
		}
	}
	return;
}
