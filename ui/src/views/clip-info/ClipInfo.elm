port module ClipInfo exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import Task exposing (Task)
import Http exposing (Error)

import HAL exposing (..)
import MediaInfo exposing (..)

port open : (List String) -> Cmd msg
port active : (HALBase -> msg) -> Sub msg

type Msg 
    = SetActiveAsset HALBase
    | ClickLink HALBase
    | RelationsLoaded (Result Http.Error HALRelations)
    | MediaInfoLoaded (Result Http.Error MediaInfoData)

type alias Model = 
    { data: Maybe (List HALAsset)
    , asset: Maybe HALBase
    , error: Maybe String
    , loading: Bool
    }


init : (Model, Cmd Msg)
init = (Model Nothing Nothing Nothing False, Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    let 
        log = Debug.log "ELM: Model update" msg
    in 
        case msg of 
            SetActiveAsset asset ->
                if asset.systemType == "interplay" then
                    (Model Nothing (Just asset) Nothing True, loadMobID asset)
                else 
                    (Model Nothing (Just asset) (Just "Not an Interplay Production asset") False, Cmd.none)
            ClickLink asset ->
                ({model | loading = True}, open [ asset.assetType, asset.assetID ] )
            RelationsLoaded (Ok relations) ->
                case relations.relatives of
                    Nothing ->
                        ({model | data = Nothing, loading = False}, Cmd.none)
                    Just relatives ->
                        ({model | data = Just relatives, loading = False}, Cmd.none)
            RelationsLoaded (Err _) ->
                ({model | error = Just "Unable to load relations", loading = False}, Cmd.none) 
            MediaInfoLoaded (Ok info) ->
                (model, loadData info.mobID)
            MediaInfoLoaded (Err _) ->
                ({model | error = Just "Unable to resolve mobid", loading = False}, Cmd.none)

view : Model -> Html Msg
view model = 
    if model.loading then
        drawMessage "Loading..."
    else
        case model.asset of
            Nothing ->
                drawMessage "No asset selected."
            Just asset ->
                case model.error of 
                    Nothing ->
                        drawRelatives model
                    Just error ->
                        drawMessage error
    
subscriptions : Model -> Sub Msg
subscriptions model =
  active SetActiveAsset

drawMessage : String -> Html Msg
drawMessage message = 
    div [class "message"] [text message]
  
drawRelation : HALAsset -> Html Msg
drawRelation relation =
    tr [onClick (ClickLink relation.base), class "clickable"] [ 
        td [] [text (relation.common.name)],
        td [] [text (relation.base.assetType)] 
    ]

drawRelatives : Model -> Html Msg
drawRelatives model = 
    fieldset [class "clipinfo-fieldset"] [
        legend [class "clipinfo-fieldset-legend"]
            [text "Relatives"],
        case model.data of
            Nothing ->
                div [] [ text "Has no relatives"]
            Just relatives ->
                table [class "clipinfo-table"] [
                    thead [] [
                        tr [] [
                            td [] [text "Name"],
                            td [] [text "Type"]
                        ]
                    ],
                    tbody [] 
                        (List.map drawRelation relatives) 
                ]
    ]
            
openLink : HALBase -> Cmd Msg
openLink asset =
    Cmd.none
        
loadData : String -> Cmd Msg
loadData asset = 
    Http.send RelationsLoaded (loadRelations asset)
        
loadMobID : HALBase -> Cmd Msg
loadMobID asset =
    Http.send MediaInfoLoaded (loadMediaInfo asset)
    
main = Html.program 
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
