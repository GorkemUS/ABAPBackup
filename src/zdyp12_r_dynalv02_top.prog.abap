*&---------------------------------------------------------------------*
*& Include          ZDYP12_R_DYNALV02_TOP
*&---------------------------------------------------------------------*

************************************************************************
*TABLES                                                                *
************************************************************************


************************************************************************
* TYPE POOLS                                                           *
************************************************************************
TYPE-POOLS: slis.

************************************************************************
*DATA TYPES                                                            *
************************************************************************
TYPES:
  BEGIN OF gty_table,
    tabname   TYPE dd03l-tabname,
    position  TYPE dd03l-position,
    keyflag   TYPE dd03l-keyflag,
    rollname  TYPE dd03l-rollname,
    datatype  TYPE dd03l-datatype,
    leng      TYPE dd03l-leng,
    decimals  TYPE dd03l-decimals,
    fieldtext TYPE c LENGTH 50,
  END OF gty_table.
************************************************************************
*CONSTANTS                                                             *
************************************************************************


************************************************************************
*FIELD SYMBOLS                                                         *
************************************************************************
FIELD-SYMBOLS:
  <it_table> TYPE STANDARD TABLE.


************************************************************************
*DATA DECLARATION                                                      *
************************************************************************
DATA : t1(30),
       t2(10),
       t3(50).
DATA: gt_data TYPE TABLE OF zdyp12_s_dynalv.
DATA: gs_data TYPE zdyp12_s_dynalv.

DATA: lt_layout       TYPE slis_layout_alv,
      lt_fieldcatalog TYPE slis_t_fieldcat_alv.

DATA: lv_count TYPE i.

DATA: lt_keys            LIKE sval OCCURS 0 WITH HEADER LINE,
      lt_selected_fields LIKE sval OCCURS 0 WITH HEADER LINE,
      lv_title           TYPE string,
      lv_ret             TYPE string.

************************************************************************
*STRUCTURES & INTERNAL TABLES                                          *
************************************************************************

************************************************************************
*CLS                                                                   *
************************************************************************
CLASS lcl_main DEFINITION DEFERRED.
DATA: lo_main TYPE REF TO lcl_main.

************************************************************************
*SELECTION SCREENS                                                     *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001 .
  PARAMETERS : p_table LIKE dd02l-tabname OBLIGATORY.
SELECTION-SCREEN END OF BLOCK a1.

************************************************************************
*RANGES                                                                *
************************************************************************
