CLASS zcl_update_product DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_update_product IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
*    delete from zyproduct.
*    commit work.
data result type zyproduct-price.

    result = 100 * ( 10 ** 0 / 100 ).

    out->write( result ).
  ENDMETHOD.
ENDCLASS.
