#include <stdio.h>
#include <string.h>

int isSubstring(char *s1, char *s2) 
{ 
    int M = s1.length(); 
    int N = s2.length();
	
    for (int i = 0; i <= N - M; i++) 
	{ 
        int j; 
  
        for (j = 0; j < M; j++) 
            if (s2[i + j] != s1[j]) 
                break; 
  
        if (j == M) 
            return i; 
    } 
  
    return -1; 
}


int main(int argc, char **argv)
{
	while (**argv)
	{
		printf("%s\n", *argv);
		argv++;
	}
	
	return (0);
}