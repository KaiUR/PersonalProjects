/*
 * substitution_cipher.c
 *
 *  Created on: 19 Apr 2014
 *      Author: Kai Rathjen
 */
#include <stdio.h>
#include <stdlib.h>

#define BUFFER 256
#define INPUTFILE "C:/Eclypse_Workspace/cipher/files/source.txt"
#define OUTPUTFILE "C:/Eclypse_Workspace/cipher/files/destination.txt"

void encrypt(FILE *source, FILE *destination, int key[]);
void decrypt(FILE *source, FILE *destination, int key[]);

int main(void)
{
	setbuf(stdin, NULL);
	setbuf(stdout, NULL);

	FILE *source = fopen(INPUTFILE, "r");
	if(source == NULL)
	{
		fprintf(stderr, "Could not open file");
		exit(1);
	}
	FILE *destination = fopen(OUTPUTFILE, "w");
	if(destination == NULL)
	{
		fprintf(stderr, "Could not open file");
		exit(1);
	}

	char keyc[BUFFER];
	printf("Please enter a key: ");
	
	char character;
	int i = 0;
	while((character = getchar()) != '\n'){
		keyc[i] = character;
		i++;
	}
	keyc[i] = '\0';
	
	int key[sizeof(keyc)];

	int index;
	for(index = 0; index < i; index++)
	{
		key[index] = keyc[index];
	}

	printf("\nPlease enter option: ");
	char c = getchar();

	if(c == 'e')
	{
		encrypt(source, destination, key);
		printf("\nfile encrypted ");
	}
	if(c == 'd')
	{
		decrypt(source, destination, key);
		printf("\nfile decrypted ");
	}
	return(0);
}

void encrypt(FILE *source, FILE *destination, int key[])
{
	int temp = 0;
	int index = 0;
	while((temp = fgetc(source)) != EOF)
	{
		temp += key[(index % (sizeof(key) / sizeof(key[0]))) - 1];
		index++;
		while(temp > 127)
		{
			temp -= 127;
		}
		fputc(temp, destination);
	}
}

void decrypt(FILE *source, FILE *destination, int key[])
{
	int temp = 0;
	int index = 0;
	while((temp = fgetc(source)) != EOF)
	{
		temp -= key[(index % (sizeof(key) / sizeof(key[0])))];
		index++;
		while(temp < 0)
		{
			temp += 127;
		}
		fputc(temp, destination);
	}
}
