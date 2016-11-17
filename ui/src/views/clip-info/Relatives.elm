module Relatives exposing (loadRelations) 

import Json.Decode exposing (..)
import Http
import HAL exposing (..)

loadRelations : String -> Http.Request HALRelations
loadRelations asset =
    let 
        url = "/apis/avid.pam;version=0;realm=global/assets/"++ asset ++"/relatives"
        debug = Debug.log "ELM: Load URL" url
    in
        Http.get url halRelationsDecoder
            
halRelationsDecoder : Decoder HALRelations
halRelationsDecoder =     
    map2 HALRelations
        (field "base" halBaseDecoder)
        (maybe ( field "relatives" (list halAssetDecoder) ) ) {- Need to make this a maybe -}
    
