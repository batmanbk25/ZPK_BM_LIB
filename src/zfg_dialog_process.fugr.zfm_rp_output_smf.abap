FUNCTION ZFM_RP_OUTPUT_SMF.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_SMARTFORM) TYPE  TDSFNAME
*"     REFERENCE(I_DATA)
*"     REFERENCE(I_TDDEST) TYPE  RSPOPNAME DEFAULT 'LP01'
*"--------------------------------------------------------------------
DATA:
      LS_SF_FM      TYPE RS38L_FNAM,
      LS_SSFCTRLOP  TYPE SSFCTRLOP,
      LS_SSFCOMPOP  TYPE SSFCOMPOP.

  LS_SSFCTRLOP-PREVIEW    = 'X'.
  LS_SSFCTRLOP-NO_DIALOG  = 'X'.
*-----------------------------------------------------------------------
  "Print immedi
*-----------------------------------------------------------------------
  LS_SSFCOMPOP-TDIMMED   = 'X'.
  LS_SSFCOMPOP-TDDELETE  = 'X'.
  LS_SSFCOMPOP-TDNOPREV  = 'X'.
*-----------------------------------------------------------------------
  "Print immedi
*-----------------------------------------------------------------------
  LS_SSFCOMPOP-TDDEST     = I_TDDEST.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME = I_SMARTFORM
    IMPORTING
      FM_NAME  = LS_SF_FM
    EXCEPTIONS
      OTHERS   = 3.
  IF SY-SUBRC = 0.
    CALL FUNCTION LS_SF_FM
      EXPORTING
        CONTROL_PARAMETERS = LS_SSFCTRLOP
        OUTPUT_OPTIONS     = LS_SSFCOMPOP
        USER_SETTINGS      = ''
        I_DATA             = I_DATA
      EXCEPTIONS
        FORMATTING_ERROR   = 1
        INTERNAL_ERROR     = 2
        SEND_ERROR         = 3
        USER_CANCELED      = 4
        OTHERS             = 5.
  ENDIF.





ENDFUNCTION.
