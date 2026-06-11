#include "hbclass.ch"

PROCEDURE Main()
   LOCAL oEmail, aRet

   oEmail := hbNFeEmail():New()

   // Brevo:
   // Usuario = SMTP login da tela SMTP & API
   // Senha   = SMTP key, nao e API key e nao e senha da conta Brevo
   oEmail:UseBrevo( "seu-login-smtp@smtp-brevo.com", "sua_smtp_key", "nfe@seudominio.com.br" )

   oEmail:AddTo( "cliente@empresa.com.br" )
   oEmail:cSubject  := "Teste de envio Brevo"
   oEmail:cMsgTexto := "Teste de envio pela classe hbNFeEmail usando Brevo SMTP."

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

