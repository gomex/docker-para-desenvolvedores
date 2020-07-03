# Processos

Seguindo a lista do modelo [12factor](https://12factor.net/pt_br/), temos **“Processos”** como sexta boa prática.

Com o advento da automatização e devida inteligência na manutenção das aplicações, hoje, é esperado que a aplicação possa atender a picos de demandas com inicialização automática de novos processos, sem afetar seu comportamento.

![](images/processos.png)

A boa prática indica que processos de aplicações 12factor são stateless (não armazenam estado) e share-nothing. Quaisquer dados que precisem persistir devem ser armazenados em serviço de apoio stateful (armazena o estado), normalmente é usado uma base de dados.

O objetivo final dessa prática não faz distinção se a aplicação é executada na máquina do desenvolvedor ou em produção, pois, nesse caso, o que muda é a quantidade de processos iniciados para atender as respectivas demandas. Na máquina do desenvolvedor pode ser apenas um e, em produção, um número maior.

O **12factor** indica que o espaço de memória ou sistema de arquivos do servidor pode ser usado brevemente como cache de transação única. Por exemplo, o download de um arquivo grande, operando sobre ele e armazenando os resultados no banco de dados.

Vale salientar que, um estado nunca deve ser armazenado entre requisições, não importando o estado do processamento da próxima requisição.

É importante salientar: ao seguir a prática, uma aplicação não assume que, qualquer item armazenado em cache de memória ou no disco, estará disponível em futura solicitação ou job – com muitos processos de cada tipo rodando, são altas as chances de futura solicitação ser servida por processo diferente, até mesmo em servidor diferente. Mesmo quando, rodando em apenas um processo, um restart (desencadeado pelo deploy de um código, mudança de configuração, ou o ambiente de execução realocando o processo para localização física diferente) geralmente vai acabar com o estado local (memória e sistema de arquivos, por exemplo).

Algumas aplicações demandam de sessões persistentes para armazenar informações da sessão de usuários e afins. Tais sessões são usadas em futuras requisições do mesmo visitante. Ou seja, se armazenado junto ao processo, é clara violação da boa prática. Nesse caso, é aconselhável usar serviço de apoio, tal como redis, memcached ou afins para esse tipo de trabalho externo ao processo. Com isso, é possível que o próximo processo, independente de onde esteja, consegue obter as informações atualizadas.

A aplicação que estamos trabalhando não guarda dado local e tudo o que precisa é armazenado no Redis. Não precisamos fazer adequação alguma nesse código para seguir a boa prática, como vemos abaixo:

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

Para acessar o código da prática, acesse o [repositório](https://github.com/gomex/exemplo-12factor-docker) e a pasta **“factor6“**.
