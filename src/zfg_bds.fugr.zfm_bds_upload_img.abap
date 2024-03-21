FUNCTION ZFM_BDS_UPLOAD_IMG.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_IMGNAME) TYPE  TDOBNAME
*"--------------------------------------------------------------------
DATA:
    LW_CNDP_URL       TYPE CNDP_URL.

  ZST_BDS_UPIMG-BDSNAME = I_IMGNAME.
  CLEAR: ZST_BDS_UPIMG-FILENAME.

  CALL FUNCTION 'ZFM_BDS_GET_IMG_URL'
    EXPORTING
*     I_TDOBJECT          = 'GRAPHICS'
      I_TDNAME            = I_IMGNAME
*     I_TDID              = 'BMAP'
*     I_TDBTYPE           = 'BMON'
    IMPORTING
      E_GRAPHIC_URL       = LW_CNDP_URL.

  GW_REFRESH_PIC = GC_XMARK.
  CALL SCREEN 0200 STARTING AT 10 10.





ENDFUNCTION.
