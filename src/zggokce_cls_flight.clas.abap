class ZGGOKCE_CLS_FLIGHT definition
  public
  final
  create public .

public section.

  interfaces IF_SADL_EXIT .
  interfaces IF_SADL_EXIT_CALC_ELEMENT_READ .
protected section.
private section.
ENDCLASS.



CLASS ZGGOKCE_CLS_FLIGHT IMPLEMENTATION.


  method IF_SADL_EXIT_CALC_ELEMENT_READ~CALCULATE.
   DATA: lt_data TYPE TABLE OF ZGGOKCE_I_003.

   lt_data = CORRESPONDING #( it_original_data ).

   LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
   <fs_data>-Note = |Price discounted on { <fs_data>-Fldate DATE = USER }. |.

   ENDLOOP.

  endmethod.
  METHOD IF_SADL_EXIT_CALC_ELEMENT_READ~GET_CALCULATION_INFO.

  ENDMETHOD.

ENDCLASS.
