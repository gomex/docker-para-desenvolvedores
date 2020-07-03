# Concorrência

A oitava boa prática da lista do modelo [12factor](https://12factor.net/pt_br/), é **“Concorrência”**.

Durante o processo de desenvolvimento de uma aplicação é difícil imaginar o volume de requisição que ela terá no momento que for colocada em produção. Por outro lado, um serviço que suporte grandes volumes de uso é esperado nas soluções modernas. Nada é mais frustrante que solicitar acesso a uma aplicação e ela não estar disponível. Sugere falta de cuidado e profissionalismo, na maioria dos casos.

Quando a aplicação é colocada em produção, normalmente é dimensionada para determinada carga esperada, porém é importante que o serviço esteja pronto para escalar. A solução deve ser capaz de iniciar novos processo da mesma aplicação, caso necessário, sem afetar o produto. A figura abaixo, apresenta gráfico de escalabilidade de serviços.

![](images/concorrencia1.png)

Com objetivo de evitar qualquer problema na escalabilidade do serviço, a boa prática indica que as aplicações devem suportar execuções concorrentes e, quando um processo está em execução, instanciar outro em paralelo e o serviço atendido, sem perda alguma.

Para tal, é importante dividir as tarefas corretamente. É interessante o processo se ater aos objetivos, caso seja necessário executar alguma atividade em backend e, depois retornar uma página para o navegador, é salutar que haja dois serviços tratando as duas atividades, de forma separada. O Docker torna essa tarefa mais simples, pois, nesse modelo, basta especificar um contêiner para cada função e configurar corretamente a rede entre eles.

Para exemplificar a boa prática, usaremos a arquitetura demonstrada na figura abaixo:

![](images/concorrencia2.png)

O serviço web é responsável por receber a requisição e balancear entre os workers, os quais são responsáveis por processar a requisição, conectar ao redis e retornar a tela de “Hello World” informando quantas vezes foi obtida e qual nome de worker está respondendo a requisição (para ter certeza que está balanceando a carga), como podemos ver na figura abaixo:

![](images/concorrencia3.png)

O arquivo **docker-compose.yml** exemplifica a boa prática:

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

Para efetuar a construção do balanceador de carga, temos o diretório web contendo arquivos Dockerfile (responsável por criar a imagem utilizada) e nginx.conf (arquivo de configuração do balanceador de carga utilizado).

Segue o conteúdo DockerFile do web:

```
FROM nginx:1.9

COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

E, o conteúdo do arquivo nginx.conf:

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

No arquivo de configuração acima, foram introduzidas algumas novidades. A primeira, **“resolver 127.0.0.11“**, é o serviço DNS interno do Docker. Usando essa abordagem é possível efetuar o balanceamento de carga via nome, usando recurso interno do Docker. Para mais detalhes sobre o funcionamento do DNS interno do Docker, veja esse documento ([https://docs.docker.com/engine/userguide/networking/configure-dns/](https://docs.docker.com/engine/userguide/networking/configure-dns/)) (apenas em inglês).

A segunda novidade, função set **$alias “apps”;**, responsável por especificar o nome **“apps”** usado na configuração do proxy reverso, em seguida **“proxy_pass http://$alias;“**. Vale salientar, o **“apps”** é o nome da rede especificada dentro do arquivo **docker-compose.yml**. Nesse caso, o balanceamento é feito para a rede, todo novo contêiner que entra nessa rede é automaticamente adicionado ao balanceamento de carga.

Para efetuar a construção do **worker** temos o diretório **worker**  contendo os arquivos **Dockerfile** (responsável por criar a imagem utilizada), **app.py** (aplicação usada em todos os capítulos) e **requirements.txt** (descreve as dependências do app.py).

Segue abaixo o conteúdo do arquivo **app.py** modificado para a prática:

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

Segue o conteúdo do **requirements.txt**:

```
flask==0.11.1
redis==2.10.5
```

E por fim, o **Dockerfile** do **worker** tem o seguinte conteúdo:

```
FROM python:2.7
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
COPY . /code
WORKDIR /code
CMD python app.py
```

No serviço **redis** não há construção da imagem, usaremos a imagem oficial para efeitos de exemplificação.

Para testar o que foi apresentado até então, realize o clone do repositório ([https://github.com/gomex/exemplo-12factor-docker](https://github.com/gomex/exemplo-12factor-docker)) e acesse a pasta **factor8**, executando o comando, abaixo, para iniciar os contêineres:

```
docker-compose up -d
```

Acesse os contêineres através do navegador na porta 80 do endereço localhost. Atualize a página e veja que apenas um nome aparece.

Por padrão, o Docker-Compose executa apenas uma instância de cada serviço explicitado no **docker-compose.yml**. Para aumentar a quantidade de contêineres **“worker”**, de um para dois, execute o comando abaixo:

```
docker-compose scale worker=2
```

Atualize a página no navegador e veja que o nome do host alterna entre duas possibilidades, ou seja, as requisições estão sendo balanceadas para ambos contêineres.

Nessa nova proposta de ambiente, o serviço **web** se encarrega de receber as requisições HTTP e fazer o balanceamento de carga. Então, o **worker** é responsável por processar as requisições, basicamente obter o nome de host, acessar o **redis** e a contagem de quantas vezes o serviço foi requisitado e, então, gerar o retorno para devolvê-lo ao serviço **web** que, por sua vez, responde ao usuário. Como podemos perceber, cada instância do ambiente tem função definida e, com isso, é mais fácil escalá-lo.

Aproveitamos para dar os créditos ao capitão [Marcosnils](https://twitter.com/marcosnils), que nos mostrou como é possível balancear carga pelo nome da rede docker.
