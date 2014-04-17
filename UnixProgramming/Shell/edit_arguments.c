#include "comp20200Shell_header.h"

/*
 * Name: Kai - Uwe Rathjen
 * Student Number: 12343046
 * Email: kai-uwe.rathjen@ucdconnect.ie
 *
 * This function is used to delete all values in an array of strings after a given index
 *
 * return: void
 * arguments: an array of strings and an index from where onwards to clear it
 *
 */
void edit_arguments(char** argument, int index)
{
	int index_2;
	for(index_2 = index; argument[index_2] != NULL; index_2++)
	{
		argument[index_2] = NULL;
	}
	
	return;
}
