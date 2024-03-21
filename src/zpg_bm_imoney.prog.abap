*&---------------------------------------------------------------------*
*& Report  ZPG_BM_IMONEY
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ZPG_BM_IMONEY.
INCLUDE ZIN_BM_IMONEYTOP                        .    " global Data

INCLUDE ZIN_BM_IMONEYO01                        .  " PBO-Modules
INCLUDE ZIN_BM_IMONEYI01                        .  " PAI-Modules
INCLUDE ZIN_BM_IMONEYF01                        .  " FORM-Routines

INITIALIZATION.
  PERFORM 0000_INIT_PROC.

AT SELECTION-SCREEN OUTPUT.
  PERFORM 1000_PBO.

START-OF-SELECTION.
  PERFORM 0000_MAIN_PROC.
