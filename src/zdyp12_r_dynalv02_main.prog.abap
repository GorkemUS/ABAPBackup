*&---------------------------------------------------------------------*
*& Include          ZDYP12_R_DYNALV02_MAIN
*&---------------------------------------------------------------------*


*----------------------------------------------------------------------*
*INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  lo_main = NEW #( ) .
*----------------------------------------------------------------------*
*AT SELECTION-SCREEN.
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.

  t1 = 'Dynamic ALV display for table'.
  t2 = p_table.
  CONCATENATE t1 t2 INTO t3 SEPARATED BY space.

*----------------------------------------------------------------------*
*AT SELECTION-SCREEN OUTPUT.
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

*----------------------------------------------------------------------*
*START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

*  DATA(lo_main) = NEW lcl_main( ).
  SELECT SINGLE COUNT( * ) FROM dd02l WHERE tabname = p_table
                                    AND   as4local = 'A'.
  IF sy-subrc <> 0.
    MESSAGE 'Lütfen Aktif bir tablo seçiniz' TYPE 'E' DISPLAY LIKE 'S'.
    RETURN.
  ENDIF.

  lo_main->get_data( ).

  lo_main->display_alv( ).

*----------------------------------------------------------------------*
*END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.
