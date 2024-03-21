*&---------------------------------------------------------------------*
*& Report  ZPG_JBCF_CREATE_JOB
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ZPG_JBCF_CREATE_JOB.
INCLUDE ZIN_JBCF_CREATE_JOBTOP                  .    " global Data

* INCLUDE ZIN_JBCF_CREATE_JOBO01                  .  " PBO-Modules
* INCLUDE ZIN_JBCF_CREATE_JOBI01                  .  " PAI-Modules
INCLUDE ZIN_JBCF_CREATE_JOBF01                  .  " FORM-Routines


START-OF-SELECTION.
  PERFORM MAIN_PROC.
