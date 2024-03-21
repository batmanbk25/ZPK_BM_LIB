*&---------------------------------------------------------------------*
*& Report  ZPG_UPDATE_DB
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT   ZPG_UPDATE_DB.
INCLUDE ZIN_UPDATE_DBTOP                        .    " global Data

INCLUDE ZIN_UPDATE_DBO01                        .  " PBO-Modules
INCLUDE ZIN_UPDATE_DBI01                        .  " PAI-Modules
INCLUDE ZIN_UPDATE_DBF01                        .  " FORM-Routines

START-OF-SELECTION.
  PERFORM MAIN_PROC.
