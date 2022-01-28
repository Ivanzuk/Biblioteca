#INCLUDE "TOTVS.CH"

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FWXIMAGE
Objeto para visualização e manipulação de imagens.

@author Ivan Haponczuk
@since 28/01/2022
@version 1.0

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
CLASS FWXIMAGE

    DATA cImagem
    DATA lImgShw
    DATA oImgShw
    DATA nShwAlt
    DATA nShwLar

    METHOD New( cImg ) CONSTRUCTOR
    METHOD Show( nTop, nLef, nAlt, nLar, oDlg )
    METHOD SetImage( cImg )
    METHOD GetSize()

ENDCLASS

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Cria e instancia do objeto de visualização e manipulação de imagens.

@author Ivan Haponczuk
@since 28/01/2022
@version 1.0

@param cImg, character, Local, nome e extensão da imagem.

@return object, Retorna o objeto de formulÃ¡rio.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD New( cImg ) CLASS FWXIMAGE

    ::cImagem := cImg
    ::lImgShw := .F.

RETURN SELF

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Show
Apresenta a imagem na tela.

@author Ivan Haponczuk
@since 28/01/2022
@version 1.0

@param nTop, number, Coordenada do topo do formulÃ¡rio.
@param nLef, number, Coordenada da esquerda do formulÃ¡rio.
@param nLar, number, Largura do formulÃ¡rio.
@param nAlt, number, Altura do formulÃ¡rio.
@param oDlg, object, Tela onde serÃ¡ apresentado o formulÃ¡rio.

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD Show( nTop, nLef, nAlt, nLar, oDlg ) CLASS FWXIMAGE

    Local oPnl := Nil

    ::lImgShw := .T.
    ::nShwAlt := nAlt
    ::nShwLar := nLar

    oPnl := tPanel():New( nTop, nLef, "", oDlg,, .T.,,,, nLar, nAlt )
    oPnl:SetCSS( " TPanel{ background-color : rgb( 245, 245, 245 ); }")

    ::oImgShw := TBitmap():New( 000, 000, 000, 000,,, .T., oPnl, {|| },, .F., .F.,,, .F.,, .T.,, .F. )
    ::oImgShw:lTransparent := .T.
    ::oImgShw:lAutoSize := .T.
    ::oImgShw:lStretch := .T.

    ::SetImage( ::cImagem )

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetImage
Define a imagem a ser visualizada ou manipulada.

@author Ivan Haponczuk
@since 28/01/2022
@version 1.0

@param cImg, character, Local, nome e extensão da imagem.

@return nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD SetImage( cImg ) CLASS FWXIMAGE

    Local nAlt := 0
    Local nLar := 0
    Local nPer := 0
    Local aTam := {}

    ::cImagem := cImg

    If ( ::lImgShw )

        aTam := ::GetSize( cImg )

        nAlt := aTam[1]
        nLar := aTam[2]

        If ( aTam[1] > ::nShwAlt )
            nPer := ::nShwAlt / aTam[1]
            nAlt := ::nShwAlt
            nLar := aTam[2] * nPer
        EndIf

        If ( nLar > ::nShwLar )
            nPer := ::nShwLar / aTam[2]
            nLar := ::nShwLar
            nAlt := aTam[1] * nPer
        EndIf

        ::oImgShw:Move( 002, 002, ( nLar * 2 ) - 4, ( nAlt * 2 ) - 4 )
        ::oImgShw:Load( Nil, cImg )

    EndIf

RETURN NIL

//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetSize
Retorna o tamanho da imagem

@author Ivan Haponczuk
@since 28/01/2022
@version 1.0

@return array, Vetor com a altura e largura da imagem.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------------------
METHOD GetSize() CLASS FWXIMAGE

    Local aRet := {}
    Local oImg := Nil
     
    oImg := TBitmap():New( -10000, -10000,,,, ::cImagem )
    oImg:lAutoSize := .T.
    oImg:Hide()
     
    aAdd( aRet, oImg:nClientHeight ) // Altura
    aAdd( aRet, oImg:nClientWidth  ) // Largura

    FreeObj( oImg )

RETURN ( aRet )
