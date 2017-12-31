-type hs_token()       :: binary().
-type hs_id()          :: hs_token().

-export_type([ hs_id/0
             , hs_token/0
             ]).

-type hs_reading() ::
  #{ id           => hs_id()
   , sensor       => atom()
   , value        => term()
   , created      => calendar:datetime()
   }.
-export_type([hs_reading/0]).
