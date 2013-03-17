#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include "hashcpa.h"


int get_pass_type(char *password)
{
    int a,b,len,tmp;

    tmp = 0;
    for (a=0;a<strlen(password);a++)
    {
	len = strlen(set_num);
	for (b=0;b<len;b++) if (password[a] == set_num[b]) 
	{
	    tmp |= (1<<TYPE_NUM);
	    goto next;
	}
	
	len = strlen(set_ualpha);
	for (b=0;b<len;b++) if (password[a] == set_ualpha[b]) 
	{
	    tmp |= (1<<TYPE_UALPHA);
	    goto next;
	}
	
	len = strlen(set_lalpha);
	for (b=0;b<len;b++) if (password[a] == set_lalpha[b]) 
	{
	    tmp |= (1<<TYPE_LALPHA);
	    goto next;
	}

	len = strlen(set_special);
	for (b=0;b<len;b++) if (password[a] == set_special[b]) 
	{
	    tmp |= (1<<TYPE_SPECIAL);
	    goto next;
	}

	len = strlen(set_space);
	for (b=0;b<len;b++) if (password[a] == set_space[b]) 
	{
	    tmp |= (1<<TYPE_SPACE);
	    goto next;
	}

	if (password[a]<128) 
	{
	    tmp |= (1<<TYPE_NONASCII);
	    goto next;
	}
	else tmp |= (1<<TYPE_UPPERASCII);
	next:;
    }
    return tmp;
}

void init_stuff()
{
    int a;

    for (a=0;a<128;a++) lens[a]=0;
    bitmap = malloc(256*256*256);
    bitmap2 = malloc(256*256*256);
    bitmap3 = malloc(256*256*256);
    bitmap4 = malloc(256*256*256);
    for (a=0;a<256*256*256;a++) bitmap[a] = 0;
    for (a=0;a<256*256*256;a++) bitmap2[a] = 0;
    for (a=0;a<256*256*256;a++) bitmap3[a] = 0;
    for (a=0;a<256*256*256;a++) bitmap4[a] = 0;
    nodes = 0;
}

void set_pass_key(char *password, int len)
{
    int a;
    int b = (len>5) ? 5 : len;
    int val = 0;
    int val1;

    for (a=1;a<b;a++)
    {
	val1 = password[a]&63;
	val1 = (a==1) ? val1 : (val1 << ((a-1)*6));
	val |= val1;
    }
    bitmap[val] |= (1<<password[0]&7);

    val = 0;
    for (a=1;a<b;a++)
    {
	val1 = (password[a]>>2)&63;
	val1 = (a==6) ? val1 : (val1 << ((a-1)*6));
	val |= val1;
    }
    bitmap2[val] |= (1<<(password[0]>>4)&7);

    if (len>=10)
    {
	val = 0;
	for (a=6;a<10;a++)
	{
	    val1 = (password[a]>>2)&63;
	    val1 = (a==1) ? val1 : (val1 << ((a-6)*6));
	    val |= val1;
	}
	bitmap3[val] |= (1<<(password[5])&7);

	val = 0;
	for (a=6;a<10;a++)
	{
	    val1 = (password[a])&63;
	    val1 = (a==1) ? val1 : (val1 << ((a-6)*6));
	    val |= val1;
	}
	bitmap3[val] |= (1<<(password[5]>>4)&7);
    }

}


int get_pass_key(char *password, int len)
{
    int a;
    int b = (len>5) ? 5 : len;
    int val = 0;
    int val1;
    int interm,interm2,fin,fin2;

    for (a=1;a<b;a++)
    {
	val1 = password[a]&63;
	val1 = (a==1) ? val1 : (val1 << ((a-1)*6));
	val |= val1;
    }
    interm = (bitmap[val]>>(password[0]&7))&1;

    val = 0;
    for (a=1;a<b;a++)
    {
	val1 = (password[a]>>2)&63;
	val1 = (a==1) ? val1 : (val1 << ((a-1)*6));
	val |= val1;
    }
    interm2 = (bitmap2[val]>>((password[0]>>4)&7))&1;

    fin = fin2 = 1;
    if (len>=10)
    {
	val = 0;
	for (a=6;a<10;a++)
	{
	    val1 = (password[a]>>2)&63;
	    val1 = (a==6) ? val1 : (val1 << ((a-6)*6));
	    val |= val1;
	}
	fin = (bitmap3[val]>>((password[5])&7))&1;

	val = 0;
	for (a=6;a<10;a++)
	{
	    val1 = (password[a])&63;
	    val1 = (a==6) ? val1 : (val1 << ((a-6)*6));
	    val |= val1;
	}
	fin = (bitmap3[val]>>((password[5]>>4)&7))&1;
    }
    
    if (interm&&interm2&&fin&&fin2) return 1;
    else return 0;
}



int add_list(char *password)
{
    pass_node *tmp;
    int len = strlen(password);
    int key;


    if (len>=64) return 0;
    if (len<3) return 0;
    lens[len]++;
    key = get_pass_key(password,len);

    // New node
    if (!end)
    {
	end = malloc(sizeof(struct pass_node_t));
	if (!end) return 0;
	end->password = malloc(strlen(password)+1);
	if (!end->password) return 0;
	strcpy(end->password,password);
	end->type = get_pass_type(password);
	end->times = 1;
	end->prev = NULL;
	end->next = NULL;
	end->len = len;
	start = end;
	set_pass_key(password,len);
	nodes++;
	return 1;
    }

    tmp = end;
    if (key) while (tmp)
    {
	if ((len==tmp->len)&&(strcmp(tmp->password,password)==0))
	{
	    tmp->times++;
	    return 1;
	}
	tmp = tmp->prev;
    }

    tmp = malloc(sizeof(struct pass_node_t));
    if (!tmp) return 0;
    tmp->password = malloc(strlen(password)+1);
    if (!tmp->password) return 0;
    strcpy(tmp->password,password);
    tmp->type = get_pass_type(password);
    tmp->times = 1;
    tmp->next = NULL;
    end->next = tmp;
    tmp->prev = end;
    nodes++;
    set_pass_key(password,len);
    end = tmp;
    return 1;
}




void main(int argc, char *argv[])
{
    FILE *fp;
    char buf[4096];
    pass_node *tmp;
    int l1;
    int cnt,cnt1=0,all;
    char progress[4]="|/-\\";

    init_stuff();

    fp = fopen(argv[1],"r");
    if (!fp) return;
    printf("Analyzing   ");
    while (fgets(buf,4095,fp))
    {
	cnt++;if ((cnt%10000)==0) 
	{
	    cnt1++;
	    printf("\b\b\b %c ",progress[cnt1&3]);
	    printf("%d\n",cnt);
	    fflush(stdout);
	}
	l1 = strlen(buf)-1;
	if (buf[l1] == '\n') buf[l1]=0;
	if (buf[l1-1] == '\r') buf[l1]=0;
	add_list(buf);
    }
    fclose(fp);
    printf("(%d)",nodes);

    tmp = start;
    cnt = 0;
    int num,lalpha,ualpha,alpha,alphanum,lalphanum,ualphanum,special,alphaspecial,upperascii,space;
    lalpha=ualpha=alpha=alphanum=lalphanum=ualphanum=special=alphaspecial=upperascii=space=0;
    while (tmp)
    {
	if (tmp->type==1) num++;
	if (tmp->type==2) lalpha++;
	if (tmp->type==3) lalphanum++;
	if (tmp->type==4) ualpha++;
	if (tmp->type==5) ualphanum++;
	if (tmp->type==6) alpha++;
	if (tmp->type==7) alphanum++;
	if (tmp->type==16) special++;
	if ((tmp->type>>4)&1) alphaspecial++;
	if ((tmp->type>>3)&1) space++;
	if ((tmp->type>>6)&1) upperascii++;
	tmp = tmp->next;
    }
    printf("\n\nPassword types:\n===============\n");
    printf("only numeric:    %d (%.2f%%)\n",num,(float)((float)(num*100)/(float)nodes));
    printf("only lalpha:     %d (%.2f%%)\n",lalpha,(float)((float)(lalpha*100)/(float)nodes));
    printf("only ualpha:     %d (%.2f%%)\n",ualpha,(float)((float)(ualpha*100)/(float)nodes));
    printf("only alpha:      %d (%.2f%%)\n",alpha,(float)((float)(alpha*100)/(float)nodes));
    printf("only alphanum:   %d (%.2f%%)\n",alphanum,(float)((float)(alphanum*100)/(float)nodes));
    printf("only lalphanum:  %d (%.2f%%)\n",lalphanum,(float)((float)(lalphanum*100)/(float)nodes));
    printf("only ualphanum:  %d (%.2f%%)\n",ualphanum,(float)((float)(ualphanum*100)/(float)nodes));
    printf("only special:    %d (%.2f%%)\n",special,(float)((float)(special*100)/(float)nodes));
    printf("has special:     %d (%.2f%%)\n",alphaspecial,(float)((float)(alphaspecial*100)/(float)nodes));
    printf("has upperascii:  %d (%.2f%%)\n",upperascii,(float)((float)(upperascii*100)/(float)nodes));
    printf("has whitespace:  %d (%.2f%%)\n",space,(float)((float)(space*100)/(float)nodes));
    printf("\n\nLengths:\n========\n");
    for (cnt=0;cnt<64;cnt++)
	if (lens[cnt]>0)
	    printf("%d - %d (%.2f%%)\n",cnt,lens[cnt],(float)((float)(lens[cnt]*100)/(float)nodes));

}
