#include "hbclass.ch"

PROCEDURE Main()
   LOCAL oEmail, aRet

   oEmail := hbNFeEmail():New()

   oEmail:UseMicrosoft365( "seuemail@empresa.com.br", "3$o#1@49Hxx" )

   oEmail:AddTo( "marceloalcarli@gmail.com" )
   oEmail:cSubject  := "Teste de envio Microsoft365"
   oEmail:cMsgTexto := "Teste de envio pela classe hbNFeEmail usando Microsoft365."

   // Opcional:
   oEmail:AddFile( "D:\classe_email\email.rar" )
   // oEmail:AddFile( "C:\NFe\danfe.pdf" )

   aRet := oEmail:Execute()

   IF aRet["OK"]
      ? "E-mail enviado com sucesso"
   ELSE
      ? "Falha no envio:"
      ? aRet["MsgErro"]
   ENDIF
   wait
RETURN

