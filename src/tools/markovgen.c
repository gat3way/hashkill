#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
int markov0[88];
int markov1[88][88];


void main(int argc, char *argv[])
{
char *charset="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~!{}@#$%^&*()-+[]|\\;':,./";

char *buffer=alloca(200);
int a,b,c,d,e;
FILE *fd;
int THRESH;


for (a=0;a<=88;a++) markov0[a]=0;
for (a=0;a<=88;a++)
for (b=0;b<=88;b++)
markov1[a][b]=0;


fd=fopen(argv[1],"r");
while (!feof(fd))
{
    fgets(buffer,199,fd);
    buffer[200]=0;
    if (strlen(buffer)>2) buffer[strlen(buffer)-1]=0;
    a = 0;
//    printf("%s\n",buffer);
    while ( (a<88) && (charset[a]!=buffer[0])) a++;
    markov0[a]++;
    b = 1;
    c = a;
    do 
    {
	a = 0;
	while ( (a<88) && (charset[a]!=buffer[b])) a++;
	markov1[c][a]++;
	c = a;
	b++;
    } while (b==strlen(buffer));
}
fclose(fd);

c = 0;
d = 0;
for (a=0;a<88;a++)
for (b=0;b<88;b++)
{
c+=markov1[a][b];
if (markov1[a][b]>d) d = markov1[a][b];
}
printf("Markov1 mean: %d max:%d\n",c/(88*88),d);

c = 0;
d = 0;
for (a=0;a<88;a++)
{
c+=markov0[a];
if (markov0[a]>d) d = markov0[a];
}
printf("Markov0 mean: %d max:%d\n",c/(88*88),d);

printf("Enter output file name: ");
scanf("%s",buffer);
fd=fopen(buffer,"w");
printf("Enter default threshold ");
scanf("%d",&e);
printf("Enter description ");
scanf("%s",buffer);
fprintf(fd,"%s\n",buffer);
fprintf(fd,"%d\n",e);
for (a=0;a<88;a++) fprintf(fd,"%c %d\n", charset[a], markov0[a]);
for (a=0;a<88;a++)
for (b=0;b<88;b++) fprintf(fd,"%c %c %d\n", charset[a], charset[b], markov1[a][b]);
fclose(fd);



/*for (a=0;a<88;a++) if (markov0[a]>THRESH)
for (b=0;b<88;b++) if (markov1[a][b]>THRESH)
for (c=0;c<88;c++) if (markov1[b][c]>THRESH)
for (d=0;d<88;d++) if (markov1[c][d]>THRESH)
for (e=0;e<88;e++) if (markov1[d][e]>THRESH)
printf("%c%c%c%c%c\n",charset[a],charset[b],charset[c],charset[d],charset[e]);*/

}