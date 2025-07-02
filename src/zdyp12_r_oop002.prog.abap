*&---------------------------------------------------------------------*
*& Report ZDYP12_R_OOP002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdyp12_r_oop002.

CLASS lcl_cat DEFINITION DEFERRED.

INTERFACE lif_animal.
  METHODS:
    get_number_of_arms RETURNING VALUE(rv_arms) TYPE i,
    get_number_of_legs RETURNING VALUE(rv_legs) TYPE i.

  DATA : mv_legs TYPE i,
         mv_arms TYPE i.
ENDINTERFACE.

CLASS lcl_cat DEFINITION.
  PUBLIC SECTION.
    METHODS: constructor.
    INTERFACES lif_animal.
ENDCLASS.

CLASS lcl_cat IMPLEMENTATION.
  METHOD constructor.
    lif_animal~mv_legs = 4.
    lif_animal~mv_arms = 0.
  ENDMETHOD.
  METHOD lif_animal~get_number_of_arms.
    rv_arms = lif_animal~mv_arms.
  ENDMETHOD.
  METHOD lif_animal~get_number_of_legs.
    rv_legs = lif_animal~mv_legs.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.

  DATA(lo_cat) = NEW lcl_cat( ).

  WRITE : / 'Cats legs: ' , lo_cat->lif_animal~get_number_of_legs( ), 'Cats arms: ', lo_cat->lif_animal~get_number_of_arms( ).
