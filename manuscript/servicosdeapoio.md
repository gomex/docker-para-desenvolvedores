# Serviços de Apoio

Seguindo a lista do modelo [12factor](http://12factor.net/pt_br), temos **“Serviços de Apoio”** como quarta boa prática.

Para contextualizar, serviços de apoio é qualquer aplicação que seu código consome para operar corretamente (Ex. Banco de dados, serviço de mensagens e afins).

![](images/servicoapoio.png)

Com objetivo de evitar que seu código seja demasiadamente dependente de uma determinada infraestrutura, essa boa prática indica que você, no momento da escrita do software, não faça distinção se o serviço é interno ou externo, ou seja, seu aplicativo deve estar pronto para receber parâmetros que farão a configuração do serviço correto e assim possibilitem o consumo de aplicações necessárias da solução proposta.

A aplicação exemplo sofreu algumas modificações para suportar essa boa prática:

```
from flask import Flask
from redis import Redis
import os
host_run=os.environ.get('HOST_RUN', '0.0.0.0')
debug=os.environ.get('DEBUG', 'True')
host_redis=os.environ.get('HOST_REDIS', 'redis')
port_redis=os.environ.get('PORT_REDIS', '6379')
app = Flask(__name__)
redis = Redis(host=host_redis, port=port_redis)
@app.route('/')
def hello():
   redis.incr('hits')
   return 'Hello World! %s times.' % redis.get('hits')
if __name__ == "__main__":
   app.run(host=host_run, debug=True)
```

Como você pode perceber no código acima, sua aplicação agora pode receber variáveis de ambiente para configurar o hostname e porta do serviço Redis, ou seja, nesse caso é possível configurar um host e porta da redis que você deseja conectar. E tudo isso pode, e deve, ser especificado no docker-compose.yml, que também passou por uma mudança para se adequar a essa nova boa prática:

```
version: "2"
services:
  web:
    build: .
    ports:
     - "5000:5000"
    volumes:
     - .:/code
    labels:
     - 'app.environment=${ENV_APP}'
    environment:
     - HOST_RUN=${HOST_RUN}
     - DEBUG=${DEBUG}
     - PORT_REDIS=6379
     - HOST_REDIS=redis
  redis:
    image: redis:3.2.1
    volumes:
     - dados:/data
    labels:
     - 'app.environment=${ENV_APP}'
volumes:
  dados:
    external: false
```

Como podemos observar nos códigos já explicados, a grande vantagem de se utilizar dessa boa prática é o fato da possibilidade de mudança de comportamento sem a necessidade de mudança do código, mais uma vez é possível viabilizar que o mesmo código que foi construído em um momento, possa ser reutilizado de forma semelhante tanto no notebook do desenvolvedor, como no servidor de produção.

Fique atento para armazenamento de segredos dentro do docker-compose.yml, pois esse arquivo será enviado para o repositório de controle de versão, ou seja, é importante pensar em outra estratégia de manutenção de segredos.

Uma estratégia possível é a manutenção de variáveis de ambiente no docker host e dessa forma você precisaria usar variáveis do tipo **${variavel}** dentro do docker-compose.yml pra pode repassar essa configuração ou utilizar outro recurso mais avançado de gerenciamento de segredos.

[Capítulo anterior: Configurações](configuracoes.md) | [Próximo capítulo: Construa, lance, execute](construa-lance-execute.md)