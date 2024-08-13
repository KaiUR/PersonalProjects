/*
 * resource.h
 *
 *  DEFENITIONS AND PROTOTYPES
 */

#ifndef RESOURCE_H_
#define RESOURCE_H_

/*
 ============================================================================
 	STATIC ID
 ============================================================================
 */
#define IDC_STATIC -1


/*
 ============================================================================
 	MENU ID
 ============================================================================
 */
#define IDR_MAIN_MENU 101

/*
 ============================================================================
 	ICON ID
 ============================================================================
 */
#define IDI_MYICON 201

/*
 ============================================================================
 	DIALOG ID
 ============================================================================
 */
#define IDD_ABOUT 301
#define IDD_HELP 302
#define IDD_NEW_GAME 303
#define IDD_REPLAY_GAME 304
#define IDD_GAME_OVER 305
#define IDD_GAME_WON 306
#define IDD_CUSTOM_GAME 307

/*
 ============================================================================
 	Menu option ID
 ============================================================================
 */
#define ID_FILE_EXIT 9001
#define ID_FILE_NEW_GAME 9002
#define ID_FILE_REPLAY_GAME 9003
#define ID_HELP_HELP 9004
#define ID_HELP_ABOUT 9005

/*
 ============================================================================
 	BUTTON ID
 ============================================================================
 */
#define IDP_EASY 401
#define IDP_NORMAL 402
#define IDP_HARD 403
#define IDP_CUSTOM 404

/*
 ============================================================================
 	BITMAP ID
 ============================================================================
 */
#define IDB_BLANK_SPACE 501
#define IDB_BLANK_SPACE_EMPTY 502
#define IDB_MINE_BLACK 503
#define IDB_MINE_RED 504
#define IDB_SPACE_1 505
#define IDB_SPACE_2 506
#define IDB_SPACE_3 507
#define IDB_SPACE_4 508
#define IDB_SPACE_5 509
#define IDB_SPACE_6 510
#define IDB_SPACE_7 511
#define IDB_SPACE_8 512
#define IDB_SPACE_FLAG 513

/*
 ============================================================================
 	EDIT ID
 ============================================================================
 */
#define IDE_CUSTOM_X 601
#define IDE_CUSTOM_Y 602
#define IDE_CUSTOM_MINES 603

/*
 ============================================================================
 	DEFENITIONS
 ============================================================================
 */
#define MAIN_WINDO_WIDTH 1024
#define MAIN_WINDO_HEIGHT 768
#define BUFFER_INT 1024
#define MIN_MINES 10
#define MIN_X 10
#define MIN_Y 10
#define MAX_MINES 999
#define MAX_X 100
#define MAX_Y 56
#define EASY_X 9
#define EASY_Y 9
#define EASY_MINES 10
#define NORMAL_X 16
#define NORMAL_Y 16
#define NORMAL_MINES 40
#define HARD_X 30
#define HARD_Y 16
#define HARD_MINES 99
#define TIME_INTERVAL 1000
#define PIXEL_X 19
#define PIXEL_Y 24
#define INDENT_X 8
#define INDENT_Y 8
#define BITMAP_PIXEL_X 16
#define BITMAP_PIXEL_Y 16

/*
 ============================================================================
 	Function prototypes
 ============================================================================
 */
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow);
LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam);
BOOL CALLBACK STD_DlgProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam);
BOOL CALLBACK New_Game_DlgProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam);
BOOL CALLBACK Custom_Game_DlgProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam);
void new_game_board(int x, int y, int mines);
void clear_game_board(void);
void game_board_reveal(int x, int y);
void reveal_r(int x, int y);

/*
 ============================================================================
 	Structure definition
 ============================================================================
 */
struct game_board_s
{
	int ** game_board;
	int ** flag_board;
	int x;
	int y;
	int mines;
	int remain_mines;
	int lost;
	int l_x;
	int l_y;
	int first_start;
};

#endif /* RESOURCE_H_ */
