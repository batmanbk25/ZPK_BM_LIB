*&---------------------------------------------------------------------*
*& Module Pool      ZPG_BM_TRAN_RQ
*&---------------------------------------------------------------------*
*&  Created by: TuanBA
*&  Created date: 30/12/2019
*&---------------------------------------------------------------------*

REPORT ZPG_BM_TRAN_RQ.
INCLUDE ZIN_BM_TRAN_RQTOP                       .    " Global Data

* INCLUDE ZIN_BM_TRAN_RQO01                       .  " PBO-Modules
* INCLUDE ZIN_BM_TRAN_RQI01                       .  " PAI-Modules
 INCLUDE ZIN_BM_TRAN_RQF01                       .  " FORM-Routines

INITIALIZATION.
  PERFORM INIT.

AT SELECTION-SCREEN OUTPUT.
  PERFORM MODIFY_SCREEN.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_TRKORR.
  PERFORM GET_F4_TRKORR.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_PATH.
  PERFORM GET_F4_LOCAL_PATH.

START-OF-SELECTION.
  PERFORM CHECK_CONDITION.
  PERFORM GET_APPLICATION_FILE_PATH.
  CASE 'X'.
    WHEN P_DOWRQ.
      PERFORM DOWNLOAD_PROCESSING.
    WHEN P_UPLRQ.
      PERFORM UPLOAD_PROCESSING.
  ENDCASE.
