*&---------------------------------------------------------------------*
*&  Include           ZIN_BM_SVINFOI01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CALL FUNCTION 'ZFM_SCR_SIMPLE_FC_PROCESS'.

  CALL FUNCTION 'ZFM_SCR_PAI'.

  CASE SY-UCOMM.
    WHEN 'FC_USRMN'.
      CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
        EXPORTING
          ACTION                               = 'U'
          VIEW_NAME                            = 'ZTB_BM_SV_USR'.
    WHEN 'FC_INTRAN'.
      CALL FUNCTION 'VIEWCLUSTER_MAINTENANCE_CALL'
        EXPORTING
          VIEWCLUSTER_NAME                   = 'ZVI_SVACF'
          MAINTENANCE_ACTION                 = 'U'
        EXCEPTIONS
          OTHERS                             = 16.
    WHEN 'FC_INTRAND'.
      CALL FUNCTION 'VIEWCLUSTER_MAINTENANCE_CALL'
        EXPORTING
          VIEWCLUSTER_NAME                   = 'ZVI_SVCF'
          MAINTENANCE_ACTION                 = 'U'
          SHOW_SELECTION_POPUP               = 'X'
        EXCEPTIONS
          OTHERS                             = 16.
    WHEN 'FC_USRAC'.
      PERFORM 0100_GET_USR_ACCOUNT.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
