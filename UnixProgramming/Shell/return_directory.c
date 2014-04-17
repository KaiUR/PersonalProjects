#include "comp20200Shell_header.h"

/*
 * Name: Kai - Uwe Rathjen
 * Student Number: 12343046
 * Email: kai-uwe.rathjen@ucdconnect.ie
 *
 * This function is used to return the current working directory.
 * The cwd is stored in a char** varible, that needs to be freed after use
 *
 * return: The current working directory
 * arguments: none
 *
 */
char* return_current_directory(void)
{
	char temp_current_directory[BUFFER_SIZE];
	char* current_directory = (char*) malloc(sizeof(char) * BUFFER_SIZE);
	if(current_directory == NULL)
	{
		error("ERROR - Could not allocate memory");
	}
	
	if(getcwd(temp_current_directory, sizeof(temp_current_directory)) == NULL)
	{
		error("error with geting the cwd");
	}

	char* home = getenv("HOME");
	strcpy(current_directory, temp_current_directory);

	/* This compresses the path in "HOME" into '~' */
	if(strcmp(current_directory, home) == 0)
	{
		free(current_directory);
		current_directory = (char*)malloc(sizeof(char) * 2);
		if(current_directory == NULL)
		{
			error("ERROR - Could not allocate memory");
		}
		strcpy(current_directory, "~");
	}
	else if(strstr(current_directory, home) != NULL)
	{
		memmove(current_directory, current_directory + strlen(home) , 1 + strlen(current_directory + strlen(home)));
		char* temp_temp = (char*)calloc(2 + BUFFER_SIZE, sizeof(char) * 2 + BUFFER_SIZE);
		if(temp_temp == NULL)
		{
			error("ERROR - Could not allocate memory");
		}
		strcpy(temp_temp, "~");
		strcat(temp_temp, current_directory);
		return(temp_temp);
	}
	
	return(current_directory);
}


