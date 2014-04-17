#include "comp20200Shell_header.h"
#include <stdarg.h>

/*
 * Name: Kai - Uwe Rathjen
 * Student Number: 12343046
 * Email: kai-uwe.rathjen@ucdconnect.ie
 *
 * This function is used to print an error mesage and to exit the program
 *
 * return: void
 * arguments: a string followed by arguments (arguments are optional)
 *
 */
void error(const char *fmt, ...)
{
	va_list args;
	va_start(args, fmt);
	vprintf(fmt, args);
	va_end(args);
	exit(EXIT_FAILURE);
}
