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

ENDCLASS.
