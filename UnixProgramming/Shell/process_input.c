#include "comp20200Shell_header.h"
#include <sys/wait.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

/*
 * Name: Kai - Uwe Rathjen
 * Student Number: 12343046
 * Email: kai-uwe.rathjen@ucdconnect.ie
 *
 * This function is used to process the command entered by the user
 *
 * return: the error value or 0 when everything whent ok
 * arguments: the command entered by the user
 *
 */
int process_input(char** input)
{
	/* Flags to redirect stderr and stdout */
	bool redirect_stdout = false;
	bool redirect_stderr = false;

	pid_t child_pid;
	int child_status;
	char** argument = (char **)malloc(sizeof(char*));
	if(argument == NULL)
	{
		error("ERROR - Could not allocate memory");
	}
	int count = 0;

	/* Separates all of the commands give and puts them into a NULL terminated array */
	char* temp = strtok(*input, " ");
	while(temp != NULL)
	{
		argument[count] = temp;
		count ++;
		argument = (char **)realloc(argument, (count+2) * sizeof(char *));
		if(argument == NULL)
		{
			error("ERROR - Could not allocate memory");
		}
		temp = strtok(NULL, " ");
	}
	argument[count] = NULL;
	
	/* If no input exit */
	if(argument[0] == NULL)
	{
		return(0);
	}
	/* If cd was entered call change_directory(char **) function with first command after the cd */
	else if(strcmp(argument[0], "cd") == 0)
	{
		return(change_directory(argument[1]));
	}
	
	/* Checks for >0 and >2 and sets flags */
	int index;
	for(index = 1; argument[index] != NULL; index++)
	{
		if(strcmp(argument[index], ">") == 0)
		{
			if(argument[index + 1] == NULL)
			{
				return(EINVAL);
			}
			redirect_stdout = true;
			break;
		}
		else if(strcmp(argument[index], ">2") == 0)
		{
			if(argument[index + 1] == NULL)
			{
				return(EINVAL);
			}
			redirect_stderr = true;
			break;
		}
	}

	/* Forks the program */
	child_pid = fork();
	if(child_pid == 0)
	{
		/* Redirects stdout */
		int file;
		if(redirect_stdout == true)
		{
			file = open(argument[index + 1], O_WRONLY|O_CREAT|O_TRUNC, 0666);
			if(file < 0)
			{
				fprintf(stderr, "%s: ", argument[index + 1]);
				exit(FILE_OPEN_ERROR);	
			}
			dup2(file, 1);
			close(file);
			edit_arguments(argument, index);
			execvp(argument[0], argument);
			fprintf(stderr, "%s: ", argument[0]);
			exit(EXIT_FAILURE);
		}
		/* Redirects stderr */
		else if(redirect_stderr == true)
		{
			file = open(argument[index + 1], O_WRONLY|O_CREAT|O_TRUNC, 0666);
			if(file < 0)
			{
				fprintf(stderr, "%s: ", argument[index + 1]);
				exit(FILE_OPEN_ERROR);	
			}
			dup2(file, 2);
			close(file);
			edit_arguments(argument, index);
			execvp(argument[0], argument);
			fprintf(stderr, "%s: ", argument[0]);
    			exit(EXIT_FAILURE);
		}

		/* If no redirect, normaly calls a program */
		execvp(argument[0], argument);
		fprintf(stderr, "%s: ", argument[0]);
		exit(EXIT_FAILURE);
	}
	else
	{
		/* Parent waits for child to finish */
		wait(&child_status);
	}

	return(child_status);
}

	

	
