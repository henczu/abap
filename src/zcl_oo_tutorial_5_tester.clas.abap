"! <p class="shorttext synchronized" lang="en">OO Tutorial #5 Tester</p>
CLASS ZCL_OO_TUTORIAL_5_TESTER DEFINITION
 PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES IF_OO_ADT_CLASSRUN.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_OO_TUTORIAL_5_TESTER IMPLEMENTATION.


  METHOD IF_OO_ADT_CLASSRUN~MAIN.

    TRY.
        DATA(AA_0017) = NEW ZCL_OO_TUTORIAL_5(
            CARRIER_ID    = `AA`
            CONNECTION_ID = `0017`
            FLIGHT_DATE   = `20230222` ).
        DATA(FLIGHT_GOOD) = AA_0017->CALCULATE_FLIGHT_PRICE( ).
        OUT->WRITE( |Flight Price for AA-0017 on {  CONV /DMO/FLIGHT_DATE( `20230222` ) DATE = ENVIRONMENT }: | &&
                    |{ FLIGHT_GOOD-PRICE CURRENCY = FLIGHT_GOOD-CURRENCY } { FLIGHT_GOOD-CURRENCY }| ).
        OUT->WRITE( AA_0017->GET_FLIGHT_DETAILS( ) ).

        OUT->WRITE( ` `).
        DATA(UA_0017) = NEW ZCL_OO_TUTORIAL_5(
          CARRIER_ID    = `UA`
          CONNECTION_ID = `0058`
          FLIGHT_DATE   = `20200426` ).

        DATA(FLIGHT_BAD) = UA_0017->CALCULATE_FLIGHT_PRICE( ).

        OUT->WRITE( |Flight Price for UA-0058 on {  CONV /DMO/FLIGHT_DATE( `20220426` ) DATE = ENVIRONMENT }: | &&
                    |{ FLIGHT_BAD-PRICE CURRENCY = FLIGHT_BAD-CURRENCY } { FLIGHT_BAD-CURRENCY }| ).
        OUT->WRITE( UA_0017->GET_FLIGHT_DETAILS( ) ).

      CATCH ZCX_OO_TUTORIAL INTO DATA(CX_FLIGHT).
        OUT->WRITE(  CX_FLIGHT->GET_TEXT(  ) ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
