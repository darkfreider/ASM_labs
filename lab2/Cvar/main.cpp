

#include <stdio.h>
#include <string.h>

#define IN 1
#define OUT 2

int main() {
	char str[200];
	gets_s(str, 200);
	int  str_len = (int)strlen(str);

	char w1[20];
	gets_s(w1, 20);
	int w1_len = (int)strlen(w1);

	char w2[20];
	gets_s(w2, 20);
	int w2_len = (int)strlen(w2);

	int state = OUT;
	int i = 0;

	int word_start = -1;
	int word_end = -1;

	while (str[i] == ' ')
		i++;

	bool found = false;
	while (i < str_len)
	{
		if (str[i] == ' ')
		{
			word_end = i;
			state = OUT;

			int curr_str_len = word_end - word_start;
			if ((curr_str_len == w1_len) && strncmp(&str[word_start], w1, w1_len) == 0)
			{
				// found word!!!
				found = true;
				break;
				
			}
		}
		else if (state == OUT)
		{
			state = IN;
			word_start = i;
		}

		i++;
	}
	word_end = i;

	if (i == str_len)
	{
		int curr_str_len = word_end - word_start;
		if ((curr_str_len == w1_len) && strncmp(&str[word_start], w1, w1_len) == 0)
		{
			// found word!!!
			found = true;
		}
	}

	if (found)
	{
		printf("%.*s", word_start, str);
		printf("%.*s ", w2_len, w2);
		printf("%.*s\n", str_len - word_start, &str[word_start]);
	}

	getchar();
	if (str_len + w2_len + 1 <= 200)
	{
		
	}
	else
	{
		printf("not ehough space!\n");
	}

	return(0);
}