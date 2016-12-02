# Processos

Seguindo a lista do modelo [12factor](http://12factor.net/pt_br), temos **“Processos”** como sexta boa prática.

Com advento da automatização, e uma devida inteligência na manutenção das aplicações, hoje é esperado que a sua aplicação possa atender a picos de demandas com inicialização automática de novos processos, sem que isso afete negativamente o comportamento da mesma.

![](images/processos.png)

Essa boa prática indica que processos de aplicações 12factor são stateless (não armazenam estado) e share-nothing. Quaisquer dados que precise persistir deve ser armazenado em um serviço de apoio stateful(que armazena o seu estado), tipicamente uma base de dados.

O objetivo final dessa prática é não fazer distinção se a aplicação está sendo executada na máquina do desenvolvedor ou em produção, pois nesse caso o que mudaria seria a quantidade de processos iniciados para atender as suas respectivas demandas, ou seja, na máquina do desenvolvedor poderia ser apenas um e em produção um número maior.

O **12factor** indica que o espaço de memória ou sistema de arquivos do servidor pode ser usado brevemente como cache de transação única. Por exemplo, o download de um arquivo grande, operando sobre ele, e armazenando os resultados da operação no banco de dados.

Vale a pena salientar que um estado nunca deve ser armazenado entre requisições, não importando o estado do processamento da próxima requisição.

É importante salientar que ao seguir essa prática, uma aplicação nunca assume que qualquer coisa armazenada em cache de memória ou no disco estará disponível em uma futura solicitação ou job – com muitos processos de cada tipo rodando, as chances são altas de que uma futura solicitação será servida por um processo diferente, até mesmo em um servidor diferente. Mesmo quando rodando em apenas um processo, um restart (desencadeado pelo deploy de um código, mudança de configuração, ou o ambiente de execução realocando o processo para uma localização física diferente) geralmente vai acabar com todo o estado local (por exemplo, memória e sistema de arquivos).

Algumas aplicações demandam de sessões persistentes, para armazenar informações da sessão de usuários e afins. Essas sessões são usadas em futuras requisições do mesmo visitante, ou seja, se armazenado junto ao processo isso é uma clara violação dessa boa prática. Nesse caso o mais aconselhável é usar um serviço de apoio, tal como redis, memcached ou afins para esse tipo de trabalho externo ao processo, com isso será possível que o próximo processo, independente onde ele esteja, conseguirá obter as informações atualizadas.

A aplicação que estamos trabalhando não guarda nenhum dado local, e tudo que ela precisa é armazenado no Redis. Dessa forma não precisamos fazer adequação alguma nesse código para seguir essa boa prática, como podemos ver abaixo:

```
from flask import Flask
from redis import Redis
import os
host_redis=os.environ.get('HOST_REDIS', 'redis')
port_redis=os.environ.get('PORT_REDIS', '6379')
app = Flask(__name__)
 redis = Redis(host=host_redis, port=port_redis)
@app.route('/')
def hello():
 redis.incr('hits')
 return 'Hello World! %s times.' % redis.get('hits')
if __name__ == "__main__":
 app.run(host="0.0.0.0", debug=True)
```

Para acessar o código dessa prática, acesse o nosso [repositório](https://github.com/gomex/exemplo-12factor-docker) e acesse a pasta **“factor6“**.

[Capítulo anterior: Construa, lance, execute](m/construa-lance-execute.md) | [Próximo capítulo: Vínculo de portas](vinculos.md)