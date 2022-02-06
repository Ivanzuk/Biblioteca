#INCLUDE "TOTVS.CH"

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FWXFIELD
Objeto para armazenar as propriedades de um campo.

@author Ivan Haponczuk
@since 18/02/2020
@version 1.0

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
CLASS FWXFIELD

    DATA cCmp
    DATA cTit
    DATA cTip
    DATA nTam
    DATA nDec
    DATA cPic
    DATA aOpc
    DATA aCod
    DATA bVal
    DATA xIni
    DATA xCon
    DATA bGat
    DATA bBlq
    DATA lVis
    DATA nAlg
    DATA bChg
    DATA lAct

    METHOD New() CONSTRUCTOR
    METHOD SetOpcoes( aOpc )
    METHOD GetIni()
    METHOD GerPic()

ENDCLASS

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Instancia um objeto para armazenar as propriedades de um campo.

@author Ivan Haponczuk
@since 18/02/2020
@version 1.0

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD New() CLASS FWXFIELD

    ::cCmp := ""
    ::cTit := ""
    ::cTip := ""
    ::nTam := 0
    ::nDec := 0
    ::cPic := Nil
    ::aOpc := {}
    ::aCod := {}
    ::bVal := Nil
    ::xIni := Nil
    ::xCon := Nil
    ::bGat := Nil
    ::bBlq := Nil
    ::lVis := Nil
    ::nAlg := Nil
    ::bChg := Nil
    ::lAct := .T.

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetOpcoes
Define as opções de seleção do campo.

@author Ivan Haponczuk
@since 03/03/2021
@version 1.0

@param aOpc, array, Array com as opções de seleção a serem definidas para o campo.

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD SetOpcoes( aOpc ) CLASS FWXFIELD

    Local nOpc := 0
    Local aCod := {}
    Local aDes := {}

    Default aOpc := {}

    If ( Len( aOpc ) > 0 )

        For nOpc := 1 To Len( aOpc )
            If ( ValType( aOpc[nOpc] ) == "A" )
                aAdd( aCod, aOpc[nOpc,1] )
                aAdd( aDes, aOpc[nOpc,2] )
            Else
                aAdd( aDes, aOpc[nOpc] )
            EndIf
        Next nOpc

        aOpc := aDes

    EndIf

    ::aCod := aCod
    ::aOpc := aOpc

    If ( ValType( ::bChg ) == "B" )
        EVAL( ::bChg )
    EndIf

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetIni
Retorna um inicializador padrão para o campo de acordo com suas propriedades.

@author Ivan Haponczuk
@since 18/02/2020
@version 1.0

@return xRet, Retorna um inicializador padrão para o campo de acordo com suas propriedades.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD GetIni() CLASS FWXFIELD

    Local xRet := Nil

    xRet := ::xIni

    If ( ValType( xRet ) <> ::cTip )
        xRet := Nil
    EndIf

    If ( ValType( xRet ) == "U" )

        Do Case

            Case ( ::cTip == "C" )

                xRet := Space( ::nTam )

            Case ( ::cTip == "N" )

                xRet := 0

            Case ( ::cTip == "D" )

                xRet := STOD( "" )

            Case ( ::cTip == "L" )

                xRet := .F.

        EndCase

    EndIf

RETURN ( xRet )

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GerPic
Define um picture padrão para o campo de acordo com as suas propriedades.

@author Ivan Haponczuk
@since 18/02/2020
@version 1.0

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD GerPic() CLASS FWXFIELD

    Local nPos := 0
    Local nTri := 0
    Local cPic := ""
    Local nTam := ::nTam
    Local nDec := ::nDec

    If ( ::cTip == "N" )

        cPic := Replicate( "9", nDec )
        If !( Empty( cPic ) )
            cPic := "." + cPic
            nTam := nTam - ( nDec + 1 )
        EndIf

        For nPos := 1 To nTam
            If ( nTri == 3 )
                cPic := "," + cPic
                nTri := 0
            EndIf
            cPic := "9" + cPic
            nTri++
        Next nPos
        cPic := "@E " + cPic

    EndIf

    ::cPic := cPic

Return Nil
