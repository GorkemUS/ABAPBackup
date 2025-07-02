*&---------------------------------------------------------------------*
*& Report ZDYP12_R_OOP001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdyp12_r_oop001.

CLASS lcl_main DEFINITION DEFERRED.
DATA: go_main TYPE REF TO lcl_main.
DATA: go_main2 TYPE REF TO lcl_main.
DATA: go_main3 TYPE REF TO lcl_main.
DATA: go_main4 TYPE REF TO lcl_main.

*PARAMETERS: p_num1 TYPE int2,
*            p_num2 TYPE int2.

CLASS lcl_main DEFINITION.
  PUBLIC SECTION.
    METHODS:
      constructor,
*      constructor IMPORTING iv_num1 TYPE int2
*                            iv_num2 TYPE int2,
      do_process IMPORTING iv_pers_id   TYPE char10
                           iv_pers_name TYPE char20
                           iv_pers_age  TYPE numc2,
      sum_numbers.

    DATA: mv_num1      TYPE i,
          mv_num2      TYPE i,
          mv_sum       TYPE i,
          mv_pers_id   TYPE char10,
          mv_pers_name TYPE char20.
*          mv_pers_age  TYPE numc2.

    CLASS-DATA: mv_pers_age TYPE numc2,
                mv_ttl_num  TYPE i,
                mv_ttl_num2  TYPE i.

    CLASS-METHODS: class_constructor,
                   inc_num.
ENDCLASS.

CLASS lcl_main IMPLEMENTATION.
  METHOD constructor.
*    mv_num1 = p_num1.
*    mv_num2 = p_num2.

  ENDMETHOD.
  METHOD class_constructor.
    mv_ttl_num = mv_ttl_num + 1.

  ENDMETHOD.
  METHOD inc_num.
    mv_ttl_num2 = mv_ttl_num2 + 1.

    ENDMETHOD.
  METHOD do_process.
    mv_pers_id = iv_pers_id.
    mv_pers_name = iv_pers_name.
    mv_pers_age = iv_pers_age.
  ENDMETHOD.
  METHOD sum_numbers.
*    mv_sum = mv_num1 + mv_num2.

  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.

  CREATE OBJECT: go_main , go_main2, go_main3 , go_main4.

  go_main2->do_process(
    EXPORTING
      iv_pers_id   = '1000000001'
      iv_pers_name = 'Görkem'
      iv_pers_age  = '27'
  ).

  go_main3->do_process(
    EXPORTING
      iv_pers_id   = '1000000002'
      iv_pers_name = 'Burak'
      iv_pers_age  = '25'
  ).

  go_main4->do_process(
    EXPORTING
      iv_pers_id   = '1000000003'
      iv_pers_name = 'Rami'
      iv_pers_age  = '30'
  ).
*  go_main->sum_numbers( ).

*  WRITE : / 'Toplam : ', go_main->mv_sum.

DATA(lo_main) = NEW lcl_main( ).

  WRITE: / go_main2->mv_pers_id, go_main2->mv_pers_name, go_main2->mv_pers_age.
  WRITE: / go_main3->mv_pers_id, go_main3->mv_pers_name, go_main3->mv_pers_age.
  WRITE: / go_main4->mv_pers_id, go_main4->mv_pers_name, go_main4->mv_pers_age.
  WRITE: / 'Total Number : ', lo_main->mv_ttl_num.


go_main->inc_num( ).
go_main->inc_num( ).
go_main->inc_num( ).
go_main->inc_num( ).
go_main->inc_num( ).
go_main->inc_num( ).
go_main->inc_num( ).
go_main->inc_num( ).
go_main->inc_num( ).

WRITE : / 'Total Num for inc_num method: ' , go_main->mv_ttl_num2.
