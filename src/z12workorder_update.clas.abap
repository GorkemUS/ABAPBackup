class Z12WORKORDER_UPDATE definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_WORKORDER_UPDATE .
protected section.
private section.
ENDCLASS.



CLASS Z12WORKORDER_UPDATE IMPLEMENTATION.


  METHOD if_ex_workorder_update~before_update.
    DATA : ls_header     TYPE cobai_s_header,
           ls_header_old TYPE cobai_s_header_old,
           lv_mess TYPE char200.

    READ TABLE it_header INTO ls_header INDEX 1.
    READ TABLE it_header_old INTO ls_header_old INDEX 1.
    IF ls_header IS NOT INITIAL AND ls_header_old IS NOT INITIAL.
      IF ls_header-gamng <> ls_header_old-gamng.
        MESSAGE ID 'ZDYP12_BADI' TYPE 'I' NUMBER 000 WITH ls_header_old-gamng ls_header-gamng.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
