*&---------------------------------------------------------------------*
*&  Include           ZIN_PRSC_SUBROUTINES
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  CALL_SCREEN
*&---------------------------------------------------------------------*
*       Call screen
*----------------------------------------------------------------------*
FORM  CALL_SCREEN
  USING LPW_DYNNR   TYPE DYNNR.

  CALL FUNCTION 'ZFM_PRSC_PREPARE'
    EXPORTING
      I_DYNNR       = LPW_DYNNR.

  CHECK LPW_DYNNR NP '1+++'.
  CALL SCREEN LPW_DYNNR.
ENDFORM.
