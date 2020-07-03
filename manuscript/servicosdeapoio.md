# Serviços de Apoio

Seguindo a lista do modelo [12factor](https://12factor.net/pt_br/), temos **“Serviços de Apoio”** como quarta boa prática.

Para contextualizar, "serviços de apoio" é qualquer aplicação que seu código consome para operar corretamente (Ex.: banco de dados, serviço de mensagens e afins).

![](images/servicoapoio.png)

Com objetivo de evitar que o código seja demasiadamente dependente de determinada infraestrutura, a boa prática indica que você, no momento da escrita do software, não faça distinção entre serviço interno ou externo. Ou seja, o aplicativo deve estar pronto para receber parâmetros que configurem o serviço corretamente e, assim, possibilitem o consumo de aplicações necessárias à solução proposta.

A aplicação exemplo sofreu modificações para suportar a boa prática:

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

Como pode perceber no código acima, a aplicação agora recebe variáveis de ambiente para configurar o hostname e a porta do serviço Redis. Nesse caso, é possível configurar o host e a porta da Redis que deseja conectar. E isso pode e deve ser especificado no docker-compose.yml que também passou por mudança para se adequar a nova boa prática:

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

Como observamos nos códigos já tratados, a vantagem da boa prática passa pela possibilidade de mudança de comportamento sem mudança do código. Mais uma vez é possível viabilizar que, o mesmo código construído em um momento, possa ser reutilizado de forma semelhante, tanto no notebook do desenvolvedor como no servidor de produção.

Fique atento para armazenamento de segredos dentro do docker-compose.yml, pois esse arquivo é enviado para o repositório de controle de versão e é importante pensar outra estratégia de manutenção de segredos.

Uma estratégia possível é a manutenção de variáveis de ambiente no Docker Host. Dessa forma, você precisa usar variáveis do tipo **${variavel}** dentro do docker-compose.yml para repassar a configuração ou, utilizar outro recurso mais avançado de gerenciamento de segredos.
