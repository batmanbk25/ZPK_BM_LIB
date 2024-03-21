*----------------------------------------------------------------------*
***INCLUDE LZFG_BDSF01.
*----------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  0200_PBO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0200_PBO .
  DATA:
    LW_URL        TYPE CNDP_URL.

  IF GO_CONTAINER_OLD IS INITIAL.
    "Creating the object for the container
    CREATE OBJECT GO_CONTAINER_OLD
      EXPORTING
        REPID           = SY-REPID
        DYNNR           = '0200'
        CONTAINER_NAME  = 'PICTURECONTROL_OLD'.
    CREATE OBJECT GO_CONTAINER_NEW
      EXPORTING
        REPID           = SY-REPID
        DYNNR           = '0200'
        CONTAINER_NAME  = 'PICTURECONTROL_NEW'.

    CREATE OBJECT GO_PIC_OLD
      EXPORTING
        PARENT = GO_CONTAINER_OLD.

    CREATE OBJECT GO_PIC_NEW
      EXPORTING
        PARENT = GO_CONTAINER_NEW.
  ENDIF.

  IF GW_REFRESH_PIC = GC_XMARK.
    CALL FUNCTION 'ZFM_BDS_GET_IMG_URL'
      EXPORTING
        I_TDNAME            = ZST_BDS_UPIMG-BDSNAME
      IMPORTING
        E_GRAPHIC_URL       = LW_URL.

    IF LW_URL IS NOT INITIAL.
      CALL METHOD GO_PIC_OLD->LOAD_PICTURE_FROM_URL
        EXPORTING
          URL     = LW_URL.
    ELSE.
      CALL METHOD GO_PIC_OLD->CLEAR_PICTURE.
    ENDIF.
    CLEAR: GW_REFRESH_PIC.
  ENDIF.
ENDFORM.                    " 0200_PBO

*&---------------------------------------------------------------------*
*&      Form  F4_FILENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4_FILENAME .
  DATA:
    LW_FILENAME       TYPE RLGRAP-FILENAME,
    LT_FILE_TABLE     TYPE FILETABLE,
    LW_RC             TYPE I,
    LW_USER_ACTION    TYPE I.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
*    EXPORTING
*      WINDOW_TITLE            = 'Upload File'
*      DEFAULT_EXTENSION       =
*      DEFAULT_FILENAME        =
*      FILE_FILTER             =
*      WITH_ENCODING           =
*      INITIAL_DIRECTORY       =
*      MULTISELECTION          =
    CHANGING
      FILE_TABLE              = LT_FILE_TABLE
      RC                      = LW_RC
      USER_ACTION             = LW_USER_ACTION
    EXCEPTIONS
      FILE_OPEN_DIALOG_FAILED = 1
      CNTL_ERROR              = 2
      ERROR_NO_GUI            = 3
      NOT_SUPPORTED_BY_GUI    = 4
      OTHERS                  = 5.
  CHECK SY-SUBRC IS INITIAL.
  IF LW_USER_ACTION = CL_GUI_FRONTEND_SERVICES=>ACTION_OK.
    CONCATENATE LINES OF LT_FILE_TABLE INTO ZST_BDS_UPIMG-FILENAME.

    CONCATENATE 'FILE://' ZST_BDS_UPIMG-FILENAME
    INTO LW_FILENAME.

    CALL METHOD GO_PIC_NEW->LOAD_PICTURE_FROM_URL
      EXPORTING
        URL = LW_FILENAME.


    CALL METHOD CL_GUI_CFW=>UPDATE_VIEW.
  ENDIF.
ENDFORM.                    " F4_FILENAME
*&---------------------------------------------------------------------*
*&      Form  SAVE_IMG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_IMG .
  DATA:
    LW_RESOLUTION     TYPE STXBITMAPS-RESOLUTION,
    LW_DOCID          TYPE STXBITMAPS-DOCID,
    LW_URL            TYPE CNDP_URL.
  DATA :
    GO_IGS_IMAGE_CONVERTER TYPE REF TO CL_IGS_IMAGE_CONVERTER.


  CHECK ZST_BDS_UPIMG-FILENAME IS NOT INITIAL.

*  CREATE OBJECT GO_IGS_IMAGE_CONVERTER.
*  GO_IGS_IMAGE_CONVERTER->INPUT   = 'image/bmp'.
*  GO_IGS_IMAGE_CONVERTER->OUTPUT  = 'image/bmp'.
*  GO_IGS_IMAGE_CONVERTER->WIDTH   = 90.
*  GO_IGS_IMAGE_CONVERTER->HEIGHT  = 30.
*
*  CALL METHOD GO_IGS_IMAGE_CONVERTER->SET_IMAGE
*    EXPORTING
*      BLOB      = I_IMAGE_INFO-IMG_DAT
*      BLOB_SIZE = I_IMAGE_INFO-IMG_LENGTH.
*
*  CALL METHOD GO_IGS_IMAGE_CONVERTER->EXECUTE
*    EXCEPTIONS
*      COMMUNICATION_ERROR = 1
*      INTERNAL_ERROR      = 2
*      EXTERNAL_ERROR      = 3
*      OTHERS              = 4.
*
*  IF SY-SUBRC = 0.
*    CALL METHOD GO_IGS_IMAGE_CONVERTER->GET_IMAGE
*      IMPORTING
*        BLOB      = C_DES_IMAGE_INFO-IMG_DAT
*        BLOB_SIZE = C_DES_IMAGE_INFO-IMG_LENGTH
*        BLOB_TYPE = C_DES_IMAGE_INFO-IMG_TYPE.
*  ENDIF.

  PERFORM IMPORT_BITMAP_BDS
    IN PROGRAM SAPLSTXBITMAPS
              USING    ZST_BDS_UPIMG-FILENAME
                       ZST_BDS_UPIMG-BDSNAME
                       'GRAPHICS'     "Object
                       'BMAP'         "ID
                       'BMON'         "B/W
                       'BMP'          "Extension
                       ''             "title
                       SPACE
                       'X'
                       'X'
              CHANGING LW_DOCID
                       LW_RESOLUTION.

  GW_REFRESH_PIC = GC_XMARK.
ENDFORM.                    " SAVE_IMG
