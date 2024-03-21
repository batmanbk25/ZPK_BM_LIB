*&---------------------------------------------------------------------*
*& Report  ZPG_LOGON_RFC
*&
*&---------------------------------------------------------------------*
*&  Create by: TuanBA
*&  Create date: 3/10/2016
*&---------------------------------------------------------------------*

REPORT ZPG_LOGON_RFC.
INCLUDE ZIN_LOGON_RFCTOP                        .    " global Data

* INCLUDE ZIN_LOGON_RFCO01                        .  " PBO-Modules
* INCLUDE ZIN_LOGON_RFCI01                        .  " PAI-Modules
 INCLUDE ZIN_LOGON_RFCF01                        .  " FORM-Routines

 START-OF-SELECTION.
  PERFORM 0000_MAIN_PROC.
