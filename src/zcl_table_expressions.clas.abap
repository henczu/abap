"! <p class="shorttext synchronized" lang="en">ABAP Table Expressions Examples</p>
CLASS ZCL_TABLE_EXPRESSIONS DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES IF_OO_ADT_CLASSRUN.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TABLE_EXPRESSIONS IMPLEMENTATION.


  METHOD IF_OO_ADT_CLASSRUN~MAIN.
    DATA FLIGHTS TYPE STANDARD TABLE OF /DMO/FLIGHT
          WITH NON-UNIQUE SORTED KEY PLTYPE COMPONENTS PLANE_TYPE_ID.
    SELECT * FROM /DMO/FLIGHT INTO TABLE @FLIGHTS.

    TRY.
****Old
        READ TABLE FLIGHTS INDEX 1 INTO DATA(WA).

****New
        DATA(WA1) = FLIGHTS[ 1 ].

****Old
        READ TABLE FLIGHTS INDEX 1
             USING KEY PLTYPE INTO DATA(WA3).

****New
        DATA(WA4) = FLIGHTS[ KEY PLTYPE INDEX 1 ].

****Old
        READ TABLE FLIGHTS WITH KEY
            CARRIER_ID = 'AA' CONNECTION_ID = '0322' INTO DATA(WA5).

****New
        DATA(WA6) = FLIGHTS[ CARRIER_ID = 'AA' CONNECTION_ID = '0322' ].

****Old
        READ TABLE FLIGHTS WITH TABLE KEY PLTYPE
             COMPONENTS PLANE_TYPE_ID = '747-400' INTO DATA(WA7).

****New
        DATA(WA8) = FLIGHTS[ KEY PLTYPE PLANE_TYPE_ID = '747-400' ].

****Old
        READ TABLE FLIGHTS INDEX 1 ASSIGNING FIELD-SYMBOL(<LINE1>).
        <LINE1>-PLANE_TYPE_ID = 'A310-300'.

****New
        FLIGHTS[ 1 ]-PLANE_TYPE_ID = 'A319'.

****Old
        READ TABLE FLIGHTS INDEX 1 INTO DATA(LINE2).
        IF SY-SUBRC <> 0.
          LINE2 = WA3.
        ENDIF.
        ZCL_SIMPLE_EXAMPLE=>METHOD2( LINE2 ).
      CATCH CX_SY_ITAB_LINE_NOT_FOUND.
    ENDTRY.

****New
    ZCL_SIMPLE_EXAMPLE=>METHOD2( VALUE #( FLIGHTS[ 1 ] DEFAULT WA3 ) ).

****Old
    READ TABLE FLIGHTS INDEX 1 REFERENCE INTO DATA(LINEREF1).
    ZCL_SIMPLE_EXAMPLE=>METHOD3( LINEREF1 ).

****New
    ZCL_SIMPLE_EXAMPLE=>METHOD3( REF #( FLIGHTS[ 1 ] ) ).

****Setup for nested internal table
    DATA NESTED TYPE ZCL_SIMPLE_EXAMPLE=>EXAMPLE_TABLE_TYPE.
    SELECT * FROM /DMO/CONNECTION WHERE CARRIER_ID = 'AA' INTO CORRESPONDING FIELDS OF TABLE @NESTED.
    LOOP AT NESTED REFERENCE INTO DATA(CONNECTION).
      SELECT * FROM /DMO/FLIGHT
        WHERE CARRIER_ID = @CONNECTION->CARRIER_ID AND CONNECTION_ID = @CONNECTION->CONNECTION_ID
         INTO CORRESPONDING FIELDS OF TABLE @CONNECTION->FLIGHT.
      LOOP AT CONNECTION->FLIGHT REFERENCE INTO DATA(FLIGHT).
        SELECT * FROM /DMO/BOOKING
            WHERE CARRIER_ID = @CONNECTION->CARRIER_ID AND CONNECTION_ID = @CONNECTION->CONNECTION_ID AND FLIGHT_DATE = @FLIGHT->FLIGHT_DATE
            INTO CORRESPONDING FIELDS OF TABLE @FLIGHT->BOOKING.
      ENDLOOP.
    ENDLOOP.

****Old
    READ TABLE NESTED     INTO DATA(NEST1) INDEX 2.
    READ TABLE NEST1-FLIGHT INTO DATA(NEST2) INDEX 1.
    READ TABLE NEST2-BOOKING   INTO DATA(NEST3) INDEX 2.
    OUT->WRITE( NEST3-CUSTOMER_ID ).


****New
    DATA(CUSTOMER2) = NESTED[ 2 ]-FLIGHT[ 1 ]-BOOKING[ 2 ]-CUSTOMER_ID.
    OUT->WRITE(  CUSTOMER2 ).


****Old
    READ TABLE FLIGHTS WITH KEY
        CARRIER_ID = 'AA' CONNECTION_ID = '0322' TRANSPORTING NO FIELDS.
    DATA(INDEX1) = SY-TABIX.
    OUT->WRITE( INDEX1 ).

****New
    DATA(INDEX2) = LINE_INDEX( FLIGHTS[ CARRIER_ID = 'AA' CONNECTION_ID = '0322' ] ).
    OUT->WRITE( INDEX2 ).


****Old
    DATA HTML TYPE STRING.
    HTML = `<table>`.
    LOOP AT FLIGHTS ASSIGNING FIELD-SYMBOL(<WA_SFLIGHT>).
      HTML =
        |{ HTML }<tr><td>{ <WA_SFLIGHT>-CARRIER_ID }| &
        |</td><td>{ <WA_SFLIGHT>-CONNECTION_ID }</td></tr>|.
    ENDLOOP.
    HTML = HTML && `</table>`.

****New
    DATA(HTML2) = REDUCE STRING(
       INIT H = `<table>`
       FOR  SFLIGHT2 IN FLIGHTS
       NEXT H =  |{ H }<tr><td>{ SFLIGHT2-CARRIER_ID }| &
                 |</td><td>{ SFLIGHT2-CONNECTION_ID }</td></tr>| ) && `</table>`.

****New
    SELECT * FROM /DMO/CONNECTION INTO TABLE @DATA(CONNECTIONS).
    LOOP AT CONNECTIONS REFERENCE INTO DATA(FLG)
       GROUP BY COND #( WHEN FLG->DISTANCE < 120 THEN 0
                        WHEN FLG->DISTANCE > 600 THEN 99
                        ELSE TRUNC( FLG->DISTANCE / '60' ) )
       ASCENDING
       REFERENCE INTO DATA(FD).
      OUT->WRITE(  |Distance: { COND #( WHEN FD->* = 0  THEN `less than 2`
                                        WHEN FD->* = 99 THEN `more than 10`
                                        ELSE FD->* ) } hours | ).
      LOOP AT GROUP FD REFERENCE INTO DATA(FLG2).
        OUT->WRITE(  |    { FLG2->AIRPORT_FROM_ID }-{ FLG2->AIRPORT_TO_ID }: { FLG2->DISTANCE }| ).
      ENDLOOP.
    ENDLOOP.

****Breakpoint helper
    IF SY-SUBRC = 0.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
