FUNCTION ZFM_SCR_GET_CURSOR.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_DYNNR) TYPE  SY-DYNNR DEFAULT SY-DYNNR
*"--------------------------------------------------------------------
IF GS_LAST_CUSOR_FIELD IS INITIAL.
    GET CURSOR FIELD GS_LAST_CUSOR_FIELD-FIELDNAME
               LINE GS_LAST_CUSOR_FIELD-LINE
               OFFSET GS_LAST_CUSOR_FIELD-OFFSET.
    IF SY-SUBRC IS INITIAL.
      GS_LAST_CUSOR_FIELD-DYNNR = I_DYNNR.
    ENDIF.
  ENDIF.





ENDFUNCTION.
