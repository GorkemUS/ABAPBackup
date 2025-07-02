*&---------------------------------------------------------------------*
*& Include          ZDHP12_R_HW_TOP
*&---------------------------------------------------------------------*

TABLES: vbrk, vbrp, kna1, sscrfields.

DATA : gs_data TYPE zdyp12_s_odev2,
       gt_data TYPE TABLE OF zdyp12_s_odev2.

DATA: gt_color  TYPE TABLE OF lvc_s_scol .
DATA: gs_color  TYPE lvc_s_scol.

DATA: alv_fieldcat   TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      alv_event_exit TYPE TABLE OF slis_event_exit WITH HEADER LINE,
      alv_tabname    TYPE slis_tabname,
      alv_structure  TYPE tabname,
      alv_repid      LIKE sy-repid,
      alv_variant    LIKE disvariant,
      alv_layout     TYPE slis_layout_alv.
