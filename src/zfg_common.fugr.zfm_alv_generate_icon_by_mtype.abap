FUNCTION ZFM_ALV_GENERATE_ICON_BY_MTYPE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_MTYPE) TYPE  BAPI_MTYPE
*"     REFERENCE(I_SMALL_ICON) TYPE  XMARK OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_STATUS_ICON) TYPE  ZDD_STATUS_ICON
*"     REFERENCE(E_ROWCOLOR) TYPE  ANY
*"--------------------------------------------------------------------
DATA:
    LW_ICON_NAME    TYPE CHAR50.

  CASE I_MTYPE.
    WHEN GC_MTYPE_E.
      IF I_SMALL_ICON IS INITIAL.
        LW_ICON_NAME  = 'ICON_RED_LIGHT'.
      ELSE.
        LW_ICON_NAME  = 'ICON_LED_RED'.
      ENDIF.
      E_ROWCOLOR    = 'C710'.
    WHEN GC_MTYPE_W.
      IF I_SMALL_ICON IS INITIAL.
        LW_ICON_NAME  = 'ICON_YELLOW_LIGHT'.
      ELSE.
        LW_ICON_NAME  = 'ICON_LED_YELLOW'.
      ENDIF.
      E_ROWCOLOR    = 'C310'.
    WHEN GC_MTYPE_P.
      LW_ICON_NAME  = 'ICON_SET_STATE'.
    WHEN SPACE.
      LW_ICON_NAME  = 'ICON_LIGHT_OUT'.
*      E_ROWCOLOR    = 'C310'.
    WHEN OTHERS.
      IF I_SMALL_ICON IS INITIAL.
        LW_ICON_NAME  = 'ICON_GREEN_LIGHT'.
      ELSE.
        LW_ICON_NAME  = 'ICON_LED_GREEN'.
      ENDIF.
      E_ROWCOLOR    = 'C510'.
  ENDCASE.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      NAME                       = LW_ICON_NAME
   IMPORTING
     RESULT                      = E_STATUS_ICON
   EXCEPTIONS
     ICON_NOT_FOUND              = 1
     OUTPUTFIELD_TOO_SHORT       = 2
     OTHERS                      = 3.





ENDFUNCTION.
