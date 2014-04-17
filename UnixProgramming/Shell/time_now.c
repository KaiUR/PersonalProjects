#include "comp20200Shell_header.h"
#include <time.h>

/*
 * Name: Kai - Uwe Rathjen
 * Student Number: 12343046
 * Email: kai-uwe.rathjen@ucdconnect.ie
 *
 * This function is used to get the current time and date of the system.
 * This time and date is stored in a char** varible, which will have to be free after use.
 *
 * return: The date and time
 * arguments: none
 *
 */
char* return_time(void)
{
	time_t now;
	struct tm *timestamp;
	char* time_now = (char*) malloc(sizeof(char) * 12);
	if(time_now == NULL)
	{
		error("ERROR - Could not allocate memory");
	}
	char temp_time[12];

	now = time(NULL);

	timestamp = localtime(&now);
	strftime(temp_time, sizeof(temp_time), "%d/%m %H:%M", timestamp);
	

	strcpy(time_now, temp_time);
	return(time_now);
}
