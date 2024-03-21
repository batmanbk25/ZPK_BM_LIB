FUNCTION ZFM_BDS_GET_IMG_URL.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_TDOBJECT) TYPE  TDOBJECTGR DEFAULT 'GRAPHICS'
*"     REFERENCE(I_TDNAME) TYPE  TDOBNAME
*"     VALUE(I_TDID) TYPE  TDIDGR DEFAULT 'BMAP'
*"     VALUE(I_TDBTYPE) TYPE  TDBTYPE DEFAULT 'BMON'
*"  EXPORTING
*"     REFERENCE(E_GRAPHIC_URL) TYPE  CNDP_URL
*"--------------------------------------------------------------------
DATA:
    LW_GRAPHIC_XSTR TYPE XSTRING,
    LW_GRAPHIC_SIZE TYPE I,
    LW_GRAPHIC_CONV TYPE I,
    LW_GRAPHIC_OFFS TYPE I,
    BEGIN OF LT_GRAPHIC_TABLE OCCURS 0,
        LINE(255) TYPE X,
    END OF LT_GRAPHIC_TABLE..

  CLEAR: E_GRAPHIC_URL.

  CALL METHOD CL_SSF_XSF_UTILITIES=>GET_BDS_GRAPHIC_AS_BMP
    EXPORTING
      P_OBJECT  = I_TDOBJECT
      P_NAME    = I_TDNAME
      P_ID      = I_TDID
      P_BTYPE   = I_TDBTYPE
    RECEIVING
      P_BMP     = LW_GRAPHIC_XSTR
    EXCEPTIONS
      NOT_FOUND = 1
      OTHERS    = 2.

  LW_GRAPHIC_SIZE = XSTRLEN( LW_GRAPHIC_XSTR ).
  CHECK LW_GRAPHIC_SIZE > 0.

  LW_GRAPHIC_CONV = LW_GRAPHIC_SIZE.
  LW_GRAPHIC_OFFS = 0.

  WHILE LW_GRAPHIC_CONV > 255.
    LT_GRAPHIC_TABLE-LINE = LW_GRAPHIC_XSTR+LW_GRAPHIC_OFFS(255).
    APPEND LT_GRAPHIC_TABLE.
    LW_GRAPHIC_OFFS = LW_GRAPHIC_OFFS + 255.
    LW_GRAPHIC_CONV = LW_GRAPHIC_CONV - 255.
  ENDWHILE.

  LT_GRAPHIC_TABLE-LINE =
                    LW_GRAPHIC_XSTR+LW_GRAPHIC_OFFS(LW_GRAPHIC_CONV).
  APPEND LT_GRAPHIC_TABLE.

  CALL FUNCTION 'DP_CREATE_URL'
       EXPORTING
          TYPE                 = 'image'                    "#EC NOTEXT
          SUBTYPE              = CNDP_SAP_TAB_UNKNOWN " 'X-UNKNOWN'
          SIZE                 = LW_GRAPHIC_SIZE
          LIFETIME             = CNDP_LIFETIME_TRANSACTION  " 'T'
       TABLES
          DATA                 = LT_GRAPHIC_TABLE
       CHANGING
          URL                  = E_GRAPHIC_URL
       EXCEPTIONS
*           DP_INVALID_PARAMETER = 1
*           DP_ERROR_PUT_TABLE   = 2
*           DP_ERROR_GENERAL     = 3
          OTHERS               = 4 .
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    EXIT.
  ENDIF.





ENDFUNCTION.
