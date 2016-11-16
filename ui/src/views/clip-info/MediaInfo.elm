module MediaInfo exposing (loadMediaInfo, MediaInfoData)

import HAL exposing (HALBase)
import Json.Decode exposing (..)
import Task exposing (Task)
import String exposing (startsWith)
import Http

type alias MediaInfoData = 
    {
        mobID : String
    }

loadMediaInfo : HALBase -> Http.Request MediaInfoData
loadMediaInfo asset =
    let
        url = "/api/mediaInfo/" ++ 
            if startsWith "interplay" asset.assetID then
                asset.assetID
            else
                asset.systemType ++ ":" ++
                asset.systemID ++ ":" ++
                asset.assetType ++ ":" ++
                asset.assetID

        d = Debug.log "ELM: Request " url
    in
        Http.request
            { method = "GET"
            , headers = [ (Http.header "Accept" "application/json" )]
            , url = url
            , expect = Http.expectJson decode
            , body = Http.emptyBody
            , timeout = Nothing 
            , withCredentials = False
            }
        
decode : Decoder MediaInfoData
decode =
    at ["mediaInfo"]
        ( map MediaInfoData
            (field "mobId" string) )
