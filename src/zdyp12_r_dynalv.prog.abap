*&---------------------------------------------------------------------*
*& Report ZDYP12_R_DYNALV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdyp12_r_dynalv.

*Type pools declaration for ALV
TYPE-POOLS: slis.                    " ALV Global Types
*data declaration for dynamic internal table and alv
DATA: l_structure           TYPE REF TO data,
      l_table               TYPE REF TO data,
      struc_desc            TYPE REF TO cl_abap_structdescr,
      lt_layout             TYPE slis_layout_alv,
      ls_lvc_fieldcatalogue TYPE lvc_s_fcat,
      lt_lvc_fieldcatalogue TYPE lvc_t_fcat,
      ls_fieldcatalogue     TYPE slis_fieldcat_alv,
      lt_fieldcatalogue     TYPE slis_t_fieldcat_alv.
*field symbols declaration
FIELD-SYMBOLS :
  <it_table> TYPE STANDARD TABLE,
  <dyn_str>  TYPE any,
  <str_comp> TYPE abap_compdescr.
*declarations for grid title
DATA : t1(30),
       t2(10),
       t3(50).
*selection screen declaration for table input
PARAMETERS : p_table LIKE dd02l-tabname.
*initialization event
INITIALIZATION.
*start of selection event
START-OF-SELECTION.
*texts for grid title
  t1 = 'Dynamic ALV display for table'.
  t2 = p_table.
  CONCATENATE t1 t2 INTO t3 SEPARATED BY space.
* Dynamic creation of a structure
  CREATE DATA l_structure TYPE (p_table).
  ASSIGN l_structure->* TO <dyn_str>.
* Fields Structure
  struc_desc ?= cl_abap_typedescr=>describe_by_data( <dyn_str> ).
  LOOP AT struc_desc->components ASSIGNING <str_comp>.
*   Build Fieldcatalog
    ls_lvc_fieldcatalogue-fieldname = <str_comp>-name.
    ls_lvc_fieldcatalogue-ref_table = p_table.
    APPEND ls_lvc_fieldcatalogue TO lt_lvc_fieldcatalogue.
*   Build Fieldcatalog
    ls_fieldcatalogue-fieldname = <str_comp>-name.
    ls_fieldcatalogue-ref_tabname = p_table.
    APPEND ls_fieldcatalogue TO lt_fieldcatalogue.
  ENDLOOP.
* Create internal table dynamic
  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog = lt_lvc_fieldcatalogue
    IMPORTING
      ep_table        = l_table.
  ASSIGN l_table->* TO <it_table>.
* Read data from the table selected.
  SELECT * FROM (p_table)
    INTO CORRESPONDING FIELDS OF TABLE <it_table>.
* ALV Layout
  lt_layout-zebra = 'X'.
  lt_layout-colwidth_optimize = 'X'.
  lt_layout-window_titlebar = t3.
*ALV  output
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      is_layout     = lt_layout
      it_fieldcat   = lt_fieldcatalogue
    TABLES
      t_outtab      = <it_table>
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
