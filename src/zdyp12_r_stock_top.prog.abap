*&---------------------------------------------------------------------*
*& Include          ZDYP12_R_STOCK_TOP
*&---------------------------------------------------------------------*

TABLES: mara, mchb,t001l,mard,sscrfields.

DATA: gs_data TYPE zdyp12_s_stock,
      gt_data TYPE TABLE OF zdyp12_s_stock.


CLASS lcl_event_receiver DEFINITION DEFERRED.
DATA : g_main TYPE REF TO lcl_event_receiver.
DATA : grid TYPE REF TO cl_gui_alv_grid.
DATA : go_popup  TYPE REF TO cl_reca_gui_f4_popup.

DATA: lt_fieldcatalog TYPE TABLE OF lvc_s_fcat.
DATA: ls_fieldcatalog TYPE lvc_s_fcat .
DATA: ls_layout   TYPE lvc_s_layo .
FIELD-SYMBOLS: <gfs_fieldcat> TYPE lvc_s_fcat.

DATA: lt_selected_row TYPE lvc_t_row,
      ls_selected_row TYPE lvc_s_row.

DATA: gt_smartform TYPE ZDYP12_TT_STOCK,
      gs_smartform TYPE ZDYP12_S_STOCK.

DATA:container_1 TYPE REF TO cl_gui_custom_container.

DATA: mail TYPE REF TO cl_bcs_message.

DATA: gs_toolbar TYPE stb_button.

DATA: gt_row_no TYPE lvc_t_roid,
      gs_row_no TYPE lvc_s_roid.

DATA: gt_color TYPE TABLE OF lvc_s_scol,
      gs_color TYPE lvc_s_scol.

SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME.

  PARAMETERS rbutton1 TYPE xfeld RADIOBUTTON GROUP r1 DEFAULT 'X' USER-COMMAND r_button .
  PARAMETERS rbutton2 TYPE xfeld RADIOBUTTON GROUP r1.
  PARAMETERS rbutton3 TYPE xfeld RADIOBUTTON GROUP r1 .

SELECTION-SCREEN END OF BLOCK a1.

SELECTION-SCREEN BEGIN OF BLOCK a2 WITH FRAME.

  SELECT-OPTIONS: s_matnr FOR mchb-matnr.
  SELECT-OPTIONS: s_werks FOR mchb-werks.
  SELECT-OPTIONS: s_charg FOR mchb-charg MODIF ID crg.
  SELECT-OPTIONS: s_lgort FOR mard-lgort MODIF ID lrt.

SELECTION-SCREEN END OF BLOCK a2.

SELECTION-SCREEN BEGIN OF BLOCK a3 WITH FRAME.

  PARAMETERS p_check1 AS CHECKBOX USER-COMMAND c1 MODIF ID chk.

SELECTION-SCREEN END OF BLOCK a3.
