CLASS lhc_zr_yproduct DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_product,
             productid     TYPE zde_product_id,
             productname   TYPE zde_product_name,
             price         TYPE zyproduct-price,
             currency      TYPE zyproduct-currency,
             stock         TYPE zyproduct-stock,
             unitofmeasure TYPE zyproduct-unit_of_measure,
           END OF ty_product.

    TYPES: BEGIN OF ty_product_header,
             productid     TYPE string,
             productname   TYPE string,
             price         TYPE string,
             currency      TYPE string,
             stock         TYPE string,
             unitofmeasure TYPE string,
           END OF ty_product_header.

    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR Product
        RESULT result,
      fileUpload FOR MODIFY
        IMPORTING keys FOR ACTION Product~fileUpload,
      downloadFile FOR MODIFY
        IMPORTING keys FOR ACTION Product~downloadFile RESULT result.

    METHODS convert_unit importing i_unit type msehi
                         RETURNING VALUE(r_unit) type msehi.
    METHODS convert_price importing i_price type zyproduct-price
                                    i_currency type zyproduct-currency
                          RETURNING VALUE(r_price) type zyproduct-price.

ENDCLASS.

CLASS lhc_zr_yproduct IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD fileUpload.
    DATA lt_product TYPE STANDARD TABLE OF ty_product.
    DATA lt_product_c TYPE TABLE FOR CREATE zr_yproduct.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<ls_keys>) INDEX 1.
    CHECK sy-subrc = 0.
    DATA(lv_filecontent) = <ls_keys>-%param-fileContent.
    DATA(lo_read_access) = xco_cp_xlsx=>document->for_file_content( lv_filecontent )->read_access(  ).
    DATA(lo_worksheet) = lo_read_access->get_workbook( )->worksheet->at_position( 1 ).

    DATA(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
                                   )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
                                   )->to_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'F' )
                                   )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 2 )
                                   )->get_pattern( ).

    lo_worksheet->select( lo_selection_pattern )->row_stream(
                    )->operation->write_to( REF #( lt_product )
                    )->if_xco_xlsx_ra_operation~execute( ).

    "create new entity
    lt_product_c = CORRESPONDING #( lt_product ).

    loop at lt_product_c ASSIGNING FIELD-SYMBOL(<product>).
      <product>-UnitOfMeasure = convert_unit( <product>-UnitOfMeasure ).
      <product>-price = convert_price(
                          i_price    = <product>-price
                          i_currency = <product>-currency ).
    endloop.

    MODIFY ENTITIES OF zr_yproduct IN LOCAL MODE
    ENTITY Product
    CREATE AUTO FILL CID FIELDS ( ProductId
                                  ProductName
                                  Price
                                  Currency
                                  Stock
                                  UnitOfMeasure ) WITH lt_product_c
    MAPPED DATA(lt_mapped_create)
    REPORTED DATA(lt_mapped_reported)
    FAILED DATA(lt_failed_create).

  ENDMETHOD.

  METHOD downloadFile.
    DATA lt_product TYPE STANDARD TABLE OF ty_product_header WITH DEFAULT KEY.
*    DATA lo_selection_pattern TYPE REF TO if_xco_xlsx_slc_pattern.
    DATA(lo_write_access) = xco_cp_xlsx=>document->empty( )->write_access( ).
    DATA(lo_worksheet) = lo_write_access->get_workbook(
        )->worksheet->at_position( 1 ).

    DATA(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
                               )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
                               )->to_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'F' )
                               )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 1 )
                               )->get_pattern( ).

    lt_product = VALUE #( (  ProductId = 'Product ID'
                             productname = 'Product Name'
                             price = 'Price'
                             currency = 'Currency'
                             stock = 'Stock'
                             unitofmeasure = 'Unit of Measure') ).

    lo_worksheet->select( lo_selection_pattern
        )->row_stream(
        )->operation->write_from( REF #( lt_product )
        )->execute( ).

    DATA(lv_file_content) = lo_write_access->get_file_content( ).
    DATA(lv_base64_encoding) = xco_cp=>xstring( lv_file_content
        )->as_string( xco_cp_binary=>text_encoding->base64
        )->value.

* base64でエンコードすると、レスポンスのfileContentが空になる
* エンコードしないとatobでエラーになる
    result = VALUE #( FOR key IN keys (
                        %cid = key-%cid
                        %param = VALUE #(  fileContent = lv_file_content
                                           fileName = 'ProductTemplate'
                                           fileExtension = 'xlsx'
                                           mimeType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' )
                       ) ).

  ENDMETHOD.

  METHOD convert_unit.
    select single UnitOfMeasure from I_UnitOfMeasure
      where UnitOfMeasure_E = @i_unit
      into @r_unit.

  ENDMETHOD.

  METHOD convert_price.
* https://userapps.support.sap.com/sap/support/knowledge/en/2973787
    select single * from i_currency
    where currency = @i_currency
    into @data(ls_curx).

    check sy-subrc is initial.
    r_price = i_price * ( 10 ** ls_curx-decimals / 100 ).
  ENDMETHOD.

ENDCLASS.
