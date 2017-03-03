# Processos de administração

Seguindo a lista do modelo [12factor](http://12factor.net/pt_br), temos **“Processos de administração”** como décima segunda e última boa prática.

![](images/admin1.png)

Toda aplicação demanda administração. Isso quer dizer que uma vez implantada é possível que ela precise receber determinados comandos para corrigir possíveis problemas ou simplesmente mudar de comportamento. Como exemplos temos migrações de banco de dados, execução de scripts diversos como backup, e também execução de um console para inspeção do serviço.

Essa boa prática recomenda processos de administração executados em ambientes idênticos ao utilizado no código em execução, ou seja, seguindo todas as práticas explicadas até então.

Usando Docker é possível rodar esses processos utilizando a mesma imagem base no ambiente de execução que se desejar. Com isso podemos nos beneficiar da comunicação entre os contêineres, uso de volumes que forem necessários e afins.

Para exemplificar essa boa prática criamos o arquivo **reset.py**:

```
from redis import Redis
import signal, os

host_redis=os.environ.get('HOST_REDIS', 'redis')
port_redis=os.environ.get('PORT_REDIS', '6379')

redis = Redis(host=host_redis, port=port_redis)

redis.set('hits', 0)
```

Ele é responsável por reinicializar o contador de visitas do Redis. Esse comando será dado usando um contêiner diferente a partir da mesma imagem docker. Primeiro vamos iniciar o ambiente. Baixe o repositório e acesse a pasta factor12 e execute o comando abaixo:

```
docker-compose up 
```

Acesse a aplicação em seu navegador. Caso esteja usando GNU/Linux ou Docker For MAC e Windows acesse o endereço 127.0.0.1. Você verá a seguinte frase:

```
“Hello World! 1 times.”
```

Acesse a aplicação mais algumas vezes para o marcador aumentar bastante.

Depois execute o comando de administração a partir do serviço worker:

```
docker-compose exec worker python reset.py
```

O comando **“python reset.py”** será executado dentro de um novo contêiner, mas usando a mesma imagem de um worker regular.

Acesse novamente a aplicação e verifique se o marcador iniciou a partir de 1 novamente.

