*&---------------------------------------------------------------------*
*& Report  ZPG_BM_SVINFO
*&
*&---------------------------------------------------------------------*
*&  Created by  : TUANBA
*&  Created date: 21/10/2016
*&---------------------------------------------------------------------*

REPORT ZPG_BM_SVINFO.
INCLUDE ZIN_BM_SVINFOTOP                        .    " global Data

INCLUDE ZIN_BM_SVINFOO01                        .  " PBO-Modules
INCLUDE ZIN_BM_SVINFOI01                        .  " PAI-Modules
INCLUDE ZIN_BM_SVINFOF01                        .  " FORM-Routines

INITIALIZATION.
  PERFORM 0000_INIT_PROC.

START-OF-SELECTION.
  PERFORM 0000_MAIN_PROC.
