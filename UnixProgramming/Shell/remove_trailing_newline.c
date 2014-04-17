#include "comp20200Shell_header.h"

/*
 * Name: Kai - Uwe Rathjen
 * Student Number: 12343046
 * Email: kai-uwe.rathjen@ucdconnect.ie
 *
 * This function is used to remove all newline characters if it exists from a string, 
 * since getline is used in this program this is not a problem, there will be only one
 * newline character.
 *
 * return: void
 * arguments: A string of type char*
 *
 */
void remove_trailing_newline(char* input)
{
	int index;
	for(index = 0; input[index] != '\0'; index++)
	{
		if(input[index] == '\n')
		{
			input[index] = '\0';
		}
	}
	
	return;
}
