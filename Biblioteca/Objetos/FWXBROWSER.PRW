#INCLUDE "TOTVS.CH"

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FWXBROWSER
Cria um browser para apresentar as informações de uma tabela, query ou array.

@author Ivan Haponczuk
@since 17/11/2020
@version 1.0

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
CLASS FWXBROWSER

    DATA oBrowse
    DATA aStatus
    DATA lActive
    DATA cTipDat
    DATA oWndPnl
    DATA oBrwPnl
    DATA xBrwDat
    DATA cBrwAls
    DATA aBrwCol
    DATA bRigCli
    DATA lBorder

    METHOD New( nTop, nLef, nLar, nAlt, oDlg, xDat, cAls, lBrd ) CONSTRUCTOR
    METHOD AddColumns( bDat, cTit, cTip, nSiz, nDec, cPic, nAlg )
    METHOD Move( nTop, nLef, nLar, nAlt )
    METHOD AddStatus( xCnd, cCol, cTit, cDes, cCod )
    METHOD SetRightClick( bCod )
    METHOD SetQuery( cQry )
    METHOD SetArray( aArr )
    METHOD Refresh( lTop )
    METHOD Activate()
    METHOD Legenda()
    METHOD At()    

ENDCLASS

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Cria e instancia o browser a ser apresentado.

@author Ivan Haponczuk
@since 17/11/2020
@version 1.0

@param nTop, number, Coordenada do topo do browser.
@param nLef, number, Coordenada da esquerda do browser.
@param nLar, number, Largura do browser.
@param nAlt, number, Altura do browser.
@param oDlg, object, Tela onde será apresentado o browser.
@param xDad, undefined, Dados que serão apresentados no browser.
@param cAls, character, Alias que será definido no browser.
@param lBrd, boolean, Define se deve apresentar a borda ou não.

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD New( nTop, nLef, nAlt, nLar, oDlg, xDat, cAls, lBrd ) CLASS FWXBROWSER

    Default cAls := ""
    Default lBrd := .T.

    ::aStatus := {}

    ::lActive := .F.
    ::cTipDat := ValType( xDat )
    ::xBrwDat := xDat
    ::cBrwAls := cAls
    ::aBrwCol := {}
    ::bRigCli := Nil
    ::lBorder := lBrd

    If ( ::lBorder )

        ::oWndPnl := tPanel():New( nTop, nLef, "", oDlg,, .T.,,,, nLar, nAlt )
        ::oWndPnl:SetCSS( " TPanel{ background-color : rgb( 197, 201, 202 ); }")

        ::oBrwPnl := tPanel():New( 000, 0.5, "", ::oWndPnl,, .T.,,,, nLar-1, nAlt )
        ::oBrwPnl:SetCSS( " TPanel{ background-color : rgb( 255, 255, 255 ); }")

    Else

        ::oBrwPnl := tPanel():New( nTop, nLef, "", oDlg,, .T.,,,, nLar, nAlt )
        ::oBrwPnl:SetCSS( " TPanel{ background-color : rgb( 255, 255, 255 ); }")
        ::oWndPnl := ::oBrwPnl

    EndIf

RETURN SELF

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AddColumns
Adiciona uma coluna para ser apresentada no browser.

@author Ivan Haponczuk
@since 17/11/2020
@version 1.0

@param bVar, codeblock, Valor a ser apresentado no campo.
@param cTit, character, Título da coluna.
@param cTip, character, Tipo do conteúdo do campo.
@param nTam, number, Tamanho da coluna.
@param nDec, number, Quantidade de decimais do campo.
@param cPic, character, Picture de apresentação do campo.
@param nAlg, number, Alinhamento do conteúdo do campo.

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD AddColumns( bVar, cTit, cTip, nSiz, nDec, cPic, nAlg, bHed ) CLASS FWXBROWSER

    If ( ::lActive )

        ::oBrowse:DeActivate()
        ::oBrowse:SetColumns( { GetColumn( bVar, cTit, cTip, nSiz, nDec, cPic, nAlg, bHed ) } )
        ::oBrowse:Activate()

    Else

        aAdd( ::aBrwCol, GetColumn( bVar, cTit, cTip, nSiz, nDec, cPic, nAlg, bHed ) )

    EndIf

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Move
Move a posição do browser na tela atual que ele está apresentado.

@author Ivan Haponczuk
@since 29/04/2021
@version 1.0

@param nTop, number, Coordenada do topo do browser.
@param nLef, number, Coordenada da esquerda do browser.
@param nAlt, number, Altura do browser.
@param nLar, number, Largura do browser.

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD Move( nTop, nLef, nAlt, nLar ) CLASS FWXBROWSER

    nTop *= 2
    nLef *= 2
    nAlt *= 2
    nLar *= 2

    ::oWndPnl:Move( nTop, nLef, nLar, nAlt )

    If ( ::lBorder )
        ::oBrwPnl:Move( 000, 001, nLar-2, nAlt )
    EndIf

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AddLegend
Adiciona uma coluna de status de acordo com as regras parametrizadas.

@author Ivan Haponczuk
@since 25/11/2020
@version 1.0

@param aLeg, array, Vetor com as regras da legenda.

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD AddStatus( xCnd, cCol, cTit, cDes, cCod ) CLASS FWXBROWSER

    Default cCod := "01"

    aAdd( ::aStatus, { cCol, cTit, cDes, xCnd, cCod } )

    If ( ::lActive )
        ::oBrowse:AddLegend( xCnd, cCol, cTit, cCod )
    EndIf

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetRightClick
Define um bloco de código a ser executado ao efetuar o click com o botão direito do mouse no browser.

@author Ivan Haponczuk
@since 24/02/2021
@version 1.0

@param bCod, codeblock, Bloco de código a ser executado.

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD SetRightClick( bCod ) CLASS FWXBROWSER

    ::bRigCli := bCod

    If ( ::lActive )
        ::oBrowse:oBrowse:bRClicked := ::bRigCli
    EndIf

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetQuery
Define uma nova querie para ser apresentada no browser.

@author Ivan Haponczuk
@since 18/02/2020
@version 1.0

@param cQry, character, Querie a ser apresentada no browser.

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD SetQuery( cQry ) CLASS FWXBROWSER

    ::oBrowse:SetQuery( cQry )
    ::Refresh( .T. )

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetArray
Define um novo array para ser apresentado no browser.

@author Ivan Haponczuk
@since 18/02/2020
@version 1.0

@param aArr, array, Array a ser apresentado no browser.

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD SetArray( aArr ) CLASS FWXBROWSER

    ::oBrowse:SetArray( aArr )
    ::Refresh( .T. )

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Refresh
Atualiza o conteúdo do browser.

@author Ivan Haponczuk
@since 18/02/2020
@version 1.0

@param lTop, boolean, Define se após atualização o cursor deve ser posicionado no topo.

@return boolean, Retorna verdadeiro caso o browser tenha sido atualizado com sucesso, caso contrário retorna falso.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD Refresh( lTop ) CLASS FWXBROWSER

    ::oBrowse:Data():DeActivate()
    ::oBrowse:Data():Activate()

RETURN ( ::oBrowse:Refresh( lTop ) )

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Activate
Ativa o browser e o apresenta na tela.

@author Ivan Haponczuk
@since 25/03/2021
@version 1.0

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD Activate() CLASS FWXBROWSER

    Local nSts := 0

    ::oBrowse := FWFormBrowse():New()

    For nSts := 1 To Len( ::aStatus )
        ::oBrowse:AddLegend( ::aStatus[nSts,4], ::aStatus[nSts,1], ::aStatus[nSts,2], ::aStatus[nSts,5] )
    Next nSts

    ::oBrowse:SetColumns( ::aBrwCol )

    If ( ::cTipDat == "A" )

        ::oBrowse:SetDataArray()
        ::oBrowse:SetArray( ::xBrwDat )

    Else

        ::oBrowse:SetDataQuery() 
        ::oBrowse:SetAlias( ::cBrwAls )
        ::oBrowse:SetQuery( ::xBrwDat )

    EndIf

    ::oBrowse:SetOwner( ::oBrwPnl )
    ::oBrowse:DisableDetails()
    ::oBrowse:DisableReport()
    ::oBrowse:Activate()

    ::oBrowse:oBrowse:bRClicked := ::bRigCli
    ::oBrowse:oBrowse:bKeyBlock := {|oGrid,cKey| KeyBlock( SELF:oBrowse, cKey ) } 

    ::lActive := .T.

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Legenda
Apresenta uma tela com a legenda do semáforo aplicado ao brownser.

@author Ivan Haponczuk
@since 18/02/2020
@version 1.0

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD Legenda() CLASS FWXBROWSER

    Local nLin := 0
	Local nAlt := 0
	Local nLar := 0
    Local cDes := ""
    Local oWnd := Nil
    Local oDlg := Nil

    Local aBmp[ Len( ::aStatus ) ]

    oWnd := FWXWindow():New( @oDlg, "Legenda", ( 12 * ( Len( ::aStatus ) + 2 ) ) + 45, 175 )

        nAlt := oWnd:GetAlt()
		nLar := oWnd:GetLar()

        For nLin := 1 To Len( ::aStatus )
			@ ( nLin * 12 ), 012 BITMAP aBmp[nLin] RESNAME ::aStatus[nLin,1] OF oDlg SIZE 12,12 PIXEL NOBORDER
			aBmp[nLin]:lStretch := .T.
            cDes := ::aStatus[nLin,3]
            &( "TSay():New( ( nLin * 12 ) + 2.5, 30, {|| '" + cDes + "' }, oDlg,,,,,, .T.,,, 200, 20 )" )
        Next nLin
        nLin := Len( ::aStatus )

        oWnd:AddButton( "Fechar" , {|| oWnd:Close() }, 2, 2 )

    oWnd:Activate()

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At
Retorna o número linha posicionada no browser.

@author Ivan Haponczuk
@since 17/11/2020
@version 1.0

@return number, Número da linha posicionada no browser.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD At() CLASS FWXBROWSER
RETURN ( ::oBrowse:At() )

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetColumn
Retorna um objeto FWBrwColumn de acordo com os parâmetros informados.

@author Ivan Haponczuk
@since 06/04/2020
@version 1.0

@param bVar, codeblock, Valor a ser apresentado no campo.
@param cTit, character, Título da coluna.
@param cTip, character, Tipo do conteúdo do campo.
@param nTam, number, Tamanho da coluna.
@param nDec, number, Quantidade de decimais do campo.
@param cPic, character, Picture de apresentação do campo.
@param nAlg, number, Alinhamento do conteúdo do campo.
@param bHed, codeblock, Ação ao clicar no cabeçalho da coluna.

@return object, Objeto FWBrwColumn da coluna.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function GetColumn( bVar, cTit, cTip, nTam, nDec, cPic, nAlg, bHed )

	Local oCol := Nil

    Default bHed := {|| }
	Default nAlg := 1

	oCol := FWBrwColumn():New()
    oCol:bHeaderClick := bHed
	oCol:bData        := bVar
	oCol:cTitle       := cTit
	oCol:cType        := cTip
	oCol:nSize        := nTam
	oCol:nDecimal     := nDec
	oCol:xPicture     := cPic
	oCol:nAlign       := nAlg

	If ( cTip == "I"  )
		oCol:cType  := "@BMP"
		oCol:lImage := .T.
	EndIf

Return ( oCol )

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} KeyBlock
Função que recebe as teclar digitadas no browse.

@author Ivan Haponczuk
@since 17/02/2022
@version 1.0

@param oBrw, object, Objeto do browse.
@param cKey, character, Código da tecla apertada.

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function KeyBlock( oBrw, cKey )

    If ( oBrw:At() <= 0 )
        Return Nil
    EndIf

    Do Case
        
        Case ( cKey == 3 )

            CopytoClipboard( All2Str( Eval( oBrw:aColumns[oBrw:ColPos()]:bData ) ) )

    EndCase

Return Nil

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} All2Str
Converte qualquer tipo de variável para texto.

@author Ivan Haponczuk
@since 18/06/2020
@version 1.0

@param xVar, undefined, Varável a ser convertida para texto.

@return character, Retorna a variável convertida para texto.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function All2Str( xVar )

	Local cRet := ""
	
	Do Case
		Case ValType( xVar ) == "C"
			cRet := xVar
		Case ValType( xVar ) == "N"
			cRet := StrTran( AllTrim( Str( xVar ) ), ".", "," )
		Case ValType( xVar ) == "D"
			cRet := DTOS( xVar )
		Case ValType( xVar ) == "L"
			cRet := If( xVar, ".T.", ".F." )
		OtherWise
			cRet := "ERRO"
	EndCase

Return AllTrim( cRet )
