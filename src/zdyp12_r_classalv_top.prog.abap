*&---------------------------------------------------------------------*
*& Include          ZDYP12_R_CLASSALV_TOP
*&---------------------------------------------------------------------*

TABLES: vbrk, vbrp, sscrfields,kna1.
TYPE-POOLS: icon. " Iconları görmek için kullanılır.

DATA: gs_data TYPE ZDYP12_S_ODEV2,
      gt_data TYPE TABLE OF ZDYP12_S_ODEV2.

DATA: gt_color  TYPE TABLE OF lvc_s_scol,
      gs_color  TYPE lvc_s_scol,
      gv_flag   TYPE char1,
      gv_flag2   TYPE char1.
*      gv_check  TYPE char1.

CLASS lcl_event_receiver DEFINITION DEFERRED.
DATA : g_main TYPE REF TO lcl_event_receiver.
DATA : grid TYPE REF TO cl_gui_alv_grid.


  SELECTION-SCREEN FUNCTION KEY 1.
  SELECTION-SCREEN FUNCTION KEY 2.

SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME.
  SELECT-OPTIONS: s_matnr FOR vbrp-matnr NO INTERVALS NO-EXTENSION.
  SELECT-OPTIONS: s_vbeln FOR vbrk-vbeln.
  SELECT-OPTIONS: s_kunnr FOR kna1-kunnr.
  SELECT-OPTIONS: s_fkdat FOR vbrk-fkdat.

SELECTION-SCREEN END OF BLOCK a1.

SELECTION-SCREEN BEGIN OF BLOCK a2 WITH FRAME.
  PARAMETERS p_check1 AS CHECKBOX USER-COMMAND c1 MODIF ID chk.
  PARAMETERS p_check2 AS CHECKBOX USER-COMMAND c2 MODIF ID chk.

  PARAMETERS p_check3 AS CHECKBOX MODIF ID ck1.
  PARAMETERS p_check4 AS CHECKBOX MODIF ID ck1.

SELECTION-SCREEN END OF BLOCK a2.
