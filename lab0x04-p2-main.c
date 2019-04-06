#include <stdio.h>
#include <string.h>

extern int _sumAndPrintList(int *list, int length);
extern int _replaceChar(char * textPtr, int length, char searchChar, char replaceChar);

int main()
{
	char ss[512];

	int a[1000];
	int count = 0;

	puts("Enter list of numbers separated with spaces ending with a period (e.g. \"1 1 2 3 5 8.\"):");
	while(scanf("%d", &a[count]))
		count++;

	fgets(ss, sizeof(ss), stdin) != NULL;	// use this to clear up remaining . and \n from stdin
											// because scanf stopped right at them.
											// != NULL eliminates gcc warning :3

	printf("Owo~ your function returned a sum of %d, does that match the last number in the running total column?\n", _sumAndPrintList(a, count));

	puts("----------------------------------------------------------");

	puts("Enter lines of text, blank line to stop:");

	while(fgets(ss, sizeof(ss), stdin) && ss[0] != '\n')
	{
		printf("%s%d spaces were replaced\n", ss, _replaceChar(ss, strlen(ss), ' ', '_'));
	}

	puts("Sayonara~");
}
