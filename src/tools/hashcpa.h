
#ifndef HASHCPA_H
#define HASHCPA_H


typedef enum pass_type_e
{
    TYPE_NUM = 0,
    TYPE_LALPHA = 1,
    TYPE_UALPHA = 2,
    TYPE_SPACE = 3,
    TYPE_SPECIAL = 4,
    TYPE_NONASCII = 5,
    TYPE_UPPERASCII = 6
} pass_type;

typedef struct pass_node_t
{
    char *password;
    int len;
    pass_type type;
    int times;
    struct pass_node_t *prev,*next;
} pass_node;

pass_node *start,*end;

int lens[64];
unsigned char *bitmap;
unsigned char *bitmap2;
unsigned char *bitmap3;
unsigned char *bitmap4;
int nodes;
char *set_num = "0123456789";
char *set_ualpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
char *set_lalpha = "abcdefghijklmnopqrstuvwxyz";
char *set_space = " \t";
char *set_special = "~!@#$%^&*()_+-={}[]\\|;':\",.<>/?";


#endif