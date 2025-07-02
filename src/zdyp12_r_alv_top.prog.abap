
*&---------------------------------------------------------------------*
*& Include          ZDYP12_R_ALV_TOP
*&---------------------------------------------------------------------*
************************************************************************
*TABLES                                                                *
************************************************************************
TABLES: vbak, kna1, tvakt.

************************************************************************
* TYPE POOLS                                                           *
************************************************************************
TYPES: BEGIN OF ty_vbap,
         matnr  TYPE vbap-matnr,
         maktx  TYPE makt-maktx,
         kwmeng TYPE vbap-kwmeng,
         meins  TYPE vbap-meins,
       END OF ty_vbap.
************************************************************************
************************************************************************
*DATA TYPES                                                            *
************************************************************************

DATA: BEGIN OF gs_vbak.
        INCLUDE STRUCTURE zdyp12_s_alv.
DATA: color(4).
DATA: clrt TYPE lvc_t_scol.
DATA: END OF gs_vbak.

DATA: BEGIN OF gs_vbak_d.
        INCLUDE STRUCTURE zdyp12_s_alv.
DATA: color(4).
DATA: clrt   TYPE lvc_t_scol,
      matnr  TYPE vbap-matnr,
      maktx  TYPE makt-maktx,
      kwmeng TYPE vbap-kwmeng,
      meins  TYPE vbap-meins.
DATA: END OF gs_vbak_d.
DATA: gt_vbak_d   LIKE TABLE OF gs_vbak_d.

DATA: lv_flag TYPE i.
DATA: gt_vbak LIKE TABLE OF gs_vbak.
DATA: gt_vbap TYPE TABLE OF ty_vbap,
      gs_vbap LIKE LINE OF gt_vbap.

DATA: alv_fieldcat   TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      alv_event_exit TYPE TABLE OF slis_event_exit WITH HEADER LINE,
      alv_tabname    TYPE slis_tabname,
      alv_structure  TYPE tabname,
      alv_repid      LIKE sy-repid,
      alv_variant    LIKE disvariant,
      alv_layout     TYPE slis_layout_alv.

DATA: gt_color  TYPE TABLE OF lvc_s_scol .
DATA: gs_color  TYPE lvc_s_scol.

DATA: lv_vbeln    TYPE vbeln_va,
      lv_vbeln_vl TYPE vbeln_vl,
      lv_landx    TYPE t005t-landx.

DATA: lv_count TYPE i.

DATA: gs_teslimat TYPE zdyp12_teslimat.

DATA : lt_exclude TYPE slis_t_extab.

************************************************************************
*CONSTANTS                                                             *
************************************************************************


************************************************************************
*FIELD SYMBOLS                                                         *
************************************************************************


************************************************************************
*DATA DECLARATION                                                      *
************************************************************************


************************************************************************
*STRUCTURES & INTERNAL TABLES                                          *
************************************************************************

************************************************************************
*CLS                                                                   *
************************************************************************


************************************************************************
*SELECTION SCREENS                                                     *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001 .

  SELECT-OPTIONS: s_vbeln FOR vbak-vbeln .
  SELECT-OPTIONS: s_erdat FOR vbak-erdat .
  SELECT-OPTIONS: s_audat FOR vbak-audat .
  SELECT-OPTIONS: s_kunnr FOR vbak-kunnr .

SELECTION-SCREEN END OF BLOCK a1 .

SELECTION-SCREEN BEGIN OF BLOCK a2 WITH FRAME TITLE TEXT-002 .
  PARAMETERS : p_vbak TYPE xfeld RADIOBUTTON GROUP 1 DEFAULT 'X' USER-COMMAND r_flag,
               p_vbap TYPE xfeld RADIOBUTTON GROUP 1.

SELECTION-SCREEN END OF BLOCK a2.



************************************************************************
*RANGES                                                                *
************************************************************************
