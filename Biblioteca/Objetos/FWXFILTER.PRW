#INCLUDE "TOTVS.CH"

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FWXFILTER
Cria um objeto para selecionar e definir filtros.

@author Ivan Haponczuk
@since 12/02/2021
@version 1.0

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
CLASS FWXFILTER

    DATA aFilLst
    DATA aFilter
    DATA xFilter

    DATA nFilCod
    DATA nFilIni
    DATA nFilFim
    DATA oFilPnl
    DATA nFilPos
    DATA nFilLar
    DATA oFilBtn
    DATA oFilMnu
    DATA oFilGet
    DATA oFilCmb
    DATA oBtnAdd
    DATA bChange

    METHOD New( nTop, nLef, nLar, nAlt, oDlg, bChg ) CONSTRUCTOR
    METHOD Add( cCod, cTit, cTip, nTam, cPic, aOpc, cQry )
    METHOD AltFiltro( nPos )
    METHOD AddFiltro()
    METHOD SetFiltro( cCod, cFil, cTxt, cTip )
    METHOD DelFiltro( nPos )
    METHOD ClrFiltro()
    METHOD GetFiltro()
    METHOD GetQuery()

ENDCLASS

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Cria e instancia o filtro a ser apresentado.

@author Ivan Haponczuk
@since 12/02/2021
@version 1.0

@param nTop, number, Coordenada do topo do filtro.
@param nLef, number, Coordenada da esquerda do filtro.
@param nLar, number, Largura do filtro.
@param nAlt, number, Altura do filtro.
@param oDlg, object, Tela onde será apresentado o filtro.
@param bChg, codeblock, Bloco de código a ser executado ao incluir, excluir ou alterar um filtro.

@return object, Retorna o objeto de filtro.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD New( nTop, nLef, nAlt, nLar, oDlg, bChg ) CLASS FWXFILTER

    Default bChg := {|| }

    ::nFilCod := 0
    ::nFilPos := 0
    ::nFilLar := 0
    ::aFilLst := {}
    ::aFilter := {}
    ::bChange := bChg
    ::xFilter := Space( 100 )

    ::oFilPnl := tPanel():New( nTop, nLef,, oDlg,, .T.,,,, nLar, nAlt )

    ::oFilBtn := tButton():New( 000, 000, "Filtro", ::oFilPnl,, 015, 015,,,, .T. )
    ::oFilMnu := tMenu():New( 000, 000, 000, 000, .T. )
    ::oFilBtn:setPopupMenu( ::oFilMnu )
    ::oFilBtn:SetCSS( GetCSSBtn() )

    ::oFilMnu:Add( tMenuItem():New( ::oFilMnu, "Remover filtros",,,, {|| ::ClrFiltro() },, "FWSKIN_MODAL_CLOSE",,,,,,, .T. ) )
    ::oFilMnu:lShowHint := .F.

    ::oFilGet := TGet():New( 000, 050, bSetGet( ::xFilter ), ::oFilPnl, 050, 013,,,,,,,, .T. )
    ::oFilGet:SetCSS( GetCSSGet() )
    ::oFilGet:lNoButton := .T.

	::oFilCmb := tComboBox():New( 000, 050, bSetGet( ::xFilter ), {}, 050, 013, ::oFilPnl,,,,,, .T. )
    ::oFilCmb:SetCSS( GetCSSCmb() )
    ::oFilCmb:Hide()

    ::oBtnAdd := tButton():New( 000, 100, "", ::oFilPnl, {|| ::AddFiltro() }, 015, 015,,,, .T. )
    ::oBtnAdd:SetCSS( GetCSSBtn( .T. ) )

RETURN SELF

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Add
Adiciona um filtro para ser selecionado.

@author Ivan Haponczuk
@since 12/02/2021
@version 1.0

@param cCod, character, Código do filtro ou campo à que se refere ao filtro, tem que ser único.
@param cTit, character, Título do filtro que será apresentado na seleção.
@param cTip, character, Tipo do variável do filtro, indicando se é caracter, data ou número.
@param nTam, number, Tamanho máximo do conteúdo do filtro.
@param cPic, character, Formato de apresentação do filtro.
@param aOpc, array, Array com as opções do filtro.
@param cQry, character, Indica o tipo de filtro.

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD Add( cCod, cTit, cTip, nTam, cPic, aOpc, cQry ) CLASS FWXFILTER

    Local nLar := 0
    Local oItm := Nil
    Local bSel := {|| }

    Default cCod := ""
    Default cTit := ""
    Default cTip := ""
    Default nTam := 99
    Default cPic := ""
    Default aOpc := {}
    Default cQry := ""

    aAdd( ::aFilLst, { cCod, cTit, cTip, nTam, cPic, aOpc, cQry } )

    nLar := ( ( Len( cTit ) * 3 ) + 15 ) * 2
    If ( nLar > ::nFilLar )
        ::nFilLar := nLar
        ::oFilBtn:Move( 000, 000, ::nFilLar, 030 )
        ::oFilGet:Move( 000, ::nFilLar, 200, 030 )
        ::oFilCmb:Move( 000, ::nFilLar, 200, 030 )
        ::oBtnAdd:Move( 000, ::nFilLar + 200, 030, 030 )
        ::nFilIni := ::nFilLar + 240
        ::nFilFim := ::nFilIni
    EndIf

    bSel := &( "{|| SELF:AltFiltro(" + AllTrim( Str( Len( ::aFilLst ) ) ) + ")  }" )
    oItm := tMenuItem():New( ::oFilMnu, cTit + Space( 5 ),,,, bSel,,,,,,,,, .T. )
    ::oFilMnu:Add( oItm )

    If ( Len( ::aFilLst ) == 1 )
        ::AltFiltro( 1 )
    EndIf

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AltFiltro
Seleciona um filtro da lista de filtros disponíveis.

@author Ivan Haponczuk
@since 12/02/2021
@version 1.0

@param nPos, number, Número do filtro a ser selecionado.

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD AltFiltro( nPos ) CLASS FWXFILTER

    ::nFilPos := nPos
    ::oFilBtn:cCaption := ::aFilLst[nPos,2]
    ::oFilCmb:Hide()
    
    Do Case

        Case ( Len( ::aFilLst[nPos,6] ) > 0 )
        
            ::oFilCmb:SetItems( GetLst( ::aFilLst[nPos,6], .T. ) )
            ::oFilCmb:Select( 1 )
            ::oFilCmb:Show()

        Case ( ::aFilLst[nPos,3] == "D" )

            ::xFilter := STOD( "" )

        Case ( ::aFilLst[nPos,3] == "N" )

            ::xFilter := 0

        OtherWise

            ::xFilter := Space( ::aFilLst[nPos,4] )

    EndCase

    If ( !Empty( ::aFilLst[nPos,5] ) )
        ::oFilGet:Picture := ::aFilLst[nPos,5]
    Else
        ::oFilGet:Picture := ""
    EndIf

    ::oFilGet:CtrlRefresh()

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AddFiltro
Aplica um filtro de acordo com as informações definidas.

@author Ivan Haponczuk
@since 12/02/2021
@version 1.0

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD AddFiltro() CLASS FWXFILTER

    Local cCod := ""
    Local cTit := ""
    Local cTxt := ""
    Local cFil := ""
    Local cTip := ""

    cCod := ::aFilLst[::nFilPos,1]
    cTit := ::aFilLst[::nFilPos,2]

    Do Case

        Case ( Len( ::aFilLst[::nFilPos,6] ) > 0 )

            cFil := GetLst( ::aFilLst[::nFilPos,6], .F. )[::oFilCmb:nAt]
            cTxt := GetLst( ::aFilLst[::nFilPos,6], .T. )[::oFilCmb:nAt]

        Case ( ::aFilLst[::nFilPos,3] == "D" )

            cFil := ::xFilter
            cTxt := DTOC( cFil )

        Case ( ::aFilLst[::nFilPos,3] == "N" )

            cFil := ::xFilter
            If ( Empty( ::aFilLst[::nFilPos,5] ) )
                cTxt := AllTrim( Str( cFil ) )
            Else
                cTxt := cFil
            EndIf

        OtherWise

            cFil := AllTrim( ::xFilter )
            cTxt := cFil

    EndCase

    If ( !Empty( ::aFilLst[::nFilPos,5] ) )
        cTxt := Transform( cTxt, ::aFilLst[::nFilPos,5] )
    EndIf

    cTxt := AllTrim( cTit ) + " " + AllTrim( cTxt )
    cTip := ::aFilLst[::nFilPos,7]

    ::SetFiltro( cCod, cFil, cTxt, cTip )

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetFiltro
Adiciona um filtro a barra de filtros conforme os parâmetros enviados.

@author Ivan Haponczuk
@since 12/02/2021
@version 1.0

@param cCod, character, Código do filtro.
@param cFil, character, Conteúdo do filtro.
@param cTxt, character, Texto de apresentação do filtro.
@param cTip, character, Tipo do filtro a ser executado.

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD SetFiltro( cCod, cFil, cTxt, cTip ) CLASS FWXFILTER

    Local nCod := 0
    Local nLar := 0
    Local oBtn := Nil
    Local bSel := {|| }

    Default cTxt := ""
    Default cTip := ""

    ::nFilCod++
    nCod := ::nFilCod

    If ( Empty( cTxt ) )
        cTxt := cCod + " " + cFil
    EndIf

    bSel := &( "{|| SELF:DelFiltro(" + AllTrim( Str( nCod ) ) + ")  }" )
    oBtn := tButton():New( -99, -99, cTxt, ::oFilPnl, bSel, 015, 015,,,, .T. )
    oBtn:SetCSS( GetCSSFil() )

    nLar := GetStringPixSize( cTxt, "Arial", 8 )[2]
    nLar += 45

    oBtn:Move( 000, ::nFilFim, nLar, 030 )
    ::nFilFim += nLar + 5

    aAdd( ::aFilter, { nCod, cCod, cFil, oBtn, nLar, cTip } )

    Eval( ::bChange, SELF )

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DelFiltro
Efetua a exclusão de um filtro selecionado.

@author Ivan Haponczuk
@since 12/02/2021
@version 1.0

@param nCod, number, Número do filtro a ser excluído.

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD DelFiltro( nCod ) CLASS FWXFILTER

    Local nFil := 0
    Local nPos := 0

    nPos := aScan( ::aFilter, {|x| x[1] == nCod } )
    
    If ( nPos > 0 )

        FreeObj( ::aFilter[nPos,4] )

        aDel( ::aFilter, nPos )
        aSize( ::aFilter, Len( ::aFilter ) - 1 )

        ::nFilFim := ::nFilIni
        For nFil := 1 To Len( ::aFilter )
            ::aFilter[nFil,4]:Move( 000, ::nFilFim, ::aFilter[nFil,5], 030 )
            ::nFilFim += ::aFilter[nFil,5] + 5
        Next nFil

    EndIf

    Eval( ::bChange, SELF )

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ClrFiltro
Efetua a limpeza de todos os filtros aplicados.

@author Ivan Haponczuk
@since 12/02/2021
@version 1.0

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD ClrFiltro() CLASS FWXFILTER

    Local nFil := 0

    For nFil := 1 To Len( ::aFilter )
        FreeObj( ::aFilter[nFil,4] )
    Next nFil

    ::aFilter := {}
    ::nFilFim := ::nFilIni

    Eval( ::bChange, SELF )

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetFiltro
Retorna os filtros aplicados em array.

@author Ivan Haponczuk
@since 12/02/2021
@version 1.0

@return array, Retorna os filtros aplicados em array.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD GetFiltro() CLASS FWXFILTER

    Local nFil := 0
    Local aFil := {}
    Local aRet := {}
    Local cCod := ""

    For nFil := 1 To Len( ::aFilter )
        aAdd( aFil, { ::aFilter[nFil,2], ::aFilter[nFil,3], ::aFilter[nFil,6] } )
    Next nFil

    aFil := aSort( aFil,,, {|x,y| x[1] > y[1] } )

    For nFil := 1 To Len( aFil )

        If ( aFil[nFil,1] == cCod )
            aAdd( aRet[Len(aRet),2], { aFil[nFil,2], aFil[nFil,3] } )
        Else
            aAdd( aRet, { aFil[nFil,1], { { aFil[nFil,2], aFil[nFil,3] } } } )
            cCod := aFil[nFil,1]
        EndIf

    Next nFil

RETURN ( aRet )

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetQuery
Retorna os filtros aplicados em formato de query.

@author Ivan Haponczuk
@since 12/02/2021
@version 1.0

@return character, Retorna os filtros aplicados em formato de query.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD GetQuery() CLASS FWXFILTER

    Local nFil := 0
    Local cQry := ""
    Local aFil := ::GetFiltro()

    For nFil := 1 To Len( aFil )

        cQry += " AND ( " + GetFil( aFil[nFil,1], aFil[nFil,2] ) + " )"

    Next nFil

Return ( cQry )

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetFil
Efetua e retorna a montagem do filtro em formado de query.

@author Ivan Haponczuk
@since 12/02/2021
@version 1.0

@param cCmp, character, Nome do campo a ser filtrado.
@param aFil, array, Conteúdos a serem filtrados.

@return character, Retorna a montagem do filtro em formado de query.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function GetFil( cCmp, aFil )

    Local nFil := 0
    Local cFil := ""
    Local cCon := ""

    For nFil := 1 To Len( aFil )

        cCon := aFil[nFil,1] // Conteúdo do filtro
        cTip := aFil[nFil,2] // Tipo do filtro

        Do Case

            Case ( ValType( cCon ) == "D" )

                cCon := DTOS( cCon )

        EndCase

        If ( SubStr( cTip, 1, 1 ) == "&" )
            cTip := SubStr( cTip, 2, 999 )
            cFil += If( nFil > 1, " AND ", "" )
        Else
            cFil += If( nFil > 1, " OR ", "" )
        EndIf
        
        Do Case

            Case ( cTip == "L%" )

                cCon := If( Empty( cCon ), " ", cCon )
                cFil += cCmp + " LIKE '" + cCon + "%'"

            Case ( cTip == "%L" )

                cCon := If( Empty( cCon ), " ", cCon )
                cFil += cCmp + " LIKE '%" + cCon + "'"

            Case ( cTip == "%L%" )

                cCon := If( Empty( cCon ), " ", cCon )
                cFil += cCmp + " LIKE '%" + cCon + "%'"

            Case ( cTip == "IN" )

                cCon := If( Empty( cCon ), "''", cCon )
                cFil += cCmp + " IN (" + cCon + ")"

            Case ( cTip == "NIN" )

                cCon := If( Empty( cCon ), "''", cCon )
                cFil += cCmp + " NOT IN (" + cCon + ")"

            Case ( cTip == ">" )

                cFil += cCmp + " > '" + cCon + "'"

            Case ( cTip == "<" )

                cFil += cCmp + " < '" + cCon + "'"

            Case ( cTip == ">=" )

                cFil += cCmp + " >= '" + cCon + "'"

            Case ( cTip == "<=" )

                cFil += cCmp + " <= '" + cCon + "'"

            OtherWise

                cFil += cCmp + " = '" + cCon + "'"

        EndCase

    Next nFil

Return ( cFil )

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetLst
Filtra a lista de opções de um filtro.

@author Ivan Haponczuk
@since 12/02/2021
@version 1.0

@param aLst, array, Lista de opções de um filtro.
@param lDes, boolean, Define se deve ser retornado um array com o conteúdo das opções ou a descrição.

@return array, Vetor com a lista de opções do filtro.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function GetLst( aLst, lDes )

    Local nLin := 0
    Local aRet := {}

    Default lDes := .F.

    For nLin := 1 To Len( aLst )
        If ( lDes )
            aAdd( aRet, aLst[nLin,2] )
        Else
            aAdd( aRet, aLst[nLin,1] )
        EndIf
    Next nLin

Return ( aRet )

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetCSSBtn
Retorna a estilização dos botões.

@author Ivan Haponczuk
@since 12/02/2021
@version 1.0

@param lFil, boolean, Indica se deve retorna a estilização do botão do filtro ou não.

@return character, Retorna a estilização dos botões.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function GetCSSBtn( lFil )

    Local cCSS := ""

    Default lFil := .F.

    cCSS := " QPushButton { "
    cCSS += "  border: 1px solid rgb(197,201,202);"
    cCSS += "  padding-right: 1px;"
    cCSS += "  background-color: rgb(238,238,238);"
    If ( lFil )
        cCSS += "  border-left-width: 0px;"
        cCSS += "  border-top-left-radius: 0px;"
        cCSS += "  border-top-right-radius: 3px;"
        cCSS += "  border-bottom-left-radius: 0px;"
        cCSS += "  border-bottom-right-radius: 3px;"
        cCSS += "  qproperty-icon: url(rpo:FWSKIN_ADD_ICO_GRAY.PNG);"
    Else
        cCSS += "  border-right-width: 0px;"
        cCSS += "  border-top-left-radius: 3px;"
        cCSS += "  border-top-right-radius: 0px;"
        cCSS += "  border-bottom-left-radius: 3px;"
        cCSS += "  border-bottom-right-radius: 0px;"
    EndIf
    cCSS += "  qproperty-iconSize: 12px 12px;"
    cCSS += " }"
    If !( lFil )
        cCSS += " QPushButton::menu-indicator {"
        cCSS += "  image: url(rpo:FWX_ARROWDSB.PNG);"
        cCSS += "  subcontrol-position: right center;"
        cCSS += "  subcontrol-origin: padding;"
        cCSS += "  left: -7px;"
        cCSS += " }"
    EndIf

Return ( cCSS )

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetCSSGet
Retorna a estilização da caixa de texto.

@author Ivan Haponczuk
@since 12/02/2021
@version 1.0

@return character, Retorna a estilização da caixa de texto.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function GetCSSGet()

    Local cCSS := ""

    cCSS := " QLineEdit { "
    cCSS += "  color: rgb(50,50,50);"
    cCSS += "  border: 1px solid rgb(197,201,202);"
    cCSS += "  border-top-left-radius: 0px;"
    cCSS += "  border-top-right-radius: 0px;"
    cCSS += "  border-bottom-left-radius: 0px;"
    cCSS += "  border-bottom-right-radius: 0px;"
    cCSS += "  padding-left: 4px;"
    cCSS += "  padding-right: 6px;"
    cCSS += " }"
    cCSS += " QLineEdit:focus {"
    cCSS += "  border-color: rgb(51,147,223)"
    cCSS += " }"

Return ( cCSS )

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetCSSCmb
Retorna a estilização do combo de seleção.

@author Ivan Haponczuk
@since 12/02/2021
@version 1.0

@return character, Retorna a estilização do combo de seleção.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function GetCSSCmb()

    Local cCSS := ""

    cCSS := " QComboBox { "
    cCSS += "  color: rgb(50,50,50);"
    cCSS += "  background-color: #FFFFFF;"
    cCSS += "  border: 1px solid rgb(197,201,202);"
    cCSS += "  border-top-left-radius: 0px;"
    cCSS += "  border-top-right-radius: 0px;"
    cCSS += "  border-bottom-left-radius: 0px;"
    cCSS += "  border-bottom-right-radius: 0px;"
    cCSS += "  padding-left: 10px;"
    cCSS += "  padding-right: 5px;"
    cCSS += " }"
    cCSS += " QComboBox:focus {"
    cCSS += "  border-color: rgb(51,147,223)"
    cCSS += " }"
    cCSS += " QComboBox::drop-down {"
    cCSS += "  border: 0px;"
    cCSS += "  width: 20px;"
    cCSS += " }"
    cCSS += " QComboBox::down-arrow {"
	cCSS += "  padding: 0px 10px 0px 6px;"
    cCSS += "  image: url(rpo:FWX_ARROWDSB.PNG);"
	cCSS += "  width: 15px;"
	cCSS += "  height: 10px;"
    cCSS += " }"

Return ( cCSS )

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetCSSFil
Retorna a estilização dos botões de filtros aplicados.

@author Ivan Haponczuk
@since 12/02/2021
@version 1.0

@return character, Retorna a estilização dos botões de filtros aplicados.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function GetCSSFil()

    Local cCSS := ""

    Default lFil := .F.

    cCSS := " QPushButton { "
    cCSS += "  text-align: left;
    cCSS += "  border: 1px solid rgb(197,201,202);"
    cCSS += "  background-color: rgb(238,238,238);"
    cCSS += "  border-top-left-radius: 3px;"
    cCSS += "  border-top-right-radius: 3px;"
    cCSS += "  border-bottom-left-radius: 3px;"
    cCSS += "  border-bottom-right-radius: 3px;"
    cCSS += "  background-position: right center;"
    cCSS += "  background-repeat: no-repeat;"
    cCSS += "  background-origin: content;"
    cCSS += "  background-image: url(rpo:FWSKIN_MODAL_CLOSE.PNG);"
    cCSS += "  padding-right: 10px;"
    cCSS += "  padding-left: 10px;"
    cCSS += " }"

Return ( cCSS )
