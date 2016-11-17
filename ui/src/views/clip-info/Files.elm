module HAL exposing (loadFiles, ) 

import Json.Decode exposing (..)
import Task exposing (Task)
import Http
import HAL exposing (..)

loadRelations : String -> Http.Request FileLocationsData
loadRelations asset =
    let 
        url = "/apis/avid.pam;version=0;realm=global/assets/"++ asset ++"/filemobs"
        debug = Debug.log "ELM: Load URL" url
    in
        Http.get url halRelationsDecoder
    
halRelationsDecoder : Decoder HALRelations
halRelationsDecoder =     
    map2 HALRelations
        (field "base" halBaseDecoder)
        (maybe ( field "relatives" (list halAssetDecoder) ) ) {- Need to make this a maybe -}
    
