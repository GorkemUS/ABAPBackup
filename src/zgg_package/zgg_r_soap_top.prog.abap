*&---------------------------------------------------------------------*
*& Include          ZGG_R_SOAP_TOP
*&---------------------------------------------------------------------*

************************************************************************
*TABLES                                                                *
************************************************************************


************************************************************************
* TYPE POOLS                                                           *
************************************************************************


************************************************************************
*DATA TYPES                                                            *
************************************************************************

************************************************************************
*CONSTANTS                                                             *
************************************************************************


************************************************************************
*FIELD SYMBOLS                                                         *
************************************************************************


************************************************************************
*DATA DECLARATION                                                      *
************************************************************************
DATA: lr_proxy TYPE REF TO zggco_yzft_fm,
      input	   TYPE zggyzft_fm,
      output   TYPE zggyzft_fmresponse.

DATA: lv_encoded_xml TYPE string,
      lr_conv        TYPE REF TO cl_abap_conv_in_ce,
      ls_countries   TYPE zgg_s_soap2,
      ls_leagues     TYPE zgg_s_league1,
      lt_leagues     TYPE TABLE OF zgg_s_league,
      gs_teams       TYPE zgg_s_mteams,
      gt_teams       TYPE TABLE OF zgg_s_teams,
      ls_teams       TYPE zgg_s_teams,
      gv_row_id      TYPE i,
      gv_rowteam_id  TYPE i.

DATA: gs_squad        TYPE zgg_s_response,
      gt_squads       TYPE TABLE OF zgg_s_squad,
      gs_playerphoto  TYPE zgg_s_squad,
      gv_rowplayer_id TYPE i,
      gt_text         TYPE TABLE OF char200.

DATA: gv_leagueidchar TYPE char10,
      gv_teamidchar   TYPE char10.

DATA: gv_uname TYPE sy-uname,
      gv_datum TYPE sy-datum,
      gv_uzeit TYPE sy-uzeit.

DATA: gs_header TYPE thead,
      lt_tline  TYPE TABLE OF tline,
      ls_tline  TYPE  tline.

DATA: gt_texttable TYPE TABLE OF zgg_t_player,
      gs_texttable TYPE zgg_t_player,
      gt_player    TYPE TABLE OF zgg_t_player.

DATA: gs_block TYPE zgg_block_player,
      gs_log   TYPE zgg_log_ch_play.

DATA: gs_item TYPE zggrsparams.

DATA: gv_flag TYPE char1.

DATA: gs_leaguelogo TYPE zgg_s_league.

DATA : lt_vrm TYPE vrm_values.

DATA: gv_player TYPE int4.
DATA: gv_ulke  TYPE char4.
DATA: gv_lig  TYPE int4.

DATA: go_splitter TYPE REF TO cl_gui_splitter_container,
      container1  TYPE REF TO cl_gui_container,
      container2  TYPE REF TO cl_gui_container,
      container3  TYPE REF TO cl_gui_container,
      container4  TYPE REF TO cl_gui_container,
      container5  TYPE REF TO cl_gui_container,
      container6  TYPE REF TO cl_gui_container,
      custom_cont TYPE REF TO cl_gui_custom_container,
      text_cont   TYPE REF TO cl_gui_custom_container.


************************************************************************
*STRUCTURES & INTERNAL TABLES                                          *
************************************************************************

************************************************************************
*CLS                                                                   *
************************************************************************
CLASS lcl_main DEFINITION DEFERRED.
DATA: go_main TYPE REF TO lcl_main.
DATA : grid TYPE REF TO cl_gui_alv_grid.
DATA : grid2 TYPE REF TO cl_gui_alv_grid.
DATA : grid3 TYPE REF TO cl_gui_alv_grid.
DATA: go_picture TYPE REF TO cl_gui_picture.
DATA: go_picture1 TYPE REF TO cl_gui_picture.
DATA: text_edit TYPE REF TO cl_gui_textedit.
DATA: go_cl TYPE REF TO zgg_cl_wsbadi_imp.

************************************************************************
*SELECTION SCREENS                                                     *
************************************************************************

SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_ulke(10) AS LISTBOX VISIBLE LENGTH 30 OBLIGATORY.
SELECTION-SCREEN END OF BLOCK a1.


************************************************************************
*RANGES                                                                *
************************************************************************
