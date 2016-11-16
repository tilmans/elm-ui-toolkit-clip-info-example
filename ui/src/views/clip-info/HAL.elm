module HAL exposing (loadRelations, HALBase, HALCommon, HALAsset, HALRelations) 

import Json.Decode exposing (..)
import Task exposing (Task)
import Http

type alias HALBase = 
    { systemID: String
    , systemType: String
    , assetID: String
    , assetType: String
    }
    
type alias HALCommon = 
    { name: String
    , creator: String
    , created: String
    , modifier: String
    , modified: String
    , start: String
    , end: String
    , duration: String
    }
    
type alias HALRelations = 
    { base: HALBase
    , relatives: Maybe (List HALAsset)
    }
    
type alias HALAsset =
    { base: HALBase
    , common: HALCommon
    }
    
loadRelations : String -> Http.Request HALRelations
loadRelations asset =
    let 
        url = "/apis/avid.pam;version=0;realm=global/assets/"++ asset ++"/relatives"
        debug = Debug.log "ELM: Load URL" url
    in
        Http.get url halRelationsDecoder
    
halBaseDecoder : Decoder HALBase
halBaseDecoder = 
    map4 HALBase
        (field "systemID" string)
        (field "systemType" string)
        (field "id" string)
        (field "type" string)
        
halAssetDecoder : Decoder HALAsset
halAssetDecoder =
    map2 HALAsset
        (field "base" halBaseDecoder)
        (field "common" halCommonDecoder)        
        
halCommonDecoder : Decoder HALCommon
halCommonDecoder = 
    map8 HALCommon
        (field "name" string)
        (field "creator" string)
        (field "created" string)
        (field "modifier" string)
        (field "modified" string)
        (field "startTC" string)
        (field "endTC" string)
        (field "durationTC" string)
        
halRelationsDecoder : Decoder HALRelations
halRelationsDecoder =     
    map2 HALRelations
        (field "base" halBaseDecoder)
        (maybe ( field "relatives" (list halAssetDecoder) ) ) {- Need to make this a maybe -}
    
