#INCLUDE "TOTVS.CH"

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FWXWINDOW
Cria uma tela padronizada para apresentação de informações.

@author Ivan Haponczuk
@since 17/11/2020
@version 1.0

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
CLASS FWXWINDOW

    DATA oWindow
    DATA oMnuBar

    METHOD New( oDlg, cTit, nAlt, nLar, lEsc, lCls ) CONSTRUCTOR
    METHOD Activate()
    METHOD Close()
    METHOD AddButton( cDes, bAct, nAli, nCol )
    METHOD AddMenu( aMnu )
    METHOD GetAlt()
    METHOD GetLar()

ENDCLASS

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Instancia o objeto e cria a tela.

@author Ivan Haponczuk
@since 17/11/2020
@version 1.0

@param oDlg, object, Variável na qual será armazenado o painel principal da tela.
@param cTit, character, Título da tela.
@param nAlt, number, Altura da tela.
@param nLar, number, Largura da tela.
@param lEsc, boolean, Define se a tela pode ser fechada com esc.

@return object, Retorna o objeto instanciado.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD New( oDlg, cTit, nAlt, nLar, lEsc, lCls ) CLASS FWXWINDOW

    Local oSize := FwDefSize():New( .F. )
    Local nMaxA := ( oSize:aWindSize[3] / 2 ) + 4
    Local nMaxL := ( oSize:aWindSize[4] / 2 ) + 1

    Default nAlt := 0
    Default nLar := 0
    Default cTit := ""
    Default lEsc := .F.
    Default lCls := .F.

    If ( nAlt == 0 )
        nAlt := nMaxA
    EndIf
    If ( nAlt > nMaxA )
        nAlt := nMaxA
    EndIf
    If ( nAlt < 0 )
        nAlt := nMaxA + nAlt
    EndIf
    If ( nAlt < 1 )
        nAlt := nMaxA * nAlt
    EndIf

    If ( nLar == 0 )
        nLar := nMaxL
    EndIf
    If ( nLar > nMaxL )
        nLar := nMaxL
    EndIf
    If ( nLar < 0 )
        nLar := nMaxL + nLar
    EndIf
    If ( nLar < 1 )
        nLar := nMaxL * nLar
    EndIf

	::oWindow := FWDialogModal():New()
	::oWindow:SetSize( nAlt, nLar )
	::oWindow:SetBackground( .T. )
    ::oWindow:lCloseButton := lCls
    ::oWindow:SetEscClose( lEsc )

    If !( Empty( cTit ) )
        ::oWindow:SetTitle( cTit )
    ElseIf ( lCls )
        ::oWindow:lPanelTitle := .T.
    EndIf

	::oWindow:CreateDialog()
    oDlg := ::oWindow:getPanelMain()

    nAlt := ( ::oWindow:oOwner:nHeight / 2 ) - 27
    nLar := ( ::oWindow:oOwner:nWidth / 2 ) - 10
    ::oMnuBar := FWXMenuBar():New( nAlt, 010, nLar, 017, ::oWindow:oOwner )

RETURN SELF

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Activate
Ativa a tela e a apresenta.

@author Ivan Haponczuk
@since 17/11/2020
@version 1.0

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD Activate() CLASS FWXWINDOW

    ::oWindow:Activate()

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Close
Fecha a tela.

@author Ivan Haponczuk
@since 17/11/2020
@version 1.0

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD Close() CLASS FWXWINDOW

    ::oWindow:Deactivate()

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AddButton
Adiciona um botão na barra de menu.

@author Ivan Haponczuk
@since 16/11/2020
@version 1.0

@param cDes, character, Texto do botão.
@param bAct, codeblock, Código a ser executado ao clicar no botão.
@param nAli, number, Alinhamento do botão.
@param nCol, number, Cor do botão.
@param aSub, array, Vetor com os subitens do menu.

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD AddButton( cDes, bAct, nAli, nCol, aSub ) CLASS FWXWINDOW

    ::oMnuBar:AddButton( cDes, bAct, nAli, nCol, aSub )

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AddMenu
Adiciona uma lista de opções na barra de menu.

@author Ivan Haponczuk
@since 24/03/2021
@version 1.0

@param aMnu, array, Vetor com as opções a serem adicionadas a barra de menu.

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD AddMenu( aMnu ) CLASS FWXWINDOW

    ::oMnuBar:AddMenu( aMnu )

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetAlt
Retorna a altura do painel principal da tela.

@author Ivan Haponczuk
@since 17/11/2020
@version 1.0

@return number, Retorna a altura do painel principal da tela.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD GetAlt() CLASS FWXWINDOW

    Local oDlg := ::oWindow:getPanelMain()

RETURN ( oDlg:nHeight / 2 )

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetLar
Retorna a largura do painel principal da tela.

@author Ivan Haponczuk
@since 17/11/2020
@version 1.0

@return number, Retorna a largura do painel principal da tela.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD GetLar() CLASS FWXWINDOW

    Local oDlg := ::oWindow:getPanelMain()

RETURN ( oDlg:nWidth / 2 )
