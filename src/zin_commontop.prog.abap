*&---------------------------------------------------------------------*
*& Include ZIN_COMMONTOP
*&
*&---------------------------------------------------------------------*

*--------------------------------------------------------------------*
* CONSTANTS
*--------------------------------------------------------------------*
CONSTANTS:
  GC_XMARK            TYPE XMARK VALUE 'X',
* Mode for create
  GC_MODE_CREATE      TYPE CHAR2 VALUE '01',
* Mode for edit
  GC_MODE_EDIT        TYPE CHAR2 VALUE '02',
* Mode for display
  GC_MODE_DISPLAY     TYPE CHAR2 VALUE '03',
* Abort
  GC_MTYPE_A          TYPE C VALUE 'A',
* Error
  GC_MTYPE_E          TYPE C VALUE 'E',
* Successful
  GC_MTYPE_S          TYPE C VALUE 'S',
* Warning
  GC_MTYPE_W          TYPE C VALUE 'W',
* Information
  GC_MTYPE_I          TYPE C VALUE 'I',
* Pause: Need approve
  GC_MTYPE_P          TYPE C VALUE 'P',

* Answer 'Cancel' of confirm pop up
  GC_ANSWER_ABORT     TYPE C VALUE 'A',
* Answer yes
  GC_ANSWER_YES       TYPE C VALUE '1',
* Answer no
  GC_ANSWER_NO        TYPE C VALUE '2',

* Function code F8 on selection screen
  GC_FC_SEL_F8        TYPE SYUCOMM  VALUE 'ONLI',
* Function code OPEN
  GC_FC_OPEN          TYPE SYUCOMM  VALUE 'OPEN',
* Function code SAVE
  GC_FC_SAVE          TYPE SYUCOMM  VALUE 'SAVE',
* Function code OK
  GC_FC_OK            TYPE SYUCOMM  VALUE 'OK',
* Function code EXIT
  GC_FC_EXIT          TYPE SYUCOMM  VALUE 'EXIT',
* Function code BACK
  GC_FC_BACK          TYPE SYUCOMM  VALUE 'BACK',
* Function code CANCEL
  GC_FC_CANCEL        TYPE SYUCOMM  VALUE 'CANCEL',
* Function code CHANGE
  GC_FC_CHANGE        TYPE SYUCOMM  VALUE 'CHANGE',
* Function code CREATE
  GC_FC_CREATE        TYPE SYUCOMM  VALUE 'CREATE',
* Function code PRINT
  GC_FC_PRINT1         TYPE SYUCOMM  VALUE 'PRINT1',
  GC_FC_PRINT2         TYPE SYUCOMM  VALUE 'PRINT2',
  GC_FC_PRINT_GN       TYPE SYUCOMM  VALUE 'PRINT_GN',
* Function code SEL_ALL
  GC_FC_SEL_ALL       TYPE SYUCOMM  VALUE 'SEL_ALL',
  GC_FC_SEL_1000      TYPE SYUCOMM  VALUE 'SEL_1000',
* Function code SEL_NONE
  GC_FC_SEL_NONE      TYPE SYUCOMM  VALUE 'SEL_NONE',
* Function code ACCEPT
  GC_FC_ACCEPT        TYPE SYUCOMM  VALUE 'ACCEPT',
  GC_FC_ACCEPT_TC     TYPE SYUCOMM  VALUE 'ACCEPT_TC',
* Function code REJECT
  GC_FC_REJECT        TYPE SYUCOMM  VALUE 'REJECT',
  GC_FC_REJECT_TC     TYPE SYUCOMM  VALUE 'REJECT_TC',
* Function code APPROVE
  GC_FC_APPROVE       TYPE SYUCOMM  VALUE 'APPROVE',

  GC_TYPEKIND_TABL    TYPE DDTYPEKIND VALUE 'TABL',
  GC_TYPEKIND_TTYP    TYPE DDTYPEKIND VALUE 'TTYP',

  GC_COMPTYPE_ELEM    TYPE COMPTYPE VALUE 'E',
  GC_COMPTYPE_STRU    TYPE COMPTYPE VALUE 'S',
  GC_COMPTYPE_TTYP    TYPE COMPTYPE VALUE 'L',


  GC_ALV_LINELENG_H   TYPE I VALUE 77,
  GC_ALV_LINELENG_S   TYPE I VALUE 124,
  GC_ALV_LINELENG_A   TYPE I VALUE 127,
  GC_ALV_HEIGH_H      TYPE I VALUE 8,
  GC_ALV_HEIGH_S      TYPE I VALUE 3,
  GC_ALV_HEIGH_A      TYPE I VALUE 4,
  GC_ALV_TYP_HEAD     TYPE ZDD_ALV_TYP VALUE 'H',
  GC_ALV_TYP_SEL      TYPE ZDD_ALV_TYP VALUE 'S',
  GC_ALV_TYP_ACTION   TYPE ZDD_ALV_TYP VALUE 'A',
  GC_ALV_TYP_LOGO     TYPE ZDD_ALV_TYP VALUE 'L',

* Default country VN
  GC_COUNTRY_VN       TYPE LAND1 VALUE 'VN',
  GC_LANGU_VN         TYPE LANGU VALUE '쁩',

* KH doi tuong: Quan nhan
  GC_REGIO_TW         TYPE REGIO VALUE '00',
* CQBH TW
  GC_BUKRS_TW         TYPE BUKRS VALUE '0010',
* CQBH trung tam da tuyen mien Bac
  GC_BUKRS_DTMB       TYPE BUKRS VALUE '00MB',
* CQBH trung tam da tuyen mien Nam
  GC_BUKRS_DTMN       TYPE BUKRS VALUE '00MN',
* CQBH KXD
  GC_BUKRS_TM         TYPE BUKRS VALUE '00TM',
* CQBH TW
  GC_BUKLVTW          TYPE BUKRS VALUE '1',
* CQBH Tinh
  GC_BUKLVRG          TYPE BUKRS VALUE '2',

* Default currenty VND
  GC_CURRENCY_VND     TYPE LAND1      VALUE 'VND',

* Comma separator
  GC_COMMA_SEPARATOR  TYPE CHAR03     VALUE ', ',
* RFC connect to TW
  GC_RFCDEST_TW       TYPE RFCDEST    VALUE 'BHXHDE2_280',
* Parameter list box: All
  GC_PARLIST_ALL      TYPE C          VALUE '*',
  GC_STREET_BLK       TYPE AD_STREET  VALUE '.'.

* Loai doi tuong
CONSTANTS:
  GC_BUTYPE_ORG       TYPE BU_TYPE    VALUE '2',
  GC_BUTYPE_PER       TYPE BU_TYPE    VALUE '1'.
