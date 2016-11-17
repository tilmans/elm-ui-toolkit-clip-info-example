module HAL exposing (..)

import HAL exposing (..)
import Json.Decode exposing (..)

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
