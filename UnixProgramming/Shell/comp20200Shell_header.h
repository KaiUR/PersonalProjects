/*
 * Name: Kai - Uwe Rathjen
 * Student Number: 12343046
 * Email: kai-uwe.rathjen@ucdconnect.ie
 *
 * This is my header file, It includes all common used headerfiles on the top.
 * Any specific header file that is only used once will be included with the .c file that needs it.
 *
 */

/* included headerfiles begin */
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <stdbool.h>
/* included headerfiles end */

/* defenitions begin */
#define PROMPT "# "
#define BUFFER_SIZE 1024
#define UNDERLINE "\033[4m"
#define RESET "\033[0m"
#define BLUE_TEXT "\x1B[34m"
#define MAGENTA_TEXT "\x1B[35m"
#define GREEN_TEXT "\x1B[32m"
#define RESET_COLOUR "\x1B[0m"
#define ERROR_COMMAND_NOT_FOUND 256
#define FILE_OPEN_ERROR 2
#define FILE_OPEN_ERROR_CODE 512
/* defenitions end */

/* Function prototypes begin */
void remove_trailing_newline(char *input);
void sigintHandler(int sig_num);
int process_input(char** input);
char* return_time(void);
void error(const char *fmt, ...);
int change_directory(char* path);
char* return_current_directory(void);
void process_errors(int return_value);
void edit_arguments(char** argument, int index);
/* Function prototypes end */
