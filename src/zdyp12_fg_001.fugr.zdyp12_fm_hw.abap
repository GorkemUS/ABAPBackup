FUNCTION zdyp12_fm_hw.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_DATA) TYPE  ZDYP12_S_HW
*"  EXPORTING
*"     REFERENCE(ET_TABLE) TYPE  ZDYP12_TT_HW
*"----------------------------------------------------------------------

DATA: lt_data_table TYPE TABLE OF zdyp12_t_hw,
      ls_data_table TYPE zdyp12_t_hw.
*     lt_table      TYPE zdyp12_t_hw. local table'ı aynı şekil type table yaparak structure'a da bağlıyabiliriz.
*     lt_table2     TYPE TABLE OF zdyp12_s_h


MOVE-CORRESPONDING is_data TO ls_data_table.
APPEND ls_data_table TO lt_data_table.
APPEND is_data TO et_table.

DO 10 TIMES.
  INSERT zdyp12_t_hw FROM ls_data_table.
  IF sy-subrc = 0.
    COMMIT WORK.
    ls_data_table-personel_no += 1.
  ENDIF.
ENDDO.

*SELECT * FROM zdyp12_t_hw INTO TABLE lt_data_table.

LOOP AT lt_data_table INTO ls_data_table.
  ls_data_table-dogum_yeri = 'Erzurum'.

  UPDATE zdyp12_t_hw SET dogum_yeri = ls_data_table-dogum_yeri.

  IF sy-subrc = 0.
    COMMIT WORK.
  ENDIF.
ENDLOOP.

ENDFUNCTION.
