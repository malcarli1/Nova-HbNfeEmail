# Manual de uso - hbNFeEmail

Este manual documenta a classe hbNFeEmail usada para envio de e-mail em Harbour/xHarbour.
Arquivo principal:


## Observacao importante sobre Gmail e Microsoft
A classe original usa CDO.Message, SMTP, usuario e senha.
Isso ainda pode funcionar em servidores comuns, mas Gmail e Microsoft mudaram as regras:
- Gmail nao aceita mais senha normal em aplicativos antigos. Deve usar senha de app, quando a conta permitir, ou OAuth.
- Google Workspace bloqueou acesso por senha basica para apps menos seguros.
- Microsoft 365/Exchange Online esta retirando SMTP Basic Auth. O caminho moderno e OAuth/Graph.

Na pratica:
- Para Gmail pessoal: usar smtp.gmail.com, porta 587, TLS ligado e senha de app.
- Para Microsoft 365 antigo: smtp.office365.com, porta 587, TLS ligado, mas isso tende a parar conforme a politica do tenant.
- Para Microsoft moderno: usar OAuth/Microsoft Graph ou SMTP OAuth.

## Propriedades da classe

### ohbNFe
Objeto auxiliar da NFe, caso o sistema use algum objeto externo para montar informacoes.
Normalmente pode ficar vazio.

### cSubject
Assunto do e-mail.
Exemplo:
harbour
oEmail:cSubject := "NF-e emitida"

### cMsgTexto
Corpo do e-mail em texto puro.
Exemplo:
harbour
oEmail:cMsgTexto := "Segue em anexo o XML e DANFE da NF-e."


### cMsgHTML
Corpo do e-mail em HTML.
Se cMsgTexto estiver vazio, a classe usa cMsgHTML.
Exemplo:
harbour
oEmail:cMsgHTML := "<b>Segue NF-e em anexo.</b>"

### cServerIP
Servidor SMTP.
Exemplos:
harbour
oEmail:cServerIP := "smtp.gmail.com"
oEmail:cServerIP := "smtp.office365.com"
oEmail:cServerIP := "mail.seudominio.com.br"


### cFrom
Remetente do e-mail.
Use normalmente o mesmo e-mail autenticado em cUser.
harbour
oEmail:cFrom := "empresa@gmail.com"


### cUser
Usuario de autenticacao SMTP.
Normalmente e o e-mail completo.
harbour
oEmail:cUser := "empresa@gmail.com"


### cPass
Senha de autenticacao SMTP.
Para Gmail, nao use senha normal da conta. Use senha de app.
harbour
oEmail:cPass := "senha_de_app_do_gmail"


### nPortSMTP
Porta SMTP.
Valores comuns:
text
587 - SMTP com STARTTLS
465 - SMTP SSL direto
25  - SMTP legado, geralmente bloqueado

Exemplo:
harbour
oEmail:nPortSMTP := 587


### lConf
Solicita confirmacao de leitura.
harbour
oEmail:lConf := .T.
Observacao: nem todo cliente/servidor respeita confirmacao de leitura.

### lSSL
Liga SSL direto.
Use .T. normalmente na porta 465.
harbour
oEmail:lSSL := .T.
oEmail:nPortSMTP := 465
Para porta 587, normalmente deixe .F. e use TLS/STARTTLS.

### lTLS
Indica uso de TLS/STARTTLS.
Na classe CDO original, esse campo existe mas o suporte pode ser limitado.
Recomendado para Gmail/Microsoft:
harbour
oEmail:lTLS := .T.
oEmail:lSSL := .F.
oEmail:nPortSMTP := 587


### lAut
Liga autenticacao SMTP.
Para Gmail, Microsoft e servidores comerciais, normalmente:
harbour
oEmail:lAut := .T.

### aFiles
Array de anexos.
Exemplo:
harbour
oEmail:aFiles := { ;
   "C:\NFe\35140600000000000000550010000000011000000010-nfe.xml", ;
   "C:\NFe\DANFE_000001.pdf" ;
}


### aTo
Destinatarios principais.
Pode ser string ou array.
harbour
oEmail:aTo := { "cliente@empresa.com.br", "financeiro@empresa.com.br" }
Ou:
harbour
oEmail:aTo := "cliente@empresa.com.br"
### aCC
Destinatarios em copia.
harbour
oEmail:aCC := { "contador@empresa.com.br" }

### aBCC
Destinatarios em copia oculta.
harbour
oEmail:aBCC := { "arquivo@empresa.com.br" }

## Retorno do metodo Execute()
O metodo retorna um Hash().
Campos principais:
harbour
aRetorno["OK"]
aRetorno["MsgErro"]


Exemplo:
harbour
aRet := oEmail:Execute()
IF aRet["OK"]
   ? "E-mail enviado com sucesso"
ELSE
   ? "Erro ao enviar:"
   ? aRet["MsgErro"]
ENDIF

## Exemplo basico - servidor SMTP comum
harbour
LOCAL oEmail, aRet
oEmail := hbNFeEmail():New()
oEmail:cServerIP := "mail.seudominio.com.br"
oEmail:nPortSMTP := 587
oEmail:lAut      := .T.
oEmail:lTLS      := .T.
oEmail:lSSL      := .F.

oEmail:cUser := "nfe@seudominio.com.br"
oEmail:cPass := "senha_do_email"
oEmail:cFrom := "nfe@seudominio.com.br"

oEmail:aTo      := { "cliente@empresa.com.br" }
oEmail:cSubject := "NF-e emitida"
oEmail:cMsgTexto:= "Segue em anexo o XML e o DANFE da NF-e."
oEmail:aFiles   := { "C:\NFe\nfe.xml", "C:\NFe\danfe.pdf" }

aRet := oEmail:Execute()

IF ! aRet["OK"]
   ? aRet["MsgErro"]
ENDIF


## Exemplo Gmail
Configuracao recomendada:
text
Servidor: smtp.gmail.com
Porta: 587
TLS: sim
SSL direto: nao
Usuario: e-mail completo
Senha: senha de app, nao senha normal


Exemplo:
harbour
LOCAL oEmail, aRet
oEmail := hbNFeEmail():New()

oEmail:cServerIP := "smtp.gmail.com"
oEmail:nPortSMTP := 587
oEmail:lAut      := .T.
oEmail:lTLS      := .T.
oEmail:lSSL      := .F.

oEmail:cUser := "suaempresa@gmail.com"
oEmail:cPass := "senha_de_app_16_caracteres"
oEmail:cFrom := "suaempresa@gmail.com"

oEmail:aTo       := { "cliente@empresa.com.br" }
oEmail:cSubject  := "Documento fiscal"
oEmail:cMsgTexto := "Segue documento fiscal em anexo."
oEmail:aFiles    := { "C:\NFe\nfe.xml", "C:\NFe\danfe.pdf" }

aRet := oEmail:Execute()

IF aRet["OK"]
   ? "Enviado"
ELSE
   ? aRet["MsgErro"]
ENDIF


## Erros comuns no Gmail

### Erro de usuario ou senha

Causa provavel:

- Foi usada a senha normal da conta.
- A conta nao tem verificacao em duas etapas.
- A senha de app foi revogada.
- A conta Workspace bloqueia senha de app.

Solucao:

- Ativar verificacao em duas etapas.
- Gerar senha de app.
- Usar a senha de app sem espacos.
- Em conta Workspace, validar politica com o administrador.

### Falha de TLS/SSL

Tente:

harbour
oEmail:nPortSMTP := 587
oEmail:lTLS := .T.
oEmail:lSSL := .F.


Se usar porta 465:

harbour
oEmail:nPortSMTP := 465
oEmail:lSSL := .T.


## Exemplo Microsoft 365 legado

Configuracao classica:

text
Servidor: smtp.office365.com
Porta: 587
TLS: sim
SSL direto: nao
Usuario: e-mail completo
Senha: senha da conta ou senha permitida pelo tenant


Exemplo:

harbour
LOCAL oEmail, aRet

oEmail := hbNFeEmail():New()

oEmail:cServerIP := "smtp.office365.com"
oEmail:nPortSMTP := 587
oEmail:lAut      := .T.
oEmail:lTLS      := .T.
oEmail:lSSL      := .F.

oEmail:cUser := "nfe@empresa.com.br"
oEmail:cPass := "senha"
oEmail:cFrom := "nfe@empresa.com.br"

oEmail:aTo       := { "cliente@empresa.com.br" }
oEmail:cSubject  := "NF-e emitida"
oEmail:cMsgTexto := "Segue NF-e em anexo."
oEmail:aFiles    := { "C:\NFe\nfe.xml", "C:\NFe\danfe.pdf" }

aRet := oEmail:Execute()

IF ! aRet["OK"]
   ? aRet["MsgErro"]
ENDIF


## Observacao Microsoft 365

Mesmo que funcione hoje, SMTP com usuario/senha no Microsoft 365 esta em processo de descontinuidade.

Para produto novo ou vendido comercialmente, o ideal e implementar uma destas opcoes:

- Microsoft Graph sendMail com OAuth.
- SMTP AUTH com OAuth2.
- Servico SMTP transacional, como SendGrid, Mailgun, Amazon SES, Brevo etc.

## Sugestao de interface nova para facilitar o programador

Uma versao modernizada da classe pode manter compatibilidade e acrescentar metodos auxiliares:

harbour
oEmail := hbNFeEmail():New()
oEmail:UseGmail( "suaempresa@gmail.com", "senha_de_app" )
oEmail:AddTo( "cliente@empresa.com.br" )
oEmail:AddFile( "C:\NFe\nfe.xml" )
oEmail:AddFile( "C:\NFe\danfe.pdf" )
oEmail:cSubject  := "NF-e emitida"
oEmail:cMsgTexto := "Segue documento fiscal."
aRet := oEmail:Execute()


Para Microsoft moderno:

harbour
oEmail := hbNFeEmail():New()
oEmail:UseMicrosoft365( "nfe@empresa.com.br", cAccessToken, .T. )
oEmail:AddTo( "cliente@empresa.com.br" )
oEmail:cSubject  := "NF-e emitida"
oEmail:cMsgTexto := "Segue documento fiscal."
aRet := oEmail:Execute()


## Checklist de configuracao

Antes de testar:

text
[ ] Servidor SMTP correto
[ ] Porta correta
[ ] TLS/SSL coerente com a porta
[ ] Usuario e remetente conferem
[ ] Senha de app no Gmail
[ ] SMTP AUTH habilitado no Microsoft 365, se ainda usar modo legado
[ ] Anexos existem no caminho informado
[ ] Antivírus/firewall nao bloqueia porta 587/465
[ ] Conta permite envio por aplicativo


## Melhorias recomendadas para a classe

Para deixar a classe atualizada de verdade:

text
1. Manter CDO apenas como modo legado.
2. Criar envio SMTP via curl ou libcurl com TLS moderno.
3. Criar modo OAuth para Gmail e Microsoft.
4. Criar envio Microsoft Graph para Microsoft 365.
5. Melhorar retorno com OK, MsgErro, Codigo, Provider, RawResponse.
6. Criar logs opcionais.
7. Criar validacao dos anexos antes do envio.
8. Criar helpers UseGmail(), UseMicrosoft365(), UseSMTP().
9. Separar montagem MIME do transporte.
10. Suportar HTML + texto alternativo.


## Modelo de retorno sugerido

harbour
aRet["OK"]       // .T. ou .F.
aRet["MsgErro"]  // mensagem amigavel
aRet["Codigo"]   // codigo interno
aRet["Provider"] // GMAIL, MICROSOFT365, SMTP
aRet["Modo"]     // CDO, CURL, GRAPH
aRet["Raw"]      // retorno bruto do transporte


Exemplo de uso:

harbour
aRet := oEmail:Execute()

IF ! aRet["OK"]
   hb_MemoWrit( "erro_email.log", aRet["MsgErro"] + hb_Eol() + aRet["Raw"] )
ENDIF

## Brevo SMTP

A classe tambem possui a variacao:

harbour
oEmail:UseBrevo( cSmtpLogin, cSmtpKey, cFrom, nPorta )

Parametros:

text
cSmtpLogin - login SMTP exibido na tela SMTP & API do Brevo
cSmtpKey   - SMTP key do Brevo
cFrom      - remetente validado/autenticado no Brevo
nPorta     - opcional: 587, 465 ou 2525

Padrao usado:

text
Servidor: smtp-relay.brevo.com
Porta: 587
TLS: sim
SSL direto: nao

Importante:

text
Use a SMTP key do Brevo.
Nao use API key.
Nao use a senha da conta Brevo.
O remetente ou dominio precisa estar validado no Brevo.

Exemplo:

harbour
LOCAL oEmail, aRet

oEmail := hbNFeEmail():New()

oEmail:UseBrevo( ;
   "seu-login-smtp@smtp-brevo.com", ;
   "sua_smtp_key", ;
   "nfe@seudominio.com.br" ;
)

oEmail:AddTo( "cliente@empresa.com.br" )
oEmail:cSubject  := "NF-e emitida"
oEmail:cMsgTexto := "Segue documento fiscal em anexo."
oEmail:AddFile( "C:\NFe\nfe.xml" )
oEmail:AddFile( "C:\NFe\danfe.pdf" )

aRet := oEmail:Execute()

IF aRet["OK"]
   ? "Enviado"
ELSE
   ? aRet["MsgErro"]
ENDIF

Se a porta 587 estiver bloqueada:

harbour
oEmail:UseBrevo( "login", "smtp_key", "nfe@seudominio.com.br", 2525 )

Para SSL direto:

harbour
oEmail:UseBrevo( "login", "smtp_key", "nfe@seudominio.com.br", 465 )

