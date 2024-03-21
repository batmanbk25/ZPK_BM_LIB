FUNCTION ZFM_BM_XLWB_CALLFORM.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_FORMNAME) TYPE  ANY
*"     REFERENCE(IV_CONTEXT_REF)
*"     VALUE(IV_VIEWER_TITLE) TYPE  ANY DEFAULT SY-TITLE
*"     REFERENCE(IV_VIEWER_INPLACE) TYPE  FLAG DEFAULT 'X'
*"     VALUE(IV_VIEWER_CALLBACK_PROG) TYPE  ANY DEFAULT SY-CPROG
*"     REFERENCE(IV_VIEWER_CALLBACK_FORM) TYPE  ANY OPTIONAL
*"     REFERENCE(IV_VIEWER_SUPPRESS) TYPE  ANY OPTIONAL
*"     REFERENCE(IV_PROTECT) TYPE  FLAG OPTIONAL
*"     REFERENCE(IV_SAVE_AS) TYPE  ANY OPTIONAL
*"     REFERENCE(IV_SAVE_AS_APPSERVER) TYPE  ANY OPTIONAL
*"     REFERENCE(IV_STARTUP_MACRO) TYPE  ANY OPTIONAL
*"     REFERENCE(IT_DOCPROPERTIES) TYPE  CKF_FIELD_VALUE_TABLE OPTIONAL
*"     REFERENCE(I_DEFAULT_FILENAME) TYPE  STRING OPTIONAL
*"  EXPORTING
*"     REFERENCE(EV_DOCUMENT_RAWDATA) TYPE  MIME_DATA
*"  EXCEPTIONS
*"      PROCESS_TERMINATED
*"----------------------------------------------------------------------
*=======================================================================
*=======================================================================
* Copyright 2016 Igor Borodin
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*     http://www.apache.org/licenses/LICENSE-2.0
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*=======================================================================
*=======================================================================
*
* XLSX-Workbench(XLWB) components                         [Version 4.05]
* Documentation is available at:
*                             https://sites.google.com/site/sapxlwb/home
*=======================================================================
* Render and display form
*=======================================================================
*
* Parameters:
*     IV_FORMNAME         -->> name of the form
*     IV_CONTEXT_REF      -->> data for the form building
*     IV_VIEWER_TITLE     -->> text, which displayed in the title bar of the Viewer
*     IV_VIEWER_INPLACE   -->> set 'X' to show Excel in modal SAP-screen,
*                              or set SPACE for floating mode
*     IV_VIEWER_CALLBACK_PROG, IV_VIEWER_CALLBACK_FORM -->>
*                         -->> subroutine to customizing Viewer (see Docum.)
*     IV_VIEWER_SUPPRESS  -->> set 'X' to do not call the Viewer
*     IV_PROTECT          -->> set 'X', if tamper protection of workbook is required
*     IV_SAVE_AS          -->> full path (including file extention),
*                              if you want to save file on the Frontend
*     IV_SAVE_AS_APPSERVER-->> full path (including file extention),
*                              if you want to save file on the Application server
*     IV_STARTUP_MACRO    -->> Only for .XLSM (not for .XLSX)
*                              macro name, which should be run directly after file creation
*                              For example: Module1.Macro1
*     IT_DOCPROPERTIES    -->> Document properties (ie Author, Company etc.)
*
*
*=======================================================================

  DATA:
    LR_FORMRUNTIME        TYPE REF TO LCL_FORMRUNTIME ,
    LV_FULLPATH           TYPE STRING ,
    LV_MESSAGE            TYPE STRING ,
    LV_DOCUMENT_SIZE      TYPE I ,
    LT_DOCUMENT_TABLE     TYPE STANDARD TABLE OF W3MIME .

**********************************************************************
*     TuanBA add 21/11/2017 - Start
**********************************************************************
  GW_DEFAULT_FILE = I_DEFAULT_FILENAME.
**********************************************************************
*     TuanBA add 21/11/2017 - End
**********************************************************************

* compose document
  CREATE OBJECT LR_FORMRUNTIME
    EXPORTING
      IV_FORMNAME        = IV_FORMNAME
      IV_CONTEXT_REF     = IV_CONTEXT_REF
      IV_PROTECT         = IV_PROTECT
      IV_STARTUP_MACRO   = IV_STARTUP_MACRO
      IT_DOCPROPERTIES   = IT_DOCPROPERTIES
    EXCEPTIONS
      PROCESS_TERMINATED = 1.
  IF SY-SUBRC NE 0 .
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
       RAISING PROCESS_TERMINATED .
  ENDIF .

  EV_DOCUMENT_RAWDATA  = LR_FORMRUNTIME->GET_RAWDATA( ) .

  LR_FORMRUNTIME->FREE( ) .
  FREE LR_FORMRUNTIME .

* call viewer (if required)
  IF  IV_VIEWER_SUPPRESS IS INITIAL
  AND LCL_ROOT=>IS_GUI_AVAILABLE( ) IS NOT INITIAL .

    IF GV_VIEWER_BUNDLE_COLLECT IS INITIAL .
      PERFORM VIEWER_BUNDLE_REFRESH .
    ENDIF .

    IF GR_VIEWER IS BOUND .
      GR_VIEWER->DOCUMENT_ADD(
          IV_DOCUMENT_RAWDATA = EV_DOCUMENT_RAWDATA
          IV_DOCUMENT_TITLE   = IV_VIEWER_TITLE
          IV_CALLBACK_PROG    = IV_VIEWER_CALLBACK_PROG
          IV_CALLBACK_FORM    = IV_VIEWER_CALLBACK_FORM
          IV_INPLACE          = IV_VIEWER_INPLACE ) .
    ENDIF .

    IF GV_VIEWER_BUNDLE_COLLECT IS INITIAL .
      PERFORM VIEWER_BUNDLE_CLOSE .
    ENDIF .
  ENDIF .

* download on frontend (if required)
  IF IV_SAVE_AS IS NOT INITIAL .
    LV_FULLPATH = IV_SAVE_AS .

    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        BUFFER        = EV_DOCUMENT_RAWDATA
      IMPORTING
        OUTPUT_LENGTH = LV_DOCUMENT_SIZE
      TABLES
        BINARY_TAB    = LT_DOCUMENT_TABLE.

    CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD(
      EXPORTING BIN_FILESIZE = LV_DOCUMENT_SIZE
                FILENAME     = LV_FULLPATH
                FILETYPE     = 'BIN'
      CHANGING  DATA_TAB     = LT_DOCUMENT_TABLE
      EXCEPTIONS OTHERS      = 24 ).
    IF SY-SUBRC NE 0 .
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
         RAISING PROCESS_TERMINATED .
    ENDIF .

  ENDIF .

* download on application server (if required)
  IF IV_SAVE_AS_APPSERVER IS NOT INITIAL .
    LV_FULLPATH = IV_SAVE_AS_APPSERVER .

    DELETE DATASET LV_FULLPATH .
    OPEN DATASET LV_FULLPATH FOR OUTPUT IN BINARY MODE MESSAGE LV_MESSAGE .
    IF SY-SUBRC NE 0 .
      MESSAGE E000(LP) WITH `OPEN DATASET ERROR:` LV_MESSAGE
      RAISING PROCESS_TERMINATED .
    ENDIF .
    TRANSFER EV_DOCUMENT_RAWDATA TO LV_FULLPATH .
    CLOSE DATASET LV_FULLPATH .
  ENDIF .

ENDFUNCTION.
