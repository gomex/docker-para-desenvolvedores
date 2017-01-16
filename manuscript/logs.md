# Logs

Seguindo a lista do modelo [12factor](http://12factor.net/pt_br), temos **“Logs”** como décima primeira boa prática.

![](images/logs1.png)

No desenvolvimento de código, gerar dados para efeitos de log é algo bastante consolidado, ou seja, não acredito que existam pessoas desenvolvendo software que não se preocupem com isso, porém o uso correto do log vai além de apenas gerar os dados.

Para efeito de contextualização, de acordo com o 12factor o log é um: “…fluxo de eventos agregados e ordenados por tempo coletados dos fluxos de saída de todos os processos em execução e serviços de apoio.”

Logs normalmente são armazenados em arquivos, com eventos por linha (pilhas de exceção podem ocupar várias linhas), mas essa prática não é indicada, ao menos não na perspectiva da aplicação. Isso quer dizer que sua aplicação não deveria se preocupar em qual arquivo deve guardar os logs.

Especificar arquivos implica em informar o diretório correto desse arquivo, que por sua vez resulta em uma configuração prévia do ambiente e tudo isso junto impacta negativamente na portabilidade da sua aplicação, pois será necessário que o ambiente que receberá sua solução deve seguir uma série de requisitos técnicos para suportar a aplicação, ou seja, com isso enterrando a possibilidade do “Construa uma vez, rode em qualquer lugar”.

Essa boa prática indica que as aplicações não devem gerenciar ou rotear arquivos de log, ou seja, eles devem ser depositados sem nenhum esquema de buffer na saída padrão (STDOUT). Assim uma infraestrutura externa à aplicação, plataforma, deve gerenciar, coletar e formatar a saída desses logs para futura leitura. Isso é realmente importante quando a aplicação está rodando em várias instâncias.

Com o Docker, essa tarefa fica bem mais fácil, pois Docker já coleta logs da saída padrão e encaminha para algum dos vários drivers de log. Esse driver pode ser configurado na inicialização do container de forma a centralizar os logs num serviço remoto de logs, por exemplo syslog.

O código exemplo que está nesse repositório([https://github.com/gomex/exemplo-12factor-docker](https://github.com/gomex/exemplo-12factor-docker)), na pasta factor11 já se encontra pronto para testar essa boa prática, pois o mesmo já envia todas as saídas de dados para STDOUT e você pode conferir iniciando o nosso serviço com o comando abaixo:

```
docker-compose up
```

Depois de iniciar acesse o navegador e verifique as requisições da aplicação aparecendo na console do docker-compose.

[Capítulo anterior: Paridade entre desenvolvimento/produção](paridade.md) | [Próximo capítulo: Processos de administração](admin.md)