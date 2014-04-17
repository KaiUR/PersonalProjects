#include "comp20200Shell_header.h"
#include <signal.h>


/*
 * Name: Kai - Uwe Rathjen
 * Student Number: 12343046
 * Email: kai-uwe.rathjen@ucdconnect.ie
 *
 * This is the main function of my shell implementation.
 *
 */
int main(void)
{
	bool end_program = false;
	size_t length = 0;
	ssize_t read;
	char* current_directory = NULL;
	char* current_time = NULL;

	/* Sets up signal handler to catch SIGINT*/
	if(signal(SIGINT, sigintHandler) == SIG_ERR)
	{
		error("An error occured while setting a signal handler\n");
	}

	/* Welcome Message */
	printf("%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s", 
			BLUE_TEXT, "\n\tWellcome to my Shell",
			MAGENTA_TEXT, "\n\n\tName: ", 
			GREEN_TEXT, "Kai-Uwe Rathjen",
			MAGENTA_TEXT, "\n\tStudent Number: ",
			GREEN_TEXT, "12343046",
			MAGENTA_TEXT, "\n\tE-mail: ",
			BLUE_TEXT, 
			UNDERLINE, "kai-uwe.rathjen@ucdconnect.ie",
			RESET,
			MAGENTA_TEXT, "\n\tVersion: ",
			GREEN_TEXT, "1.0\n\n", RESET_COLOUR);
	
	/* Infinitive loop, so after command or invalid comman will prompt again*/
	while(end_program != true)
	{
		char* input = NULL;
		
		/* Gets current working directory */
		current_directory = return_current_directory();

		/* Gets current date and time */
		current_time = return_time();
		
		/* Prints Prompt */
		printf("%s\x5b%s\x5d %s%s %s%s%s", MAGENTA_TEXT, current_time, GREEN_TEXT, current_directory, BLUE_TEXT, PROMPT, RESET_COLOUR);

		/* Frees the pointers returned by return_time() and return_current_directory() */
		free(current_time);
		free(current_directory);

		/* Reads one line from standard input */
		read = getline(&input, &length, stdin);

		/* Checks if ctrl d, i.e. end of file is found or exit is typed */
		if(strcmp(input, "exit\n") == 0 || read == -1)
		{
			if(read == -1)
			{
				putchar('\n');
			}
			/* Frees input */
			free(input);
			return(0);
		}

		/* Removes newline character that will be at the end */
		remove_trailing_newline(input);

		/* Passes input to process input, and the return value is passed in to process errors */
		process_errors(process_input(&input));

		/* Frees input */
		free(input);

	}

	return(0);
}	

		
