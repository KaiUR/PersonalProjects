#include "comp20200Shell_header.h"

/*
 * Name: Kai - Uwe Rathjen
 * Student Number: 12343046
 * Email: kai-uwe.rathjen@ucdconnect.ie
 *
 * This function is used to process cd calls, it will return 0 for sucess, else it will
 * return an errno
 *
 * return: the number of the error, or 0 on sucess
 * arguments: The path to go to as char*
 *
 */
int change_directory(char* path)
{
	/* Gets current working directory */
	char current_directory[BUFFER_SIZE];
	if(getcwd(current_directory, sizeof(current_directory)) == NULL)
	{
		error("error with geting the cwd");
	}

	/* If only "cd" was entered go to getenv("HOME") */
	if(path == NULL || strcmp(path, "~") == 0)
	{
		if(chdir(getenv("HOME")) == EXIT_SUCCESS)
		{
			errno = EXIT_SUCCESS;
		}
		else
		{
			fprintf(stderr, "cd: %s: ", path);
		}
		return(errno);
	}
	/* expand '~' to getenv("HOME") */
	else if(path[0] == '~')
	{
		char* temp_home = getenv("HOME");
		/* calloc because otherwise strcat will fail */
		char* home = (char*) calloc(strlen(temp_home) + strlen(path) + 1, sizeof(temp_home) + 1 + sizeof(path));
		if(home == NULL)
		{
			error("ERROR - Could not allocate memory");
		}
		strcpy(home, temp_home);
		memmove(path, path+1, strlen(path));
		strcat(home, path);
		if(chdir(home) == EXIT_SUCCESS)
		{
			errno = EXIT_SUCCESS;
		}
		else
		{
			fprintf(stderr, "cd: %s: ", home);
		}
		free(home);
		return(errno);
	}

	if(chdir(path) == EXIT_SUCCESS)
	{
		errno = EXIT_SUCCESS;
	}
	else
	{
		fprintf(stderr, "cd: %s: ", path);
	}
	return(errno);
}
