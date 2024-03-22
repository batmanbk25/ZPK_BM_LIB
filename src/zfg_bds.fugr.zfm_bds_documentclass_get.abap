FUNCTION ZFM_BDS_DOCUMENTCLASS_GET.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(CLASSNAME) LIKE  SEOCLASS-CLSNAME OPTIONAL
*"     VALUE(CLASSTYPE) LIKE  BDS_CONN00-CLASSTYPE OPTIONAL
*"  EXPORTING
*"     VALUE(LO_CLASS) LIKE  BDS_LOCL-LO_CLASS
*"     VALUE(PH_CLASS) LIKE  BDS_LOCL-PH_CLASS
*"     VALUE(RE_CLASS) LIKE  BDS_LOCL-RE_CLASS
*"     VALUE(TABNAME) LIKE  BDS_LOCL-TABNAME
*"     VALUE(FUNCNAME) LIKE  BDS_LOCL-FUNCNAME
*"     VALUE(LOG_LEVEL) LIKE  BDS_LOCL-LOG_LEVEL
*"  TABLES
*"      DOCUMENT_CLASSES STRUCTURE  BDS_LOCL OPTIONAL
*"  EXCEPTIONS
*"      NOTHING_FOUND
*"      PARAMETER_ERROR
*"      NOT_ALLOWED
*"      ERROR_KPRO
*"      INTERNAL_ERROR
*"      NOT_AUTHORIZED
*"--------------------------------------------------------------------
******************************** data declaration **********************

  DATA: TIMESTAMP TYPE TIMESTAMP.

******************************** program *******************************

* check classtype
  IF CLASSTYPE NE SPACE.
    PERFORM CHECK_CLASSTYPE(SAPLBDS_BAPI)
                USING
                   CLASSTYPE.
  ENDIF.
**********************************************************************
* TuanBA Edit START
**********************************************************************
  IF CLASSNAME = BDS_LOCL-CLASSNAME AND CLASSTYPE = BDS_LOCL-CLASSTYPE.
    MOVE: BDS_LOCL-TABNAME TO TABNAME,
          BDS_LOCL-LO_CLASS TO LO_CLASS,
          BDS_LOCL-PH_CLASS TO PH_CLASS,
          BDS_LOCL-RE_CLASS TO RE_CLASS,
          BDS_LOCL-FUNCNAME TO FUNCNAME,
          BDS_LOCL-LOG_LEVEL TO LOG_LEVEL,
          BDS_LOCL TO DOCUMENT_CLASSES.
    APPEND DOCUMENT_CLASSES.
    RETURN.
  ENDIF.
**********************************************************************
* TuanBA Edit END
**********************************************************************
  IF CLASSNAME NE SPACE AND CLASSTYPE NE SPACE.
    SELECT SINGLE * FROM BDS_LOCL WHERE CLASSNAME EQ CLASSNAME
                                  AND CLASSTYPE EQ CLASSTYPE.
    IF SY-SUBRC NE 0.
      GET TIME STAMP FIELD TIMESTAMP.
      BDS_LOCL-CLASSNAME = CLASSNAME.
      BDS_LOCL-CLASSTYPE = CLASSTYPE.
      BDS_LOCL-LO_CLASS = 'BDS_LOC1'.
      BDS_LOCL-PH_CLASS = 'BDS_POC1'.
      BDS_LOCL-RE_CLASS = 'BDS_REC1'.
      BDS_LOCL-TABNAME  = 'BDS_CONN00'.
      BDS_LOCL-CREA_USER = SY-UNAME.
      MOVE TIMESTAMP TO BDS_LOCL-CREA_TIME.
      INSERT BDS_LOCL.
    ENDIF.
    IF SY-SUBRC NE 0.
      MESSAGE W105 RAISING INTERNAL_ERROR.
    ENDIF.
    MOVE: BDS_LOCL-TABNAME TO TABNAME,
          BDS_LOCL-LO_CLASS TO LO_CLASS,
          BDS_LOCL-PH_CLASS TO PH_CLASS,
          BDS_LOCL-RE_CLASS TO RE_CLASS,
          BDS_LOCL-FUNCNAME TO FUNCNAME,
          BDS_LOCL-LOG_LEVEL TO LOG_LEVEL,
          BDS_LOCL TO DOCUMENT_CLASSES.
    APPEND DOCUMENT_CLASSES.
  ELSEIF CLASSTYPE EQ SPACE AND CLASSNAME EQ SPACE.
    SELECT * FROM BDS_LOCL INTO TABLE DOCUMENT_CLASSES.
    IF SY-SUBRC NE 0.
      MESSAGE W001 RAISING NOTHING_FOUND.
    ENDIF.
  ELSEIF CLASSTYPE EQ SPACE AND CLASSNAME NE SPACE.
    SELECT * FROM BDS_LOCL INTO TABLE DOCUMENT_CLASSES
                                  WHERE CLASSNAME EQ CLASSNAME.
    IF SY-SUBRC NE SPACE.
      MESSAGE W001 RAISING NOTHING_FOUND.
    ENDIF.
  ELSEIF CLASSTYPE NE SPACE AND CLASSNAME EQ SPACE.
    SELECT * FROM BDS_LOCL INTO TABLE DOCUMENT_CLASSES
                                  WHERE CLASSTYPE EQ CLASSTYPE.
    IF SY-SUBRC NE SPACE.
      MESSAGE W001 RAISING NOTHING_FOUND.
    ENDIF.
  ENDIF.





ENDFUNCTION.