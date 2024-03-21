*&---------------------------------------------------------------------*
*& Include ZIN_LOGON_RFCTOP          Report ZPG_LOGON_RFC
*&
*&---------------------------------------------------------------------*

INCLUDE ZIN_COMMONTOP.

**********************************************************************
* PARAMETERS AND SELECT-OPTION
**********************************************************************
PARAMETERS:
  P_RFCNAN               TYPE XMARK RADIOBUTTON GROUP RFC DEFAULT 'X',
  P_RFCHTI               TYPE XMARK RADIOBUTTON GROUP RFC,
  P_RFCHCM               TYPE XMARK RADIOBUTTON GROUP RFC,
  P_RFCHUA               TYPE XMARK RADIOBUTTON GROUP RFC.
