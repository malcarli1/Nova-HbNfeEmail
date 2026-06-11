#include "hbclass.ch"

PROCEDURE Main()
   LOCAL oEmail, aRet

   oEmail := hbNFeEmail():New()

   // Gmail atual: usar senha de app, nao a senha normal da conta.
   oEmail:UseGmail( "suaempresa@gmail.com", "senha_de_app_16_caracteres" )

   oEmail:AddTo( "cliente@empresa.com.br" )
   oEmail:cSubject  := "Teste de envio Gmail"
   oEmail:cMsgTexto := "Teste de envio pela classe hbNFeEmail usando Gmail."

   // Opcional:
   // oEmail:AddFile( "C:\NFe\nfe.xml" )
   // oEmail:AddFile( "C:\NFe\danfe.pdf" )

   aRet := oEmail:Execute()

   IF aRet["OK"]
      ? "E-mail enviado com sucesso"
   ELSE
      ? "Falha no envio:"
      ? aRet["MsgErro"]
   ENDIF
RETURN

