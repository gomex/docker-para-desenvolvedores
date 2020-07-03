# Logs

A décima primeira boa prática, na lista do modelo [12factor](https://12factor.net/pt_br/), é **“Logs”**.

![](images/logs1.png)

No desenvolvimento de código, gerar dados para efeitos de log é algo bastante consolidado. Não acreditamos que existam softwares em desenvolvimento sem essa preocupação. Porém, o uso correto do log vai além de, apenas, gerar dados.

Para efeito de contextualização, de acordo com o 12factor, o log é: “(…) fluxo de eventos agregados e ordenados por tempo coletados dos fluxos de saída de todos os processos em execução e serviços de apoio.”

Logs, normalmente, são armazenados em arquivos, com eventos por linha (pilhas de exceção podem ocupar várias linhas). Mas essa prática não é indicada, ao menos não na perspectiva da aplicação. Isso quer dizer que, a aplicação não deveria se preocupar em qual arquivo guardar os logs.

Especificar arquivos, implica informar o diretório correto desse arquivo, que, por sua vez, resulta em configuração prévia do ambiente. Isso impacta, negativamente, na portabilidade da aplicação, pois é necessário que, o ambiente que receberá a solução, siga uma série de requisitos técnicos para suportar a aplicação, enterrando, assim, a possibilidade do “Construa uma vez, rode em qualquer lugar”.

A boa prática indica que as aplicações não devem gerenciar ou rotear arquivos de log, mas devem ser depositados sem qualquer esquema de buffer na saída padrão (STDOUT). Assim, uma infraestrutura externa à aplicação - plataforma - deve gerenciar, coletar e formatar a saída dos logs para futura leitura. Isso é realmente importante quando a aplicação está rodando em várias instâncias.

Com o Docker, tal tarefa se torna fácil, pois o Docker já coleta logs da saída padrão e encaminha para algum dos vários drivers de log. O driver pode ser configurado na inicialização do contêiner de forma a centralizar os logs no serviço remoto de logs, por exemplo syslog.

O código exemplo no repositório([https://github.com/gomex/exemplo-12factor-docker](https://github.com/gomex/exemplo-12factor-docker)), na pasta factor11, está pronto para testar a boa prática, pois já envia todas as saídas de dados para STDOUT e você pode conferir iniciando o serviço com o comando abaixo:

```
docker-compose up
```

Depois de iniciar, acesse o navegador e verifique as requisições da aplicação que aparecem na console do Docker-Compose.
