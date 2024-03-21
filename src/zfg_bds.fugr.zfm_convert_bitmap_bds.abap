FUNCTION ZFM_CONVERT_BITMAP_BDS.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(COLOR) TYPE  C DEFAULT SPACE
*"     VALUE(FORMAT) TYPE  C
*"     VALUE(RESIDENT) TYPE  C DEFAULT SPACE
*"     VALUE(BITMAP_BYTECOUNT) TYPE  I
*"     VALUE(COMPRESS_BITMAP) TYPE  C DEFAULT SPACE
*"  EXPORTING
*"     VALUE(WIDTH_TW) LIKE  STXBITMAPS-WIDTHTW
*"     VALUE(HEIGHT_TW) LIKE  STXBITMAPS-HEIGHTTW
*"     VALUE(WIDTH_PIX) LIKE  STXBITMAPS-WIDTHPIX
*"     VALUE(HEIGHT_PIX) LIKE  STXBITMAPS-HEIGHTPIX
*"     VALUE(DPI) LIKE  STXBITMAPS-RESOLUTION
*"     REFERENCE(BDS_BYTECOUNT) TYPE  I
*"  TABLES
*"      BITMAP_FILE
*"      BITMAP_FILE_BDS TYPE  SBDST_CONTENT
*"  EXCEPTIONS
*"      FORMAT_NOT_SUPPORTED
*"      NO_BMP_FILE
*"      BMPERR_INVALID_FORMAT
*"      BMPERR_NO_COLORTABLE
*"      BMPERR_UNSUP_COMPRESSION
*"      BMPERR_CORRUPT_RLE_DATA
*"      TIFFERR_INVALID_FORMAT
*"      TIFFERR_NO_COLORTABLE
*"      TIFFERR_UNSUP_COMPRESSION
*"      BMPERR_EOF
*"--------------------------------------------------------------------
* BIOK000391 add full color support to TIFF->BDS and BMP->BDS conversion
* BIOK010505 run-length compression of BDS bitmaps

  CASE FORMAT.
    WHEN 'BMP'.
      PERFORM FILL_BMFILE_FROM_BMP TABLES BITMAP_FILE
                                   USING BITMAP_BYTECOUNT
                                         COLOR.
      PERFORM FILL_BDS_CONTENT_FROM_BMINFO TABLES BITMAP_FILE_BDS
                                           USING COLOR
                                                 RESIDENT
                                                 COMPRESS_BITMAP
                                                 BDS_BYTECOUNT.
    WHEN 'TIF'.
      PERFORM FILL_BMFILE_FROM_TIF TABLES BITMAP_FILE
                                   USING BITMAP_BYTECOUNT
                                         COLOR.
      PERFORM FILL_BDS_CONTENT_FROM_BMINFO TABLES BITMAP_FILE_BDS
                                           USING COLOR
                                                 RESIDENT
                                                 COMPRESS_BITMAP
                                                 BDS_BYTECOUNT.
    WHEN OTHERS.
      MESSAGE E873 WITH FORMAT RAISING FORMAT_NOT_SUPPORTED.
  ENDCASE.
  WIDTH_TW    = OTF_BMINFO-W_TW.
  HEIGHT_TW   = OTF_BMINFO-H_TW.
  WIDTH_PIX   = OTF_BMINFO-W_PIX.
  HEIGHT_PIX  = OTF_BMINFO-H_PIX.
  DPI         = OTF_BMINFO-DPI.





ENDFUNCTION.
