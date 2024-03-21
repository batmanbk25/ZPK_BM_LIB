*&---------------------------------------------------------------------*
*& Report  ZPG_BM_ALVWB
*&
*&---------------------------------------------------------------------*
*&  Created by: TuanBA
*&  Created date: 12/12/2017
*&---------------------------------------------------------------------*

REPORT ZPG_BM_ALVWB.
INCLUDE ZIN_BM_ALVWBTOP                         .    " global Data

INCLUDE ZIN_BM_ALVWBO01                         .  " PBO-Modules
INCLUDE ZIN_BM_ALVWBI01                         .  " PAI-Modules
INCLUDE ZIN_BM_ALVWBF01                         .  " FORM-Routines

INITIALIZATION.
  PERFORM 0000_INIT_PROC.

START-OF-SELECTION.
  PERFORM 0000_MAIN_PROC.
