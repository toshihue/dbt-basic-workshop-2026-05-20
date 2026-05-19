unit_tests:
 - name: test_customers_aggregates_orders_for_existing_customer
   model: customers
   given:
     - input: ref('stg_customers')
       rows:
         - {customer_id: <todo>, first_name: <todo>, last_name: <todo>}
     - input: ref('stg_orders')
       rows:
         - {order_id: <todo>, customer_id: <todo>, order_date: <todo>}
         - {order_id: <todo>, customer_id: <todo>, order_date: <todo>}
   expect:
     rows:
       - {
           customer_id: <todo>,
           first_name: <todo>,
           last_name: <todo>,
           first_order_date: <todo>,
           most_recent_order_date: <todo>,
           number_of_orders: <todo>
         }
