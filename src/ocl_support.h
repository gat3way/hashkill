/* ocl_support.h
 *
 * hashkill - a hash cracking tool
 * Copyright (C) 2010 Milen Rangelov <gat3way@gat3way.eu>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */


#ifndef OCL_SUPPORT_H
#define OCL_SUPPORT_H

#include <stdint.h>
#include "err.h"
//#include "hashinterface.h"

/* md5 plugin support */
hash_stat ocl_bruteforce_md5(void);
hash_stat ocl_markov_md5(void);
hash_stat ocl_rule_md5(void);

/* sha1 plugin support */
hash_stat ocl_bruteforce_sha1(void);
hash_stat ocl_markov_sha1(void);
hash_stat ocl_rule_sha1(void);

/* md4 plugin support */
hash_stat ocl_bruteforce_md4(void);
hash_stat ocl_markov_md4(void);
hash_stat ocl_rule_md4(void);

/* ntlm plugin support */
hash_stat ocl_bruteforce_ntlm(void);
hash_stat ocl_markov_ntlm(void);
hash_stat ocl_rule_ntlm(void);

/* md5md5 plugin support */
hash_stat ocl_bruteforce_md5md5(void);
hash_stat ocl_markov_md5md5(void);
hash_stat ocl_rule_md5md5(void);


/* mysql5 plugin support */
hash_stat ocl_bruteforce_mysql5(void);
hash_stat ocl_markov_mysql5(void);
hash_stat ocl_rule_mysql5(void);

/* mysql-old plugin support */
//hash_stat ocl_bruteforce_mysql_old(void);
//hash_stat ocl_markov_mysql_old(void);
//hash_stat ocl_rule_mysql_old(void);

/* nsldap plugin support */
hash_stat ocl_bruteforce_nsldap(void);
hash_stat ocl_markov_nsldap(void);
hash_stat ocl_rule_nsldap(void);

/* nsldaps plugin support */
hash_stat ocl_bruteforce_nsldaps(void);
hash_stat ocl_markov_nsldaps(void);
hash_stat ocl_rule_nsldaps(void);


/* sha256 plugin support */
hash_stat ocl_bruteforce_sha256(void);
hash_stat ocl_markov_sha256(void);
hash_stat ocl_rule_sha256(void);

/* sha512 plugin support */
hash_stat ocl_bruteforce_sha512(void);
hash_stat ocl_markov_sha512(void);
hash_stat ocl_rule_sha512(void);


/* joomla plugin support */
hash_stat ocl_bruteforce_joomla(void);
hash_stat ocl_markov_joomla(void);
hash_stat ocl_rule_joomla(void);

/* lm plugin support */
hash_stat ocl_bruteforce_lm(void);
hash_stat ocl_markov_lm(void);
hash_stat ocl_rule_lm(void);

/* oracle-old plugin support */
hash_stat ocl_bruteforce_oracle_old(void);
hash_stat ocl_markov_oracle_old(void);
hash_stat ocl_rule_oracle_old(void);

/* oracle11g plugin support */
hash_stat ocl_bruteforce_oracle11g(void);
hash_stat ocl_markov_oracle11g(void);
hash_stat ocl_rule_oracle11g(void);

/* ipb2 plugin support */
hash_stat ocl_bruteforce_ipb2(void);
hash_stat ocl_markov_ipb2(void);
hash_stat ocl_rule_ipb2(void);

/* vbulletin plugin support */
hash_stat ocl_bruteforce_vbulletin(void);
hash_stat ocl_markov_vbulletin(void);
hash_stat ocl_rule_vbulletin(void);

/* oscommerce plugin support */
hash_stat ocl_bruteforce_oscommerce(void);
hash_stat ocl_markov_oscommerce(void);
hash_stat ocl_rule_oscommerce(void);

/* smf plugin support */
hash_stat ocl_bruteforce_smf(void);
hash_stat ocl_markov_smf(void);
hash_stat ocl_rule_smf(void);

/* desunix plugin support */
hash_stat ocl_bruteforce_desunix(void);
hash_stat ocl_markov_desunix(void);
hash_stat ocl_rule_desunix(void);

/* phpbb3 plugin support */
hash_stat ocl_bruteforce_phpbb3(void);
hash_stat ocl_markov_phpbb3(void);
hash_stat ocl_rule_phpbb3(void);

/* wordpress plugin support */
hash_stat ocl_bruteforce_wordpress(void);
hash_stat ocl_markov_wordpress(void);
hash_stat ocl_rule_wordpress(void);

/* md5unix plugin support */
hash_stat ocl_bruteforce_md5unix(void);
hash_stat ocl_markov_md5unix(void);
hash_stat ocl_rule_md5unix(void);

/* sha512unix plugin support */
hash_stat ocl_bruteforce_sha512unix(void);
hash_stat ocl_markov_sha512unix(void);
hash_stat ocl_rule_sha512unix(void);

/* sha256unix plugin support */
hash_stat ocl_bruteforce_sha256unix(void);
hash_stat ocl_markov_sha256unix(void);
hash_stat ocl_rule_sha256unix(void);


/* osxlion plugin support */
hash_stat ocl_bruteforce_osxlion(void);
hash_stat ocl_markov_osxlion(void);
hash_stat ocl_rule_osxlion(void);

/* pixmd5 plugin support */
hash_stat ocl_bruteforce_pixmd5(void);
hash_stat ocl_markov_pixmd5(void);
hash_stat ocl_rule_pixmd5(void);

/* mssql-2000 plugin support */
hash_stat ocl_bruteforce_mssql_2000(void);
hash_stat ocl_markov_mssql_2000(void);
hash_stat ocl_rule_mssql_2000(void);

/* mssql-2005 plugin support */
hash_stat ocl_bruteforce_mssql_2005(void);
hash_stat ocl_markov_mssql_2005(void);
hash_stat ocl_rule_mssql_2005(void);

/* mscash plugin support */
hash_stat ocl_bruteforce_mscash(void);
hash_stat ocl_markov_mscash(void);
hash_stat ocl_rule_mscash(void);

/* apr1 plugin support */
hash_stat ocl_bruteforce_apr1(void);
hash_stat ocl_markov_apr1(void);
hash_stat ocl_rule_apr1(void);

/* mscash2 plugin support */
hash_stat ocl_bruteforce_mscash2(void);
hash_stat ocl_markov_mscash2(void);
hash_stat ocl_rule_mscash2(void);

/* zip plugin support */
hash_stat ocl_bruteforce_zip(void);
hash_stat ocl_markov_zip(void);
hash_stat ocl_rule_zip(void);

/* wpa plugin support */
hash_stat ocl_bruteforce_wpa(void);
hash_stat ocl_markov_wpa(void);
hash_stat ocl_rule_wpa(void);

/* rar plugin support */
hash_stat ocl_bruteforce_rar(void);
hash_stat ocl_markov_rar(void);
hash_stat ocl_rule_rar(void);

/* dmg plugin support */
hash_stat ocl_bruteforce_dmg(void);
hash_stat ocl_markov_dmg(void);
hash_stat ocl_rule_dmg(void);

/* osx-old plugin support */
hash_stat ocl_bruteforce_osx_old(void);
hash_stat ocl_markov_osx_old(void);
hash_stat ocl_rule_osx_old(void);

/* bfunix plugin support */
hash_stat ocl_bruteforce_bfunix(void);
hash_stat ocl_markov_bfunix(void);
hash_stat ocl_rule_bfunix(void);

/* drupal7 plugin support */
hash_stat ocl_bruteforce_drupal7(void);
hash_stat ocl_markov_drupal7(void);
hash_stat ocl_rule_drupal7(void);

/* django256 plugin support */
hash_stat ocl_bruteforce_django256(void);
hash_stat ocl_markov_django256(void);
hash_stat ocl_rule_django256(void);

/* o5logon plugin support */
hash_stat ocl_bruteforce_o5logon(void);
hash_stat ocl_markov_o5logon(void);
hash_stat ocl_rule_o5logon(void);

/* mssql-2012 plugin support */
hash_stat ocl_bruteforce_mssql_2012(void);
hash_stat ocl_markov_mssql_2012(void);
hash_stat ocl_rule_mssql_2012(void);

/* msoffice plugin support */
hash_stat ocl_bruteforce_msoffice(void);
hash_stat ocl_markov_msoffice(void);
hash_stat ocl_rule_msoffice(void);

/* luks plugin support */
hash_stat ocl_bruteforce_luks(void);
hash_stat ocl_markov_luks(void);
hash_stat ocl_rule_luks(void);

/* ripemd160 plugin support */
hash_stat ocl_bruteforce_ripemd160(void);
hash_stat ocl_markov_ripemd160(void);
hash_stat ocl_rule_ripemd160(void);

/* whirlpool plugin support */
hash_stat ocl_bruteforce_whirlpool(void);
hash_stat ocl_markov_whirlpool(void);
hash_stat ocl_rule_whirlpool(void);

/* truecrypt plugin support */
hash_stat ocl_bruteforce_truecrypt(void);
hash_stat ocl_markov_truecrypt(void);
hash_stat ocl_rule_truecrypt(void);

/* lastpass plugin support */
hash_stat ocl_bruteforce_lastpass(void);
hash_stat ocl_markov_lastpass(void);
hash_stat ocl_rule_lastpass(void);

/* keepass plugin support */
hash_stat ocl_bruteforce_keepass(void);
hash_stat ocl_markov_keepass(void);
hash_stat ocl_rule_keepass(void);

/* mozilla plugin support */
hash_stat ocl_bruteforce_mozilla(void);
hash_stat ocl_markov_mozilla(void);
hash_stat ocl_rule_mozilla(void);

/* pwsafe plugin support */
hash_stat ocl_bruteforce_pwsafe(void);
hash_stat ocl_markov_pwsafe(void);
hash_stat ocl_rule_pwsafe(void);

/* keyring plugin support */
hash_stat ocl_bruteforce_keyring(void);
hash_stat ocl_markov_keyring(void);
hash_stat ocl_rule_keyring(void);

/* kwallet plugin support */
hash_stat ocl_bruteforce_kwallet(void);
hash_stat ocl_markov_kwallet(void);
hash_stat ocl_rule_kwallet(void);

/* msoffice-old plugin support */
hash_stat ocl_bruteforce_msoffice_old(void);
hash_stat ocl_markov_msoffice_old(void);
hash_stat ocl_rule_msoffice_old(void);

/* pdf plugin support */
hash_stat ocl_bruteforce_pdf(void);
hash_stat ocl_markov_pdf(void);
hash_stat ocl_rule_pdf(void);

/* sha384 plugin support */
hash_stat ocl_bruteforce_sha384(void);
hash_stat ocl_markov_sha384(void);
hash_stat ocl_rule_sha384(void);

/* odf plugin support */
hash_stat ocl_bruteforce_odf(void);
hash_stat ocl_markov_odf(void);
hash_stat ocl_rule_odf(void);

/* grub2 plugin support */
hash_stat ocl_bruteforce_grub2(void);
hash_stat ocl_markov_grub2(void);
hash_stat ocl_rule_grub2(void);

/* androidfde plugin support */
hash_stat ocl_bruteforce_androidfde(void);
hash_stat ocl_markov_androidfde(void);
hash_stat ocl_rule_androidfde(void);

/* androidpin plugin support */
hash_stat ocl_bruteforce_androidpin(void);
hash_stat ocl_markov_androidpin(void);
hash_stat ocl_rule_androidpin(void);

/* osx-ml plugin support */
hash_stat ocl_bruteforce_osx_ml(void);
hash_stat ocl_markov_osx_ml(void);
hash_stat ocl_rule_osx_ml(void);


/* a51 plugin support */
hash_stat ocl_bruteforce_a51(void);
hash_stat ocl_markov_a51(void);
hash_stat ocl_rule_a51(void);



/* test plugin support */
//hash_stat ocl_bruteforce_test(void);
//hash_stat ocl_markov_test(void);
//hash_stat ocl_rule_test(void);

/* supported plugins struct array*/
struct ocl_supported_plugins_s
{
    int is_linear;
    char plugin_name[32];
    hash_stat (*bruteforce_routine)(void);
    hash_stat (*markov_routine)(void);
    hash_stat (*rule_routine)(void);
};






#endif
