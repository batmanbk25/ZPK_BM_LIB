FUNCTION ZFM_DATE_GET_PERIOD.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_DATE) TYPE  DATS DEFAULT SY-DATUM
*"     REFERENCE(I_GET_QUARTER) TYPE  XMARK OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_MONTH) TYPE  PERSL_KK
*"     REFERENCE(E_QUARTER) TYPE  PERSL_KK
*"     REFERENCE(E_PREDC) TYPE  PREDC_KK
*"     REFERENCE(E_PERSLT_KK) TYPE  PERSLT_KK
*"     REFERENCE(T_TFKPERIOD) TYPE  ZTT_TFKPERIOD
*"--------------------------------------------------------------------
DATA:
    LS_PERIOD TYPE ZST_TFKPERIOD.

  IF GT_TFKPERIOD IS INITIAL.
    SELECT TFKPERIOD~PERSL
           ABRZU
           ABRZO
           PREDC
           TXT50
      FROM TFKPERIOD INNER JOIN TFK001PT
        ON TFKPERIOD~PERSL = TFK001PT~PERSL
      INTO TABLE GT_TFKPERIOD
     WHERE SPRAS = SY-LANGU.
  ENDIF.
  T_TFKPERIOD = GT_TFKPERIOD.

  IF I_GET_QUARTER IS INITIAL.
    LOOP AT T_TFKPERIOD INTO LS_PERIOD
      WHERE PERSL CO '1234567890 '
        AND ABRZU <= I_DATE AND ABRZO >= I_DATE.
      E_MONTH       = LS_PERIOD-PERSL.
      E_PREDC       = LS_PERIOD-PREDC.
      E_PERSLT_KK   = LS_PERIOD-TXT50.
    ENDLOOP.
  ELSE.
    LOOP AT T_TFKPERIOD INTO LS_PERIOD
      WHERE PERSL CO '1234567890Q '
        AND ABRZU <= I_DATE AND ABRZO >= I_DATE.
      E_QUARTER     = LS_PERIOD-PERSL.
      E_PREDC       = LS_PERIOD-PREDC.
      E_PERSLT_KK   = LS_PERIOD-TXT50.
    ENDLOOP.
  ENDIF.





ENDFUNCTION.
