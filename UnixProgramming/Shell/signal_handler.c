#include "comp20200Shell_header.h"
#include <signal.h>

/*
 * Name: Kai - Uwe Rathjen
 * Student Number: 12343046
 * Email: kai-uwe.rathjen@ucdconnect.ie
 *
 * This function is used to handle the SIGINT sigle, i.e. ctrl c.
 * The signal handler is also reset here. The stdout stream is also flushed
 *
 * return: void
 * arguments: an integer value representing the signal number
 *
 */
void sigintHandler(int sig_num)
{
    if(signal(SIGINT, sigintHandler) == SIG_ERR)
    {
		error("An error occured while setting a signal handler\n");
    }  
    fflush(stdout);
    return;
}
