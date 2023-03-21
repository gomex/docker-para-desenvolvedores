# Configurações

Seguindo a lista do modelo [12factor](https://12factor.net/), **“Configurações”** é terceira boa prática.

Quando estamos criando um software, aplicamos determinado comportamento dentro do código e normalmente ele não é parametrizável. Para que a aplicação se comporte de forma diferente, será necessário mudar parte do código.

A necessidade de modificar o código para trocar o comportamento da aplicação, inviabiliza que, a mesma seja executa na máquina (desenvolvimento) da mesma forma que é usada para atender os usuários (produção). E, com isso, acabamos com a possibilidade de portabilidade. E, sem portabilidade, qual a vantagem de se usar contêineres, certo?

O objetivo da boa prática é viabilizar a configuração da aplicação sem a necessidade de modificar o código. Já que, o comportamento da aplicação varia de acordo com o ambiente onde é executada, as configurações devem considerar o ambiente.

Seguem alguns exemplo:

 - Configuração de banco de dados que, normalmente, são diferentes entre ambientes
 - Credenciais para acesso a serviços remotos (Ex.: DigitalOcean ou Twitter)
 - Qual nome de DNS será usado pela aplicação

Como já mencionamos, quando a configuração está estaticamente explícita no código, é necessário modificar manualmente e efetuar novo build dos binários a cada reconfiguração do sistema.

Como demonstramos na boa prática codebase, usamos uma variável de ambiente para modificar o volume que usaremos no redis. De certa forma, já estamos seguindo a boa prática, mas podemos ir além e mudarmos não somente o comportamento da infraestrutura, mas sim algo inerente ao código em si.

Segue a aplicação modificada:

```
from flask import Flask
from redis import Redis
import os
host_run=os.environ.get('HOST_RUN', '0.0.0.0')
debug=os.environ.get('DEBUG', 'True')
app = Flask(__name__)
redis = Redis(host='redis', port=6379)
@app.route('/')
def hello():
   redis.incr('hits')
   return 'Hello World! %s times.' % redis.get('hits')
if __name__ == "__main__":
   app.run(host=host_run, debug=debug)
```

Lembrando! Para acessar o código da prática, basta clonar [esse repositório](https://github.com/gomex/exemplo-12factor-docker) e acessar a pasta **“factor3“**.

Como podemos notar, adicionamos alguns parâmetros na configuração do endereço usado para iniciar a aplicação web que será parametrizada com base no valor da variável de ambiente **“HOST_RUN”**. E, a possibilidade de efetuar, ou não, o debug da aplicação com a variável de ambiente **“DEBUG“**.

Vale salientar: nesse caso a variável de ambiente precisa ser passada para o contêiner, não basta ter a variável no Docker Host. É preciso enviá-la para o contêiner usando o parâmetro “-e”, caso utilize o comando “docker container run” ou, a instrução “environment” no docker-compose.yml:

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

Para executar o Docker-Compose, deveríamos fazer da seguinte maneira:

```
export HOST_RUN="0.0.0.0"; export DEBUG=True ; docker-compose up -d
```

No comando acima, usamos as variáveis de ambiente **“HOST_RUN”** e **“DEBUG”** do Docker Host para enviar às variáveis de ambiente com os mesmos nomes dentro do contêiner que, por sua vez, é consumido pelo código Python. Caso não haja parâmetros, o contêiner assume os valores padrões estipulados no código.

Essa boa prática é seguida com ajuda do Docker, pois o código é o mesmo e, a configuração, um anexo da solução que pode ser parametrizada de maneira distinta com base no que for configurado nas variáveis de ambiente.

Se a aplicação crescer, as variáveis podem ser carregadas em arquivos e parametrizadas no docker-compose.yml com a opção “env_file”.
