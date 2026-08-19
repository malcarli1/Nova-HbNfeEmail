/*****************************************************************************
 * SISTEMA  : GERAL                                                          *
 * PROGRAMA : HbNfeEmail.PRG                                                 *
 * OBJETIVO : Funções e Classes Relativas a NFE (Envio de Email)             *
 * AUTOR    : Fernando Athayde - fernando_athayde@yahoo.com.br               *
 * ALTERADO : Marcelo Antonio Lázzaro Carli                                  *
 * ALTERADO : Franklin Brasil                                                *
 * DATA     : 28.08.2011                                                     *
 * ULT. ALT.: 19.08.2026                                                     *
 *****************************************************************************/
#include "common.ch"
#include "hbclass.ch"
#ifndef __XHARBOUR__
   #include "hbwin.ch"
#Endif

CLASS hbNFeEmail
   DATA ohbNFe

   DATA cSubject
   DATA cMsgTexto
   DATA cMsgHTML
   DATA cServerIP
   DATA cFrom
   DATA cUser
   DATA cPass
   DATA nPortSMTP
   DATA lConf     INIT .F.
   DATA lSSL      INIT .F.
   DATA lAut      INIT .F.
   DATA lTLS      INIT .F.
   DATA aFiles    INIT {}
   DATA aTo
   DATA aCC
   DATA aBCC
   DATA cProvider INIT []
   DATA cLastErro INIT []
   DATA cLastModo INIT []
   DATA nTimeout  INIT 60

   METHOD New()
   METHOD UseGmail()
   METHOD UseMicrosoft365()
   METHOD UseBrevo()
   METHOD UseSMTP()
   METHOD AddTo()
   METHOD AddCC()
   METHOD AddBCC()
   METHOD AddFile()
   METHOD Execute()
   METHOD ExecuteGmailNative()
ENDCLASS

METHOD New() CLASS hbNFeEmail
   ::aFiles   := {}
   ::aTo      := {}
   ::aCC      := {}
   ::aBCC     := {}
   ::lAut     := .T.
   ::lSSL     := .F.
   ::lTLS     := .T.
   ::nPortSMTP:= 587
   ::nTimeout := 60
RETURN Self

METHOD UseGmail( cEmail, cSenhaApp ) CLASS hbNFeEmail
   ::cProvider := [GMAIL]
   ::cServerIP := [smtp.gmail.com]
   ::nPortSMTP := 587
   ::lAut      := .T.
   ::lSSL      := .F.
   ::lTLS      := .T.
   ::cUser     := AllTrim( HbNfeEmailDefault( cEmail, [] ) )
   ::cPass     := AllTrim( HbNfeEmailDefault( cSenhaApp, [] ) )
   ::cFrom     := ::cUser
RETURN Self

METHOD UseBrevo( cSmtpLogin, cSmtpKey, cFrom, nPorta ) CLASS hbNFeEmail
   ::cProvider := [BREVO]
   ::cServerIP := [smtp-relay.brevo.com]
   ::nPortSMTP := HbNfeEmailDefault( nPorta, 587 )
   ::lAut      := .T.
   ::lSSL      := ::nPortSMTP == 465
   ::lTLS      := ! ::lSSL
   ::cUser     := AllTrim( HbNfeEmailDefault( cSmtpLogin, [] ) )
   ::cPass     := AllTrim( HbNfeEmailDefault( cSmtpKey, [] ) )
   IF ! Empty( cFrom )
      ::cFrom  := AllTrim( cFrom )
   ELSE
      ::cFrom  := ::cUser
   ENDIF
RETURN Self

METHOD UseMicrosoft365( cEmail, cSenha ) CLASS hbNFeEmail
   ::cProvider := [MICROSOFT365]
   ::cServerIP := [smtp.office365.com]
   ::nPortSMTP := 587  // se não funcionar use 25
   ::lAut      := .T.
   ::lSSL      := .T.
   ::lTLS      := .T.
   ::cUser     := AllTrim( HbNfeEmailDefault( cEmail, [] ) )
   ::cPass     := AllTrim( HbNfeEmailDefault( cSenha, [] ) )
   ::cFrom     := ::cUser
RETURN Self

METHOD UseSMTP( cServer, nPorta, cUsuario, cSenha, lSSL, lTLS ) CLASS hbNFeEmail
   ::cProvider := [SMTP]
   ::cServerIP := AllTrim( HbNfeEmailDefault( cServer, [] ) )
   ::nPortSMTP := HbNfeEmailDefault( nPorta, 587 )
   ::cUser     := AllTrim( HbNfeEmailDefault( cUsuario, [] ) )
   ::cPass     := AllTrim( HbNfeEmailDefault( cSenha, [] ) )
   ::lAut      := ! Empty( ::cUser )
   ::lSSL      := HbNfeEmailDefault( lSSL, .F. )
   ::lTLS      := HbNfeEmailDefault( lTLS, .T. )
   IF Empty( ::cFrom )
      ::cFrom  := ::cUser
   ENDIF
RETURN Self

METHOD AddTo( cEmail ) CLASS hbNFeEmail
   IF ValType( ::aTo ) != [A]
      ::aTo := {}
   ENDIF
   IF ValType( cEmail ) == [A]
      AEval( cEmail, {|c| ::AddTo( c ) } )
   ELSEIF ! Empty( cEmail )
      AAdd( ::aTo, AllTrim( cEmail ) )
   ENDIF
RETURN Self

METHOD AddCC( cEmail ) CLASS hbNFeEmail
   IF ValType( ::aCC ) != [A]
      ::aCC := {}
   ENDIF
   IF ValType( cEmail ) == [A]
      AEval( cEmail, {|c| ::AddCC( c ) } )
   ELSEIF ! Empty( cEmail )
      AAdd( ::aCC, AllTrim( cEmail ) )
   ENDIF
RETURN Self

METHOD AddBCC( cEmail ) CLASS hbNFeEmail
   IF ValType( ::aBCC ) != [A]
      ::aBCC := {}
   ENDIF
   IF ValType( cEmail ) == [A]
      AEval( cEmail, {|c| ::AddBCC( c ) } )
   ELSEIF ! Empty( cEmail )
      AAdd( ::aBCC, AllTrim( cEmail ) )
   ENDIF
RETURN Self

METHOD AddFile( cArquivo ) CLASS hbNFeEmail
   IF ValType( ::aFiles ) != [A]
      ::aFiles := {}
   ENDIF
   IF ValType( cArquivo ) == [A]
      AEval( cArquivo, {|c| ::AddFile( c ) } )
   ELSEIF ! Empty( cArquivo )
      AAdd( ::aFiles, AllTrim( cArquivo ) )
   ENDIF
RETURN Self

METHOD Execute() CLASS hbNFeEmail
   Local aRetorno:= {=>}, oCfg, oMsg, oError, nITo, nIFiles, cArgs, cFileName, nXa, cArg, oRetorno

   IF ::cProvider == [GMAIL]
      RETURN ::ExecuteGmailNative()
   ENDIF

   If Valtype(::aTo) == [C]
      ::aTo:= {::aTo}
   ElseIf ValType(::aTo) != [A]
      ::aTo:= {}
   Endif
   If Valtype(::aCC) == [C]
      ::aCC:= {::aCC}
   ElseIf ValType(::aCC) != [A]
      ::aCC:= {}
   Endif
   If Valtype(::aBCC) == [C]
      ::aBCC:= {::aBCC}
   ElseIf ValType(::aBCC) != [A]
      ::aBCC:= {}
   Endif
   If Valtype(::aFiles) == [C]
      ::aFiles:= {::aFiles}
   ElseIf ValType(::aFiles) != [A]
      ::aFiles:= {}
   Endif
   If Len(::aTo) == 0
      aRetorno["OK"]:= .F.
      aRetorno["MsgErro"]:= [Nenhum destinatario informado]
      Return(aRetorno)
   Endif
   If ::cSubject == Nil
      ::cSubject:= []
   Endif
   If ::cMsgTexto == Nil
      ::cMsgTexto:= []
   Endif
   If ::cMsgHTML == Nil
      ::cMsgHTML:= []
   Endif
   If ::cServerIP == Nil
      ::cServerIP:= []
   Endif
   If ::cFrom == Nil
      ::cFrom:= ::cUser
   Endif
   If ::cUser == Nil
      ::cUser:= []
   Endif
   If ::cPass == Nil
      ::cPass:= []
   Endif
   If ::nPortSMTP == Nil
      ::nPortSMTP:= 587
   Endif

   // preparar
   BEGIN SEQUENCE WITH {|oErr| Break(oErr)}
     #ifdef __XHARBOUR__
        oCfg:= xhb_CreateObject("CDO.Configuration")
     #Else
        oCfg:= win_oleCreateObject("CDO.Configuration")
     #Endif
     WITH OBJECT oCfg:Fields
       :Item("http://schemas.microsoft.com/cdo/configuration/smtpserver"      )     :Value:= ::cServerIP
       :Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport"  )     :Value:= ::nPortSMTP
       :Item("http://schemas.microsoft.com/cdo/configuration/sendusing"       )     :Value:= 2
       :Item("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate")     :Value:= IIf(::lAut, 1, 0)
       :Item("http://schemas.microsoft.com/cdo/configuration/smtpusessl"      )     :Value:= IIf(::lSSL .or. ::lTLS, .T., .F.)
       :Item("http://schemas.microsoft.com/cdo/configuration/sendusername"    )     :Value:= Alltrim(::cUser)
       :Item("http://schemas.microsoft.com/cdo/configuration/sendpassword"    )     :Value:= Alltrim(::cPass)
       :Item("http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout"):Value:= ::nTimeout
*      :Item("http://schemas.microsoft.com/cdo/configuration/sendtls")              :Value:= ::lTLS

       :Update()
     END WITH
   RECOVER USING oError
     aRetorno["OK"]     := .F.
     aRetorno["MsgErro"]:= "Falha conexão com o smtp"                          + hb_Eol() + ;
                           "Erro: "      + Transf(oError:GenCode, Nil)   + ";" + hb_Eol() + ;
                     	   "SubC: "      + Transf(oError:SubCode, Nil)   + ";" + hb_Eol() + ;
                      	   "OSCode: "    + Transf(oError:OsCode,  Nil)   + ";" + hb_Eol() + ;
                      	   "SubSystem: " + Transf(oError:SubSystem, Nil) + ";" + hb_Eol() + ;
                      	   "Mensagem: "  + oError:Description
     Return(aRetorno)
   END SEQUENCE

   // enviar
   For nITo:= 1 To Len(::aTo)
       #ifdef __XHARBOUR__
          oMsg:= xhb_CreateObject ("CDO.Message")
       #Else
          oMsg:= win_oleCreateObject ("CDO.Message")
       #Endif
       WITH OBJECT oMsg
         :To           := ::aTo[nITo]
         :From         := ::cFrom
         :Configuration:= oCfg
         If ::aCC # Nil
            :Cc:= HbNfeEmailJoin(::aCC, [,])
         Else
	    :Cc:= []
         Endif
         If ::aBCC # Nil
            :BCC:= HbNfeEmailJoin(::aBCC, [,])
         Else
 	    :BCC:= []
         Endif
         :Subject:= ::cSubject
         If !Empty(::cMsgTexto)
            :TextBody:= ::cMsgTexto
         Else
            :HTMLBody:= ::cMsgHTML
         Endif

         :BodyPart:Charset:= "utf-8"

         For nIfiles:= 1 To Len(::aFiles)
             If File( Alltrim(::aFiles[nIfiles]))
                :AddAttachment(Alltrim(::aFiles[nIfiles]))
             Else
                aRetorno["OK"]     := .F.
                aRetorno["MsgErro"]:= "Arquivo não encontrado: " + ::aFiles[nIfiles]
                Return(aRetorno)
             Endif
         Next
         If ::lConf
            :Fields("urn:schemas:mailheader:disposition-notification-to"):Value:= ::cFrom
            :Fields:update()
         Endif
       END WITH
       BEGIN SEQUENCE WITH {|oErr| Break(oErr)}
         oRetorno:= oMsg:Send()
       RECOVER USING oError
         cFilename:= []
         If oError:Filename # Nil
            If Valtype(oError:Filename) == [C]
               cFilename:= oError:Filename
            ElseIf Valtype(oError:Filename) == [N]
               cFilename:= Transf(oError:Filename, Nil)
            Else
               cFilename:= Valtype(oError:Filename)
            Endif
         Endif
         cArgs:= []
         If oError:Args # Nil
            If Valtype(oError:Args) == [C]
               cArgs:= oError:Args
            ElseIf Valtype(oError:Args) == [N]
               cArgs:= Transf(oError:Args, Nil)
            ElseIf Valtype(oError:Args) == [A]
               For nXa:= 1 TO Len(oError:Args)
                   cArg:= []
                   If Valtype(oError:Args[nXa]) == [C]
                      cArg:= oError:Args[nXa]
                   ElseIf Valtype(oError:Args[nXa]) == [N]
                      cArg:= Transf(oError:Args[nXa], Nil)
                   Else
                      cArg:= "desc." + Valtype(oError:Args[nXa])
                   Endif
                   cArgs += cArg + [,]
               Next
            Else
               cArgs:= Valtype(oError:Args)
            Endif
         Endif
	 aRetorno["MsgErro"]:= "Falha envio de email"                                                                                                            + hb_Eol()+ ;
                               "Erro: "      + Transf(oError:GenCode, Nil) + ";"                                                                                 + hb_Eol()+ ;
                               "SubC: "      + Transf(oError:SubCode, Nil) + ";"                                                                                 + hb_Eol()+ ;
                               "OSCode: "    + Transf(oError:OsCode,  Nil) + ";"                                                                                 + hb_Eol()+ ;
                               "SubSystem: " + If(oError:SubSystem == Nil, [], oError:SubSystem) + ";"                                                           + hb_Eol()+ ;
                               "Operação: "  + If(oError:Operation == Nil, [], If(IsCharacter(oError:Operation), oError:Operation, Str(oError:Operation))) + ";" + hb_Eol()+ ;
                               "Arquivo: "   + cFilename + ";"                                                                                                   + hb_Eol()+ ;
                               "Args: "      + cArgs + ";"                                                                                                       + hb_Eol()+ ;
                               "Mensagem: "  + If(oError:Description == Nil, [], oError:Description) + ";"
         #ifndef __XHARBOUR__
             aRetorno["MsgErro"] += "WinOle: " + win_oleErrorText()
         #Endif
         aRetorno["OK"]:= .F.
         Return(aRetorno)
       END SEQUENCE
   Next
   aRetorno["OK"]:= .T.
   aRetorno["MsgErro"]:= []
   aRetorno["Provider"]:= ::cProvider
   aRetorno["Server"]:= ::cServerIP
   aRetorno["Porta"]:= ::nPortSMTP
Return(aRetorno)


METHOD ExecuteGmailNative() CLASS hbNFeEmail
   LOCAL aRetorno := {=>}, cTmpBase, cPsFile, cResultFile, cPs := [], cOut := [], cErr := [], nRet
   LOCAL nI, cBody, lHtml, cFile

   IF Valtype(::aTo) == [C]
      ::aTo:= {::aTo}
   ELSEIF ValType(::aTo) != [A]
      ::aTo:= {}
   ENDIF
   IF Valtype(::aCC) == [C]
      ::aCC:= {::aCC}
   ELSEIF ValType(::aCC) != [A]
      ::aCC:= {}
   ENDIF
   IF Valtype(::aBCC) == [C]
      ::aBCC:= {::aBCC}
   ELSEIF ValType(::aBCC) != [A]
      ::aBCC:= {}
   ENDIF
   IF Valtype(::aFiles) == [C]
      ::aFiles:= {::aFiles}
   ELSEIF ValType(::aFiles) != [A]
      ::aFiles:= {}
   ENDIF

   IF Len(::aTo) == 0
      aRetorno["OK"]:= .F.
      aRetorno["MsgErro"]:= [Nenhum destinatario informado]
      RETURN aRetorno
   ENDIF

   FOR nI := 1 TO Len(::aFiles)
      IF ! File( AllTrim(::aFiles[nI]) )
         aRetorno["OK"]:= .F.
         aRetorno["MsgErro"]:= "Arquivo nao encontrado: " + AllTrim(::aFiles[nI])
         RETURN aRetorno
      ENDIF
   NEXT

   IF Empty(::cServerIP)
      ::cServerIP := [smtp.gmail.com]
   ENDIF
   IF Empty(::nPortSMTP)
      ::nPortSMTP := 587
   ENDIF

   cTmpBase := hb_DirTemp() + "hbnfeemail_" + StrTran( DToS(Date()) + StrTran(Time(), ":", ""), " ", "" ) + "_" + LTrim(Str(Int(Seconds() * 1000)))
   cPsFile := cTmpBase + ".ps1"
   cResultFile := cTmpBase + ".log"
   lHtml := ! Empty(::cMsgHTML) .AND. Empty(::cMsgTexto)
   cBody := IIf( lHtml, ::cMsgHTML, ::cMsgTexto )

   cPs += "$ErrorActionPreference = 'Stop'" + hb_Eol()
   cPs += "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12" + hb_Eol()
   cPs += "$smtp = $null" + hb_Eol()
   cPs += "$msg = $null" + hb_Eol()
   cPs += "try {" + hb_Eol()
   cPs += "  $smtp = New-Object Net.Mail.SmtpClient(" + HbNfeEmailPsString(::cServerIP) + ", " + LTrim(Str(::nPortSMTP)) + ")" + hb_Eol()
   cPs += "  $smtp.EnableSsl = $true" + hb_Eol()
   cPs += "  $smtp.Timeout = " + LTrim(Str(::nTimeout * 1000)) + hb_Eol()
   cPs += "  $smtp.Credentials = New-Object Net.NetworkCredential(" + HbNfeEmailPsString(::cUser) + ", " + HbNfeEmailPsString(::cPass) + ")" + hb_Eol()
   cPs += "  $msg = New-Object Net.Mail.MailMessage" + hb_Eol()
   cPs += "  $msg.From = " + HbNfeEmailPsString(::cFrom) + hb_Eol()
   FOR nI := 1 TO Len(::aTo)
      cPs += "  $msg.To.Add(" + HbNfeEmailPsString(AllTrim(::aTo[nI])) + ")" + hb_Eol()
   NEXT
   FOR nI := 1 TO Len(::aCC)
      cPs += "  $msg.CC.Add(" + HbNfeEmailPsString(AllTrim(::aCC[nI])) + ")" + hb_Eol()
   NEXT
   FOR nI := 1 TO Len(::aBCC)
      cPs += "  $msg.Bcc.Add(" + HbNfeEmailPsString(AllTrim(::aBCC[nI])) + ")" + hb_Eol()
   NEXT
   cPs += "  $msg.Subject = " + HbNfeEmailPsString(HbNfeEmailHeaderText(::cSubject)) + hb_Eol()
   cPs += "  $msg.Body = " + HbNfeEmailPsString(cBody) + hb_Eol()
   cPs += "  $msg.IsBodyHtml = $" + IIf( lHtml, "true", "false" ) + hb_Eol()
   FOR nI := 1 TO Len(::aFiles)
      cFile := AllTrim(::aFiles[nI])
      cPs += "  $msg.Attachments.Add((New-Object Net.Mail.Attachment(" + HbNfeEmailPsString(cFile) + "))) | Out-Null" + hb_Eol()
   NEXT
   cPs += "  $smtp.Send($msg)" + hb_Eol()
   cPs += "  'OK' | Set-Content -Encoding ASCII -LiteralPath " + HbNfeEmailPsString(cResultFile) + hb_Eol()
   cPs += "  exit 0" + hb_Eol()
   cPs += "} catch {" + hb_Eol()
   cPs += "  $_.Exception.ToString() | Set-Content -Encoding UTF8 -LiteralPath " + HbNfeEmailPsString(cResultFile) + hb_Eol()
   cPs += "  exit 1" + hb_Eol()
   cPs += "} finally {" + hb_Eol()
   cPs += "  if ($msg -ne $null) { $msg.Dispose() }" + hb_Eol()
   cPs += "  if ($smtp -ne $null) { $smtp.Dispose() }" + hb_Eol()
   cPs += "}" + hb_Eol()

   hb_MemoWrit( cPsFile, cPs )
   nRet := hb_processRun( "powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File " + HbNfeEmailCmdQuote( cPsFile ),, @cOut, @cErr )

   IF nRet == 0
      aRetorno["OK"]:= .T.
      aRetorno["MsgErro"]:= []
   ELSE
      aRetorno["OK"]:= .F.
      aRetorno["MsgErro"]:= "Falha envio Gmail via PowerShell/.NET" + hb_Eol() + ;
                            "ExitCode: " + LTrim(Str(nRet)) + hb_Eol() + ;
                            "Erro: " + cErr + hb_Eol() + ;
                            "Detalhe: " + IIf( File(cResultFile), MemoRead(cResultFile), cOut )
   ENDIF

   FErase( cPsFile )
   FErase( cResultFile )

   aRetorno["Provider"]:= ::cProvider
   aRetorno["Server"]:= ::cServerIP
   aRetorno["Porta"]:= ::nPortSMTP
RETURN aRetorno

STATIC FUNCTION HbNfeEmailPsString( cText )
RETURN Chr(39) + StrTran( HbNfeEmailDefault( cText, [] ), Chr(39), Chr(39) + Chr(39) ) + Chr(39)

STATIC FUNCTION HbNfeEmailCmdQuote( cText )
RETURN Chr(34) + StrTran( AllTrim(cText), Chr(34), Chr(34) + Chr(34) ) + Chr(34)

STATIC FUNCTION HbNfeEmailHeaderText( cText )
RETURN StrTran( StrTran( HbNfeEmailDefault( cText, [] ), Chr(13), " " ), Chr(10), " " )

STATIC FUNCTION HbNfeEmailJoin( aLista, cSep )
   LOCAL cRet:= [], nI
   IF aLista == Nil
      RETURN []
   ENDIF
   IF ValType(aLista) == [C]
      RETURN aLista
   ENDIF
   FOR nI:= 1 TO Len(aLista)
      IF ! Empty(aLista[nI])
         IF ! Empty(cRet)
            cRet += cSep
         ENDIF
         cRet += AllTrim(aLista[nI])
      ENDIF
   NEXT
RETURN cRet

STATIC FUNCTION HbNfeEmailDefault( xValue, xDefault )
   IF xValue == Nil
      RETURN xDefault
   ENDIF
RETURN xValue