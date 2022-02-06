#INCLUDE "TOTVS.CH"

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FWXFORM
Cria um formulário de campos.

@author Ivan Haponczuk
@since 18/02/2021
@version 1.0

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
CLASS FWXFORM

    DATA nLarMax
    DATA oScroll
    DATA lScroll
    DATA oMPanel
    DATA aFields
    DATA aCampos
    DATA nOperac
    DATA bFrmVal

    METHOD New( nTop, nLef, nAlt, nLar, oDlg, nOPC, bVal ) CONSTRUCTOR
    METHOD AddLin( nLin, cCmp, cTit, cTip, nTam, nDec, cPic, aOpc, xIni, nAlg, bBlq, bGat, xCon, lVis )
    METHOD AddField( oCmp, nLin )
    METHOD Show()
    METHOD AddObject()
    METHOD bSetGet( nLin, nCol, xVar )
    METHOD GetField( cCmp )
    METHOD Get( cCmp )
    METHOD Set( cCmp, xVal )
    METHOD RefreshField( cCmp )
    METHOD Valid()

ENDCLASS

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Cria e instancia o formulário a ser apresentado.

@author Ivan Haponczuk
@since 18/02/2021
@version 1.0

@param nTop, number, Coordenada do topo do formulário.
@param nLef, number, Coordenada da esquerda do formulário.
@param nLar, number, Largura do formulário.
@param nAlt, number, Altura do formulário.
@param oDlg, object, Tela onde será apresentado o formulário.
@param bVal, codeblock, Bloco de código de validação do formulário.

@return object, Retorna o objeto de formulário.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD New( nTop, nLef, nAlt, nLar, oDlg, nOPC, bVal ) CLASS FWXFORM

    Default nOPC := 0
    Default bVal := {|| .T. }

    ::lScroll := .F.
    ::nLarMax := nLar

    ::oScroll := TScrollBox():New( oDlg, nTop, nLef, nAlt, nLar, .T., .F., .F. )
    ::oMPanel := tPanel():New( 000, 000, "", ::oScroll,, .T.,,,, 000, 000 )
    ::nOperac := nOPC
    ::bFrmVal := bVal
    ::aFields := {}
    ::aCampos := {}

RETURN SELF

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AddLin
Adiciona um campo a uma determinada linha do formulário.

@author Ivan Haponczuk
@since 18/02/2021
@version 1.0

@param nLin, number, Linha a ser adicionado o campo, caso não informado ou informado 0 o formulário irá distribuir automáticamente.
@param cCmp, character, Nome do campo.
@param cTit, character, Título do campo.
@param cTip, character, Tipo do campo.
@param nTam, number, Tamanho do campo.
@param nDec, number, Quantidade de decimais do campo.
@param cPic, character, Picture do campo.
@param aOpc, array, Lista de opções do campo.
@param xIni, undefined, Inicializador padrão do campo.
@param nAlg, number, Alinhamento do campo.
@param bBlq, codeblock, Bloco de código que define se o campo está bloqueado ou não.
@param bGat, codeblock, Bloco de código a ser executado após a alteração do conteúdo do campo.
@param xCon, undefined, Define a consulta padrão do campo ou bloco de código a ser executado como consulta.
@param lVis, boolean, Define se o campo será somente visualização.

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD AddLin( nLin, cCmp, cTit, cTip, nTam, nDec, cPic, aOpc, xIni, nAlg, bBlq, bGat, xCon, lVis ) CLASS FWXFORM

    Local oCmp := FWXFIELD():New()

    If ( ::nOperac == 2 )
        lVis := .T.
    EndIf

    If ( ::nOperac == 5 )
        bBlq := {|| .F. }
    EndIf

    oCmp:cCmp := cCmp
    oCmp:cTit := cTit
    oCmp:cTip := cTip
    oCmp:nTam := nTam
    oCmp:nDec := nDec
    oCmp:cPic := cPic
    oCmp:xIni := xIni
    oCmp:nAlg := nAlg
    oCmp:bBlq := bBlq
    oCmp:bGat := bGat
    oCmp:xCon := xCon
    oCmp:lVis := lVis
    oCmp:SetOpcoes( aOpc )

    ::AddField( oCmp, nLin )

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AddField
Adiciona um campo no formulário.

@author Ivan Haponczuk
@since 18/02/2021
@version 1.0

@param oCmp, object, Objeto do campo do tipo FWXFIELD.
@param nLin, number, Linha a ser adicionado o campo.

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD AddField( oCmp, nLin ) CLASS FWXFORM

    Local nPos := 0
    Local cCmp := ""
    Local aCmp := {}

    Default nLin := 0

    If ( nLin > Len( ::aFields ) )

        For nPos := ( Len( ::aFields ) + 1 ) To nLin
            aAdd( ::aFields, {} )
        Next nPos

    EndIf

    If ( oCmp:cTip == "N" .And. Empty( oCmp:cPic ) )
        oCmp:GerPic()
    EndIf

    aAdd( aCmp, oCmp          ) // 1 - Objeto com os dados do campo
    aAdd( aCmp, Nil           ) // 2 - Objeto visual do campo
    aAdd( aCmp, oCmp:GetIni() ) // 3 - Conteúdo do campo
    aAdd( ::aFields[nLin], aCmp )

    cCmp := Upper( AllTrim( oCmp:cCmp ) )
    nCol := Len( ::aFields[nLin] )

    oCmp:bChg := &( '{|| SELF:RefreshField( "' + oCmp:cCmp + '" ) }' )

    aAdd( ::aCampos, { cCmp, nLin, nCol } )

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Show
Monta e apresenta o browser.

@author Ivan Haponczuk
@since 18/02/2021
@version 1.0

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD Show() CLASS FWXFORM

    Local nLin := 0
    Local nCol := 0
    Local aFld := {}

    Local nLarMax := 0
    Local nBoxQnt := 0
    Local nBoxLin := 0
    Local nSpcQnt := 0
    Local nLarTot := 0
    Local nPosLin := 0
    Local nPosCol := 0
    Local nColLar := 0
    Local nColAlt := 0

    FreeObj( ::oMPanel )
    ::oMPanel := tPanel():New( 000, 000, "", ::oScroll,, .T.,,,, 000, 000 )

    nLarMax := ( ::nLarMax - 10 )
    If ( ::lScroll )
        nLarMax -= 10
    EndIf
    nBoxQnt := Int( nLarMax / 5 )

    aFld := ::aFields
    For nLin := 1 To Len( aFld )

        nLarTot := 0
        nColAlt := 0
        nSpcQnt := 0
        nBoxLin := nBoxQnt

        For nCol := 1 To Len( aFld[nLin] )
            nLarTot += LarCal( aFld[nLin,nCol,1] )
            If ( AltCal( aFld[nLin,nCol,1] ) > nColAlt )
                nColAlt := AltCal( aFld[nLin,nCol,1] )
            EndIf
            nSpcQnt++
        Next nCol

        If ( nSpcQnt > 0 )
            nSpcQnt--
            nBoxLin -= nSpcQnt
        EndIf

        nPosCol := 0
        For nCol := 1 To Len( aFld[nLin] )

            If ( nCol <> Len( aFld[nLin] ) )

                nColLar := LarCal( aFld[nLin,nCol,1] )
                nColLar := ( nColLar / nLarTot )
                nColLar := Round( nColLar * nBoxLin, 0 )
                nColLar := ( nColLar * 5 )

            Else
                
                nColLar := ( nLarMax - nPosCol ) + 1

            EndIf

            ::AddObject( nLin, nCol, nPosLin, nPosCol, nColLar, nColAlt )

            nPosCol += ( nColLar + 4 )

        Next nCol

        nPosLin += ( nColAlt + 5 )

    Next nLin

    ::oMPanel:Move( 010, 010, ( nLarMax * 2 ), ( nPosLin * 2 ) )

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AddObject
Adiciona o objeto visual do campo no formulário.

@author Ivan Haponczuk
@since 18/02/2021
@version 1.0

@param nLin, number, Número da linha do campo.
@param nCol, number, Número da coluna do campo.
@param nTop, number, Coordenada do topo do campo.
@param nLef, number, Coordenada da esquerda do campo.
@param nLar, number, Largura do campo.
@param nAlt, number, Altura do campo.

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD AddObject( nLin, nCol, nTop, nLef, nLar, nAlt ) CLASS FWXFORM

    Local cCmp := ""
    Local xIni := Nil
    Local bGet := Nil
    Local oObj := Nil
    Local oCmp := ::aFields[nLin,nCol,1]

    Local oF01 := TFont():New( "Arial",, 16,, .F.,,,,, .F. )

    If ( !Empty( oCmp:cTit ) .And. !( oCmp:cTip $ "L|B" ) )

        TSay():New( nTop, nLef, {|| '<font size="4" face="Arial" color="#323232"><b>' + oCmp:cTit + '</b></font>' }, ::oMPanel,,,,,, .T.,,, 300, 020,,,,,, .T. )

    EndIf

    cCmp := "SELF:aFields[" + StrZero( nLin, 2 ) + "," + StrZero( nCol, 2 ) + ",3]"
    bGet := &( "{|U| IF( PCOUNT() == 0, " + cCmp + ", SELF:bSetGet( " + StrZero( nLin, 2 ) + ", " + StrZero( nCol, 2 ) + ", U ) ) }" )

    Do Case

        Case ( Len( oCmp:aOpc ) > 0 )

            xIni := ::aFields[nLin,nCol,3]
            If ( Empty( ::aFields[nLin,nCol,3] ) )
                xIni := oCmp:xIni
            EndIf

            oObj := tComboBox():New( ( nTop + nAlt - 15 ), nLef, bGet, oCmp:aOpc, nLar, 015, ::oMPanel,, oCmp:bGat,,,, .T., oF01,,, oCmp:bBlq,,,,, cCmp )
            oObj:SetHeight( 30 )

            If ( ValType( oCmp:lVis ) == "L" )
                oObj:lReadOnly := oCmp:lVis
                oObj:bWhen := {|| .T. }
            EndIf

            ::aFields[nLin,nCol,2] := oObj
            ::Set( oCmp:cCmp, xIni )

        Case ( oCmp:cTip == "L" )

            oObj := TCheckBox():New( ( nTop + nAlt - 11.5 ), nLef, oCmp:cTit, bGet, ::oMPanel, 500, 200,,,,,,,, .T. )
            ::aFields[nLin,nCol,2] := oObj

        Case ( oCmp:cTip == "B" )

            oObj := tButton():New( ( nTop + nAlt - 15 ), nLef, oCmp:cTit, ::oMPanel, oCmp:bGat, nLar-1, 015,,,, .T. )
            ::aFields[nLin,nCol,2] := oObj

        OtherWise

            If ( oCmp:lAct )
                PTSetAcento( .T. )
            EndIf

            oObj := TGet():New( ( nTop + nAlt - 15 ), nLef, bGet, ::oMPanel, nLar, 013, oCmp:cPic,,,, oF01,,, .T.,,, oCmp:bBlq,,, oCmp:bGat,,, oCmp:xCon )

            If ( oCmp:lAct )
                PTSetAcento( .F. )
            EndIf
            
            If ( ValType( oCmp:nAlg ) == "N" )
                oObj:SetContentAlign( oCmp:nAlg )
            EndIf

            If ( ValType( oCmp:lVis ) == "L" )
                oObj:lReadOnly := oCmp:lVis
            EndIf

            ::aFields[nLin,nCol,2] := oObj

    EndCase

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} bSetGet
Função a ser executada ao alterar o conteúdo de um campo.

@author Ivan Haponczuk
@since 18/02/2021
@version 1.0

@param nLin, number, Número da linha do campo.
@param nCol, number, Número da coluna do campo.
@param xVar, undefined, Conteúdo a ser definido no campo.

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD bSetGet( nLin, nCol, xVar ) CLASS FWXFORM

    Local oCmp := ::aFields[nLin,nCol,1]
    Local oObj := ::aFields[nLin,nCol,2]

    If ( Len( oCmp:aCod ) > 0 )

        If ( ValType( oObj ) == "O" )

            If ( oObj:nAt > 0 )
                xVar := oCmp:aCod[oObj:nAt]
            Else
                xVar := oCmp:GetIni()
            EndIf

        ENdIf

    EndIf

    ::aFields[nLin,nCol,3] := xVar

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetField
Retorna o objeto com os dados do campo.

@author Ivan Haponczuk
@since 03/03/2021
@version 1.0

@param cCmp, character, Nome do campo.

@return object, Retorna o objeto com os dados do campo, caso não encontrado retorna nulo.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD GetField( cCmp ) CLASS FWXFORM

    Local nPos := 0
    Local nLin := 0
    Local nCol := 0

    nPos := aScan( ::aCampos, {|x| x[1] == Upper( AllTrim( cCmp ) ) } )

    If ( nPos > 0 )
        nLin := ::aCampos[nPos,2]
        nCol := ::aCampos[nPos,3]
    Else
        Return Nil
    EndIf

RETURN ( ::aFields[nLin,nCol,1] )

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get
Retorna o conteúdo de um determinado campo.

@author Ivan Haponczuk
@since 18/02/2021
@version 1.0

@param cCmp, character, Nome do campo.

@return undefined, Retorna o conteúdo de um determinado campo.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD Get( cCmp ) CLASS FWXFORM

    Local nPos := 0
    Local nLin := 0
    Local nCol := 0
    Local xRet := Nil

    nPos := aScan( ::aCampos, {|x| x[1] == Upper( AllTrim( cCmp ) ) } )

    If ( nPos > 0 )
        nLin := ::aCampos[nPos,2]
        nCol := ::aCampos[nPos,3]
        xRet := ::aFields[nLin,nCol,3]
    EndIf

RETURN ( xRet )

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Set
Define o conteúdo de um determinado campo.

@author Ivan Haponczuk
@since 18/02/2021
@version 1.0

@param cCmp, character, Nome do campo.
@param xVal, undefined, Conteúdo a ser definido no campo.

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD Set( cCmp, xVal ) CLASS FWXFORM

    Local nPos := 0
    Local nLin := 0
    Local nCol := 0
    Local oCmp := Nil
    Local oObj := Nil

    nPos := aScan( ::aCampos, {|x| x[1] == Upper( AllTrim( cCmp ) ) } )

    If ( nPos > 0 )

        nLin := ::aCampos[nPos,2]
        nCol := ::aCampos[nPos,3]
        oCmp := ::aFields[nLin,nCol,1]
        oObj := ::aFields[nLin,nCol,2]

        ::aFields[nLin,nCol,3] := xVal

        If ( Len( oCmp:aOpc ) > 0 )

            If ( Len( oCmp:aCod ) > 0 )
                nPos := aScan( oCmp:aCod, {|x| AllTrim( x ) == AllTrim( xVal ) } )
            Else
                nPos := aScan( oCmp:aOpc, {|x| AllTrim( x ) == AllTrim( xVal ) } )
            EndIf

            If ( ValType( oObj ) == "O" )
                oObj:Select( nPos )
            EndIf

        Else

            If ( ValType( oCmp:nAlg ) == "N" )
                oObj:Refresh()
                oObj:SetContentAlign( oCmp:nAlg )
            EndIf

        EndIf

    EndIf

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RefreshField
Efetua a atualização do objeto visual de um determinado campo.

@author Ivan Haponczuk
@since 03/03/2021
@version 1.0

@param cCmp, character, Nome do campo.

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD RefreshField( cCmp ) CLASS FWXFORM

    Local nPos := 0
    Local nLin := 0
    Local nCol := 0
    Local oCmp := Nil
    Local oObj := Nil

    nPos := aScan( ::aCampos, {|x| x[1] == Upper( AllTrim( cCmp ) ) } )

    If ( nPos > 0 )

        nLin := ::aCampos[nPos,2]
        nCol := ::aCampos[nPos,3]
        oCmp := ::aFields[nLin,nCol,1]
        oObj := ::aFields[nLin,nCol,2]

        If ( ValType( oObj ) == "O" )

            If ( Len( oCmp:aOpc ) > 0 )
                oObj:SetItems( oCmp:aOpc )
            EndIf

        EndIf

    EndIf

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Valid
Efetua a validação do conteúdo do formulário.

@author Ivan Haponczuk
@since 08/03/2021
@version 1.0

@return boolean, Retorna verdadeiro caso o conteúdo do formulário seja válido, caso contrário retorna falso.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD Valid() CLASS FWXFORM

    Local lRet := EVAL( ::bFrmVal, SELF )

RETURN ( lRet )

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AltCal
Retorna a altura que irá ocupar o campo.

@author Ivan Haponczuk
@since 18/02/2021
@version 1.0

@param oCmp, object, Objeto do campo do tipo FWXFIELD.

@return number, Retorna a altura que irá ocupar o campo.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function AltCal( oCmp )

    Local nAlt := 15

    If ( !Empty( oCmp:cTit ) .And. !( oCmp:cTip $ "L|B" ) )
        nAlt += 10
    EndIf

Return ( nAlt )

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LarCal
Retorna a largura que irá ocupar o campo.

@author Ivan Haponczuk
@since 18/02/2021
@version 1.0

@param oCmp, object, Objeto do campo do tipo FWXFIELD.

@return number, Retorna a largura que irá ocupar o campo.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function LarCal( oCmp )

    Local nLar := 0
    
    nLar := oCmp:nTam
    
    If ( oCmp:cTip == "N" )
        nLar += oCmp:nDec
    EndIf

Return ( nLar )
