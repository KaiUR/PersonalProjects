#include "comp20200Shell_header.h"

/*
 * Name: Kai - Uwe Rathjen
 * Student Number: 12343046
 * Email: kai-uwe.rathjen@ucdconnect.ie
 *
 * This function is used to print all error messages that are returned from void process_input(char**)
 *
 * return: void
 * arguments: The error id
 *
 */
void process_errors(int return_value)
{
	switch(return_value)
	{
		case ERROR_COMMAND_NOT_FOUND:
			fprintf(stderr, "Command not found\n");
			break;

		case FILE_OPEN_ERROR_CODE:
			fprintf(stderr, "Could not open file\n");
			break;
		
		case ENOENT:
			fprintf(stderr, "No such file or directory\n");
			break;

		case EACCES:
			fprintf(stderr, "Permmission denied\n");
			break;
			
		case EIO:
			fprintf(stderr, "An io error occured\n");
			break;

		case ENAMETOOLONG:
			fprintf(stderr, "The path is too long\n");
			break;

		case EINVAL:
			fprintf(stderr, "Invalid argument\n");
			break;

		case EXIT_SUCCESS:
			break;
		
		default:
			fprintf(stderr, "Error %i occured\n", return_value);
			break;
	}

	return;
}
