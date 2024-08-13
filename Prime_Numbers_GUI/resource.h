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
#define IDD_NEW 303

/*
 ============================================================================
 	Menu option ID
 ============================================================================
 */
#define ID_FILE_EXIT 9001
#define ID_FILE_NEW 9002
#define ID_HELP_HELP 9003
#define ID_HELP_ABOUT 9004

/*
 ============================================================================
 	EDIT ID
 ============================================================================
 */
#define IDE_INPUT_NUMBER 601

/*
 ============================================================================
 	DEFENITIONS
 ============================================================================
 */
#define MAIN_WINDO_WIDTH 1024
#define MAIN_WINDO_HEIGHT 768
#define BUFFER_INT 1024

/*
 ============================================================================
 	Function prototypes
 ============================================================================
 */
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow);
LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam);
BOOL CALLBACK STD_DlgProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam);
BOOL CALLBACK new_DlgProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam);
void caculate_primes(int current_n);


#endif /* RESOURCE_H_ */
