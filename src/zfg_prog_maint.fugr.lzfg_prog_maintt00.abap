*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTB_BM_DATCON...................................*
DATA:  BEGIN OF STATUS_ZTB_BM_DATCON                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_BM_DATCON                 .
CONTROLS: TCTRL_ZTB_BM_DATCON
            TYPE TABLEVIEW USING SCREEN '0454'.
*...processing: ZTB_BM_DATGROUP.................................*
DATA:  BEGIN OF STATUS_ZTB_BM_DATGROUP               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_BM_DATGROUP               .
CONTROLS: TCTRL_ZTB_BM_DATGROUP
            TYPE TABLEVIEW USING SCREEN '0456'.
*...processing: ZTB_BM_DATTYPE..................................*
DATA:  BEGIN OF STATUS_ZTB_BM_DATTYPE                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_BM_DATTYPE                .
CONTROLS: TCTRL_ZTB_BM_DATTYPE
            TYPE TABLEVIEW USING SCREEN '0450'.
*...processing: ZTB_BM_DF_EC....................................*
DATA:  BEGIN OF STATUS_ZTB_BM_DF_EC                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_BM_DF_EC                  .
CONTROLS: TCTRL_ZTB_BM_DF_EC
            TYPE TABLEVIEW USING SCREEN '0710'.
*...processing: ZTB_BM_DF_STR...................................*
DATA:  BEGIN OF STATUS_ZTB_BM_DF_STR                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_BM_DF_STR                 .
CONTROLS: TCTRL_ZTB_BM_DF_STR
            TYPE TABLEVIEW USING SCREEN '0700'.
*...processing: ZTB_BM_DF_TYP...................................*
DATA:  BEGIN OF STATUS_ZTB_BM_DF_TYP                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_BM_DF_TYP                 .
CONTROLS: TCTRL_ZTB_BM_DF_TYP
            TYPE TABLEVIEW USING SCREEN '0704'.
*...processing: ZTB_BM_IM_CAT...................................*
DATA:  BEGIN OF STATUS_ZTB_BM_IM_CAT                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_BM_IM_CAT                 .
CONTROLS: TCTRL_ZTB_BM_IM_CAT
            TYPE TABLEVIEW USING SCREEN '0150'.
*...processing: ZTB_BM_IM_MARA..................................*
DATA:  BEGIN OF STATUS_ZTB_BM_IM_MARA                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_BM_IM_MARA                .
CONTROLS: TCTRL_ZTB_BM_IM_MARA
            TYPE TABLEVIEW USING SCREEN '0153'.
*...processing: ZTB_BM_ROLE.....................................*
DATA:  BEGIN OF STATUS_ZTB_BM_ROLE                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_BM_ROLE                   .
CONTROLS: TCTRL_ZTB_BM_ROLE
            TYPE TABLEVIEW USING SCREEN '0126'.
*...processing: ZTB_BM_SCP_PAR..................................*
DATA:  BEGIN OF STATUS_ZTB_BM_SCP_PAR                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_BM_SCP_PAR                .
CONTROLS: TCTRL_ZTB_BM_SCP_PAR
            TYPE TABLEVIEW USING SCREEN '0138'.
*...processing: ZTB_BM_SV_TRANS.................................*
DATA:  BEGIN OF STATUS_ZTB_BM_SV_TRANS               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_BM_SV_TRANS               .
CONTROLS: TCTRL_ZTB_BM_SV_TRANS
            TYPE TABLEVIEW USING SCREEN '0606'.
*...processing: ZTB_BM_SV_USR...................................*
DATA:  BEGIN OF STATUS_ZTB_BM_SV_USR                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_BM_SV_USR                 .
CONTROLS: TCTRL_ZTB_BM_SV_USR
            TYPE TABLEVIEW USING SCREEN '0458'.
*...processing: ZTB_BM_TAB_DESC.................................*
DATA:  BEGIN OF STATUS_ZTB_BM_TAB_DESC               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_BM_TAB_DESC               .
CONTROLS: TCTRL_ZTB_BM_TAB_DESC
            TYPE TABLEVIEW USING SCREEN '0140'.
*...processing: ZTB_BM_USR_ROLE.................................*
DATA:  BEGIN OF STATUS_ZTB_BM_USR_ROLE               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_BM_USR_ROLE               .
CONTROLS: TCTRL_ZTB_BM_USR_ROLE
            TYPE TABLEVIEW USING SCREEN '0134'.
*...processing: ZTB_FIELD_DB....................................*
DATA:  BEGIN OF STATUS_ZTB_FIELD_DB                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_FIELD_DB                  .
CONTROLS: TCTRL_ZTB_FIELD_DB
            TYPE TABLEVIEW USING SCREEN '0202'.
*...processing: ZTB_JBCF_JOB....................................*
DATA:  BEGIN OF STATUS_ZTB_JBCF_JOB                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_JBCF_JOB                  .
CONTROLS: TCTRL_ZTB_JBCF_JOB
            TYPE TABLEVIEW USING SCREEN '0300'.
*...processing: ZTB_JBCF_JSTEP..................................*
DATA:  BEGIN OF STATUS_ZTB_JBCF_JSTEP                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_JBCF_JSTEP                .
CONTROLS: TCTRL_ZTB_JBCF_JSTEP
            TYPE TABLEVIEW USING SCREEN '0304'.
*...processing: ZTB_MC_BUSAREA..................................*
DATA:  BEGIN OF STATUS_ZTB_MC_BUSAREA                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_MC_BUSAREA                .
CONTROLS: TCTRL_ZTB_MC_BUSAREA
            TYPE TABLEVIEW USING SCREEN '0400'.
*...processing: ZTB_MC_BUSELE...................................*
DATA:  BEGIN OF STATUS_ZTB_MC_BUSELE                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_MC_BUSELE                 .
CONTROLS: TCTRL_ZTB_MC_BUSELE
            TYPE TABLEVIEW USING SCREEN '0402'.
*...processing: ZTB_MC_BUSFLD...................................*
DATA:  BEGIN OF STATUS_ZTB_MC_BUSFLD                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_MC_BUSFLD                 .
CONTROLS: TCTRL_ZTB_MC_BUSFLD
            TYPE TABLEVIEW USING SCREEN '0404'.
*...processing: ZTB_MC_BUSKEYG..................................*
DATA:  BEGIN OF STATUS_ZTB_MC_BUSKEYG                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_MC_BUSKEYG                .
CONTROLS: TCTRL_ZTB_MC_BUSKEYG
            TYPE TABLEVIEW USING SCREEN '0418'.
*...processing: ZTB_MC_BUSMAP...................................*
DATA:  BEGIN OF STATUS_ZTB_MC_BUSMAP                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_MC_BUSMAP                 .
CONTROLS: TCTRL_ZTB_MC_BUSMAP
            TYPE TABLEVIEW USING SCREEN '0406'.
*...processing: ZTB_MC_BUSMAPID.................................*
DATA:  BEGIN OF STATUS_ZTB_MC_BUSMAPID               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_MC_BUSMAPID               .
CONTROLS: TCTRL_ZTB_MC_BUSMAPID
            TYPE TABLEVIEW USING SCREEN '0420'.
*...processing: ZTB_MC_BUSTAB...................................*
DATA:  BEGIN OF STATUS_ZTB_MC_BUSTAB                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_MC_BUSTAB                 .
CONTROLS: TCTRL_ZTB_MC_BUSTAB
            TYPE TABLEVIEW USING SCREEN '0424'.
*...processing: ZVI_ALV_LAYOUT..................................*
TABLES: ZVI_ALV_LAYOUT, *ZVI_ALV_LAYOUT. "view work areas
CONTROLS: TCTRL_ZVI_ALV_LAYOUT
TYPE TABLEVIEW USING SCREEN '0104'.
DATA: BEGIN OF STATUS_ZVI_ALV_LAYOUT. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_ALV_LAYOUT.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_ALV_LAYOUT_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_ALV_LAYOUT.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_ALV_LAYOUT_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_ALV_LAYOUT_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_ALV_LAYOUT.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_ALV_LAYOUT_TOTAL.

*...processing: ZVI_BM_CHA_LAYO.................................*
TABLES: ZVI_BM_CHA_LAYO, *ZVI_BM_CHA_LAYO. "view work areas
CONTROLS: TCTRL_ZVI_BM_CHA_LAYO
TYPE TABLEVIEW USING SCREEN '0154'.
DATA: BEGIN OF STATUS_ZVI_BM_CHA_LAYO. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_BM_CHA_LAYO.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_BM_CHA_LAYO_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_CHA_LAYO.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_CHA_LAYO_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_BM_CHA_LAYO_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_CHA_LAYO.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_CHA_LAYO_TOTAL.

*...processing: ZVI_BM_CHA_SERI.................................*
TABLES: ZVI_BM_CHA_SERI, *ZVI_BM_CHA_SERI. "view work areas
CONTROLS: TCTRL_ZVI_BM_CHA_SERI
TYPE TABLEVIEW USING SCREEN '0156'.
DATA: BEGIN OF STATUS_ZVI_BM_CHA_SERI. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_BM_CHA_SERI.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_BM_CHA_SERI_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_CHA_SERI.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_CHA_SERI_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_BM_CHA_SERI_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_CHA_SERI.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_CHA_SERI_TOTAL.

*...processing: ZVI_BM_DATCON...................................*
TABLES: ZVI_BM_DATCON, *ZVI_BM_DATCON. "view work areas
CONTROLS: TCTRL_ZVI_BM_DATCON
TYPE TABLEVIEW USING SCREEN '0452'.
DATA: BEGIN OF STATUS_ZVI_BM_DATCON. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_BM_DATCON.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_BM_DATCON_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_DATCON.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_DATCON_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_BM_DATCON_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_DATCON.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_DATCON_TOTAL.

*...processing: ZVI_BM_DF_FIELD.................................*
TABLES: ZVI_BM_DF_FIELD, *ZVI_BM_DF_FIELD. "view work areas
CONTROLS: TCTRL_ZVI_BM_DF_FIELD
TYPE TABLEVIEW USING SCREEN '0702'.
DATA: BEGIN OF STATUS_ZVI_BM_DF_FIELD. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_BM_DF_FIELD.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_BM_DF_FIELD_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_DF_FIELD.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_DF_FIELD_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_BM_DF_FIELD_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_DF_FIELD.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_DF_FIELD_TOTAL.

*...processing: ZVI_BM_DF_TYPLS.................................*
TABLES: ZVI_BM_DF_TYPLS, *ZVI_BM_DF_TYPLS. "view work areas
CONTROLS: TCTRL_ZVI_BM_DF_TYPLS
TYPE TABLEVIEW USING SCREEN '0706'.
DATA: BEGIN OF STATUS_ZVI_BM_DF_TYPLS. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_BM_DF_TYPLS.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_BM_DF_TYPLS_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_DF_TYPLS.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_DF_TYPLS_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_BM_DF_TYPLS_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_DF_TYPLS.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_DF_TYPLS_TOTAL.

*...processing: ZVI_BM_DF_TYP_EC................................*
TABLES: ZVI_BM_DF_TYP_EC, *ZVI_BM_DF_TYP_EC. "view work areas
CONTROLS: TCTRL_ZVI_BM_DF_TYP_EC
TYPE TABLEVIEW USING SCREEN '0708'.
DATA: BEGIN OF STATUS_ZVI_BM_DF_TYP_EC. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_BM_DF_TYP_EC.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_BM_DF_TYP_EC_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_DF_TYP_EC.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_DF_TYP_EC_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_BM_DF_TYP_EC_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_DF_TYP_EC.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_DF_TYP_EC_TOTAL.

*...processing: ZVI_BM_PROG_ROLE................................*
TABLES: ZVI_BM_PROG_ROLE, *ZVI_BM_PROG_ROLE. "view work areas
CONTROLS: TCTRL_ZVI_BM_PROG_ROLE
TYPE TABLEVIEW USING SCREEN '0136'.
DATA: BEGIN OF STATUS_ZVI_BM_PROG_ROLE. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_BM_PROG_ROLE.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_BM_PROG_ROLE_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_PROG_ROLE.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_PROG_ROLE_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_BM_PROG_ROLE_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_PROG_ROLE.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_PROG_ROLE_TOTAL.

*...processing: ZVI_BM_ROLE_FLD.................................*
TABLES: ZVI_BM_ROLE_FLD, *ZVI_BM_ROLE_FLD. "view work areas
CONTROLS: TCTRL_ZVI_BM_ROLE_FLD
TYPE TABLEVIEW USING SCREEN '0132'.
DATA: BEGIN OF STATUS_ZVI_BM_ROLE_FLD. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_BM_ROLE_FLD.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_BM_ROLE_FLD_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_ROLE_FLD.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_ROLE_FLD_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_BM_ROLE_FLD_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_ROLE_FLD.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_ROLE_FLD_TOTAL.

*...processing: ZVI_BM_SL_SCRVL.................................*
TABLES: ZVI_BM_SL_SCRVL, *ZVI_BM_SL_SCRVL. "view work areas
CONTROLS: TCTRL_ZVI_BM_SL_SCRVL
TYPE TABLEVIEW USING SCREEN '0146'.
DATA: BEGIN OF STATUS_ZVI_BM_SL_SCRVL. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_BM_SL_SCRVL.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_BM_SL_SCRVL_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_SL_SCRVL.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_SL_SCRVL_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_BM_SL_SCRVL_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_SL_SCRVL.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_SL_SCRVL_TOTAL.

*...processing: ZVI_BM_SL_STEP..................................*
TABLES: ZVI_BM_SL_STEP, *ZVI_BM_SL_STEP. "view work areas
CONTROLS: TCTRL_ZVI_BM_SL_STEP
TYPE TABLEVIEW USING SCREEN '0144'.
DATA: BEGIN OF STATUS_ZVI_BM_SL_STEP. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_BM_SL_STEP.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_BM_SL_STEP_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_SL_STEP.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_SL_STEP_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_BM_SL_STEP_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_SL_STEP.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_SL_STEP_TOTAL.

*...processing: ZVI_BM_SL_TRAN..................................*
TABLES: ZVI_BM_SL_TRAN, *ZVI_BM_SL_TRAN. "view work areas
CONTROLS: TCTRL_ZVI_BM_SL_TRAN
TYPE TABLEVIEW USING SCREEN '0142'.
DATA: BEGIN OF STATUS_ZVI_BM_SL_TRAN. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_BM_SL_TRAN.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_BM_SL_TRAN_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_SL_TRAN.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_SL_TRAN_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_BM_SL_TRAN_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_SL_TRAN.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_SL_TRAN_TOTAL.

*...processing: ZVI_BM_SV_TRAND.................................*
TABLES: ZVI_BM_SV_TRAND, *ZVI_BM_SV_TRAND. "view work areas
CONTROLS: TCTRL_ZVI_BM_SV_TRAND
TYPE TABLEVIEW USING SCREEN '0604'.
DATA: BEGIN OF STATUS_ZVI_BM_SV_TRAND. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_BM_SV_TRAND.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_BM_SV_TRAND_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_SV_TRAND.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_SV_TRAND_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_BM_SV_TRAND_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_SV_TRAND.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_SV_TRAND_TOTAL.

*...processing: ZVI_BM_SV_TRANS.................................*
TABLES: ZVI_BM_SV_TRANS, *ZVI_BM_SV_TRANS. "view work areas
CONTROLS: TCTRL_ZVI_BM_SV_TRANS
TYPE TABLEVIEW USING SCREEN '0602'.
DATA: BEGIN OF STATUS_ZVI_BM_SV_TRANS. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_BM_SV_TRANS.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_BM_SV_TRANS_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_SV_TRANS.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_SV_TRANS_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_BM_SV_TRANS_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_SV_TRANS.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_SV_TRANS_TOTAL.

*...processing: ZVI_BM_USR_ROLE.................................*
TABLES: ZVI_BM_USR_ROLE, *ZVI_BM_USR_ROLE. "view work areas
CONTROLS: TCTRL_ZVI_BM_USR_ROLE
TYPE TABLEVIEW USING SCREEN '0128'.
DATA: BEGIN OF STATUS_ZVI_BM_USR_ROLE. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_BM_USR_ROLE.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_BM_USR_ROLE_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_USR_ROLE.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_USR_ROLE_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_BM_USR_ROLE_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_BM_USR_ROLE.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_BM_USR_ROLE_TOTAL.

*...processing: ZVI_EXCEL_LAYOUT................................*
TABLES: ZVI_EXCEL_LAYOUT, *ZVI_EXCEL_LAYOUT. "view work areas
CONTROLS: TCTRL_ZVI_EXCEL_LAYOUT
TYPE TABLEVIEW USING SCREEN '0106'.
DATA: BEGIN OF STATUS_ZVI_EXCEL_LAYOUT. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_EXCEL_LAYOUT.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_EXCEL_LAYOUT_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_EXCEL_LAYOUT.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_EXCEL_LAYOUT_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_EXCEL_LAYOUT_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_EXCEL_LAYOUT.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_EXCEL_LAYOUT_TOTAL.

*...processing: ZVI_EXCEL_SHEETS................................*
TABLES: ZVI_EXCEL_SHEETS, *ZVI_EXCEL_SHEETS. "view work areas
CONTROLS: TCTRL_ZVI_EXCEL_SHEETS
TYPE TABLEVIEW USING SCREEN '0110'.
DATA: BEGIN OF STATUS_ZVI_EXCEL_SHEETS. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_EXCEL_SHEETS.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_EXCEL_SHEETS_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_EXCEL_SHEETS.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_EXCEL_SHEETS_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_EXCEL_SHEETS_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_EXCEL_SHEETS.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_EXCEL_SHEETS_TOTAL.

*...processing: ZVI_FIELD_DB....................................*
TABLES: ZVI_FIELD_DB, *ZVI_FIELD_DB. "view work areas
CONTROLS: TCTRL_ZVI_FIELD_DB
TYPE TABLEVIEW USING SCREEN '0102'.
DATA: BEGIN OF STATUS_ZVI_FIELD_DB. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_FIELD_DB.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_FIELD_DB_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_FIELD_DB.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_FIELD_DB_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_FIELD_DB_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_FIELD_DB.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_FIELD_DB_TOTAL.

*...processing: ZVI_FIELD_DESC..................................*
TABLES: ZVI_FIELD_DESC, *ZVI_FIELD_DESC. "view work areas
CONTROLS: TCTRL_ZVI_FIELD_DESC
TYPE TABLEVIEW USING SCREEN '0116'.
DATA: BEGIN OF STATUS_ZVI_FIELD_DESC. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_FIELD_DESC.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_FIELD_DESC_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_FIELD_DESC.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_FIELD_DESC_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_FIELD_DESC_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_FIELD_DESC.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_FIELD_DESC_TOTAL.

*...processing: ZVI_JBCF_JSTEP..................................*
TABLES: ZVI_JBCF_JSTEP, *ZVI_JBCF_JSTEP. "view work areas
CONTROLS: TCTRL_ZVI_JBCF_JSTEP
TYPE TABLEVIEW USING SCREEN '0302'.
DATA: BEGIN OF STATUS_ZVI_JBCF_JSTEP. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_JBCF_JSTEP.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_JBCF_JSTEP_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_JBCF_JSTEP.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_JBCF_JSTEP_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_JBCF_JSTEP_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_JBCF_JSTEP.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_JBCF_JSTEP_TOTAL.

*...processing: ZVI_MAP_SELSCR..................................*
TABLES: ZVI_MAP_SELSCR, *ZVI_MAP_SELSCR. "view work areas
CONTROLS: TCTRL_ZVI_MAP_SELSCR
TYPE TABLEVIEW USING SCREEN '0108'.
DATA: BEGIN OF STATUS_ZVI_MAP_SELSCR. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_MAP_SELSCR.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_MAP_SELSCR_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_MAP_SELSCR.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_MAP_SELSCR_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_MAP_SELSCR_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_MAP_SELSCR.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_MAP_SELSCR_TOTAL.

*...processing: ZVI_MC_BUSELE...................................*
TABLES: ZVI_MC_BUSELE, *ZVI_MC_BUSELE. "view work areas
CONTROLS: TCTRL_ZVI_MC_BUSELE
TYPE TABLEVIEW USING SCREEN '0408'.
DATA: BEGIN OF STATUS_ZVI_MC_BUSELE. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_MC_BUSELE.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_MC_BUSELE_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_MC_BUSELE.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_MC_BUSELE_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_MC_BUSELE_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_MC_BUSELE.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_MC_BUSELE_TOTAL.

*...processing: ZVI_MC_BUSFLD...................................*
TABLES: ZVI_MC_BUSFLD, *ZVI_MC_BUSFLD. "view work areas
CONTROLS: TCTRL_ZVI_MC_BUSFLD
TYPE TABLEVIEW USING SCREEN '0412'.
DATA: BEGIN OF STATUS_ZVI_MC_BUSFLD. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_MC_BUSFLD.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_MC_BUSFLD_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_MC_BUSFLD.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_MC_BUSFLD_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_MC_BUSFLD_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_MC_BUSFLD.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_MC_BUSFLD_TOTAL.

*...processing: ZVI_MC_BUSKEYE..................................*
TABLES: ZVI_MC_BUSKEYE, *ZVI_MC_BUSKEYE. "view work areas
CONTROLS: TCTRL_ZVI_MC_BUSKEYE
TYPE TABLEVIEW USING SCREEN '0414'.
DATA: BEGIN OF STATUS_ZVI_MC_BUSKEYE. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_MC_BUSKEYE.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_MC_BUSKEYE_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_MC_BUSKEYE.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_MC_BUSKEYE_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_MC_BUSKEYE_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_MC_BUSKEYE.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_MC_BUSKEYE_TOTAL.

*...processing: ZVI_MC_BUSKEYM..................................*
TABLES: ZVI_MC_BUSKEYM, *ZVI_MC_BUSKEYM. "view work areas
CONTROLS: TCTRL_ZVI_MC_BUSKEYM
TYPE TABLEVIEW USING SCREEN '0416'.
DATA: BEGIN OF STATUS_ZVI_MC_BUSKEYM. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_MC_BUSKEYM.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_MC_BUSKEYM_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_MC_BUSKEYM.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_MC_BUSKEYM_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_MC_BUSKEYM_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_MC_BUSKEYM.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_MC_BUSKEYM_TOTAL.

*...processing: ZVI_MC_BUSMAP...................................*
TABLES: ZVI_MC_BUSMAP, *ZVI_MC_BUSMAP. "view work areas
CONTROLS: TCTRL_ZVI_MC_BUSMAP
TYPE TABLEVIEW USING SCREEN '0422'.
DATA: BEGIN OF STATUS_ZVI_MC_BUSMAP. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_MC_BUSMAP.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_MC_BUSMAP_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_MC_BUSMAP.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_MC_BUSMAP_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_MC_BUSMAP_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_MC_BUSMAP.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_MC_BUSMAP_TOTAL.

*...processing: ZVI_MC_BUSTABF..................................*
TABLES: ZVI_MC_BUSTABF, *ZVI_MC_BUSTABF. "view work areas
CONTROLS: TCTRL_ZVI_MC_BUSTABF
TYPE TABLEVIEW USING SCREEN '0426'.
DATA: BEGIN OF STATUS_ZVI_MC_BUSTABF. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_MC_BUSTABF.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_MC_BUSTABF_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_MC_BUSTABF.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_MC_BUSTABF_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_MC_BUSTABF_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_MC_BUSTABF.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_MC_BUSTABF_TOTAL.

*...processing: ZVI_PROG........................................*
TABLES: ZVI_PROG, *ZVI_PROG. "view work areas
CONTROLS: TCTRL_ZVI_PROG
TYPE TABLEVIEW USING SCREEN '0100'.
DATA: BEGIN OF STATUS_ZVI_PROG. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_PROG.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_PROG_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_PROG.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_PROG_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_PROG_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_PROG.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_PROG_TOTAL.

*...processing: ZVI_PROG_FLOW...................................*
TABLES: ZVI_PROG_FLOW, *ZVI_PROG_FLOW. "view work areas
CONTROLS: TCTRL_ZVI_PROG_FLOW
TYPE TABLEVIEW USING SCREEN '0118'.
DATA: BEGIN OF STATUS_ZVI_PROG_FLOW. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_PROG_FLOW.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_PROG_FLOW_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_PROG_FLOW.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_PROG_FLOW_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_PROG_FLOW_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_PROG_FLOW.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_PROG_FLOW_TOTAL.

*...processing: ZVI_PROG_PRSF...................................*
TABLES: ZVI_PROG_PRSF, *ZVI_PROG_PRSF. "view work areas
CONTROLS: TCTRL_ZVI_PROG_PRSF
TYPE TABLEVIEW USING SCREEN '0124'.
DATA: BEGIN OF STATUS_ZVI_PROG_PRSF. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_PROG_PRSF.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_PROG_PRSF_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_PROG_PRSF.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_PROG_PRSF_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_PROG_PRSF_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_PROG_PRSF.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_PROG_PRSF_TOTAL.

*...processing: ZVI_PROG_PRSV...................................*
TABLES: ZVI_PROG_PRSV, *ZVI_PROG_PRSV. "view work areas
CONTROLS: TCTRL_ZVI_PROG_PRSV
TYPE TABLEVIEW USING SCREEN '0122'.
DATA: BEGIN OF STATUS_ZVI_PROG_PRSV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_PROG_PRSV.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_PROG_PRSV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_PROG_PRSV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_PROG_PRSV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_PROG_PRSV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_PROG_PRSV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_PROG_PRSV_TOTAL.

*...processing: ZVI_PROG_SCR....................................*
TABLES: ZVI_PROG_SCR, *ZVI_PROG_SCR. "view work areas
CONTROLS: TCTRL_ZVI_PROG_SCR
TYPE TABLEVIEW USING SCREEN '0120'.
DATA: BEGIN OF STATUS_ZVI_PROG_SCR. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_PROG_SCR.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_PROG_SCR_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_PROG_SCR.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_PROG_SCR_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_PROG_SCR_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_PROG_SCR.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_PROG_SCR_TOTAL.

*...processing: ZVI_PROG_STEP...................................*
TABLES: ZVI_PROG_STEP, *ZVI_PROG_STEP. "view work areas
CONTROLS: TCTRL_ZVI_PROG_STEP
TYPE TABLEVIEW USING SCREEN '0114'.
DATA: BEGIN OF STATUS_ZVI_PROG_STEP. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_PROG_STEP.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_PROG_STEP_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_PROG_STEP.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_PROG_STEP_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_PROG_STEP_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_PROG_STEP.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_PROG_STEP_TOTAL.

*...processing: ZVI_SHEET_LAYOUT................................*
TABLES: ZVI_SHEET_LAYOUT, *ZVI_SHEET_LAYOUT. "view work areas
CONTROLS: TCTRL_ZVI_SHEET_LAYOUT
TYPE TABLEVIEW USING SCREEN '0112'.
DATA: BEGIN OF STATUS_ZVI_SHEET_LAYOUT. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVI_SHEET_LAYOUT.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVI_SHEET_LAYOUT_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVI_SHEET_LAYOUT.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_SHEET_LAYOUT_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVI_SHEET_LAYOUT_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVI_SHEET_LAYOUT.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVI_SHEET_LAYOUT_TOTAL.

*.........table declarations:.................................*
TABLES: *ZTB_BM_DATCON                 .
TABLES: *ZTB_BM_DATGROUP               .
TABLES: *ZTB_BM_DATTYPE                .
TABLES: *ZTB_BM_DF_EC                  .
TABLES: *ZTB_BM_DF_STR                 .
TABLES: *ZTB_BM_DF_TYP                 .
TABLES: *ZTB_BM_IM_CAT                 .
TABLES: *ZTB_BM_IM_MARA                .
TABLES: *ZTB_BM_ROLE                   .
TABLES: *ZTB_BM_SCP_PAR                .
TABLES: *ZTB_BM_SV_TRANS               .
TABLES: *ZTB_BM_SV_USR                 .
TABLES: *ZTB_BM_TAB_DESC               .
TABLES: *ZTB_BM_USR_ROLE               .
TABLES: *ZTB_FIELD_DB                  .
TABLES: *ZTB_JBCF_JOB                  .
TABLES: *ZTB_JBCF_JSTEP                .
TABLES: *ZTB_MC_BUSAREA                .
TABLES: *ZTB_MC_BUSELE                 .
TABLES: *ZTB_MC_BUSFLD                 .
TABLES: *ZTB_MC_BUSKEYG                .
TABLES: *ZTB_MC_BUSMAP                 .
TABLES: *ZTB_MC_BUSMAPID               .
TABLES: *ZTB_MC_BUSTAB                 .
TABLES: ZTB_BM_ALV_LAYO                .
TABLES: ZTB_BM_CHA_LAYO                .
TABLES: ZTB_BM_CHA_SERI                .
TABLES: ZTB_BM_DATCON                  .
TABLES: ZTB_BM_DATGROUP                .
TABLES: ZTB_BM_DATTYPE                 .
TABLES: ZTB_BM_DF_EC                   .
TABLES: ZTB_BM_DF_FIELD                .
TABLES: ZTB_BM_DF_STR                  .
TABLES: ZTB_BM_DF_TYP                  .
TABLES: ZTB_BM_DF_TYPLS                .
TABLES: ZTB_BM_DF_TYP_EC               .
TABLES: ZTB_BM_IM_CAT                  .
TABLES: ZTB_BM_IM_MARA                 .
TABLES: ZTB_BM_PROG_ROLE               .
TABLES: ZTB_BM_ROLE                    .
TABLES: ZTB_BM_ROLE_FLD                .
TABLES: ZTB_BM_SCP_PAR                 .
TABLES: ZTB_BM_SL_SCRVL                .
TABLES: ZTB_BM_SL_STEP                 .
TABLES: ZTB_BM_SL_TRAN                 .
TABLES: ZTB_BM_SV_TRAND                .
TABLES: ZTB_BM_SV_TRANS                .
TABLES: ZTB_BM_SV_USR                  .
TABLES: ZTB_BM_TAB_DESC                .
TABLES: ZTB_BM_USR_ROLE                .
TABLES: ZTB_EXCEL_LAYOUT               .
TABLES: ZTB_EXCEL_SHEETS               .
TABLES: ZTB_FIELD_DB                   .
TABLES: ZTB_FIELD_DESC                 .
TABLES: ZTB_JBCF_JOB                   .
TABLES: ZTB_JBCF_JSTEP                 .
TABLES: ZTB_MAP_SELSCR                 .
TABLES: ZTB_MC_BUSAREA                 .
TABLES: ZTB_MC_BUSELE                  .
TABLES: ZTB_MC_BUSFLD                  .
TABLES: ZTB_MC_BUSKEYE                 .
TABLES: ZTB_MC_BUSKEYG                 .
TABLES: ZTB_MC_BUSKEYGM                .
TABLES: ZTB_MC_BUSMAP                  .
TABLES: ZTB_MC_BUSMAPID                .
TABLES: ZTB_MC_BUSTAB                  .
TABLES: ZTB_MC_BUSTABF                 .
TABLES: ZTB_PROG                       .
TABLES: ZTB_PROG_FLOW                  .
TABLES: ZTB_PROG_PRSF                  .
TABLES: ZTB_PROG_PRSV                  .
TABLES: ZTB_PROG_SCR                   .
TABLES: ZTB_PROG_STEP                  .
TABLES: ZTB_SHEET_LAYOUT               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
