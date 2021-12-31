#INCLUDE "TOTVS.CH"

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FWXMENUBAR
Cria uma barra de menu com botões.

@author Ivan Haponczuk
@since 16/11/2020
@version 1.0

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
CLASS FWXMENUBAR

    DATA nPosTop
    DATA nPosLef
    DATA nTamLar
    DATA nTamAlt
    DATA nTamBtn
    DATA nSpcBtn
    DATA oWindow
	
	METHOD New( nTop, nLef, nLar, nAlt, oDlg, nTam, nSpc ) CONSTRUCTOR
    METHOD AddButton( cDes, bAct, nAli, nCol, aSub )
	METHOD AddMenu( aMnu )
	
ENDCLASS

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Cria o objeto de barra de menu.

@author Ivan Haponczuk
@since 16/11/2020
@version 1.0

@param nTop, number, Coordenada do topo da barra de menu.
@param nLef, number, Coordenada da esquerda da barra de menu.
@param nLar, number, Largura total da barra de menu.
@param nAlt, number, Altura total da barra de menu.
@param oDlg, object, Painel ou tela onde será apresentado o menu.
@param nTam, number, Tamanho da largura dos botões.
@param nSpc, number, Tamanho do espaço entre os botões.

@return self
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD New( nTop, nLef, nLar, nAlt, oDlg, nTam, nSpc ) CLASS FWXMENUBAR

    Default nTam := 55
    Default nSpc := 5

    ::nPosTop := nTop
    ::nPosLef := nLef
    ::nTamLar := nLar - nTam
    ::nTamAlt := nAlt
    ::nTamBtn := nTam
    ::nSpcBtn := nSpc
    ::oWindow := oDlg

RETURN SELF

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
METHOD AddButton( cDes, bAct, nAli, nCol, aSub ) CLASS FWXMENUBAR

    Local nPos := 0
    Local oBtn := Nil

    Default bAct := {|| }
    Default nAli := 1
    Default nCol := 0
	Default aSub := {}

    Do Case

        Case ( nAli == 2 )

            nPos := ::nTamLar
            ::nTamLar -= ::nTamBtn + ::nSpcBtn

        OtherWise

            nPos := ::nPosLef
            ::nPosLef += ::nTamBtn + ::nSpcBtn

    EndCase

    oBtn := tButton():New( ::nPosTop, nPos, cDes, ::oWindow, bAct, ::nTamBtn, ::nTamAlt,,,, .T. )
    oBtn:SetCSS( GetCSS( nCol ) )

	If ( Len( aSub ) > 0 )
		oBtn:setPopupMenu( GetSubMnu( aSub ) )
	EndIf

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AddMenu
Adiciona um lista de botões na barra de menu.

@author Ivan Haponczuk
@since 24/03/2021
@version 1.0

@param aMnu, array, Vetor com as opções a serem adicionadas a barra de menu.

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD AddMenu( aMnu ) CLASS FWXMENUBAR

	Local nItm := 0
	Local nSub := 0
	Local aSub := {}

	For nItm := 1 To Len( aMnu )
		If ( ValType( aMnu[nItm,2] ) == "A" )

			aSub := {}
			For nSub := 1 To Len( aMnu[nItm,2] )
				aAdd( aSub, { aMnu[nItm,2,nSub,6], aMnu[nItm,2,nSub,1], aMnu[nItm,2,nSub,2] } )
			Next nSub

			::AddButton( aMnu[nItm,1], {|| }, 1, aMnu[nItm,5], aSub )

		Else

			::AddButton( aMnu[nItm,1], aMnu[nItm,2], 1, aMnu[nItm,5] ) 
			
		EndIf
	Next nItm

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetSubMnu
Retorna o menu popup com as opções informadas para ser aplicado no botão como um submenu.

@author Ivan Haponczuk
@since 15/10/2019
@version 1.0

@param aItm, array, Vetor com as informações dos itens a serem disponibilizado no menu.

@return object, Objeto do tipo TMenu para ser anexado ao botão.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function GetSubMnu( aItm )

	Local nLin := 0
	Local oMnu := Nil
	Local oItm := Nil

	oMnu := tMenu():New( 000, 000, 000, 000, .T. ) 
	
	For nLin := 1 To Len( aItm )
		oItm := tMenuItem():New( oMnu, aItm[nLin,2],,,, aItm[nLin,3],, aItm[nLin,1],,,,,,, .T. )
		oMnu:Add( oItm )
	Next nLin

Return ( oMnu )

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetCSS
Retorna o CSS do botão de acordo com os parâmetros.

@author Ivan Haponczuk
@since 15/10/2019
@version 1.0

@param nCor, number, Define a cor do botão: 1 = Azul, 2 = Vermelho; Padrão: 1
@param cImg, character, Imagem de ícone do RPO a ser apresentado no botão.

@return character, CSS a ser aplicado no botão.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function GetCSS( nCor, cImg )

	Local cCSS := ""
	
	Local cText := ""
	Local cCor0 := ""
	Local cCor1 := ""
	Local cCor2 := ""
	Local cCor3 := ""
	Local cCor4 := ""
	Local cArow := ""
	
	Default nCor := 0
	Default cImg := ""
	
	Do Case
	
		Case ( nCor == 1 ) // Azul
		
			cText := "#FFFFFF"
			cCor0 := "#369cb5"
			cCor1 := "#39afcc"
			cCor2 := "#0f9cbf"
			cCor3 := "#3badca"
			cCor4 := "#148aa8"
			cArow := "GEOARROWDPW.PNG"
			
		Case ( nCor == 2 ) // Vermelho
		
			cText := "#FFFFFF"
			cCor0 := "#b5363c"
			cCor1 := "#ca393e"
			cCor2 := "#bf0f15"
			cCor3 := "#c8393e"
			cCor4 := "#a71318"
			cArow := "GEOARROWDPW.PNG"
			
		OtherWise // Cinza
		
			cText := "#4f545e"
			cCor0 := "#d8d8d8"
			cCor1 := "#fdfdfd"
			cCor2 := "#e7e7e7"
			cCor3 := "#fcfcfc"
			cCor4 := "#c8cbcc"
			cArow := "GEOARROWDP.PNG"
	
	EndCase
	
	cCSS := " QPushButton {"
	cCSS += "  color: " + cText + ";"
	cCSS += "  border: 1px solid " + cCor0 + ";"
	cCSS += "  border-radius: 3px;"
	cCSS += "  font-family: 'Verdana';"
	cCSS += "  font-size: 12px;"
	cCSS += "  background-color: qlineargradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 " + cCor1 + ", stop: 1 " + cCor2 + " );"
	If !Empty( cImg )
		cCSS += "  qproperty-icon: url(rpo:" + cImg + ".png);"
		cCSS += "  qproperty-iconSize: 20px 20px;"
	EndIf
	cCSS += " }"
	cCSS += " QPushButton:hover {"
	cCSS += "  background-color: qlineargradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 " + cCor3 + ", stop: 1 " + cCor4 + " );"
	cCSS += " }"
	cCSS += " QPushButton:pressed {"
	cCSS += "  background-color: qlineargradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 " + cCor4 + ", stop: 1 " + cCor3 + " );"
	cCSS += " }"
	cCSS += " QPushButton::menu-indicator {"
	cCSS += "  image: url(rpo:" + cArow + ");"
	cCSS += "  subcontrol-position: right center;"
	cCSS += "  subcontrol-origin: padding;"
	cCSS += "  left: -7px;"
	cCSS += " }"

Return ( cCSS )
