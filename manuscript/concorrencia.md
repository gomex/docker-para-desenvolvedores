# Concorrência

Seguindo a lista do modelo [12factor](http://12factor.net/pt_br), temos **“Concorrência”** como oitava boa prática.

Durante o processo de desenvolvimento de uma aplicação é difícil imaginar o volume de requisição que ela terá no momento que for colocada em produção. Por outro lado, ter um serviço que suporte grandes volumes de uso é algo esperado nas soluções modernas, pois nada é mais frustante do que solicitar acesso a uma aplicação e ela não estar disponível. Demonstra falta de cuidado e de profissionalismo na maioria dos casos.

Quando uma aplicação é colocada em produção normalmente ela é dimensionada para uma determinada carga esperada, porém é importante que o serviço esteja pronto para escalar, ou seja, a solução deve ser capaz de iniciar novos processo da mesma aplicação caso necessário, sem que isso afete negativamente o produto. A figura abaixo apresenta um gráfico de escalabilidade de serviços.

![](images/concorrencia1.png)

Com objetivo de evitar que exista qualquer problema na escalabilidade do serviço, esta boa prática indica que as aplicações devem suportar execuções concorrentes, tal que quando um processo está em execução deve ser possível instanciar um outro em paralelo e o serviço possa ser atendido sem perda alguma.

Para que isto aconteça, é importante dividir as tarefas corretamente. É interessante que os processos se atenham aos seus objetivos, ou seja, caso seja necessário executar alguma atividade em backend e depois retornar uma página para o navegador, é salutar que existam dois serviços que tratem as duas atividades de forma separada. O Docker torna essa tarefa mais simples, pois nesse modelo basta especificar um container para cada função e configurar corretamente a rede entre eles.

Para exemplificar essa boa prática, usaremos a arquitetura demonstrada na figura abaixo:

![](images/concorrencia2.png)

O serviço web será responsável por receber a requisição e balancear entre os workers, os quais são responsáveis por processar a requisição, conectar ao redis e retornar uma tela de “Hello World” informando quantas vezes ela foi obtida e qual nome do worker que está respondendo essa requisição (Para ter certeza que está balanceando a carga), como podemos ver na figura abaixo:

![](images/concorrencia3.png)

O arquivo **docker-compose.yml** exemplifica essa boa prática:

```
version: "2"
services:
  web:
    container_name: web
    build: web
    networks:
      - backend
    ports:
      - "80:80"

  worker:
    build: worker
    networks:
      backend:
        aliases:
          - apps
    expose:
      - 80
    depends_on:
      - web

  redis:
    image: redis
    networks:
      - backend

networks:
  backend:
      driver: bridge
```

Para efetuar a construção desse balanceador de carga, temos o diretório web contendo os arquivos Dockerfile (responsável por criar a imagem utilizada) e nginx.conf (arquivo de configuração do balanceador de carga utilizado).

Segue abaixo o conteúdo do DockerFile do web:

```
FROM nginx:1.9

COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

Segue o conteúdo do arquivo nginx.conf:

```
user nginx;
worker_processes 2;

events {
  worker_connections 1024;
}

http {
  access_log /var/log/nginx/access.log;
  error_log /var/log/nginx/error.log;

  resolver 127.0.0.11 valid=1s;

  server {
    listen 80;
    set $alias "apps";

    location / {
      proxy_pass http://$alias;
    }
  }
}
```

No arquivo de configuração acima, foram introduzidas algumas novidades. A primeira é o **“resolver 127.0.0.11“**, que é o serviço DNS interno do Docker. Usando essa abordagem será possível efetuar o balanceamento de carga via nome, usando um recurso interno do Docker.

Para mais detalhes sobre o funcionamento do DNS interno do Docker, veja esse documento ([https://docs.docker.com/engine/userguide/networking/configure-dns/](https://docs.docker.com/engine/userguide/networking/configure-dns/)) (apenas em inglês).

A segunda novidade é a função set **$alias “apps”;** que é responsável por especificar o nome **“apps”** que será usado na configuração do proxy reverso em seguida **“proxy_pass http://$alias;“**. Vale salientar que o **“apps”** é o nome da rede especificada dentro do arquivo **docker-compose.yml**. Nesse caso o balanceamento será feito para a rede, ou seja, todo novo contêiner que entrar nessa rede será automaticamente adicionado no balanceamento de carga.

Para efetuar a construção do **worker** temos o diretório **worker**  contendo os arquivos **Dockerfile** (responsável por criar a imagem utilizada), **app.py** (que é a aplicação que usamos em todos os outros capítulos) e **requirements.txt** (descreve todas as dependências do app.py).

Segue abaixo o conteúdo do arquivo **app.py** modificado para essa prática:

```
from flask import Flask
from redis import Redis
import os
import socket
print(socket.gethostname())
host_redis=os.environ.get('HOST_REDIS', 'redis')
port_redis=os.environ.get('PORT_REDIS', '6379')

app = Flask(__name__)
redis = Redis(host=host_redis, port=port_redis)

@app.route('/')
def hello():
   redis.incr('hits')
   return 'Hello World I am %s! %s times.' % (socket.gethostname(), redis.get('hits'))
if __name__ == "__main__":
   app.run(host="0.0.0.0", debug=True)
```

Segue abaixo o conteúdo do **requirements.txt**:

```
flask==0.11.1
redis==2.10.5
```

E por fim o **Dockerfile** do **worker** tem o seguinte conteúdo:

```
FROM python:2.7
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
COPY . /code
WORKDIR /code
CMD python app.py
```

No serviço **redis**, não há construção da imagem, pois usaremos a imagem oficial para efeitos de exemplificação.

Para realizar o teste de tudo que apresentado até então, realize o clone do repositório ([https://github.com/gomex/exemplo-12factor-docker](https://github.com/gomex/exemplo-12factor-docker)) e acesse a pasta **factor8**, executando o comando abaixo para iniciar os contêineres:

```
docker-compose up -d
```

Acesse os contêineres através do navegador na porta 80 do endereço localhost. Tente atualizar a página e veja que apenas um nome aparecerá.

Por padrão o docker-compose executa apenas uma instância de cada serviço explicitado em seu **docker-compose.yml**. Para aumentar a quantidade de contêineres **“worker”** de apenas um para dois execute o comando abaixo:

```
docker-compose scale worker=2
```

Atualize a página no navegador novamente e verá que o nome do host vai alternar entre duas possibilidades, ou seja, as requisições estão sendo balanceadas para ambos contêineres.

Nessa nova proposta de ambiente, o serviço **web** se encarregará de receber todas requisições HTTP e fazer o balanceamento de carga. Então o **worker** será responsável por processar essas requisições, que basicamente é obter seu nome de host, acessar o **redis** e obter a contagem de quantas vezes esse serviço foi requisitado e então gerar o retorno, para então devolvê-lo para o serviço **web**, que por sua vez responderá ao usuário. Como podem perceber, cada instância desse ambiente tem sua função bem definida e com isso será muito mais fácil escalá-lo.

Aproveito para dar os créditos ao capitão [Marcosnils](https://twitter.com/marcosnils), que foi a pessoa que me mostrou que é possível balancear carga pelo nome da rede docker.



